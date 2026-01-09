#!/bin/bash

echo "======================================"
echo "Hammerspoon GitHub Pages 部署脚本"
echo "======================================"
echo ""

# 检查是否在正确的目录
if [ ! -f "init.lua" ]; then
    echo "错误：请在 hammerspoon 项目根目录运行此脚本"
    exit 1
fi

# 菜单选择
echo "请选择操作："
echo "1) 启动本地测试服务器"
echo "2) 部署到 GitHub Pages"
echo "3) 查看部署状态"
echo "4) 退出"
echo ""
read -p "请输入选项 (1-4): " choice

case $choice in
    1)
        echo ""
        echo "启动本地测试服务器..."
        echo "网站将在 http://localhost:8000 上运行"
        echo "按 Ctrl+C 停止服务器"
        echo ""
        cd docs && python3 -m http.server 8000
        ;;
    2)
        echo ""
        echo "部署到 GitHub Pages..."
        echo ""
        
        # 检查是否有未提交的更改
        if [ -n "$(git status --porcelain)" ]; then
            echo "检测到未提交的更改"
            read -p "是否要提交这些更改？(y/n): " commit_choice
            if [ "$commit_choice" = "y" ]; then
                git add .
                read -p "请输入提交信息: " commit_message
                git commit -m "$commit_message"
            else
                echo "取消部署"
                exit 1
            fi
        fi
        
        # 推送到 GitHub
        echo "推送到 GitHub..."
        git push origin main
        
        echo ""
        echo "✅ 代码已推送到 GitHub"
        echo "📝 请按照以下步骤完成部署："
        echo "   1. 访问仓库的 Settings 页面"
        echo "   2. 在左侧菜单中选择 'Pages'"
        echo "   3. 在 'Build and deployment' 下选择 'Source' 为 'GitHub Actions'"
        echo "   4. 等待 GitHub Actions 完成部署"
        echo ""
        echo "🌐 部署完成后，网站将发布在："
        echo "   https://yourusername.github.io/hammerspoon/"
        ;;
    3)
        echo ""
        echo "检查部署状态..."
        echo ""
        
        # 检查 GitHub Actions 状态
        echo "请访问以下链接查看部署状态："
        echo "https://github.com/yourusername/hammerspoon/actions"
        echo ""
        echo "或者使用以下命令查看："
        echo "gh run list"
        ;;
    4)
        echo ""
        echo "退出"
        exit 0
        ;;
    *)
        echo ""
        echo "无效的选项"
        exit 1
        ;;
esac