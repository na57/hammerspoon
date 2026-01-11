-- ========================================
-- 日程解析功能测试脚本
-- ========================================
-- 用于测试优化后的日程文本解析功能
-- ========================================

local calendar = require("calendar")

-- 测试用例集合
local testCases = {
    {
        name = "测试1: 会议事件（无明确时间）",
        input = "明天和张三开会讨论项目进度",
        expected = {
            title = "和张三开会讨论项目进度",
            time = "上午9:00",
            duration = "1小时",
            attendees = {"张三"}
        }
    },
    {
        name = "测试2: 运动事件（无明确时间）",
        input = "周五下午去健身房锻炼",
        expected = {
            title = "去健身房锻炼",
            time = "下午14:00",
            duration = "1小时",
            attendees = nil
        }
    },
    {
        name = "测试3: 面试事件（无明确时间）",
        input = "下周二参加技术面试",
        expected = {
            title = "参加技术面试",
            time = "上午9:00",
            duration = "1小时",
            attendees = nil
        }
    },
    {
        name = "测试4: 培训事件（无明确时间）",
        input = "下周一参加产品培训课程",
        expected = {
            title = "参加产品培训课程",
            time = "上午9:00",
            duration = "2小时",
            attendees = nil
        }
    },
    {
        name = "测试5: 用餐事件（无明确时间）",
        input = "明天中午和同事一起吃饭",
        expected = {
            title = "和同事一起吃饭",
            time = "中午12:00",
            duration = "1小时",
            attendees = nil
        }
    },
    {
        name = "测试6: 多人参与事件",
        input = "明天下午3点和张三、李四、王五开会",
        expected = {
            title = "和张三、李四、王五开会",
            time = "15:00",
            duration = "1小时",
            attendees = {"张三", "李四", "王五"}
        }
    },
    {
        name = "测试7: 排除职位称谓",
        input = "明天和经理开会讨论工作",
        expected = {
            title = "和经理开会讨论工作",
            time = "上午9:00",
            duration = "1小时",
            attendees = nil
        }
    },
    {
        name = "测试8: 排除老师称谓",
        input = "下周三下午和王老师讨论论文",
        expected = {
            title = "和王老师讨论论文",
            time = "下午14:00",
            duration = "1小时",
            attendees = nil
        }
    },
    {
        name = "测试9: 明确时间的事件",
        input = "明天下午3点到5点在会议室A开会",
        expected = {
            title = "在会议室A开会",
            time = "15:00",
            duration = "2小时",
            attendees = nil
        }
    },
    {
        name = "测试10: 简洁标题提取",
        input = "下周二上午10点在会议室B参加产品评审会议，讨论新功能上线计划",
        expected = {
            title = "参加产品评审会议",
            time = "10:00",
            duration = "1小时",
            attendees = nil
        }
    }
}

-- 运行单个测试用例
local function runTestCase(testCase)
    print("\n========================================")
    print("测试用例: " .. testCase.name)
    print("输入文本: " .. testCase.input)
    print("========================================")
    
    -- 调用日历处理函数
    calendar.testProcessText(testCase.input)
end

-- 运行所有测试用例
local function runAllTests()
    print("\n========================================")
    print("开始运行日程解析功能测试")
    print("========================================")
    
    for i, testCase in ipairs(testCases) do
        runTestCase(testCase)
        
        -- 等待3秒再进行下一个测试
        if i < #testCases then
            hs.timer.doAfter(4, function()
                print("\n等待下一个测试用例...")
            end)
        end
    end
    
    print("\n========================================")
    print("所有测试用例执行完成")
    print("========================================")
end

-- 导出测试函数
local testCalendar = {
    runAllTests = runAllTests,
    runTestCase = runTestCase,
    testCases = testCases
}

return testCalendar
