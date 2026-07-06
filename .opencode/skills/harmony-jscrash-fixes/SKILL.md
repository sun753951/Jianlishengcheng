---
name: harmony-jscrash-fixes
description: Triage and fix ArkTS or JavaScript runtime crashes. MUST load this skill immediately when the user provides jscrash logs, uncaught exceptions, launch white screen evidence, or runtime stack traces.
---

# Harmony JSCrash Fixes

This skill provides a stable workflow for diagnosing and fixing ArkTS or JavaScript runtime crashes with minimal edits.

## Symptoms

Load this skill when the issue looks like one of these:

- `TypeError`, `ReferenceError`, `RangeError`, `SyntaxError`, or `BusinessError` in runtime logs
- App exits, flashes back, or shows a white screen after launch
- User provides a `jscrash` log, a stack trace, or a temporary log file with `@file`
- Build succeeds, but runtime behavior fails immediately

## Quick Triage

1. Load this skill first so the runtime crash workflow is in context before editing.
2. If the user already provided a crash log, call `hmos_jscrash_report` first with the raw log text.
3. If the user only described symptoms, call `hmos_jscrash_report` without `crash_log` to inspect recent device hilog. Use `hmos_run` + `hdc_log` only when launch evidence or raw device logs are still needed.
4. Extract four anchors before editing:
   - error type
   - error message
   - top stack frame
   - suspected file or page
5. If the user provides reproduction steps, trust those steps over a naive assumption from the stack alone. A crash inside `aboutToAppear`, `onPageShow`, or similar lifecycle code may still require a tap or navigation step if that page is not the entry page.
6. Read the suspected source files and nearby navigation entry points before changing code.
7. Make the smallest fix that removes the root cause.
8. Verify with `hmos_compilation` first.
9. After compilation succeeds, prefer `calibrate` as the final verification path whenever the repaired flow still depends on taps, typing, navigation, tab switching, or other UI interaction.
10. If `calibrate` is unavailable, blocked by the environment, or fails to complete, fall back to `hmos_run` and `hdc_log` to continue collecting runtime evidence.

## Common Crash Signatures

| Signature | Typical Cause | First Fix Direction |
|---|---|---|
| `TypeError` on property access | Null or undefined state during render or lifecycle | Guard null state, initialize state earlier, or move logic to a safer lifecycle point |
| `ReferenceError` | Wrong symbol scope, stale import, missing variable | Fix symbol ownership, import path, or callback capture |
| `RangeError` | Invalid index, recursion loop, oversized array access | Add bounds checks, break loops, or clamp indexes |
| `BusinessError` / `ParameterError` | Framework API preconditions not met | Validate arguments, permissions, or API call timing |
| White screen with sparse logs | Crash during page setup, resource read, or route parsing | Inspect entry page, route params, resource loading, and `aboutToAppear` logic |

## Interpretation Rules

- Prefer the first application stack frame over framework noise.
- Treat the first concrete `.ets`, `.ts`, or `.js` path in the stack as the starting point, not the final truth.
- If the log contains both a UI symptom and a JS exception, prioritize the exception.
- If the user gives reproduction steps, those steps outrank a simplistic "launch crash" guess from the stack.
- If the stack points to a non-entry page or view reached through tabs, buttons, list items, or routing, treat the crash as interaction-triggered until proven otherwise.
- If the stack is missing, use the nearest error line plus the page or bundle context to narrow the search.
- Do not refactor broadly. Fix the crash path first, then verify.

## Verification Standard

- `PASS`: compilation succeeds and runtime evidence shows the crash is resolved
- `SOFT_FAIL`: code fix is applied but runtime verification is blocked by environment, device, or incomplete reproduction steps
- `FAIL`: runtime evidence still shows the original crash or a regression

## Tool Usage

- `hmos_jscrash_report`: normalize raw logs into error type, stack, suspected file, and next action
- `hmos_compilation`: mandatory verification before finalizing a code fix
- `calibrate`: preferred final verification path for interactive post-fix validation
- `hmos_run`: fallback when `calibrate` cannot be used to finish verification, or when you need install/start only
- `hdc_log`: use for raw evidence collection and before/after comparison

## Constraints

- Never claim a crash fix from prompt reasoning alone.
- Never replace a root-cause fix with retries, artificial delays, or broad defensive rewrites.
- If the crash involves unfamiliar `@ohos.*` or `@kit.*` APIs, research the API constraints before editing.
- Do not treat `hmos_run` alone as sufficient validation for an interactive user flow unless `calibrate` is unavailable, blocked, or has already failed to complete.
