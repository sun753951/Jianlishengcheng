# Skills 目录

此目录包含 HarmonyOS 开发相关的技能（Skills）。Skills 会被 Codegenie 自动加载并注册为可调用的命令。

## Skills 列表

- **[harmony-arkts](./harmony-arkts/SKILL.md)** - ArkTS 代码编写指南
- **[harmony-ui](./harmony-ui/SKILL.md)** - ArkUI 声明式 UI 组件实现最佳实践
- **[harmony-error-fixes](./harmony-error-fixes/SKILL.md)** - ArkTS 编译错误和类型不匹配问题解决方案

## SKILL.md 文件格式

每个 skill 必须包含一个 `SKILL.md` 文件，格式如下：

```markdown
---
name: skill-name
description: 简短的技能描述
---

# Skill 标题

## Instructions
详细的指令内容...
```

### 必需字段

- `name`: skill 的唯一标识符（kebab-case）
- `description`: skill 的简短描述

## 如何使用 Skills

### 1. 查看已加载的 Skills

在 Codegenie TUI 中：
- 按 **Ctrl+X C** (或配置的 `command_list` 键绑定) 打开命令面板
- 所有已加载的 skills 会显示在命令列表中

使用命令行：
```bash
codegenie skill
```

### 2. 调用 Skill

Skills 会被自动注册为命令，可以通过以下方式调用：

- **在对话中引用**: 直接在提示中提到 skill 名称
- **作为命令**: 通过命令面板选择并执行
- **斜杠命令**: 如果 skill 注册了斜杠命令，可以使用 `/skill-name` 格式

## 添加新的 Skill

1. 在此目录下创建新的 skill 文件夹
2. 创建 `SKILL.md` 文件，包含正确的 frontmatter
3. 重启 Codegenie 以加载新的 skill

示例：
```bash
mkdir skills/my-new-skill
cat > skills/my-new-skill/SKILL.md << 'EOF'
---
name: my-new-skill
description: My new skill description
---

# My New Skill

## Instructions
Detailed instructions here...
EOF
```

## 故障排除

### Skills 没有显示？

1. **检查文件格式**: 确保 SKILL.md 有正确的 YAML frontmatter
2. **检查 name 字段**: 必须是唯一的，使用 kebab-case
3. **查看日志**: 启动时查看是否有解析错误
4. **重启服务**: 修改后需要重启 Codegenie

### 查看解析错误

```bash
OPENCODE_LOG_LEVEL=DEBUG codegenie
```

这会显示 skill 加载过程中的详细日志。
