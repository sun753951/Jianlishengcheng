# 项目记忆

## 项目概述

**职简** — 运行于 HarmonyOS 端侧的智能简历生成系统。用户填写个人信息与工作经历，系统利用端侧 NLG 模型自动生成专业简历文本，并支持模板切换、在线编辑、AI 评分优化与 PDF 导出。所有数据处理与模型推理在设备端完成，保障用户隐私。

- **Bundle Name**: `com.example.jianlishengcheng`
- **目标系统**: HarmonyOS 4.0+（API 10+）
- **当前阶段**: MVP Phase 2 — 简历编辑器功能开发，8 模块折叠卡片式编辑 + 文本导入入口

## 核心原则

- **ArkTS 严格类型**：禁用 `any`、`as` 类型断言、结构类型、动态属性访问
- **编译后验证**：编码完成后必须运行 `hmos_compilation` 编译检查
- **API 不确定时查文档**：通过 `harmonyos-expert` subagent 查阅官方文档
- **三层架构纪律**：UI(ArkTS) → NAPI桥接(C++) → AI引擎，各层职责清晰不越界
- **C++ 修改需重新编译**：修改 cpp/ 目录后需完整重编译，NAPI 接口签名变更需同步 Index.d.ts

## 项目架构

```
┌─────────────────────────────────────────────┐
│                  UI 层 (ArkTS)               │
│  pages/  components/  model/  utils/        │
├─────────────────────────────────────────────┤
│              NAPI 桥接 (resume_napi.ets)      │
├─────────────────────────────────────────────┤
│              AI 引擎 (C++)                   │
│  resume_generator  onnx_session  tokenizer  │
│  (当前阶段: Mock 回退，C++ 骨架就绪)          │
└─────────────────────────────────────────────┘
```

## 团队角色

| 角色 | 类型 | 职责 |
|------|------|------|
| Team Lead | primary | 工作流协调，不写代码 |
| build | primary | HarmonyOS ArkTS 编码与编译 |
| debug | primary | 运行时 log 证据驱动调试 |
| @planner | subagent | 需求→策划案 |
| @architect | subagent | 策划案→程序方案 |
| @harmonyos-expert | subagent | 官方文档研究（只读） |
| @docs-updater | subagent | 代码变更→文档同步 |
| @git-admin | subagent | Git 操作 |

## 源码结构

```
entry/src/main/ets/
├── model/                          # 数据模型
│   ├── ResumeData.ets              # 完整简历数据结构（8 个子模块）
│   ├── TemplateConfig.ets          # 3 种模板预设（经典蓝/现代绿/极简黑）
│   └── ResumeScore.ets             # AI 评分与改进建议模型
├── pages/                          # 7 个页面
│   ├── Index.ets                   # Dashboard 首页 — 简历列表 + 新建入口
│   ├── TemplatePicker.ets          # 模板选择页 — 3 种风格切换
│   ├── ResumeForm.ets              # 5 步 Stepper 表单 — 信息录入
│   ├── Generating.ets              # 生成中页面 — 进度动画 + 小贴士
│   ├── ResumePreview.ets           # 简历预览页 — 模板渲染 + 导出入口
│   ├── ResumeEditor.ets            # 在线编辑页 — 8 模块折叠卡片式编辑器（含文本导入入口）
│   └── Score.ets                   # 评分页 — 四维评分 + AI 建议
├── components/                          # UI 组件
│   ├── ResumeCard.ets                   # 简历卡片组件
│   ├── TemplateItem.ets                 # 模板缩略图组件
│   ├── FormStepIndicator.ets            # Stepper 步骤指示器
│   ├── EmptyState.ets                   # 空状态占位组件
│   ├── CollapsibleSection.ets           # 通用折叠卡片（核心复用组件，三角指示器 + 展开动画）
│   ├── PersonalInfoEditor.ets           # 个人信息编辑器（11 字段，@ObjectLink 绑定）
│   ├── ItemListEditor.ets               # 通用多条目列表编辑器（增/删 + @BuilderParam 插槽）
│   ├── EditableSectionCard.ets          # 可折叠卡片容器（替代样式，带阴影 + 计数徽章）
│   ├── EditableStringList.ets           # 字符串数组编辑组件（增/删/改）
│   ├── ProjectSection.ets               # 项目经历章节组件（@Link 绑定，含亮点 + 技术栈列表）
│   ├── SkillItem.ets                    # 单条技能行组件（Slider 熟练度 + 删除）
│   └── WorkExperienceSection.ets        # 工作经历章节组件（@Link 绑定，含成就列表）
├── utils/                          # 工具类
│   ├── SampleData.ets              # 示例数据生成
│   ├── MockGenerator.ets           # Mock AI 生成器（模拟端侧推理）
│   ├── PdfGenerator.ets            # PDF 导出骨架
│   ├── IdGenerator.ets             # 唯一 ID 生成器（前缀 + 时间戳 + 计数器）
│   ├── TextImporter.ets            # 文本导入器接口（isReady 骨架，待接入解析引擎）
│   └── TextToResumeParser.ets      # 文本→简历解析器（抽象基类 + Mock + 工厂方法）
└── napi/                           # NAPI 桥接
    └── resume_napi.ets             # 连接 ArkTS → C++ 引擎

entry/src/main/cpp/                 # C++ 引擎层（骨架就绪）
├── CMakeLists.txt
├── napi_init.cpp                   # NAPI 模块注册
├── resume_generator.h/.cpp         # 简历生成器
├── onnx_session.h/.cpp             # ONNX Runtime 封装
├── tokenizer.h/.cpp                # 中文 Tokenizer
└── types/libresume_napi/Index.d.ts # NAPI 类型声明
```

## 页面路由

| 页面 | 路由 | 功能 |
|------|------|------|
| 首页 Dashboard | `pages/Index` | 简历列表、新建入口 |
| 模板选择 | `pages/TemplatePicker` | 3 种模板风格选择 |
| 信息填写 | `pages/ResumeForm` | 5 步 Stepper 表单 |
| AI 生成中 | `pages/Generating` | 进度动画 + 小贴士轮播 |
| 简历预览 | `pages/ResumePreview` | 模板渲染 + PDF 导出 |
| 在线编辑 | `pages/ResumeEditor` | 8 模块折叠卡片式编辑 + 文本导入 |
| AI 评分 | `pages/Score` | 四维评分 + 改进建议 |

## 状态管理

- `AppStorage` 全局状态：`currentResume`（当前简历）、`pendingResume`（待生成简历）
- 页面间通过 `router.pushUrl`/`router.replaceUrl` 传递 `@ohos.router` 路由
- 组件内状态使用 `@State`、`@Link` 装饰器
- **编辑器深度绑定**：`@Observed` 类 + `@ObjectLink` 子组件绑定 + 展开运算符整体替换数组实现深层状态刷新
- **跨页同步**：`AppStorage.setOrCreate` 自动保存 + `onPageShow` 读取最新数据
- **展开折叠**：每个模块独立 `@State` 折叠标志位，编辑过的模块自动展开

## 交互规范

- **按压态**：所有可点击元素统一使用 `stateStyles({ pressed: {...} })` 提供视觉反馈
- **文本导入**：`@CustomDialog` 模态框 + `TextImporter` 接口骨架，粘贴旧简历文本自动解析
- **折叠卡片**：`CollapsibleSection` 通用组件 — 三角指示器（▶/▼）+ 条目计数 + 200ms 展开动画

## 技术栈

- 运行时：Bun >= 1.1
- 构建：hvigorw（HarmonyOS 编译工具链）
- 设备交互：hdc
- MCP：deveco-mcp-server、runtime-calibration
- AI 引擎（规划）：ONNX Runtime（端侧推理）、Chinese-GPT2-Small（INT8 量化）
- 当前阶段：Mock 模拟生成，C++ 引擎骨架就绪等待真实模型接入

## 关键工具

| 工具 | 功能 |
|------|------|
| `hmos_compilation` | hvigorw 编译 |
| `hmos_run` | 构建 + 安装 + 启动 |
| `hdc_log` | 设备日志采集 |
| `harmonyos_knowledge_search` | 搜索官方文档 |
| `calibrate` | UI 自动化校验 |

## 环境变量

- `DEVECO_HOME` — DevEco Studio 安装目录（必须）
- `RC_API_KEY` — runtime-calibration 凭据（可选）
