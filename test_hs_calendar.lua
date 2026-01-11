-- 测试Hammerspoon访问日历的权限和正确语法
local function testCalendarAccess()
    print("开始测试日历访问...")
    
    -- 简单的测试脚本
    local testScript = [[tell application "Calendar"
        set defaultCal to first calendar
        make new event at end of events of defaultCal with properties {
            summary:"HS测试事件",
            start date:date "2026-01-12 14:00:00",
            end date:date "2026-01-12 15:00:00",
            description:"这是一个Hammerspoon测试事件"
        }
    end tell]]
    
    local success, result = hs.osascript.applescript(testScript)
    print("测试结果:")
    print("成功:", success)
    print("结果:", result)
    
    if success then
        print("日历访问测试成功!")
        return true
    else
        print("日历访问测试失败，错误信息:", result)
        return false
    end
end

-- 运行测试
testCalendarAccess()