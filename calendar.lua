-- ========================================
-- 文本提取日历日程创建功能
-- ========================================
-- 功能：通过Hyper+C快捷键触发文本输入框，提取日程信息并创建日历事件
-- ========================================

local calendar = {}

-- 导入配置文件
local config = require("config").calendar

-- 显示加载状态
local function showLoading(show)
    -- 先关闭旧的提示，避免重复
    if calendar.loadingAlertID then
        -- 使用hs.alert.closeSpecific关闭特定提示
        hs.alert.closeSpecific(calendar.loadingAlertID)
        calendar.loadingAlertID = nil
    end
    
    if show then
        -- 显示新的加载提示
        -- 使用定时器在3秒后关闭提示
        calendar.loadingAlertID = hs.alert.show("正在处理，请稍候...", "informational")
        
        -- 3秒后自动关闭
        hs.timer.doAfter(3, function()
            if calendar.loadingAlertID then
                hs.alert.closeSpecific(calendar.loadingAlertID)
                calendar.loadingAlertID = nil
            end
        end)
    end
end

-- 显示结果提示
local function showResult(message, isSuccess)
    -- 确保message是字符串类型
    if type(message) ~= "string" then
        message = tostring(message)
    end
    
    -- hs.alert.show的正确用法：hs.alert.show(str, [style], [screen], [seconds])
    -- 参数顺序：message, style, screen, seconds
    -- 注意：seconds参数可能不起作用，需要使用定时器手动关闭
    local style = isSuccess and "success" or "critical"
    local alertID = hs.alert.show(message, style)
    
    -- 使用定时器在3秒后关闭提示
    hs.timer.doAfter(3, function()
        hs.alert.closeSpecific(alertID)
    end)
end

-- 调用OpenAI API提取日程信息
local function callOpenAIAPI(text, callback)
    -- 调试信息：打印函数调用
    print("[调试] 进入callOpenAIAPI函数")
    
    -- 构建请求体
    local requestBody = {
        model = config.model,
        messages = {
            {
                role = "system",
                content = config.system_prompt:gsub("{time_zone}", config.time_zone)
            },
            {
                role = "user",
                content = text
            }
        },
        max_tokens = config.max_tokens,
        temperature = config.temperature
    }
    
    -- 标记请求是否已完成
    local requestCompleted = false
    -- 定义超时计时器变量，作用域为整个函数
    local timeoutTimer = nil
    
    -- 构建HTTP请求
    local request = hs.http.asyncPost(
        config.openai_api_url,
        hs.json.encode(requestBody),
        {
            Authorization = "Bearer " .. config.openai_api_key,
            ["Content-Type"] = "application/json"
        },
        function(status, response)    
            -- 检查请求是否已经完成
            if requestCompleted then
                print("[调试] 请求已完成，忽略重复回调")
                return
            end
            
            -- 标记请求已完成
            requestCompleted = true
            
            -- 取消超时计时器
            if timeoutTimer then
                timeoutTimer:stop()
                timeoutTimer = nil
            end
            
            -- 显示加载状态
            showLoading(false)
            
            -- 调试信息：打印请求状态和响应
            print("[调试] API请求状态码:", status)
            print("[调试] API响应内容:", response)
            
            if status == 200 then
                -- 解析API响应
                local success, data = pcall(hs.json.decode, response)
                if success then
                    print("[调试] 解析API响应成功")
                    if data.choices and #data.choices > 0 then
                        local message = data.choices[1].message.content
                        print("[调试] 提取的消息内容:", message)
                        local success, eventData = pcall(hs.json.decode, message)
                        if success then
                            print("[调试] 解析日程信息成功")
                            callback(true, eventData)
                        else
                            print("[调试] 解析日程信息失败")
                            callback(false, "无法解析API返回的日程信息")
                        end
                    else
                        print("[调试] API返回格式错误，缺少choices字段")
                        callback(false, "API返回格式错误")
                    end
                else
                    print("[调试] 解析API响应失败")
                    callback(false, "无法解析API响应")
                end
            else
                print("[调试] API请求失败，状态码:", status)
                callback(false, "API调用失败，状态码：" .. status)
            end
        end
    )
    
    -- 超时处理
    timeoutTimer = hs.timer.doAfter(30, function()
        -- 检查请求是否已经完成
        if requestCompleted then
            print("[调试] 请求已完成，忽略超时回调")
            return
        end
        
        -- 标记请求已完成
        requestCompleted = true
        
        -- 显示加载状态
        showLoading(false)
        
        print("[调试] API请求超时")
        callback(false, "API调用超时，请重试")
    end)
    
    return request
end

-- 创建日历事件
local function createCalendarEvent(eventData, originalText)
    -- 格式化日期时间字符串（用于AppleScript）
    local function formatDateTime(timestamp)
        -- 使用标准日期格式：YYYY-MM-DD HH:MM:SS
        return os.date("%Y-%m-%d %H:%M:%S", timestamp)
    end
    
    -- 转义 AppleScript 字符串
    local function escapeAppleScriptString(str)
        if not str then return "" end
        -- 转义特殊字符
        str = str:gsub("\\", "\\\\")  -- 反斜杠
        str = str:gsub('"', '\\"')    -- 双引号
        str = str:gsub("\n", "\\n")   -- 换行符
        str = str:gsub("\r", "\\r")   -- 回车符
        str = str:gsub("\t", "\\t")   -- 制表符
        return str
    end
    
    -- 验证时间戳
    local startTime = tonumber(eventData.start_time)
    local endTime = tonumber(eventData.end_time)
    
    if not startTime or not endTime then
        showResult("无法解析事件时间", false)
        return false
    end
    
    -- 构建日历事件参数
    local eventParams = {
        summary = eventData.title or "未命名事件",
        description = "原始文本：" .. originalText .. "\n\n" .. (eventData.description or ""),
        location = eventData.location
    }
    
    -- 使用AppleScript创建日历事件（因为Hammerspoon的日历API有限）
    local appleScript = 'tell application "Calendar"\n'
    appleScript = appleScript .. 'set newEvent to make new event at end of events of calendar "' .. escapeAppleScriptString(config.default_calendar) .. '"\n'
    appleScript = appleScript .. 'set summary of newEvent to "' .. escapeAppleScriptString(eventParams.summary) .. '"\n'
    appleScript = appleScript .. 'set start date of newEvent to date "' .. escapeAppleScriptString(formatDateTime(startTime)) .. '"\n'
    appleScript = appleScript .. 'set end date of newEvent to date "' .. escapeAppleScriptString(formatDateTime(endTime)) .. '"\n'
    appleScript = appleScript .. 'set description of newEvent to "' .. escapeAppleScriptString(eventParams.description) .. '"\n'
    
    if eventParams.location then
        appleScript = appleScript .. 'set location of newEvent to "' .. escapeAppleScriptString(eventParams.location) .. '"\n'
    end
    
    appleScript = appleScript .. 'save newEvent\n'
    appleScript = appleScript .. 'end tell'
    
    -- 执行AppleScript
    local success, result = hs.applescript(appleScript)
    if success then
        showResult("日历事件创建成功", true)
        return true
    else
        local errorMsg = result or "未知错误"
        showResult("日历事件创建失败：" .. errorMsg, false)
        return false
    end
end

-- 处理日历文本
local function processCalendarText(text)
    -- 调试信息：打印函数调用
    print("[调试] 进入processCalendarText函数")
    print("[调试] 输入文本:", text)
    
    -- 显示加载状态
    showLoading(true)
    
    -- 检查API密钥是否配置
    if config.openai_api_key == "" or config.openai_api_key == nil then
        showLoading(false)
        print("[调试] API密钥未配置")
        showResult("请先在config.lua中配置OpenAI API密钥", false)
        return
    end
    
    -- 调用API提取日程信息
    print("[调试] 调用callOpenAIAPI函数")
    callOpenAIAPI(text, function(success, data)
        if success then
            -- 创建日历事件
            createCalendarEvent(data, text)
        else
            -- 显示错误信息
            showResult(data, false)
        end
    end)
end

-- 创建输入对话框
local function createInputDialog()
    -- 使用hs.dialog.textPrompt创建阻塞对话框
    -- 正确用法：buttonPressed, textClicked = hs.dialog.textPrompt(title, message, defaultText, button1, button2)
    local buttonPressed, textClicked = hs.dialog.textPrompt(
        "创建日历事件", -- 标题
        "请输入包含日程信息的文本（例如：明天下午3点到5点开会，讨论项目进度，地点在会议室A）", -- 消息
        "", -- 默认文本
        "确认", -- button1 (主要按钮)
        "取消" -- button2 (次要按钮)
    )
    
    -- 调试信息：打印对话框返回结果
    print("[调试] 对话框返回结果:")
    print("[调试] buttonPressed:", buttonPressed)
    print("[调试] textClicked:", textClicked)
    
    -- 处理对话框结果
    if buttonPressed == "确认" then
        if textClicked and textClicked ~= "" then
            -- 处理输入文本
            print("[调试] 调用processCalendarText函数处理文本")
            processCalendarText(textClicked)
        else
            print("[调试] 输入文本为空，不处理")
            local alertID = hs.alert.show("请输入日程信息", "warning")
            
            -- 2秒后自动关闭
            hs.timer.doAfter(2, function()
                hs.alert.closeSpecific(alertID)
            end)
        end
    else
        print("[调试] 用户点击了取消按钮或关闭了对话框")
    end
    
    return
end

-- 触发文本输入对话框
function calendar.showInputDialog()
    createInputDialog()
end

-- 初始化功能
function calendar.init()
    -- 这里可以添加初始化代码
    print("日历日程创建功能已初始化")
end

-- 测试专用函数：暴露processCalendarText用于测试
function calendar.testProcessText(text)
    processCalendarText(text)
end

return calendar
