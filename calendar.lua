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
        -- 正确参数顺序：hs.alert.show(str, [style], [screen], [seconds])
        -- 第四个参数才是显示时间（秒）
        calendar.loadingAlertID = hs.alert.show(
            "正在处理，请稍候...", -- str
            "informational", -- style
            nil, -- screen (nil表示使用主屏幕)
            3 -- seconds (显示3秒后自动消失)
        )
    end
end

-- 显示结果提示
local function showResult(message, isSuccess)
    -- 确保message是字符串类型
    if type(message) ~= "string" then
        message = tostring(message)
    end
    
    -- 简化调用，只使用前两个参数
    -- hs.alert.show的正确用法：hs.alert.show(message, [style])
    -- 移除第三个参数，避免类型错误
    local style = isSuccess and "success" or "critical"
    hs.alert.show(message, style, nil, 3)
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
                content = "你是一个专业的日历日程信息提取助手，请从用户输入的文本中提取关键的日程信息，并以JSON格式返回。需要提取的信息包括：事件主题/标题、事件时间（包括日期和具体时间点）、事件地点、事件参与人员、事件持续时间、事件描述。请确保返回的JSON格式正确，不包含任何额外的文本。对于相对日期如\"下周一\"，请转换为具体的日期格式（YYYY-MM-DD）。对于时间，请使用24小时制的HH:MM格式。如果没有提取到某些信息，请返回null值。"
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
    timeoutTimer = hs.timer.doAfter(5, function()
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
    -- 解析日期和时间
    local function parseDateTime(dateStr, timeStr)
        if not dateStr then return nil end
        
        -- 尝试解析日期
        local date = hs.date.parse(dateStr)
        if not date then
            -- 尝试其他日期格式
            local formats = {
                "%Y-%m-%d",
                "%Y/%m/%d",
                "%m/%d/%Y",
                "%d/%m/%Y"
            }
            
            for _, fmt in ipairs(formats) do
                date = hs.date.parse(dateStr, fmt)
                if date then break end
            end
        end
        
        if not date then return nil end
        
        -- 如果有时间，添加时间信息
        if timeStr then
            local timePattern = "(%d+):(%d+)" -- 匹配HH:MM格式
            local hour, min = timeStr:match(timePattern)
            if hour and min then
                -- 设置时间
                date = hs.date.copy(date)
                date = hs.date.setHours(date, tonumber(hour))
                date = hs.date.setMinutes(date, tonumber(min))
            else
                -- 尝试匹配其他时间格式，如"下午3点"或"3pm"
                local timePattern2 = "(%d+)[点|时]?" -- 匹配"3点"或"3时"或"3"
                local hour2 = timeStr:match(timePattern2)
                if hour2 then
                    hour2 = tonumber(hour2)
                    -- 检查是否是下午
                    if timeStr:find("下午") or timeStr:find("pm") or timeStr:find("PM") then
                        if hour2 < 12 then
                            hour2 = hour2 + 12
                        end
                    elseif timeStr:find("上午") or timeStr:find("am") or timeStr:find("AM") then
                        if hour2 == 12 then
                            hour2 = 0
                        end
                    end
                    date = hs.date.copy(date)
                    date = hs.date.setHours(date, hour2)
                    date = hs.date.setMinutes(date, 0)
                end
            end
        end
        
        return date
    end
    
    -- 解析开始时间
    local startTime = parseDateTime(eventData.time, eventData.time)
    if not startTime then
        showResult("无法解析事件时间", false)
        return false
    end
    
    -- 计算结束时间
    local endTime
    if eventData.duration then
        -- 解析持续时间（格式如：1小时，30分钟，2h30m等）
        local duration = eventData.duration
        local hours = 0
        local minutes = 0
        
        -- 提取小时
        local hourMatch = duration:match("(%d+)小时") or duration:match("(%d+)h")
        if hourMatch then
            hours = tonumber(hourMatch)
        end
        
        -- 提取分钟
        local minMatch = duration:match("(%d+)分钟") or duration:match("(%d+)m")
        if minMatch then
            minutes = tonumber(minMatch)
        end
        
        -- 计算结束时间
        endTime = hs.date.copy(startTime)
        endTime = hs.date.setHours(endTime, hs.date.getHours(endTime) + hours)
        endTime = hs.date.setMinutes(endTime, hs.date.getMinutes(endTime) + minutes)
    else
        -- 默认持续1小时
        endTime = hs.date.copy(startTime)
        endTime = hs.date.setHours(endTime, hs.date.getHours(endTime) + 1)
    end
    
    -- 构建日历事件参数
    local eventParams = {
        summary = eventData.title or "未命名事件",
        description = "原始文本：" .. originalText .. "\n\n" .. (eventData.description or ""),
        location = eventData.location
    }
    
    -- 使用AppleScript创建日历事件（因为Hammerspoon的日历API有限）
    local appleScript = [[
        tell application "Calendar"
            set newEvent to make new event at end of events of calendar "]] .. config.default_calendar:gsub('"', '\"') .. [["
            set summary of newEvent to "]] .. eventParams.summary:gsub('"', '\"') .. [["\n            set start date of newEvent to date "]] .. hs.date.format(startTime, "%Y-%m-%d %H:%M") .. [["\n            set end date of newEvent to date "]] .. hs.date.format(endTime, "%Y-%m-%d %H:%M") .. [["\n            set description of newEvent to "]] .. eventParams.description:gsub('"', '\"') .. [["\n    ]]
    
    if eventParams.location then
        appleScript = appleScript .. [[
            set location of newEvent to "]] .. eventParams.location:gsub('"', '\"') .. [["\n        ]]
    end
    
    appleScript = appleScript .. [[
            save newEvent
        end tell
    ]]
    
    -- 执行AppleScript
    local success, result = hs.applescript(appleScript)
    if success then
        showResult("日历事件创建成功", true)
        return true
    else
        showResult("日历事件创建失败：" .. result, false)
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
            hs.alert.show("请输入日程信息", "warning", 2)
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
