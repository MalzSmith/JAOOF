#!/usr/bin/env lua
--- Simple demo application

-- DEBUG = true

local counter = 0

local function LabelTextProvider()
    return counter
end

Jaoof = require("jaoof")

local application = Jaoof.app:new()
application.title = "TestApplication"
application.titleBarColor = 0x101010
application:start()

application:databind("title", LabelTextProvider)

-- Tick the app manually, this won't be necessary once there is an event loop