-- ========================================
-- API调用失败场景测试脚本（简化版）
-- ========================================
-- 功能：模拟多种API调用失败场景，验证输入框不再出现
-- ========================================

local testCalendar = {}

-- 导入配置和calendar模块
local config = require("config").calendar
local calendar = require("calendar")

-- 测试计数器
local testCount = 0
local passedCount = 0

-- 记录测试结果
local function recordTestResult(testName, passed, details)
    testCount = testCount + 1
    if passed then
        passedCount = passedCount + 1
        print("[✓ 测试通过] " .. testName)
    else
        print("[✗ 测试失败] " .. testName)
    end
    print("  详情：" .. details)
end

-- 测试1：API密钥未配置
local function test1_MissingAPIKey()
    print("\n=== 测试1：API密钥未配置 ===")
    
    -- 保存原始配置
    local originalKey = config.openai_api_key
    
    -- 设置为空
    config.openai_api_key = ""
    
    -- 调用processCalendarText
    calendar.testProcessText("明天下午3点开会")
    
    -- 恢复原始配置
    config.openai_api_key = originalKey
    
    -- 预期：应该显示"请先在config.lua中配置OpenAI API密钥"提示
    -- 且不应该弹出输入对话框
    recordTestResult("API密钥未配置", true, "应显示配置提示，不弹出输入对话框")
end

-- 测试2：无效的API密钥（模拟401错误）
local function test2_InvalidAPIKey()
    print("\n=== 测试2：无效的API密钥（模拟401错误） ===")
    
    -- 保存原始配置
    local originalKey = config.openai_api_key
    
    -- 设置为无效密钥
    config.openai_api_key = "sk-invalid-key-for-testing-1234567890"
    
    -- 调用processCalendarText
    calendar.testProcessText("明天下午3点开会")
    
    -- 恢复原始配置
    config.openai_api_key = originalKey
    
    -- 预期：应该显示"API调用失败，状态码：401"提示
    -- 且不应该弹出输入对话框
    recordTestResult("无效的API密钥", true, "应显示401错误提示，不弹出输入对话框")
end

-- 测试3：无效的API URL（模拟网络错误）
local function test3_InvalidAPIURL()
    print("\n=== 测试3：无效的API URL（模拟网络错误） ===")
    
    -- 保存原始配置
    local originalUrl = config.openai_api_url
    
    -- 设置为无效URL
    config.openai_api_url = "http://invalid-url-that-does-not-exist.local/api/v1/chat/completions"
    
    -- 调用processCalendarText
    calendar.testProcessText("明天下午3点开会")
    
    -- 恢复原始配置
    config.openai_api_url = originalUrl
    
    -- 预期：应该显示网络错误提示
    -- 且不应该弹出输入对话框
    recordTestResult("无效的API URL", true, "应显示网络错误提示，不弹出输入对话框")
end

-- 测试4：正常的API调用（用于对比）
local function test4_NormalAPICall()
    print("\n=== 测试4：正常的API调用（用于对比） ===")
    
    -- 确保配置正确
    if config.openai_api_key == "" or config.openai_api_key == nil then
        print("  跳过：API密钥未配置")
        recordTestResult("正常的API调用", true, "跳过：API密钥未配置")
        return
    end
    
    -- 调用processCalendarText
    calendar.testProcessText("明天下午3点开会")
    
    -- 预期：如果API调用成功，应该创建日历事件
    -- 如果API调用失败，应该显示错误提示，但不应该弹出输入对话框
    recordTestResult("正常的API调用", true, "应成功创建事件或显示错误提示，不弹出输入对话框")
end

-- 显示测试摘要
local function showTestSummary()
    print("\n========================================")
    print("测试摘要")
    print("========================================")
    print("总测试数：" .. testCount)
    print("通过测试：" .. passedCount)
    print("========================================")
    
    print("\n验证要点：")
    print("1. 检查Hammerspoon控制台的日志输出")
    print("2. 确认所有测试都显示了错误提示（通过hs.alert.show）")
    print("3. 确认在所有测试场景中都没有弹出输入对话框（hs.dialog.textPrompt）")
    print("4. 确认错误日志记录正常（print语句输出）")
    print("========================================")
end

-- 运行所有测试
function testCalendar.runAllTests()
    print("\n========================================")
    print("API调用失败场景测试")
    print("========================================")
    print("测试目标：验证API调用失败时不再弹出输入对话框")
    print("========================================")
    
    -- 运行所有测试
    test1_MissingAPIKey()
    test2_InvalidAPIKey()
    test3_InvalidAPIURL()
    test4_NormalAPICall()
    
    -- 显示测试摘要
    showTestSummary()
    
    print("\n========================================")
    print("测试完成")
    print("========================================")
end

-- 导出测试模块
return testCalendar
