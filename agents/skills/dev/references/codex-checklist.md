# Codex Checklist

Use this checklist only when the current harness is Codex. If any required check
fails, STOP the /dev pipeline and report the failed check plus the repair needed.

## Required Checks

| Capability | Required provider | How to verify | Repair hint |
|---|---|---|---|
| Subagent delegation | `multi_agent_v1.spawn_agent` or the current Codex subagent tool | Confirm the tool is available; use tool discovery only to expose the subagent tool, then verify it appeared | Enable Codex multi-agent tools or run /dev in a Codex environment that exposes them |
| Skill discovery | Current Codex skill list and `tool_search` when needed | Confirm required skills/tools are visible in the current session | Install or enable the missing Codex skill/plugin |
| Intent alignment | `mattpocock-skills:grill-with-docs` | Confirm the skill is available | Install or enable `mattpocock-skills` for Codex |
| Design | `mattpocock-skills:codebase-design` | Confirm the skill is available | Install or enable `mattpocock-skills` for Codex |
| Build vs. buy | A named `managing-dependencies` skill/plugin exposed in Codex | Confirm the capability is available by name | Install or expose the dependency-management skill before running /dev |
| Test scenarios | A named PM test-scenarios skill exposed in Codex | Confirm the capability is available by name | Install or expose the PM test-scenarios skill before running /dev |
| TDD | `mattpocock-skills:tdd` | Confirm the skill is available | Install or enable `mattpocock-skills` for Codex |
| Review | `mattpocock-skills:review` when a fixed point/spec review fits the run, or an explicitly exposed Codex code-review capability | Confirm the skill/tool is available by name and matches the review shape needed for this run | Install or enable the review capability |
| Ponytail | Active Ponytail instructions or `ponytail:ponytail` skill | Confirm Ponytail is active in the current instructions or visible as an enabled skill | Enable Ponytail for this Codex session before running /dev |
| Library docs | `context7:resolve-library-id` and `context7:query-docs`, or an explicitly exposed docs tool named in the Codex tool list | Confirm the docs tool is available before choosing a library | Enable the docs lookup provider required by this Codex environment |

## Skill Graph

After preflight passes, invoke these providers for the matching pipeline steps.
Do not replace a listed provider with an inline imitation.

| Pipeline step | Skill/provider to invoke |
|---|---|
| 1. Align intent | `mattpocock-skills:grill-with-docs` |
| 2. Design seams | `mattpocock-skills:codebase-design` |
| 3. Build vs. buy | `managing-dependencies` |
| 3. Library docs | `context7:resolve-library-id`, then `context7:query-docs` when a library is chosen |
| 4. Test scenarios | `pm-execution:test-scenarios` with `PRODUCT`, `USER_STORY`, and `CONTEXT` |
| 5. Implement via subagent | `multi_agent_v1.spawn_agent` plus `mattpocock-skills:tdd` in the implementation subagent prompt |
| 6. Review | `multi_agent_v1.spawn_agent` plus `mattpocock-skills:review` when fixed-point/spec review fits the run, or the selected Codex code-review provider |

## Config Integrity

- Do not inspect `~/.claude` as evidence for Codex readiness. Claude Code plugin
  state does not prove Codex skill or tool availability.
- If Codex tool discovery fails, reports an error, or cannot expose a required
  tool, stop and report that exact failure.
- Do not emulate a missing skill inline. The point of preflight is to reveal and
  repair harness drift.

## Completion Criteria

Preflight passes only after every required capability above is verified in the
current Codex session.
