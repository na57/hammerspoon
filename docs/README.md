# GitHub Pages 部署指南

本目录包含 Hammerspoon 配置指南的 GitHub Pages 网站文件。

## 📁 文件结构

```
docs/
├── index.html          # 主页面
├── css/
│   └── styles.css      # 样式文件
├── js/
│   └── main.js         # JavaScript 交互功能
├── assets/             # 静态资源（图片、字体等）
├── _config.yml         # Jekyll 配置文件
└── .nojekyll           # 禁用 Jekyll 处理
```

## 🚀 部署步骤

### 方法 1：使用 GitHub Actions 自动部署（推荐）

1. **确保仓库已推送到 GitHub**
   ```bash
   git add .
   git commit -m "Add GitHub Pages site"
   git push origin main
   ```

2. **启用 GitHub Pages**
   - 访问仓库的 Settings 页面
   - 在左侧菜单中选择 "Pages"
   - 在 "Build and deployment" 下选择 "Source" 为 "GitHub Actions"

3. **推送代码**
   - 当你推送代码到 main 或 master 分支时，GitHub Actions 会自动部署网站
   - 部署完成后，你会在仓库的 Actions 页面看到部署状态

4. **访问网站**
   - 网站将发布在：`https://yourusername.github.io/hammerspoon/`

### 方法 2：手动部署

1. **构建网站**
   ```bash
   cd docs
   # 网站已经构建完成，无需额外构建步骤
   ```

2. **推送到 gh-pages 分支**
   ```bash
   git checkout --orphan gh-pages
   git add docs/
   git commit -m "Deploy to GitHub Pages"
   git push origin gh-pages
   ```

3. **启用 GitHub Pages**
   - 访问仓库的 Settings > Pages
   - 在 "Source" 中选择 "Deploy from a branch"
   - 选择 "gh-pages" 分支和 "/docs" 目录

## 🎨 自定义配置

### 修改网站标题和描述

编辑 `index.html` 文件中的 `<title>` 和 `<meta>` 标签：

```html
<title>你的网站标题</title>
<meta name="description" content="你的网站描述">
```

### 修改颜色主题

编辑 `css/styles.css` 文件中的 CSS 变量：

```css
:root {
    --primary-color: #2c3e50;      /* 主色调 */
    --secondary-color: #3498db;     /* 次要色调 */
    --accent-color: #e74c3c;        /* 强调色 */
    /* ... 其他颜色变量 */
}
```

### 添加自定义功能

编辑 `js/main.js` 文件添加自定义 JavaScript 功能。

## 📱 响应式设计

网站已实现完全响应式设计，支持以下设备：

- **桌面设备**：> 1024px
- **平板设备**：768px - 1024px
- **手机设备**：< 768px
- **小屏手机**：< 480px

## ♿ 可访问性特性

网站遵循 Web 可访问性标准，包含以下特性：

- 语义化 HTML 标签
- ARIA 标签支持
- 键盘导航支持
- 屏幕阅读器友好
- 高对比度颜色方案
- 减少动画选项支持

## 🔍 功能特性

### 导航功能
- 固定顶部导航栏
- 侧边栏目录导航
- 平滑滚动到章节
- 返回顶部按钮

### 搜索功能
- 实时搜索内容
- 高亮匹配结果
- 快捷键支持（Alt + S）

### 交互功能
- FAQ 折叠/展开
- 代码块复制按钮
- 外部链接自动处理
- 滚动动画效果

### 键盘快捷键
- `Alt + S`：聚焦搜索框
- `Alt + T`：返回顶部
- `Escape`：关闭移动端菜单

## 🧪 本地测试

### 方法 1：使用 Python 内置服务器

```bash
cd docs
python3 -m http.server 8000
```

访问：`http://localhost:8000`

### 方法 2：使用 Node.js http-server

```bash
npm install -g http-server
cd docs
http-server -p 8000
```

访问：`http://localhost:8000`

### 方法 3：使用 VS Code Live Server

1. 安装 "Live Server" 扩展
2. 右键点击 `index.html`
3. 选择 "Open with Live Server"

## 📊 性能优化

网站已进行以下优化：

- 最小化 CSS 和 JavaScript
- 图片懒加载（如适用）
- 代码分割和按需加载
- 浏览器缓存策略
- 压缩和优化资源

## 🔧 故障排除

### 网站无法访问

1. 检查 GitHub Actions 部署状态
2. 确认 Pages 设置正确
3. 等待几分钟让 DNS 传播

### 样式未加载

1. 检查文件路径是否正确
2. 确认 CSS 文件存在
3. 清除浏览器缓存

### JavaScript 功能不工作

1. 检查浏览器控制台错误
2. 确认 JavaScript 文件已加载
3. 检查浏览器兼容性

## 📝 更新内容

### 更新网站内容

1. 编辑 `index.html` 文件
2. 提交更改到 Git
3. 推送到 GitHub
4. 等待自动部署

### 添加新页面

1. 在 `docs/` 目录创建新的 HTML 文件
2. 在 `index.html` 中添加链接
3. 提交并推送更改

## 🌐 多语言支持

如需添加多语言支持：

1. 为每种语言创建单独的 HTML 文件
2. 添加语言切换按钮
3. 使用 `lang` 属性指定语言
4. 提供翻译后的内容

## 📚 相关资源

- [GitHub Pages 官方文档](https://docs.github.com/en/pages)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Web 可访问性指南](https://www.w3.org/WAI/WCAG21/quickref/)
- [响应式设计教程](https://web.dev/responsive-web-design-basics/)

## 🤝 贡献

欢迎贡献改进建议和 bug 报告！

## 📄 许可证

本网站内容遵循与主项目相同的许可证。