--==================================================
-- LIGHTWEIGHT ESP + GENERATOR PROGRESS
-- Roblox Studio - LocalScript
-- StarterPlayer > StarterPlayerScripts
--==================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Enabled = false
local ESPObjects = {}
local PlayerConnections = {}

--==================================================
-- COLORS
--==================================================

local SURVIVOR_COLOR = Color3.fromRGB(45, 255, 90)
local KILLER_COLOR = Color3.fromRGB(255, 45, 45)
local GENERATOR_COLOR = Color3.fromRGB(55, 170, 255)

--==================================================
-- ROLE DETECTION
--==================================================

local function getRole(player)

	-- Team
	if player.Team then
		local team = player.Team.Name:lower()

		if team:find("killer") then
			return "Killer"
		end

		if team:find("survivor") then
			return "Survivor"
		end
	end

	-- Attribute
	local role = player:GetAttribute("Role")

	if typeof(role) == "string" then
		role = role:lower()

		if role:find("killer") then
			return "Killer"
		end

		if role:find("survivor") then
			return "Survivor"
		end
	end

	-- Attribute alternatif
	local class = player:GetAttribute("Class")

	if typeof(class) == "string" then
		class = class:lower()

		if class:find("killer") then
			return "Killer"
		end

		if class:find("survivor") then
			return "Survivor"
		end
	end

	return "Survivor"
end

--==================================================
-- GENERATOR CHECK
--==================================================

local function isGenerator(obj)

	if not obj:IsA("Model") then
		return false
	end

	local name = obj.Name:lower()

	return name:find("generator") ~= nil
		or name == "gen"
		or name:find("gen_") ~= nil
end

--==================================================
-- FIND GENERATOR PROGRESS
--==================================================

local function getGeneratorProgress(generator)

	-- Attribute
	local attributes = {
		"Progress",
		"progress",
		"RepairProgress",
		"repairProgress",
		"GeneratorProgress",
		"generatorProgress",
		"Percentage",
		"percentage",
		"Percent",
		"percent"
	}

	for _, name in ipairs(attributes) do
		local value = generator:GetAttribute(name)

		if typeof(value) == "number" then
			if value <= 1 then
				return math.clamp(value * 100, 0, 100)
			else
				return math.clamp(value, 0, 100)
			end
		end
	end

	-- Value objects di dalam generator
	for _, obj in ipairs(generator:GetDescendants()) do

		if obj:IsA("NumberValue") or obj:IsA("IntValue") then

			local name = obj.Name:lower()

			if name:find("progress")
				or name:find("repair")
				or name:find("percent") then

				local value = obj.Value

				if value <= 1 then
					value = value * 100
				end

				return math.clamp(value, 0, 100)
			end
		end
	end

	return nil
end

--==================================================
-- CREATE ESP
--==================================================

local function createESP(object, color, text)

	if not object then
		return
	end

	if ESPObjects[object] then
		return
	end

	if not object:IsDescendantOf(Workspace) then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESP_Highlight"
	highlight.Adornee = object
	highlight.FillColor = color
	highlight.OutlineColor = color
	highlight.FillTransparency = 0.80
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = object

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESP_Label"
	billboard.Adornee = object
	billboard.Size = UDim2.fromOffset(110, 20)
	billboard.StudsOffset = Vector3.new(0, 2.7, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 300
	billboard.Parent = object

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.TextStrokeTransparency = 0.35
	label.TextSize = 11
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard

	ESPObjects[object] = {
		Highlight = highlight,
		Billboard = billboard,
		Label = label,
		Type = "Normal"
	}
end

--==================================================
-- GENERATOR ESP
--==================================================

local function createGeneratorESP(generator)

	if ESPObjects[generator] then
		return
	end

	if not generator:IsDescendantOf(Workspace) then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESP_Generator"
	highlight.Adornee = generator
	highlight.FillColor = GENERATOR_COLOR
	highlight.OutlineColor = GENERATOR_COLOR
	highlight.FillTransparency = 0.82
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = generator

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Generator_Progress"
	billboard.Adornee = generator
	billboard.Size = UDim2.fromOffset(110, 22)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 350
	billboard.Parent = generator

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = GENERATOR_COLOR
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.TextStrokeTransparency = 0.3
	label.TextSize = 10
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard

	ESPObjects[generator] = {
		Highlight = highlight,
		Billboard = billboard,
		Label = label,
		Type = "Generator"
	}

	local progress = getGeneratorProgress(generator)

	if progress then
		label.Text = "GEN • " .. math.floor(progress) .. "%"
	else
		label.Text = "GEN"
	end
end

--==================================================
-- REMOVE ESP
--==================================================

local function removeESP(object)

	local data = ESPObjects[object]

	if not data then
		return
	end

	if data.Highlight then
		data.Highlight:Destroy()
	end

	if data.Billboard then
		data.Billboard:Destroy()
	end

	ESPObjects[object] = nil
end

--==================================================
-- PLAYER ESP
--==================================================

local function updatePlayer(player)

	if player == LocalPlayer then
		return
	end

	if not Enabled then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	-- Hapus ESP karakter lama
	removeESP(character)

	local role = getRole(player)

	if role == "Killer" then

		createESP(
			character,
			KILLER_COLOR,
			player.DisplayName
		)

	else

		createESP(
			character,
			SURVIVOR_COLOR,
			player.DisplayName
		)

	end
end

local function setupPlayer(player)

	if player == LocalPlayer then
		return
	end

	if PlayerConnections[player] then
		PlayerConnections[player]:Disconnect()
	end

	PlayerConnections[player] =
		player.CharacterAdded:Connect(function()
			task.wait(0.2)

			if Enabled then
				updatePlayer(player)
			end
		end)

	if player.Character then
		task.spawn(function()
			updatePlayer(player)
		end)
	end
end

--==================================================
-- SCAN ALL
--==================================================

local function scanAll()

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			setupPlayer(player)
			updatePlayer(player)
		end
	end

	for _, object in ipairs(Workspace:GetDescendants()) do

		if object:IsA("Model") and isGenerator(object) then
			createGeneratorESP(object)
		end

	end
end

--==================================================
-- CLEAR
--==================================================

local function clearAll()

	local objects = {}

	for object in pairs(ESPObjects) do
		table.insert(objects, object)
	end

	for _, object in ipairs(objects) do
		removeESP(object)
	end
end

--==================================================
-- ENABLE / DISABLE
--==================================================

local function setESP(state)

	Enabled = state

	if not state then
		clearAll()
		return
	end

	scanAll()
end

--==================================================
-- PLAYER EVENTS
--==================================================

Players.PlayerAdded:Connect(function(player)

	if Enabled then
		setupPlayer(player)

		task.wait(0.2)

		updatePlayer(player)
	end
end)

Players.PlayerRemoving:Connect(function(player)

	if PlayerConnections[player] then
		PlayerConnections[player]:Disconnect()
		PlayerConnections[player] = nil
	end

	if player.Character then
		removeESP(player.Character)
	end
end)

--==================================================
-- NEW GENERATOR DETECTION
--==================================================

Workspace.DescendantAdded:Connect(function(object)

	if not Enabled then
		return
	end

	if object:IsA("Model") and isGenerator(object) then

		task.wait(0.1)

		if Enabled then
			createGeneratorESP(object)
		end
	end
end)

--==================================================
-- UPDATE LOOP
--==================================================

task.spawn(function()

	while true do

		task.wait(0.5)

		if Enabled then

			-- Update player role
			for _, player in ipairs(Players:GetPlayers()) do

				if player ~= LocalPlayer then
					updatePlayer(player)
				end

			end

			-- Update generator progress
			for object, data in pairs(ESPObjects) do

				if data.Type == "Generator"
					and object.Parent then

					local progress =
						getGeneratorProgress(object)

					if progress then

						data.Label.Text =
							"GEN • "
							.. math.floor(progress)
							.. "%"

						if progress >= 100 then

							data.Label.Text =
								"GEN • DONE"

							data.Label.TextColor3 =
								Color3.fromRGB(80, 255, 120)

						end
					else
						data.Label.Text = "GEN"
					end
				end
			end
		end
	end
end)

--==================================================
-- ROUND RESPAWN CHECK
--==================================================

task.spawn(function()

	while true do

		task.wait(2)

		if Enabled then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					if player.Character
						and not ESPObjects[player.Character] then

						updatePlayer(player)
					end
				end
			end
		end
	end
end)

--==================================================
-- SMALL CIRCULAR BUTTON
--==================================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "ESP_Controller"
GUI.ResetOnSpawn = false
GUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Button = Instance.new("TextButton")
Button.Name = "ESP_Button"
Button.Size = UDim2.fromOffset(44, 44)
Button.Position = UDim2.new(0, 25, 0.5, 0)

Button.BackgroundColor3 =
	Color3.fromRGB(55, 55, 55)

Button.Text = "ESP"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextSize = 11
Button.Font = Enum.Font.GothamBold

Button.AutoButtonColor = false
Button.Parent = GUI

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(1, 0)
Corner.Parent = Button

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(110, 110, 110)
Stroke.Thickness = 1
Stroke.Parent = Button

--==================================================
-- BUTTON
--==================================================

Button.Activated:Connect(function()

	setESP(not Enabled)

	if Enabled then

		Button.BackgroundColor3 =
			Color3.fromRGB(35, 180, 75)

	else

		Button.BackgroundColor3 =
			Color3.fromRGB(55, 55, 55)

	end
end)

--==================================================
-- DRAG
--==================================================

local dragging = false
local dragStart
local startPosition

Button.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = Button.Position
	end
end)

Button.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local delta =
			input.Position - dragStart

		Button.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)
