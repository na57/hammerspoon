-- ========================================
-- Hammerspoon 配置文件
-- ========================================
-- 存放各个模块的配置参数
-- ========================================

local config = {}

-- 日历模块配置
config.calendar = {
    openai_api_key = "0cb4aa30-0b1c-451c-8002-893b1727bbac", -- 请在这里填写你的OpenAI API密钥
    openai_api_url = "https://ark.cn-beijing.volces.com/api/v3/chat/completions", -- OpenAI API URL
    model = "doubao-seed-code-preview-251028", -- 使用的模型
    max_tokens = 4096, -- 最大 tokens
    temperature = 0.1, -- 温度参数，越低越准确
    default_calendar = "Home", -- 默认日历名称
    time_zone = "Asia/Shanghai", -- 时区设置

}

return config
