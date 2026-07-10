---
name: harmony-page-incremental
description: Add or modify UI blocks on an existing HarmonyOS page with minimal edits and compile verification.
---

# Harmony Page Incremental Skill

## Description
Use this skill when the user asks to add a section, component, or feature to an existing HarmonyOS page, or to modify existing behavior. The page already exists; the task is to locate the right insertion point and make minimal, focused edits.

## When to use
- User asks to "加个XX"、"在首页加个"、"给列表加个"、"给XX页面加个"、"加个轮播"、"加下拉刷新"、"加个搜索框"、"add a XX to"、"add XX section"、"modify the XX".
- Target page is already in the project; not creating a brand-new page from scratch.

## Mandatory workflow

1. **Clarify target**:
   - If which page or where to insert is ambiguous, ask ONE focused question.
   - Otherwise, infer from user description and proceed immediately.

2. **Locate target page and insertion point**:
   - Identify the target page file (e.g. `Index.ets`, `Detail.ets`).
   - Read the full page content to understand its structure (layout hierarchy, `@Builder` blocks, state).
   - Determine the insertion point: which `Column`/`Row`/`build()` body, which `@Builder`, or before/after which existing block.

3. **Implement incrementally**:
   - Follow the `harmony-arkts` skill for ArkTS rules.
   - Follow the `harmony-ui` skill for layout and state management.
   - Match existing code style (indentation, naming, `@Builder` usage).
   - Do not reference icon or resource names unless confirmed in `resources/`; use safe placeholders.
   - Reference `kb/harmony-api-cheatsheet.md` for component/API lookup.
   - Avoid touching unrelated code; only add or modify the requested block.

4. **Compile verify**:
   - Run `hmos_compilation` after edits.
   - Fix all compile errors before finalizing.
   - If compile still fails after one fix attempt, report root cause with exact file path and line number.

5. **Delivery output**:

   | Item | Detail |
   |---|---|
   | Updated files | List with per-file change summary |
   | Inserted/modified block | Brief description of what was added or changed |
   | Compile | ✅ success / ❌ failed (reason + file:line) |

## Guardrails
- Do not assume icon/resource names exist; verify first or use safe placeholders.
- Do not use unsupported ArkTS patterns (unsafe object literal typing, unsupported modifiers, etc.).
- Do not delete or refactor unrelated code; keep edits minimal.
- Do not modify other pages or shared components unless the user explicitly asks.
- Preserve existing layout structure; insert within the intended parent, do not break nesting.
