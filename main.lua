-- ============================================
-- TIARHUB v20 - BAGIAN 1/5
-- Setup + Services + Config
-- ============================================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
if not Rayfield then
    Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local InsertService = game:GetService("InsertService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local RainbowHue = 0
RunService.Heartbeat:Connect(function()
    RainbowHue = (RainbowHue + 0.008) % 1
end)
local function getRainbowColor()
    return Color3.fromHSV(RainbowHue, 1, 1)
end

local Window = Rayfield:CreateWindow({
    name = "TiarHub v20",
    subtitle = "Violence District",
    sidebarLayout = true,
    configuration = { autoSave = true, autoLoad = true, fileName = "TiarHubV20" }
})

local SASUKE_BG_ID = "rbxassetid://0"
local SasukeBG = Instance.new("ScreenGui")
SasukeBG.Name = "TiarSasukeBG"
SasukeBG.ResetOnSpawn = false
SasukeBG.IgnoreGuiInset = true
SasukeBG.DisplayOrder = -999
SasukeBG.Parent = CoreGui

local BGImage = Instance.new("ImageLabel")
BGImage.Name = "BG"
BGImage.Size = UDim2.new(1, 0, 1, 0)
BGImage.Position = UDim2.new(0, 0, 0, 0)
BGImage.BackgroundTransparency = 1
BGImage.Image = SASUKE_BG_ID
BGImage.ImageTransparency = 0.35
BGImage.ScaleType = Enum.ScaleType.Crop
BGImage.Visible = false
BGImage.Parent = SasukeBG

local ESP = {
    Survivor = false, Killer = false, Generator = false,
    Hook = false, Pallet = false, Window = false, SCP = false,
    Distance = 300, Mode = "Highlight",
    ShowName = true, NameSize = 14,
    SurvivorColor = Color3.fromRGB(60, 255, 120),
    KillerColor = Color3.fromRGB(255, 60, 60),
    GeneratorColor = Color3.fromRGB(255, 170, 0),
    HookColor = Color3.fromRGB(180, 80, 255),
    PalletColor = Color3.fromRGB(255, 220, 80),
    WindowColor = Color3.fromRGB(80, 255, 255),
    SCPColor = Color3.fromRGB(255, 0, 0)
}

local ESPStatus = { Enabled = false, ShowName = true, ShowDistance = true, ShowHealth = false, Radius = 100 }
local KillerWarning = { Enabled = false, Distance = 60, Color = Color3.fromRGB(255, 0, 0) }

local Visual = {
    Fullbright = false, NoFog = false, NoShadow = false,
    NoBloom = false, NoBlur = false, ColorCorrection = false,
    Saturation = 0, Brightness = 0, Contrast = 0,
    AmbientColorEnabled = false, AmbientColor = Color3.fromRGB(255, 255, 255),
    ClockTimeEnabled = false, ClockTime = 14,
    FogControlEnabled = false, FogEnd = 100000, FogStart = 0,
    FogColor = Color3.fromRGB(200, 200, 200),
    NoCameraShake = false, NoBlood = false,
    LowGraphics = false, CleanSky = false
}

local VisualOriginal = {
    Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
    Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
    GlobalShadows = Lighting.GlobalShadows, FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart, FogColor = Lighting.FogColor
}

local PARRY_PRESETS = {
    Safety     = { Distance = 12, Debounce = 0.15, Face = 0.5, RequireFacing = true },
    Aggressive = { Distance = 20, Debounce = 0.05, Face = -1,  RequireFacing = false }
}

local Auto = {
    Parry = false, ParryMode = "Safety",
    ParryDistance = 12, FaceSensitivity = 0.5, RequireFacing = true,
    SkillCheck = false, Wiggle = false, WiggleSpam = 5
}

local PARRY_DEBOUNCE = 0.15

local function applyParryPreset(mode)
    local p = PARRY_PRESETS[mode]
    if not p then return end
    Auto.ParryDistance = p.Distance
    Auto.FaceSensitivity = p.Face
    Auto.RequireFacing = p.RequireFacing
    PARRY_DEBOUNCE = p.Debounce
end

local ParryRangeVisual = {
    Enabled = false, Color = Color3.fromRGB(255, 80, 80),
    Transparency = 0.7, RainbowMode = false, PulseEnabled = true
}
local ParryCircle = nil
local ParryCircleInner = nil
local ParryCircleLastCF = nil

local AutoFlee = { Enabled = false, DetectDistance = 50, Cooldown = 0.1 }
local LastFlee = 0

local FastVault = {
    Enabled = false, Speed = 1.2,
    ReplaceMap = { ["rbxassetid://83873880822918"] = "rbxassetid://136962284480779" }
}
local VaultTracks = {}

local AutoDodgeAbyss = {
    Enabled = false, Radius = 30, Cooldown = 2.0,
    CrouchDuration = 0.3, LastDodge = 0,
    IsCrouching = false, DetectMode = "Both"
}

local FakePerks = {
    Flowstate = { Enabled = false, Duration = 3, SpeedBoost = 20, Cooldown = 10, LastUse = 0 },
    SnakeStep = { Enabled = false, SpeedBoost = 90, Cooldown = 10, LastUse = 0 },
    QuickRecovery = { Enabled = false, Cooldown = 10, LastUse = 0 },
    LastVault = 0, LastCrouchState = false
}

local SilentAimSpear = {
    Enabled = false, TargetMode = "Killer",
    FOV = 250, AimPart = "HumanoidRootPart",
    Prediction = 0.12, Holding = false, ShowFOV = false
}
local SilentAimCircle = nil

local HideSpark = { Enabled = false }
local HiddenSparkCache = {}

local Teleport = { LastTeleport = 0, Cooldown = 0.5 }

local AutoEscape = { Enabled = false, DetectDistance = 40, Cooldown = 0.8, LastEscape = 0 }

local SkillCheckMode = "Perfect"

local SoundFeedback = { Enabled = true, CurrentSound = "Click", Volume = 0.5, LastPlay = 0, Cooldown = 0.05 }
local SoundList = {
    Click  = "rbxassetid://6895079853",
    Switch = "rbxassetid://876939830",
    Beep   = "rbxassetid://4817809188",
    Bell   = "rbxassetid://5156781795",
    Whoosh = "rbxassetid://5063167535"
}
local SoundInstance = nil

local function initSound()
    if SoundInstance then return end
    SoundInstance = Instance.new("Sound")
    SoundInstance.Name = "TiarClickSound"
    SoundInstance.Volume = SoundFeedback.Volume
    pcall(function() SoundInstance.Parent = SoundService end)
    if not SoundInstance.Parent then SoundInstance.Parent = CoreGui end
end

local function playClickSound()
    if not SoundFeedback.Enabled then return end
    local now = tick()
    if now - SoundFeedback.LastPlay < SoundFeedback.Cooldown then return end
    SoundFeedback.LastPlay = now
    initSound()
    pcall(function()
        SoundInstance.SoundId = SoundList[SoundFeedback.CurrentSound] or SoundList.Click
        SoundInstance.Volume = SoundFeedback.Volume
        SoundInstance:Play()
    end)
end

initSound()

local AvatarCopier = {
    Enabled = true, TargetUsername = "",
    OriginalDescription = nil, CurrentCopiedUserId = nil, BlockyBody = true
}

local GunAim = {
    Enabled = false, Holding = false, TargetMode = "Killer",
    Strength = 1, Predict = true, PredictStrength = 0.12,
    FOV = 250, VisibilityCheck = false, AimPart = "HumanoidRootPart",
    ShowTracer = false, TracerColor = Color3.fromRGB(255, 0, 0)
}

local FOVCircle = nil
local FOVCircleInner = nil
local FOVCircleVisible = false
local FOVCircleSize = 250
local FOVCircleColor = Color3.fromRGB(255, 255, 255)

local KillerAim = { Enabled = false, FOV = 200, Strength = 0.5, Holding = false }

local AimlockButton = {
    Enabled = false, Locked = false, LockedTarget = nil,
    Radius = 250, ShowCircle = true,
    CircleColor = Color3.fromRGB(255, 0, 100),
    Strength = 0.4, Predict = 0.12,
    AimPart = "HumanoidRootPart", TargetMode = "Killer",
    Gui = nil, Circle = nil, CircleInner = nil
}

local Killer = {
    AutoAttack = false, AutoCarry = false, AutoHook = false, KillAll = false,
    AutoStalk = false, StalkRange = 150,
    AutoHookAllDowned = false, AutoHookAllRange = 500,
    AutoSprint = false, AutoSprintValue = 30,
    AutoFaceTarget = false, AutoFaceRange = 20,
    PredictionAttack = false, PredictStrength = 0.15,
    AttackDelay = 0.45, LastAttack = 0
}
local KillerBusy = false
local KillerTarget = nil
local StalkConnection = nil

local HitMarker = {
    Enabled = false, Color = Color3.fromRGB(255, 0, 0),
    Size = 20, Thickness = 2, Duration = 0.15
}
local HitMarkerLines = {}
local HitMarkerActive = false
local HitMarkerEnd = 0

local ChaseDetector = { Enabled = false, Range = 30, LastNotify = 0, Cooldown = 2 }

local Movement = {
    WalkSpeedEnabled = false, WalkSpeedValue = 17.6, OriginalWalkSpeed = 16,
    NoClip = false
}

local PlayerMods = { GodMode = false }

local CameraZoom = {
    UnlimitedZoom = false, MaxDistance = 1000, MinDistance = 0,
    FOVEnabled = false, FOV = 70,
    DefaultFOV = workspace.CurrentCamera.FieldOfView
}

local Moonwalk = {
    Enabled = false, ShowButton = false,
    SpamSpeed = 30, Intensity = 35, SlowSpeed = 13, UseSlow = true,
    Mode = "Default", FOVPreset = 90
}
local MoonwalkConnection = nil
local MoonwalkHeartbeat = nil
local MoonwalkButton = nil
local ParryActive = false

local Crosshair = {
    Enabled = false, Size = 8, Thickness = 2,
    Color = Color3.fromRGB(255, 255, 255),
    Style = "Plus", OffsetX = 0, OffsetY = 0
}

local Emote = { Selected = "Mannrobics" }
local EmoteList = { "Mannrobics","Arm Swing","Schadenfreude","Kyoufuu","Backflip","Griddy","Friday Night","Floating Rest","OnePlays","Quick Combo","WarCry","Wave" }

local Masked = { CurrentPower = "Cobra" }
local MaskedPowers = {"Cobra", "Richter", "Brandon", "Rabbit", "Alex"}

local AntiLag = {
    Enabled = false, NoParticles = false, NoTextures = false,
    PhysicsThrottle = false, NoGlobalShadows = false, NetworkLag = false
}

local FPSOverlay = { Enabled = true, Gui = nil, Label = nil, FPS = 0, Frames = 0, LastTick = tick() }

local KillerAnims = {
["rbxassetid://105374834496520"] = true, ["rbxassetid://113255068724446"] = true,
["rbxassetid://118907603246885"] = true, ["rbxassetid://129784271201071"] = true,
["rbxassetid://117042998468241"] = true, ["rbxassetid://122812055447896"] = true,
["rbxassetid://78935059863801"] = true, ["rbxassetid://74968262036854"] = true,
["rbxassetid://78432063483146"] = true, ["rbxassetid://132817836308238"] = true,
["rbxassetid://133963973694098"] = true, ["rbxassetid://111920872708571"] = true,
["rbxassetid://80411309607666"] = true, ["rbxassetid://98163597193511"] = true,
["rbxassetid://82666958311998"] = true, ["rbxassetid://110355011987939"] = true,
["rbxassetid://139369275981139"] = true, ["rbxassetid://135002183282873"] = true,
["rbxassetid://121216847022485"] = true, ["rbxassetid://130593238885843"] = true,
["rbxassetid://117070354890871"] = true, ["rbxassetid://106871536134254"] = true,
["rbxassetid://138720291317243"] = true
}

local function findRemote(path)
    local cur = ReplicatedStorage
    for seg in string.gmatch(path, "[^%.]+") do
        cur = cur and cur:FindFirstChild(seg)
        if not cur then return nil end
    end
    return cur
end

local AttackEvent = findRemote("Remotes.Attacks.BasicAttack")
local CarryEvent = findRemote("Remotes.Carry.CarrySurvivorEvent")
local HookEvent = findRemote("Remotes.Carry.HookEvent")
local EmoteRemote = findRemote("Remotes.EmoteHandler")

local function getRoot()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function isDowned()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    return hum.Health <= 0 or hum.Health < 2
        or char:GetAttribute("Downed") == true
        or char:GetAttribute("IsDown") == true
        or char:GetAttribute("Knocked") == true
end

local function shouldDisableWalkSpeed()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local anim = track.Animation
                if anim and anim.AnimationId then
                    local id = anim.AnimationId:match("%d+")
                    if id and KillerAnims["rbxassetid://" .. id] then return true end
                end
            end
        end
    end
    if hum and (hum.Health <= 0 or hum.Health < 2) then return true end
    return false
end

local function GetPos(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local ok, p = pcall(function() return obj:GetPivot().Position end)
        if ok then return p end
    end
    return nil
end

local function getTeamLabel(plr)
    if not plr.Team then return "?" end
    if plr.Team.Name == "Killer" then return "KILLER" end
    if plr.Team.Name == "Survivors" or plr.Team.Name == "Survivor" then return "SURVIVOR" end
    return plr.Team.Name
end

local function GetNearestKiller()
    local root = getRoot()
    if not root then return nil end
    local closest, shortest = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team and plr.Team.Name == "Killer" and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < shortest then shortest = dist; closest = hrp end
            end
        end
    end
    return closest, shortest
end

-- END BAGIAN 1-- ============================================
-- TIARHUB v20 - BAGIAN 2/5
-- ESP System + Smooth Parry + FPS Overlay
-- ============================================

local ESPObjects = {}
local ESPNames = {}
local StatusESP = {}
local CachedObjects = { Generators = {}, Hooks = {}, Pallets = {}, Windows = {} }
local CachedSCP = {}

local function removeESP(obj)
    if ESPObjects[obj] then ESPObjects[obj]:Destroy(); ESPObjects[obj] = nil end
    if ESPNames[obj] then ESPNames[obj]:Destroy(); ESPNames[obj] = nil end
end

local function createESP(obj, color, showName, customName)
    if not obj then return end
    if ESPObjects[obj] then
        local h = ESPObjects[obj]
        if ESP.Mode == "Outline" then h.FillTransparency = 1; h.OutlineTransparency = 0
        elseif ESP.Mode == "Fill" then h.FillTransparency = 0.5; h.OutlineTransparency = 1
        else h.FillTransparency = 0.9; h.OutlineTransparency = 0.3 end
        h.FillColor = color; h.OutlineColor = color
    else
        local h = Instance.new("Highlight")
        h.FillColor = color; h.OutlineColor = color
        if ESP.Mode == "Outline" then h.FillTransparency = 1; h.OutlineTransparency = 0
        elseif ESP.Mode == "Fill" then h.FillTransparency = 0.5; h.OutlineTransparency = 1
        else h.FillTransparency = 0.9; h.OutlineTransparency = 0.3 end
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = obj
        ESPObjects[obj] = h
        obj.AncestryChanged:Connect(function(_, parent)
            if not parent then removeESP(obj) end
        end)
    end
    if showName then
        local head = obj:FindFirstChild("Head")
        local adornee = head or (obj:IsA("BasePart") and obj)
        if adornee then
            local playerName = customName or "?"
            local teamLabel = ""
            if not customName then
                local plr = Players:GetPlayerFromCharacter(obj)
                if plr then playerName = plr.Name; teamLabel = getTeamLabel(plr) end
            end
            local displayText = playerName
            if teamLabel ~= "" then displayText = string.format("[%s] %s", teamLabel, playerName) end
            if ESPNames[obj] then
                local bb = ESPNames[obj]
                bb.Size = UDim2.new(0, 250, 0, ESP.NameSize * 2)
                local lbl = bb:FindFirstChildOfClass("TextLabel")
                if lbl then lbl.Text = displayText; lbl.TextSize = ESP.NameSize; lbl.TextColor3 = color end
            else
                local bb = Instance.new("BillboardGui")
                bb.Size = UDim2.new(0, 250, 0, ESP.NameSize * 2)
                bb.AlwaysOnTop = true
                bb.StudsOffset = Vector3.new(0, 2.5, 0)
                bb.Adornee = adornee
                bb.Parent = obj
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = displayText
                lbl.TextColor3 = color
                lbl.TextStrokeTransparency = 0
                lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = ESP.NameSize
                lbl.Parent = bb
                ESPNames[obj] = bb
            end
        end
    end
end

local function UpdateGenerator(generator)
    if not generator or not generator.Parent then return end
    if not ESP.Generator then
        local old = generator:FindFirstChild("GenHighlight"); if old then old:Destroy() end
        local oldName = generator:FindFirstChild("GenNameTag"); if oldName then oldName:Destroy() end
        return
    end
    local percent = 0
    local found = false
    local attr = generator:GetAttribute("Progress")
    if attr and type(attr) == "number" then percent = attr; found = true end
    if not found then
        local attr2 = generator:GetAttribute("RepairProgress")
        if attr2 and type(attr2) == "number" then percent = attr2; found = true end
    end
    if not found then
        for _, v in ipairs(generator:GetDescendants()) do
            if v:IsA("ValueBase") and (v.Name == "Progress" or v.Name == "RepairProgress" or v.Name == "Percent") then
                percent = v.Value; found = true; break
            end
        end
    end
    if not found then
        for _, v in ipairs(generator:GetChildren()) do
            if v:IsA("NumberValue") then percent = v.Value; found = true; break end
        end
    end
    percent = math.clamp(percent, 0, 100)
    local color = ESP.GeneratorColor
    local labelText = "Generator"
    if found then
        color = ESP.GeneratorColor:Lerp(Color3.fromRGB(0, 255, 120), percent / 100)
        labelText = string.format("Gen %.0f%%", percent)
    end
    local h = generator:FindFirstChild("GenHighlight") or Instance.new("Highlight")
    h.Name = "GenHighlight"
    h.Adornee = generator
    h.FillColor = color
    h.OutlineColor = color
    if ESP.Mode == "Outline" then h.FillTransparency = 1; h.OutlineTransparency = 0
    elseif ESP.Mode == "Fill" then h.FillTransparency = 0.5; h.OutlineTransparency = 1
    else h.FillTransparency = 0.9; h.OutlineTransparency = 0.3 end
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = generator
    local bb = generator:FindFirstChild("GenNameTag")
    if not bb then
        bb = Instance.new("BillboardGui")
        bb.Name = "GenNameTag"
        bb.Size = UDim2.new(0, 150, 0, 40)
        bb.AlwaysOnTop = true
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.Adornee = generator
        bb.Parent = generator
        local lbl = Instance.new("TextLabel")
        lbl.Name = "Label"
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextStrokeTransparency = 0
        lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.Parent = bb
    end
    local lbl = bb:FindFirstChild("Label") or bb:FindFirstChildOfClass("TextLabel")
    if lbl then lbl.Text = labelText; lbl.TextColor3 = color end
end

local function removeStatusESP(char)
    if StatusESP[char] then StatusESP[char]:Destroy(); StatusESP[char] = nil end
end

local function createStatusESP(player, char, root)
    if not ESPStatus.Enabled then removeStatusESP(char); return end
    if not root then return end
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not head or not hum then return end
    local isDown = hum.Health <= 0 or hum.Health < 2
    local dist = (head.Position - root.Position).Magnitude
    if dist > ESPStatus.Radius then removeStatusESP(char); return end
    local text = ""
    local teamLabel = getTeamLabel(player)
    if isDown then text = "DOWN\n" end
    text = text .. string.format("[%s]\n", teamLabel)
    if ESPStatus.ShowName then text = text .. player.Name .. "\n" end
    if ESPStatus.ShowDistance then text = text .. string.format("Dist: %.0f\n", dist) end
    if ESPStatus.ShowHealth then text = text .. string.format("HP: %.0f\n", hum.Health) end
    if text == "" then removeStatusESP(char); return end
    local bb = StatusESP[char]
    if not bb then
        bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 150, 0, 60)
        bb.AlwaysOnTop = true
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextStrokeTransparency = 0
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.Parent = bb
        bb.Adornee = head
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.Parent = char
        StatusESP[char] = bb
    end
    local lbl = bb:FindFirstChildOfClass("TextLabel")
    if lbl then
        lbl.Text = text
        local tc = Color3.new(1, 1, 1)
        if player.Team then
            if player.Team.Name == "Killer" then tc = ESP.KillerColor
            elseif player.Team.Name == "Survivors" or player.Team.Name == "Survivor" then tc = ESP.SurvivorColor end
        end
        if isDown then tc = Color3.fromRGB(255, 0, 0) end
        lbl.TextColor3 = tc
    end
end

local function cacheObject(obj)
    if not obj then return end
    if not obj:IsA("BasePart") and not obj:IsA("Model") then return end
    local name = obj.Name
    if name == "Generator" then CachedObjects.Generators[obj] = true
    elseif string.find(name, "Hook") and obj:IsA("BasePart") then CachedObjects.Hooks[obj] = true
    elseif name == "Pallet" or name == "Palletwrong" then CachedObjects.Pallets[obj] = true
    elseif name == "Window" then CachedObjects.Windows[obj] = true
    end
    if string.find(string.lower(name), "scp") then CachedSCP[obj] = true end
end

for _, obj in ipairs(workspace:GetDescendants()) do cacheObject(obj) end
workspace.DescendantAdded:Connect(cacheObject)
workspace.DescendantRemoving:Connect(function(obj)
    CachedObjects.Generators[obj] = nil
    CachedObjects.Hooks[obj] = nil
    CachedObjects.Pallets[obj] = nil
    CachedObjects.Windows[obj] = nil
    CachedSCP[obj] = nil
    removeESP(obj)
end)

local WarningGui = nil
local function updateWarning()
    pcall(function()
        local root = getRoot()
        if not KillerWarning.Enabled or not root then
            if WarningGui then WarningGui.Enabled = false end
            return
        end
        local nearest, dist = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local isKiller = p.Team and p.Team.Name == "Killer"
                if isKiller then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local d = (hrp.Position - root.Position).Magnitude
                        if d < dist then dist = d; nearest = p end
                    end
                end
            end
        end
        if not WarningGui then
            WarningGui = Instance.new("ScreenGui")
            WarningGui.Name = "TiarKillerWarning"
            WarningGui.ResetOnSpawn = false
            WarningGui.IgnoreGuiInset = true
            WarningGui.DisplayOrder = 5
            WarningGui.Parent = PlayerGui
            local frame = Instance.new("Frame")
            frame.Name = "Border"
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 1
            frame.Parent = WarningGui
            local stroke = Instance.new("UIStroke")
            stroke.Name = "Stroke"
            stroke.Thickness = 12
            stroke.Color = KillerWarning.Color
            stroke.Transparency = 0.5
            stroke.Parent = frame
            local text = Instance.new("TextLabel")
            text.Name = "WarnText"
            text.Size = UDim2.new(0, 400, 0, 60)
            text.Position = UDim2.new(0.5, -200, 0, 40)
            text.BackgroundTransparency = 1
            text.Text = "KILLER DEKAT"
            text.TextColor3 = KillerWarning.Color
            text.TextStrokeTransparency = 0
            text.TextStrokeColor3 = Color3.new(0, 0, 0)
            text.Font = Enum.Font.GothamBlack
            text.TextScaled = true
            text.Visible = false
            text.Parent = WarningGui
        end
        WarningGui.Enabled = true
        local border = WarningGui:FindFirstChild("Border")
        local stroke = border and border:FindFirstChild("Stroke")
        local warnText = WarningGui:FindFirstChild("WarnText")
        if dist <= KillerWarning.Distance then
            if stroke then stroke.Transparency = 0.3 end
            if warnText then warnText.Visible = true; warnText.Text = string.format("KILLER DEKAT (%.0f stud)", dist) end
        else
            if stroke then stroke.Transparency = 0.9 end
            if warnText then warnText.Visible = false end
        end
    end)
end

local function createFPSOverlay()
    if FPSOverlay.Gui then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "TiarFPSOverlay"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 10
    gui.Parent = PlayerGui
    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.Size = UDim2.new(0, 220, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(150, 0, 255)
    stroke.Thickness = 1.5
    stroke.Parent = frame
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "TiarHub | FPS: -- | PING: -- ms"
    label.TextColor3 = Color3.fromRGB(200, 215, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Parent = frame
    FPSOverlay.Gui = gui
    FPSOverlay.Label = label
end

local function updateFPSOverlay()
    if not FPSOverlay.Enabled then
        if FPSOverlay.Gui then FPSOverlay.Gui.Enabled = false end
        return
    end
    if not FPSOverlay.Gui then createFPSOverlay() end
    FPSOverlay.Gui.Enabled = true
    if FPSOverlay.Label then
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        FPSOverlay.Label.Text = string.format("TiarHub | FPS: %d | PING: %d ms", FPSOverlay.FPS, ping)
    end
end

createFPSOverlay()

RunService.RenderStepped:Connect(function()
    FPSOverlay.Frames = FPSOverlay.Frames + 1
    if tick() - FPSOverlay.LastTick >= 1 then
        FPSOverlay.FPS = FPSOverlay.Frames
        FPSOverlay.Frames = 0
        FPSOverlay.LastTick = tick()
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        pcall(function()
            Rayfield:SetWatermark(string.format("TiarHub | FPS: %d | PING: %d ms", FPSOverlay.FPS, ping))
        end)
        updateFPSOverlay()
    end
end)

local lastUpdate = 0
local PARRY_LERP_SPEED = 0.25

RunService.RenderStepped:Connect(function()
    pcall(function()
        local root = getRoot()
        if not root then return end
        local now = tick()

        if ParryRangeVisual.Enabled and root then
            if not ParryCircle then
                ParryCircle = Instance.new("Part")
                ParryCircle.Shape = Enum.PartType.Cylinder
                ParryCircle.Anchored = true
                ParryCircle.CanCollide = false
                ParryCircle.Material = Enum.Material.Neon
                ParryCircle.Name = "ParryCircleOuter"
                ParryCircle.Parent = workspace
            end
            if not ParryCircleInner then
                ParryCircleInner = Instance.new("Part")
                ParryCircleInner.Shape = Enum.PartType.Cylinder
                ParryCircleInner.Anchored = true
                ParryCircleInner.CanCollide = false
                ParryCircleInner.Material = Enum.Material.Neon
                ParryCircleInner.Name = "ParryCircleInner"
                ParryCircleInner.Parent = workspace
            end

            local baseSize = Auto.ParryDistance * 2
            local pulse = 0
            if ParryRangeVisual.PulseEnabled then
                pulse = math.sin(tick() * 3) * 0.15
            end

            local sizeOuter = baseSize + pulse
            local sizeInner = baseSize - 0.8
            local yOffset = root.Size.Y / 2 + 1.5
            local targetCF = CFrame.new(root.Position - Vector3.new(0, yOffset, 0)) * CFrame.Angles(0, 0, math.rad(90))

            if ParryCircleLastCF then
                ParryCircleLastCF = ParryCircleLastCF:Lerp(targetCF, PARRY_LERP_SPEED)
            else
                ParryCircleLastCF = targetCF
            end

            ParryCircle.Size = Vector3.new(0.3, sizeOuter, sizeOuter)
            ParryCircle.CFrame = ParryCircleLastCF
            ParryCircle.Transparency = ParryRangeVisual.Transparency

            ParryCircleInner.Size = Vector3.new(0.15, sizeInner, sizeInner)
            ParryCircleInner.CFrame = ParryCircleLastCF
            ParryCircleInner.Transparency = ParryRangeVisual.Transparency + 0.15

            local color = ParryRangeVisual.Color
            if ParryRangeVisual.RainbowMode then color = getRainbowColor() end
            ParryCircle.Color = color
            ParryCircleInner.Color = color
        else
            if ParryCircle then ParryCircle:Destroy(); ParryCircle = nil end
            if ParryCircleInner then ParryCircleInner:Destroy(); ParryCircleInner = nil end
            ParryCircleLastCF = nil
        end

        if now - lastUpdate < 0.05 then return end
        lastUpdate = now

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local char = p.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dist = (hrp.Position - root.Position).Magnitude
                        if dist <= ESP.Distance then
                            local isKiller = p.Team and p.Team.Name == "Killer"
                            local isSurv = p.Team and (p.Team.Name == "Survivors" or p.Team.Name == "Survivor")
                            if ESP.Survivor and isSurv then createESP(char, ESP.SurvivorColor, ESP.ShowName)
                            elseif ESP.Killer and isKiller then createESP(char, ESP.KillerColor, ESP.ShowName)
                            else removeESP(char) end
                        else removeESP(char) end
                    end
                    createStatusESP(p, char, root)
                else removeESP(char); removeStatusESP(char) end
            end
        end

        if ESP.Generator then
            for gen in pairs(CachedObjects.Generators) do
                local pos = GetPos(gen)
                if pos and (pos - root.Position).Magnitude <= ESP.Distance then UpdateGenerator(gen)
                else
                    local old = gen:FindFirstChild("GenHighlight"); if old then old:Destroy() end
                    local oldName = gen:FindFirstChild("GenNameTag"); if oldName then oldName:Destroy() end
                end
            end
        end

        if ESP.Hook then
            for hook in pairs(CachedObjects.Hooks) do
                local pos = GetPos(hook)
                if pos and (pos - root.Position).Magnitude <= ESP.Distance then createESP(hook, ESP.HookColor, false)
                else removeESP(hook) end
            end
        else for hook in pairs(CachedObjects.Hooks) do removeESP(hook) end end

        if ESP.Pallet then
            for pallet in pairs(CachedObjects.Pallets) do
                local pos = GetPos(pallet)
                if pos and (pos - root.Position).Magnitude <= ESP.Distance then createESP(pallet, ESP.PalletColor, false)
                else removeESP(pallet) end
            end
        else for pallet in pairs(CachedObjects.Pallets) do removeESP(pallet) end end

        if ESP.Window then
            for win in pairs(CachedObjects.Windows) do
                local pos = GetPos(win)
                if pos and (pos - root.Position).Magnitude <= ESP.Distance then createESP(win, ESP.WindowColor, false)
                else removeESP(win) end
            end
        else for win in pairs(CachedObjects.Windows) do removeESP(win) end end

        if ESP.SCP then
            for scp in pairs(CachedSCP) do
                local pos = GetPos(scp)
                if pos and (pos - root.Position).Magnitude <= ESP.Distance then createESP(scp, ESP.SCPColor, false)
                else removeESP(scp) end
            end
        else for scp in pairs(CachedSCP) do removeESP(scp) end end

        updateWarning()
    end)
end)

local function isTiarHubGui(gui)
    if not gui then return false end
    local name = gui.Name or ""
    if name:find("TiarHub") or name:find("Rayfield") or name:find("rayfield") then return true end
    for _, v in pairs(gui:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text and (v.Text:find("TiarHub")) then return true end
    end
    return false
end

local function rainbowifyGui(gui)
    if not gui then return end
    for _, v in pairs(gui:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            pcall(function()
                if v.Text and v.Text:find("TiarHub") then
                    v.Font = Enum.Font.GothamBlack
                    v.TextStrokeTransparency = 0.2
                    v.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                end
            end)
            task.spawn(function()
                while v and v.Parent do
                    pcall(function()
                        v.TextColor3 = getRainbowColor()
                        if v.TextStrokeTransparency < 1 then
                            v.TextStrokeTransparency = 0.3
                            v.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        end
                    end)
                    task.wait(0.08)
                end
            end)
        end
        if v:IsA("UIStroke") then
            task.spawn(function()
                while v and v.Parent do
                    pcall(function()
                        v.Color = getRainbowColor()
                        if v.Thickness < 1.5 then v.Thickness = 1.5 end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
end

task.spawn(function()
    task.wait(3)
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") and isTiarHubGui(gui) then rainbowifyGui(gui) end
    end
    CoreGui.ChildAdded:Connect(function(child)
        if child:IsA("ScreenGui") then
            task.wait(0.5)
            if isTiarHubGui(child) then rainbowifyGui(child) end
        end
    end)
end)

task.spawn(function()
    task.wait(5)
    pcall(function()
        local found = false
        local rayGui = nil
        for _, g in pairs(CoreGui:GetChildren()) do
            if g:IsA("ScreenGui") and (g.Name:find("Rayfield") or g.Name:find("rayfield") or g.Name:find("TiarHub")) then
                rayGui = g; found = true; break
            end
        end
        if not found then
            for _, g in pairs(PlayerGui:GetChildren()) do
                if g:IsA("ScreenGui") and (g.Name:find("Rayfield") or g.Name:find("rayfield") or g.Name:find("TiarHub")) then
                    rayGui = g; found = true; break
                end
            end
        end
        if rayGui then
            BGImage.Visible = rayGui.Enabled
            rayGui:GetPropertyChangedSignal("Enabled"):Connect(function()
                BGImage.Visible = rayGui.Enabled
            end)
        end
    end)
end)

-- END BAGIAN 2-- ============================================
-- TIARHUB v20 - BAGIAN 3/5
-- Survivor System
-- ============================================

local lastParry = 0

local function pressRightClick()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
        task.wait()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
    end)
end

local function GetParryButton()
    local current = PlayerGui
    for segment in string.gmatch("Survivor-mob.Controls.Gui-mob", "[^%.]+") do
        current = current and current:FindFirstChild(segment)
    end
    return current
end

local function pressParryButton()
    if UserInputService.TouchEnabled then
        local btn = GetParryButton()
        if btn and btn:IsA("GuiObject") then
            local pos = btn.AbsolutePosition
            local size = btn.AbsoluteSize
            local inset = game:GetService("GuiService"):GetGuiInset()
            pcall(function()
                VirtualInputManager:SendTouchEvent(8823, 0, pos.X + size.X/2 + inset.X, pos.Y + size.Y/2 + inset.Y)
                task.wait(0.01)
                VirtualInputManager:SendTouchEvent(8823, 2, pos.X + size.X/2 + inset.X, pos.Y + size.Y/2 + inset.Y)
            end)
        end
    else
        pressRightClick()
    end
end

local function doParry()
    local now = tick()
    if now - lastParry < PARRY_DEBOUNCE then return end
    lastParry = now
    ParryActive = true
    pressParryButton()
    task.delay(0.25, function() ParryActive = false end)
end

local hookedKillers = {}
local lastKillerParry = {}

local function hookKiller(char)
    if hookedKillers[char] then return end
    hookedKillers[char] = true
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end
    animator.AnimationPlayed:Connect(function(track)
        if not Auto.Parry then return end
        local anim = track.Animation
        if not anim then return end
        local id = anim.AnimationId:match("%d+")
        if not id then return end
        if not KillerAnims["rbxassetid://" .. id] then return end
        local myRoot = getRoot()
        local enemyRoot = char:FindFirstChild("HumanoidRootPart")
        if not myRoot or not enemyRoot then return end
        local dist = (enemyRoot.Position - myRoot.Position).Magnitude
        if dist > Auto.ParryDistance then return end
        local now = tick()
        if lastKillerParry[char] and now - lastKillerParry[char] < 0.4 then return end
        lastKillerParry[char] = now
        doParry()
    end)
end

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Auto.Parry then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        if p.Team and p.Team.Name == "Killer" then
                            hookKiller(p.Character)
                        end
                    end
                end
            end
        end)
    end
end)

local TouchID = 8822
local ActionPath = "Survivor-mob.Controls.action.check"
local busy = false
local SkillHeartbeat = nil

local function GetActionTarget()
    local current = PlayerGui
    for segment in string.gmatch(ActionPath, "[^%.]+") do
        current = current and current:FindFirstChild(segment)
    end
    return current
end

local function pressSpace()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
end

local function TriggerMobileButton()
    local b = GetActionTarget()
    if b and b:IsA("GuiObject") then
        local p = b.AbsolutePosition
        local s = b.AbsoluteSize
        local i = game:GetService("GuiService"):GetGuiInset()
        pcall(function()
            VirtualInputManager:SendTouchEvent(TouchID, 0, p.X + (s.X/2) + i.X, p.Y + (s.Y/2) + i.Y)
            task.wait(0.01)
            VirtualInputManager:SendTouchEvent(TouchID, 2, p.X + (s.X/2) + i.X, p.Y + (s.Y/2) + i.Y)
        end)
    end
end

local function startSkillCheck()
    if SkillHeartbeat then SkillHeartbeat:Disconnect() end
    SkillHeartbeat = RunService.RenderStepped:Connect(function()
        pcall(function()
            if not Auto.SkillCheck or busy then return end
            local prompt = PlayerGui:FindFirstChild("SkillCheckPromptGui")
            if not prompt then return end
            local check = prompt:FindFirstChild("Check")
            if not check or not check.Visible then return end
            local line = check:FindFirstChild("Line")
            local goal = check:FindFirstChild("Goal")
            if not line or not goal then return end
            local lr = line.Rotation % 360
            local gr = goal.Rotation % 360
            if SkillCheckMode == "Instant" then
                busy = true
                task.spawn(function()
                    if UserInputService.TouchEnabled then TriggerMobileButton() else pressSpace() end
                    task.wait(0.05)
                    busy = false
                end)
            else
                local startRange = (gr + 102) % 360
                local endRange   = (gr + 116) % 360
                local success = (startRange > endRange and (lr >= startRange or lr <= endRange))
                    or (lr >= startRange and lr <= endRange)
                if success then
                    busy = true
                    task.spawn(function()
                        if UserInputService.TouchEnabled then TriggerMobileButton() else pressSpace() end
                        task.wait(0.05)
                        busy = false
                    end)
                end
            end
        end)
    end)
end

local function AutoWiggle()
    if not Auto.Wiggle then return end
    local char = LocalPlayer.Character
    if not char then return end
    local carried = (char:FindFirstChild("IsCarried") and char.IsCarried.Value)
        or (char:FindFirstChild("IsCarrying") and char.IsCarrying.Value)
    if not carried then return end
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return end
    local carry = remotes:FindFirstChild("Carry")
    if not carry then return end
    local event = carry:FindFirstChild("SelfUnHookEvent")
    if not event then return end
    for i = 1, Auto.WiggleSpam do event:FireServer() end
end

local function GetFarthestGeneratorPoint(killerRoot)
    if not killerRoot then return nil end
    local bestPoint, farthest = nil, 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.match(obj.Name, "^GeneratorPoint%d+$") then
            local dist = (obj.Position - killerRoot.Position).Magnitude
            if dist > farthest then farthest = dist; bestPoint = obj end
        end
    end
    return bestPoint
end

task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if not AutoFlee.Enabled then return end
            local root = getRoot()
            if not root then return end
            local killerRoot, distance = GetNearestKiller()
            if killerRoot and distance <= AutoFlee.DetectDistance and tick() - LastFlee > AutoFlee.Cooldown then
                local point = GetFarthestGeneratorPoint(killerRoot)
                if point then
                    LastFlee = tick()
                    root.CFrame = point.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end)
    end
end)

local AbyssSlashAnims = {}

local function isAbyssSlashSound(sound)
    if not sound then return false end
    local name = string.lower(sound.Name or "")
    return string.find(name, "severance") or string.find(name, "slash")
        or string.find(name, "dark") or string.find(name, "abyss")
end

local function IsAbyssKiller(plr)
    if not plr or not plr.Character then return false end
    if not plr.Team or plr.Team.Name ~= "Killer" then return false end
    local charName = string.lower(plr.Character.Name)
    local plrName = string.lower(plr.Name)
    local dispName = plr.DisplayName and string.lower(plr.DisplayName) or ""
    if string.find(charName, "abyss") then return true end
    if string.find(plrName, "abyss") then return true end
    if string.find(dispName, "abyss") then return true end
    for _, v in ipairs(plr.Character:GetChildren()) do
        if v:IsA("Tool") and string.find(string.lower(v.Name), "abyss") then
            return true
        end
    end
    return false
end

local function GetNearestAbyss()
    local root = getRoot()
    if not root then return nil end
    local closest, shortest = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and IsAbyssKiller(plr) then
            local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - root.Position).Magnitude
                if d < shortest then shortest = d; closest = hrp end
            end
        end
    end
    return closest, shortest
end

local function FindCrouchButton()
    local paths = {
        "Survivor-mob.Controls.Gui-mob.Crouch",
        "Survivor-mob.Controls.Gui-mob.crouch",
        "Survivor-mob.Controls.crouch",
        "Survivor-mob.Controls.Crouch",
        "Survivor-mob.Controls.action.crouch",
        "Survivor-mob.Controls.action.Crouch",
    }
    for _, path in ipairs(paths) do
        local cur = PlayerGui
        for segment in string.gmatch(path, "[^%.]+") do
            cur = cur and cur:FindFirstChild(segment)
        end
        if cur and cur:IsA("GuiObject") then return cur end
    end
    for _, v in ipairs(PlayerGui:GetDescendants()) do
        if v:IsA("GuiObject") and string.find(string.lower(v.Name), "crouch") then
            return v
        end
    end
    return nil
end

local function PressCrouchButton()
    local btn = FindCrouchButton()
    if btn then
        local pos = btn.AbsolutePosition
        local size = btn.AbsoluteSize
        local inset = game:GetService("GuiService"):GetGuiInset()
        local x = pos.X + size.X/2 + inset.X
        local y = pos.Y + size.Y/2 + inset.Y
        pcall(function()
            VirtualInputManager:SendTouchEvent(7777, 0, x, y)
            task.wait(0.05)
            VirtualInputManager:SendTouchEvent(7777, 2, x, y)
        end)
        return true
    end
    if not UserInputService.TouchEnabled then
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game)
        end)
        return true
    end
    return false
end

local function DoDodgeAbyss()
    if AutoDodgeAbyss.IsCrouching then return end
    AutoDodgeAbyss.IsCrouching = true
    PressCrouchButton()
    task.delay(AutoDodgeAbyss.CrouchDuration, function()
        if AutoDodgeAbyss.Enabled then
            PressCrouchButton()
        end
        AutoDodgeAbyss.IsCrouching = false
    end)
end

local hookedAbyss = {}

local function hookAbyssAnim(char)
    if hookedAbyss[char] then return end
    hookedAbyss[char] = true
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end
    animator.AnimationPlayed:Connect(function(track)
        if not AutoDodgeAbyss.Enabled then return end
        local anim = track.Animation
        if not anim or not anim.AnimationId then return end
        local id = anim.AnimationId:match("%d+")
        if not id then return end
        local fullId = "rbxassetid://" .. id
        if AbyssSlashAnims[fullId] then
            local myRoot = getRoot()
            local enemyRoot = char:FindFirstChild("HumanoidRootPart")
            if not myRoot or not enemyRoot then return end
            local dist = (enemyRoot.Position - myRoot.Position).Magnitude
            if dist <= AutoDodgeAbyss.Radius then
                local now = tick()
                if now - AutoDodgeAbyss.LastDodge >= AutoDodgeAbyss.Cooldown then
                    AutoDodgeAbyss.LastDodge = now
                    DoDodgeAbyss()
                end
            end
        end
    end)
    for _, sound in ipairs(char:GetDescendants()) do
        if sound:IsA("Sound") and isAbyssSlashSound(sound) then
            sound.Played:Connect(function()
                if not AutoDodgeAbyss.Enabled then return end
                local myRoot = getRoot()
                local enemyRoot = char:FindFirstChild("HumanoidRootPart")
                if not myRoot or not enemyRoot then return end
                local dist = (enemyRoot.Position - myRoot.Position).Magnitude
                if dist <= AutoDodgeAbyss.Radius then
                    local now = tick()
                    if now - AutoDodgeAbyss.LastDodge >= AutoDodgeAbyss.Cooldown then
                        AutoDodgeAbyss.LastDodge = now
                        DoDodgeAbyss()
                    end
                end
            end)
        end
    end
end

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if not AutoDodgeAbyss.Enabled then return end
            if AutoDodgeAbyss.DetectMode == "Anim" then return end
            local root = getRoot()
            if not root then return end
            if isDowned() then return end
            local abyssRoot, dist = GetNearestAbyss()
            if not abyssRoot then return end
            if dist > AutoDodgeAbyss.Radius then return end
            local now = tick()
            if now - AutoDodgeAbyss.LastDodge < AutoDodgeAbyss.Cooldown then return end
            AutoDodgeAbyss.LastDodge = now
            DoDodgeAbyss()
        end)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and IsAbyssKiller(plr) and plr.Character then
                    hookAbyssAnim(plr.Character)
                end
            end
        end)
    end
end)

local function hookFakeFlowstate(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end
    animator.AnimationPlayed:Connect(function(track)
        if not FakePerks.Flowstate.Enabled then return end
        local anim = track.Animation
        if not anim or not anim.AnimationId then return end
        local id = anim.AnimationId:match("%d+")
        if not id then return end
        local vaultIds = {
            ["rbxassetid://83873880822918"] = true,
            ["rbxassetid://136962284480779"] = true,
        }
        if vaultIds["rbxassetid://" .. id] then
            local now = tick()
            if now - FakePerks.Flowstate.LastUse < FakePerks.Flowstate.Cooldown then return end
            if now - FakePerks.LastVault < 1 then return end
            FakePerks.Flowstate.LastUse = now
            FakePerks.LastVault = now
            local originalSpeed = hum.WalkSpeed
            hum.WalkSpeed = originalSpeed * (1 + FakePerks.Flowstate.SpeedBoost / 100)
            Rayfield:Notify({ title = "Fake Flowstate", content = "Speed boost aktif!", duration = 2 })
            task.delay(FakePerks.Flowstate.Duration, function()
                if hum and hum.Parent then
                    hum.WalkSpeed = originalSpeed
                end
            end)
        end
    end)
end

task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if not FakePerks.SnakeStep.Enabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local isCrouching = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
                or (hum.HipHeight and hum.HipHeight < 1.5)
            if isCrouching and not FakePerks.LastCrouchState then
                local now = tick()
                if now - FakePerks.SnakeStep.LastUse < FakePerks.SnakeStep.Cooldown then return end
                FakePerks.SnakeStep.LastUse = now
                FakePerks.LastCrouchState = true
                hum.WalkSpeed = FakePerks.SnakeStep.SpeedBoost
            elseif not isCrouching and FakePerks.LastCrouchState then
                FakePerks.LastCrouchState = false
                if Movement.WalkSpeedEnabled then
                    hum.WalkSpeed = Movement.WalkSpeedValue
                else
                    hum.WalkSpeed = 16
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if not FakePerks.QuickRecovery.Enabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.FallingDown
                or state == Enum.HumanoidStateType.Ragdoll
                or hum.Health < hum.MaxHealth * 0.3 then
                local now = tick()
                if now - FakePerks.QuickRecovery.LastUse < FakePerks.QuickRecovery.Cooldown then return end
                FakePerks.QuickRecovery.LastUse = now
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end)
            end
        end)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    pcall(function() hookFakeFlowstate(char) end)
end)
if LocalPlayer.Character then pcall(function() hookFakeFlowstate(LocalPlayer.Character) end) end

local Drawing = Drawing
local TracerLine = nil

local function createFOVCircle()
    if not Drawing then return end
    if FOVCircle then FOVCircle:Remove() end
    if FOVCircleInner then FOVCircleInner:Remove() end
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 80
    FOVCircle.Radius = FOVCircleSize
    FOVCircle.Filled = false
    FOVCircle.Color = FOVCircleColor
    FOVCircle.Transparency = 0.6
    FOVCircleInner = Drawing.new("Circle")
    FOVCircleInner.Visible = false
    FOVCircleInner.Thickness = 1
    FOVCircleInner.NumSides = 80
    FOVCircleInner.Radius = FOVCircleSize - 3
    FOVCircleInner.Filled = false
    FOVCircleInner.Color = FOVCircleColor
    FOVCircleInner.Transparency = 0.3
end

local function createTracer()
    if not Drawing then return end
    if TracerLine then TracerLine:Remove() end
    TracerLine = Drawing.new("Line")
    TracerLine.Visible = false
    TracerLine.Thickness = 1
    TracerLine.Color = GunAim.TracerColor
end

createTracer()
createFOVCircle()

RunService.RenderStepped:Connect(function()
    pcall(function()
        if not FOVCircle then return end
        if FOVCircleVisible then
            FOVCircle.Visible = true
            FOVCircle.Radius = FOVCircleSize
            FOVCircle.Color = FOVCircleColor
            FOVCircle.Position = Vector2.new(
                workspace.CurrentCamera.ViewportSize.X / 2,
                workspace.CurrentCamera.ViewportSize.Y / 2
            )
            if FOVCircleInner then
                FOVCircleInner.Visible = true
                FOVCircleInner.Radius = FOVCircleSize - 3
                FOVCircleInner.Color = FOVCircleColor
                FOVCircleInner.Position = FOVCircle.Position
            end
        else
            FOVCircle.Visible = false
            if FOVCircleInner then FOVCircleInner.Visible = false end
        end
    end)
end)

local function createSilentAimCircle()
    if not Drawing then return end
    if SilentAimCircle then SilentAimCircle:Remove() end
    SilentAimCircle = Drawing.new("Circle")
    SilentAimCircle.Visible = false
    SilentAimCircle.Thickness = 2
    SilentAimCircle.NumSides = 60
    SilentAimCircle.Radius = SilentAimSpear.FOV
    SilentAimCircle.Filled = false
    SilentAimCircle.Color = Color3.fromRGB(150, 0, 255)
    SilentAimCircle.Transparency = 0.6
end

createSilentAimCircle()

local function getSilentAimTarget()
    local cam = workspace.CurrentCamera
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local closest, shortest = nil, SilentAimSpear.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Team then
            local valid = false
            if SilentAimSpear.TargetMode == "Killer" and p.Team.Name == "Killer" then valid = true
            elseif SilentAimSpear.TargetMode == "Survivor" and (p.Team.Name == "Survivors" or p.Team.Name == "Survivor") then valid = true
            elseif SilentAimSpear.TargetMode == "Both" then valid = true end
            if valid then
                local hrp = p.Character:FindFirstChild(SilentAimSpear.AimPart)
                    or p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local pos, visible = cam:WorldToViewportPoint(hrp.Position)
                    if visible then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < shortest then
                            shortest = dist
                            closest = hrp
                        end
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        if SilentAimCircle then
            SilentAimCircle.Visible = SilentAimSpear.Enabled and SilentAimSpear.ShowFOV
            SilentAimCircle.Radius = SilentAimSpear.FOV
            SilentAimCircle.Position = Vector2.new(
                workspace.CurrentCamera.ViewportSize.X / 2,
                workspace.CurrentCamera.ViewportSize.Y / 2
            )
        end
        if not SilentAimSpear.Enabled then return end
        if not SilentAimSpear.Holding then return end
        local target = getSilentAimTarget()
        if not target then return end
        local cam = workspace.CurrentCamera
        local pos = target.Position
        if SilentAimSpear.Prediction > 0 then
            pos = pos + (target.AssemblyLinearVelocity * SilentAimSpear.Prediction)
        end
        cam.CFrame = CFrame.new(cam.CFrame.Position, pos)
    end)
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not SilentAimSpear.Enabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and string.find(string.lower(tool.Name), "veil") then
                SilentAimSpear.Holding = true
            else
                SilentAimSpear.Holding = false
            end
        end)
    end
end)

local function createHitMarkerLines()
    if not Drawing then return end
    for _, v in pairs(HitMarkerLines) do pcall(function() v:Remove() end) end
    HitMarkerLines = {}
    for i = 1, 4 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = HitMarker.Thickness
        line.Color = HitMarker.Color
        table.insert(HitMarkerLines, line)
    end
end

local function triggerHitMarker()
    HitMarkerActive = true
    HitMarkerEnd = tick() + HitMarker.Duration
    if #HitMarkerLines == 0 then createHitMarkerLines() end
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        if not Drawing then return end
        if not HitMarker.Enabled then
            for _, v in pairs(HitMarkerLines) do v.Visible = false end
            return
        end
        if not HitMarkerActive or tick() > HitMarkerEnd then
            HitMarkerActive = false
            for _, v in pairs(HitMarkerLines) do v.Visible = false end
            return
        end
        if #HitMarkerLines == 0 then createHitMarkerLines() end
        local cam = workspace.CurrentCamera
        local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        local s = HitMarker.Size
        local t = HitMarker.Thickness
        for _, v in pairs(HitMarkerLines) do
            v.Thickness = t
            v.Color = HitMarker.Color
            v.Visible = true
        end
        HitMarkerLines[1].From = center + Vector2.new(-s, -s)
        HitMarkerLines[1].To   = center + Vector2.new(-s/2, -s/2)
        HitMarkerLines[2].From = center + Vector2.new(s, -s)
        HitMarkerLines[2].To   = center + Vector2.new(s/2, -s/2)
        HitMarkerLines[3].From = center + Vector2.new(-s, s)
        HitMarkerLines[3].To   = center + Vector2.new(-s/2, s/2)
        HitMarkerLines[4].From = center + Vector2.new(s, s)
        HitMarkerLines[4].To   = center + Vector2.new(s/2, s/2)
    end)
end)

local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Blacklist

local function isVisible(part)
    local cam = workspace.CurrentCamera
    RayParams.FilterDescendantsInstances = { LocalPlayer.Character }
    local origin = cam.CFrame.Position
    local direction = (part.Position - origin)
    local result = workspace:Raycast(origin, direction, RayParams)
    if not result then return true end
    return result.Instance:IsDescendantOf(part.Parent)
end

local function getClosestGunTarget()
    local cam = workspace.CurrentCamera
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local closest, shortest = nil, GunAim.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Team then
            local valid = false
            if GunAim.TargetMode == "Killer" and p.Team.Name == "Killer" then valid = true
            elseif GunAim.TargetMode == "Survivor" and (p.Team.Name == "Survivors" or p.Team.Name == "Survivor") then valid = true
            elseif GunAim.TargetMode == "Both" then valid = true end
            if valid then
                local hrp = p.Character:FindFirstChild(GunAim.AimPart) or p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local pos, visible = cam:WorldToViewportPoint(hrp.Position)
                    if visible then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < shortest then
                            if GunAim.VisibilityCheck and not isVisible(hrp) then
                            else
                                shortest = dist
                                closest = hrp
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        if not GunAim.Enabled then
            if TracerLine then TracerLine.Visible = false end
            return
        end
        if not GunAim.Holding then
            if TracerLine then TracerLine.Visible = false end
            return
        end
        local cam = workspace.CurrentCamera
        local target = getClosestGunTarget()
        if not target then
            if TracerLine then TracerLine.Visible = false end
            return
        end
        local pos = target.Position
        if GunAim.Predict then
            pos = pos + (target.AssemblyLinearVelocity * GunAim.PredictStrength)
        end
        cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, pos), GunAim.Strength)
        if GunAim.ShowTracer and TracerLine then
            local screenPos, onScreen = cam:WorldToViewportPoint(target.Position)
            if onScreen then
                TracerLine.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                TracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
                TracerLine.Color = GunAim.TracerColor
                TracerLine.Visible = true
            end
        end
    end)
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        GunAim.Holding = true
        KillerAim.Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        GunAim.Holding = false
        KillerAim.Holding = false
    end
end)

-- END BAGIAN 3-- ============================================
-- TIARHUB v20 - BAGIAN 4/5
-- Killer System + Movement + Visual + Camera + Teleport
-- ============================================

local function applyGodMode()
    if not PlayerMods.GodMode then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if hum.Health < hum.MaxHealth then
        pcall(function() hum.Health = hum.MaxHealth end)
    end
    local state = hum:GetState()
    if state == Enum.HumanoidStateType.Dead
        or state == Enum.HumanoidStateType.FallingDown
        or state == Enum.HumanoidStateType.Ragdoll then
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end
end

RunService.Heartbeat:Connect(function()
    pcall(applyGodMode)
end)

local function GetDownedSurvivor()
    local root = getRoot()
    if not root then return nil end
    local best, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 and hum.Health <= hum.MaxHealth * 0.25 then
                local d = (hrp.Position - root.Position).Magnitude
                if d < dist then dist = d; best = p.Character end
            end
        end
    end
    return best
end

local function GetNearestAliveSurvivor()
    local root = getRoot()
    if not root then return nil end
    local closest, shortest = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 30 then
                local d = (hrp.Position - root.Position).Magnitude
                if d < shortest then shortest = d; closest = p.Character end
            end
        end
    end
    return closest
end

local function GetHook()
    local root = getRoot()
    if not root then return nil end
    local bestHook, shortest = nil, math.huge
    for hook in pairs(CachedObjects.Hooks) do
        local pos = GetPos(hook)
        if pos then
            local dist = (pos - root.Position).Magnitude
            if dist < shortest and dist < 400 then shortest = dist; bestHook = hook end
        end
    end
    return bestHook
end

local function startAutoStalk()
    if StalkConnection then return end
    StalkConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not Killer.AutoStalk then return end
            local root = getRoot()
            if not root then return end
            local target, dist = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 30 then
                        local d = (hrp.Position - root.Position).Magnitude
                        if d <= Killer.StalkRange and d < dist then dist = d; target = p end
                    end
                end
            end
            if target then
                local stalkEvent = findRemote("Remotes.Killers.Stalker.StartStalking")
                if stalkEvent then pcall(function() stalkEvent:FireServer(target) end) end
            end
        end)
    end)
end

local function stopAutoStalk()
    if StalkConnection then StalkConnection:Disconnect(); StalkConnection = nil end
end

RunService.Heartbeat:Connect(function()
    pcall(function()
        if not getRoot() then return end

        if Killer.AutoAttack and AttackEvent then
            local now = tick()
            if now - Killer.LastAttack >= Killer.AttackDelay then
                Killer.LastAttack = now
                pcall(function() AttackEvent:FireServer(false) end)
                if HitMarker.Enabled and math.random(1,3) == 1 then triggerHitMarker() end
            end
        end

        if Killer.AutoHookAllDowned and HookEvent and not KillerBusy then
            local root = getRoot()
            if root then
                local bestHook, bestDist = nil, Killer.AutoHookAllRange
                for hook in pairs(CachedObjects.Hooks) do
                    local pos = GetPos(hook)
                    if pos then
                        local d = (pos - root.Position).Magnitude
                        if d < bestDist then bestDist = d; bestHook = hook end
                    end
                end
                if bestHook then
                    local hp = GetPos(bestHook)
                    if hp then
                        root.CFrame = CFrame.new(hp) * CFrame.new(0, 4, -3)
                        task.wait(0.3)
                        for i = 1, 3 do HookEvent:FireServer(bestHook); task.wait(0.1) end
                    end
                end
            end
        end

        if Killer.AutoCarry and not KillerBusy and CarryEvent then
            KillerBusy = true
            task.spawn(function()
                local target = GetDownedSurvivor()
                local root = getRoot()
                if target and root then
                    local tRoot = target:FindFirstChild("HumanoidRootPart")
                    if tRoot then
                        root.CFrame = tRoot.CFrame * CFrame.new(0, 3, -2)
                        task.wait(0.4)
                        for i = 1, 4 do CarryEvent:FireServer(target); task.wait(0.2) end
                        task.wait(0.6)
                        if Killer.AutoHook and HookEvent then
                            local hook = GetHook()
                            if hook then
                                local hp = GetPos(hook)
                                if hp then
                                    root.CFrame = CFrame.new(hp) * CFrame.new(0, 4, -3)
                                    task.wait(0.7)
                                    for i = 1, 6 do HookEvent:FireServer(hook); task.wait(0.15) end
                                end
                            end
                        end
                    end
                end
                task.wait(1.5)
                KillerBusy = false
            end)
        end

        if Killer.KillAll and AttackEvent then
            local root = getRoot()
            if root then
                if not KillerTarget or not KillerTarget:FindFirstChild("Humanoid") or KillerTarget.Humanoid.Health <= 35 then
                    KillerTarget = GetNearestAliveSurvivor()
                end
                if KillerTarget then
                    local targetHRP = KillerTarget:FindFirstChild("HumanoidRootPart")
                    if targetHRP then
                        local velocity = targetHRP.AssemblyLinearVelocity
                        local predict = velocity * 0.15
                        local targetPos = targetHRP.Position + predict
                        local behind = targetHRP.CFrame.LookVector * -3
                        root.CFrame = CFrame.new(targetPos + behind, targetPos)
                    end
                    local now = tick()
                    if now - Killer.LastAttack >= Killer.AttackDelay then
                        Killer.LastAttack = now
                        pcall(function() AttackEvent:FireServer(false) end)
                    end
                end
            end
        end

        if Killer.AutoSprint then
            local hum = getHum()
            if hum and hum.WalkSpeed < Killer.AutoSprintValue then
                local target = GetNearestAliveSurvivor()
                if target then
                    local hrp = target:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local myRoot = getRoot()
                        if myRoot then
                            local d = (hrp.Position - myRoot.Position).Magnitude
                            if d < 100 then hum.WalkSpeed = Killer.AutoSprintValue end
                        end
                    end
                end
            end
        else
            local hum = getHum()
            if hum and Movement.WalkSpeedEnabled == false and hum.WalkSpeed == Killer.AutoSprintValue then
                hum.WalkSpeed = Movement.OriginalWalkSpeed
            end
        end

        if Killer.AutoFaceTarget then
            local root = getRoot()
            if root then
                local target = GetNearestAliveSurvivor()
                if target then
                    local hrp = target:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local d = (hrp.Position - root.Position).Magnitude
                        if d <= Killer.AutoFaceRange then
                            local myHum = getHum()
                            if myHum then
                                myHum.AutoRotate = false
                                local look = CFrame.new(root.Position, hrp.Position).LookVector
                                root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(look.X, 0, look.Z))
                            end
                        end
                    end
                end
            end
        end

        if Killer.PredictionAttack and AttackEvent then
            local root = getRoot()
            if root then
                local target = GetNearestAliveSurvivor()
                if target then
                    local hrp = target:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local d = (hrp.Position - root.Position).Magnitude
                        if d < 15 then
                            local vel = hrp.AssemblyLinearVelocity
                            local predPos = hrp.Position + (vel * Killer.PredictStrength)
                            local myHum = getHum()
                            if myHum then myHum.AutoRotate = false end
                            root.CFrame = CFrame.new(root.Position, predPos)
                            pcall(function() AttackEvent:FireServer(false) end)
                            if HitMarker.Enabled then triggerHitMarker() end
                        end
                    end
                end
            end
        end

        if ChaseDetector.Enabled then
            local now = tick()
            if now - ChaseDetector.LastNotify > ChaseDetector.Cooldown then
                local root = getRoot()
                if root then
                    local closest, dist = nil, math.huge
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            local isSurv = p.Team and (p.Team.Name == "Survivors" or p.Team.Name == "Survivor")
                            if isSurv then
                                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    local d = (hrp.Position - root.Position).Magnitude
                                    if d < dist then dist = d; closest = p end
                                end
                            end
                        end
                    end
                    if closest and dist <= ChaseDetector.Range then
                        ChaseDetector.LastNotify = now
                        Rayfield:Notify({ title = "Chase Alert", content = string.format("Survivor dalam %.0f stud!", dist), duration = 2 })
                    end
                end
            end
        end
    end)
end)

local function getClosestSurvivorForKiller()
    local cam = workspace.CurrentCamera
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local closest, shortest = nil, KillerAim.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local isSurvivor = p.Team and (p.Team.Name == "Survivors" or p.Team.Name == "Survivor")
            if isSurvivor then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local pos, visible = cam:WorldToViewportPoint(hrp.Position)
                    if visible then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < shortest then shortest = dist; closest = hrp end
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        if not KillerAim.Enabled then return end
        local mouseHeld = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        if not (KillerAim.Holding or mouseHeld) then return end
        local target = getClosestSurvivorForKiller()
        if not target then return end
        local cam = workspace.CurrentCamera
        local pos = target.Position
        if GunAim.Predict then
            pos = pos + (target.AssemblyLinearVelocity * GunAim.PredictStrength)
        end
        cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, pos), KillerAim.Strength)
    end)
end)

local function createAimlockButton()
    if AimlockButton.Gui then AimlockButton.Gui:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "TiarAimlockBtn"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 20
    gui.Parent = PlayerGui

    local btn = Instance.new("ImageButton")
    btn.Name = "LockBtn"
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0.15, 0, 0.75, 0)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    btn.BackgroundTransparency = 0.15
    btn.Image = "rbxassetid://6023426923"
    btn.ImageColor3 = Color3.fromRGB(200, 200, 200)
    btn.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Name = "Stroke"
    stroke.Color = Color3.fromRGB(150, 0, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = btn

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0, 100, 0, 18)
    label.Position = UDim2.new(0.5, -50, 1, 4)
    label.BackgroundTransparency = 1
    label.Text = "LOCK: OFF"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.Parent = btn

    local dragging, dragStart, startPos = false, nil, nil
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    btn.MouseButton1Click:Connect(function()
        AimlockButton.Locked = not AimlockButton.Locked
        if AimlockButton.Locked then
            stroke.Color = Color3.fromRGB(0, 255, 100)
            label.Text = "LOCK: ON"
            btn.ImageColor3 = Color3.fromRGB(0, 255, 100)
            Rayfield:Notify({ title = "Aimlock", content = "Target locked!", duration = 1.5 })
        else
            stroke.Color = Color3.fromRGB(150, 0, 255)
            label.Text = "LOCK: OFF"
            btn.ImageColor3 = Color3.fromRGB(200, 200, 200)
            AimlockButton.LockedTarget = nil
        end
    end)

    AimlockButton.Gui = gui
    AimlockButton.Stroke = stroke
    AimlockButton.Label = label
end

local function removeAimlockButton()
    if AimlockButton.Gui then AimlockButton.Gui:Destroy(); AimlockButton.Gui = nil end
end

local function createAimlockCircle()
    if not Drawing then return end
    if AimlockButton.Circle then AimlockButton.Circle:Remove() end
    if AimlockButton.CircleInner then AimlockButton.CircleInner:Remove() end
    AimlockButton.Circle = Drawing.new("Circle")
    AimlockButton.Circle.Visible = false
    AimlockButton.Circle.Thickness = 2
    AimlockButton.Circle.NumSides = 80
    AimlockButton.Circle.Filled = false
    AimlockButton.Circle.Color = AimlockButton.CircleColor
    AimlockButton.Circle.Transparency = 0.6
    AimlockButton.CircleInner = Drawing.new("Circle")
    AimlockButton.CircleInner.Visible = false
    AimlockButton.CircleInner.Thickness = 1
    AimlockButton.CircleInner.NumSides = 80
    AimlockButton.CircleInner.Filled = false
    AimlockButton.CircleInner.Color = AimlockButton.CircleColor
    AimlockButton.CircleInner.Transparency = 0.3
end

createAimlockCircle()

local function getClosestAimlockTarget()
    local cam = workspace.CurrentCamera
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local closest, shortest = nil, AimlockButton.Radius
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Team then
            local valid = false
            if AimlockButton.TargetMode == "Killer" and p.Team.Name == "Killer" then valid = true
            elseif AimlockButton.TargetMode == "Survivor" and (p.Team.Name == "Survivors" or p.Team.Name == "Survivor") then valid = true
            elseif AimlockButton.TargetMode == "Both" then valid = true end
            if valid then
                local hrp = p.Character:FindFirstChild(AimlockButton.AimPart)
                    or p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local pos, visible = cam:WorldToViewportPoint(hrp.Position)
                    if visible then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < shortest then
                            shortest = dist
                            closest = hrp
                        end
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        if AimlockButton.Circle then
            local cam = workspace.CurrentCamera
            local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            local show = AimlockButton.Enabled and AimlockButton.ShowCircle
            AimlockButton.Circle.Visible = show
            AimlockButton.CircleInner.Visible = show
            AimlockButton.Circle.Radius = AimlockButton.Radius
            AimlockButton.CircleInner.Radius = AimlockButton.Radius - 3
            AimlockButton.Circle.Position = center
            AimlockButton.CircleInner.Position = center
            local col = AimlockButton.Locked and Color3.fromRGB(0, 255, 100) or AimlockButton.CircleColor
            AimlockButton.Circle.Color = col
            AimlockButton.CircleInner.Color = col
        end

        if not AimlockButton.Locked then return end
        local cam = workspace.CurrentCamera
        local target = AimlockButton.LockedTarget
        if target then
            local hum = target.Parent and target.Parent:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 or not target.Parent then
                target = nil
                AimlockButton.LockedTarget = nil
            else
                local pos, visible = cam:WorldToViewportPoint(target.Position)
                if not visible then
                    target = nil
                    AimlockButton.LockedTarget = nil
                else
                    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist > AimlockButton.Radius then
                        target = nil
                        AimlockButton.LockedTarget = nil
                    end
                end
            end
        end
        if not target then
            target = getClosestAimlockTarget()
            AimlockButton.LockedTarget = target
        end
        if not target then return end
        local pos = target.Position
        if AimlockButton.Predict > 0 then
            pos = pos + (target.AssemblyLinearVelocity * AimlockButton.Predict)
        end
        cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, pos), AimlockButton.Strength)
    end)
end)

local function normalizeId(id)
    local num = tostring(id):match("%d+")
    return num and ("rbxassetid://" .. num)
end

local function hookVault(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end
    animator.AnimationPlayed:Connect(function(track)
        pcall(function()
            if not FastVault.Enabled then return end
            local anim = track.Animation
            if not anim or not anim.AnimationId then return end
            local id = normalizeId(anim.AnimationId)
            if not id then return end
            local replaceId = FastVault.ReplaceMap[id]
            if not replaceId then return end
            if VaultTracks[track] then return end
            VaultTracks[track] = true
            track:Stop()
            local newAnim = Instance.new("Animation")
            newAnim.AnimationId = replaceId
            local newTrack = animator:LoadAnimation(newAnim)
            newTrack.Priority = Enum.AnimationPriority.Action
            newTrack:Play()
            newTrack:AdjustSpeed(FastVault.Speed)
            newTrack.Stopped:Connect(function() VaultTracks[track] = nil end)
        end)
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5); pcall(function() hookVault(char) end)
end)
if LocalPlayer.Character then pcall(function() hookVault(LocalPlayer.Character) end) end

local WalkSpeedConnection = nil
local function applyWalkSpeed()
    if WalkSpeedConnection then WalkSpeedConnection:Disconnect() end
    WalkSpeedConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not Movement.WalkSpeedEnabled then return end
            local hum = getHum()
            if not hum then return end
            if shouldDisableWalkSpeed() then return end
            if hum.WalkSpeed ~= Movement.WalkSpeedValue then hum.WalkSpeed = Movement.WalkSpeedValue end
        end)
    end)
end

local NoClipConnection = nil
local function toggleNoClip(state)
    Movement.NoClip = state
    if state then
        if NoClipConnection then NoClipConnection:Disconnect() end
        NoClipConnection = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not Movement.NoClip then return end
                local char = LocalPlayer.Character
                if not char then return end
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end)
        end)
    else
        if NoClipConnection then NoClipConnection:Disconnect(); NoClipConnection = nil end
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end
end

local function applyUnlimitedZoom()
    if CameraZoom.UnlimitedZoom then
        LocalPlayer.CameraMaxZoomDistance = CameraZoom.MaxDistance
        LocalPlayer.CameraMinZoomDistance = CameraZoom.MinDistance
    else
        LocalPlayer.CameraMaxZoomDistance = 128
        LocalPlayer.CameraMinZoomDistance = 0.5
    end
end

local function applyCameraFOV()
    local cam = workspace.CurrentCamera
    if not cam then return end
    if CameraZoom.FOVEnabled then
        cam.FieldOfView = CameraZoom.FOV
    else
        cam.FieldOfView = CameraZoom.DefaultFOV
    end
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        if CameraZoom.FOVEnabled then
            local cam = workspace.CurrentCamera
            if cam and cam.FieldOfView ~= CameraZoom.FOV then
                cam.FieldOfView = CameraZoom.FOV
            end
        end
    end)
end)

local function applyMoonwalkFOV()
    local cam = workspace.CurrentCamera
    if not cam then return end
    if Moonwalk.Enabled then
        cam.FieldOfView = Moonwalk.FOVPreset
    end
end

local function startMoonwalk()
    if MoonwalkConnection then return end
    local hum0 = getHum()
    if hum0 then hum0.AutoRotate = false end
    MoonwalkConnection = RunService.RenderStepped:Connect(function()
        if not Moonwalk.Enabled or ParryActive or isDowned() then return end
        local char = LocalPlayer.Character
        if not char or not char.Parent then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera
        if not (humanoid and hrp and cam) then return end
        humanoid.AutoRotate = false
        if Moonwalk.UseSlow and humanoid.WalkSpeed ~= Moonwalk.SlowSpeed then
            humanoid.WalkSpeed = Moonwalk.SlowSpeed
        end
        if Moonwalk.Mode == "Camera" then
            local camLook = cam.CFrame.LookVector
            local flatCam = Vector3.new(camLook.X, 0, camLook.Z)
            if flatCam.Magnitude > 0 then
                flatCam = flatCam.Unit
                local baseCF = CFrame.new(hrp.Position, hrp.Position + flatCam)
                local angle = math.sin(tick() * Moonwalk.SpamSpeed) * Moonwalk.Intensity
                hrp.CFrame = baseCF * CFrame.Angles(0, math.rad(angle), 0)
                humanoid:Move(Vector3.new(0, 0, 1), true)
            end
        else
            local look = cam.CFrame.LookVector
            local flatLook = Vector3.new(look.X, 0, look.Z)
            if flatLook.Magnitude > 0 then
                flatLook = flatLook.Unit
                local baseCF = CFrame.new(hrp.Position, hrp.Position + flatLook)
                local angle = math.sin(tick() * Moonwalk.SpamSpeed) * Moonwalk.Intensity
                hrp.CFrame = baseCF * CFrame.Angles(0, math.rad(angle), 0)
                humanoid:Move(Vector3.new(0, 0, 1), true)
            end
        end
    end)
    if MoonwalkHeartbeat then MoonwalkHeartbeat:Disconnect() end
    MoonwalkHeartbeat = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not Moonwalk.Enabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.AutoRotate = false end
        end)
    end)
end

local function stopMoonwalk()
    if MoonwalkConnection then MoonwalkConnection:Disconnect(); MoonwalkConnection = nil end
    if MoonwalkHeartbeat then MoonwalkHeartbeat:Disconnect(); MoonwalkHeartbeat = nil end
    local hum = getHum()
    if hum then
        hum.AutoRotate = true
        if Movement.WalkSpeedEnabled then hum.WalkSpeed = Movement.WalkSpeedValue
        else hum.WalkSpeed = Movement.OriginalWalkSpeed end
    end
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = 70 end
end

local function createMoonwalkButton()
    pcall(function()
        if MoonwalkButton then MoonwalkButton:Destroy() end
        local gui = Instance.new("ScreenGui")
        gui.Name = "MoonwalkGui"
        gui.ResetOnSpawn = false
        gui.Parent = PlayerGui
        local btn = Instance.new("ImageButton")
        btn.Size = UDim2.new(0, 50, 0, 50)
        btn.Position = UDim2.new(0.65, 0, 0.75, 0)
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundTransparency = 0.9
        btn.Parent = gui
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local stroke = Instance.new("UIStroke")
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Thickness = 1.2
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Transparency = 0.8
        stroke.Parent = btn
        btn.MouseButton1Click:Connect(function()
            Moonwalk.Enabled = not Moonwalk.Enabled
            if Moonwalk.Enabled then
                stroke.Color = Color3.fromRGB(170, 0, 255)
                if not MoonwalkConnection then startMoonwalk() end
                applyMoonwalkFOV()
            else
                stroke.Color = Color3.fromRGB(255, 255, 255)
                stopMoonwalk()
            end
        end)
        MoonwalkButton = gui
    end)
end

local function removeMoonwalkButton()
    if MoonwalkButton then MoonwalkButton:Destroy(); MoonwalkButton = nil end
end

local CrosshairDrawings = {}
local CrosshairLastStyle = nil

local function clearCrosshair()
    for _, v in pairs(CrosshairDrawings) do
        if v and v.Remove then pcall(function() v:Remove() end) end
    end
    CrosshairDrawings = {}
end

local function updateCrosshair()
    pcall(function()
        if not Drawing then return end
        if not Crosshair.Enabled then
            for _, v in pairs(CrosshairDrawings) do
                if v then v.Visible = false end
            end
            return
        end
        if CrosshairLastStyle ~= Crosshair.Style then
            clearCrosshair()
            CrosshairLastStyle = Crosshair.Style
        end
        local cam = workspace.CurrentCamera
        local center = Vector2.new(
            cam.ViewportSize.X / 2 + Crosshair.OffsetX,
            cam.ViewportSize.Y / 2 + Crosshair.OffsetY
        )
        if #CrosshairDrawings == 0 then
            if Crosshair.Style == "Plus" then
                for i = 1, 4 do
                    local line = Drawing.new("Line")
                    line.Visible = true
                    table.insert(CrosshairDrawings, line)
                end
            elseif Crosshair.Style == "Dot" then
                local dot = Drawing.new("Circle")
                dot.Filled = true
                dot.Visible = true
                table.insert(CrosshairDrawings, dot)
            elseif Crosshair.Style == "Circle" then
                local circle = Drawing.new("Circle")
                circle.Filled = false
                circle.Visible = true
                table.insert(CrosshairDrawings, circle)
            end
        end
        if Crosshair.Style == "Plus" then
            for _, line in pairs(CrosshairDrawings) do
                line.Color = Crosshair.Color
                line.Thickness = Crosshair.Thickness
                line.Visible = true
            end
            if CrosshairDrawings[1] then
                CrosshairDrawings[1].From = center + Vector2.new(-Crosshair.Size, 0)
                CrosshairDrawings[1].To   = center + Vector2.new(-2, 0)
                CrosshairDrawings[2].From = center + Vector2.new(Crosshair.Size, 0)
                CrosshairDrawings[2].To   = center + Vector2.new(2, 0)
                CrosshairDrawings[3].From = center + Vector2.new(0, -Crosshair.Size)
                CrosshairDrawings[3].To   = center + Vector2.new(0, -2)
                CrosshairDrawings[4].From = center + Vector2.new(0, Crosshair.Size)
                CrosshairDrawings[4].To   = center + Vector2.new(0, 2)
            end
        elseif Crosshair.Style == "Dot" then
            local dot = CrosshairDrawings[1]
            if dot then
                dot.Position = center
                dot.Radius = Crosshair.Size / 2
                dot.Color = Crosshair.Color
                dot.Visible = true
            end
        elseif Crosshair.Style == "Circle" then
            local circle = CrosshairDrawings[1]
            if circle then
                circle.Position = center
                circle.Radius = Crosshair.Size
                circle.Color = Crosshair.Color
                circle.Thickness = Crosshair.Thickness
                circle.Visible = true
            end
        end
    end)
end

RunService.RenderStepped:Connect(function() pcall(updateCrosshair) end)
RunService.Heartbeat:Connect(function() pcall(function() AutoWiggle() end) end)

local function playEmote(name)
    if EmoteRemote then pcall(function() EmoteRemote:FireServer(name) end) end
end

local function activateMasked()
    local event = findRemote("Remotes.Killers.Masked.Activatepower")
    if event then pcall(function() event:FireServer(Masked.CurrentPower) end) end
end
local function deactivateMasked()
    local event = findRemote("Remotes.Killers.Masked.Deactivatepower")
    if event then pcall(function() event:FireServer() end) end
end

local function saveOriginalAppearance()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    local ok, desc = pcall(function() return hum:GetAppliedDescription() end)
    if ok and desc then
        AvatarCopier.OriginalDescription = desc
        return true
    end
    return false
end

local function copyAvatar(username)
    if not username or username == "" then
        Rayfield:Notify({ title = "Copy Avatar", content = "Username kosong!" })
        return false
    end
    saveOriginalAppearance()
    local ok, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    if not ok or not userId then
        Rayfield:Notify({ title = "Copy Avatar", content = "User '" .. username .. "' tidak ditemukan!" })
        return false
    end
    AvatarCopier.CurrentCopiedUserId = userId
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    task.spawn(function()
        local okDesc, desc = pcall(function()
            return Players:GetHumanoidDescriptionFromUserId(userId)
        end)
        if not okDesc or not desc then
            Rayfield:Notify({ title = "Copy Avatar", content = "Gagal ambil deskripsi!" })
            return
        end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
                pcall(function() v:Destroy() end)
            end
        end
        task.wait(0.2)
        if AvatarCopier.BlockyBody then
            pcall(function()
                local bd = Instance.new("HumanoidDescription")
                bd.BodyTypeScale = 1; bd.DepthScale = 1; bd.HeadScale = 1
                bd.HeightScale = 1; bd.ProportionScale = 0; bd.WidthScale = 1
                bd.HeadColor = desc.HeadColor; bd.TorsoColor = desc.TorsoColor
                bd.LeftArmColor = desc.LeftArmColor; bd.RightArmColor = desc.RightArmColor
                bd.LeftLegColor = desc.LeftLegColor; bd.RightLegColor = desc.RightLegColor
                hum:ApplyDescriptionClientServer(bd)
            end)
            task.wait(0.5)
        end
        pcall(function() hum:ApplyDescriptionClientServer(desc) end)
        Rayfield:Notify({ title = "Copy Avatar", content = "Copy: " .. username .. " OK" })
    end)
    return true
end

local function resetAvatar()
    if not AvatarCopier.OriginalDescription then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
            pcall(function() v:Destroy() end)
        end
    end
    task.wait(0.1)
    pcall(function() hum:ApplyDescriptionClientServer(AvatarCopier.OriginalDescription) end)
    AvatarCopier.CurrentCopiedUserId = nil
    Rayfield:Notify({ title = "Reset Avatar", content = "Avatar original balik!" })
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1.5)
    if AvatarCopier.CurrentCopiedUserId then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local okDesc, desc = pcall(function()
                return Players:GetHumanoidDescriptionFromUserId(AvatarCopier.CurrentCopiedUserId)
            end)
            if okDesc and desc then
                pcall(function() hum:ApplyDescriptionClientServer(desc) end)
            end
        end
    end
end)

local LastVisualState = { Fullbright = nil, NoFog = nil, NoShadow = nil }
local ColorCorrection = nil
local LastOptimizationState = { LowGraphics = nil, CleanSky = nil }

local function applyVisual(force)
    pcall(function()
        if force or LastVisualState.Fullbright ~= Visual.Fullbright then
            LastVisualState.Fullbright = Visual.Fullbright
            if Visual.Fullbright then
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.Ambient = Color3.new(1, 1, 1)
                Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            else
                Lighting.Brightness = VisualOriginal.Brightness
                Lighting.ClockTime = VisualOriginal.ClockTime
                Lighting.Ambient = VisualOriginal.Ambient
                Lighting.OutdoorAmbient = VisualOriginal.OutdoorAmbient
            end
        end
        if force or LastVisualState.NoFog ~= Visual.NoFog then
            LastVisualState.NoFog = Visual.NoFog
            if Visual.NoFog then
                Lighting.FogEnd = 100000; Lighting.FogStart = 100000
            else
                Lighting.FogEnd = VisualOriginal.FogEnd
                Lighting.FogStart = VisualOriginal.FogStart
                Lighting.FogColor = VisualOriginal.FogColor
            end
        end
        if force or LastVisualState.NoShadow ~= Visual.NoShadow then
            LastVisualState.NoShadow = Visual.NoShadow
            Lighting.GlobalShadows = not Visual.NoShadow
        end
        if Visual.AmbientColorEnabled then
            Lighting.Ambient = Visual.AmbientColor
            Lighting.OutdoorAmbient = Visual.AmbientColor
        end
        if Visual.ClockTimeEnabled then
            Lighting.ClockTime = Visual.ClockTime
        end
        if Visual.FogControlEnabled then
            Lighting.FogEnd = Visual.FogEnd
            Lighting.FogStart = Visual.FogStart
            Lighting.FogColor = Visual.FogColor
        end
    end)
end

local function toggleScreenEffects()
    pcall(function()
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("SunRaysEffect") then v.Enabled = not Visual.NoBloom end
            if v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") then v.Enabled = not Visual.NoBlur end
        end
    end)
end

local function getOrCreateCC()
    if ColorCorrection and ColorCorrection.Parent then return ColorCorrection end
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("ColorCorrectionEffect") and v.Name == "TiarColorCorrection" then
            ColorCorrection = v
            return v
        end
    end
    ColorCorrection = Instance.new("ColorCorrectionEffect")
    ColorCorrection.Name = "TiarColorCorrection"
    ColorCorrection.Parent = Lighting
    ColorCorrection.Enabled = true
    return ColorCorrection
end

local function applyColorCorrection()
    local cc = getOrCreateCC()
    if not cc then return end
    cc.Saturation = Visual.Saturation or 0
    cc.Brightness = Visual.Brightness or 0
    cc.Contrast = Visual.Contrast or 0
    local shouldEnable = Visual.ColorCorrection
        or (Visual.Saturation and Visual.Saturation ~= 0)
        or (Visual.Brightness and Visual.Brightness ~= 0)
        or (Visual.Contrast and Visual.Contrast ~= 0)
    cc.Enabled = shouldEnable and true or false
end

local function resetColorCorrection()
    Visual.Saturation = 0
    Visual.Brightness = 0
    Visual.Contrast = 0
    local cc = getOrCreateCC()
    if cc then
        cc.Saturation = 0
        cc.Brightness = 0
        cc.Contrast = 0
    end
end

local function applyOptimization(force)
    if force or LastOptimizationState.LowGraphics ~= Visual.LowGraphics then
        LastOptimizationState.LowGraphics = Visual.LowGraphics
        pcall(function()
            if Visual.LowGraphics then
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            else
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            end
        end)
    end
    if force or LastOptimizationState.CleanSky ~= Visual.CleanSky then
        LastOptimizationState.CleanSky = Visual.CleanSky
        if Visual.CleanSky then
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("Sky") then v:Destroy() end
            end
        end
    end
end

local function applyCameraShake()
    pcall(function()
        if Visual.NoCameraShake then
            if workspace.CurrentCamera then
                workspace.CurrentCamera.CameraSubject = getHum() or workspace.CurrentCamera.CameraSubject
            end
        end
    end)
end

local function removeBlood()
    pcall(function()
        if Visual.NoBlood then
            for _, v in pairs(workspace:GetDescendants()) do
                local name = string.lower(v.Name)
                if (v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Trail"))
                   and (name:find("blood") or name:find("gore") or name:find("splat")) then
                    pcall(function()
                        if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1
                        else v.Enabled = false end
                    end)
                end
            end
        end
    end)
end

task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            applyVisual()
            toggleScreenEffects()
            applyColorCorrection()
            applyCameraShake()
            removeBlood()
            applyOptimization()
            if Moonwalk.Enabled then applyMoonwalkFOV() end
        end)
    end
end)

local function isRedSpark(obj)
    if not obj then return false end
    if not (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
            or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")) then
        return false
    end
    local name = string.lower(obj.Name)
    if name:find("parry") or name:find("spark") or name:find("blood")
       or name:find("slash") or name:find("hit") or name:find("impact") then
        return true
    end
    if obj:IsA("ParticleEmitter") then
        local ok, c = pcall(function() return obj.Color end)
        if ok and c and c.R > 0.5 and c.G < 0.4 and c.B < 0.4 then return true end
    end
    return false
end

local HideSparkConn = nil
local function startHideSpark()
    if HideSparkConn then return end
    for _, v in ipairs(workspace:GetDescendants()) do
        if isRedSpark(v) then
            HiddenSparkCache[v] = true
            pcall(function() v.Enabled = false; if v.Transparency then v.Transparency = 1 end end)
        end
    end
    HideSparkConn = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not HideSpark.Enabled then return end
            for _, v in ipairs(workspace:GetDescendants()) do
                if not HiddenSparkCache[v] and isRedSpark(v) then
                    HiddenSparkCache[v] = true
                    pcall(function() v.Enabled = false; if v.Transparency then v.Transparency = 1 end end)
                end
            end
        end)
    end)
end

local function stopHideSpark()
    if HideSparkConn then HideSparkConn:Disconnect(); HideSparkConn = nil end
    HiddenSparkCache = {}
end

local function findNearestByNames(names, maxDist)
    local root = getRoot()
    if not root then return nil, math.huge end
    local best, bestDist = nil, maxDist or math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            for _, target in ipairs(names) do
                if obj.Name == target or string.find(obj.Name, target, 1, true) then
                    local pos = GetPos(obj)
                    if pos then
                        local d = (pos - root.Position).Magnitude
                        if d < bestDist then bestDist = d; best = obj end
                    end
                    break
                end
            end
        end
    end
    return best, bestDist
end

local function teleportTo(obj)
    if not obj then return false end
    local now = tick()
    if now - Teleport.LastTeleport < Teleport.Cooldown then return false end
    Teleport.LastTeleport = now
    local root = getRoot()
    if not root then return false end
    local pos = GetPos(obj)
    if not pos then return false end
    pcall(function() root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0)) end)
    return true
end

local function teleportToGenerator() return teleportTo(findNearestByNames({"Generator", "GeneratorPoint"})) end
local function teleportToGate() return teleportTo(findNearestByNames({"Gate", "Exit", "ExitGate", "fininshline", "FinishLine"})) end
local function teleportToWindow() return teleportTo(findNearestByNames({"Window"})) end
local function teleportToPallet() return teleportTo(findNearestByNames({"Pallet", "Palletwrong"})) end
local function teleportToHook() return teleportTo(findNearestByNames({"HookPoint", "Hook"})) end

local function teleportToFinishLine()
    local root = getRoot()
    if not root then return false end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if string.lower(obj.Name) == "fininshline" and obj:IsA("BasePart") then
            root.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
            return true
        end
    end
    return false
end

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if not AutoEscape.Enabled then return end
            local root = getRoot()
            if not root then return end
            local killerRoot, dist = GetNearestKiller()
            if not killerRoot or dist > AutoEscape.DetectDistance then return end
            if tick() - AutoEscape.LastEscape < AutoEscape.Cooldown then return end
            local target = findNearestByNames({"Gate", "Exit", "ExitGate", "fininshline", "FinishLine"}, 1000)
            if not target then target = findNearestByNames({"Window"}, 500) end
            if not target then target = findNearestByNames({"Pallet", "Palletwrong"}, 500) end
            if not target then target = findNearestByNames({"Generator"}, 500) end
            if target then
                AutoEscape.LastEscape = tick()
                teleportTo(target)
            end
        end)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1.5)
    pcall(function()
        applyVisual(true)
        toggleScreenEffects()
        applyColorCorrection()
        applyOptimization(true)
        if Moonwalk.Enabled then
            task.wait(0.5)
            startMoonwalk()
            applyMoonwalkFOV()
        end
        if FakePerks.Flowstate.Enabled then
            hookFakeFlowstate(char)
        end
        if CameraZoom.UnlimitedZoom then applyUnlimitedZoom() end
        if CameraZoom.FOVEnabled then applyCameraFOV() end
    end)
end)

-- END BAGIAN 4-- ============================================
-- TIARHUB v20 - BAGIAN 5/5
-- UI Menu + Startup + Notifikasi
-- ============================================

-- ============ ESP TAB ============
local ESPTab = Window:CreateTab({ name = "ESP", icon = 0 })
ESPTab:CreateSection("Player ESP")
ESPTab:CreateToggle({ name = "ESP Survivor", currentValue = false, flag = "esp_survivor", callback = function(v) ESP.Survivor = v end })
ESPTab:CreateColorPicker({ name = "Survivor Color", color = ESP.SurvivorColor, flag = "esp_survivor_color", callback = function(c) ESP.SurvivorColor = c end })
ESPTab:CreateToggle({ name = "ESP Killer", currentValue = false, flag = "esp_killer", callback = function(v) ESP.Killer = v end })
ESPTab:CreateColorPicker({ name = "Killer Color", color = ESP.KillerColor, flag = "esp_killer_color", callback = function(c) ESP.KillerColor = c end })
ESPTab:CreateSection("Map ESP")
ESPTab:CreateToggle({ name = "ESP Generator (%)", currentValue = false, flag = "esp_generator", callback = function(v) ESP.Generator = v end })
ESPTab:CreateColorPicker({ name = "Generator Color", color = ESP.GeneratorColor, flag = "esp_gen_color", callback = function(c) ESP.GeneratorColor = c end })
ESPTab:CreateToggle({ name = "ESP Hook", currentValue = false, flag = "esp_hook", callback = function(v) ESP.Hook = v end })
ESPTab:CreateColorPicker({ name = "Hook Color", color = ESP.HookColor, flag = "esp_hook_color", callback = function(c) ESP.HookColor = c end })
ESPTab:CreateToggle({ name = "ESP Pallet", currentValue = false, flag = "esp_pallet", callback = function(v) ESP.Pallet = v end })
ESPTab:CreateColorPicker({ name = "Pallet Color", color = ESP.PalletColor, flag = "esp_pallet_color", callback = function(c) ESP.PalletColor = c end })
ESPTab:CreateToggle({ name = "ESP Window", currentValue = false, flag = "esp_window", callback = function(v) ESP.Window = v end })
ESPTab:CreateColorPicker({ name = "Window Color", color = ESP.WindowColor, flag = "esp_window_color", callback = function(c) ESP.WindowColor = c end })
ESPTab:CreateToggle({ name = "ESP SCP", currentValue = false, flag = "esp_scp", callback = function(v) ESP.SCP = v end })
ESPTab:CreateColorPicker({ name = "SCP Color", color = ESP.SCPColor, flag = "esp_scp_color", callback = function(c) ESP.SCPColor = c end })
ESPTab:CreateSection("Style")
ESPTab:CreateSlider({ name = "ESP Radius", range = {50, 2000}, increment = 50, suffix = "stud", currentValue = 300, flag = "esp_radius", callback = function(v) ESP.Distance = v end })
ESPTab:CreateDropdown({ name = "ESP Mode", options = {"Highlight", "Outline", "Fill"}, currentOption = "Highlight", flag = "esp_mode", callback = function(opt) ESP.Mode = opt end })
ESPTab:CreateToggle({ name = "Show Name Tag", currentValue = true, flag = "esp_name", callback = function(v) ESP.ShowName = v end })
ESPTab:CreateSlider({ name = "Name Size", range = {8, 30}, increment = 1, suffix = "px", currentValue = 14, flag = "esp_namesize", callback = function(v) ESP.NameSize = v end })
ESPTab:CreateSection("ESP Status")
ESPTab:CreateToggle({ name = "Enable Status ESP", currentValue = false, flag = "espstatus_on", callback = function(v) ESPStatus.Enabled = v end })
ESPTab:CreateToggle({ name = "Show Name", currentValue = true, flag = "espstatus_name", callback = function(v) ESPStatus.ShowName = v end })
ESPTab:CreateToggle({ name = "Show Distance", currentValue = true, flag = "espstatus_dist", callback = function(v) ESPStatus.ShowDistance = v end })
ESPTab:CreateToggle({ name = "Show Health", currentValue = false, flag = "espstatus_hp", callback = function(v) ESPStatus.ShowHealth = v end })
ESPTab:CreateSection("Killer Warning")
ESPTab:CreateToggle({ name = "Killer Warning", currentValue = false, flag = "kwarn_on", callback = function(v) KillerWarning.Enabled = v end })
ESPTab:CreateColorPicker({ name = "Warning Color", color = KillerWarning.Color, flag = "kwarn_color", callback = function(c) KillerWarning.Color = c end })
ESPTab:CreateSlider({ name = "Warning Distance", range = {20, 200}, increment = 5, suffix = "stud", currentValue = 60, flag = "kwarn_dist", callback = function(v) KillerWarning.Distance = v end })

-- ============ SURVIVOR TAB ============
local SurvivorTab = Window:CreateTab({ name = "Survivor", icon = 0 })
SurvivorTab:CreateSection("Auto Parry")
SurvivorTab:CreateToggle({ name = "Auto Parry", currentValue = false, flag = "parry_on", callback = function(v) Auto.Parry = v end })
SurvivorTab:CreateDropdown({ name = "Parry Mode", options = {"Safety", "Aggressive"}, currentOption = "Safety", flag = "parry_mode", callback = function(opt) Auto.ParryMode = opt; applyParryPreset(opt); Rayfield:Notify({ title = "Parry Mode", content = "Mode: " .. opt }) end })
SurvivorTab:CreateToggle({ name = "Show Parry Range (Smooth)", currentValue = false, flag = "parry_range", callback = function(v) ParryRangeVisual.Enabled = v end })
SurvivorTab:CreateToggle({ name = "Parry Rainbow Mode", currentValue = false, flag = "parry_rainbow", callback = function(v) ParryRangeVisual.RainbowMode = v end })
SurvivorTab:CreateToggle({ name = "Parry Pulse Effect", currentValue = true, flag = "parry_pulse", callback = function(v) ParryRangeVisual.PulseEnabled = v end })
SurvivorTab:CreateColorPicker({ name = "Parry Range Color", color = ParryRangeVisual.Color, flag = "parry_color", callback = function(c) ParryRangeVisual.Color = c end })
SurvivorTab:CreateSlider({ name = "Parry Circle Size", range = {5, 50}, increment = 1, suffix = "stud", currentValue = 12, flag = "parry_size", callback = function(v) Auto.ParryDistance = v end })
SurvivorTab:CreateSlider({ name = "Parry Range Transparency", range = {0, 1}, increment = 0.05, currentValue = 0.7, flag = "parry_trans", callback = function(v) ParryRangeVisual.Transparency = v end })

SurvivorTab:CreateSection("Auto Skill Check")
SurvivorTab:CreateToggle({ name = "Auto Skill Check", currentValue = false, flag = "skillcheck", callback = function(v) Auto.SkillCheck = v; if v then startSkillCheck() end end })
SurvivorTab:CreateDropdown({ name = "Skill Check Mode", options = {"Instant", "Perfect"}, currentOption = "Perfect", flag = "skill_mode", callback = function(opt) SkillCheckMode = opt; Rayfield:Notify({ title = "Skill Check", content = "Mode: " .. opt }) end })

SurvivorTab:CreateSection("Auto Wiggle / Flee")
SurvivorTab:CreateToggle({ name = "Auto Wiggle", currentValue = false, flag = "wiggle", callback = function(v) Auto.Wiggle = v end })
SurvivorTab:CreateSlider({ name = "Wiggle Spam", range = {1, 10}, increment = 1, suffix = "x", currentValue = 5, flag = "wiggle_spam", callback = function(v) Auto.WiggleSpam = v end })
SurvivorTab:CreateToggle({ name = "Auto Flee Killer", currentValue = false, flag = "flee", callback = function(v) AutoFlee.Enabled = v end })
SurvivorTab:CreateSlider({ name = "Flee Detect Distance", range = {10, 200}, increment = 5, suffix = "stud", currentValue = 50, flag = "flee_dist", callback = function(v) AutoFlee.DetectDistance = v end })

SurvivorTab:CreateSection("Fast Vault")
SurvivorTab:CreateToggle({ name = "Fast Vault", currentValue = false, flag = "vault", callback = function(v) FastVault.Enabled = v end })
SurvivorTab:CreateSlider({ name = "Animation Speed", range = {1, 5}, increment = 0.1, suffix = "x", currentValue = 1.2, flag = "vault_speed", callback = function(v) FastVault.Speed = v end })

SurvivorTab:CreateSection("Auto Dodge Abyss (Anti Dark Severance)")
SurvivorTab:CreateToggle({ name = "Enable Auto Dodge Abyss", currentValue = false, flag = "auto_dodge_abyss", callback = function(v) AutoDodgeAbyss.Enabled = v end })
SurvivorTab:CreateDropdown({ name = "Detect Mode", options = {"Anim", "Distance", "Both"}, currentOption = "Both", flag = "ad_abyss_mode", callback = function(opt) AutoDodgeAbyss.DetectMode = opt end })
SurvivorTab:CreateSlider({ name = "Detect Radius", range = {5, 100}, increment = 1, suffix = "stud", currentValue = 30, flag = "ad_abyss_range", callback = function(v) AutoDodgeAbyss.Radius = v end })
SurvivorTab:CreateSlider({ name = "Cooldown", range = {0.5, 10}, increment = 0.5, suffix = "s", currentValue = 2, flag = "ad_abyss_cd", callback = function(v) AutoDodgeAbyss.Cooldown = v end })
SurvivorTab:CreateSlider({ name = "Crouch Duration", range = {0.1, 2}, increment = 0.1, suffix = "s", currentValue = 0.3, flag = "ad_abyss_dur", callback = function(v) AutoDodgeAbyss.CrouchDuration = v end })

SurvivorTab:CreateSection("Fake Perks")
SurvivorTab:CreateToggle({ name = "Fake Flowstate (Speed Boost on Vault)", currentValue = false, flag = "fp_flow", callback = function(v) FakePerks.Flowstate.Enabled = v end })
SurvivorTab:CreateSlider({ name = "Flowstate Speed Boost (%)", range = {10, 50}, increment = 5, suffix = "%", currentValue = 20, flag = "fp_flow_speed", callback = function(v) FakePerks.Flowstate.SpeedBoost = v end })
SurvivorTab:CreateSlider({ name = "Flowstate Duration", range = {1, 10}, increment = 0.5, suffix = "s", currentValue = 3, flag = "fp_flow_dur", callback = function(v) FakePerks.Flowstate.Duration = v end })
SurvivorTab:CreateSlider({ name = "Flowstate Cooldown", range = {0, 70}, increment = 1, suffix = "s", currentValue = 10, flag = "fp_flow_cd", callback = function(v) FakePerks.Flowstate.Cooldown = v end })
SurvivorTab:CreateToggle({ name = "Fake Snake Step (Crouch Speed)", currentValue = false, flag = "fp_snake", callback = function(v) FakePerks.SnakeStep.Enabled = v end })
SurvivorTab:CreateSlider({ name = "Snake Step Speed", range = {16, 100}, increment = 1, currentValue = 90, flag = "fp_snake_speed", callback = function(v) FakePerks.SnakeStep.SpeedBoost = v end })
SurvivorTab:CreateSlider({ name = "Snake Step Cooldown", range = {0, 70}, increment = 1, suffix = "s", currentValue = 10, flag = "fp_snake_cd", callback = function(v) FakePerks.SnakeStep.Cooldown = v end })
SurvivorTab:CreateToggle({ name = "Fake Quick Recovery", currentValue = false, flag = "fp_recovery", callback = function(v) FakePerks.QuickRecovery.Enabled = v end })
SurvivorTab:CreateSlider({ name = "Quick Recovery Cooldown", range = {0, 70}, increment = 1, suffix = "s", currentValue = 10, flag = "fp_recovery_cd", callback = function(v) FakePerks.QuickRecovery.Cooldown = v end })

SurvivorTab:CreateSection("Aimbot Pistol (Survivor)")
SurvivorTab:CreateToggle({ name = "Aimbot Pistol (Hold RMB)", currentValue = false, flag = "aim_pistol", callback = function(v) GunAim.Enabled = v end })
SurvivorTab:CreateToggle({ name = "Show FOV Circle", currentValue = false, flag = "aim_fovcircle", callback = function(v) FOVCircleVisible = v; if v and not FOVCircle then createFOVCircle() end end })
SurvivorTab:CreateSlider({ name = "FOV Circle Size", range = {50, 1000}, increment = 10, suffix = "px", currentValue = 250, flag = "aim_fovsize", callback = function(v) FOVCircleSize = v end })
SurvivorTab:CreateColorPicker({ name = "FOV Circle Color", color = FOVCircleColor, flag = "aim_fovcolor", callback = function(c) FOVCircleColor = c end })
SurvivorTab:CreateToggle({ name = "Show Tracer", currentValue = false, flag = "aim_tracer", callback = function(v) GunAim.ShowTracer = v; if v and not TracerLine then createTracer() end end })
SurvivorTab:CreateColorPicker({ name = "Tracer Color", color = GunAim.TracerColor, flag = "aim_tracercolor", callback = function(c) GunAim.TracerColor = c; if TracerLine then TracerLine.Color = c end end })
SurvivorTab:CreateDropdown({ name = "Target", options = {"Killer", "Survivor", "Both"}, currentOption = "Killer", flag = "aim_target", callback = function(opt) GunAim.TargetMode = opt end })
SurvivorTab:CreateDropdown({ name = "Aim Part", options = {"Head", "HumanoidRootPart", "Torso"}, currentOption = "HumanoidRootPart", flag = "aim_part", callback = function(opt) GunAim.AimPart = opt end })
SurvivorTab:CreateSlider({ name = "Aimbot FOV", range = {50, 1000}, increment = 10, currentValue = 250, flag = "aim_fov", callback = function(v) GunAim.FOV = v end })
SurvivorTab:CreateSlider({ name = "Aimbot Smoothness", range = {0.1, 1}, increment = 0.05, currentValue = 1, flag = "aim_smooth", callback = function(v) GunAim.Strength = v end })
SurvivorTab:CreateSlider({ name = "Aimbot Prediction", range = {0, 1}, increment = 0.01, currentValue = 0.12, flag = "aim_predict", callback = function(v) GunAim.PredictStrength = v end })
SurvivorTab:CreateToggle({ name = "Visibility Check", currentValue = false, flag = "aim_vis", callback = function(v) GunAim.VisibilityCheck = v end })

-- ============ SILENT AIM TAB ============
local AimTab = Window:CreateTab({ name = "Silent Aim", icon = 0 })
AimTab:CreateSection("Silent Aim Veil Spear")
AimTab:CreateToggle({ name = "Enable Silent Aim Spear", currentValue = false, flag = "silent_spear", callback = function(v) SilentAimSpear.Enabled = v end })
AimTab:CreateToggle({ name = "Show Silent Aim FOV", currentValue = false, flag = "silent_fov", callback = function(v) SilentAimSpear.ShowFOV = v end })
AimTab:CreateDropdown({ name = "Silent Aim Target", options = {"Killer", "Survivor", "Both"}, currentOption = "Killer", flag = "silent_target", callback = function(opt) SilentAimSpear.TargetMode = opt end })
AimTab:CreateDropdown({ name = "Silent Aim Part", options = {"Head", "HumanoidRootPart", "Torso"}, currentOption = "HumanoidRootPart", flag = "silent_part", callback = function(opt) SilentAimSpear.AimPart = opt end })
AimTab:CreateSlider({ name = "Silent Aim FOV", range = {50, 1000}, increment = 10, currentValue = 250, flag = "silent_fov_val", callback = function(v) SilentAimSpear.FOV = v end })
AimTab:CreateSlider({ name = "Silent Aim Prediction", range = {0, 1}, increment = 0.01, currentValue = 0.12, flag = "silent_pred", callback = function(v) SilentAimSpear.Prediction = v end })

AimTab:CreateSection("Hit Marker")
AimTab:CreateToggle({ name = "Enable Hit Marker", currentValue = false, flag = "hm_on", callback = function(v) HitMarker.Enabled = v; if v and #HitMarkerLines == 0 then createHitMarkerLines() end end })
AimTab:CreateColorPicker({ name = "Hit Marker Color", color = HitMarker.Color, flag = "hm_color", callback = function(c) HitMarker.Color = c end })
AimTab:CreateSlider({ name = "Hit Marker Size", range = {5, 50}, increment = 1, suffix = "px", currentValue = 20, flag = "hm_size", callback = function(v) HitMarker.Size = v end })
AimTab:CreateSlider({ name = "Hit Marker Thickness", range = {1, 5}, increment = 1, suffix = "px", currentValue = 2, flag = "hm_thick", callback = function(v) HitMarker.Thickness = v end })

AimTab:CreateSection("Aimlock Button (On-Screen)")
AimTab:CreateToggle({ name = "Show Aimlock Button", currentValue = false, flag = "alb_show", callback = function(v) AimlockButton.Enabled = v; if v then createAimlockButton() else removeAimlockButton() end end })
AimTab:CreateToggle({ name = "Show Aimlock Circle", currentValue = true, flag = "alb_circle", callback = function(v) AimlockButton.ShowCircle = v end })
AimTab:CreateDropdown({ name = "Aimlock Target", options = {"Killer", "Survivor", "Both"}, currentOption = "Killer", flag = "alb_target", callback = function(opt) AimlockButton.TargetMode = opt end })
AimTab:CreateDropdown({ name = "Aimlock Part", options = {"Head", "HumanoidRootPart", "Torso"}, currentOption = "HumanoidRootPart", flag = "alb_part", callback = function(opt) AimlockButton.AimPart = opt end })
AimTab:CreateSlider({ name = "Aimlock Radius", range = {50, 1000}, increment = 10, suffix = "px", currentValue = 250, flag = "alb_radius", callback = function(v) AimlockButton.Radius = v end })
AimTab:CreateSlider({ name = "Aimlock Strength", range = {0.1, 1}, increment = 0.05, currentValue = 0.4, flag = "alb_strength", callback = function(v) AimlockButton.Strength = v end })
AimTab:CreateSlider({ name = "Aimlock Prediction", range = {0, 1}, increment = 0.01, currentValue = 0.12, flag = "alb_predict", callback = function(v) AimlockButton.Predict = v end })
AimTab:CreateColorPicker({ name = "Aimlock Circle Color", color = AimlockButton.CircleColor, flag = "alb_color", callback = function(c) AimlockButton.CircleColor = c end })

-- ============ KILLER TAB ============
local KillerTab = Window:CreateTab({ name = "Killer", icon = 0 })
KillerTab:CreateSection("Attack")
KillerTab:CreateToggle({ name = "Auto Attack", currentValue = false, flag = "k_attack", callback = function(v) Killer.AutoAttack = v end })
KillerTab:CreateSlider({ name = "Attack Delay", range = {0.1, 2}, increment = 0.05, suffix = "s", currentValue = 0.45, flag = "k_atk_delay", callback = function(v) Killer.AttackDelay = v end })
KillerTab:CreateToggle({ name = "Auto Kill All", currentValue = false, flag = "k_killall", callback = function(v) Killer.KillAll = v end })
KillerTab:CreateToggle({ name = "Prediction Attack", currentValue = false, flag = "k_predict", callback = function(v) Killer.PredictionAttack = v end })
KillerTab:CreateSlider({ name = "Prediction Strength", range = {0, 1}, increment = 0.05, currentValue = 0.15, flag = "k_predict_str", callback = function(v) Killer.PredictStrength = v end })

KillerTab:CreateSection("Aimbot Killer (Lock saat Hit)")
KillerTab:CreateToggle({ name = "Killer Aim Lock", currentValue = false, flag = "kaim_on", callback = function(v) KillerAim.Enabled = v end })
KillerTab:CreateSlider({ name = "Killer Aim FOV", range = {50, 500}, increment = 10, currentValue = 200, flag = "kaim_fov", callback = function(v) KillerAim.FOV = v end })
KillerTab:CreateSlider({ name = "Killer Aim Smoothness", range = {0.1, 1}, increment = 0.05, currentValue = 0.5, flag = "kaim_smooth", callback = function(v) KillerAim.Strength = v end })

KillerTab:CreateSection("Carry & Hook")
KillerTab:CreateToggle({ name = "Auto Carry Downed", currentValue = false, flag = "k_carry", callback = function(v) Killer.AutoCarry = v end })
KillerTab:CreateToggle({ name = "Auto Hook After Carry", currentValue = false, flag = "k_hook", callback = function(v) Killer.AutoHook = v end })
KillerTab:CreateToggle({ name = "Auto Hook All Downed", currentValue = false, flag = "k_hookall", callback = function(v) Killer.AutoHookAllDowned = v end })
KillerTab:CreateSlider({ name = "Hook All Range", range = {100, 2000}, increment = 50, suffix = "stud", currentValue = 500, flag = "k_hookall_range", callback = function(v) Killer.AutoHookAllRange = v end })

KillerTab:CreateSection("Auto Sprint")
KillerTab:CreateToggle({ name = "Auto Sprint", currentValue = false, flag = "k_sprint", callback = function(v) Killer.AutoSprint = v end })
KillerTab:CreateSlider({ name = "Sprint Speed", range = {16, 100}, increment = 1, currentValue = 30, flag = "k_sprint_val", callback = function(v) Killer.AutoSprintValue = v end })

KillerTab:CreateSection("Auto Face Target")
KillerTab:CreateToggle({ name = "Auto Face Survivor", currentValue = false, flag = "k_face", callback = function(v) Killer.AutoFaceTarget = v end })
KillerTab:CreateSlider({ name = "Face Range", range = {5, 100}, increment = 5, suffix = "stud", currentValue = 20, flag = "k_face_range", callback = function(v) Killer.AutoFaceRange = v end })

KillerTab:CreateSection("Chase Detector")
KillerTab:CreateToggle({ name = "Chase Alert", currentValue = false, flag = "k_chase", callback = function(v) ChaseDetector.Enabled = v end })
KillerTab:CreateSlider({ name = "Chase Range", range = {10, 200}, increment = 5, suffix = "stud", currentValue = 30, flag = "k_chase_range", callback = function(v) ChaseDetector.Range = v end })
KillerTab:CreateSlider({ name = "Chase Cooldown", range = {0.5, 10}, increment = 0.5, suffix = "s", currentValue = 2, flag = "k_chase_cd", callback = function(v) ChaseDetector.Cooldown = v end })

KillerTab:CreateSection("Stalk")
KillerTab:CreateToggle({ name = "Auto Stalk", currentValue = false, flag = "k_stalk", callback = function(v) Killer.AutoStalk = v; if v then startAutoStalk() else stopAutoStalk() end end })
KillerTab:CreateSlider({ name = "Stalk Range", range = {50, 500}, increment = 10, suffix = "stud", currentValue = 150, flag = "k_stalk_range", callback = function(v) Killer.StalkRange = v end })

KillerTab:CreateSection("Masked Power")
KillerTab:CreateDropdown({ name = "Select Power", options = MaskedPowers, currentOption = "Cobra", flag = "k_masked", callback = function(opt) Masked.CurrentPower = opt end })
KillerTab:CreateButton({ name = "Activate Power", callback = activateMasked })
KillerTab:CreateButton({ name = "Deactivate Power", callback = deactivateMasked })

-- ============ TELEPORT TAB ============
local TeleportTab = Window:CreateTab({ name = "Teleport", icon = 0 })
TeleportTab:CreateSection("Teleport Cepat")
TeleportTab:CreateButton({ name = "Teleport ke Generator", callback = function()
    if teleportToGenerator() then Rayfield:Notify({ title = "Teleport", content = "Ke Generator OK" })
    else Rayfield:Notify({ title = "Teleport", content = "Generator tidak ditemukan" }) end
end })
TeleportTab:CreateButton({ name = "Teleport ke Gate / Exit", callback = function()
    if teleportToGate() then Rayfield:Notify({ title = "Teleport", content = "Ke Gate OK" })
    else Rayfield:Notify({ title = "Teleport", content = "Gate tidak ditemukan" }) end
end })
TeleportTab:CreateButton({ name = "Teleport ke Window", callback = function()
    if teleportToWindow() then Rayfield:Notify({ title = "Teleport", content = "Ke Window OK" })
    else Rayfield:Notify({ title = "Teleport", content = "Window tidak ditemukan" }) end
end })
TeleportTab:CreateButton({ name = "Teleport ke Pallet", callback = function()
    if teleportToPallet() then Rayfield:Notify({ title = "Teleport", content = "Ke Pallet OK" })
    else Rayfield:Notify({ title = "Teleport", content = "Pallet tidak ditemukan" }) end
end })
TeleportTab:CreateButton({ name = "Teleport ke Hook", callback = function()
    if teleportToHook() then Rayfield:Notify({ title = "Teleport", content = "Ke Hook OK" })
    else Rayfield:Notify({ title = "Teleport", content = "Hook tidak ditemukan" }) end
end })
TeleportTab:CreateButton({ name = "Instant Escape (Finish Line)", callback = function()
    if teleportToFinishLine() then Rayfield:Notify({ title = "Teleport", content = "Ke Finish Line OK" })
    else Rayfield:Notify({ title = "Teleport", content = "Finish Line tidak ditemukan" }) end
end })
TeleportTab:CreateSection("Auto Escape")
TeleportTab:CreateToggle({ name = "Auto Escape (Kabur dari Killer)", currentValue = false, flag = "auto_escape", callback = function(v) AutoEscape.Enabled = v end })
TeleportTab:CreateSlider({ name = "Detect Distance", range = {10, 200}, increment = 5, suffix = "stud", currentValue = 40, flag = "escape_dist", callback = function(v) AutoEscape.DetectDistance = v end })
TeleportTab:CreateSlider({ name = "Cooldown", range = {0.2, 3}, increment = 0.1, suffix = "s", currentValue = 0.8, flag = "escape_cd", callback = function(v) AutoEscape.Cooldown = v end })

-- ============ AVATAR TAB ============
local AvatarTab = Window:CreateTab({ name = "Avatar", icon = 0 })
AvatarTab:CreateSection("Copy Avatar")
AvatarTab:CreateInput({ name = "Target Username", currentValue = "", placeholder = "Ketik username (tanpa @)", flag = "av_username", callback = function(v) AvatarCopier.TargetUsername = v end })
AvatarTab:CreateButton({ name = "Copy Avatar", callback = function() copyAvatar(AvatarCopier.TargetUsername) end })
AvatarTab:CreateButton({ name = "Reset to Original", callback = function() resetAvatar() end })
AvatarTab:CreateButton({ name = "Save Current as Original", callback = function()
    if saveOriginalAppearance() then Rayfield:Notify({ title = "Save Avatar", content = "Avatar original disimpan!" })
    else Rayfield:Notify({ title = "Save Avatar", content = "Gagal simpan avatar!" }) end
end })
AvatarTab:CreateSection("Setting")
AvatarTab:CreateToggle({ name = "Blocky Body (R6 Style)", currentValue = true, flag = "av_blocky", callback = function(v) AvatarCopier.BlockyBody = v end })

-- ============ MISC TAB ============
local MiscTab = Window:CreateTab({ name = "Misc", icon = 0 })
MiscTab:CreateSection("Walk Speed")
MiscTab:CreateToggle({ name = "Enable Walk Speed", currentValue = false, flag = "m_ws", callback = function(v) Movement.WalkSpeedEnabled = v; if v then applyWalkSpeed() else local hum = getHum(); if hum then hum.WalkSpeed = Movement.OriginalWalkSpeed end end end })
MiscTab:CreateSlider({ name = "Walk Speed Value", range = {16, 100}, increment = 0.5, currentValue = 17.6, flag = "m_ws_val", callback = function(v) Movement.WalkSpeedValue = v end })
MiscTab:CreateSection("No Clip")
MiscTab:CreateToggle({ name = "No Clip", currentValue = false, flag = "m_noclip", callback = function(v) toggleNoClip(v) end })
MiscTab:CreateSection("Anti KnockDown / GodMode")
MiscTab:CreateToggle({ name = "Anti KnockDown (GodMode)", currentValue = false, flag = "m_god", callback = function(v) PlayerMods.GodMode = v end })

MiscTab:CreateSection("Moonwalk")
MiscTab:CreateToggle({ name = "Moonwalk", currentValue = false, flag = "m_moonwalk", callback = function(v) Moonwalk.Enabled = v; if v then startMoonwalk(); applyMoonwalkFOV() else stopMoonwalk() end end })
MiscTab:CreateDropdown({ name = "Moonwalk Mode", options = {"Default", "Camera"}, currentOption = "Default", flag = "m_moon_mode", callback = function(opt)
    Moonwalk.Mode = opt
    Rayfield:Notify({ title = "Moonwalk Mode", content = "Mode: " .. opt })
end })
MiscTab:CreateDropdown({ name = "Moonwalk FOV", options = {"70", "90", "120"}, currentOption = "90", flag = "m_moon_fov", callback = function(opt)
    Moonwalk.FOVPreset = tonumber(opt)
    if Moonwalk.Enabled then applyMoonwalkFOV() end
end })
MiscTab:CreateToggle({ name = "Moonwalk Button", currentValue = false, flag = "m_moonwalk_btn", callback = function(v) Moonwalk.ShowButton = v; if v then createMoonwalkButton() else removeMoonwalkButton() end end })
MiscTab:CreateSlider({ name = "Spam Speed", range = {1, 50}, increment = 1, currentValue = 30, flag = "m_moon_spam", callback = function(v) Moonwalk.SpamSpeed = v end })
MiscTab:CreateSlider({ name = "Intensity", range = {1, 50}, increment = 1, currentValue = 35, flag = "m_moon_int", callback = function(v) Moonwalk.Intensity = v end })

MiscTab:CreateSection("Emote")
MiscTab:CreateDropdown({ name = "Select Emote", options = EmoteList, currentOption = "Mannrobics", flag = "m_emote", callback = function(opt) Emote.Selected = opt end })
MiscTab:CreateButton({ name = "Play Emote", callback = function() playEmote(Emote.Selected) end })

-- ============ VISUAL TAB ============
local VisualTab = Window:CreateTab({ name = "Visual", icon = 0 })
VisualTab:CreateSection("Lighting")
VisualTab:CreateToggle({ name = "Fullbright", currentValue = false, flag = "v_fb", callback = function(v) Visual.Fullbright = v; applyVisual(true) end })
VisualTab:CreateToggle({ name = "No Fog", currentValue = false, flag = "v_nofog", callback = function(v) Visual.NoFog = v; applyVisual(true) end })
VisualTab:CreateToggle({ name = "No Shadow", currentValue = false, flag = "v_noshadow", callback = function(v) Visual.NoShadow = v; applyVisual(true) end })
VisualTab:CreateSection("Ambient & Time")
VisualTab:CreateToggle({ name = "Custom Ambient Color", currentValue = false, flag = "v_ambient", callback = function(v) Visual.AmbientColorEnabled = v; applyVisual(true) end })
VisualTab:CreateColorPicker({ name = "Ambient Color", color = Visual.AmbientColor, flag = "v_ambient_color", callback = function(c) Visual.AmbientColor = c; applyVisual(true) end })
VisualTab:CreateToggle({ name = "Custom Clock Time", currentValue = false, flag = "v_clock", callback = function(v) Visual.ClockTimeEnabled = v; applyVisual(true) end })
VisualTab:CreateSlider({ name = "Clock Time", range = {0, 24}, increment = 1, currentValue = 14, flag = "v_clock_val", callback = function(v) Visual.ClockTime = v; applyVisual(true) end })
VisualTab:CreateSection("Fog Control")
VisualTab:CreateToggle({ name = "Custom Fog", currentValue = false, flag = "v_fog", callback = function(v) Visual.FogControlEnabled = v; applyVisual(true) end })
VisualTab:CreateSlider({ name = "Fog End", range = {0, 100000}, increment = 100, currentValue = 100000, flag = "v_fog_end", callback = function(v) Visual.FogEnd = v; applyVisual(true) end })
VisualTab:CreateSlider({ name = "Fog Start", range = {0, 100000}, increment = 100, currentValue = 0, flag = "v_fog_start", callback = function(v) Visual.FogStart = v; applyVisual(true) end })
VisualTab:CreateColorPicker({ name = "Fog Color", color = Visual.FogColor, flag = "v_fog_color", callback = function(c) Visual.FogColor = c; applyVisual(true) end })
VisualTab:CreateSection("Screen Effects")
VisualTab:CreateToggle({ name = "No Bloom", currentValue = false, flag = "v_nobloom", callback = function(v) Visual.NoBloom = v; toggleScreenEffects() end })
VisualTab:CreateToggle({ name = "No Blur / DOF", currentValue = false, flag = "v_noblur", callback = function(v) Visual.NoBlur = v; toggleScreenEffects() end })
VisualTab:CreateToggle({ name = "No Camera Shake", currentValue = false, flag = "v_noshake", callback = function(v) Visual.NoCameraShake = v; applyCameraShake() end })
VisualTab:CreateToggle({ name = "No Blood", currentValue = false, flag = "v_noblood", callback = function(v) Visual.NoBlood = v; removeBlood() end })

VisualTab:CreateSection("Graphics Optimization")
VisualTab:CreateToggle({ name = "Low Graphics", currentValue = false, flag = "v_lowgfx", callback = function(v) Visual.LowGraphics = v; applyOptimization(true) end })
VisualTab:CreateToggle({ name = "Clean Sky", currentValue = false, flag = "v_cleansky", callback = function(v) Visual.CleanSky = v; applyOptimization(true) end })

VisualTab:CreateSection("Color Correction")
VisualTab:CreateToggle({ name = "Enable Color Correction", currentValue = false, flag = "v_cc", callback = function(v) Visual.ColorCorrection = v; applyColorCorrection() end })
VisualTab:CreateSlider({ name = "Saturation", range = {-1, 1}, increment = 0.05, currentValue = 0, flag = "v_sat", callback = function(v) Visual.Saturation = v; applyColorCorrection() end })
VisualTab:CreateSlider({ name = "Brightness", range = {-1, 1}, increment = 0.05, currentValue = 0, flag = "v_bright", callback = function(v) Visual.Brightness = v; applyColorCorrection() end })
VisualTab:CreateSlider({ name = "Contrast", range = {-1, 1}, increment = 0.05, currentValue = 0, flag = "v_contrast", callback = function(v) Visual.Contrast = v; applyColorCorrection() end })
VisualTab:CreateButton({ name = "Reset Color", callback = function()
    resetColorCorrection()
    Rayfield:Notify({ title = "Color Reset", content = "Saturation, Brightness, Contrast di-reset ke 0." })
end })

VisualTab:CreateSection("Camera")
VisualTab:CreateToggle({ name = "Unlimited Zoom Out", currentValue = false, flag = "v_zoom", callback = function(v) CameraZoom.UnlimitedZoom = v; applyUnlimitedZoom() end })
VisualTab:CreateSlider({ name = "Max Zoom Distance", range = {100, 5000}, increment = 50, currentValue = 1000, flag = "v_zoom_max", callback = function(v) CameraZoom.MaxDistance = v; if CameraZoom.UnlimitedZoom then applyUnlimitedZoom() end end })
VisualTab:CreateToggle({ name = "Custom FOV", currentValue = false, flag = "v_fov", callback = function(v) CameraZoom.FOVEnabled = v; applyCameraFOV() end })
VisualTab:CreateSlider({ name = "Camera FOV", range = {40, 120}, increment = 1, currentValue = 70, flag = "v_fov_val", callback = function(v) CameraZoom.FOV = v; if CameraZoom.FOVEnabled then applyCameraFOV() end end })

VisualTab:CreateSection("Effect")
VisualTab:CreateToggle({ name = "Hide Red Spark", currentValue = false, flag = "v_hide_spark", callback = function(v) HideSpark.Enabled = v; if v then startHideSpark() else stopHideSpark() end end })

-- ============ ANTI-LAG TAB ============
local AntiLagTab = Window:CreateTab({ name = "Anti-Lag", icon = 0 })
AntiLagTab:CreateSection("Anti-Lag Pack")
AntiLagTab:CreateToggle({ name = "Enable Anti-Lag", currentValue = false, flag = "al_on", callback = function(v) AntiLag.Enabled = v end })
AntiLagTab:CreateSection("Individual")
AntiLagTab:CreateToggle({ name = "No Particles", currentValue = false, flag = "al_particles", callback = function(v) AntiLag.NoParticles = v end })
AntiLagTab:CreateToggle({ name = "No Textures", currentValue = false, flag = "al_textures", callback = function(v) AntiLag.NoTextures = v end })
AntiLagTab:CreateToggle({ name = "Physics Throttle", currentValue = false, flag = "al_physics", callback = function(v) AntiLag.PhysicsThrottle = v end })
AntiLagTab:CreateToggle({ name = "No Global Shadows", currentValue = false, flag = "al_shadows", callback = function(v) AntiLag.NoGlobalShadows = v end })
AntiLagTab:CreateToggle({ name = "Network Replication Lag", currentValue = false, flag = "al_net", callback = function(v) AntiLag.NetworkLag = v end })

-- ============ CROSSHAIR TAB ============
local CrosshairTab = Window:CreateTab({ name = "Crosshair", icon = 0 })
CrosshairTab:CreateToggle({ name = "Enable Crosshair", currentValue = false, flag = "ch_on", callback = function(v) Crosshair.Enabled = v end })
CrosshairTab:CreateDropdown({ name = "Style", options = {"Plus", "Dot", "Circle"}, currentOption = "Plus", flag = "ch_style", callback = function(opt) Crosshair.Style = opt end })
CrosshairTab:CreateColorPicker({ name = "Color", color = Crosshair.Color, flag = "ch_color", callback = function(c) Crosshair.Color = c end })
CrosshairTab:CreateSlider({ name = "Size", range = {2, 30}, increment = 1, suffix = "px", currentValue = 8, flag = "ch_size", callback = function(v) Crosshair.Size = v end })
CrosshairTab:CreateSlider({ name = "Thickness", range = {1, 5}, increment = 1, suffix = "px", currentValue = 2, flag = "ch_thick", callback = function(v) Crosshair.Thickness = v end })
CrosshairTab:CreateSlider({ name = "Position X", range = {-100, 100}, increment = 1, suffix = "px", currentValue = 0, flag = "ch_x", callback = function(v) Crosshair.OffsetX = v end })
CrosshairTab:CreateSlider({ name = "Position Y", range = {-100, 100}, increment = 1, suffix = "px", currentValue = 0, flag = "ch_y", callback = function(v) Crosshair.OffsetY = v end })

-- ============ UI SETTINGS TAB ============
local UISettingsTab = Window:CreateTab({ name = "UI Settings", icon = 0 })
UISettingsTab:CreateSection("FPS / Ping Overlay")
UISettingsTab:CreateToggle({ name = "Show FPS/Ping Overlay", currentValue = true, flag = "fps_overlay", callback = function(v) FPSOverlay.Enabled = v end })

UISettingsTab:CreateSection("Sound Feedback")
UISettingsTab:CreateToggle({ name = "Enable Click Sound", currentValue = true, flag = "sf_on", callback = function(v) SoundFeedback.Enabled = v end })
UISettingsTab:CreateDropdown({ name = "Sound Type", options = {"Click", "Switch", "Beep", "Bell", "Whoosh"}, currentOption = "Click", flag = "sf_type", callback = function(opt)
    SoundFeedback.CurrentSound = opt
    playClickSound()
end })
UISettingsTab:CreateSlider({ name = "Volume", range = {0, 1}, increment = 0.05, currentValue = 0.5, flag = "sf_vol", callback = function(v)
    SoundFeedback.Volume = v
    if SoundInstance then SoundInstance.Volume = v end
    playClickSound()
end })
UISettingsTab:CreateButton({ name = "Test Sound", callback = function()
    playClickSound()
    Rayfield:Notify({ title = "Sound", content = "Sound: " .. SoundFeedback.CurrentSound })
end })

UISettingsTab:CreateSection("Sasuke Background")
UISettingsTab:CreateButton({ name = "Toggle Sasuke BG", callback = function()
    BGImage.Visible = not BGImage.Visible
    Rayfield:Notify({ title = "Sasuke BG", content = BGImage.Visible and "Ditampilkan" or "Disembunyikan" })
end })
UISettingsTab:CreateButton({ name = "Cara Ganti Gambar", callback = function()
    Rayfield:Notify({
        title = "Cara Ganti BG",
        content = "Buka script, cari 'SASUKE_BG_ID' di BAGIAN 1, ganti dengan 'rbxassetid://ID_KAMU'.",
        duration = 10
    })
end })

-- ============ SOUND WRAPPER ============
local function wrapCallbacks()
    local origToggle = Window.CreateToggle
    local origButton = Window.CreateButton
    local origDropdown = Window.CreateDropdown
    local origSlider = Window.CreateSlider

    if origToggle then
        Window.CreateToggle = function(self, config)
            if config and config.callback then
                local cb = config.callback
                config.callback = function(...)
                    pcall(function() playClickSound() end)
                    return cb(...)
                end
            end
            return origToggle(self, config)
        end
    end
    if origButton then
        Window.CreateButton = function(self, config)
            if config and config.callback then
                local cb = config.callback
                config.callback = function(...)
                    pcall(function() playClickSound() end)
                    return cb(...)
                end
            end
            return origButton(self, config)
        end
    end
    if origDropdown then
        Window.CreateDropdown = function(self, config)
            if config and config.callback then
                local cb = config.callback
                config.callback = function(...)
                    pcall(function() playClickSound() end)
                    return cb(...)
                end
            end
            return origDropdown(self, config)
        end
    end
    if origSlider then
        Window.CreateSlider = function(self, config)
            if config and config.callback then
                local cb = config.callback
                config.callback = function(...)
                    pcall(function() playClickSound() end)
                    return cb(...)
                end
            end
            return origSlider(self, config)
        end
    end
end

pcall(wrapCallbacks)

-- ============ STARTUP ============
task.wait(0.5)
pcall(function() applyParryPreset(Auto.ParryMode) end)
pcall(function() if Auto.SkillCheck then startSkillCheck() end end)
pcall(function() applyVisual(true) end)
pcall(function() applyOptimization(true) end)
pcall(function() createFPSOverlay() end)

-- ============ NOTIFIKASI ============
task.wait(1)
Rayfield:Notify({
    title = "TiarHub v20",
    content = "Script loaded! Semua fitur siap dipakai.",
    duration = 8
})

task.wait(2)
Rayfield:Notify({
    title = "Fitur Baru",
    content = "Auto Dodge Abyss + Aimlock Button + Sasuke BG + FPS Overlay",
    duration = 8
})

task.wait(2)
Rayfield:Notify({
    title = "Tips",
    content = "Aimlock Button: drag tombol di layar, klik untuk lock target. Radius bisa diubah di tab Silent Aim.",
    duration = 8
})

task.wait(2)
Rayfield:Notify({
    title = "Sasuke Background",
    content = "Ganti SASUKE_BG_ID di BAGIAN 1 dengan asset ID gambar kamu.",
    duration = 10
})

-- ============ PRINT STATUS ============
print("============================================")
print("  TIARHUB v20 - ALL LOADED")
print("  ==========================================")
print("  [OK] ESP System + Killer Warning")
print("  [OK] Parry Circle SMOOTH (lerp)")
print("  [OK] Auto Parry (2 Mode)")
print("  [OK] Skill Check (Instant/Perfect)")
print("  [OK] Auto Dodge Abyss (Anti Dark Severance)")
print("  [OK] Fake Perks + Cooldown 0-70s")
print("  [OK] Silent Aim Veil Spear")
print("  [OK] Aimbot Pistol (Tab Survivor)")
print("  [OK] Aimbot Killer (Tab Killer)")
print("  [OK] Aimlock Button (On-Screen + Drag)")
print("  [OK] Hit Marker")
print("  [OK] Killer System + Attack Delay")
print("  [OK] Anti KnockDown / GodMode")
print("  [OK] Movement + Moonwalk + FOV")
print("  [OK] Camera Zoom Out + Custom FOV")
print("  [OK] Crosshair Style (Plus/Dot/Circle)")
print("  [OK] Copy Avatar")
print("  [OK] Teleport + Instant Escape")
print("  [OK] Visual + Low Graphics + Clean Sky")
print("  [OK] Anti-Lag + Hide Spark")
print("  [OK] FPS/Ping Overlay")
print("  [OK] Sasuke Background (Placeholder)")
print("  [OK] Rainbow UI + Nama Tebal")
print("  ==========================================")
print("  Violence District | by Tiar | v20")
print("============================================")

-- END BAGIAN 5
-- SC TIARHUB v20 SELESAI
