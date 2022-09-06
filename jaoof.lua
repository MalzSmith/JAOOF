-- I've dumped everything in a single file because I'm lazy and I want to make installation of this thing as easy as possible

TextMode = false

---@param text string
local function debugPrint(text)
    if TextMode then
        print(text)
    end
end

local gpu = require("component").gpu

local graphics = {}

if not gpu then
    debugPrint("RUNNING WITHOUT GPU ENABLED")
    TextMode = true
end

--- OpenComputers stuff ------------------------------------------------------------------------------------------------------------------------------

---Wrapper for gpu.setBackground
---@param value integer
---@return nil
function graphics.setBackground(value)
    if not TextMode then
        gpu.setBackground(value)
    end
end

--- OpenComputers stuff

---Wrapper for gpu.setForeground
---@param value integer
---@return nil
function graphics.setForeground(value)
    if not TextMode then
        gpu.setForeground(value)
    end
end

---Wrapper for gpu.fill
---@param x integer
---@param y integer
---@param height integer
---@param width integer
---@param color integer
function graphics.drawRectangle(x, y, width, height, color)
    if not TextMode then
        local previousColor, _ = gpu.getBackground()
        gpu.setBackground(color)
        gpu.fill(x, y, width, height, " ")
        gpu.setBackground(previousColor)
    end
end

---Wrapper for gpu.getResolution
---@return number, number
function graphics.resolution()
    if not TextMode then
        return gpu.getResolution()
    end
    return 0, 0
end

---Wrapper for gpu.set
---@param x number
---@param y number
---@param value string
---@param color integer
---@return boolean
function graphics.set(x, y, value, color)
    if not TextMode then
        local previousColor, _ = gpu.getBackground()
        gpu.setBackground(color)
        local res = gpu.set(x, y, value)
        gpu.setBackground(previousColor)
        return res
    else
        return false
    end
end

local windowWidth, windowHeight = graphics.resolution()

function graphics.clearScreen()
    graphics.drawRectangle(1, 1, windowWidth, windowHeight, 0x000000)
end

--- Should probably write a wrapper for this too for compatibility?
local event = require("event")


-- control class ------------------------------------------------------------------------------------------------------------------------------

---INTERNAL USE, USE THE DERIVED CLASSES INSTEAD - Base class for other controls
---@class control
---@field isVisible boolean Whether the control is visible or not
---@field orientation boolean orientation of the control (true is vertical, false is horizontal)
---@field flowDirection boolean flow direction of the control (true is left->right or top->bottom, false is reversed)
---@field foregroundColor integer | nil
---@field backgroundColor integer | nil
---@field databindings table INTERNAL USE - data bindings of the control
local control = {}
control.isVisible = true
control.databindings = {}
control.orientation = true
control.flowDirection = true
control.backgroundColor = nil
control.foregroundColor = nil
--- Yeah, not sure why you are reading my code but I feel sorry for you.
--- Anyways, these variables are used internally
control.x = 1
control.y = 1
control.h = 0
control.w = 0


---Constructor for the control class
---@param obj control | nil
---@return control
function control:new(obj)
    obj = obj or {}
    local e = {}
    self.__index = self
    setmetatable(e, self)
    for k, v in pairs(self) do
        e[k] = obj[k] or v
    end
    return e
end

---Bind a provider to a property of the control (a provider is a function that takes no argument and returns a value)
---@param key string
---@param provider function()
function control:databind(key, provider)
    self.databindings[key] = provider
end

---INTERNAL USE - Forces an update of internal values
---@return nil
function control:tick()
    debugPrint(tostring(self) .. " - updating... ")
    local shouldRender = false
    --- Update databindings
    for key, provider in pairs(self.databindings) do
        local newValue = provider()
        if self[key] ~= newValue then
            self[key] = newValue
            shouldRender = true
        end
    end
    if shouldRender then
        self:render()
    end
end

---INTERNAL USE - Forces a rendering of the control
---@return nil
function control:render()
    debugPrint(tostring(self) .. " - rendering... ")
    if self.backgroundColor ~= nil then
        graphics.drawRectangle(self.x, self.y, self.w, self.h, self.backgroundColor)
    end
end

-- container class ------------------------------------------------------------------------------------------------------------------------------

---@class container : control
---@field children control[] Child controls of the container
local container = control:new()
container.children = {}


---@param obj container | nil
---@return container
function container:new(obj)
    obj = obj or {}
    local e = {}
    self.__index = self
    setmetatable(e, self)
    for k, v in pairs(self) do
        e[k] = obj[k] or v
    end
    return e
end

---INTERNAL USE - Forces a rendering of the control
---@return nil
function container:render()
    control.render(self)
end

-- app class ------------------------------------------------------------------------------------------------------------------------------

---@class app : container
---@field title string Title of the application. Set to "" if you do not want a title bar
---@field titleBarColor integer
local app = control:new()
app.title = "application"
app.backgroundColor = 0x202020
app.foregroundColor = 0xFFFFFF
app.titleBarColor = 0x101010
app.x = 1
app.y = 1
app.w = windowWidth
app.h = windowHeight

---Constructor for the app class
---@param obj app | nil
---@return app
function app:new(obj)
    obj = obj or {}
    local e = {}
    self.__index = self
    setmetatable(e, self)
    for k, v in pairs(self) do
        e[k] = obj[k] or v
    end
    return e
end

--- Start the application
---@return nil
function app:start()
    debugPrint(self.title .. " - starting application... ")
    self:render()
    while true do
        self:tick()


        --- Check for events
        local id, _, x, y = event.pullMultiple(1, "touch", "interrupted")
        if id == "interrupted" then
            --- interrupted
            graphics.clearScreen()
            break
        elseif id == "touch" then
            --- TODO event handling
            --print("user clicked", x, y)
        end
    end
end

function app:stop()
    -- TODO
end

---INTERNAL USE - Forces a rendering of the control
---@return nil
function app:render()
    container.render(self)
    if self.title ~= "" then
        graphics.drawRectangle(self.x, self.y, self.w, 1, self.titleBarColor)
        graphics.set(((self.x + self.w) / 2 - 1) - string.len(self.title) / 2, self.y, self.title, self.titleBarColor)
    end
end

-- label class ------------------------------------------------------------------------------------------------------------------------------


---@alias verticalAlignment
---| '"top"'
---| '"center"'
---| '"bottom"'

---@alias horizontalAlignment
---| '"left"'
---| '"center"'
---| '"right"'

---@class label : control
---@field text string The text displayed
---@field verticalAlignment verticalAlignment
local label = control:new()
label.text = ""
label.verticalAlignment = "center"
label.horizontalAlignment = "center"

---Constructor for the label class
---@param obj label | nil
---@return label
function label:new(obj)
    obj = obj or {}
    local e = {}
    self.__index = self
    setmetatable(e, self)
    for k, v in pairs(self) do
        e[k] = obj[k] or v
    end
    return e
end

-- button class ------------------------------------------------------------------------------------------------------------------------------

-- This is pretty much a label just different rendering behavior

---@class button : label
local button = label:new()


---Constructor for the label class
---@param obj button | nil
---@return button
function button:new(obj)
    obj = obj or {}
    local e = {}
    self.__index = self
    setmetatable(e, self)
    for k, v in pairs(self) do
        e[k] = obj[k] or v
    end
    return e
end

-- progressBar class ------------------------------------------------------------------------------------------------------------------------------

---@class progressBar : control
---@field value integer Value to be displayed
---@field minValue integer Minimum of value
---@field maxValue integer Maximum of value
local progressBar = control:new()
progressBar.value = 0
progressBar.minValue = 0
progressBar.maxValue = 100

---Constructor for the label class
---@param obj progressBar | nil
---@return progressBar
function progressBar:new(obj)
    obj = obj or {}
    local e = {}
    self.__index = self
    setmetatable(e, self)
    for k, v in pairs(self) do
        e[k] = obj[k] or v
    end
    return e
end

Api = {}
Api.app = app
Api.control = control
Api.container = container
Api.label = label
Api.button = button
Api.progressBar = progressBar

return Api
