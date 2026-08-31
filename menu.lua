-- TH ULTRA BOOST v3 - By TiarHub
local g = Instance.new("ScreenGui", game.CoreGui)
g.Name="TH_Ultra" g.ResetOnSpawn=false

local b = Instance.new("TextButton", g)
b.Size=UDim2.new(0,32,0,32) b.Position=UDim2.new(0,10,0.45,0)
b.Text="TH" b.Font=Enum.Font.GothamBlack b.TextSize=11 b.TextColor3=Color3.new(1,1,1)
b.Active=true b.Draggable=true
Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
task.spawn(function() while b.Parent do for i=0,1,0.02 do b.BackgroundColor3=Color3.fromHSV(i,1,1) task.wait() end end end)

local f = Instance.new("Frame", g)
f.Size=UDim2.new(0,130,0,150) f.Position=UDim2.new(0.5,-65,0.5,-75)
f.Visible=false f.Active=true f.Draggable=true f.BackgroundColor3=Color3.fromRGB(8,8,15)
f.BorderSizePixel=0
Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
local s = Instance.new("UIStroke",f) s.Thickness=1.5 s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
task.spawn(function() while f.Parent do for i=0,1,0.02 do s.Color=Color3.fromHSV(i,1,1) task.wait() end end end)

local function title(t,y)
 local l=Instance.new("TextLabel",f) l.Size=UDim2.new(0,114,0,18) l.Position=UDim2.new(0,8,0,y)
 l.Text=t l.Font=Enum.Font.GothamBlack l.TextSize=12 l.TextColor3=Color3.new(1,1,1) l.BackgroundTransparency=1 return l
end
title("TH ULTRA BOOST",8)

local on=false
local function ultra()
 local L=game.Lighting
 -- FULL BRIGHT + NO FOG
 L.Ambient=Color3.new(1,1,1) L.OutdoorAmbient=Color3.new(1,1,1)
 L.Brightness=3 L.ClockTime=14 L.GeographicLatitude=0
 L.FogStart=1000000 L.FogEnd=1000000 L.FogColor=Color3.new(1,1,1)
 L.GlobalShadows=false L.ShadowSoftness=0 L.ExposureCompensation=0.5
 -- Hapus semua efek berat
 for _,v in pairs(L:GetChildren()) do
  if v:IsA("PostEffect") or v:IsA("Atmosphere") then v:Destroy() end
 end
 -- ANTI LAG EXTREME
 settings().Rendering.QualityLevel=1
 local ter=workspace:FindFirstChildOfClass("Terrain")
 if ter then ter.WaterWaveSize=0 ter.WaterWaveSpeed=0 ter.WaterReflectance=0 ter.WaterTransparency=0 end
 for _,v in pairs(workspace:GetDescendants()) do
  if v:IsA("BasePart") then
   v.Material=Enum.Material.SmoothPlastic v.Reflectance=0 v.CastShadow=false
  elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1
  elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled=false
  elseif v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then v:Destroy()
  elseif v:IsA("MeshPart") then v.TextureID="" v.Render
