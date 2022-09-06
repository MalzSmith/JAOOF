--- Simple demo application

local counter = 0

local function LabelTextProvider()
    return tostring(counter)
end

local jaoof = require("jaoof")

local application = jaoof.app:new()
application.title = "TestApplication"
application.titleBarColor = 0x101010
application:databind("title", LabelTextProvider)


application:start()

