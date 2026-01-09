local icloud = {}

local function getTargetDirectory()
    return os.getenv("HOME") .. "/Library/Mobile Documents/com~apple~CloudDocs/ITC/2025年/"
end

local function getSelectedFiles()
    local applescript = [[
    tell application "Finder"
        set theFiles to selection
        set filePaths to {}
        repeat with i from 1 to (count theFiles)
            set end of filePaths to POSIX path of (theFiles's item i as alias)
        end repeat
        return filePaths
    end tell
    ]]
    
    local ok, result = hs.applescript(applescript)
    print("[DEBUG] AppleScript执行结果:", ok, result)
    
    if not ok or type(result) ~= "table" or #result == 0 then
        return nil
    end
    
    return result
end

local function moveFile(filePath, targetDir)
    local mvCmd = string.format("/bin/mv -f \"%s\" \"%s\"", filePath, targetDir)
    print("[DEBUG] 执行命令:", mvCmd)
    local success, _, code = hs.execute(mvCmd)
    return success and code == 0
end

function icloud.moveToICloud()
    local filePaths = getSelectedFiles()
    
    if not filePaths then
        hs.alert.show("未获取到有效文件路径")
        return
    end

    local targetDir = getTargetDirectory()
    print("[DEBUG] 解析后的目标路径:", targetDir)

    local moveSuccessCount = 0
    for _, filePath in ipairs(filePaths) do
        if moveFile(filePath, targetDir) then
            moveSuccessCount = moveSuccessCount + 1
        else
            print("[ERROR] 移动失败:", filePath)
        end
    end
    
    if moveSuccessCount == #filePaths then
        hs.alert.show(string.format("成功移动 %d 个文件", moveSuccessCount))
    else
        hs.alert.show(string.format("部分成功 (%d/%d)", moveSuccessCount, #filePaths))
    end
end

return icloud
