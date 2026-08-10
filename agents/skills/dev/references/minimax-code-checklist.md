# MiniMax Code Checklist

Use this checklist only when the current harness is MiniMax Code. If any
required check fails, STOP the /dev pipeline and report the failed check plus the
repair needed.

## Required Checks

| Capability | Required provider | How to verify | Repair hint |
|---|---|---|---|
| Subagent delegation | MiniMax Code subagent delegation exposed in the current session, preferably the `task` tool or a policy-approved `mavis communication send --command spawn` path | Confirm the current tool list exposes a subagent/delegation mechanism and that current runtime policy permits the required /dev use for implementation and review | Run /dev in a MiniMax Code session that exposes delegation, or update the local runtime/policy so producer implementation subagents are explicitly allowed for /dev |
| Intent alignment | Built-in orchestrator using the /dev alignment gate | Confirm the orchestrator can produce an approved spec and stop for user sign-off | If a dedicated alignment skill is required for this environment, install or expose it and update this checklist to name it |
| Design | Built-in orchestrator using the /dev design gate | Confirm the orchestrator can produce a design note and ADR updates when appropriate | If a dedicated design skill is required for this environment, install or expose it and update this checklist to name it |
| Build vs. buy | Built-in orchestrator using repository inspection plus available docs/search tools | Confirm file, grep, package-manifest inspection, and current docs/search lookup tools are available | Expose local file tools and at least one current-information/docs lookup provider |
| Test scenarios | Built-in orchestrator writing the scenario contract file | Confirm local file write access is available for the target project root | Grant write access to the project root or choose an approved scenario contract path |
| TDD | Implementation subagent instructed to follow /dev TDD discipline | Confirm the selected implementation delegation path can run tests, edit files, and report concise evidence | Fix delegation permissions/tooling or explicitly waive /dev's subagent requirement for this run |
| Review | Verifier-only review worker via MiniMax Code communication spawn or local review delegation | Confirm a review-only worker can be spawned and is prohibited from editing source files | Enable MiniMax Code communication spawn or another review-only delegation path |
| Ponytail | Current session instructions and project conventions that enforce lean, minimal, scoped code | Confirm current instructions include lean implementation discipline and that the implementation worker will receive it | Add or enable Ponytail-equivalent instructions for the session/worker |
| Library docs | `web_search`/`web_fetch` for public docs, plus local package manifests; use any exposed docs-specific provider when available | Confirm at least one current docs lookup path is available before choosing a new library | Enable network/docs tools or avoid adding libraries whose current usage cannot be verified |

## Skill Graph

After preflight passes, invoke these providers for the matching pipeline steps.
Do not replace a listed provider with an inline imitation unless this checklist
explicitly names the built-in orchestrator as the provider.

| Pipeline step | Skill/provider to invoke |
|---|---|
| 1. Align intent | Built-in orchestrator alignment gate: produce approved spec and wait for user confirmation |
| 2. Design seams | Built-in orchestrator design gate: produce design note and ADR path when needed |
| 3. Build vs. buy | Built-in orchestrator repository inspection plus docs/search lookup |
| 3. Library docs | `web_search`/`web_fetch` or a docs-specific provider exposed in the current MiniMax Code tool list |
| 4. Test scenarios | Built-in orchestrator scenario contract writer using the /dev table shape |
| 5. Implement via subagent | MiniMax Code subagent delegation path verified in preflight, with explicit /dev TDD instructions |
| 6. Review | MiniMax Code review-only delegation path verified in preflight |
| 7. Manual E2E acceptance | Orchestrator-authored — no external provider; write the verification guide per SKILL.md step 7 |

For step 4, use `PRODUCT` = the project or area under change; `USER_STORY` = the
approved spec and acceptance criteria from step 1; `CONTEXT` = the design note,
dependency decisions, docs notes, constraints, and risk areas.

## Config Integrity

- Do not inspect Claude Code or Codex config as evidence for MiniMax Code readiness.
  Their plugin state does not prove MiniMax Code tool availability.
- Treat unavailable local tools, permission-gate denial, malformed config,
  unreadable project files, or failed delegation spawn as hard failures. Report
  the exact failure and stop.
- Do not emulate missing delegation by doing /dev implementation work in the main
  orchestrator thread. The /dev pipeline requires clean orchestration.
- If local runtime policy forbids producer implementation subagents, preflight
  fails unless the user explicitly waives the /dev subagent requirement for this
  run.

## Completion Criteria

Preflight passes only after every required capability above is verified in the
current MiniMax Code session and current runtime policy permits the
required /dev use.