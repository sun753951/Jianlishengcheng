---
name: harmony-ui
description: Best practices for implementing HarmonyOS UI components with ArkUI declarative syntax.
---

# Harmony UI Implementation Skill

## Description
Best practices for implementing HarmonyOS UI components with ArkUI declarative syntax.

## Instructions
When building UI components:

1. **Layout**: Use `Column`, `Row`, `Stack`, `Flex`, `Grid`, `List` for layout. Avoid absolute positioning.
2. **Responsive**: Use `vp` units, percentage widths, and `GridRow`/`GridCol` for responsive design.
3. **Navigation**: Use `Navigation`, `NavRouter`, `NavDestination` for page routing.
4. **State Management**:
   - `@State` for component-local state
   - `@Prop` for one-way parent-to-child binding
   - `@Link` for two-way binding
   - `@Provide`/`@Consume` for cross-component state
   - `AppStorage` for global persistent state
5. **Animation**: Use `animateTo()` for property animations, `.transition()` for enter/exit effects.
6. **Custom Components**: Create with `@Component` decorator, expose with `@Builder` for reusable UI blocks.
7. **Performance**:
   - Use `LazyForEach` with `IDataSource` for large lists
   - Minimize `@State` scope to reduce re-renders
   - Use `@Reusable` for frequently created/destroyed components
