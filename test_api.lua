-- 简单的API测试脚本
local calendar = require("calendar")

print("测试1: 会议事件（无明确时间）")
calendar.testProcessText("明天和张三开会讨论项目进度")

hs.timer.doAfter(5, function()
    print("\n测试2: 运动事件（无明确时间）")
    calendar.testProcessText("周五下午去健身房锻炼")
end)

hs.timer.doAfter(10, function()
    print("\n测试3: 多人参与事件")
    calendar.testProcessText("明天下午3点和张三、李四、王五开会")
end)

hs.timer.doAfter(15, function()
    print("\n测试4: 排除职位称谓")
    calendar.testProcessText("明天和经理开会讨论工作")
end)

hs.timer.doAfter(20, function()
    print("\n测试完成")
end)
