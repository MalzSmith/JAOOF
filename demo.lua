#!/usr/bin/env lua
--- Simple demo application

-- DEBUG = true

local counter = 0

local function LabelTextProvider()
    return counter
end

require("jaoof")

local application = App:new()
application.title = "test"
application:start()

application:databind("title", LabelTextProvider)

-- Tick the app manually, this won't be necessary once there is an event loop