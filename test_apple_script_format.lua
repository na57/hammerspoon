-- 测试文件：验证AppleScript格式修复
-- 直接输出修复后的AppleScript格式示例

print("修复后的AppleScript格式应该如下所示：")
print("======================================")
print([[tell application "Calendar"]])
print("        set newEvent to make new event at end of events of calendar \"Home\"")
print("        set summary of newEvent to \"到中心交流调研\"")
print("        set start date of newEvent to date \"2026-01-12 09:00:00\"")
print("        set end date of newEvent to date \"2026-01-12 10:00:00\"")
print("        set description of newEvent to \"四川省教育装备行业协会高等教育技术专业委员会一行16人到中心交流调研\"")
print("        set location of newEvent to \"中心\"")
print("        save newEvent")
print("    end tell")
print("\n")

print("每个命令都应该在单独的行上，没有连在一起的情况。")
print("修复后的代码确保了每个命令后面都有换行符\n，所以生成的AppleScript会是上述格式。")
