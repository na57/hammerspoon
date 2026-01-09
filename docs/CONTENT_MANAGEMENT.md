# Hammerspoon 配置指南 - 内容管理系统文档

## 📖 系统概述

本内容管理系统基于 Markdown 和 Jekyll 构建，实现了内容的模块化管理和自动化同步。您只需维护 Markdown 源文件，系统会自动将内容集成到网站中，无需手动编辑 HTML。

---

## 🎯 核心优势

### 1. 内容只需维护一次
- 所有内容存储在 Markdown 文件中
- 修改后自动同步到所有页面
- 消除了内容重复维护的问题

### 2. 模块化内容组织
- 内容按功能分割成独立的 Markdown 文件
- 每个文件专注于特定主题
- 易于查找、编辑和维护

### 3. 自动化构建和部署
- 支持自动构建流程
- 内容修改后自动更新
- 可集成 CI/CD 流程

### 4. 版本控制友好
- 使用纯文本 Markdown 格式
- 易于使用 Git 进行版本管理
- 清晰的变更历史

---

## 📁 文件结构

```
docs/
├── index.md                    # 主文档文件
├── _config.yml                 # Jekyll 配置文件
├── Gemfile                     # Ruby 依赖配置
├── _layouts/                   # 布局模板目录
│   └── default.html           # 默认布局模板
├── _sections/                  # 内容章节目录
│   ├── features.md            # 核心功能特点
│   ├── installation.md        # 安装步骤
│   ├── usage.md               # 使用方法
│   ├── requirements.md        # 系统要求
│   ├── faq.md                 # 常见问题解答
│   ├── support.md             # 技术支持
│   ├── changelog.md           # 更新日志
│   └── license.md             # 许可证
├── css/                        # 样式文件目录
│   └── styles.css             # 主样式文件
├── js/                         # JavaScript 文件目录
│   └── main.js                # 主脚本文件
└── preview.html                # 内容预览页面
```

---

## 🚀 使用方法

### 方法一：直接编辑 Markdown 文件（推荐）

1. **编辑内容**
   - 打开 `_sections/` 目录下对应的 Markdown 文件
   - 使用任何文本编辑器编辑内容
   - 保存文件

2. **自动同步**
   - 内容会自动集成到 `index.md` 中
   - 无需手动编辑 HTML 文件
   - 修改立即生效

### 方法二：使用 Jekyll 构建静态网站

1. **安装依赖**
   ```bash
   cd docs
   bundle install
   ```

2. **构建网站**
   ```bash
   bundle exec jekyll build
   ```

3. **预览网站**
   ```bash
   bundle exec jekyll serve
   ```

4. **访问预览**
   - 打开浏览器访问 `http://localhost:4000`
   - 查看构建后的网站

---

## 📝 内容编辑指南

### Markdown 基础语法

#### 标题
```markdown
# 一级标题
## 二级标题
### 三级标题
```

#### 列表
```markdown
- 无序列表项 1
- 无序列表项 2

1. 有序列表项 1
2. 有序列表项 2
```

#### 链接
```markdown
[链接文本](https://example.com)
```

#### 代码
```markdown
`行内代码`

```
代码块
```
```

#### 强调
```markdown
**粗体文本**
*斜体文本*
```

### 内容组织建议

1. **保持文件专注**
   - 每个 Markdown 文件只包含一个主题的内容
   - 避免在一个文件中混合多个主题

2. **使用清晰的标题结构**
   - 使用一致的标题层级
   - 确保标题能够准确描述内容

3. **添加适当的分隔**
   - 使用 `---` 分隔不同的内容块
   - 提高内容的可读性

4. **保持格式一致**
   - 统一使用相同的 Markdown 语法
   - 保持代码块和列表的格式一致

---

## 🔧 配置说明

### Jekyll 配置 (_config.yml)

主要配置项：

```yaml
# 站点信息
title: Hammerspoon 配置指南
description: 提高 macOS 使用效率的自动化工具配置指南

# Markdown 设置
markdown: kramdown
highlighter: rouge

# 插件
plugins:
  - jekyll-seo-tag
  - jekyll-sitemap

# 集合
collections:
  sections:
    output: false
```

### 内容引用机制

在 `index.md` 中使用 `{% include_relative %}` 引用章节文件：

```markdown
{% include_relative _sections/features.md %}
{% include_relative _sections/installation.md %}
```

这种方式确保：
- 内容只在源文件中维护一次
- 自动集成到主文档中
- 修改后自动同步

---

## 🧪 测试和验证

### 运行结构测试

```bash
cd docs
python3 test_structure.py
```

测试内容包括：
- ✓ 检查所有章节文件是否存在
- ✓ 验证主文档文件存在
- ✓ 确认所有章节都被正确引用
- ✓ 检查文件内容是否完整
- ✓ 验证 Markdown 格式是否正确

### 预览内容

打开 `preview.html` 文件可以查看内容结构的预览。

---

## 📚 最佳实践

### 1. 定期备份
- 使用 Git 进行版本控制
- 定期提交更改
- 保留重要的版本历史

### 2. 内容审查
- 在提交前检查内容准确性
- 确保链接有效
- 验证代码示例可运行

### 3. 文档更新
- 及时更新变更日志
- 保持文档与代码同步
- 添加适当的版本标记

### 4. 协作规范
- 使用清晰的提交信息
- 遵循统一的代码风格
- 及时解决冲突

---

## 🔄 自动化部署

### GitHub Actions 集成

可以创建 `.github/workflows/deploy.yml` 文件实现自动部署：

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build with Jekyll
        uses: helaili/jekyll-action@v2
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
```

### 本地构建脚本

创建 `build.sh` 脚本简化构建流程：

```bash
#!/bin/bash
cd docs
bundle install
bundle exec jekyll build
```

---

## ❓ 常见问题

### Q1: 如何添加新的章节？

1. 在 `_sections/` 目录下创建新的 Markdown 文件
2. 在 `index.md` 中添加引用：
   ```markdown
   {% include_relative _sections/your-new-section.md %}
   ```
3. 运行测试验证结构

### Q2: 如何修改现有内容？

1. 直接编辑对应的 Markdown 文件
2. 保存文件
3. 内容会自动同步到主文档

### Q3: 如何预览构建后的网站？

```bash
cd docs
bundle exec jekyll serve
```

然后访问 `http://localhost:4000`

### Q4: 如何解决构建错误？

1. 检查 Markdown 语法是否正确
2. 确保所有引用的文件都存在
3. 运行 `python3 test_structure.py` 验证结构
4. 查看构建日志中的错误信息

---

## 🎉 总结

本内容管理系统提供了：

- ✓ 简单直观的内容管理方式
- ✓ 自动化的内容同步机制
- ✓ 模块化的内容组织结构
- ✓ 版本控制友好的文件格式
- ✓ 灵活的构建和部署选项

通过使用这个系统，您可以专注于内容创作，而无需担心内容重复维护的问题。

---

**祝您使用愉快！** 🎉
