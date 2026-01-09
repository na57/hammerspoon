local mouse = {}

local mouseTimer = nil

local function calculateCenterArea(frame)
    return {
        x = frame.x + frame.w * 0.25,
        y = frame.y + frame.h * 0.25,
        w = frame.w * 0.5,
        h = frame.h * 0.5
    }
end

local function getRandomPosition(centerArea)
    local x = centerArea.x + math.random() * centerArea.w
    local y = centerArea.y + math.random() * centerArea.h
    return {x = x, y = y}
end

local function moveMouseRandomly()
    local screen = hs.screen.mainScreen()
    local frame = screen:frame()
    local centerArea = calculateCenterArea(frame)
    
    for i = 1, 5 do
        local position = getRandomPosition(centerArea)
        hs.mouse.setAbsolutePosition(position)
        hs.timer.usleep(100000)
    end
end

function mouse.startMouseMovement()
    if mouseTimer then
        mouseTimer:stop()
    end
    
    mouseTimer = hs.timer.new(30, moveMouseRandomly)
    mouseTimer:start()
    
    moveMouseRandomly()
    hs.alert('鼠标随机移动已启动')
end

function mouse.stopMouseMovement()
    if mouseTimer then
        mouseTimer:stop()
        mouseTimer = nil
        hs.alert('鼠标随机移动已停止')
    end
end

return mouse
