# Codex Checklist

Use this checklist only when the current harness is Codex. If any required check
fails, STOP the `$dev` pipeline and report the failed check plus the repair needed.

## Required Checks

| Capability | Required provider | How to verify | Repair hint |
|---|---|---|---|
| Subagent delegation | Current Codex subagent workflow | Confirm the current runtime and instructions permit skill-directed delegation | Enable Codex agents or run the dev pipeline in a Codex environment that permits subagents |
| Intent alignment | `mattpocock-skills:grilling` with `mattpocock-skills:domain-modeling` | Confirm both skills are available | Install or enable `mattpocock-skills` for Codex |
| Design | `mattpocock-skills:codebase-design` | Confirm the skill is available | Install or enable `mattpocock-skills` for Codex |
| Build vs. buy | `managing-dependencies:managing-dependencies` | Confirm the skill is available | Install or enable `managing-dependencies` for Codex |
| Test scenarios | `pm-execution:test-scenarios` | Confirm the skill is available | Install or enable `pm-execution` for Codex |
| TDD | `mattpocock-skills:tdd` | Confirm the skill is available | Install or enable `mattpocock-skills` for Codex |
| Review | `mattpocock-skills:code-review` | Confirm the skill is available by name and matches the review shape needed for this run | Install or enable the review capability |
| Ponytail | Active Ponytail instructions or `ponytail:ponytail` skill | Confirm Ponytail is active in the current instructions or visible as an enabled skill | Enable Ponytail for this Codex session before running `$dev` |
| Library docs | `context7:context7-mcp` or another current library-docs provider | Confirm the skill/provider is available. MCP tools may load only when the skill is invoked; require a successful lookup before relying on library docs | Install, enable, or authenticate the docs provider required by this Codex environment |

## Skill Graph

After preflight passes, invoke these providers for the matching pipeline steps.
Do not replace a listed provider with an inline imitation.

| Pipeline step | Skill/provider to invoke |
|---|---|
| 1. Align intent | `mattpocock-skills:grilling` with `mattpocock-skills:domain-modeling` |
| 2. Design seams | `mattpocock-skills:codebase-design` |
| 3. Build vs. buy | `managing-dependencies:managing-dependencies` |
| 3. Library docs | `context7:context7-mcp` when a library is chosen; follow its resolve-then-query workflow |
| 4. Test scenarios | `pm-execution:test-scenarios` with `PRODUCT`, `USER_STORY`, and `CONTEXT` |
| 5. Reviewable proposal, if selected | `mattpocock-skills:to-spec`, then `personal-voice` |
| 6. Implement via subagent | Current Codex subagent workflow plus `mattpocock-skills:tdd` in the implementation subagent prompt |
| 7. Review | Current Codex subagent workflow plus `mattpocock-skills:code-review` |
| 8. Manual E2E acceptance | Orchestrator-authored — no external provider; write the verification guide per SKILL.md step 8 |

## Config Integrity

- Do not inspect `~/.claude` as evidence for Codex readiness. Claude Code plugin
  state does not prove Codex skill or tool availability.
- Treat the current session's skill list, instructions, and runtime policy as
  primary evidence. Installed plugin or MCP state is supporting evidence only.
- Do not fail only because a plugin's MCP tools are absent from the initial tool
  list. Invoke the named skill when the pipeline needs it, then stop on an actual
  lookup, authentication, or tool-loading failure.
- Do not emulate a missing skill inline. The point of preflight is to reveal and
  repair harness drift.

## Completion Criteria

Preflight passes only after every required capability above is visible or active
in the current Codex session. Providers that load tools on invocation must still
succeed when their pipeline step uses them.
