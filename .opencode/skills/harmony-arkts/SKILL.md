---
name: harmony-arkts
description: Guidelines for writing correct ArkTS code in HarmonyOS projects.
---

# Harmony ArkTS Coding Skill

## Description
Guidelines for writing correct ArkTS code in HarmonyOS projects.

## Instructions
When writing ArkTS code:

1. **Type Safety**: Never use `any` or `unknown`. All types must be explicit.
2. **Decorators**: Use `@Entry`, `@Component`, `@State`, `@Prop`, `@Link`, `@Builder` correctly.
3. **Lifecycle**: Implement `aboutToAppear()` and `aboutToDisappear()` for resource management.
4. **UI Declaration**: Use declarative UI with `build()` method. No imperative DOM manipulation.
5. **Resource Access**: Use `$r('app.string.key')` for resource references, not hardcoded strings.
6. **Module Imports**: Import from `@ohos.*` packages, not Node.js or browser APIs.
7. **Async Patterns**: Use `async/await` with `TaskPool` for CPU-intensive work, not raw `Promise`.
8. **Permissions**: Declare required permissions in `module.json5`, request dynamic permissions at runtime.

## Anti-patterns
- Do not use `eval()` or dynamic code execution.
- Do not access `globalThis` for state management.
- Do not use `setTimeout`/`setInterval` for animations; use `animateTo`.
- Do not mutate `@State` arrays/objects directly; reassign to trigger re-render.
- Do not put imperative statements (console.log, assignments, function calls) directly inside `build()` body or `@Builder` functions — these are declarative UI contexts.
- Do not use anonymous object literals without type context (triggers `arkts-no-untyped-obj-literals`).
