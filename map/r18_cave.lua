-- Giang Ho Sinh Ton - R18 hillside cave dressing
-- Run in Roblox Studio Edit mode via loadstring (plain Luau). Idempotent.

local ChangeHistoryService = game:GetService("ChangeHistoryService")

local village = workspace:FindFirstChild("Village")
if not village then
	return "Cave18 build FAILED: workspace.Village not found"
end

pcall(function()
	ChangeHistoryService:SetWaypoint("Cave18 - before rebuild")
end)

local existing = village:FindFirstChild("Cave18")
if existing then
	existing:Destroy()
end

local model = Instance.new("Model")
model.Name = "Cave18"
model.Parent = village

local partsCreated = 0
local skipped = {}
local stoneTotal = 9

local function build()
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Include
	rayParams.FilterDescendantsInstances = { workspace.Terrain }

	local function groundHit(x, z, fromY, dist)
		return workspace:Raycast(Vector3.new(x, fromY, z), Vector3.new(0, -dist, 0), rayParams)
	end

	local function addPart(shape, name, size, cframe, color, material, canCollide)
		local part = Instance.new("Part")
		part.Shape = shape
		part.Name = name
		part.Size = size
		part.CFrame = cframe
		part.Color = color
		part.Material = material
		part.Anchored = true
		part.CanCollide = canCollide ~= false
		part.CastShadow = true
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Parent = model
		partsCreated = partsCreated + 1
		return part
	end

	local function cylUp(name, height, dia, pos, color, material)
		return addPart(Enum.PartType.Cylinder, name, Vector3.new(height, dia, dia),
			CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90)), color, material)
	end

	local function addInscription(part, text, textSize)
		local gui = Instance.new("SurfaceGui")
		gui.Name = "Inscription"
		gui.Face = Enum.NormalId.Front -- part Front = -Z, toward the north approach
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 50
		gui.LightInfluence = 1
		local label = Instance.new("TextLabel")
		label.Name = "Text"
		label.BackgroundTransparency = 1
		label.BorderSizePixel = 0
		label.Size = UDim2.fromScale(1, 1)
		label.Font = Enum.Font.Antique
		label.TextColor3 = Color3.fromRGB(150, 52, 40)
		label.TextTransparency = 0.15
		label.TextWrapped = true
		label.TextSize = textSize
		label.Text = text
		label.Parent = gui
		gui.Parent = part
	end

	local SLATE = Enum.Material.Slate
	local STONE = Color3.fromRGB(126, 123, 117)
	local CLAY = Color3.fromRGB(120, 85, 60)

	-- 1) Stele: viewer faces +Z toward the mouth, so viewer's left is +X
	local steleHit = groundHit(-88.5, 221, 25.5, 40)
	local steleBase = steleHit and steleHit.Position.Y or 21
	local stele = addPart(Enum.PartType.Block, "Stele", Vector3.new(2.6, 6.5, 0.7),
		CFrame.new(-88.5, steleBase + 2.85, 221), STONE, SLATE)
	addInscription(stele, "問\n道", 90)

	-- Carved lintel across the mouth, bottom at y 27.7 (head clearance above floor ~22)
	local lintel = addPart(Enum.PartType.Block, "Lintel", Vector3.new(8, 1.4, 0.9),
		CFrame.new(-94, 28.4, 223.5), STONE, SLATE)
	addInscription(lintel, "洞天", 60)

	-- 2) Cave interior; floor via downward raycast against Terrain only
	local function caveFloor(x, z)
		local hit = groundHit(x, z, 24.6, 20)
		if hit then
			return hit.Position.Y
		end
		return 22
	end

	local y0 = caveFloor(-92, 227.5)
	cylUp("StrawCushion", 0.5, 2.2, Vector3.new(-92, y0 + 0.25, 227.5),
		Color3.fromRGB(150, 120, 70), Enum.Material.Fabric)

	-- Stone bed runs along Z, pushed against the west (-X) side wall if found
	local bedZ = 231
	local bedX = -97
	local wallHit = workspace:Raycast(Vector3.new(-94, caveFloor(-94, bedZ) + 1, bedZ),
		Vector3.new(-12, 0, 0), rayParams)
	if wallHit then
		bedX = wallHit.Position.X + 1.6
	end
	y0 = caveFloor(bedX, bedZ)
	addPart(Enum.PartType.Block, "StoneBed", Vector3.new(6, 1.5, 3),
		CFrame.new(bedX, y0 + 0.75, bedZ) * CFrame.Angles(0, math.rad(90), 0), STONE, SLATE)

	y0 = caveFloor(-91.5, 225.8)
	cylUp("LampDish", 0.3, 1.3, Vector3.new(-91.5, y0 + 0.15, 225.8), CLAY, Enum.Material.Sand)
	local flame = addPart(Enum.PartType.Ball, "LampFlame", Vector3.new(0.45, 0.45, 0.45),
		CFrame.new(-91.5, y0 + 0.5, 225.8), Color3.fromRGB(255, 170, 80), Enum.Material.Neon, false)
	flame.CastShadow = false
	local lampLight = Instance.new("PointLight")
	lampLight.Range = 14
	lampLight.Brightness = 1.2
	lampLight.Color = Color3.fromRGB(255, 170, 110)
	lampLight.Shadows = true
	lampLight.Parent = flame

	y0 = caveFloor(-92.8, 234)
	local burner = addPart(Enum.PartType.Ball, "IncenseBurner", Vector3.new(1.1, 1.1, 1.1),
		CFrame.new(-92.8, y0 + 0.45, 234), Color3.fromRGB(110, 80, 45), Enum.Material.Metal)
	local smoke = Instance.new("ParticleEmitter")
	smoke.Name = "IncenseSmoke"
	smoke.Rate = 3
	smoke.Color = ColorSequence.new(Color3.fromRGB(128, 128, 128))
	smoke.Transparency = NumberSequence.new(0.6)
	smoke.Lifetime = NumberRange.new(3)
	smoke.Size = NumberSequence.new(0.3, 1.2)
	smoke.Speed = NumberRange.new(0.6, 1)
	smoke.EmissionDirection = Enum.NormalId.Top
	smoke.Parent = burner

	y0 = caveFloor(-91.5, 229.5)
	addPart(Enum.PartType.Cylinder, "Scroll", Vector3.new(2.4, 0.7, 0.7),
		CFrame.new(-91.5, y0 + 0.35, 229.5), Color3.fromRGB(220, 205, 170), Enum.Material.Fabric)

	y0 = caveFloor(-90.8, 232)
	addPart(Enum.PartType.Ball, "JarBody", Vector3.new(1.5, 1.5, 1.5),
		CFrame.new(-90.8, y0 + 0.75, 232), CLAY, Enum.Material.Sand)
	cylUp("JarNeck", 0.8, 0.6, Vector3.new(-90.8, y0 + 1.15, 232), CLAY, Enum.Material.Sand)

	-- 3) Stepping stones (seed 1818), path (-62, ground, 207) -> (-94, ledge, 214)
	local rng = Random.new(1818)
	for i = 1, stoneTotal do
		local t = (i - 1) / (stoneTotal - 1)
		local x = -62 - 32 * t
		local z = 207 + 7 * t
		local shade = rng:NextInteger(-10, 10)
		local sx = rng:NextNumber(1.6, 2.4)
		local sz = rng:NextNumber(1.3, 1.9)
		local rotY = rng:NextNumber(-25, 25)
		local hit = groundHit(x, z, 60, 300)
		if not hit then
			table.insert(skipped, "#" .. i .. " no hit")
		elseif hit.Material == Enum.Material.Water then
			table.insert(skipped, "#" .. i .. " water")
		elseif hit.Normal.Y < 0.55 then
			table.insert(skipped, string.format("#%d slope %.2f", i, hit.Normal.Y))
		else
			-- top = hit + 0.08, thickness 0.4 => center = hit + 0.08 - 0.2
			addPart(Enum.PartType.Block, "SteppingStone" .. i,
				Vector3.new(sx, 0.4, sz),
				CFrame.new(x, hit.Position.Y - 0.12, z) * CFrame.Angles(0, math.rad(rotY), 0),
				Color3.fromRGB(132 + shade, 130 + shade, 120 + shade), SLATE)
		end
	end
end

local ok, err = pcall(build)
if not ok then
	model:Destroy()
	pcall(function()
		ChangeHistoryService:SetWaypoint("Cave18 - build failed, cleaned up")
	end)
	return "Cave18 build FAILED, model removed: " .. tostring(err)
end

pcall(function()
	ChangeHistoryService:SetWaypoint("Cave18 - rebuilt")
end)

local skippedText = #skipped > 0 and table.concat(skipped, ", ") or "none"
return string.format("Cave18 rebuilt: %d parts created; stones skipped %d/%d (%s)",
	partsCreated, #skipped, stoneTotal, skippedText)
