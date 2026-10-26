#!/usr/bin/env python3
"""Read the local Anki collection read-only and build importable TSV files.

Commands:
  decks                         list decks with new / review counts
  search PATTERN [--deck NAME]  regex search over card fronts and tags
  sample DECK [-n N]            print raw fields of N notes in a deck
  build CARDS.json --deck NAME --batch TAG --name SLUG [--out DIR]

CARDS.json is a list of objects with front, answer, source, type, tags.
type is 原文 (what a source says) or 综合 (synthesized heuristic).
"""
import argparse
import datetime
import glob
import json
import os
import re
import shutil
import sqlite3
import statistics
import sys
import tempfile

TYPES = {"原文", "综合"}
MAX_ANSWER = 120
# Card shapes the user deleted far more often than others; each is a warning, not an error.
FRONT_CHECKS = [
    (re.compile(r"谁提出|提出者|由谁|最早由|哪个团队|哪一年|成立于|创始人|全称|量表|多大规模|比较了哪"
                r"|who (first )?(proposed|coined|introduced)|in what year|which (scale|dataset)|sample size", re.I),
     "asks for provenance; move it to the source"),
    (re.compile(r"效应量|效果量|证据(强度|状态|质量)|有多硬|元分析|缓解率|effect size|meta-analy|how strong is the evidence", re.I),
     "asks about evidence strength; note it in the source"),
    (re.compile(r"^\s*(什么是\S{1,14}[？?]|what is (an? |the )?[\w -]{1,30}\?)\s*$", re.I),
     "bare definition; ask why, when, or how it differs unless the name is worth recalling"),
]
HEADER = ["#separator:tab", "#html:true", "#notetype:Basic", "#deck:{deck}", "#tags column:3"]


def find_collection():
    env = os.environ.get("ANKI_COLLECTION")
    if env:
        return os.path.expanduser(env)
    paths = []
    for root in ("~/Library/Application Support/Anki2", "~/.local/share/Anki2"):
        paths += glob.glob(os.path.join(os.path.expanduser(root), "*", "collection.anki2"))
    if not paths:
        sys.exit("collection.anki2 not found. Set ANKI_COLLECTION to its path.")
    return max(paths, key=os.path.getmtime)


def open_copy():
    # Anki may hold a lock on the live file, so read a copy.
    src = find_collection()
    dst = os.path.join(tempfile.mkdtemp(prefix="anki-ro-"), "collection.anki2")
    shutil.copy2(src, dst)
    for suffix in ("-wal", "-shm"):
        if os.path.exists(src + suffix):
            shutil.copy2(src + suffix, dst + suffix)
    return src, sqlite3.connect(f"file:{dst}?mode=ro", uri=True)


def strip(html):
    return re.sub(r"<[^>]+>", "", html).replace("&nbsp;", " ").strip()


def deck_names(db):
    # Compare deck names in Python: the decks table uses Anki's custom collation.
    return {did: name.replace("\x1f", "::") for did, name in db.execute("select id, name from decks")}


def notes_with_deck(db):
    names = deck_names(db)
    for flds, tags, did in db.execute("select n.flds, n.tags, c.did from notes n join cards c on c.nid = n.id"):
        yield names.get(did, str(did)), flds.split("\x1f"), tags.strip()


def cmd_decks(args):
    src, db = open_copy()
    names = deck_names(db)
    mtime = datetime.datetime.fromtimestamp(os.path.getmtime(src))
    last = db.execute("select max(id) from revlog").fetchone()[0]
    print(f"collection: {src}")
    print(f"file modified: {mtime:%Y-%m-%d %H:%M}")
    if last:
        print(f"last review: {datetime.datetime.fromtimestamp(last / 1000):%Y-%m-%d %H:%M}")
    print("note: desktop data, current only as of the last desktop sync")
    rows = db.execute("select did, count(*), sum(type = 0), sum(type = 2) from cards group by did").fetchall()
    for did, total, new, review in sorted(rows, key=lambda r: -r[1]):
        print(f"{names.get(did, did)}\ttotal {total}\tnew {new}\treview {review}")


def cmd_search(args):
    _, db = open_copy()
    pattern = re.compile(args.pattern, re.IGNORECASE)
    hits = 0
    for deck, fields, tags in notes_with_deck(db):
        if args.deck and deck != args.deck:
            continue
        front = strip(fields[0])
        if pattern.search(front) or pattern.search(tags):
            back = strip(fields[1]) if len(fields) > 1 else ""
            print(f"[{deck}] {front[:100]} || {back[:60]} || {tags}")
            hits += 1
    print(f"{hits} matches")


def cmd_sample(args):
    _, db = open_copy()
    shown = 0
    for deck, fields, tags in notes_with_deck(db):
        if deck != args.deck:
            continue
        print(repr("\x1f".join(fields)))
        print(f"tags: {tags}\n")
        shown += 1
        if shown >= args.n:
            return
    if not shown:
        sys.exit(f"no cards in deck {args.deck!r}; check the name with the decks command")


def validate(cards, existing):
    errors, warnings, seen = [], [], set()
    for i, card in enumerate(cards, 1):
        for key in ("front", "answer", "source", "type", "tags"):
            if not str(card.get(key, "")).strip():
                errors.append(f"card {i}: missing {key}")
        for key in ("front", "answer", "source", "tags"):
            if re.search(r"[\t\r\n]", str(card.get(key, ""))):
                errors.append(f"card {i}: {key} contains a tab or newline")
        if card.get("type") not in TYPES:
            errors.append(f"card {i}: type must be one of {sorted(TYPES)}")
        front = str(card.get("front", "")).strip()
        if front in seen:
            errors.append(f"card {i}: front repeats another card in this batch: {front}")
        if front in existing:
            errors.append(f"card {i}: front already exists in the collection: {front}")
        seen.add(front)
        if len(str(card.get("answer", ""))) > MAX_ANSWER:
            warnings.append(f"card {i}: answer has {len(card['answer'])} characters, consider splitting: {front}")
        for pattern, message in FRONT_CHECKS:
            if pattern.search(front):
                warnings.append(f"card {i}: {message}: {front}")
    return errors, warnings


def cmd_build(args):
    with open(args.cards, encoding="utf-8") as f:
        cards = json.load(f)
    _, db = open_copy()
    existing = {strip(fields[0]) for _, fields, _ in notes_with_deck(db)}
    errors, warnings = validate(cards, existing)
    if errors:
        print("\n".join(errors))
        sys.exit(1)
    lines = [h.format(deck=args.deck) for h in HEADER]
    for card in cards:
        back = f"{card['answer']}<br><br><small>来源：{card['source']}<br>类型：{card['type']}</small>"
        tags = f"{card['tags']} 类型::{card['type']} {args.batch}"
        lines.append("\t".join([card["front"].strip(), back, tags]))
    name = f"anki-{args.batch}-{args.name}.tsv"
    out = os.path.join(os.path.expanduser(args.out), name)
    try:
        with open(out, "w", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")
    except PermissionError:
        out = os.path.join(tempfile.mkdtemp(prefix="anki-out-"), name)
        with open(out, "w", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")
        print(f"no permission to write {args.out}; wrote to a temp directory instead")
    lengths = [len(card["answer"]) for card in cards]
    counts = {t: sum(card["type"] == t for card in cards) for t in sorted(TYPES)}
    print(f"wrote {out}")
    print(f"{len(cards)} cards {counts}; answer length median {statistics.median(lengths)}, max {max(lengths)}")
    for warning in warnings:
        print("warning: " + warning)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("decks")
    p = sub.add_parser("search")
    p.add_argument("pattern")
    p.add_argument("--deck")
    p = sub.add_parser("sample")
    p.add_argument("deck")
    p.add_argument("-n", type=int, default=3)
    p = sub.add_parser("build")
    p.add_argument("cards")
    p.add_argument("--deck", required=True)
    p.add_argument("--batch", required=True, help="tag added to every card, e.g. YYMMDD")
    p.add_argument("--name", required=True, help="topic slug used in the file name")
    p.add_argument("--out", default="~/Downloads")
    args = parser.parse_args()
    {"decks": cmd_decks, "search": cmd_search, "sample": cmd_sample, "build": cmd_build}[args.cmd](args)


if __name__ == "__main__":
    main()
