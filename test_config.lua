-- ========================================
-- 配置文件验证测试脚本
-- ========================================
-- 用于验证 system prompt 移到 config.lua 后的功能
-- ========================================

local calendar = require("calendar")

print("========================================")
print("开始测试配置文件功能")
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

-- 测试用例5: 原始错误案例
hs.timer.doAfter(20, function()
    print("\n测试5: 原始错误案例")
    print("输入: 下周一（1月12日），四川省教育装备行业协会高等教育技术专业委员会一行16人到中心交流调研")
    calendar.testProcessText("下周一（1月12日），四川省教育装备行业协会高等教育技术专业委员会一行16人到中心交流调研")
end)

hs.timer.doAfter(25, function()
    print("\n========================================")
    print("测试完成")
    print("========================================")
end)
