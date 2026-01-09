# Hammerspoon 自动化配置

## 📖 项目简介

**Hammerspoon 自动化配置** 是一个专为 macOS 用户设计的自动化工具集合，通过简单的快捷键组合，让您能够轻松管理显示器、窗口、文件和鼠标等日常操作。

### 开发背景

在日常使用 Mac 电脑时，我们经常需要重复执行一些操作，比如在多个显示器之间切换窗口、清除屏幕残影、将文件移动到 iCloud 等。这些操作虽然简单，但频繁执行会浪费大量时间。本项目基于 Hammerspoon 框架开发，通过预设的快捷键，一键完成这些操作，大大提高工作效率。

### 主要目标

- 简化日常操作，减少重复劳动
- 提高工作效率，让 Mac 使用更加流畅
- 提供易于自定义的配置方案
- 适合所有水平的用户使用

---

## 📚 完整文档

本项目采用模块化文档管理，所有详细内容都存储在独立的 Markdown 文件中，避免内容重复维护。

### 📖 在线文档

查看完整的在线文档：[Hammerspoon 配置指南](docs/)

### 📄 文档章节

- [✨ 核心功能特点](docs/_sections/features.md) - 了解所有可用的功能
- [🚀 安装步骤](docs/_sections/installation.md) - 快速安装和配置
- [💡 使用方法](docs/_sections/usage.md) - 详细的使用指南和常见任务
- [💻 系统要求](docs/_sections/requirements.md) - 系统和硬件要求
- [❓ 常见问题解答](docs/_sections/faq.md) - FAQ 和故障排除
- [🆘 获取技术支持](docs/_sections/support.md) - 官方资源和社区支持
- [📝 更新日志](docs/_sections/changelog.md) - 版本历史和更新记录
- [� 许可证](docs/_sections/license.md) - MIT 许可证信息

---

## 🎯 快速开始

### 1. 安装 Hammerspoon

访问 [Hammerspoon 官网](https://www.hammerspoon.org/) 下载并安装最新版本。

### 2. 配置文件设置

1. 启动 Hammerspoon，点击菜单栏图标
2. 选择 "Open Config" 打开配置文件夹
3. 将本项目的所有 `.lua` 文件复制到该文件夹

### 3. 加载配置

点击菜单栏图标 → "Reload Config"，即可开始使用！

---

## ⌨️ 常用快捷键

**Hyper 键** = `Command (⌘)` + `Shift (⇧)` + `Option (⌥)`

| 快捷键 | 功能 |
|--------|------|
| `Hyper + M` | 切换显示器 |
| `Hyper + P` | 切换窗口全屏 |
| `Hyper + 2` | 移动文件到 iCloud |
| `Hyper + 5` | 启动鼠标移动 |
| `Hyper + 6` | 停止鼠标移动 |
| `Hyper + R` | 重新加载配置 |

---

## � 项目结构

```
hammerspoon/
├── init.lua              # 主配置文件
├── display.lua            # 显示器管理模块
├── window.lua             # 窗口管理模块
├── icloud.lua             # iCloud 文件管理模块
├── mouse.lua              # 鼠标控制模块
├── docs/                  # 文档目录
│   ├── index.md          # 主文档
│   ├── _sections/        # 文档章节
│   │   ├── features.md
│   │   ├── installation.md
│   │   ├── usage.md
│   │   ├── requirements.md
│   │   ├── faq.md
│   │   ├── support.md
│   │   ├── changelog.md
│   │   └── license.md
│   └── CONTENT_MANAGEMENT.md  # 内容管理系统文档
└── README.md             # 项目说明（本文件）
```

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可证

本项目基于 MIT 许可证开源。详见 [许可证](docs/_sections/license.md)。

---

## 🙏 致谢

感谢 Hammerspoon 开发团队提供的优秀工具，以及所有贡献者的支持。

---

## 🔗 相关链接

- [Hammerspoon 官网](https://www.hammerspoon.org/)
- [Hammerspoon 文档](https://www.hammerspoon.org/docs/)
- [GitHub 仓库](https://github.com/na57/hammerspoon)

---

**祝您使用愉快！** 🎉
