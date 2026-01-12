#!/bin/bash

# ========================================
# Hammerspoon 配置自动安装脚本
# 作者: na57
# 版本: 1.0.0
# 描述: 从 GitHub Releases 自动下载并安装最新版本的 Hammerspoon 配置
# ========================================

set -e

# 配置参数
GITHUB_OWNER="na57"
GITHUB_REPO="hammerspoon"
DOWNLOAD_DIR="$(mktemp -d)"
HAMMERSPOON_DIR="$HOME/.hammerspoon"
TEMP_DIR="$(mktemp -d)"
USER_NAME="$USER"
GROUP_NAME="$(id -gn)"
SCRIPT_VERSION="1.0.0"

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                echo "Hammerspoon 配置自动安装脚本 v$SCRIPT_VERSION"
                exit 0
                ;;
            -d|--dir)
                HAMMERSPOON_DIR="$2"
                shift 2
                ;;
            -u|--user)
                USER_NAME="$2"
                GROUP_NAME="$(id -gn "$2" 2>/dev/null || echo "$GROUP_NAME")"
                shift 2
                ;;
            *)
                error_exit "未知参数: $1" "使用 -h 或 --help 查看帮助信息"
                ;;
        esac
    done
}

# 显示帮助信息
show_help() {
    cat << EOF
Hammerspoon 配置自动安装脚本 v$SCRIPT_VERSION

从 GitHub Releases 自动下载并安装最新版本的 Hammerspoon 配置

用法:
  $0 [选项]

选项:
  -h, --help         显示帮助信息并退出
  -v, --version      显示脚本版本并退出
  -d, --dir <path>   指定自定义安装目录（默认：~/.hammerspoon）
  -u, --user <user>  指定安装文件的所有者（当使用 sudo 时）

示例:
  # 基本安装
  $0

  # 指定自定义目录
  $0 --dir /path/to/your/.hammerspoon

  # 使用 sudo 安装
  sudo $0 --user $(whoami)

  # 使用 curl 一键安装
  curl -fsSL https://raw.githubusercontent.com/na57/hammerspoon/main/install.sh | bash

  # 使用 wget 一键安装
  wget -O- https://raw.githubusercontent.com/na57/hammerspoon/main/install.sh | bash
EOF
}

# 彩色输出函数
print_color() {
    local color=$1
    local message=$2
    case $color in
        "red") echo -e "\033[0;31m$message\033[0m" ;;
        "green") echo -e "\033[0;32m$message\033[0m" ;;
        "yellow") echo -e "\033[0;33m$message\033[0m" ;;
        "blue") echo -e "\033[0;34m$message\033[0m" ;;
        *) echo "$message" ;;
    esac
}

# 错误处理函数
error_exit() {
    print_color "red" "❌ 错误: $1"
    print_color "yellow" "💡 提示: $2"
    clean_up
    exit 1
}

# 清理临时文件
clean_up() {
    print_color "yellow" "🧹 正在清理临时文件..."
    rm -rf "$DOWNLOAD_DIR" "$TEMP_DIR"
}

# 检查依赖
check_dependencies() {
    print_color "blue" "🔍 检查依赖项..."
    
    local missing_deps=()
    for cmd in curl unzip jq; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=($cmd)
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        error_exit "缺少必要的依赖项: ${missing_deps[*]}" "请安装这些依赖项，例如在 macOS 上运行: brew install ${missing_deps[*]}"
    fi
    
    print_color "green" "✅ 所有依赖项已安装"
}

# 获取最新版本信息
get_latest_release() {
    print_color "blue" "📥 获取最新版本信息..." >&2
    
    local api_url="https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases/latest"
    
    # 获取最新版本数据
    local release_data
    if ! release_data=$(curl -s "$api_url"); then
        error_exit "无法连接到 GitHub API" "请检查网络连接或稍后重试"
    fi
    
    # 提取版本号和下载链接
    local version=$(echo "$release_data" | jq -r '.tag_name')
    local download_url=$(echo "$release_data" | jq -r '.assets[] | select(.name | endswith(".zip")) | .browser_download_url')
    
    # 如果assets中没有zip文件，使用GitHub自动生成的zipball_url
    if [ -z "$download_url" ] || [ "$download_url" == "null" ]; then
        download_url=$(echo "$release_data" | jq -r '.zipball_url')
    fi
    
    if [ -z "$version" ] || [ "$version" == "null" ] || [ -z "$download_url" ] || [ "$download_url" == "null" ]; then
        error_exit "无法获取有效的版本信息" "请检查 GitHub Releases 页面是否有可用的发布版本"
    fi
    
    print_color "green" "✅ 找到最新版本: $version" >&2
    print_color "yellow" "📦 下载链接: $download_url" >&2
    
    # 仅输出版本号和下载链接，不包含其他输出
    echo "$version|$download_url"
}

# 下载并验证文件
download_and_verify() {
    local version=$1
    local download_url=$2
    
    print_color "blue" "📥 正在下载版本 $version..." >&2
    
    local zip_file="$DOWNLOAD_DIR/${GITHUB_REPO}-${version}.zip"
    
    # 下载文件
    if ! curl -L -o "$zip_file" "$download_url" >&2; then
        error_exit "下载失败" "请检查网络连接或稍后重试"
    fi
    
    # 验证文件大小（确保不是空文件）
    local file_size=$(stat -f "%z" "$zip_file")
    if [ "$file_size" -lt 1024 ]; then
        error_exit "下载的文件太小，可能已损坏" "请重试下载或手动下载安装"
    fi
    
    # 验证文件是否为有效的zip格式
    if ! unzip -t "$zip_file" > /dev/null 2>&1; then
        error_exit "下载的文件不是有效的zip格式" "请检查 GitHub Releases 页面的文件是否完整"
    fi
    
    print_color "green" "✅ 文件下载成功并验证通过" >&2
    print_color "yellow" "📁 文件路径: $zip_file" >&2
    print_color "yellow" "📊 文件大小: $(du -h "$zip_file" | cut -f1)" >&2
    
    echo "$zip_file"
}

# 获取当前日期，格式为yyyymmdd
get_current_date() {
    date +"%Y%m%d"
}

# 安装配置文件
install_config() {
    local zip_file=$1
    local version=$2
    
    print_color "blue" "📦 正在解压文件..."
    
    # 解压到临时目录
    if ! unzip -q "$zip_file" -d "$TEMP_DIR"; then
        error_exit "解压文件失败" "请检查文件完整性或权限问题"
    fi
    
    # 确保 Hammerspoon 目录存在
    print_color "blue" "📁 正在准备安装目录..."
    mkdir -p "$HAMMERSPOON_DIR"
    
    # 获取解压后的文件目录（处理不同的zip结构）
    local extracted_dir
    if [ -d "$TEMP_DIR/$GITHUB_REPO-$version" ]; then
        extracted_dir="$TEMP_DIR/$GITHUB_REPO-$version"
    elif [ -d "$TEMP_DIR"/$(ls -1 "$TEMP_DIR" | head -1) ]; then
        extracted_dir="$TEMP_DIR"/$(ls -1 "$TEMP_DIR" | head -1)
    else
        extracted_dir="$TEMP_DIR"
    fi
    
    # 检查是否包含必要的配置文件
    local required_files=("init.lua" "display.lua" "window.lua" "icloud.lua" "mouse.lua")
    for file in "${required_files[@]}"; do
        if [ ! -f "$extracted_dir/$file" ]; then
            error_exit "缺少必要的配置文件: $file" "请检查下载的zip包是否完整"
        fi
    done
    
    print_color "blue" "🔧 正在安装配置文件到 $HAMMERSPOON_DIR..."
    
    # 检查config.lua是否已存在
    local config_file="$HAMMERSPOON_DIR/config.lua"
    local backup_file=""
    
    if [ -f "$config_file" ]; then
        # 获取当前日期
        local current_date=$(get_current_date)
        backup_file="${config_file}.${current_date}"
        
        # 询问用户是否备份
        print_color "yellow" "⚠️  检测到已存在config.lua文件，是否备份？"
        read -p "请输入 y/n (默认: y): " backup_choice
        backup_choice=${backup_choice:-y}
        
        if [ "$backup_choice" = "y" ] || [ "$backup_choice" = "Y" ]; then
            # 执行备份
            if ! cp "$config_file" "$backup_file" 2>/dev/null; then
                # 尝试使用sudo权限
                print_color "yellow" "⚠️  普通权限备份失败，尝试使用sudo权限..."
                if ! sudo cp "$config_file" "$backup_file"; then
                    error_exit "备份config.lua失败" "请检查您的权限或手动备份文件"
                fi
                sudo chown "$USER":"$GROUP" "$backup_file"
            fi
            print_color "green" "✅ 已将config.lua备份到 $backup_file"
        fi
    fi
    
    # 复制文件，处理权限问题
    if ! cp -r "$extracted_dir"/*.lua "$HAMMERSPOON_DIR" 2>/dev/null; then
        # 尝试使用sudo权限
        print_color "yellow" "⚠️  普通权限复制失败，尝试使用sudo权限..."
        if ! sudo cp -r "$extracted_dir"/*.lua "$HAMMERSPOON_DIR"; then
            error_exit "复制文件失败" "请检查您的权限或手动复制文件"
        fi
        # 修复权限
        sudo chown -R "$USER":"$GROUP" "$HAMMERSPOON_DIR"
    fi
    
    print_color "green" "✅ 配置文件安装成功！"
    
    # 输出安装信息
    print_color "blue" "📋 安装详情："
    print_color "yellow" "   版本: $version"
    print_color "yellow" "   路径: $HAMMERSPOON_DIR"
    print_color "yellow" "   文件: $(ls -la "$HAMMERSPOON_DIR" | grep -c \.lua) 个Lua文件"
    
    # 输出成功提示
    print_color "green" "🎉 Hammerspoon 配置安装成功！"
    print_color "yellow" "💡 提示: 请在 Hammerspoon 中点击 'Reload Config' 来加载新配置"
}

# 主函数
main() {
    print_color "blue" "🚀 Hammerspoon 配置自动安装脚本 v$SCRIPT_VERSION"
    print_color "blue" "===================================="
    
    # 解析命令行参数
    parse_args "$@"
    
    # 检查依赖
    check_dependencies
    
    # 获取最新版本
    local release_info=$(get_latest_release)
    local version=$(echo "$release_info" | cut -d'|' -f1)
    local download_url=$(echo "$release_info" | cut -d'|' -f2)
    
    # 下载并验证
    local zip_file=$(download_and_verify "$version" "$download_url")
    
    # 安装
    install_config "$zip_file" "$version"
    
    # 清理临时文件
    clean_up
    
    print_color "blue" "===================================="
    print_color "green" "✅ 安装完成！"
    return 0
}

# 执行主函数
main "$@"