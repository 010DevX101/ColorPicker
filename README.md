# ColorPicker
A color picker library that can be included in plugins. Based off of Easy 1D Color Picker: https://devforum.roblox.com/t/easy-1d-color-picker/637772/40

![image](https://github.com/010DevX101/ColorPicker/assets/63361968/a7f5fb39-071f-4c70-8344-a6fd4cb9b3bf)

# Installation
## From Source
To install the color picker library from source into your project run the `installation.lua` script that can be found in the Installation folder in the command bar.

## From Roblox
To install the color picker library from Roblox into your project, use the following link: https://create.roblox.com/marketplace/asset/15969604603

# How To Use
The color picker can be easily included into any plugin using the `ColorPicker:Prompt()` method, find a sample below:
```lua
local ColorPicker = require(script.Parent.ColorPicker)

ColorPicker = ColorPicker:Prompt(
    plugin, -- Plugin Instance
    "ColorPicker", -- Gui Id
    "Color Picker", -- Gui Title
    Color3.fromRGB(255,70,100) -- Initial Color
)
```

This method also returns the PluginGui which is a `DockWidgetPluginGui` meaning that it can be binded to a BindToClose event and use the color.
```lua
local ColorPicker = require(script.Parent.ColorPicker)
local CurrentColor = script.Parent.ColorPicker.CurrentColor

ColorPicker = ColorPicker:Prompt(
    plugin, -- Plugin Instance
    "ColorPicker", -- Gui Id
    "Color Picker", -- Gui Title
    Color3.fromRGB(255,70,100) -- Initial Color
)

ColorPicker:BindToClose(function()
    print(CurrentColor.Value)
end)
```

Special credits to ToldFable (previously disspeller), Stonetr03 and LightningLion58 for the original color pickers.
