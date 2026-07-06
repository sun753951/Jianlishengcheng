# 鸿蒙工程级代码生成系统（ArkUI）规格

## 1 工程架构与目录结构标准化

### 1.1 Stage 模型目录规范

Stage 模型是 HarmonyOS NEXT 主推的应用模型，将 Ability 与 WindowStage 分离。根据文件物理路径决定生成的代码类型。

| 目录路径 | 文件类型 | 生成策略与约束 |
|---|---|---|
| `src/main/ets/entryability` | EntryAbility.ets | 高风险区。除明确的全局生命周期注入外，严禁修改。 |
| `src/main/ets/pages` | .ets (Page) | 核心生成区。必须包含 `@Entry`。必须注册到路由表。 |
| `src/main/ets/view` 或 `components` | .ets (Component) | 核心生成区。可复用组件。严禁使用 `@Entry`。推荐 `@ComponentV2`。 |
| `src/main/ets/viewmodel` | .ets (Class) | 逻辑生成区。应生成 `@Observed` 或 `@ObservedV2` 装饰的类。 |
| `src/main/ets/model` | .ets (Class/Interface) | 数据生成区。存放数据实体。避免包含业务逻辑。 |
| `src/main/ets/utils` | .ets (Function) | 工具生成区。无状态辅助函数。 |
| `src/main/resources/base/element` | .json | 资源区。严禁硬编码字符串或颜色，必须生成 string.json / color.json 条目。 |
| `src/main/resources/rawfile` | 任意文件 | 资产区。HTML、复杂 JSON 配置等。 |

### 1.2 模块化识别（HAP / HAR / HSP）

读取根目录 `hvigorfile.ts` 或模块级 `module.json5` 判断模块类型：

- **HAP (Entry/Feature)**：可生成 Ability 和 Page。
- **HAR (Static Library)**：重点生成导出组件，必须在 `index.ets` 中显式导出。
- **HSP (Shared Library)**：类似 HAR，注意动态加载的路径引用差异。

### 1.3 架构模式：MVVM

生成的代码必须遵循 MVVM 架构，禁止面条式代码：

- **View 层**：仅包含布局逻辑和简单 UI 状态。
- **ViewModel 层**：承载业务逻辑。生成 Page 时必须同步生成对应的 `XXXViewModel.ets`。
- **Model 层**：定义数据结构，不含业务逻辑。

**示例**：用户输入"创建用户详情页"，Agent 应生成：
```
src/main/ets/model/User.ets
src/main/ets/viewmodel/UserViewModel.ets
src/main/ets/pages/UserDetailPage.ets
```

---

## 2 ArkUI 组件生成规格

### Tier 1 — 基础容器与布局 ✅

| 组件 | 核心属性 | Agent 决策逻辑 |
|---|---|---|
| Column / Row | space, alignItems, justifyContent | 线性布局基础。嵌套超过 5 层时改用 RelativeContainer。 |
| Stack | alignContent, zIndex | 重叠元素场景。禁止用负 Margin 实现重叠。 |
| Flex | wrap, direction | 仅在需要自动换行时使用，简单线性优先用 Column/Row。 |
| RelativeContainer | alignRules, id | 复杂异形布局首选，需生成唯一 ID 并管理锚点依赖。 |
| GridRow / GridCol | breakpoints, span, offset | 响应式布局标配。涉及多设备适配或折叠屏必须使用。 |

### Tier 2 — 列表与滚动容器（严格性能约束）✅

**List 与 LazyForEach**

| 场景 | 方案 |
|---|---|
| 短列表（< 50 条） | 使用 ForEach |
| 长列表 / 无限滚动 | 必须使用 LazyForEach |

LazyForEach 生成规格：
- 必须在 `viewmodel/` 或 `utils/` 下生成实现 `IDataSource` 接口的基础类（如 `BasicDataSource`）。
- KeyGenerator（第三个参数）不可省略，严禁使用 `index`，必须使用 `item.id` 等唯一值。
- 必须设置 `.cachedCount()`，建议值 2~4。

**Grid 组件**
- 必须明确指定 `columnsTemplate` 或 `rowsTemplate`。

**Scroll 组件**
- 只能包含一个子组件；多个同级子组件必须自动包裹容器。
- 内部含 List/Grid 时必须生成 `nestedScroll` 属性，避免滑动冲突。

### Tier 3 — 导航与路由（架构级决策）✅

**决策逻辑**：
- 若 `module.json5` 含 `routerMap` 且用户明确维护旧代码 → 生成 `router.pushUrl`。
- 默认（新工程） → 必须使用 `Navigation` + `NavPathStack`。

**Navigation 生成规格**：
- 应用首页必须包含 `Navigation` 组件，绑定全局 `NavPathStack`。
- 子页面不使用 `@Entry`，包裹在 `NavDestination` 中。
- 推荐使用系统路由表：在 `resources/base/profile/route_map.json` 中注册，不硬编码。

### Tier 4 — Canvas 绘制 ❌ 不支持复杂场景

支持基础 `CanvasRenderingContext2D` 绘图（线、矩形、圆）。复杂动画帧回调或游戏级渲染建议引入第三方库或 Lottie。

---

## 3 状态管理

严禁在同一组件内混用 V1 和 V2 装饰器。

### 3.1 V1 状态管理（兼容旧工程，API 9/10）

| 装饰器 | 作用域 | 生成规则 |
|---|---|---|
| `@State` | 组件内私有 | 基础类型。无法深度观察嵌套对象/数组内部变化。 |
| `@Link` | 父子双向同步 | 子组件需修改父组件数据时使用。 |
| `@Prop` | 父子单向同步 | 深拷贝开销大，大对象改用 `@ObjectLink`。 |
| `@ObjectLink` | 嵌套对象观察 | 处理数组项或嵌套对象时必须配合 `@Observed` 使用。 |

### 3.2 V2 状态管理（推荐，API 12+）✅

| 装饰器 | 作用域 | 生成规格 |
|---|---|---|
| `@Local` | 组件内私有 | 替代 `@State`。 |
| `@Param` | 父组件传入 | 替代 `@Prop`，本地不可变，修改需通过事件回调。 |
| `@Event` | 回调函数 | 替代 `@Link`，实现"数据下行，事件上行"单向数据流。 |
| `@ObservedV2` | 类装饰器 | 数据模型类使用。 |
| `@Trace` | 属性装饰器 | ViewModel 类的所有属性必须加 `@Trace`，实现深度观测。 |

**版本选择策略**：
- 检查 `build-profile.json5` 中的 `compatibleSdkVersion`。
- `>= 12` → 默认使用 V2（`@ComponentV2`）。
- 已有大量 V1 代码 → 保持 V1 一致性，不混用。

---

## 4 页面复杂度等级

### Level 1 — 简单页面 ✅（生成完整度 95%）

- 定义：静态展示、简单表单、单次数据获取。
- 典型场景：登录/注册、关于我们、设置菜单、引导页（Swiper）、协议页。
- 规格：节点数 < 50，嵌套深度 < 8。

### Level 2 — 中等复杂度页面 ✅（生成完整度 80%）

- 定义：列表数据加载、下拉刷新、多状态切换（Loading/Empty/Error）、父子组件通信。
- 典型场景：商品列表（Grid + LazyForEach）、消息列表、个人主页（吸顶）、简单图表。
- 规格：节点数 50~200，涉及 ViewModel 绑定。
- 限制：业务 API 调用仅生成 Mock 数据或 TODO 注释，需人工填充。

### Level 3 — 复杂页面 ❌（生成完整度 50%）

- 定义：跨模块交互、复杂联动动画、富文本编辑、地图集成、多级嵌套滚动。
- 典型场景：短视频流、即时通讯、复杂电商首页（嵌套 Scroll/List/Grid/Swiper）。
- 限制：键盘避让需人工介入，手势冲突需真机调试，NAPI 调用无法生成。

---

## 5 UI 风格一致性与资源管理

### 5.1 像素单位规范

- **严禁使用 px**。
- 布局间距、圆角：使用 `vp`。
- 字体大小：使用 `fp`。

### 5.2 资源提取规范（No Hardcoding）

| 资源类型 | 处理方式 |
|---|---|
| 中文字符串 | 提取到 `string.json`，替换为 `$r('app.string.xxx')` |
| 颜色值（如 `#FF0000`） | 提取到 `color.json`，替换为 `$r('app.color.xxx')` |
| 间距常量 | 生成 `float.json` 或 `AppConstants.ets` 统一管理 |

### 5.3 深色模式适配 ❌（当前不支持自动生成）

使用语义化颜色或在 `resources/dark/element/color.json` 定义对应色值。

---

## 6 性能与质量保障

### 6.1 代码复杂度

- UI 树嵌套不超过 **10 层**；超过则提取为 `@Builder` 函数或独立组件。
- 单文件建议不超过 **500 行**；超过则拆分。

### 6.2 输出前自检清单

- [ ] `Image` 组件是否设置了明确的宽高？（否则解码内存浪费）
- [ ] 频繁切换显隐场景是否用 `visibility` 而非 `if/else`？（if/else 触发组件销毁重建）
- [ ] `ForEach` / `LazyForEach` 是否提供了唯一 Key？（禁止使用 index）
- [ ] 长列表是否使用了 `LazyForEach` + `cachedCount`？
- [ ] 嵌套滚动容器是否配置了 `nestedScroll`？
