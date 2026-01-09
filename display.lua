local display = {}

local function invalidateScreen(screen)
    screen:invalidate()
end

local function createTempWindow(screen)
    local frame = screen:frame()
    local tempWin = hs.webview.new(frame, {
        developerExtrasEnabled = false,
    })
    tempWin:window():close()
end

local function refreshWindowService()
    local refreshScript = [[
    tell application "System Events"
        tell application "Dock" to quit
        delay 0.5
        tell application "Dock" to activate
    end tell
    ]]
    hs.applescript(refreshScript)
end

local function restartDock()
    hs.execute("killall Dock")
end

function display.clearScreenGhosting(screen)
    if not screen then
        screen = hs.screen.mainScreen()
    end
    
    invalidateScreen(screen)
    createTempWindow(screen)
    refreshWindowService()
    restartDock()
end

local function exitFullScreen(win)
    win:toggleFullScreen()
    hs.timer.usleep(400000)
end

local function moveWindow(win, nextScreen)
    win:moveToScreen(nextScreen, false, true)
end

local function refreshWindowPosition(win)
    local f = win:frame()
    win:setFrame(f)
    hs.timer.doAfter(0.1, function()
        win:setFrame(f)
    end)
end

local function activateFinderAndReturn(win, frontApp)
    hs.application.launchOrFocus("Finder")
    hs.timer.doAfter(0.15, function()
        frontApp:activate()
        win:focus()
    end)
end

local function restoreFullScreen(win)
    hs.timer.doAfter(0.6, function()
        win:toggleFullScreen()
        hs.timer.doAfter(0.3, function()
            win:focus()
        end)
    end)
end

function display.moveWindowToNextScreen()
    local win = hs.window.focusedWindow()
    if not win then return end

    local currentScreen = win:screen()
    local allScreens = hs.screen.allScreens()
    if #allScreens < 2 then return end

    local nextScreen = currentScreen:next()
    local isFullScreen = win:isFullScreen()
    local frontApp = hs.application.frontmostApplication()

    if isFullScreen then
        exitFullScreen(win)
    end

    moveWindow(win, nextScreen)
    refreshWindowPosition(win)
    activateFinderAndReturn(win, frontApp)

    if isFullScreen then
        restoreFullScreen(win)
    end
end

function display.clearAllScreensGhosting()
    local allScreens = hs.screen.allScreens()
    for _, screen in ipairs(allScreens) do
        display.clearScreenGhosting(screen)
    end
    hs.alert.show("已清除所有显示器残影")
end

return display
