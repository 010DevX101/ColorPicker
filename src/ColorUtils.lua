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
