-- ========================================
-- Hammerspoon 主配置文件
-- ========================================
-- 本文件负责加载所有功能模块并配置快捷键
-- 各功能模块的具体实现位于对应的 .lua 文件中
-- ========================================

-- 设置 Hyper 键（Cmd + Shift + Option）
-- 可根据个人喜好修改，例如改为 {"cmd", "alt"} 或 {"cmd", "ctrl"}
local hyper = {"cmd", "shift", "alt"}

-- ========================================
-- 加载功能模块
-- ========================================
-- display.lua - 显示器管理（切换显示器、清除残影）
-- window.lua  - 窗口管理（全屏切换）
-- icloud.lua  - iCloud文件管理（移动文件到iCloud）
-- mouse.lua   - 鼠标控制（随机移动鼠标）
local display = require("display")
local window = require("window")
local icloud = require("icloud")
local mouse = require("mouse")

-- ========================================
-- 快捷键配置
-- ========================================
-- 使用方法：按住 Hyper 键 + 对应字母键触发功能
-- 自定义快捷键：修改 hs.hotkey.bind() 中的第二个参数（字母键）

-- 重新加载配置
-- 快捷键：Hyper + R
hs.hotkey.bind(hyper, "R", function()
    hs.reload()
end)

-- 切换窗口到下一显示器（支持全屏窗口）
-- 快捷键：Hyper + M
hs.hotkey.bind(hyper, "M", display.moveWindowToNextScreen)

-- 清除所有显示器残影
-- 快捷键：Hyper + G
hs.hotkey.bind(hyper, "G", display.clearAllScreensGhosting)

-- 切换当前窗口全屏状态
-- 快捷键：Hyper + P
hs.hotkey.bind(hyper, "P", window.toggleFullScreen)

-- 移动Finder选中的文件到iCloud
-- 快捷键：Hyper + 2
-- 使用前需在Finder中选中要移动的文件
hs.hotkey.bind(hyper, "2", icloud.moveToICloud)

-- 启动鼠标随机移动（每30秒移动一次）
-- 快捷键：Hyper + 5
-- 用于防止屏幕休眠或保持活跃状态，用于某些需要挂机的场景
hs.hotkey.bind(hyper, "5", mouse.startMouseMovement)

-- 停止鼠标随机移动
-- 快捷键：Hyper + 6
hs.hotkey.bind(hyper, "6", mouse.stopMouseMovement)

-- ========================================
-- 配置加载完成提示
-- ========================================
hs.alert.show("Hammerspoon 配置已加载！")
