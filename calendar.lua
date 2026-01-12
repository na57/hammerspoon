-- ========================================
-- 文本提取日历日程创建功能
-- ========================================
-- 功能：通过Hyper+C快捷键触发文本输入框，提取日程信息并创建日历事件
-- ========================================

local calendar = {}

-- 导入配置文件
local config = require("config").calendar

-- 系统提示词，用于指导AI提取日程信息
local system_prompt = [[你是一个专业的日历日程信息提取助手。请从用户输入的文本中提取关键日程信息，并以JSON格式返回。

【JSON字段要求】
{
  "title": "事件标题（简洁明确，仅包含核心行动内容）",
  "start_time": "开始时间，格式YYYY-MM-DD HH:MM:SS（24小时制）",
  "end_time": "结束时间，格式YYYY-MM-DD HH:MM:SS（24小时制）",
  "location": "事件地点",
  "attendees": ["参与人员姓名数组"],
  "description": "事件详细描述"
}

【时间计算规则】
- 计算时请使用当前时间 {current_time} 作为基准
- 对于相对日期（如"明天"、"下周一"），请转换为具体的日期
- 时区必须使用{time_zone}（UTC+8）
- 时间格式必须使用24小时制，格式为YYYY-MM-DD HH:MM:SS
- 示例（使用 Asia/Shanghai 时区，UTC+8）：
  * 2026年1月13日 09:00:00 (北京时间，下周一) → start_time: "2026-01-13 09:00:00"
  * 2026年1月13日 10:00:00 (北京时间) → end_time: "2026-01-13 10:00:00"

【事件标题提取规则】
- 标题必须极度简洁，只保留最核心的1-5个关键词
- 去除所有时间、地点、人员等辅助信息（这些信息会在其他字段单独保存）
- 只保留最核心的动作和对象，去除所有修饰词和细节
- 示例：
  * "明天下午3点和张三开会讨论项目进度" → "项目进度会议"
  * "下周二上午10点在会议室A参加产品评审会议" → "产品评审"
  * "周五下午2点去健身房锻炼" → "健身"
  * "今天晚上7点和家人一起吃晚饭" → "晚饭"
  * "下周一下午2点给李总汇报季度工作" → "季度汇报"

【开始时间处理规则】
- 优先提取文本中明确提及的时间信息
- 当文本未明确提及具体时间点时，按以下规则智能推测：
  * 会议、工作相关事件：默认上午9:00
  * 休闲、娱乐、运动等事件：默认下午14:00
  * 用餐相关事件：默认中午12:00或晚上18:00
  * 无法判断类型时：默认上午9:00

【结束时间处理规则】
- 优先提取文本中明确提及的持续时间
- 根据开始时间和持续时间计算结束时间
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
- location字段：提取文本中明确提到的地点信息
- start_time和end_time必须是整数时间戳]]

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
        -- 显示加载提示，不设置自动关闭时间，直到API调用结束
        calendar.loadingAlertID = hs.alert.show("正在处理，请稍候...")
    end
end

-- 显示结果提示
local function showResult(message, isSuccess)
    -- 确保message是字符串类型
    if type(message) ~= "string" then
        message = tostring(message)
    end
    
    -- hs.alert.show的正确用法：hs.alert.show(str, [style_table], [screen], [seconds])
    -- 参数说明：
    --   str: 要显示的消息字符串
    --   style_table: 可选，包含样式属性的table（不是字符串）
    --   screen: 可选，要显示在哪个屏幕上
    --   seconds: 可选，显示持续时间（秒）
    local alertID = hs.alert.show(message, nil, nil, 3)
    
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
            {                role = "system",                content = system_prompt:gsub("{time_zone}", config.time_zone):gsub("{current_time}", os.date("%Y-%m-%d %H:%M:%S"))            },
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
    -- 测试 AppleScript 是否可用
    local function testAppleScript()
        local testScript = [[tell application "Calendar"
            activate
        end tell]]
        local success, result = hs.osascript.applescript(testScript)
        return success, result
    end
    
    -- 转义 AppleScript 字符串
    local function escapeAppleScriptString(str)
        if not str then return "" end
        -- 转义双引号并移除所有回车符
        str = str:gsub('"', '\\"')    -- 双引号
        str = str:gsub('\n', '')        -- 移除回车符
        str = str:gsub('\r', '')        -- 移除回车符
        return str
    end
    
    -- 验证时间字符串
    local startTimeStr = eventData.start_time
    local endTimeStr = eventData.end_time
    
    if not startTimeStr or not endTimeStr then
        showResult("无法解析事件时间", false)
        return false
    end
    
    print("[调试] 开始时间字符串:", startTimeStr)
    print("[调试] 结束时间字符串:", endTimeStr)
    
    -- 构建日历事件参数
    local eventParams = {
        summary = eventData.title or "未命名事件",
        description = eventData.description or "", -- 直接使用LLM输出的description
        location = eventData.location
    }
    
    -- 使用AppleScript创建日历事件（因为Hammerspoon的日历API有限）
    -- 构建单行AppleScript，避免多行格式问题
    local baseScript = "tell application \"Calendar\" to make new event at end of events of first calendar with properties {"
    local properties = {
        "summary:\"" .. escapeAppleScriptString(eventParams.summary) .. "\"",
        "start date:date \"" .. escapeAppleScriptString(startTimeStr) .. "\"",
        "end date:date \"" .. escapeAppleScriptString(endTimeStr) .. "\"",
        "description:\"" .. escapeAppleScriptString(eventParams.description) .. "\""
    }
    
    -- 添加location（如果有）
    if eventParams.location then
        table.insert(properties, "location:\"" .. escapeAppleScriptString(eventParams.location) .. "\"")
    end
    
    local appleScript = baseScript .. table.concat(properties, ", ") .. "}"
    
    -- 调试信息：打印生成的 AppleScript
    print("[调试] 生成的 AppleScript:")
    print(appleScript)
    
    -- 先测试 AppleScript 是否可用
    print("[调试] 测试 AppleScript 连接...")
    local testSuccess, testResult = testAppleScript()
    if not testSuccess then
        print("[调试] AppleScript 连接失败:", testResult)
        showResult("无法连接到日历应用：" .. (testResult or "未知错误"), false)
        return false
    end
    
    -- 执行AppleScript（使用 os.execute 获得更详细的错误信息）
    local tempFile = "/tmp/hammerspoon_calendar.scpt"
    local f = io.open(tempFile, "w")
    if f then
        f:write(appleScript)
        f:close()
        
        local cmd = 'osascript "' .. tempFile .. '"'
        local handle = io.popen(cmd)
        local output = handle:read("*a")
        local exitCode = handle:close()
        
        -- 在 Lua 中，io.popen 的 close() 方法返回 true 表示成功
        if exitCode then
            print("[调试] AppleScript 执行成功，返回值:", output)
            showResult("日历事件创建成功", true)
            return true
        else
            print("[调试] AppleScript 执行失败，退出码:", exitCode)
            print("[调试] 错误输出:", output)
            showResult("日历事件创建失败：" .. (output or "未知错误"), false)
            return false
        end
    else
        showResult("无法创建临时文件", false)
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
            local alertID = hs.alert.show("请输入日程信息", nil, nil, 2)
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
