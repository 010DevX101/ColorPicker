local ColorPicker = require(script.Parent.Parent)
local CurrentColor = script.Parent.Parent.CurrentColor

ColorPicker = ColorPicker:Prompt(
	plugin,
	"Color Picker",
	Color3.fromRGB(255,70,100)
)

ColorPicker:BindToClose(function()
	print(CurrentColor.Value)
end)