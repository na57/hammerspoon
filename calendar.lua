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
                content = [[你是一个专业的日历日程信息提取助手。请从用户输入的文本中提取关键日程信息，并以JSON格式返回。

【JSON字段要求】
{
  "title": "事件标题（简洁明确，仅包含核心行动内容）",
  "time": "开始时间，格式YYYY-MM-DD HH:MM（24小时制）",
  "duration": "持续时间，格式如'1小时'、'30分钟'、'2小时30分钟'",
  "location": "事件地点",
  "attendees": ["参与人员姓名数组"],
  "description": "事件详细描述"
}

【事件标题提取规则】
- 仅提取核心行动内容，去除冗余修饰词和无关信息
- 标题应简洁明了，准确反映"需要执行的具体事项"
- 示例：
  * "明天下午3点和张三开会讨论项目进度" → "和张三开会讨论项目进度"
  * "下周二上午10点在会议室A参加产品评审会议" → "参加产品评审会议"
  * "周五下午2点去健身房锻炼" → "去健身房锻炼"

【开始时间处理规则】
- 优先提取文本中明确提及的时间信息
- 对于相对日期（如"明天"、"下周一"），转换为具体日期（YYYY-MM-DD格式）
- 时间使用24小时制HH:MM格式
- 当文本未明确提及具体时间点时，按以下规则智能推测：
  * 会议、工作相关事件：默认上午9:00
  * 休闲、娱乐、运动等事件：默认下午14:00
  * 用餐相关事件：默认中午12:00或晚上18:00
  * 无法判断类型时：默认上午9:00

【持续时间处理规则】
- 优先提取文本中明确提及的持续时间
- 当文本未明确提及持续时间时，按以下规则智能推测：
  * 会议：默认1小时
  * 面试：默认1小时
  * 培训/课程：默认2小时
  * 运动/健身：默认1小时
  * 用餐：默认1小时
  * 其他事件：默认1小时

【参与人员提取规则】
- 仅提取文本中明确出现的真实人员姓名
- 排除职位、称谓等非姓名信息（如"经理"、"老师"、"医生"等）
- 支持提取多个参与人员姓名，以数组形式返回
- 若文本未提及任何人员信息，返回null
- 示例：
  * "和张三、李四开会" → ["张三", "李四"]
  * "和经理开会" → null（"经理"是职位，不是姓名）
  * "和王老师讨论" → null（"老师"是称谓，不是姓名）

【其他注意事项】
- 确保返回的JSON格式正确，不包含任何额外的文本
- 如果没有提取到某些信息，对应字段返回null
- location字段：提取文本中明确提到的地点信息]]
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
