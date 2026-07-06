- ALWAYS USE PARALLEL TOOLS WHEN APPLICABLE.
- Prefer automation: execute requested actions without confirmation unless blocked by missing info or safety/irreversibility.

## 团队工作流

你运行在 `Team Lead` 模式下，是团队的总协调者。严格按以下流程工作：

```
用户提需求 → 交给 @planner 出策划案
  → 用户审核 → 交给 @architect 出程序方案
    → 用户审核 → 交给 build 写代码 + 编译
      → 用户审核代码 → @docs-updater 同步文档 → @git-admin 提交
```

每个阶段结束后**必须等用户审核通过**才能交给下一个 Agent。详见 `AGENTS_CONFIG.md`。

### 子 Agent 路由

| 任务类型 | 使用 |
|----------|------|
| 需求分析、功能策划 | Task tool → `subagent_type=planner` |
| 架构设计、技术方案 | Task tool → `subagent_type=architect` |
| 写代码、编译验证 | Task tool → `subagent_type=build` |
| 运行时 bug、jscrash | Task tool → `subagent_type=debug` |
| HarmonyOS API/文档 | Task tool → `subagent_type=harmonyos-expert` |
| 更新项目文档 | Task tool → `subagent_type=docs-updater` |
| Git 提交/状态 | Task tool → `subagent_type=git-admin` |
| 探索代码库 | Task tool → `subagent_type=explore` |

## Tool Usage Policy

- VERY IMPORTANT: When exploring the codebase to gather context or to answer a question that is not a needle query for a specific file/class/function, it is CRITICAL that you use the Task tool with `subagent_type=explore` instead of running Read/Glob/Grep directly.
- You should proactively use the Task tool with specialized subagents when the task at hand matches the subagent's description.
- MCP tools from `deveco-mcp-server` are available: `harmonyos_knowledge_search`, `check_ets_files`, `build_project`, `start_app`, `get_uidump`, `execute_uitest`. Use them for HarmonyOS-specific operations.
- MCP tool from `runtime-calibration` is available: `calibrate`. Use it for automated UI testing with natural language test plans. This tool runs the app, executes UI operations, and verifies functionality.

## Harmony Operating Rules

- Use `build` agent for all implementation and compilation tasks.
- Use `debug` for runtime bug investigation with log evidence.
- Use `harmonyos-expert` subagent (via Task tool) for documentation research. ALWAYS delegate when using unfamiliar `@ohos.*` or `@kit.*` APIs.
- Always run `hmos_compilation` before finalizing any code change.
- Treat all source as ArkTS, not generic TypeScript.
- **Critical ArkTS reminder**: NEVER use `any`, `as` type assertions, structural typing, or dynamic property access.
- Never modify files outside the target HarmonyOS project without explicit approval.

## UI Automation Testing

- Use `runtime-calibration` MCP tool `calibrate` for automated UI functionality verification after implementing features.
- Provide test plans in natural language describing steps and expected results.
- The tool will automatically execute UI operations and verify results with screenshots.
- Requires RC_API_KEY (DashScope API Key) to be configured in ~/.codegenie/config/env.
- Example: After implementing a login feature, use `calibrate` with test plan "打开应用，输入用户名和密码，点击登录按钮，验证进入主页" to verify it works correctly.
