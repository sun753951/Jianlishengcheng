---
name: harmony-page-zero-to-one
description: End-to-end workflow for generating a new HarmonyOS ArkUI page or full app from scratch and making it runnable.
---

# Harmony Page 0-1 Skill

## Description
Use this skill when the user asks for a brand-new HarmonyOS page or app from 0 to 1, including UI implementation, page registration, and compile verification.

## When to use
- User asks to "生成页面"、"做一个XX页面"、"从0到1搭页面"、"仿XX做鸿蒙页面"、"create a page"、"build a new screen".
- User asks to "做一个XX应用"、"仿XX做鸿蒙app"、"生成一个app"、"build an app"、"create an app".
- Task includes both page/app creation and runnable integration (not only small local edits).

---

## Step 0 — Distinguish: App vs Single Page, then infer structure immediately

**Before doing anything else**, determine whether the user wants a **full app** or a **single page**.

| Signal | Classification |
|---|---|
| Mentions multiple functions / tabs / sections (e.g. "首页、发现、我的") | Full App |
| Mentions a specific app product (e.g. "仿微信"、"仿淘宝"、"仿美团") | Full App |
| Uses words like "应用"、"app"、"软件" | Full App |
| Mentions only one screen / feature / page | Single Page |
| Uses words like "页面"、"界面"、"screen"、"page" (singular) | Single Page |

### CRITICAL: Never ask the user — you are the designer, always decide and proceed

You are a HarmonyOS app design expert. The user's job is to state what they want; **your job is to make every design decision**. Never delegate choices back to the user.

**For any app request — whether it is a well-known product or a completely made-up category — you must:**
1. Recall or reason about what similar real-world apps look like (e.g. "美食外卖 app" → think 美团外卖、饿了么 → infer their typical tab and page structure).
2. Design a reasonable tab structure yourself.
3. Start implementing immediately.

**You must NEVER ask questions such as:**
- "你希望包含哪些页面？"
- "需要几个 Tab？"
- "要不要商家详情页？"
- "需要购物车功能吗？"

These are your decisions to make, not the user's.

### How to infer tab structure for any app

Use this reasoning process:

1. **Identify the app category** from the user's description (外卖、电商、社交、出行、新闻、音乐、政务、教育、健康…).
2. **Recall similar real apps** in that category and their standard tab bars.
3. **Pick the most representative 3–5 tabs** that cover the core user journey.
4. **Name each tab** with a clear, functional label in Chinese.

Reference tab structures by category:

| App category | 推断的 Tab 结构 |
|---|---|
| 外卖 / 美食配送 | 首页 / 订单 / 我的 |
| 综合电商 | 首页 / 分类 / 购物车 / 我的 |
| 社交通讯 | 消息 / 通讯录 / 发现 / 我 |
| 出行导航 | 首页 / 行程 / 消息 / 我的 |
| 新闻资讯 | 首页 / 视频 / 通知 / 我的 |
| 音乐流媒体 | 首页 / 音乐馆 / 我的 |
| 生活服务 / 政务 | 首页 / 办事 / 消息 / 我的 |
| 在线教育 | 首页 / 课程 / 学习 / 我的 |
| 健康 / 运动 | 首页 / 运动 / 数据 / 我的 |
| 金融 / 银行 | 首页 / 理财 / 账单 / 我的 |
| 招聘求职 | 首页 / 消息 / 我的 |
| 旅行 / 酒店 | 首页 / 订单 / 收藏 / 我的 |

For categories not listed above, reason from first principles: what are the 3–5 core tasks a user of this app would need to do? Each core task becomes a Tab.

The ONLY case where you may ask ONE question is when the input is so vague that you cannot determine even the app category (e.g. bare "做个app" with no other context). In that case ask:
> "这个 App 主要是做什么的？（比如：外卖、社交、电商、工具类…）"

Once you know the category, proceed immediately without any further questions.

---

## Reference Library

All references are located at:
```
~/.codegenie/kernel/skills/harmony-page-zero-to-one/references/
  arkui_codegen_spec.md   — 工程级代码生成规格（架构、组件、状态管理、性能）
  module_v4_readme.md     — UI 模块库 schema 说明
  module_v4.json          — UI 模块库（大文件，用 grep 检索）
```

**Read `arkui_codegen_spec.md` at the start of every task. It defines the mandatory rules for architecture, directory layout, component usage, state management, and code quality.**

**Always consult `module_v4.json` before writing UI code from scratch.**

### Available module categories

| Label | 适用场景 |
|---|---|
| 搜索模块 | 各类搜索栏 |
| 图文信息展示模块 | 图文卡片、宫格、列表 |
| 快捷功能模块 | 功能入口、Tab 入口 |
| 账号信息模块 | 用户信息展示、积分、会员 |
| 订单信息展示模块 | 订单卡片、住宿、出行 |
| 新闻信息展示模块 | 资讯列表、新闻卡片 |
| 导航入口模块 | 点单、商品列表 |
| 店铺信息模块 | 商家信息、拼单 |
| 订票模块 | 交通/出行订票 |
| 筛选模块 | 标签筛选、Tab 切换 |
| 购物车 | 购物车列表 |
| 教育模块 | 课程列表、直播课 |

### How to look up modules

1. **Read the schema first** (only once per session):
   ```
   Read ~/.codegenie/kernel/skills/harmony-page-zero-to-one/references/module_v4_readme.md
   ```

2. **Search by label or keyword** — the JSON is large; always grep rather than reading fully:
   ```
   Grep pattern="\"label\": \"快捷功能模块\"" in module_v4.json   # find by category
   Grep pattern="\"name\": \".*搜索.*\""      in module_v4.json   # find by name
   Grep pattern="\"usage\": \".*电商.*\""     in module_v4.json   # find by usage scenario
   Grep pattern="\"en_name\": \"SearchBar1\"" in module_v4.json   # find by code name
   ```

3. **Read the matched section** with offset/limit to extract `module_code` and `model_code`.

4. **Select the best match** based on `usage` and `layout` fields. If multiple candidates exist, pick the one whose layout description most closely matches the user's intent.

### How to use a matched module

- Copy `module_code` as the component implementation base.
- Copy `model_code` as the data model file (place in `viewmodel/` or alongside the page).
- Replace resource placeholders (`$r('app.media.startIcon')`, `'app.media.ic_more'`, etc.) with confirmed resources from `resources/` or safe string placeholders.
- The `module_arguments` field lists customizable parameters — adapt these to the actual content.
- The `route` field lists page names this module may navigate to — register them if needed.
- Routing uses `@Consume('appPathStack') appPathStack: NavPathStack` — ensure the page provides this via `@Provide`.

---

## Workflow A — Full App

### A1. Plan tab structure
- Infer bottom tab items directly from the user's description or your knowledge of the app type (e.g. "首页 / 订单 / 我的" for 外卖 apps).
- **Never ask the user about page count or tab labels.** Always infer reasonable defaults and proceed.
- Each tab corresponds to one `.ets` file under `entry/src/main/ets/pages/`.
- Name each file after its tab function in PascalCase (e.g. `HomePage.ets`, `DiscoverPage.ets`, `ProfilePage.ets`).

### A2. Inspect project structure
- Read `~/.codegenie/kernel/skills/harmony-page-zero-to-one/references/arkui_codegen_spec.md` to load the mandatory code generation rules.
- Locate page directory (usually `entry/src/main/ets/pages/`).
- Read `Index.ets` to understand existing structure and code style.
- Read `build-profile.json5` to determine SDK version (>= 12 → use V2 state management).
- Read `module.json5` to determine routing strategy and declared permissions:
  - Contains `routerMap` → Traditional routing (`router.pushUrl`)
  - Default (new project) → Navigation-based (`Navigation` + `NavPathStack`)

### A3. Look up reference modules for each tab page
For each tab page, before writing code:
- Identify the UI blocks needed (e.g. HomePage needs: 搜索栏 + 快捷功能入口 + 图文列表).
- For each block, grep `module_v4.json` by `label` or `usage` to find matching modules.
- Extract `module_code` + `model_code` from the best match.
- If no match found, implement from scratch following `harmony-arkts` + `harmony-ui` skills.

### A4. Implement tab pages
For each tab page:
- Follow `harmony-arkts` skill for ArkTS rules.
- Follow `harmony-ui` skill for layout, state, and performance.
- Assemble the page by composing reference modules via `@Builder` or sub-components.
- Each page is a standalone `@Entry @Component` struct exposing a `@Provide('appPathStack') appPathStack: NavPathStack`.
- Place model files in a `viewmodel/` directory alongside the page if `model_code` is non-empty.
- Use local mock data with explicit types; avoid `any`.
- Do not reference icon or resource names unless confirmed in `resources/`; use safe string placeholders.

### A5. Implement Index.ets as the shell
- Replace or update `Index.ets` to act as the app shell.
- Use `Tabs` + `TabContent` to host each tab page component.
- Import each tab page component into `Index.ets`.
- Use `TabBar` with text labels (and optional icons if resources are confirmed available).
- Manage selected tab index with `@State currentIndex: number = 0`.
- Example shell structure:
  ```
  Index.ets
    └── Tabs(barPosition: BarPosition.End)
          ├── TabContent() { HomePage() }.tabBar(...)
          ├── TabContent() { DiscoverPage() }.tabBar(...)
          └── TabContent() { ProfilePage() }.tabBar(...)
  ```

### A6. Register routes
- **Traditional routing**: register `Index` (and any push-navigable pages from `route` fields) in `main_pages.json`; tab page components do NOT need route registration.
- **Navigation routing**: configure `NavDestination` entries as needed.
- Never remove or reorder existing routes unless explicitly asked.

### A7. Compile verify
- Run `hmos_compilation` after all files are written.
- Fix all compile errors before finalizing.
- If compile still fails after one fix attempt, report root cause with exact file path and line number.

### A8. Delivery output

| Item | Detail |
|---|---|
| Created files | List each tab page `.ets` and model files with relative paths |
| Updated files | `Index.ets` and any routing config with change summary |
| Reference modules used | List `en_name` of each module applied |
| Tab structure | Tab labels and their corresponding files |
| Compile | ✅ success / ❌ failed (reason + file:line) |

---

## Workflow B — Single Page

### B1. Clarify target
- If the page type or key sections are ambiguous, ask ONE focused question before proceeding.
- Otherwise, infer from user description and proceed immediately.

### B2. Inspect project structure
- Read `~/.codegenie/kernel/skills/harmony-page-zero-to-one/references/arkui_codegen_spec.md` to load the mandatory code generation rules.
- Locate page directory (usually `entry/src/main/ets/pages/`).
- Read existing page examples (`Index.ets` etc.) to match local code style.
- Read `build-profile.json5` to determine SDK version (>= 12 → use V2 state management).
- Read `module.json5` to determine routing strategy and declared permissions:
  - Contains `routerMap` → Traditional routing (`router.pushUrl`)
  - Default (new project) → Navigation-based (`Navigation` + `NavPathStack`)

### B3. Look up reference modules
Before writing code:
- Break the page into UI blocks (e.g. 搜索栏、快捷入口、内容列表).
- For each block, grep `module_v4.json` to find a matching module.
- Extract `module_code` + `model_code` from matches.
- If no match found, implement from scratch.

### B4. Implement page
- Follow `harmony-arkts` skill for all ArkTS coding rules.
- Follow `harmony-ui` skill for layout, state management, animation, and performance.
- Place the page directly in `Index.ets` if it is the app's only/main page; otherwise create a new `.ets` file named after the page's function.
- Assemble the page by composing reference modules.
- Ensure `@Provide('appPathStack') appPathStack: NavPathStack` is declared if any module uses navigation.
- Place model files in `viewmodel/` if `model_code` is non-empty.
- Prefer local mock data with explicit types; avoid `any`.
- Do not reference icon or resource names unless confirmed in `resources/`; use safe string placeholders.

### B5. Register route/page entry
- **Traditional routing**: add the new page path to `main_pages.json`; keep existing entries intact.
- **Navigation routing**: add the corresponding `NavDestination` registration; do not edit `main_pages.json`.
- Register any additional pages listed in the `route` fields of used modules.
- Never remove or reorder existing routes unless explicitly asked.

### B6. Compile verify
- Run `hmos_compilation` after implementation.
- Fix all compile errors before finalizing.
- If compile still fails after one fix attempt, report root cause with exact file path and line number.

### B7. Delivery output

| Item | Detail |
|---|---|
| Created files | List with relative paths |
| Updated files | List with per-file change summary |
| Reference modules used | List `en_name` of each module applied |
| UI blocks | Component tree or section list |
| Compile | ✅ success / ❌ failed (reason + file:line) |

---

## Guardrails
- Always determine App vs Single Page before writing any code (Step 0).
- Always consult `module_v4.json` before implementing any UI block from scratch.
- Never read `module_v4.json` in full — always grep by label/name/usage first, then read the matched section.
- Do not assume icon/resource names exist; verify first or use safe string placeholders.
- Do not use unsupported ArkTS patterns (unsafe object literal typing, unsupported modifiers, etc.).
- Keep edits minimal and focused on the requested scenario.
- Do not modify unrelated pages or shared components unless the user explicitly asks.
- For Full App: tab page files must NOT be registered in `main_pages.json`; only `Index` needs registration.
- Always place model files from `model_code` in `viewmodel/` directory, not inside the page `.ets` file.
