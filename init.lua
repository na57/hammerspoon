local hyper = {"cmd", "shift", "alt"}

local display = require("display")
local window = require("window")
local icloud = require("icloud")
local mouse = require("mouse")

hs.hotkey.bind(hyper, "R", function()
    hs.reload()
end)

hs.hotkey.bind(hyper, "M", display.moveWindowToNextScreen)
hs.hotkey.bind(hyper, "G", display.clearAllScreensGhosting)
hs.hotkey.bind(hyper, "P", window.toggleFullScreen)
hs.hotkey.bind(hyper, "2", icloud.moveToICloud)
hs.hotkey.bind(hyper, "5", mouse.startMouseMovement)
hs.hotkey.bind(hyper, "6", mouse.stopMouseMovement)

hs.alert.show("Hammerspoon 配置已加载！")
