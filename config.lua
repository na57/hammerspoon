-- ========================================
-- Hammerspoon 配置文件
-- ========================================
-- 存放各个模块的配置参数
-- ========================================

local config = {}

-- 日历模块配置
config.calendar = {
    openai_api_key = "", -- 请在这里填写你的OpenAI API密钥
    openai_api_url = "https://api.openai.com/v1/chat/completions", -- OpenAI API URL
    model = "gpt-4", -- 使用的模型
    max_tokens = 500, -- 最大 tokens
    temperature = 0.1, -- 温度参数，越低越准确
    default_calendar = "默认", -- 默认日历名称
    time_zone = "Asia/Shanghai" -- 时区设置
}

return config
