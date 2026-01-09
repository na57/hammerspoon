-- ========================================
-- 文本提取日历日程创建功能
-- ========================================
-- 功能：通过Hyper+C快捷键触发文本输入框，提取日程信息并创建日历事件
-- ========================================

local calendar = {}

-- 导入配置文件
local config = require("config").calendar

-- 创建输入对话框
local function createInputDialog()
    -- 正确的hs.dialog.textPrompt签名：title, message, defaultText, button1, button2, informativeText, secure
    -- 这里我们使用正确的参数顺序和类型
    -- hs.dialog.textPrompt返回一个表，包含按钮和文本信息
    local dialog = hs.dialog.textPrompt(
        "创建日历事件", -- 标题
        "请输入包含日程信息的文本（例如：明天下午3点到5点开会，讨论项目进度，地点在会议室A）", -- 消息
        "", -- 默认文本
        "确认", -- 确认按钮
        "取消" -- 取消按钮
        -- 注意：这里我们不传递第6个参数，或者根据需要传递informativeText或secure参数
    )
    
    -- 处理对话框结果
    if dialog.buttonPressed == "确认" and dialog.textClicked ~= "" then
        -- 处理输入文本
        processCalendarText(dialog.textClicked)
    end
    
    -- 设置对话框样式
    dialog:style(hs.dialog.style.default)
    return dialog
end

-- 显示加载状态
local function showLoading(show)
    if show then
        calendar.loadingAlert = hs.alert.show("正在处理，请稍候...", "informational")
    else
        if calendar.loadingAlert then
            calendar.loadingAlert:withdraw()
            calendar.loadingAlert = nil
        end
    end
end

-- 显示结果提示
local function showResult(message, isSuccess)
    local style = isSuccess and "success" or "critical"
    hs.alert.show(message, style, 3)
end

-- 调用OpenAI API提取日程信息
local function callOpenAIAPI(text, callback)
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
    
    -- 构建HTTP请求
    local request = hs.http.asyncPost(
        config.openai_api_url,
        hs.json.encode(requestBody),
        {
            Authorization = "Bearer " .. config.openai_api_key,
            ["Content-Type"] = "application/json"
        },
        function(status, response)
            showLoading(false)
            
            if status == 200 then
                -- 解析API响应
                local success, data = pcall(hs.json.decode, response)
                if success and data.choices and #data.choices > 0 then
                    local message = data.choices[1].message.content
                    local success, eventData = pcall(hs.json.decode, message)
                    if success then
                        callback(true, eventData)
                    else
                        callback(false, "无法解析API返回的日程信息")
                    end
                else
                    callback(false, "API返回格式错误")
                end
            else
                callback(false, "API调用失败，状态码：" .. status)
            end
        end
    )
    
    -- 超时处理
    hs.timer.doAfter(5, function()
        showLoading(false)
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
    -- 显示加载状态
    showLoading(true)
    
    -- 调用API提取日程信息
    callOpenAIAPI(text, function(success, data)
        if success then
            -- 创建日历事件
            createCalendarEvent(data, text)
        else
            -- 显示错误信息
            showResult(data, false)
            
            -- 提供手动编辑选项
            hs.dialog.textPrompt(
                "API调用失败",
                "无法自动提取日程信息，请手动输入或修改。\n错误信息：" .. data .. "\n\n原始文本：" .. text,
                "",
                "确认",
                "取消",
                function(button, manualText)
                    if button == "确认" and manualText ~= "" then
                        -- 这里可以实现手动创建日历事件的逻辑
                        showResult("手动创建功能尚未实现", false)
                    end
                end
            )
        end
    end)
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

return calendar
