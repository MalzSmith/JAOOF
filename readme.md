# JAOOF - Just An Other OpenComputers Framework

I wanted to create a simple app using [OpenComputers](https://ocdoc.cil.li/). That's all I wanted to do. So here I am...

As I am a complete beginner with Lua, any advice is appreciated!

# Goals for this project

- [ ] Be able to make responsive GUI's with a few simple controls
- [ ] Include a main event loop to show the GUI
- [ ] Provide events that the users can subscribe to
- [x] Allow databinding by using providers
- [ ] Logging support?
- [ ] Add support for ComputerCraft?
- [x] Object oriented!
- [x] I'm not adding any canvas like functionality on purpose!
- [x] I should probably be writing code instead of this readme...


# Usage

Your main class is the `App`. You can create it like this:

```lua
gui = require("jaoof")

a = App:new()
a.title = "My test application"
a:start()

```

For more advanced usage check out the [demo](demo.lua).

# Controls

The library gives access to the following controls:
 - `App` - the main application control
 - `Container` - generic container control for storing other controls
 - `Label`
 - `Button`
 - `ProgressBar`

