-- 测试文件：测试日历事件AppleScript生成逻辑
-- 运行方式：在Hammerspoon控制台中运行或使用luajit

-- 模拟配置
local config = {
    default_calendar = "Home"
}

-- 模拟escapeAppleScriptString函数
local function escapeAppleScriptString(str)
    if not str then return "" end
    str = str:gsub('"', '\\"')    -- 双引号
    str = str:gsub('\n', '')        -- 移除回车符
    str = str:gsub('\r', '')        -- 移除回车符
    return str
end

-- 模拟createCalendarEvent函数的核心逻辑：生成AppleScript
local function testCreateAppleScript()
    -- 模拟事件数据
    local eventData = {
        title = "测试事件",
        start_time = "2026-01-12 09:00:00",
        end_time = "2026-01-12 10:00:00",
        description = "这是一个测试事件的描述",
        location = "测试地点"
    }
    
    local originalText = "原始测试文本"
    
    -- 构建日历事件参数
    local eventParams = {
        summary = eventData.title or "未命名事件",
        description = eventData.description or "", -- 直接使用LLM输出的description
        location = eventData.location
    }
    
    local startTimeStr = eventData.start_time
    local endTimeStr = eventData.end_time
    
    -- 使用修复后的AppleScript生成逻辑
    local appleScript = "tell application \"Calendar\"\n"
    
    -- 逐个添加命令，确保每个命令都在单独的行上
    appleScript = appleScript .. "        set newEvent to make new event at end of events of calendar \"" .. escapeAppleScriptString(config.default_calendar) .. "\"\n"
    appleScript = appleScript .. "        set summary of newEvent to \"" .. escapeAppleScriptString(eventParams.summary) .. "\"\n"
    appleScript = appleScript .. "        set start date of newEvent to date \"" .. escapeAppleScriptString(startTimeStr) .. "\"\n"
    appleScript = appleScript .. "        set end date of newEvent to date \"" .. escapeAppleScriptString(endTimeStr) .. "\"\n"
    appleScript = appleScript .. "        set description of newEvent to \"" .. escapeAppleScriptString(eventParams.description) .. "\"\n"
    
    -- 添加location（如果有）
    if eventParams.location then
        appleScript = appleScript .. "        set location of newEvent to \"" .. escapeAppleScriptString(eventParams.location) .. "\"\n"
    end
    
    -- 添加save命令和结束语句
    appleScript = appleScript .. "        save newEvent\n"
    appleScript = appleScript .. "    end tell"
    
    -- 打印生成的AppleScript
    print("生成的AppleScript:")
    print(appleScript)
    print("\n")
    
    -- 验证格式：检查每个命令是否都在单独的行上
    print("验证结果:")
    
    -- 检查tell application行
    if appleScript:find("^tell application") then
        print("✓ tell application行格式正确")
    else
        print("✗ tell application行格式错误")
    end
    
    -- 检查set newEvent行
    if appleScript:find("\n        set newEvent") then
        print("✓ set newEvent行格式正确")
    else
        print("✗ set newEvent行格式错误")
    end
    
    -- 检查set summary行
    if appleScript:find("\n        set summary") then
        print("✓ set summary行格式正确")
    else
        print("✗ set summary行格式错误")
    end
    
    -- 检查set start date行
    if appleScript:find("\n        set start date") then
        print("✓ set start date行格式正确")
    else
        print("✗ set start date行格式错误")
    end
    
    -- 检查set end date行
    if appleScript:find("\n        set end date") then
        print("✓ set end date行格式正确")
    else
        print("✗ set end date行格式错误")
    end
    
    -- 检查set description行
    if appleScript:find("\n        set description") then
        print("✓ set description行格式正确")
    else
        print("✗ set description行格式错误")
    end
    
    -- 检查set location行
    if appleScript:find("\n        set location") then
        print("✓ set location行格式正确")
    else
        print("✗ set location行格式错误")
    end
    
    -- 检查save newEvent行
    if appleScript:find("\n        save newEvent") then
        print("✓ save newEvent行格式正确")
    else
        print("✗ save newEvent行格式错误")
    end
    
    -- 检查end tell行
    if appleScript:find("\n    end tell$") then
        print("✓ end tell行格式正确")
    else
        print("✗ end tell行格式错误")
    end
    
    return appleScript
end

-- 运行测试
print("开始测试日历事件AppleScript生成逻辑...")
print("======================================")
local appleScript = testCreateAppleScript()
print("\n测试完成!")

-- 返回生成的AppleScript，方便在Hammerspoon中查看
return appleScript
