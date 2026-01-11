-- ========================================
-- 日程解析功能修复验证脚本
-- ========================================
-- 用于验证 parseDateTime 函数修复后的功能
-- ========================================

local calendar = require("calendar")

print("========================================")
print("开始测试日程创建功能")
print("========================================")

-- 测试用例1: 会议事件（无明确时间，应推测为上午9:00）
print("\n测试1: 会议事件（无明确时间）")
print("输入: 明天和张三开会讨论项目进度")
calendar.testProcessText("明天和张三开会讨论项目进度")

-- 测试用例2: 运动事件（无明确时间，应推测为下午14:00）
hs.timer.doAfter(5, function()
    print("\n测试2: 运动事件（无明确时间）")
    print("输入: 周五下午去健身房锻炼")
    calendar.testProcessText("周五下午去健身房锻炼")
end)

-- 测试用例3: 明确时间的事件
hs.timer.doAfter(10, function()
    print("\n测试3: 明确时间的事件")
    print("输入: 明天下午3点到5点在会议室A开会")
    calendar.testProcessText("明天下午3点到5点在会议室A开会")
end)

-- 测试用例4: 多人参与事件
hs.timer.doAfter(15, function()
    print("\n测试4: 多人参与事件")
    print("输入: 明天下午3点和张三、李四、王五开会")
    calendar.testProcessText("明天下午3点和张三、李四、王五开会")
end)

hs.timer.doAfter(20, function()
    print("\n========================================")
    print("测试完成")
    print("========================================")
end)
