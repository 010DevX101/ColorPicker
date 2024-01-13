local ColorPicker = require(script.Parent.ColorPicker)
local CurrentColor = script.Parent.ColorPicker.CurrentColor

local ColorPicker = ColorPicker:Prompt(
	plugin, -- Plugin Instance
	"ColorPicker", -- Gui Id
	"Color Picker", -- Gui Title
    Color3.fromRGB(255,70,100) -- Initial Color
)