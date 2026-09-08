# MiniMax Code Checklist

Use this checklist only when the current harness is MiniMax Code. If any
required check fails, STOP the /dev pipeline and report the failed check plus the
repair needed.

Verify skills against the current session's skill catalog (`available_skills` /
the `skill` tool), and tools against the current session's tool list. Do not
verify by inspecting data-directory paths on disk.

## Required Checks

| Capability | Required provider | How to verify | Repair hint |
|---|---|---|---|
| Subagent delegation | The `task` tool with `worker` and `verifier` agents (plus `task_append`/`task_output` for follow-up) | Confirm `task` is in the current tool list and current runtime policy permits producer implementation subagents for /dev | Run /dev in a MiniMax Code session that exposes `task`, or update the local runtime/policy so implementation subagents are explicitly allowed for /dev |
| Intent alignment | `mattpocock-skills:grilling` with `mattpocock-skills:domain-modeling` | Confirm both skills are in the session skill catalog | Install or enable `mattpocock-skills` for MiniMax Code |
| Design | `mattpocock-skills:codebase-design` | Confirm the skill is in the session skill catalog | Install or enable `mattpocock-skills` for MiniMax Code |
| Build vs. buy | `managing-dependencies` | Confirm the skill is in the session skill catalog | Install or enable `managing-dependencies` for MiniMax Code |
| Test scenarios | `test-scenarios` | Confirm the skill is in the session skill catalog | Install or enable `test-scenarios` for MiniMax Code |
| TDD | `mattpocock-skills:tdd` | Confirm the skill is in the session skill catalog | Install or enable `mattpocock-skills` for MiniMax Code |
| Review | `task` `verifier` agent invoking `mattpocock-skills:code-review` | Confirm `task` is available and the `code-review` skill is in the session skill catalog; the `verifier` contract is review-only by construction (reports findings, does not edit source) | Enable `task` delegation and install or enable `mattpocock-skills` for MiniMax Code |
| Ponytail | Active Ponytail instructions or the `ponytail` skill | Confirm Ponytail is active in the current instructions or visible in the session skill catalog | Enable Ponytail for this MiniMax Code session before running /dev |
| Library docs | Context7 MCP tools (resolve-library-id then query-documentation) when exposed; otherwise `web_search`/`web_fetch` plus local package manifests | Confirm at least one current docs lookup path is available; require a successful lookup before relying on library docs | Enable Context7 or network/docs tools, or avoid adding libraries whose current usage cannot be verified |

## Skill Graph

After preflight passes, invoke these providers for the matching pipeline steps.
Do not replace a listed provider with an inline imitation. If a listed skill is
genuinely absent from the session catalog and the user explicitly waives it for
this run, record the waiver before the orchestrator covers that step itself.

| Pipeline step | Skill/provider to invoke |
|---|---|
| 1. Align intent | `mattpocock-skills:grilling` with `mattpocock-skills:domain-modeling` |
| 2. Design seams | `mattpocock-skills:codebase-design` |
| 3. Build vs. buy | `managing-dependencies` |
| 3. Library docs | Context7 MCP tools when a library is chosen; follow the resolve-then-query workflow. Fall back to `web_search`/`web_fetch` |
| 4. Test scenarios | `test-scenarios` with `PRODUCT`, `USER_STORY`, and `CONTEXT` |
| 5. Reviewable proposal, if selected | `mattpocock-skills:to-spec`, then `personal-voice` |
| 6. Implement via subagent | `task` with `agent_name: "worker"`, with `mattpocock-skills:tdd` and explicit /dev TDD instructions in the subagent prompt |
| 7. Review | `task` with `agent_name: "verifier"`, with `mattpocock-skills:code-review` in the subagent prompt |
| 8. Manual E2E acceptance | Orchestrator-authored — no external provider; write the verification guide per SKILL.md step 8 |

For step 4, use `PRODUCT` = the project or area under change; `USER_STORY` = the
approved spec and acceptance criteria from step 1; `CONTEXT` = the design note,
dependency decisions, docs notes, constraints, and risk areas.

## Config Integrity

- Do not inspect Claude Code or Codex config as evidence for MiniMax Code readiness.
  Their plugin state does not prove MiniMax Code tool availability.
- Do not inspect MiniMax Code data-directory paths on disk either — the data dir
  has moved between releases, and stale paths from notes or memory drift. The
  session's injected skill catalog and tool list are the primary evidence.
- Skills load their SKILL.md on invocation. Do not fail preflight only because a
  skill's tools or full instructions are absent before invocation; invoke the
  named skill when the pipeline needs it, then stop on an actual loading or
  execution failure.
- Treat permission-gate denial, malformed config, unreadable project files, or a
  failed `task` spawn as hard failures. Report the exact failure and stop.
- Do not emulate missing delegation by doing /dev implementation work in the main
  orchestrator thread. The /dev pipeline requires clean orchestration.
- If local runtime policy forbids producer implementation subagents, preflight
  fails unless the user explicitly waives the /dev subagent requirement for this
  run.

## Completion Criteria

Preflight passes only after every required capability above is visible or active
in the current MiniMax Code session and current runtime policy permits the
required /dev use. Providers that load on invocation must still succeed when
their pipeline step uses them.
