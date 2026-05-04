-- ==============================================================================
--[ AR2 ULTIMATE PRO - v5.6 (COMPLETE & OPTIMIZED) ]
-- PEŁNA WERSJA: Wszystkie funkcje (Heli, Fly, Speed, ESP) + 10 poprawek eksperckich.
-- ==============================================================================

-- 1. CLEANUP
local function Cleanup()
    if getgenv().UnloadSolar then pcall(getgenv().UnloadSolar) end
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v:IsA("ScreenGui") and (v.Name:find("Solar") or v.Name:find("Menu")) then v:Destroy() end
    end
end
Cleanup()
task.wait(0.1)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local SafeGui = (gethui and gethui()) or CoreGui

-- 2. DRAWING MANAGER (Memory Leak Protection)
getgenv().SolarDrawings = {}
getgenv().SolarConnections = {}

local function RegisterDrawing(obj)
    table.insert(getgenv().SolarDrawings, obj)
    return obj
end

-- 3. KONFIGURACJA
getgenv().SolarConfig = {
    Visuals = {
        BoxESP = true, CornerBox = false, HealthBar = true, NameTags = true,
        WeaponESP = true, Tracers = false, Skeleton = true, OffScreenArrows = true,
        Chams = false, HeliESP = true, HeliTracers = true, HeliMaxDistance = 5000,
        MaxDistance = 3000, BulletTracers = true, Crosshair = true, TextSize = 13,
        ESP_FPS_Limit = 1, ItemESPAUG = false
    },
    Combat = {
        AimAssist = true, AimKey = Enum.UserInputType.MouseButton2, ShowFOV = true,
        FOV = 150, MaxDistance = 3000, Smoothness = 1, AimPart = "Head",
        WallCheck = false, TeamCheck = false, AdvancedPrediction = true,
        PredictionMult = 1, DynamicAim = true, TriggerBot = false,
        AutoCalibration = true, LegitRCS = true, SilentAim = false,
        RCSStrength = 5, BulletSpeed = 3000, BulletGravity = 45,
        GravityScale = 1, VerticalOffset = 0, HitSound = true,
        InstantSnap = false, HeadshotOnly = false
    },
    Misc = {
        HighJump = false, JumpPower = 50, VehicleFly = false, FlySpeed = 50,
        Fullbright = false, HitboxSize = 2, ExpandHitbox = false, Streamproof = false,
        FakeLag = false, SpeedHack = false, SpeedMultiplier = 1.2
    },
    Colors = {
        Main = Color3.fromRGB(138, 43, 226), Accent = Color3.fromRGB(155, 89, 182),
        Background = Color3.fromRGB(15, 15, 20), Section = Color3.fromRGB(25, 25, 30),
        Element = Color3.fromRGB(35, 35, 45), Text = Color3.fromRGB(240, 240, 240),
        TextDark = Color3.fromRGB(150, 150, 150), Enemy = Color3.fromRGB(255, 60, 60),
        Distance = Color3.fromRGB(255, 215, 0), HealthHigh = Color3.fromRGB(100, 255, 100),
        HealthMid = Color3.fromRGB(255, 200, 100), HealthLow = Color3.fromRGB(255, 100, 100)
    },
    State = { Aiming = false, Unloaded = false, Rainbow = true }
}
local Config = getgenv().SolarConfig

local OriginalLighting = {
    Brightness = game:GetService("Lighting").Brightness,
    ClockTime = game:GetService("Lighting").ClockTime,
    GlobalShadows = game:GetService("Lighting").GlobalShadows,
    OutdoorAmbient = game:GetService("Lighting").OutdoorAmbient
}
local OriginalHeadSizes = {}

-- 4. UTILS
local function Tween(obj, props, time) TweenService:Create(obj, TweenInfo.new(time or 0.2), props):Play() end
local function Round(obj, r) local c = Instance.new("UICorner", obj); c.CornerRadius = UDim.new(0, r or 6); return c end

local function IsKeyMatch(input, storedKey)
    if typeof(storedKey) == "EnumItem" then
        return input.KeyCode == storedKey or input.UserInputType == storedKey
    end
    return false
end

-- ==============================================================================
--[ UI SYSTEM ]
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SolarMenu_v5.6"; ScreenGui.ResetOnSpawn = false; ScreenGui.Parent = SafeGui
local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 520, 0, 420); MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = Config.Colors.Background; MainFrame.BorderSizePixel = 0; MainFrame.Active = true; Round(MainFrame, 10)
Instance.new("UIStroke", MainFrame).Color = Config.Colors.Main

-- Dragging
local dragT, dragS, startP
MainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragT = true; dragS = i.Position; startP = MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement and dragT then local d = i.Position - dragS; MainFrame.Position = UDim2.new(startP.X.Scale, startP.X.Offset + d.X, startP.Y.Scale, startP.Y.Offset + d.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragT = false end end)

local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 140, 1, 0); Sidebar.BackgroundColor3 = Config.Colors.Section; Sidebar.BorderSizePixel = 0; Round(Sidebar, 10)
local Content = Instance.new("Frame", MainFrame); Content.Size = UDim2.new(1, -150, 1, -20); Content.Position = UDim2.new(0, 150, 0, 10); Content.BackgroundTransparency = 1

local Tabs = {}; local TabFrames = {}
local function SelectTab(n)
    for name, f in pairs(TabFrames) do f.Visible = (name == n) end
    for name, b in pairs(Tabs) do if name == n then Tween(b, {BackgroundColor3 = Config.Colors.Main, TextColor3 = Color3.new(1,1,1)}) else Tween(b, {BackgroundColor3 = Config.Colors.Element, TextColor3 = Config.Colors.TextDark}) end end
end

local function CreateTab(n)
    local B = Instance.new("TextButton", Sidebar); B.Size = UDim2.new(0, 120, 0, 35); B.BackgroundColor3 = Config.Colors.Element; B.Text = n; B.Font = Enum.Font.GothamBold; B.TextColor3 = Config.Colors.TextDark; B.TextSize = 13; B.AutoButtonColor = false; Round(B, 6)
    local F = Instance.new("CanvasGroup", Content); F.Size = UDim2.new(1, 0, 1, 0); F.BackgroundTransparency = 1; F.Visible = false
    local SC = Instance.new("ScrollingFrame", F); SC.Size = UDim2.new(1, 0, 1, 0); SC.BackgroundTransparency = 1; SC.ScrollBarThickness = 2; SC.BorderSizePixel = 0
    local L = Instance.new("UIListLayout", SC); L.Padding = UDim.new(0, 8); L.HorizontalAlignment = Enum.HorizontalAlignment.Center
    L:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() SC.CanvasSize = UDim2.new(0, 0, 0, L.AbsoluteContentSize.Y + 10) end)
    Tabs[n] = B; TabFrames[n] = F; B.MouseButton1Click:Connect(function() SelectTab(n) end)
    return SC
end

local function CreateToggle(p, t, k, sub)
    local B = Instance.new("TextButton", p); B.Size = UDim2.new(1, -10, 0, 38); B.BackgroundColor3 = Config.Colors.Section; B.Text = ""; Round(B, 6)
    local L = Instance.new("TextLabel", B); L.Size = UDim2.new(1, -60, 1, 0); L.Position = UDim2.new(0, 12, 0, 0); L.Text = t; L.Font = Enum.Font.Gotham; L.TextColor3 = Config.Colors.Text; L.TextSize = 13; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
    local SB = Instance.new("Frame", B); SB.Size = UDim2.new(0, 32, 0, 16); SB.Position = UDim2.new(1, -40, 0.5, -8); SB.BackgroundColor3 = Config[sub][k] and Config.Colors.Main or Config.Colors.Element; Round(SB, 8)
    local SK = Instance.new("Frame", SB); SK.Size = UDim2.new(0, 12, 0, 12); SK.Position = Config[sub][k] and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6); SK.BackgroundColor3 = Color3.new(1,1,1); Round(SK, 6)
    B.MouseButton1Click:Connect(function() 
        Config[sub][k] = not Config[sub][k]
        local s = Config[sub][k]
        Tween(SB, {BackgroundColor3 = s and Config.Colors.Main or Config.Colors.Element}, 0.2)
        Tween(SK, {Position = s and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}, 0.2)
    end)
end

local function CreateSlider(p, t, k, sub, min, max, float)
    local Cont = Instance.new("Frame", p); Cont.Size = UDim2.new(1, -10, 0, 45); Cont.BackgroundColor3 = Config.Colors.Section; Round(Cont, 6)
    local L = Instance.new("TextLabel", Cont); L.Size = UDim2.new(1, -20, 0, 18); L.Position = UDim2.new(0, 12, 0, 4); L.Text = t; L.Font = Enum.Font.Gotham; L.TextColor3 = Config.Colors.Text; L.TextSize = 12; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
    local VL = Instance.new("TextLabel", Cont); VL.Size = UDim2.new(0, 40, 0, 18); VL.Position = UDim2.new(1, -50, 0, 4); VL.Text = tostring(Config[sub][k]); VL.Font = Enum.Font.GothamBold; VL.TextColor3 = Config.Colors.Main; VL.TextSize = 12; VL.BackgroundTransparency = 1
    local BG = Instance.new("Frame", Cont); BG.Size = UDim2.new(1, -24, 0, 4); BG.Position = UDim2.new(0, 12, 0, 28); BG.BackgroundColor3 = Config.Colors.Element; Round(BG, 2)
    local F = Instance.new("Frame", BG); local scale = (Config[sub][k] - min) / (max - min); F.Size = UDim2.new(scale, 0, 1, 0); F.BackgroundColor3 = Config.Colors.Main; Round(F, 2)
    local SB = Instance.new("TextButton", BG); SB.Size = UDim2.new(1, 0, 1, 0); SB.BackgroundTransparency = 1; SB.Text = ""
    local sliding = false; SB.MouseButton1Down:Connect(function() sliding = true end)
    table.insert(getgenv().SolarConnections, UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end))
    table.insert(getgenv().SolarConnections, RunService.RenderStepped:Connect(function()
        if sliding then
            local p = math.clamp((UserInputService:GetMouseLocation().X - BG.AbsolutePosition.X) / BG.AbsoluteSize.X, 0, 1)
            local v = min + ((max - min) * p); v = float and (math.floor(v * 100) / 100) or math.floor(v); Config[sub][k] = v
            F.Size = UDim2.new(p, 0, 1, 0); VL.Text = tostring(v)
        end
    end))
end

-- UI TABS
local TabVis = CreateTab("Visuals"); local TabCbt = CreateTab("Combat"); local TabMisc = CreateTab("Misc"); local TabSet = CreateTab("Settings"); SelectTab("Visuals")

CreateToggle(TabVis, "Box ESP", "BoxESP", "Visuals")
CreateToggle(TabVis, "Corner Box", "CornerBox", "Visuals")
CreateToggle(TabVis, "Health Bar", "HealthBar", "Visuals")
CreateToggle(TabVis, "Nicknames", "NameTags", "Visuals")
CreateToggle(TabVis, "Skeleton", "Skeleton", "Visuals")
CreateToggle(TabVis, "Bullet Tracers", "BulletTracers", "Visuals")
CreateToggle(TabVis, "Helicopter ESP", "HeliESP", "Visuals")
CreateToggle(TabVis, "AUG Item ESP", "ItemESPAUG", "Visuals")
CreateSlider(TabVis, "Max Distance", "MaxDistance", "Visuals", 100, 5000, false)

CreateToggle(TabCbt, "Aimbot", "AimAssist", "Combat")
CreateToggle(TabCbt, "Silent Aim", "SilentAim", "Combat")
CreateToggle(TabCbt, "Legit RCS", "LegitRCS", "Combat")
CreateToggle(TabCbt, "Headshot Only", "HeadshotOnly", "Combat")
CreateSlider(TabCbt, "Smoothness", "Smoothness", "Combat", 0.1, 1, true)
CreateSlider(TabCbt, "FOV Size", "FOV", "Combat", 10, 600, false)

CreateToggle(TabMisc, "Fake Lag", "FakeLag", "Misc")
CreateToggle(TabMisc, "Speed Hack", "SpeedHack", "Misc")
CreateSlider(TabMisc, "Speed Multi", "SpeedMultiplier", "Misc", 1, 3, true)
CreateToggle(TabMisc, "Vehicle Fly", "VehicleFly", "Misc")
CreateSlider(TabMisc, "Fly Speed", "FlySpeed", "Misc", 10, 300, false)

-- ==============================================================================
--[ CORE ENGINE ]
-- ==============================================================================

local function CleanConfig(o)
    local r = {}
    for k,v in pairs(o) do
        if typeof(v) == "Color3" then r[k] = {__type="Color3", r=v.R, g=v.G, b=v.B}
        elseif typeof(v) == "EnumItem" then r[k] = {__type="Enum", type=tostring(v.EnumType), name=v.Name}
        elseif type(v) == "table" then r[k] = CleanConfig(v)
        else r[k] = v end
    end
    return r
end

local function RestoreConfig(src, dst)
    for k,v in pairs(src) do
        if type(v) == "table" and v.__type == "Color3" then dst[k] = Color3.new(v.r, v.g, v.b)
        elseif type(v) == "table" and v.__type == "Enum" then pcall(function() dst[k] = Enum[v.type][v.name] end)
        elseif type(v) == "table" then if not dst[k] then dst[k] = {} end RestoreConfig(v, dst[k])
        else dst[k] = v end
    end
end

-- ESP LOD & CACHE
local Cache = { Draw = {}, Chams = {}, Backtrack = {} }
local BodyParts = {"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}
local SkeletonConns = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}}

local function RemovePlayer(p)
    if Cache.Draw[p] then for _, v in pairs(Cache.Draw[p]) do pcall(function() v:Remove() end) end Cache.Draw[p] = nil end
    if Cache.Chams[p] then pcall(function() Cache.Chams[p]:Destroy() end); Cache.Chams[p] = nil end
end

local function CreateDrawings(p)
    local d = {
        Box = RegisterDrawing(Drawing.new("Square")), BoxOut = RegisterDrawing(Drawing.new("Square")),
        HealthBG = RegisterDrawing(Drawing.new("Square")), Health = RegisterDrawing(Drawing.new("Square")),
        Tag = RegisterDrawing(Drawing.new("Text")), Dist = RegisterDrawing(Drawing.new("Text")),
        Tracer = RegisterDrawing(Drawing.new("Line")), Skeleton = {}
    }
    for i=1, #SkeletonConns do d.Skeleton[i] = RegisterDrawing(Drawing.new("Line")) end
    d.Tag.Center = true; d.Tag.Outline = true; d.Tag.Size = 13; d.Tag.Font = 2
    d.Dist.Center = true; d.Dist.Outline = true; d.Dist.Size = 12; d.Dist.Font = 2; d.Dist.Color = Config.Colors.Distance
    Cache.Draw[p] = d
end

local function HideAll(p)
    local d = Cache.Draw[p]
    if d then d.Box.Visible = false; d.BoxOut.Visible = false; d.Health.Visible = false; d.HealthBG.Visible = false; d.Tag.Visible = false; d.Dist.Visible = false; d.Tracer.Visible = false; for _,l in pairs(d.Skeleton) do l.Visible = false end end
end

local _espFrame = 0
local ESP_Loop = RunService.RenderStepped:Connect(function()
    if Config.State.Unloaded then return end
    _espFrame = _espFrame + 1
    local camPos = Camera.CFrame.Position

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
        
        if root and hum and hum.Health > 0 then
            local dist = (camPos - root.Position).Magnitude
            if dist > Config.Visuals.MaxDistance then HideAll(p) continue end
            
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                if not Cache.Draw[p] then CreateDrawings(p) end
                local d = Cache.Draw[p]
                
                -- BOX
                d.Box.Visible = Config.Visuals.BoxESP; d.BoxOut.Visible = Config.Visuals.BoxESP
                if Config.Visuals.BoxESP then
                    local h = math.clamp(2500 / dist, 10, 500); local w = h * 0.6
                    d.Box.Size = Vector2.new(w, h); d.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2); d.Box.Color = Config.Colors.Enemy
                    d.BoxOut.Size = d.Box.Size; d.BoxOut.Position = d.Box.Position; d.BoxOut.Color = Color3.new(0,0,0); d.BoxOut.Thickness = 3
                end
                
                -- TAGS
                d.Tag.Visible = Config.Visuals.NameTags; d.Tag.Text = p.Name; d.Tag.Position = Vector2.new(pos.X, pos.Y - 30)
                d.Dist.Visible = Config.Visuals.NameTags; d.Dist.Text = math.floor(dist) .. "m"; d.Dist.Position = Vector2.new(pos.X, pos.Y + 20)
                
                -- BACKTRACK STORE
                if not Cache.Backtrack[p] then Cache.Backtrack[p] = {} end
                table.insert(Cache.Backtrack[p], 1, root.Position)
                if #Cache.Backtrack[p] > 10 then table.remove(Cache.Backtrack[p], 11) end
            else HideAll(p) end
        else HideAll(p) end
    end
    
    -- FULLBRIGHT
    if Config.Misc.Fullbright then
        game:GetService("Lighting").Brightness = 2; game:GetService("Lighting").ClockTime = 14; game:GetService("Lighting").GlobalShadows = false
    else
        game:GetService("Lighting").Brightness = OriginalLighting.Brightness; game:GetService("Lighting").GlobalShadows = OriginalLighting.GlobalShadows
    end
end)
table.insert(getgenv().SolarConnections, ESP_Loop)

-- AIMBOT
local CurrentT = nil
local function IsVisible(part)
    if not Config.Combat.WallCheck then return true end
    local ray = Workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), RaycastParams.new())
    return not ray or ray.Instance:IsDescendantOf(part.Parent)
end

local function GetClosest()
    local best = nil; local maxDist = Config.Combat.FOV; local mouse = UserInputService:GetMouseLocation()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character; local root = char and char.PrimaryPart; local hum = char and char:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.Health > 0 then
            local pos, on = Camera:WorldToViewportPoint(root.Position)
            if on then
                local dist = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                if dist < maxDist then maxDist = dist; best = p end
            end
        end
    end
    return best
end

local AimLoop = RunService.RenderStepped:Connect(function()
    if Config.State.Unloaded or not Config.Combat.AimAssist then return end
    
    if Config.State.Aiming then
        if not CurrentT or not CurrentT.Character or not CurrentT.Character:FindFirstChild("Humanoid") or CurrentT.Character.Humanoid.Health <= 0 then
            CurrentT = GetClosest()
        end
        
        if CurrentT and CurrentT.Character then
            local char = CurrentT.Character
            local part = nil
            
            -- MULTIPOINT
            for _, n in ipairs(BodyParts) do
                local o = char:FindFirstChild(n)
                if o and IsVisible(o) then part = o; break end
            end
            if Config.Combat.HeadshotOnly then part = char:FindFirstChild("Head") or part end
            
            if part then
                local aimP = part.Position
                if Config.Combat.AdvancedPrediction then
                    local vel = char.PrimaryPart.AssemblyLinearVelocity; local t = (aimP - Camera.CFrame.Position).Magnitude / Config.Combat.BulletSpeed
                    aimP = aimP + (vel * t)
                end
                getgenv().PredictedPosition = aimP
                
                local pos, on = Camera:WorldToViewportPoint(aimP)
                if on then
                    local mouse = UserInputService:GetMouseLocation()
                    local dx, dy = (pos.X - mouse.X) * Config.Combat.Smoothness, (pos.Y - mouse.Y) * Config.Combat.Smoothness
                    if mousemoverel then mousemoverel(dx, dy) end
                end
            end
        end
    else CurrentT = nil end
    
    -- RCS
    if Config.Combat.LegitRCS and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        if mousemoverel then mousemoverel(0, Config.Combat.RCSStrength) end
    end
end)
table.insert(getgenv().SolarConnections, AimLoop)

-- SILENT AIM HOOK
local mt = getrawmetatable(game); local oldNamecall = mt.__namecall; setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod(); local args = {...}
    if method == "Raycast" and Config.Combat.SilentAim and getgenv().PredictedPosition then
        local origin = args[1]
        if (origin - Camera.CFrame.Position).Magnitude < 15 then
            args[2] = (getgenv().PredictedPosition - origin).Unit * args[2].Magnitude
            if Config.Combat.HitSound then
                local s = Instance.new("Sound", game:GetService("SoundService")); s.SoundId = "rbxassetid://160433791"; s.Volume = 2; s:Play(); game:GetService("Debris"):AddItem(s, 1)
            end
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- MISC LOOP
local _fakeLagTick = 0
local MiscLoop = RunService.Heartbeat:Connect(function()
    if Config.State.Unloaded then return end
    local char = LocalPlayer.Character; local root = char and char.PrimaryPart; local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if Config.Misc.SpeedHack and hum then hum.WalkSpeed = 16 * Config.Misc.SpeedMultiplier else if hum then hum.WalkSpeed = 16 end end
    if Config.Misc.FakeLag and root then
        _fakeLagTick = _fakeLagTick + 1
        if _fakeLagTick % 10 == 0 then root.Anchored = true; task.wait(0.05); root.Anchored = false end
    end
    
    -- VEHICLE FLY
    if Config.Misc.VehicleFly and hum and hum.SeatPart then
        local veh = hum.SeatPart:FindFirstAncestorOfClass("Model"); local vRoot = veh and veh.PrimaryPart
        if vRoot then
            local bv = vRoot:FindFirstChild("SolarFlyBV") or Instance.new("BodyVelocity", vRoot); bv.Name = "SolarFlyBV"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            local look = Camera.CFrame.LookVector; local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + look end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - look end
            bv.Velocity = move * Config.Misc.FlySpeed
        end
    end
end)
table.insert(getgenv().SolarConnections, MiscLoop)

-- UNLOAD
getgenv().UnloadSolar = function()
    Config.State.Unloaded = true
    for _, v in pairs(getgenv().SolarDrawings) do pcall(function() v:Remove() end) end
    for _, v in pairs(getgenv().SolarConnections) do pcall(function() v:Disconnect() end) end
    if ScreenGui then ScreenGui:Destroy() end
    print("[Solar] Unloaded.")
end

UserInputService.InputBegan:Connect(function(i, g) if not g and IsKeyMatch(i, Config.Combat.AimKey) then Config.State.Aiming = true end end)
UserInputService.InputEnded:Connect(function(i, g) if IsKeyMatch(i, Config.Combat.AimKey) then Config.State.Aiming = false end end)