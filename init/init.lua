local ServerStorage = game:GetService("ServerStorage")
local ColorPicker = Instance.new("ModuleScript", ServerStorage)
ColorPicker.Name = "ColorPicker"
ColorPicker.Source =
[[
local ColorPicker = {}

-- dispeller 2020, modified by Stonetr03, furtherly modified by LightningLion58, modified by 010DevX101 for plugin support and modularized.
-- Color picker example
-- Boolean Variables
local selecting = false

-- Gui Variables
local ColorPickerGui = script:WaitForChild("ColorPicker")
local Horizontal = ColorPickerGui:WaitForChild("Horizontal")
local Vertical = ColorPickerGui:WaitForChild("Vertical")
local ColorShower = Vertical:WaitForChild("ColorShower")

local Metadata = Horizontal:WaitForChild("Metadata")

-- HTML Metadata
local HTMLFrame = Metadata:WaitForChild("HTML")
local HTMLBox = HTMLFrame:WaitForChild("HTMLBox")

-- RGB Metadata
local RGBFrame = Metadata:WaitForChild("RGB")
local RedBox = RGBFrame:WaitForChild("R"):WaitForChild("RedBox")
local GreenBox = RGBFrame:WaitForChild("G"):WaitForChild("GreenBox")
local BlueBox = RGBFrame:WaitForChild("B"):WaitForChild("BlueBox")

-- HSV Metadata
local HSVFrame = Metadata:WaitForChild("HSV")
local HueBox = HSVFrame:WaitForChild("H"):WaitForChild("HueBox")
local SatBox = HSVFrame:WaitForChild("S"):WaitForChild("SatBox")
local ValBox = HSVFrame:WaitForChild("V"):WaitForChild("ValBox")
local PluginGuiService = game:GetService("PluginGuiService")

-- load the color utilities
local ColorUtils = require(script.ColorUtils)

local CurrentColor = script.CurrentColor

-- upon the user selecting
function ColorPicker:Prompt(plugin : Plugin, Id : string, Title : string, InitialColor : Color3)
	if InitialColor then
		CurrentColor.Value = InitialColor
	else
		CurrentColor.Value = ColorShower.BackgroundColor3
	end

	ColorPicker:SetColor(CurrentColor.Value, Vertical, "Y")

	local PluginGui = plugin:CreateDockWidgetPluginGui(
		Id,
		DockWidgetPluginGuiInfo.new(
			Enum.InitialDockState.Float,
			false,
			false,
			350,
			350,
			350,
			350
		),
		Title
	)

	PluginGui.Title = Title
	PluginGui.Name = Id
	ColorPickerGui.Parent = PluginGui
	PluginGui.Enabled = true

	ColorPicker:GetMouseInput(PluginGui, Horizontal, Horizontal.ColorPickerArea, "X", Vertical, "Y")
	ColorPicker:GetMouseInput(PluginGui, Vertical, Vertical.ColorPickerArea, "Y")

	return PluginGui
end

function ColorPicker:SetColor(Color : Color3, frameToUpdate : Frame, Axis : string)
	CurrentColor.Value = Color
	ColorShower.BackgroundColor3 = Color
	HTMLBox.Text = ColorUtils.RGBToHex({Color.R*255, Color.G*255, Color.B*255})
	RedBox.Text = math.floor(Color.R*255)
	GreenBox.Text = math.floor(Color.G*255)
	BlueBox.Text = math.floor(Color.B*255)
	HueBox.Text = ColorUtils.RGBToHSV(Color)[1]
	SatBox.Text = ColorUtils.RGBToHSV(Color)[2]
	ValBox.Text = ColorUtils.RGBToHSV(Color)[3]

	if(frameToUpdate) then --If the current color change is supposed to influence a different frame:
		local Area = frameToUpdate:WaitForChild("ColorPickerArea")
		local Grad : UIGradient = Area:FindFirstChildOfClass('UIGradient')
		local colors = Grad.Color.Keypoints
		colors[2] = ColorSequenceKeypoint.new(colors[2].Time,ColorShower.BackgroundColor3)
		Grad.Color = ColorSequence.new(colors) --Change the color pallete of the second frame

		local color = ColorUtils:GetColor(Area:WaitForChild("Picker").Position[Axis].Scale,colors)
		if(frameToUpdate:FindFirstChild("ColorShower")) then
			frameToUpdate:WaitForChild("ColorShower").BackgroundColor3 = color --Update the color shower if its in the other frame
		else
			ColorShower.BackgroundColor3 = color --Update the color shower of this frame
		end
	end
end

function ColorPicker:BeginSelection(MainFrame : frame, axis, frameToUpdate : Frame?, otherAxis : string, pluginWidget : DockWidgetPluginGui)
	local ColorShower = MainFrame:FindFirstChild("ColorShower") or frameToUpdate.ColorShower
	local PickerArea = MainFrame.ColorPickerArea
	local Picker = PickerArea.Picker
	local Gradient = PickerArea:FindFirstChildOfClass('UIGradient')

	selecting = true
	local ColorKeyPoints = Gradient.Color.Keypoints

	repeat task.wait()
		-- left cord of ColorPickerArea in pixels
		local minPos = PickerArea.AbsolutePosition[axis]

		-- right cord of ColorPickerArea in pixels
		local maxPos = minPos+PickerArea.AbsoluteSize[axis]

		-- width of ColorPickerArea in pixels
		local PixelSize = PickerArea.AbsoluteSize[axis]

		-- raw Mouse X/Y pixel position
		local mouse = pluginWidget:GetRelativeMousePosition()[axis]

		-- constraints
		if mouse<minPos then
			mouse = minPos
		elseif mouse > maxPos then
			mouse = maxPos
		end

		-- get percentage mouse is on
		local Pos = (mouse-minPos)/PixelSize

		-- move the visual Picker line
		if(axis == "X") then
			Picker.Position = UDim2.new(Pos,0,0,0)
		elseif(axis == "Y") then
			Picker.Position = UDim2.new(0,0,Pos,0)
		else
			warn("No such axis!")
		end

		-- set the ColorShower frame color
		ColorPicker:SetColor(ColorUtils:GetColor(Pos, ColorKeyPoints), frameToUpdate, otherAxis)
	until not selecting
end

-- check input for selection beginning

--Parameters for the following function:
-- frame - the color picker frame
-- axis - axis of color picking (axis of color picker)
-- frameToUpdate? - use if the change of 'frame' is supposed to influence a different gradient
-- otherAxis? - axis of 'frameToUpdate'

function ColorPicker:GetMouseInput(pluginGui : DockWidgetPluginGui, frame : Frame, colorPickerArea, axis : "Y" | "X" , frameToUpdate : Frame | nil, otherAxis : "Y"? | "X"?)
	colorPickerArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			ColorPicker:BeginSelection(frame, axis, frameToUpdate, otherAxis, pluginGui)
		end
	end)

	colorPickerArea.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			selecting = false
		end
	end)
end

return ColorPicker
]]

local CurrentColor = Instance.new("Color3Value", ColorPicker)
CurrentColor.Name = "CurrentColor"

local ColorUtils = Instance.new("ModuleScript", ColorPicker)
ColorUtils.Name = "ColorUtils"
ColorUtils.Source =

[[
local ColorUtils = {}

function ColorUtils.RGBToHex(rgb)
	return string.format("#%02x%02x%02x", rgb[1], rgb[2], rgb[3])
end

function ColorUtils.HexToRGB(hex)
	hex = hex:gsub("#", "")
	return {
		tonumber(hex:sub(1, 2), 16),
		tonumber(hex:sub(3, 4), 16),
		tonumber(hex:sub(5, 6), 16)
	}
end

function ColorUtils.RGBToHSV(rgb)
	local max = math.max(rgb.R, rgb.G, rgb.B)
	local min = math.min(rgb.R, rgb.G, rgb.B)

	local H
	local S 
	local V

	if max ~= min then
		if max == rgb.R then
			H = 60 * (rgb.G - rgb.B) / (max - min) % 360
		elseif max == rgb.G then
			H = 60 * ((rgb.B - rgb.R) / (max - min) + 2) % 360
		elseif max == rgb.B then
			H = 60 * ((rgb.R - rgb.G) / (max - min) + 4) % 360
		end
	else
		H = 0
	end

	if max == 0 then
		S = max
	else
		S = (max-min)/max
	end

	V = max

	return table.pack(math.floor(H), tonumber(string.format("%.2f", S)),tonumber(string.format("%.2f", V)))
end

function ColorUtils:GetColor(percentage, ColorKeyPoints)
	-- dispeller 2020
	-- Open Sourced Get On Gradient Slider module/function
	
	if (percentage < 0) or (percentage>1) then
		--error'getColor percentage out of bounds!'
		warn("GetColor got out of bounds percentage (less than 0 or greater than 1")
	end

	local closestToLeft = ColorKeyPoints[1]
	local closestToRight = ColorKeyPoints[#ColorKeyPoints]
	local LocalPercentage = .5
	local color = closestToLeft.Value

	-- This loop can probably be improved by doing something like a Binary search instead
	-- This should work fine though
	for i=1,#ColorKeyPoints-1 do
		if (ColorKeyPoints[i].Time <= percentage) and (ColorKeyPoints[i+1].Time >= percentage) then
			closestToLeft = ColorKeyPoints[i]
			closestToRight = ColorKeyPoints[i+1]
			LocalPercentage = (percentage-closestToLeft.Time)/(closestToRight.Time-closestToLeft.Time)
			color = closestToLeft.Value:lerp(closestToRight.Value,LocalPercentage)
			return color
		end
	end
	warn("Color not found!")
	return color
end

return ColorUtils
]]