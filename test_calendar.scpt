tell application "Calendar"
    set defaultCal to first calendar
    
    -- 测试创建事件的几种方式
    try
        -- 方式1：创建时设置所有属性（单行格式）
        make new event at end of events of defaultCal with properties {summary:"测试事件1", start date:date "2026-01-12 09:00:00", end date:date "2026-01-12 10:00:00", description:"这是一个测试事件", location:"测试地点"}
        log "方式1成功"
    on error errMsg
        log "方式1失败: " & errMsg
    end try
    
    try
        -- 方式2：分步设置属性
        set newEvent to make new event at end of events of defaultCal
        set summary of newEvent to "测试事件2"
        set start date of newEvent to date "2026-01-12 11:00:00"
        set end date of newEvent to date "2026-01-12 12:00:00"
        set description of newEvent to "这是另一个测试事件"
        set location of newEvent to "测试地点2"
        log "方式2成功"
    on error errMsg
        log "方式2失败: " & errMsg
    end try
    
    try
        -- 方式3：使用默认值简化（单行格式）
        make new event at end of events of defaultCal with properties {summary:"测试事件3", start date:current date, end date:(current date) + 3600}
        log "方式3成功"
    on error errMsg
        log "方式3失败: " & errMsg
    end try
end tell