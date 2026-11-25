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
local stonesPlaced = 0
local MAX_STONES = 17
local stoneYs = {}
local problems = {}

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

	-- Vertical carved-text layout: one TextScaled block with 10% padding so
	-- every character fits (QA: 道 was clipped at fixed TextSize).
	local function addInscription(part, text)
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
		label.Text = text
		label.TextScaled = true
		label.LineHeight = 1
		label.TextColor3 = Color3.fromRGB(128, 48, 38)
		label.TextTransparency = 0.3
		label.TextStrokeColor3 = Color3.fromRGB(60, 25, 20)
		label.TextStrokeTransparency = 0.85
		label.Parent = gui
		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0.1, 0)
		pad.PaddingBottom = UDim.new(0.1, 0)
		pad.PaddingLeft = UDim.new(0.1, 0)
		pad.PaddingRight = UDim.new(0.1, 0)
		pad.Parent = label
		gui.Parent = part
	end

	local SLATE = Enum.Material.Slate
	local GRASS = Enum.Material.Grass
	local STONE = Color3.fromRGB(126, 123, 117)
	local STELE = Color3.fromRGB(112, 110, 104)
	local MOSS = Color3.fromRGB(86, 98, 66)
	local CLAY = Color3.fromRGB(120, 85, 60)

	-- 1) Weathered stele left of the mouth (viewer faces +Z, so left is +X):
	-- tilted 2.5 deg on Z, base sunk 0.4 into the ground, thin cap slab, moss.
	local steleHit = groundHit(-88.5, 221, 25.5, 40)
	local steleBase = steleHit and steleHit.Position.Y or 21
	local steleCF = CFrame.new(-88.5, steleBase + 2.85, 221) * CFrame.Angles(0, 0, math.rad(2.5))
	local stele = addPart(Enum.PartType.Block, "Stele", Vector3.new(2.6, 6.5, 0.7),
		steleCF, STELE, SLATE)
	addInscription(stele, "問\n道")
	addPart(Enum.PartType.Block, "SteleCap", Vector3.new(2.9, 0.3, 1.0),
		steleCF * CFrame.new(0, 3.4, 0), STELE, SLATE)
	addPart(Enum.PartType.Block, "SteleMossTop", Vector3.new(1.3, 0.15, 0.9),
		steleCF * CFrame.new(0.7, 3.625, 0.05), MOSS, GRASS)
	addPart(Enum.PartType.Block, "SteleMossBase", Vector3.new(1.5, 0.7, 0.15),
		steleCF * CFrame.new(0.4, -2.5, -0.425), MOSS, GRASS)

	-- Carved lintel across the mouth: raycast +Z from in front to find the rock
	-- face, embed the back half 0.4 into it, ends resting on two stone posts.
	local lintelY = 28.4
	local faceZ = 224 -- measured front of the rock band; overridden by the ray below
	local faceRay = workspace:Raycast(Vector3.new(-94, lintelY, 204), Vector3.new(0, 0, 30), rayParams)
	if faceRay and faceRay.Position.Z >= 222 and faceRay.Position.Z < 234 then
		faceZ = faceRay.Position.Z
	end
	local lintel = addPart(Enum.PartType.Block, "Lintel", Vector3.new(8, 1.4, 0.9),
		CFrame.new(-94, lintelY, faceZ + 0.4), STONE, SLATE)
	addInscription(lintel, "洞天")

	local lintelBottom = lintelY - 0.7
	for _, px in ipairs({ -97.5, -90.5 }) do
		local postHit = groundHit(px, faceZ + 0.2, lintelY - 0.5, 20)
		local floorY = postHit and postHit.Position.Y or 21
		local h = lintelBottom - floorY + 0.2 -- 0.2 seats the post under the lintel
		if h > 0.5 then
			addPart(Enum.PartType.Block, "LintelPost", Vector3.new(1, h, 1),
				CFrame.new(px, floorY + h / 2, faceZ + 0.2), STONE, SLATE)
		end
	end

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

	-- 3) Stepping stones: greedy scan along the path (-62,207) -> (-94,214).
	-- Terrain is probed every 0.75 studs; a stone is dropped whenever the climb
	-- since the last stone exceeds STEP_RISE (so the real rise never exceeds
	-- MAX_RISE = 1.6), with zigzag +-0.6 and the long axis facing uphill. A
	-- stretch the stones cannot climb (real terrain rise > 1.6 even for the
	-- next stone) gets a carved stone stair: lateral offsets {0, +-3, +-6}
	-- perpendicular to the path are scanned, the one with the smallest total
	-- terrain climb is chosen, and treads of rise <= 1.3 are embedded there,
	-- each extending down to the terrain, the last one flush with the upper
	-- ledge. Stones then continue across the ledge to the cave mouth (PATH_C).
	local PATH_A = Vector3.new(-62, 0, 207)
	local PATH_B = Vector3.new(-94, 0, 214)
	local PATH_C = Vector3.new(-94, 0, 221) -- cave mouth on the upper ledge
	local ledgeVec = PATH_C - PATH_B
	local ledgeLen = math.sqrt(ledgeVec.X * ledgeVec.X + ledgeVec.Z * ledgeVec.Z)
	local ledgeDir = Vector3.new(ledgeVec.X / ledgeLen, 0, ledgeVec.Z / ledgeLen)
	local pathVec = PATH_B - PATH_A
	local pathLen = math.sqrt(pathVec.X * pathVec.X + pathVec.Z * pathVec.Z)
	local dirU = Vector3.new(pathVec.X / pathLen, 0, pathVec.Z / pathLen)
	local perpU = Vector3.new(-dirU.Z, 0, dirU.X)
	local uphillYaw = math.atan2(dirU.X, dirU.Z)
	local PROBE = 0.75 -- terrain probe spacing (stones can be this close together)
	local MAX_RISE = 1.6 -- hard cap on the climb between consecutive stones
	local STEP_RISE = 1.0 -- place a stone once the climb since the last exceeds this
	local MAX_PARTS = 35 -- hard cap on total Cave18 BaseParts
	local STAIR_RISE = 1.3 -- max rise between consecutive stair treads
	local TREAD_W, TREAD_D = 2.6, 1.5 -- stair tread: width across, depth along
	local MAX_GAP = 6 -- never leave more than ~6 studs of path without a stone

	local rng = Random.new(1818)

	local lastY = nil
	local lastS = nil -- path distance of the last placed stone
	local function placeStone(x, z, maxY)
		if stonesPlaced >= MAX_STONES then
			return nil, "stone budget exhausted"
		elseif partsCreated >= MAX_PARTS then
			return nil, "part budget exhausted"
		end
		local hit = groundHit(x, z, 60, 300)
		if not hit then
			return nil, "no terrain hit"
		elseif hit.Material == Enum.Material.Water then
			return nil, "water"
		elseif hit.Normal.Y < 0.55 then
			return nil, string.format("slope normal.Y %.2f", hit.Normal.Y)
		elseif maxY and hit.Position.Y > maxY + 0.05 then
			return nil, string.format("climb %.1f > %.1f", hit.Position.Y - lastY, MAX_RISE)
		end
		stonesPlaced = stonesPlaced + 1
		local along = rng:NextNumber(1.8, 2.2)
		local cross = rng:NextNumber(1.4, 1.7)
		local shade = rng:NextInteger(-10, 10)
		local yaw = uphillYaw + math.rad(rng:NextNumber(-10, 10))
		addPart(Enum.PartType.Block, "SteppingStone" .. stonesPlaced,
			Vector3.new(cross, 0.4, along),
			CFrame.new(x, hit.Position.Y - 0.12, z) * CFrame.Angles(0, yaw, 0),
			Color3.fromRGB(132 + shade, 130 + shade, 120 + shade), SLATE)
		table.insert(stoneYs, string.format("%.1f", hit.Position.Y))
		return hit.Position.Y
	end

	local nProbes = math.ceil(pathLen / PROBE)
	local budgetOut = false
	for k = 0, nProbes do
		if budgetOut then
			break
		end
		local s = math.min(k * PROBE, pathLen)
		local zig = (k % 2 == 0) and 0.6 or -0.6
		local p = PATH_A + dirU * s + perpU * zig
		local hit = groundHit(p.X, p.Z, 60, 300)
		local y = hit and hit.Position.Y or nil
		local groundOk = y ~= nil and hit.Material ~= Enum.Material.Water and hit.Normal.Y >= 0.55
		if lastY == nil then
			if groundOk then
				local sy, why = placeStone(p.X, p.Z, nil)
				if sy then
					lastY, lastS = sy, s
				elseif why == "stone budget exhausted" then
					budgetOut = true
				end
			end
		elseif not groundOk then
			-- unsafe ground: only a problem if a stone was due here
			if (s - lastS) > MAX_GAP then
				table.insert(problems, string.format("s%.1f no safe ground for a due stone", s))
			end
		else
			local climb = y - lastY
			if climb > MAX_RISE then
				-- Climb since the last stone would exceed 1.6: first try to fit
				-- another stone in between by sub-probing the interval finely
				-- (this is the "extra stones in the steep part" case).
				local placed = false
				local nFine = math.max(2, math.ceil((s - lastS) / 0.25))
				for j = 1, nFine - 1 do
					local fs = lastS + (s - lastS) * j / nFine
					local fz = (j % 2 == 0) and 0.6 or -0.6
					local fp = PATH_A + dirU * fs + perpU * fz
					local fh = groundHit(fp.X, fp.Z, 60, 300)
					if fh and fh.Material ~= Enum.Material.Water and fh.Normal.Y >= 0.55 then
						local fc = fh.Position.Y - lastY
						if fc > STEP_RISE and fc <= MAX_RISE then
							local sy, why = placeStone(fp.X, fp.Z, lastY + MAX_RISE)
							if sy then
								lastY, lastS = sy, fs
								placed = true
							elseif why == "stone budget exhausted" then
								budgetOut = true
							end
							break
						end
					end
				end
				if not placed and not budgetOut then
					-- Genuinely unclimbable wall: carve a stone stair. Scan the
					-- lateral offsets {0, +-3, +-6} perpendicular to the path
					-- and pick the one whose terrain has the smallest total
					-- climb across the remaining path.
					local bestOff, bestRise = nil, nil
					for _, off in ipairs({ 0, 3, -3, 6, -6 }) do
						local prevTy, total, ok = nil, 0, true
						for m = 0, math.ceil((pathLen - lastS) / 0.75) do
							local ss = lastS + m * 0.75
							local pp = PATH_A + dirU * ss + perpU * off
							local hh = groundHit(pp.X, pp.Z, 60, 300)
							if not hh or hh.Material == Enum.Material.Water then
								ok = false
								break
							end
							if prevTy and hh.Position.Y > prevTy then
								total = total + (hh.Position.Y - prevTy)
							end
							prevTy = hh.Position.Y
						end
						if ok and (bestRise == nil or total < bestRise) then
							bestRise, bestOff = total, off
						end
					end
					if bestOff == nil then
						budgetOut = true
						table.insert(problems, string.format(
							"path beyond s%.1f: no walkable lateral line for a stair", lastS))
						break
					end
					local endP = PATH_A + dirU * pathLen + perpU * bestOff
					local endHit = groundHit(endP.X, endP.Z, 60, 300)
					if not endHit then
						budgetOut = true
						table.insert(problems, "path end: no terrain for the stair to land on")
						break
					end
					local targetY = endHit.Position.Y
					local prevTop = lastY
					local sCur = lastS
					local tread = 0
					while partsCreated < MAX_PARTS do
						sCur = sCur + TREAD_D
						if sCur - pathLen > 6 then
							-- not enough run to reach the ledge at <=1.3 per tread
							table.insert(problems, string.format(
								"stair from s%.1f: ran out of run %.1f short of the ledge",
								lastS, targetY - prevTop))
							break
						end
						local top = math.min(prevTop + STAIR_RISE, targetY)
						local sp
						if sCur <= pathLen then
							sp = PATH_A + dirU * sCur + perpU * bestOff
						else
							-- the stair tops out past the path end: keep climbing
							-- toward the cave mouth along the ledge, tapering the
							-- lateral offset back to the ledge centreline
							local e = sCur - pathLen
							sp = PATH_B + ledgeDir * e + perpU * (bestOff * math.max(0, 1 - e / 3))
						end
						local hh = groundHit(sp.X, sp.Z, 60, 300)
						if not hh then
							table.insert(problems, "stair tread: no terrain hit")
							break
						end
						-- each tread extends DOWN to the terrain so nothing floats
						-- (clamped to a 0.5 slab where the rock face buries it)
						local height = math.max(0.5, top - hh.Position.Y + 0.5)
						tread = tread + 1
						local shade = rng:NextInteger(-8, 8)
						local yaw = uphillYaw + math.rad(rng:NextNumber(-3, 3))
						addPart(Enum.PartType.Block, "CaveStair" .. tread,
							Vector3.new(TREAD_W, height, TREAD_D),
							CFrame.new(sp.X, top - height / 2, sp.Z) * CFrame.Angles(0, yaw, 0),
							Color3.fromRGB(132 + shade, 130 + shade, 120 + shade), SLATE)
						table.insert(stoneYs, string.format("%.1f", top))
						prevTop = top
						lastY, lastS = top, sCur
						if top >= targetY - 0.01 then
							break -- last tread flush with the ledge surface
						end
					end
					if partsCreated >= MAX_PARTS then
						budgetOut = true
						table.insert(problems, "stair stopped: part budget exhausted")
						break
					end
				end
			elseif climb > STEP_RISE or (s - lastS) > MAX_GAP or k == nProbes then
				local sy, why = placeStone(p.X, p.Z, lastY + MAX_RISE)
				if sy then
					lastY, lastS = sy, s
				elseif why == "stone budget exhausted" then
					budgetOut = true
				else
					table.insert(problems, string.format("s%.1f stone not placed: %s", s, why))
				end
			end
		end
	end
	if budgetOut and stonesPlaced >= MAX_STONES then
		table.insert(problems, string.format("path beyond s%.1f: stone budget exhausted", lastS or 0))
	end

	-- 4) Ledge stones: from wherever the path/stair topped out (PATH_B is the
	-- end of the ramp path, PATH_C the cave mouth), continue flat stepping
	-- stones toward the mouth until the part or stone budget runs out.
	local ledgeStep = 0
	if lastY ~= nil then
		local ls = 0
		while ls < ledgeLen and partsCreated < MAX_PARTS and stonesPlaced < MAX_STONES do
			ls = ls + 2
			ledgeStep = ledgeStep + 1
			local lp = PATH_B + ledgeDir * ls + perpU * (ledgeStep % 2 == 0 and 0.5 or -0.5)
			local sy, why = placeStone(lp.X, lp.Z, lastY + MAX_RISE)
			if sy then
				lastY, lastS = sy, pathLen + ls
			elseif why == "stone budget exhausted" or why == "part budget exhausted" then
				break
			end
		end
	end
	if partsCreated > MAX_PARTS then
		table.insert(problems, "part budget exceeded")
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

local ysText = #stoneYs > 0 and table.concat(stoneYs, ", ") or "none"
local problemsText = #problems > 0 and table.concat(problems, "; ") or "none"
return string.format("Cave18 rebuilt: %d parts created; stones %d/%d, y list: %s; problems: %s",
	partsCreated, stonesPlaced, MAX_STONES, ysText, problemsText)
