--[[

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>

--]]

local ServerStorage = game:GetService("ServerStorage")
local ColorPicker = Instance.new("ModuleScript", ServerStorage)
ColorPicker.Name = "ColorPicker"
local ColorUtils = Instance.new("ModuleScript", ColorPicker)
ColorUtils.Name = "ColorUtils"
local CurrentColor = Instance.new("Color3Value", ColorPicker)
CurrentColor.Name = "CurrentColor"
local Examples = Instance.new("Folder", ColorPicker)
Examples.Name = "Examples"
local Prompt = Instance.new("Script", Examples)
Prompt.Name = "Prompt"
Prompt.Enabled = false

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

Prompt.Source =
[[

local ColorPicker = require(script.Parent.ColorPicker)
local CurrentColor = script.Parent.ColorPicker.CurrentColor

local ColorPicker = ColorPicker:Prompt(
	plugin,
	"ColorPicker",
	"Color Picker",
	Color3.fromRGB(255,70,100)
)

]]

-- Gui

local ColorPicker = Instance.new("Frame")
local Horizontal = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local ColorPickerArea = Instance.new("Frame")
local Picker = Instance.new("Frame")
local UICorner_2 = Instance.new("UICorner")
local Rainbow = Instance.new("UIGradient")
local Metadata = Instance.new("Frame")
local HTML = Instance.new("Frame")
local HTMLLabel = Instance.new("TextLabel")
local HTMLBox = Instance.new("TextBox")
local RGB = Instance.new("Frame")
local R = Instance.new("Frame")
local RedLabel = Instance.new("TextLabel")
local RedBox = Instance.new("TextBox")
local B = Instance.new("Frame")
local BlueLabel = Instance.new("TextLabel")
local BlueBox = Instance.new("TextBox")
local G = Instance.new("Frame")
local GreenLabel = Instance.new("TextLabel")
local GreenBox = Instance.new("TextBox")
local HSV = Instance.new("Frame")
local H = Instance.new("Frame")
local HueLabel = Instance.new("TextLabel")
local HueBox = Instance.new("TextBox")
local V = Instance.new("Frame")
local ValLabel = Instance.new("TextLabel")
local ValBox = Instance.new("TextBox")
local S = Instance.new("Frame")
local SatLabel = Instance.new("TextLabel")
local SatBox = Instance.new("TextBox")
local Vertical = Instance.new("Frame")
local ColorPickerArea_2 = Instance.new("Frame")
local Picker_2 = Instance.new("Frame")
local UICorner_3 = Instance.new("UICorner")
local UIGradent = Instance.new("UIGradient")
local UICorner_4 = Instance.new("UICorner")
local ColorShower = Instance.new("Frame")
local UICorner_5 = Instance.new("UICorner")

ColorPicker.Name = "ColorPicker"
ColorPicker.Parent = game.ServerStorage.ColorPicker
ColorPicker.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
ColorPicker.BorderSizePixel = 0
ColorPicker.Size = UDim2.new(0, 350, 0, 350)

Horizontal.Name = "Horizontal"
Horizontal.Parent = ColorPicker
Horizontal.AnchorPoint = Vector2.new(0.5, 0.5)
Horizontal.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
Horizontal.BackgroundTransparency = 1.000
Horizontal.BorderSizePixel = 0
Horizontal.Position = UDim2.new(0.44618395, 0, 0.50081104, 0)
Horizontal.Size = UDim2.new(0.892367899, 0, 0.996183217, 0)

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Horizontal

ColorPickerArea.Name = "ColorPickerArea"
ColorPickerArea.Parent = Horizontal
ColorPickerArea.Active = true
ColorPickerArea.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ColorPickerArea.BorderSizePixel = 0
ColorPickerArea.Position = UDim2.new(0.120603099, 0, 0.057338424, 0)
ColorPickerArea.Size = UDim2.new(0, 200, 0, 200)

Picker.Name = "Picker"
Picker.Parent = ColorPickerArea
Picker.BackgroundColor3 = Color3.fromRGB(27, 42, 53)
Picker.BackgroundTransparency = 1.000
Picker.BorderColor3 = Color3.fromRGB(27, 42, 53)
Picker.BorderSizePixel = 0
Picker.Size = UDim2.new(0.0170000009, 0, 1, 0)

UICorner_2.CornerRadius = UDim.new(1, 0)
UICorner_2.Parent = Picker

Rainbow.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.55, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.70, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.85, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))}
Rainbow.Name = "Rainbow"
Rainbow.Parent = ColorPickerArea

Metadata.Name = "Metadata"
Metadata.Parent = Horizontal
Metadata.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Metadata.BackgroundTransparency = 1.000
Metadata.BorderColor3 = Color3.fromRGB(0, 0, 0)
Metadata.BorderSizePixel = 0
Metadata.Position = UDim2.new(0.154865324, 0, 0.636047542, 0)
Metadata.Size = UDim2.new(0, 180, 0, 108)

HTML.Name = "HTML"
HTML.Parent = Metadata
HTML.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HTML.BackgroundTransparency = 1.000
HTML.BorderColor3 = Color3.fromRGB(0, 0, 0)
HTML.BorderSizePixel = 0
HTML.Position = UDim2.new(0.0333333351, 0, 0.811320782, 0)
HTML.Size = UDim2.new(0, 168, 0, 14)

HTMLLabel.Name = "HTMLLabel"
HTMLLabel.Parent = HTML
HTMLLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HTMLLabel.BackgroundTransparency = 1.000
HTMLLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
HTMLLabel.BorderSizePixel = 0
HTMLLabel.Size = UDim2.new(0.201999843, 0, 1, 0)
HTMLLabel.Font = Enum.Font.Unknown
HTMLLabel.Text = "HTML: "
HTMLLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HTMLLabel.TextScaled = true
HTMLLabel.TextSize = 14.000
HTMLLabel.TextWrapped = true
HTMLLabel.TextXAlignment = Enum.TextXAlignment.Left

HTMLBox.Name = "HTMLBox"
HTMLBox.Parent = HTML
HTMLBox.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
HTMLBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
HTMLBox.BorderSizePixel = 0
HTMLBox.Position = UDim2.new(0.202000007, 0, 0, 0)
HTMLBox.Selectable = false
HTMLBox.Size = UDim2.new(0.592000008, 0, 1, 0)
HTMLBox.ClearTextOnFocus = false
HTMLBox.Font = Enum.Font.SourceSans
HTMLBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
HTMLBox.ShowNativeInput = false
HTMLBox.Text = ""
HTMLBox.TextColor3 = Color3.fromRGB(255, 255, 255)
HTMLBox.TextScaled = true
HTMLBox.TextSize = 14.000
HTMLBox.TextWrapped = true
HTMLBox.TextXAlignment = Enum.TextXAlignment.Left

RGB.Name = "RGB"
RGB.Parent = Metadata
RGB.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RGB.BackgroundTransparency = 1.000
RGB.BorderColor3 = Color3.fromRGB(0, 0, 0)
RGB.BorderSizePixel = 0
RGB.Size = UDim2.new(0, 92, 0, 85)

R.Name = "R"
R.Parent = RGB
R.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
R.BackgroundTransparency = 1.000
R.BorderColor3 = Color3.fromRGB(0, 0, 0)
R.BorderSizePixel = 0
R.Position = UDim2.new(0, 0, 0.129411772, 0)
R.Size = UDim2.new(0, 89, 0, 14)

RedLabel.Name = "RedLabel"
RedLabel.Parent = R
RedLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RedLabel.BackgroundTransparency = 1.000
RedLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
RedLabel.BorderSizePixel = 0
RedLabel.Position = UDim2.new(0, 0, -0.0369742252, 0)
RedLabel.Size = UDim2.new(0.314076632, 0, 1, 0)
RedLabel.Font = Enum.Font.Unknown
RedLabel.Text = "Red:"
RedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RedLabel.TextScaled = true
RedLabel.TextSize = 14.000
RedLabel.TextWrapped = true
RedLabel.TextXAlignment = Enum.TextXAlignment.Left

RedBox.Name = "RedBox"
RedBox.Parent = R
RedBox.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
RedBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
RedBox.BorderSizePixel = 0
RedBox.Position = UDim2.new(0.314075947, 0, 0, 0)
RedBox.Selectable = false
RedBox.Size = UDim2.new(0.685923398, 0, 1, 0)
RedBox.ClearTextOnFocus = false
RedBox.Font = Enum.Font.SourceSans
RedBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
RedBox.ShowNativeInput = false
RedBox.Text = ""
RedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
RedBox.TextScaled = true
RedBox.TextSize = 14.000
RedBox.TextWrapped = true
RedBox.TextXAlignment = Enum.TextXAlignment.Left

B.Name = "B"
B.Parent = RGB
B.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
B.BackgroundTransparency = 1.000
B.BorderColor3 = Color3.fromRGB(0, 0, 0)
B.BorderSizePixel = 0
B.Position = UDim2.new(-0.0108695654, 0, 0.647058845, 0)
B.Size = UDim2.new(0, 89, 0, 14)

BlueLabel.Name = "BlueLabel"
BlueLabel.Parent = B
BlueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BlueLabel.BackgroundTransparency = 1.000
BlueLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
BlueLabel.BorderSizePixel = 0
BlueLabel.Position = UDim2.new(-0.0449431352, 0, -0.0369742252, 0)
BlueLabel.Size = UDim2.new(0.291604698, 0, 1, 0)
BlueLabel.Font = Enum.Font.Unknown
BlueLabel.Text = "Blue:"
BlueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
BlueLabel.TextScaled = true
BlueLabel.TextSize = 14.000
BlueLabel.TextWrapped = true
BlueLabel.TextXAlignment = Enum.TextXAlignment.Left

BlueBox.Name = "BlueBox"
BlueBox.Parent = B
BlueBox.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
BlueBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
BlueBox.BorderSizePixel = 0
BlueBox.Position = UDim2.new(0.325311899, 0, -0.0714285746, 0)
BlueBox.Selectable = false
BlueBox.Size = UDim2.new(0.685923398, 0, 1, 0)
BlueBox.ClearTextOnFocus = false
BlueBox.Font = Enum.Font.SourceSans
BlueBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
BlueBox.ShowNativeInput = false
BlueBox.Text = ""
BlueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
BlueBox.TextScaled = true
BlueBox.TextSize = 14.000
BlueBox.TextWrapped = true
BlueBox.TextXAlignment = Enum.TextXAlignment.Left

G.Name = "G"
G.Parent = RGB
G.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
G.BackgroundTransparency = 1.000
G.BorderColor3 = Color3.fromRGB(0, 0, 0)
G.BorderSizePixel = 0
G.Position = UDim2.new(0, 0, 0.388235301, 0)
G.Size = UDim2.new(0, 89, 0, 14)

GreenLabel.Name = "GreenLabel"
GreenLabel.Parent = G
GreenLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GreenLabel.BackgroundTransparency = 1.000
GreenLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
GreenLabel.BorderSizePixel = 0
GreenLabel.Position = UDim2.new(-0.112359554, 0, 0.0344543457, 0)
GreenLabel.Size = UDim2.new(0.392728299, 0, 1, 0)
GreenLabel.Font = Enum.Font.Unknown
GreenLabel.Text = "Green:"
GreenLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
GreenLabel.TextScaled = true
GreenLabel.TextSize = 14.000
GreenLabel.TextWrapped = true
GreenLabel.TextXAlignment = Enum.TextXAlignment.Left

GreenBox.Name = "GreenBox"
GreenBox.Parent = G
GreenBox.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
GreenBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
GreenBox.BorderSizePixel = 0
GreenBox.Position = UDim2.new(0.314075947, 0, 0, 0)
GreenBox.Selectable = false
GreenBox.Size = UDim2.new(0.685923398, 0, 1, 0)
GreenBox.ClearTextOnFocus = false
GreenBox.Font = Enum.Font.SourceSans
GreenBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
GreenBox.ShowNativeInput = false
GreenBox.Text = ""
GreenBox.TextColor3 = Color3.fromRGB(255, 255, 255)
GreenBox.TextScaled = true
GreenBox.TextSize = 14.000
GreenBox.TextWrapped = true
GreenBox.TextXAlignment = Enum.TextXAlignment.Left

HSV.Name = "HSV"
HSV.Parent = Metadata
HSV.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HSV.BackgroundTransparency = 1.000
HSV.BorderColor3 = Color3.fromRGB(0, 0, 0)
HSV.BorderSizePixel = 0
HSV.Position = UDim2.new(0.51111114, 0, 0, 0)
HSV.Size = UDim2.new(0, 88, 0, 85)

H.Name = "H"
H.Parent = HSV
H.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
H.BackgroundTransparency = 1.000
H.BorderColor3 = Color3.fromRGB(0, 0, 0)
H.BorderSizePixel = 0
H.Position = UDim2.new(0, 0, 0.129411772, 0)
H.Size = UDim2.new(0, 89, 0, 14)

HueLabel.Name = "HueLabel"
HueLabel.Parent = H
HueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HueLabel.BackgroundTransparency = 1.000
HueLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
HueLabel.BorderSizePixel = 0
HueLabel.Position = UDim2.new(0.0399999991, 0, -0.0370000005, 0)
HueLabel.Size = UDim2.new(0.246171936, 0, 1, 0)
HueLabel.Font = Enum.Font.Unknown
HueLabel.Text = "Hue:"
HueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HueLabel.TextScaled = true
HueLabel.TextSize = 14.000
HueLabel.TextWrapped = true
HueLabel.TextXAlignment = Enum.TextXAlignment.Left

HueBox.Name = "HueBox"
HueBox.Parent = H
HueBox.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
HueBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
HueBox.BorderSizePixel = 0
HueBox.Position = UDim2.new(0.314075947, 0, 0, 0)
HueBox.Selectable = false
HueBox.Size = UDim2.new(0.685923398, 0, 1, 0)
HueBox.ClearTextOnFocus = false
HueBox.Font = Enum.Font.SourceSans
HueBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
HueBox.ShowNativeInput = false
HueBox.Text = ""
HueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
HueBox.TextScaled = true
HueBox.TextSize = 14.000
HueBox.TextWrapped = true
HueBox.TextXAlignment = Enum.TextXAlignment.Left

V.Name = "V"
V.Parent = HSV
V.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
V.BackgroundTransparency = 1.000
V.BorderColor3 = Color3.fromRGB(0, 0, 0)
V.BorderSizePixel = 0
V.Position = UDim2.new(-0.0108695654, 0, 0.647058845, 0)
V.Size = UDim2.new(0, 89, 0, 14)

ValLabel.Name = "ValLabel"
ValLabel.Parent = V
ValLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ValLabel.BackgroundTransparency = 1.000
ValLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
ValLabel.BorderSizePixel = 0
ValLabel.Position = UDim2.new(0.0561804622, 0, -0.108402796, 0)
ValLabel.Size = UDim2.new(0.235424921, 0, 1, 0)
ValLabel.Font = Enum.Font.Unknown
ValLabel.Text = "Val:"
ValLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ValLabel.TextScaled = true
ValLabel.TextSize = 14.000
ValLabel.TextWrapped = true
ValLabel.TextXAlignment = Enum.TextXAlignment.Left

ValBox.Name = "ValBox"
ValBox.Parent = V
ValBox.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
ValBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
ValBox.BorderSizePixel = 0
ValBox.Position = UDim2.new(0.325311899, 0, -0.0714285746, 0)
ValBox.Selectable = false
ValBox.Size = UDim2.new(0.685923398, 0, 1, 0)
ValBox.ClearTextOnFocus = false
ValBox.Font = Enum.Font.SourceSans
ValBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
ValBox.ShowNativeInput = false
ValBox.Text = ""
ValBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ValBox.TextScaled = true
ValBox.TextSize = 14.000
ValBox.TextWrapped = true
ValBox.TextXAlignment = Enum.TextXAlignment.Left

S.Name = "S"
S.Parent = HSV
S.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
S.BackgroundTransparency = 1.000
S.BorderColor3 = Color3.fromRGB(0, 0, 0)
S.BorderSizePixel = 0
S.Position = UDim2.new(0, 0, 0.388235301, 0)
S.Size = UDim2.new(0, 89, 0, 14)

SatLabel.Name = "SatLabel"
SatLabel.Parent = S
SatLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SatLabel.BackgroundTransparency = 1.000
SatLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
SatLabel.BorderSizePixel = 0
SatLabel.Position = UDim2.new(0.0454327874, 0, -0.0369742252, 0)
SatLabel.Size = UDim2.new(0.234935969, 0, 1, 0)
SatLabel.Font = Enum.Font.Unknown
SatLabel.Text = "Sat:"
SatLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SatLabel.TextScaled = true
SatLabel.TextSize = 14.000
SatLabel.TextWrapped = true
SatLabel.TextXAlignment = Enum.TextXAlignment.Left

SatBox.Name = "SatBox"
SatBox.Parent = S
SatBox.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
SatBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
SatBox.BorderSizePixel = 0
SatBox.Position = UDim2.new(0.314075947, 0, 0, 0)
SatBox.Selectable = false
SatBox.Size = UDim2.new(0.685923398, 0, 1, 0)
SatBox.ClearTextOnFocus = false
SatBox.Font = Enum.Font.SourceSans
SatBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
SatBox.ShowNativeInput = false
SatBox.Text = ""
SatBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SatBox.TextScaled = true
SatBox.TextSize = 14.000
SatBox.TextWrapped = true
SatBox.TextXAlignment = Enum.TextXAlignment.Left

Vertical.Name = "Vertical"
Vertical.Parent = ColorPicker
Vertical.AnchorPoint = Vector2.new(0.5, 0.5)
Vertical.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
Vertical.BackgroundTransparency = 1.000
Vertical.BorderSizePixel = 0
Vertical.Position = UDim2.new(0.927431822, 0, 0.499000013, 0)
Vertical.Size = UDim2.new(0.107632093, 0, 0.918971777, 0)

ColorPickerArea_2.Name = "ColorPickerArea"
ColorPickerArea_2.Parent = Vertical
ColorPickerArea_2.Active = true
ColorPickerArea_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ColorPickerArea_2.BorderSizePixel = 0
ColorPickerArea_2.Position = UDim2.new(-0.770127594, 0, 0.0221168846, 0)
ColorPickerArea_2.Size = UDim2.new(0, 17, 0, 200)

Picker_2.Name = "Picker"
Picker_2.Parent = ColorPickerArea_2
Picker_2.BackgroundColor3 = Color3.fromRGB(27, 42, 53)
Picker_2.BorderColor3 = Color3.fromRGB(27, 42, 53)
Picker_2.BorderSizePixel = 0
Picker_2.Position = UDim2.new(0, 0, 0.5, 0)
Picker_2.Size = UDim2.new(1, 0, 0.0149999997, 0)

UICorner_3.CornerRadius = UDim.new(1, 0)
UICorner_3.Parent = Picker_2

UIGradent.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0))}
UIGradent.Rotation = 90
UIGradent.Name = "UIGradent"
UIGradent.Parent = ColorPickerArea_2

UICorner_4.CornerRadius = UDim.new(0, 10)
UICorner_4.Parent = Vertical

ColorShower.Name = "ColorShower"
ColorShower.Parent = Vertical
ColorShower.BackgroundColor3 = Color3.fromRGB(255, 0, 4)
ColorShower.BorderSizePixel = 0
ColorShower.Position = UDim2.new(-1.03803349, 0, 0.684939682, 0)
ColorShower.Size = UDim2.new(0, 36, 0, 36)

UICorner_5.CornerRadius = UDim.new(0, 10)
UICorner_5.Parent = ColorShower