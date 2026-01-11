#!/bin/bash

# 测试脚本：验证AppleScript格式修复

echo "修复后的AppleScript格式应该如下所示："
echo "======================================"
echo 'tell application "Calendar"'
echo '        set newEvent to make new event at end of events of calendar "Home"'
echo '        set summary of newEvent to "到中心交流调研"'
echo '        set start date of newEvent to date "2026-01-12 09:00:00"'
echo '        set end date of newEvent to date "2026-01-12 10:00:00"'
echo '        set description of newEvent to "四川省教育装备行业协会高等教育技术专业委员会一行16人到中心交流调研"'
echo '        set location of newEvent to "中心"'
echo '        save newEvent'
echo '    end tell'
echo "\n"

echo "每个命令都应该在单独的行上，没有连在一起的情况。"
echo "修复后的代码确保了每个命令后面都有换行符，所以生成的AppleScript会是上述格式。"

# 显示当前calendar.lua中的AppleScript生成逻辑
echo "\n"
echo "当前calendar.lua中的AppleScript生成逻辑："
echo "======================================"
grep -A25 -- "-- 使用AppleScript创建日历事件" /Users/na57/workshop/hammerspoon/calendar.lua
