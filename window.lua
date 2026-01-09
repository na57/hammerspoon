local window = {}

function window.toggleFullScreen()
    local win = hs.window.focusedWindow()
    win:toggleFullScreen()
end

return window
