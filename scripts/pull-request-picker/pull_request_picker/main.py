from collections import defaultdict
from typing import List, Tuple
import os
import sys
import random
from datetime import datetime, timedelta, timezone
from dateutil.relativedelta import relativedelta, SU
from dotenv import load_dotenv
from github import Github, GithubException
from github.Issue import Issue

# --------- Configuration ---------

load_dotenv()

# GitHub Personal Access Token (ensure it has repo and read:org access)
GITHUB_TOKEN: str = os.getenv("GITHUB_TOKEN", "")

# GitHub Organization and Team Configuration
ORGANIZATION: str = os.getenv("GITHUB_ORGANIZATION", "")
TEAM_SLUG: str = os.getenv("GITHUB_TEAM_SLUG", "")

# Alternatively, you can use TEAM_ID if you prefer (see note below)
# Repository to search PRs in (owner/repo). If multiple, make this a list
REPOSITORIES: List[str] = (
    os.getenv("GITHUB_REPOSITORIES", "").split(",")
    if os.getenv("GITHUB_REPOSITORIES")
    else []
)

# Number of PRs to select randomly for review
NUMBER_OF_PRS_TO_SELECT: int = int(os.getenv("NUMBER_OF_PRS", "5"))

# --------- End of Configuration ---------


def get_last_week_date_range() -> Tuple[datetime, datetime]:
    today = datetime.now(timezone.utc)
    # Find last Sunday
    last_sunday = today + relativedelta(weekday=SU(-1))
    # Last week's Sunday
    last_sunday = last_sunday - timedelta(weeks=1)
    # Last week's Saturday
    last_saturday = last_sunday + timedelta(days=6)

    # Normalize to midnight UTC for start and end of the week
    start_date = datetime(last_sunday.year, last_sunday.month, last_sunday.day)
    end_date = datetime(
        last_saturday.year, last_saturday.month, last_saturday.day, 23, 59, 59
    )

    return start_date, end_date


def fetch_team_members(g: Github, org_name: str, team_slug: str) -> List[str]:
    try:
        org = g.get_organization(org_name)
    except GithubException as e:
        print(f"Error accessing organization '{org_name}': {e}")
        sys.exit(1)

    try:
        team = org.get_team_by_slug(team_slug)
    except GithubException as e:
        print(f"Error accessing team '{team_slug}' in organization '{org_name}': {e}")
        sys.exit(1)

    try:
        members = team.get_members()
        member_logins = [member.login for member in members]
        print(f"Retrieved {len(member_logins)} member(s) from team '{team_slug}'.")
        return member_logins
    except GithubException as e:
        print(f"Error fetching members of team '{team_slug}': {e}")
        sys.exit(1)


def fetch_prs(
    g: Github,
    repo_name: str,
    users: List[str],
    start_date: datetime,
    end_date: datetime,
    number: int,
) -> List[Issue]:
    query = f"is:pr repo:{repo_name} created:{start_date.strftime('%Y-%m-%d')}..{end_date.strftime('%Y-%m-%d')} is:merged"

    prs = g.search_issues(query=query, sort="created", order="desc")

    filtered_user_prs = [
        pr for pr in prs if pr.user is not None and pr.user.login in users
    ]

    random.shuffle(filtered_user_prs)

    filtered_prs = []
    repo = g.get_repo(repo_name)
    checked_prs = set()

    while len(filtered_prs) < number and len(checked_prs) < len(filtered_user_prs):
        pr = random.choice(filtered_user_prs)
        if pr.number in checked_prs:
            continue

        checked_prs.add(pr.number)

        pull_request = repo.get_pull(pr.number)
        total_changes = pull_request.additions + pull_request.deletions

        if total_changes > 50:
            filtered_prs.append(pr)
        else:
            print(f"Skip a small PR: {pr.title}")

    print(
        f"Found {len(filtered_prs)} PR(s) in '{repo_name}' from specified team members."
    )
    return filtered_prs


def select_random_prs(prs: List[Issue], number: int) -> List[Issue]:
    if len(prs) < number:
        print(f"Only {len(prs)} PR(s) available. Selecting all.")
        return prs
    return random.sample(prs, number)


def main() -> None:
    if not GITHUB_TOKEN:
        print(
            "Error: GitHub token not set. Please set the GITHUB_TOKEN environment variable."
        )
        sys.exit(1)

    g = Github(GITHUB_TOKEN)

    start_date, end_date = get_last_week_date_range()
    print(
        f"Fetching PRs created between {start_date.strftime('%Y-%m-%d')} and {end_date.strftime('%Y-%m-%d')}"
    )

    target_users = fetch_team_members(g, ORGANIZATION, TEAM_SLUG)
    if not target_users:
        print("No team members found. Exiting.")
        sys.exit(0)

    all_filtered_prs: List[Issue] = []

    for repo in REPOSITORIES:
        prs = fetch_prs(
            g, repo, target_users, start_date, end_date, NUMBER_OF_PRS_TO_SELECT
        )
        all_filtered_prs.extend(prs)

    if not all_filtered_prs:
        print("No PRs found for the specified criteria.")
        sys.exit(0)

    for pr in all_filtered_prs:
        print(
            f"- [{pr.repository.full_name}] #{pr.number} {pr.title} by {pr.user.login} ({pr.html_url})"
        )


if __name__ == "__main__":
    main()
