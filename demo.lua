#!/usr/bin/env lua
--- Simple demo application

-- DEBUG = true

TITLE = "ALMA"
function TitleProvider()
    return TITLE
end

require("jaoof")

local application = App:new()
application.title = "test"
application:start()

application:databind("title", TitleProvider)

-- Tick the app manually, this won't be necessary once there is an event loop