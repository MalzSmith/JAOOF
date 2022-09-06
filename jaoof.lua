-- I've dumped everything in a single file because I'm lazy and I want to make installation of this thing as easy as possible
-- Also I'm spamming the main namespace. Sorry about that.

TextMode = false

---@param text string
local function debugPrint(text)
    if TextMode then
        print(text)
    end
end

local gpu = require("component").gpu

Graphics = {}

if not gpu then
    debugPrint("RUNNING WITHOUT GPU ENABLED")
    TextMode = true
end

--- OpenComputers stuff ------------------------------------------------------------------------------------------------------------------------------

---Wrapper for gpu.setBackground
---@param value integer
---@return nil
function Graphics.setBackground(value)
    if not TextMode then
        gpu.setBackground(value)
    end
end

--- OpenComputers stuff

---Wrapper for gpu.setForeground
---@param value integer
---@return nil
function Graphics.setForeground(value)
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
function Graphics.drawRectangle(x, y, width, height, color)
    if not TextMode then
        local previousColor, _ = gpu.getBackground()
        gpu.setBackground(color)
        gpu.fill(x, y, width, height, " ")
        gpu.setBackground(previousColor)
    end
end

---Wrapper for gpu.getResolution
---@return number, number
function Graphics.resolution()
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
function Graphics.set(x, y, value, color)
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

--- Should probably write a wrapper for this too for compatibility?
Event = require("event")


-- Control class ------------------------------------------------------------------------------------------------------------------------------

---INTERNAL USE, USE THE DERIVED CLASSES INSTEAD - Base class for other controls
---@class Control
---@field isVisible boolean Whether the control is visible or not
---@field orientation boolean orientation of the control (true is vertical, false is horizontal)
---@field flowDirection boolean flow direction of the control (true is left->right or top->bottom, false is reversed)
---@field foregroundColor integer | nil
---@field backgroundColor integer | nil
---@field databindings table INTERNAL USE - data bindings of the control
Control = {}
Control.isVisible = true
Control.databindings = {}
Control.orientation = true
Control.flowDirection = true
Control.backgroundColor = nil
Control.foregroundColor = nil
--- Yeah, not sure why you are reading my code but I feel sorry for you.
--- Anyways, these variables are used internally
Control.x = 1
Control.y = 1
Control.h = 0
Control.w = 0


---Constructor for the Control class
---@param obj Control | nil
---@return Control
function Control:new(obj)
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
function Control:databind(key, provider)
    self.databindings[key] = provider
end

---INTERNAL USE - Forces an update of internal values
---@return nil
function Control:tick()
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
function Control:render()
    debugPrint(tostring(self) .. " - rendering... ")
    if self.backgroundColor ~= nil then
        Graphics.drawRectangle(self.x, self.y, self.w, self.h, self.backgroundColor)
    end
end

-- Container class ------------------------------------------------------------------------------------------------------------------------------

---@class Container : Control
---@field children Control[] Child controls of the container
Container = Control:new()
Container.children = {}


---@param obj Container | nil
---@return Container
function Container:new(obj)
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
function Container:render()
    Control.render(self)
end

-- App class ------------------------------------------------------------------------------------------------------------------------------

---@class App : Container
---@field title string Title of the application. Set to "" if you do not want a title bar
---@field titleBarColor integer
App = Control:new()
App.title = "Application"
App.backgroundColor = 0x202020
App.foregroundColor = 0xFFFFFF
App.titleBarColor = 0x1b00ff
App.x = 1
App.y = 1
local w, h = Graphics.resolution()
App.w = w
App.h = h

---Constructor for the App class
---@param obj App | nil
---@return App
function App:new(obj)
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
function App:start()
    debugPrint(self.title .. " - starting application... ")
    self:render()
    while true do
        self:tick()


        --- Check for events
        local id, _, x, y = Event.pullMultiple(1, "touch", "interrupted")
        if id == "interrupted" then
            --- interrupted
            break
        elseif id == "touch" then
            --- TODO event handling
            --print("user clicked", x, y)
        end
    end
end

function App:stop()
    -- TODO
end

---INTERNAL USE - Forces a rendering of the control
---@return nil
function App:render()
    Container.render(self)
    if self.title ~= "" then
        Graphics.drawRectangle(self.x, self.y, self.w, 1, self.titleBarColor)
        Graphics.set(((self.x + self.w) / 2 - 1) - self.title:len() / 2, self.y, self.title, self.titleBarColor)
    end
end

-- Label class ------------------------------------------------------------------------------------------------------------------------------


---@alias verticalAlignment
---| '"top"'
---| '"center"'
---| '"bottom"'

---@alias horizontalAlignment
---| '"left"'
---| '"center"'
---| '"right"'

---@class Label : Control
---@field text string The text displayed
---@field verticalAlignment verticalAlignment
Label = Control:new()
Label.text = ""
Label.verticalAlignment = "center"
Label.horizontalAlignment = "center"

---Constructor for the Label class
---@param obj Label | nil
---@return Label
function Label:new(obj)
    obj = obj or {}
    local e = {}
    self.__index = self
    setmetatable(e, self)
    for k, v in pairs(self) do
        e[k] = obj[k] or v
    end
    return e
end

-- Button class ------------------------------------------------------------------------------------------------------------------------------

-- This is pretty much a label just different rendering behavior

---@class Button : Label
Button = Label:new()


---Constructor for the Label class
---@param obj Button | nil
---@return Button
function Button:new(obj)
    obj = obj or {}
    local e = {}
    self.__index = self
    setmetatable(e, self)
    for k, v in pairs(self) do
        e[k] = obj[k] or v
    end
    return e
end

-- ProgressBar class ------------------------------------------------------------------------------------------------------------------------------

---@class ProgressBar : Control
---@field value integer Value to be displayed
---@field minValue integer Minimum of value
---@field maxValue integer Maximum of value
ProgressBar = Control:new()
ProgressBar.value = 0
ProgressBar.minValue = 0
ProgressBar.maxValue = 100

---Constructor for the Label class
---@param obj ProgressBar | nil
---@return ProgressBar
function ProgressBar:new(obj)
    obj = obj or {}
    local e = {}
    self.__index = self
    setmetatable(e, self)
    for k, v in pairs(self) do
        e[k] = obj[k] or v
    end
    return e
end
