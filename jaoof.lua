-- I've dumped everything in a single file because I'm lazy and I want to make installation of this thing as easy as possible
-- Also I'm spamming the main namespace. Sorry about that.

DEBUG = DEBUG or false

---@param text string
local function debugPrint(text)
    if DEBUG then
        print(text)
    end
end

-- Control class ------------------------------------------------------------------------------------------------------------------------------

---INTERNAL USE, USE THE DERIVED CLASSES INSTEAD - Base class for other controls
---@class Control
---@field isVisible boolean Whether the control is visible or not
---@field orientation boolean orientation of the control (true is vertical, false is horizontal)
---@field flowDirection boolean flow direction of the control (true is left->right or top->bottom, false is reversed)
---@field foregroundColor integer
---@field backgroundColor integer
---@field databindings table INTERNAL USE - data bindings of the control
Control = {}
Control.isVisible = true
Control.databindings = {}
Control.orientation = true
Control.flowDirection = true
Control.backgroundColor = 0x000000
Control.foregroundColor = 0xFFFFFF


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
    -- TODO
    -- Need to decide how I should split the screen across controls.
    -- Current idea is to just use the minimum required space for Labels and split the rest of the space evenly between competing controls...
    -- Maybe a more complex solution is better but for my personal use case this should be sufficient
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

-- App class ------------------------------------------------------------------------------------------------------------------------------

---@class App : Container
---@field title string
App = Control:new()
App.title = "Application"

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
    -- TODO event loop
end

function App:stop()
    -- TODO
end

-- Label class ------------------------------------------------------------------------------------------------------------------------------

---@class Label : Control
---@field text string The text displayed on the Label
Label = Control:new()
Label.text = ""

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

---@class Button : Control
---@field text string The text displayed on the Button
Button = Control:new()
Button.text = ""

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
