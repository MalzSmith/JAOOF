--- Simple demo application

local counter = 0

local function LabelTextProvider()
    return tostring(counter)
end

local jaoof = require("jaoof")

local application = jaoof.app:new()
application.title = "TestApplication"
application.titleBarColor = 0x101010
application:start()

application:databind("title", LabelTextProvider)

-- Tick the app manually, this won't be necessary once there is an event loop