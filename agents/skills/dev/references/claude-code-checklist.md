# Claude Code Checklist

Use this checklist only when the current harness is Claude Code. If any required
check fails, STOP the /dev pipeline and report the failed check plus the repair
needed.

## Required Checks

| Capability | Required provider | How to verify | Repair hint |
|---|---|---|---|
| Subagent delegation | Claude Code Agent tool with `subagent_type: general-purpose` | Confirm the Agent tool is available in the current tool list | Enable the Agent tool or run /dev in a Claude Code environment that exposes it |
| Intent alignment | `mattpocock-skills:grill-with-docs` | Confirm the command or skill is available | `git clone --depth 1 https://github.com/mattpocock/skills.git ~/.claude/skills/mattpocock-skills` |
| Design | `mattpocock-skills:codebase-design` | Confirm the command or skill is available | `git clone --depth 1 https://github.com/mattpocock/skills.git ~/.claude/skills/mattpocock-skills` |
| Build vs. buy | `managing-dependencies:managing-dependencies` | Confirm the plugin command or skill is available | `/plugin marketplace add andrew/managing-dependencies`; then `/plugin install managing-dependencies@managing-dependencies` |
| Test scenarios | `/pm-execution:test-scenarios` | Confirm the PM command or skill is available | Install or enable the PM skills bundle |
| TDD | `mattpocock-skills:tdd` | Confirm the command or skill is available | `git clone --depth 1 https://github.com/mattpocock/skills.git ~/.claude/skills/mattpocock-skills` |
| Review | `/code-review` | Confirm the command or skill is available | Enable the built-in review command or the project review skill |
| Ponytail | `ponytail` plugin enabled and active | Inspect Claude Code plugin state and current instructions | `/plugin marketplace add https://github.com/DietrichGebert/ponytail.git`; then `/plugin install ponytail@ponytail` |
| Library docs | `context7:resolve-library-id` and `context7:query-docs` | Confirm both context7 MCP tools are available | Add context7 to Claude Code MCP config |

## Skill Graph

After preflight passes, invoke these providers for the matching pipeline steps.
Do not replace a listed provider with an inline imitation.

| Pipeline step | Skill/provider to invoke |
|---|---|
| 1. Align intent | `mattpocock-skills:grill-with-docs` |
| 2. Design seams | `mattpocock-skills:codebase-design` |
| 3. Build vs. buy | `managing-dependencies:managing-dependencies` |
| 3. Library docs | `context7:resolve-library-id`, then `context7:query-docs` when a library is chosen |
| 4. Test scenarios | `/pm-execution:test-scenarios` with `PRODUCT`, `USER_STORY`, and `CONTEXT` |
| 5. Implement via subagent | Claude Code Agent tool plus `mattpocock-skills:tdd` in the implementation subagent prompt |
| 6. Review | Claude Code Agent tool plus `/code-review` in the review subagent prompt |

For step 4, pass `/pm-execution:test-scenarios`: `PRODUCT` = the project or area
under change; `USER_STORY` = the approved spec and acceptance criteria from step 1;
`CONTEXT` = the design note, dependency decisions, docs notes, constraints, and risk
areas.

## Config Integrity

- If `~/.claude/settings.json` or `~/.claude/plugins/installed_plugins.json`
  must be inspected, malformed JSON, permission errors, or unreadable files are
  hard failures. Report the exact file and stop.
- Missing plugin records are missing dependencies. Broken config files are broken
  config files; do not collapse them into a generic missing-plugin report.
- Do not hand-copy upstream `SKILL.md` files into this repo to satisfy a missing
  dependency. Install or enable the provider properly.

## Completion Criteria

Preflight passes only after every required capability above is verified in the
current Claude Code session.
