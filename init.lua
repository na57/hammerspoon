-- 设置 Hyper 键（Cmd + Shift + Option）
local hyper = {"cmd", "shift", "alt"}

-- 清除显示器残影的函数
function clearScreenGhosting(screen)
    if not screen then
        screen = hs.screen.mainScreen()
    end
    
    -- 方法1: 强制刷新屏幕
    screen:invalidate()
    
    -- 方法2: 创建临时透明窗口强制重绘
    local frame = screen:frame()
    local tempWin = hs.webview.new(frame, {
        developerExtrasEnabled = false,
    })
    tempWin:window():close()
    
    -- 方法3: 使用AppleScript刷新窗口服务
    local refreshScript = [[
    tell application "System Events"
        tell application "Dock" to quit
        delay 0.5
        tell application "Dock" to activate
    end tell
    ]]
    hs.applescript(refreshScript)
    
    -- 方法4: 触发图形系统刷新
    hs.execute("killall Dock")
end

-- === 显示器切换（支持全屏，防残影） ===
function moveWindowToNextScreen()
    local win = hs.window.focusedWindow()
    if not win then return end

    local currentScreen = win:screen()
    local allScreens = hs.screen.allScreens()
    if #allScreens < 2 then return end

    local nextScreen = currentScreen:next()
    local isFullScreen = win:isFullScreen()

    -- 如果是全屏，先退出全屏
    if isFullScreen then
        win:toggleFullScreen()
        hs.timer.usleep(400000) -- 等待动画完成 (0.4秒)
    end

    -- 移动到下一屏幕（保持相对位置）
    win:moveToScreen(nextScreen, false, true)

    -- 强制刷新窗口位置（防止残影）
    local f = win:frame()
    win:setFrame(f)
    hs.timer.doAfter(0.1, function()
        win:setFrame(f)
    end)

    -- 强制系统重绘：激活 Finder 再返回
    local frontApp = hs.application.frontmostApplication()
    hs.application.launchOrFocus("Finder")
    hs.timer.doAfter(0.15, function()
        frontApp:activate()
        win:focus()
    end)

    -- 如果原本是全屏，延迟恢复
    if isFullScreen then
        hs.timer.doAfter(0.6, function()
            win:toggleFullScreen()
            hs.timer.doAfter(0.3, function()
                win:focus()
            end)
        end)
    end
end

-- 控制台快捷键
hs.hotkey.bind(hyper, "R", function()
    hs.reload()
end)

-- 显示器切换快捷键（Hyper+M）
hs.hotkey.bind(hyper, "M", moveWindowToNextScreen)

-- 清除所有显示器残影的函数
function clearAllScreensGhosting()
    local allScreens = hs.screen.allScreens()
    for _, screen in ipairs(allScreens) do
        clearScreenGhosting(screen)
    end
    hs.alert.show("已清除所有显示器残影")
end

-- 手动清除残影快捷键（Hyper+G）
hs.hotkey.bind(hyper, "G", clearAllScreensGhosting)

-- 窗口全屏切换函数
function toggleFullScreen()
    local win = hs.window.focusedWindow()
    win:toggleFullScreen()
end

-- 窗口全屏快捷键（Hyper+P）
hs.hotkey.bind(hyper, "P", toggleFullScreen)

hs.alert.show("Hammerspoon 配置已加载！")

-- 移动文件到iCloud函数
function moveToICloud()
    -- 获取Finder选中文件
    local applescript = [[
    tell application "Finder"
        set theFiles to selection
        set filePaths to {}
        repeat with i from 1 to (count theFiles)
            set end of filePaths to POSIX path of (theFiles's item i as alias)
        end repeat
        return filePaths
    end tell
    ]]
    
    -- 执行AppleScript并验证结果
    local ok, result = hs.applescript(applescript)
    print("[DEBUG] AppleScript执行结果:", ok, result)
    
    -- 检查返回数据有效性
    if not ok or type(result) ~= "table" or #result == 0 then
        hs.alert.show("未获取到有效文件路径")
        return
    end

    -- 使用hs.fs路径处理
    local targetDir = os.getenv("HOME") .. "/Library/Mobile Documents/com~apple~CloudDocs/ITC/2025年/"
    print("[DEBUG] 解析后的目标路径:", targetDir)

    
    local moveSuccessCount = 0
    for _, filePath in ipairs(result) do
        -- 使用双引号包裹路径处理空格
        local mvCmd = string.format("/bin/mv -f \"%s\" \"%s\"", filePath, targetDir)
        print("[DEBUG] 执行命令:", mvCmd)
        local success, _, code = hs.execute(mvCmd)
        if success and code == 0 then
            moveSuccessCount = moveSuccessCount + 1
        else
            print("[ERROR] 移动失败:", filePath, "状态码:", code)
        end
    end
    
    -- 显示最终结果
    if moveSuccessCount == #result then
        hs.alert.show(string.format("成功移动 %d 个文件", moveSuccessCount))
    else
        hs.alert.show(string.format("部分成功 (%d/%d)", moveSuccessCount, #result))
    end
end

-- 绑定快捷键 Hyper+2
hs.hotkey.bind(hyper, "2", moveToICloud)

-- 全局变量存储鼠标移动定时器
local mouseTimer = nil

-- 在屏幕中间区域随机移动鼠标5次
local function moveMouseRandomly()
    local screen = hs.screen.mainScreen()
    local frame = screen:frame()
    
    -- 计算屏幕中间50%区域 (左右25%-75%，上下25%-75%)
    local centerArea = {
        x = frame.x + frame.w * 0.25,
        y = frame.y + frame.h * 0.25,
        w = frame.w * 0.5,
        h = frame.h * 0.5
    }
    
    -- 随机移动5次鼠标
    for i = 1, 5 do
        local x = centerArea.x + math.random() * centerArea.w
        local y = centerArea.y + math.random() * centerArea.h
        hs.mouse.setAbsolutePosition({x = x, y = y})
        hs.timer.usleep(100000) -- 每次移动间隔100ms
    end
end

-- 启动鼠标移动定时器 (每30秒执行一次)
local function startMouseMovement()
    -- 如果已有定时器则先停止
    if mouseTimer then
        mouseTimer:stop()
    end
    
    -- 创建新定时器，每30秒执行一次
    mouseTimer = hs.timer.new(30, moveMouseRandomly)
    mouseTimer:start()
    
    -- 立即执行一次
    moveMouseRandomly()
    hs.alert('鼠标随机移动已启动')
end

-- 停止鼠标移动定时器
local function stopMouseMovement()
    if mouseTimer then
        mouseTimer:stop()
        mouseTimer = nil
        hs.alert('鼠标随机移动已停止')
    end
end

-- 绑定热键: Hyper+5启动, Hyper+6停止
hs.hotkey.bind(hyper, '5', startMouseMovement)
hs.hotkey.bind(hyper, '6', stopMouseMovement)