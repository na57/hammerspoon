## 🚀 安装步骤 {#installation}

### 第一步：安装 Hammerspoon

访问 [Hammerspoon 官网](https://www.hammerspoon.org/)下载并安装Hammerspoon

---

### 第二步：配置文件设置

#### 1. 自动安装（推荐）

使用自动化脚本一键安装最新版本：
```bash
curl -fsSL https://raw.githubusercontent.com/na57/hammerspoon/pages/install.sh | bash
```

**特殊权限场景：**
```bash
curl -fsSL https://raw.githubusercontent.com/na57/hammerspoon/pages/install.sh | sudo bash -s -- -u $(whoami)
```

#### 2. 手动安装（可选）

1. 访问 [GitHub Releases](https://github.com/na57/hammerspoon/releases) 下载最新 zip 包
2. 使用以下命令解压并安装：

   ```bash
   # 替换为实际下载的文件名
   unzip -o hammerspoon-2026.01.09.zip -d /tmp/hammerspoon && cp -r /tmp/hammerspoon/* ~/.hammerspoon/
   ```
---

### 第三步：加载配置

1. 确保所有文件都已正确放置在配置文件夹中
2. 点击菜单栏中的 Hammerspoon 图标
3. 选择"Reload Config"选项
4. 如果配置成功，屏幕上会显示提示："Hammerspoon 配置已加载！"

---
