-- ==============================================================================
--[ AR2 ULTIMATE PRO - v5 (ULTRA OPTIMIZED) ]
-- Naprawiono lagi, zoptymalizowano rysowanie i dodano super-czyszczenie.
-- ==============================================================================

-- 1. SUPER CZYSZCZENIE (Usuwamy wszystko co stare)
local function Cleanup()
    if getgenv().UnloadSolar then pcall(getgenv().UnloadSolar) end
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v:IsA("ScreenGui") and (v.Name:find("Solar") or v.Name:find("Menu")) then
            v:Destroy()
        end
    end
end
Cleanup()
task.wait(0.2)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Fix kamery
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    Camera = Workspace.CurrentCamera
end)

local SafeGui = (gethui and gethui()) or CoreGui
getgenv().SolarConnections = {}

-- ==============================================================================
--[ KONFIGURACJA v5 ]
-- ==============================================================================
getgenv().SolarConfig = {
    Visuals = {
        BoxESP = true,
        CornerBox = true,
        NameTags = true,
        HealthBar = true,
        Skeleton = false,
        WeaponESP = true,
        Tracers = false,
        OffScreenArrows = true,
        Chams = true,
        HeliESP = true,
        HeliTracers = true,
        HeliMaxDistance = 5000,
        MaxDistance = 3000,
        MinDistance = 0,
        ItemESPAUG = false,
        Crosshair = true,
        TextSize = 13,
        ESP_FPS_Limit = 1
    },
    Combat = {
        AimAssist = true,
        AimKey = Enum.UserInputType.MouseButton2,
        ShowFOV = true,
        FOV = 150,
        MaxDistance = 3000,
        Smoothness = 1,
        AimPart = "Head",
        WallCheck = true,
        TeamCheck = false,
        AdvancedPrediction = true,
        PredictionMult = 1,
        DynamicAim = true,
        TriggerBot = false,
        AutoCalibration = true,
        LegitRCS = false,
        SilentAim = false,
        RCSStrength = 5,
        BulletSpeed = 2500,
        BulletGravity = 196.2
    },
    Misc = {
        HighJump = false,
        JumpPower = 50,
        VehicleFly = false,
        FlySpeed = 50,
        Fullbright = false,
        HitboxSize = 2,
        ExpandHitbox = false,
        Streamproof = false
    },
    Colors = {
        Main = Color3.fromRGB(138, 43, 226),
        Accent = Color3.fromRGB(155, 89, 182),
        Background = Color3.fromRGB(15, 15, 20),
        Section = Color3.fromRGB(25, 25, 30),
        Element = Color3.fromRGB(35, 35, 45),
        Text = Color3.fromRGB(240, 240, 240),
        TextDark = Color3.fromRGB(150, 150, 150),
        Enemy = Color3.fromRGB(255, 60, 60),
        Distance = Color3.fromRGB(255, 215, 0), -- Golden Xeno Style
        HealthHigh = Color3.fromRGB(100, 255, 100),
        HealthMid = Color3.fromRGB(255, 200, 100),
        HealthLow = Color3.fromRGB(255, 100, 100),
    },
    State = { Aiming = false, Unloaded = false, Rainbow = true }
}
local Config = getgenv().SolarConfig

local function Tween(obj, props, time) TweenService:Create(obj, TweenInfo.new(time or 0.2), props):Play() end
local function Round(obj, r) local c = Instance.new("UICorner", obj); c.CornerRadius = UDim.new(0, r or 6); return c end

-- ==============================================================================
--[ UI v5 ]
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SolarMenu_v5"; ScreenGui.ResetOnSpawn = false; ScreenGui.Parent = SafeGui
local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 520, 0, 400); MainFrame.Position = UDim2.new(0.5, -260, 0.5, -200)
MainFrame.BackgroundColor3 = Config.Colors.Background; MainFrame.BorderSizePixel = 0; MainFrame.Active = true; Round(MainFrame, 10)
Instance.new("UIStroke", MainFrame).Color = Config.Colors.Main

-- Dragging
local dragT, dragS, startP
MainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragT = true; dragS = i.Position; startP = MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement and dragT then local d = i.Position - dragS; MainFrame.Position = UDim2.new(startP.X.Scale, startP.X.Offset + d.X, startP.Y.Scale, startP.Y.Offset + d.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragT = false end end)

local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 140, 1, 0); Sidebar.BackgroundColor3 = Config.Colors.Section; Sidebar.BorderSizePixel = 0; Round(Sidebar, 10)
local SideFix = Instance.new("Frame", Sidebar); SideFix.Size = UDim2.new(0, 10, 1, 0); SideFix.Position = UDim2.new(1, -10, 0, 0); SideFix.BackgroundColor3 = Config.Colors.Section; Sidebar.ZIndex = 2
local Content = Instance.new("Frame", MainFrame); Content.Size = UDim2.new(1, -150, 1, -20); Content.Position = UDim2.new(0, 150, 0, 10); Content.BackgroundTransparency = 1

-- Rainbow Footer Logic (Xeno style)
local Footer = Instance.new("TextLabel", Sidebar)
Footer.Size = UDim2.new(1, 0, 0, 20); Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.BackgroundTransparency = 1; Footer.Text = "Made by Antigravity x Xeno"; Footer.Font = Enum.Font.GothamBold
Footer.TextSize = 11; Footer.TextColor3 = Config.Colors.Main

task.spawn(function()
    while task.wait() do
        if Config.State.Unloaded then break end
        if Config.State.Rainbow then
            local hue = tick() % 5 / 5
            Footer.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
        end
    end
end)
local Tabs = {}; local TabFrames = {}

local function SelectTab(n)
    for name, f in pairs(TabFrames) do 
        if name == n then
            f.Visible = true
            f.GroupTransparency = 1
            Tween(f, {GroupTransparency = 0}, 0.3)
        else
            f.Visible = false 
        end
    end
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

local TabListL = Instance.new("UIListLayout", Sidebar); TabListL.Padding = UDim.new(0, 5); TabListL.HorizontalAlignment = Enum.HorizontalAlignment.Center; TabListL.SortOrder = Enum.SortOrder.LayoutOrder; Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 50)

local function CreateToggle(p, t, k, c)
    local B = Instance.new("TextButton", p); B.Size = UDim2.new(1, -10, 0, 38); B.BackgroundColor3 = Config.Colors.Section; B.Text = ""; Round(B, 6)
    local L = Instance.new("TextLabel", B); L.Size = UDim2.new(1, -60, 1, 0); L.Position = UDim2.new(0, 12, 0, 0); L.Text = t; L.Font = Enum.Font.Gotham; L.TextColor3 = Config.Colors.Text; L.TextSize = 13; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
    local SB = Instance.new("Frame", B); SB.Size = UDim2.new(0, 32, 0, 16); SB.Position = UDim2.new(1, -40, 0.5, -8); SB.BackgroundColor3 = Config[c][k] and Config.Colors.Main or Config.Colors.Element; Round(SB, 8)
    local SK = Instance.new("Frame", SB); SK.Size = UDim2.new(0, 12, 0, 12); SK.Position = Config[c][k] and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6); SK.BackgroundColor3 = Color3.new(1,1,1); Round(SK, 6)
    B.MouseButton1Click:Connect(function() local s = not Config[c][k]; Config[c][k] = s; Tween(SB, {BackgroundColor3 = s and Config.Colors.Main or Config.Colors.Element}, 0.2); Tween(SK, {Position = s and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}, 0.2) end)
end

local function CreateSlider(p, t, c, k, min, max, float)
    local Cont = Instance.new("Frame", p); Cont.Size = UDim2.new(1, -10, 0, 45); Cont.BackgroundColor3 = Config.Colors.Section; Round(Cont, 6)
    local L = Instance.new("TextLabel", Cont); L.Size = UDim2.new(1, -20, 0, 18); L.Position = UDim2.new(0, 12, 0, 4); L.Text = t; L.Font = Enum.Font.Gotham; L.TextColor3 = Config.Colors.Text; L.TextSize = 12; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
    local VL = Instance.new("TextLabel", Cont); VL.Size = UDim2.new(0, 40, 0, 18); VL.Position = UDim2.new(1, -50, 0, 4); VL.Text = tostring(Config[c][k]); VL.Font = Enum.Font.GothamBold; VL.TextColor3 = Config.Colors.Main; VL.TextSize = 12; VL.BackgroundTransparency = 1
    local BG = Instance.new("Frame", Cont); BG.Size = UDim2.new(1, -24, 0, 4); BG.Position = UDim2.new(0, 12, 0, 28); BG.BackgroundColor3 = Config.Colors.Element; Round(BG, 2)
    local F = Instance.new("Frame", BG); local scale = (Config[c][k] - min) / (max - min); F.Size = UDim2.new(scale, 0, 1, 0); F.BackgroundColor3 = Config.Colors.Main; Round(F, 2)
    local SB = Instance.new("TextButton", BG); SB.Size = UDim2.new(1, 0, 1, 0); SB.BackgroundTransparency = 1; SB.Text = ""
    local sliding = false; SB.MouseButton1Down:Connect(function() sliding = true end)
    table.insert(getgenv().SolarConnections, UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end))
    table.insert(getgenv().SolarConnections, RunService.RenderStepped:Connect(function()
        if sliding then
            local p = math.clamp((UserInputService:GetMouseLocation().X - BG.AbsolutePosition.X) / BG.AbsoluteSize.X, 0, 1)
            local v = min + ((max - min) * p); v = float and (math.floor(v * 100) / 100) or math.floor(v); Config[c][k] = v
            F.Size = UDim2.new(p, 0, 1, 0); VL.Text = tostring(v)
        end
    end))
end

local function CreateKeybind(p, t, c, k)
    local B = Instance.new("TextButton", p); B.Size = UDim2.new(1, -10, 0, 38); B.BackgroundColor3 = Config.Colors.Section; B.Text = ""; Round(B, 6)
    local L = Instance.new("TextLabel", B); L.Size = UDim2.new(1, -100, 1, 0); L.Position = UDim2.new(0, 12, 0, 0); L.Text = t; L.Font = Enum.Font.Gotham; L.TextColor3 = Config.Colors.Text; L.TextSize = 13; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
    local KB = Instance.new("TextButton", B); KB.Size = UDim2.new(0, 100, 0, 24); KB.Position = UDim2.new(1, -110, 0.5, -12); KB.BackgroundColor3 = Config.Colors.Element; KB.Text = Config[c][k].Name; KB.Font = Enum.Font.GothamBold; KB.TextColor3 = Config.Colors.Main; KB.TextSize = 11; Round(KB, 6)
    local listening = false
    KB.MouseButton1Click:Connect(function() listening = true; KB.Text = "..." end)
    table.insert(getgenv().SolarConnections, UserInputService.InputBegan:Connect(function(i)
        if listening then
            if i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode ~= Enum.KeyCode.Unknown then
                Config[c][k] = i.KeyCode; KB.Text = i.KeyCode.Name; listening = false
            elseif i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.MouseButton2 or i.UserInputType == Enum.UserInputType.MouseButton3 then
                Config[c][k] = i.UserInputType; KB.Text = i.UserInputType.Name; listening = false
            end
        end
    end))
end

local TabVis = CreateTab("Visuals"); local TabCbt = CreateTab("Combat"); local TabMisc = CreateTab("Misc"); local TabSet = CreateTab("Settings"); SelectTab("Visuals")

CreateToggle(TabVis, "Boxes", "BoxESP", "Visuals")
CreateToggle(TabVis, "Health Bar", "HealthBar", "Visuals")
CreateToggle(TabVis, "Skeleton (FPS Heavy)", "Skeleton", "Visuals")
CreateToggle(TabVis, "Nicknames", "NameTags", "Visuals")
CreateToggle(TabVis, "Weapon ESP", "WeaponESP", "Visuals")
CreateToggle(TabVis, "Tracers", "Tracers", "Visuals")
CreateToggle(TabVis, "Off-Screen Arrows", "OffScreenArrows", "Visuals")
CreateToggle(TabVis, "Chams (Highlight)", "Chams", "Visuals")
CreateToggle(TabVis, "Helicopter ESP", "HeliESP", "Visuals")
CreateToggle(TabVis, "Heli Tracers", "HeliTracers", "Visuals")
CreateToggle(TabVis, "AUG Item ESP", "ItemESPAUG", "Visuals")
CreateToggle(TabVis, "Custom Crosshair", "Crosshair", "Visuals")
CreateSlider(TabVis, "ESP Text Size", "Visuals", "TextSize", 8, 24, false)
CreateSlider(TabVis, "Max Distance", "Visuals", "MaxDistance", 100, 10000, false)

CreateToggle(TabCbt, "Aimbot", "AimAssist", "Combat")
CreateKeybind(TabCbt, "Aim Key", "Combat", "AimKey")
CreateToggle(TabCbt, "Show FOV", "ShowFOV", "Combat")
CreateToggle(TabCbt, "Wall Check", "WallCheck", "Combat")
CreateToggle(TabCbt, "Dynamic Part Selection", "DynamicAim", "Combat")
CreateToggle(TabCbt, "TriggerBot", "TriggerBot", "Combat")
CreateToggle(TabCbt, "Advanced Physics", "AdvancedPrediction", "Combat")
CreateToggle(TabCbt, "Legit RCS", "LegitRCS", "Combat")
CreateToggle(TabCbt, "Silent Aim (Magic Bullets)", "SilentAim", "Combat")
CreateSlider(TabCbt, "RCS Strength", "Combat", "RCSStrength", 1, 20, false)
CreateSlider(TabCbt, "Smoothness", "Combat", "Smoothness", 0.1, 1, true)
CreateSlider(TabCbt, "Lead Calibration", "Combat", "PredictionMult", 0.1, 5, true)
CreateSlider(TabCbt, "FOV Size", "Combat", "FOV", 10, 600, false)

CreateToggle(TabMisc, "High Jump", "HighJump", "Misc")
CreateSlider(TabMisc, "Jump Height", "Misc", "JumpPower", 50, 300, false)
CreateToggle(TabMisc, "Vehicle Fly", "VehicleFly", "Misc")
CreateSlider(TabMisc, "Fly Speed", "Misc", "FlySpeed", 10, 300, false)
CreateToggle(TabMisc, "Fullbright", "Fullbright", "Misc")
CreateToggle(TabMisc, "Expand Hitbox", "ExpandHitbox", "Misc")
CreateSlider(TabMisc, "Hitbox Size", "Misc", "HitboxSize", 2, 15, false)
CreateToggle(TabMisc, "Streamproof (Hide UI)", "Streamproof", "Misc")

local HttpService = game:GetService("HttpService")
local CfgName = "AR2_SolarV5_Config.json"

local SaveBtn = Instance.new("TextButton", TabSet); SaveBtn.Size = UDim2.new(1, -10, 0, 45); SaveBtn.BackgroundColor3 = Config.Colors.Element; SaveBtn.Text = "ZAPISZ CONFIG"; SaveBtn.Font = Enum.Font.GothamBold; SaveBtn.TextColor3 = Color3.new(1,1,1); SaveBtn.TextSize = 14; Round(SaveBtn, 8)
local LoadBtn = Instance.new("TextButton", TabSet); LoadBtn.Size = UDim2.new(1, -10, 0, 45); LoadBtn.BackgroundColor3 = Config.Colors.Element; LoadBtn.Text = "WCZYTAJ CONFIG"; LoadBtn.Font = Enum.Font.GothamBold; LoadBtn.TextColor3 = Color3.new(1,1,1); LoadBtn.TextSize = 14; Round(LoadBtn, 8)

SaveBtn.MouseButton1Click:Connect(function()
    if writefile then
        local t = {Visuals=Config.Visuals, Combat=Config.Combat, Misc=Config.Misc}
        local function clean(o)
            local r = {}
            for k,v in pairs(o) do
                if typeof(v) == "EnumItem" then r[k] = "ENUM_"..tostring(v.EnumType).."_"..v.Name
                elseif type(v) == "table" then r[k] = clean(v)
                else r[k] = v end
            end
            return r
        end
        pcall(function() writefile(CfgName, HttpService:JSONEncode(clean(t))) end)
    end
end)

LoadBtn.MouseButton1Click:Connect(function()
    if readfile and isfile and isfile(CfgName) then
        pcall(function()
            local d = HttpService:JSONDecode(readfile(CfgName))
            local function restore(src, dst)
                for k,v in pairs(src) do
                    if type(v) == "string" and v:sub(1,5) == "ENUM_" then
                        local p = v:split("_")
                        if #p >= 3 then pcall(function() dst[k] = Enum[p[2]][p[3]] end) end
                    elseif type(v) == "table" and type(dst[k]) == "table" then
                        restore(v, dst[k])
                    else
                        dst[k] = v
                    end
                end
            end
            restore(d, Config)
        end)
    end
end)

local UnloadBtn = Instance.new("TextButton", TabSet); UnloadBtn.Size = UDim2.new(1, -10, 0, 45); UnloadBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40); UnloadBtn.Text = "WYŁĄCZ I WYCZYŚĆ"; UnloadBtn.Font = Enum.Font.GothamBold; UnloadBtn.TextColor3 = Color3.new(1,1,1); UnloadBtn.TextSize = 14; Round(UnloadBtn, 8)

getgenv().FOVRing = Drawing.new("Circle")
getgenv().FOVRing.Thickness = 1.5; getgenv().FOVRing.NumSides = 60; getgenv().FOVRing.Transparency = 0.7

getgenv().UnloadSolar = function()
    Config.State.Unloaded = true
    if getgenv().ClearESP then pcall(getgenv().ClearESP) end
    for _, c in pairs(getgenv().SolarConnections) do pcall(function() c:Disconnect() end) end
    if ScreenGui then ScreenGui:Destroy() end
    if getgenv().FOVRing then pcall(function() getgenv().FOVRing:Remove() end) end
    getgenv().SolarConfig = nil; getgenv().UnloadSolar = nil; getgenv().ClearESP = nil
    print("[SOLARA] Wersja v5 wyczyszczona.")
end
UnloadBtn.MouseButton1Click:Connect(getgenv().UnloadSolar)
table.insert(getgenv().SolarConnections, UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.RightControl then ScreenGui.Enabled = not ScreenGui.Enabled end end))

-- ==============================================================================
--[ LOGIKA ESP v5 (ULTRA OPTIMIZED) ]
-- ==============================================================================
local CurrentT = nil -- Definicja CurrentT wyżej, by tracery widziały target
local Cache = { Draw = {}, Chams = {} }
local SkeletonConns = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}}

local function CreateDrawings(p)
    local d = {
        Box = Drawing.new("Square"), BoxOut = Drawing.new("Square"), Corners = {}, CornersOut = {},
        HealthBG = Drawing.new("Square"), Health = Drawing.new("Square"),
        Tag = Drawing.new("Text"), Dist = Drawing.new("Text"), Weapon = Drawing.new("Text"), Team = Drawing.new("Text"),
        Tracer = Drawing.new("Line"), Skeleton = {}, Arrows = Drawing.new("Triangle")
    }
    for i=1, #SkeletonConns do d.Skeleton[i] = Drawing.new("Line"); d.Skeleton[i].Thickness = 1 end
    d.Arrows.Thickness = 1; d.Arrows.Filled = true; d.Arrows.Color = Config.Colors.Main
    d.Box.Thickness = 1; d.BoxOut.Thickness = 3; d.BoxOut.Color = Color3.new(0,0,0)
    for i=1, 8 do d.Corners[i] = Drawing.new("Line"); d.Corners[i].Thickness = 1; d.CornersOut[i] = Drawing.new("Line"); d.CornersOut[i].Thickness = 3; d.CornersOut[i].Color = Color3.new(0,0,0) end
    d.HealthBG.Filled = true; d.HealthBG.Color = Color3.new(0,0,0); d.Health.Filled = true
    d.Tag.Size = 13; d.Tag.Center = true; d.Tag.Outline = true; d.Tag.Font = 2
    d.Dist.Size = 12; d.Dist.Center = true; d.Dist.Outline = true; d.Dist.Font = 2; d.Dist.Color = Config.Colors.Distance
    d.Weapon.Size = 11; d.Weapon.Center = true; d.Weapon.Outline = true; d.Weapon.Font = 2; d.Weapon.Color = Config.Colors.Accent
    d.Team.Size = 11; d.Team.Center = true; d.Team.Outline = true; d.Team.Font = 2; d.Team.Color = Color3.fromRGB(100, 200, 255)
    d.Tracer.Thickness = 1
    Cache.Draw[p] = d
end

local function HideAll(p)
    local d = Cache.Draw[p]
    if d and (d.Tag.Visible or d.Box.Visible or d.Tracer.Visible) then 
        d.Box.Visible = false; d.BoxOut.Visible = false
        for i=1, 8 do d.Corners[i].Visible = false; d.CornersOut[i].Visible = false end
        d.Health.Visible = false; d.HealthBG.Visible = false
        d.Tag.Visible = false; d.Dist.Visible = false; d.Weapon.Visible = false; d.Team.Visible = false; d.Tracer.Visible = false; d.Arrows.Visible = false
        for _, l in pairs(d.Skeleton) do l.Visible = false end
    end
    if Cache.Chams[p] and Cache.Chams[p].Enabled then Cache.Chams[p].Enabled = false end
end

local function RemovePlayer(p)
    if Cache.Draw[p] then 
        for _, v in pairs(Cache.Draw[p]) do 
            if type(v) == "table" then 
                for _, l in pairs(v) do pcall(function() l:Remove() end) end 
            else 
                pcall(function() v:Remove() end) 
            end 
        end 
        Cache.Draw[p] = nil 
    end
    if Cache.Chams[p] then pcall(function() Cache.Chams[p]:Destroy() end); Cache.Chams[p] = nil end
end

-- ==============================================================================
--[ ITEM ESP v5 (AUG ONLY) ]
-- ==============================================================================
local ItemCache = {}

local function CreateItemDrawing(item)
    local t = Drawing.new("Text")
    t.Size = 13; t.Center = true; t.Outline = true; t.Color = Color3.fromRGB(0, 255, 255)
    t.Visible = false
    ItemCache[item] = t
end

local ItemESPLoop = RunService.RenderStepped:Connect(function()
    if Config.State.Unloaded or not Config.Visuals.ItemESPAUG then
        for i, v in pairs(ItemCache) do v.Visible = false end
        return
    end

    -- Skanowanie przedmiotów co sekundę (oszczędność wydajności)
    if tick() % 1 < 0.05 then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "AUG" and not ItemCache[obj] then
                CreateItemDrawing(obj)
            end
        end
    end

    for item, draw in pairs(ItemCache) do
        if not item or not item.Parent then
            draw:Remove()
            ItemCache[item] = nil
            continue
        end

        local pos = item:IsA("BasePart") and item.Position or (item:IsA("Model") and item:GetPivot().Position)
        if pos then
            local dist = (Camera.CFrame.Position - pos).Magnitude
            if dist < Config.Visuals.MaxDistance then
                local scr, on = Camera:WorldToViewportPoint(pos)
                if on then
                    draw.Position = Vector2.new(scr.X, scr.Y)
                    draw.Text = "[AUG] [" .. math.floor(dist) .. "m]"
                    draw.Visible = true
                else
                    draw.Visible = false
                end
            else
                draw.Visible = false
            end
        end
    end
end)
table.insert(getgenv().SolarConnections, ItemESPLoop)

getgenv().ClearESP = function()
    for p, _ in pairs(Cache.Draw) do RemovePlayer(p) end
    for heli, _ in pairs(HeliCache or {}) do
        for _, v in pairs(heli) do pcall(function() v:Remove() end) end
    end
    for _, v in pairs(ItemCache) do pcall(function() v:Remove() end) end
end

-- Pre-allocowane stałe (nie tworzone w pętli = zero GC)
local COL_GREEN   = Color3.new(0, 1, 0)
local COL_WHITE   = Color3.new(1, 1, 1)
local COL_BLACK   = Color3.new(0, 0, 0)
local V3_UP25     = Vector3.new(0, 2.5, 0)
local V3_DOWN3    = Vector3.new(0, -3, 0)
local V2_ZERO     = Vector2.new(0, 0)
local CrossLines  = {Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line")}
for _,l in pairs(CrossLines) do l.Thickness = 1.5; l.Color = Color3.new(0,1,0); l.ZIndex = 10 end

-- Cache nazw graczy (string concat tworzy śmieć co klatkę)
local NameCache = {}
local TeamCache = {}
local ToolCache = {} -- nazwa broni gracza
local _espTick  = 0  -- licznik do throttlowania drogich operacji

local ESP_Loop = RunService.RenderStepped:Connect(function()
    if Config.State.Unloaded then 
        for p, _ in pairs(Cache.Draw) do RemovePlayer(p) end 
        return 
    end
    _espTick = _espTick + 1
    local slowTick = (_espTick % 10 == 0) -- co 10 klatek: drogie operacje
    
    -- Cache'ujemy transform kamery RAZ na całą iterację (nie recalculate per-gracz)
    local camPos    = Camera.CFrame.Position
    local vpSize    = Camera.ViewportSize
    local halfVpX   = vpSize.X * 0.5
    local vpY       = vpSize.Y
    local maxDist   = Config.Visuals.MaxDistance
    local showBox   = Config.Visuals.BoxESP
    local showCorner= Config.Visuals.CornerBox
    local showHP    = Config.Visuals.HealthBar
    local showTags  = Config.Visuals.NameTags
    local showWep   = Config.Visuals.WeaponESP
    local showTrace = Config.Visuals.Tracers
    local showSkel  = Config.Visuals.Skeleton
    local showArrow = Config.Visuals.OffScreenArrows
    local showChams = Config.Visuals.Chams
    local enemyCol  = Config.Colors.Enemy
    local hpHigh    = Config.Colors.HealthHigh
    local hpMid     = Config.Colors.HealthMid
    local hpLow     = Config.Colors.HealthLow
    local distCol   = Config.Colors.Distance
    local accentCol = Config.Colors.Accent
    local textSize  = Config.Visuals.TextSize

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not Cache.Draw[p] then
            CreateDrawings(p)
            NameCache[p] = p.Name
            TeamCache[p] = nil
            ToolCache[p]  = "None"
        end
        local char = p.Character
        local root = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"))
        local hum  = char and char:FindFirstChild("Humanoid")
        
        if root and hum and hum.Health > 0 then
            local rootPos = root.Position
            local dist = (camPos - rootPos).Magnitude
            if dist > maxDist then HideAll(p) continue end
            
            local pos, onScreen = Camera:WorldToViewportPoint(rootPos)
            if onScreen then
                local d = Cache.Draw[p]
                -- Oblicz rozmiar boxa przez offset pionowy (2 WorldToViewport zamiast 3)
                local hPos = Camera:WorldToViewportPoint(rootPos + V3_UP25)
                local lPos = Camera:WorldToViewportPoint(rootPos + V3_DOWN3)
                local h    = math.abs(hPos.Y - lPos.Y)
                local w    = h * 0.6
                local bx   = pos.X - w * 0.5
                local by   = hPos.Y
                local bPos = Vector2.new(bx, by)
                
                -- BOX ESP
                local boxWant = showBox and not showCorner
                if d.Box.Visible ~= boxWant then
                    d.Box.Visible = boxWant; d.BoxOut.Visible = boxWant
                end
                if boxWant then
                    d.Box.Position = bPos; d.Box.Size = Vector2.new(w, h); d.Box.Color = enemyCol
                    d.BoxOut.Position = bPos; d.BoxOut.Size = Vector2.new(w, h)
                end
                
                -- CORNER BOX
                local cVis = showBox and showCorner
                if d.Corners[1].Visible ~= cVis then
                    for i = 1, 8 do d.Corners[i].Visible = cVis; d.CornersOut[i].Visible = cVis end
                end
                if cVis then
                    local cl = w * 0.25
                    local c, co = d.Corners, d.CornersOut
                    local bpw = bPos + Vector2.new(w, 0)
                    local bph = bPos + Vector2.new(0, h)
                    local bpwh= bPos + Vector2.new(w, h)
                    c[1].From=bPos;  c[1].To=bPos+Vector2.new(cl,0)
                    c[2].From=bPos;  c[2].To=bPos+Vector2.new(0,cl)
                    c[3].From=bpw;   c[3].To=bpw-Vector2.new(cl,0)
                    c[4].From=bpw;   c[4].To=bpw+Vector2.new(0,cl)
                    c[5].From=bph;   c[5].To=bph+Vector2.new(cl,0)
                    c[6].From=bph;   c[6].To=bph-Vector2.new(0,cl)
                    c[7].From=bpwh;  c[7].To=bpwh-Vector2.new(cl,0)
                    c[8].From=bpwh;  c[8].To=bpwh-Vector2.new(0,cl)
                    for i=1,8 do
                        c[i].Color=enemyCol; co[i].From=c[i].From; co[i].To=c[i].To
                    end
                end

                -- HEALTH BAR
                if d.Health.Visible ~= showHP then
                    d.Health.Visible = showHP; d.HealthBG.Visible = showHP
                end
                if showHP then
                    local pct = hum.Health / hum.MaxHealth
                    local hh  = h * pct
                    d.HealthBG.Position = bPos - Vector2.new(6, 0)
                    d.HealthBG.Size     = Vector2.new(3, h)
                    d.Health.Position   = bPos + Vector2.new(-6, h - hh)
                    d.Health.Size       = Vector2.new(3, hh)
                    d.Health.Color      = pct > 0.6 and hpHigh or (pct > 0.3 and hpMid or hpLow)
                end
                
                -- NAME / DISTANCE / TEAM (drogie stringa - odswiezamy co 10 klatek)
                if d.Tag.Visible ~= showTags then
                    d.Tag.Visible=showTags; d.Dist.Visible=showTags; d.Team.Visible=showTags
                end
                if showTags then
                    d.Tag.Text = NameCache[p] or p.Name
                    d.Tag.Size = textSize
                    d.Tag.Position = Vector2.new(pos.X, by - 15)
                    d.Dist.Text = math.floor(dist) .. "m"
                    d.Dist.Size = textSize - 1
                    d.Dist.Position = Vector2.new(pos.X, by + h + 2)
                    if slowTick then
                        TeamCache[p] = p.Team and ("\xf0\x9f\x91\xa5 " .. p.Team.Name) or "\xf0\x9f\x91\xa5 No Team"
                    end
                    d.Team.Text = TeamCache[p] or "..."
                    d.Team.Size = textSize - 2
                    d.Team.Position = Vector2.new(pos.X, by + h + 14)
                end
                
                -- WEAPON ESP (tylko co 10 klatek - FindFirstChildOfClass jest drogie)
                if d.Weapon.Visible ~= showWep then d.Weapon.Visible = showWep end
                if showWep then
                    if slowTick then
                        local tool = char:FindFirstChildOfClass("Tool")
                        ToolCache[p] = "\xf0\x9f\x94\xab " .. (tool and tool.Name or "None")
                    end
                    d.Weapon.Text = ToolCache[p] or "..."
                    d.Weapon.Size = textSize - 2
                    d.Weapon.Position = Vector2.new(pos.X, by + h + (showTags and 26 or 2))
                end

                -- TRACERS
                if d.Tracer.Visible ~= showTrace then d.Tracer.Visible = showTrace end
                if showTrace then
                    d.Tracer.From  = Vector2.new(halfVpX, vpY)
                    d.Tracer.To    = Vector2.new(pos.X, by + h)
                    d.Tracer.Color = (CurrentT == p) and COL_GREEN or COL_WHITE
                end

                -- CHAMS (Highlight) - tworzymy tylko raz
                if showChams and dist < 800 then
                    if not Cache.Chams[p] then 
                        local hi = Instance.new("Highlight")
                        hi.Parent             = SafeGui
                        hi.Adornee            = char
                        hi.FillColor          = enemyCol
                        hi.FillTransparency   = 0.5
                        hi.OutlineColor       = COL_WHITE
                        hi.OutlineTransparency= 0
                        hi.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
                        Cache.Chams[p] = hi
                    end
                    if not Cache.Chams[p].Enabled then Cache.Chams[p].Enabled = true end
                elseif Cache.Chams[p] and Cache.Chams[p].Enabled then 
                    Cache.Chams[p].Enabled = false 
                end

                -- SKELETON ESP
                if d.Skeleton[1].Visible ~= showSkel then for _,l in pairs(d.Skeleton) do l.Visible = showSkel end end
                if showSkel then
                    for i, bone in pairs(SkeletonConns) do
                        local b1, b2 = char:FindFirstChild(bone[1]), char:FindFirstChild(bone[2])
                        if b1 and b2 then
                            local p1, o1 = Camera:WorldToViewportPoint(b1.Position)
                            local p2, o2 = Camera:WorldToViewportPoint(b2.Position)
                            if o1 and o2 then
                                d.Skeleton[i].From = Vector2.new(p1.X, p1.Y)
                                d.Skeleton[i].To   = Vector2.new(p2.X, p2.Y)
                                d.Skeleton[i].Color = enemyCol
                            else d.Skeleton[i].Visible = false end
                        else d.Skeleton[i].Visible = false end
                    end
                end

                -- OFF-SCREEN ARROWS
                d.Arrows.Visible = false -- Resetuj na ekranie
            else 
                HideAll(p)
                -- Pokaż strzałkę jeśli gracz jest poza ekranem, ale w zasięgu
                if showArrow and dist < maxDist then
                    local d = Cache.Draw[p]
                    local relativePos = Camera.CFrame:PointToObjectSpace(rootPos)
                    local angle = math.atan2(-relativePos.X, relativePos.Z)
                    local arrowSize = 15
                    local arrowRadius = 200
                    
                    local center = Vector2.new(halfVpX, vpY * 0.5)
                    local dir = Vector2.new(math.sin(angle), math.cos(angle))
                    local pos = center + dir * arrowRadius
                    
                    d.Arrows.PointA = pos + dir * arrowSize
                    d.Arrows.PointB = pos + Vector2.new(dir.Y, -dir.X) * (arrowSize * 0.6)
                    d.Arrows.PointC = pos + Vector2.new(-dir.Y, dir.X) * (arrowSize * 0.6)
                    d.Arrows.Visible = true
                end
            end
        else HideAll(p) end
    end
    
    -- FULLBRIGHT Logic
    if Config.Misc.Fullbright then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").OutdoorAmbient = Color3.new(1,1,1)
    end
    
    -- CROSSHAIR Logic
    local chVis = Config.Visuals.Crosshair
    for _, l in pairs(CrossLines) do l.Visible = chVis end
    if chVis then
        local m = UserInputService:GetMouseLocation()
        local s = 6
        local g = 3
        CrossLines[1].From = m + Vector2.new(0, g); CrossLines[1].To = m + Vector2.new(0, s + g)
        CrossLines[2].From = m - Vector2.new(0, g); CrossLines[2].To = m - Vector2.new(0, s + g)
        CrossLines[3].From = m + Vector2.new(g, 0); CrossLines[3].To = m + Vector2.new(s + g, 0)
        CrossLines[4].From = m - Vector2.new(g, 0); CrossLines[4].To = m - Vector2.new(s + g, 0)
    end
    -- STREAMPROOF Logic
    ScreenGui.DisplayOrder = Config.Misc.Streamproof and -100 or 10
    
    -- HITBOX EXPANDER Logic
    if slowTick and Config.Misc.ExpandHitbox then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local head = p.Character:FindFirstChild("Head")
                if head then
                    head.Size = Vector3.new(Config.Misc.HitboxSize, Config.Misc.HitboxSize, Config.Misc.HitboxSize)
                    head.Transparency = 0.5
                    head.CanCollide = false
                end
            end
        end
    end
end)
table.insert(getgenv().SolarConnections, ESP_Loop)
Players.PlayerRemoving:Connect(RemovePlayer)

-- ==============================================================================
--[ AIMBOT v5 ]
-- ==============================================================================


-- Dane balistyczne broni (Speed = prędkość pocisku w studs/s, Gravity = opad kuli)
-- Wartości skalibrowane pod AR2 (1 stud ≈ 0.28m, silnik Roblox)
local WeaponData = {
    -- ===== SNAJPERKI =====
    ["L96A1"]       = {Speed = 4000, Gravity = 150},
    ["M24"]         = {Speed = 3800, Gravity = 160},
    ["AWP"]         = {Speed = 4200, Gravity = 140},
    ["Kar98k"]      = {Speed = 3600, Gravity = 170},
    ["SVD"]         = {Speed = 3500, Gravity = 175},
    ["Dragunov"]    = {Speed = 3500, Gravity = 175},
    ["Mosin"]       = {Speed = 3700, Gravity = 165},
    -- ===== DMR =====
    ["SKS"]         = {Speed = 3200, Gravity = 180},
    ["M14"]         = {Speed = 3000, Gravity = 185},
    ["Mk14"]        = {Speed = 3100, Gravity = 180},
    -- ===== KARABINY SZTURMOWE =====
    -- AK-47 (7.62x39mm - wolniejsza, cięższa kula, większy opad)
    ["AK-47"]       = {Speed = 2620, Gravity = 210},
    ["AK47"]        = {Speed = 2620, Gravity = 210},
    -- AK-74 (5.45x39mm - szybsza, lżejsza kula, mniejszy opad)
    -- Priorytet: DOKŁADNE wartości pod AR2
    ["AK-74"]       = {Speed = 2950, Gravity = 190},
    ["AK74"]        = {Speed = 2950, Gravity = 190},
    -- AKS-74 (składana kolba, identyczna balistyka co AK-74)
    ["AKS-74"]      = {Speed = 2950, Gravity = 190},
    ["AKS74"]       = {Speed = 2950, Gravity = 190},
    ["AKS 74"]      = {Speed = 2950, Gravity = 190},
    -- AKS-74U (skrócona lufa = niższa prędkość)
    ["AKS-74U"]     = {Speed = 2600, Gravity = 196},
    ["AKS74U"]      = {Speed = 2600, Gravity = 196},
    -- AUG (Steyr AUG, 5.56x45mm NATO - wysoka prędkość, mały opad)
    ["AUG"]         = {Speed = 3100, Gravity = 185},
    ["Steyr AUG"]   = {Speed = 3100, Gravity = 185},
    ["AUG A1"]      = {Speed = 3100, Gravity = 185},
    ["AUG A3"]      = {Speed = 3100, Gravity = 185},
    -- M4/M16 (5.56x45mm NATO)
    ["M4A1"]        = {Speed = 2950, Gravity = 188},
    ["M4"]          = {Speed = 2950, Gravity = 188},
    ["HK416"]       = {Speed = 3050, Gravity = 185},
    ["SCAR-L"]      = {Speed = 2900, Gravity = 190},
    ["M16A4"]       = {Speed = 3000, Gravity = 186},
    ["FN FAL"]      = {Speed = 2750, Gravity = 200},
    -- ===== SMG =====
    ["MP5"]         = {Speed = 2400, Gravity = 210},
    ["UMP45"]       = {Speed = 2100, Gravity = 220},
    ["Vector"]      = {Speed = 2000, Gravity = 215},
    ["P90"]         = {Speed = 2400, Gravity = 205},
    -- ===== SHOTGUNY =====
    ["M870"]        = {Speed = 1500, Gravity = 280},
    ["SPAS-12"]     = {Speed = 1400, Gravity = 285},
    ["Shotgun"]     = {Speed = 1450, Gravity = 280},
}

-- Tabela częściowych dopasowań nazw (fuzzy matching dla AR2)
-- AR2 używa różnych wewnętrznych nazw narzędzi
local WeaponFuzzy = {
    {pattern = "AKS.?74U",  data = {Speed = 2600, Gravity = 196}},
    {pattern = "AKS.?74",   data = {Speed = 2950, Gravity = 190}},  -- AKS-74 musi być PRZED AK-74
    {pattern = "AK.?74",    data = {Speed = 2950, Gravity = 190}},
    {pattern = "AK.?47",    data = {Speed = 2620, Gravity = 210}},
    {pattern = "AUG",       data = {Speed = 3100, Gravity = 185}},
    {pattern = "M4",        data = {Speed = 2950, Gravity = 188}},
    {pattern = "HK4",       data = {Speed = 3050, Gravity = 185}},
    {pattern = "SCAR",      data = {Speed = 2900, Gravity = 190}},
    {pattern = "SVD",       data = {Speed = 3500, Gravity = 175}},
    {pattern = "Dragunov",  data = {Speed = 3500, Gravity = 175}},
    {pattern = "L96",       data = {Speed = 4000, Gravity = 150}},
    {pattern = "M24",       data = {Speed = 3800, Gravity = 160}},
    {pattern = "AWP",       data = {Speed = 4200, Gravity = 140}},
    {pattern = "Kar98",     data = {Speed = 3600, Gravity = 170}},
    {pattern = "SKS",       data = {Speed = 3200, Gravity = 180}},
    {pattern = "MP5",       data = {Speed = 2400, Gravity = 210}},
    {pattern = "UMP",       data = {Speed = 2100, Gravity = 220}},
    {pattern = "Vector",    data = {Speed = 2000, Gravity = 215}},
    {pattern = "P90",       data = {Speed = 2400, Gravity = 205}},
    {pattern = "Shotgun",   data = {Speed = 1450, Gravity = 280}},
    {pattern = "M870",      data = {Speed = 1500, Gravity = 280}},
    {pattern = "SPAS",      data = {Speed = 1400, Gravity = 285}},
}

local function UpdateAim()
    if not Config.Combat.AutoCalibration then return end
    local char = LocalPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local name = tool.Name
    -- Najpierw: dokładne dopasowanie (szybsze)
    local s = WeaponData[name]
    if s then
        Config.Combat.BulletSpeed = s.Speed
        Config.Combat.BulletGravity = s.Gravity
        return
    end
    -- Potem: fuzzy matching (dla niestandardowych nazw w AR2)
    for _, entry in ipairs(WeaponFuzzy) do
        if name:match(entry.pattern) then
            Config.Combat.BulletSpeed = entry.data.Speed
            Config.Combat.BulletGravity = entry.data.Gravity
            return
        end
    end
end

-- Cachujemy RaycastParams raz (eliminuje GC pressure - duży boost FPS)
local _rayParams = RaycastParams.new()
_rayParams.FilterType = Enum.RaycastFilterType.Exclude
_rayParams.IgnoreWater = true

local function IsVisible(targetPart)
    if not targetPart then return false end
    -- Aktualizujemy listę filtrów (character może się zmienić)
    _rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local rayOrigin = Camera.CFrame.Position
    local rayDir = (targetPart.Position - rayOrigin)
    local result = Workspace:Raycast(rayOrigin, rayDir, _rayParams)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

local function GetClosest()
    local bestTarget = nil
    local bestMag = Config.Combat.FOV
    local bestPhysTarget = nil
    local bestPhysDist = 50 -- Tylko dystans do 50m jako ostateczność (Panic Mode)
    local m = UserInputService:GetMouseLocation()
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            local root = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"))
            local hum = char and char:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local physDist = (root.Position - Camera.CFrame.Position).Magnitude
                
                local head = char:FindFirstChild("Head")
                local torso = char:FindFirstChild("UpperTorso")
                local part = nil
                local vis = false
                
                -- STRICT HEAD PRIORITY
                if Config.Combat.DynamicAim then
                    if head and IsVisible(head) then part = head; vis = true
                    elseif torso and IsVisible(torso) then part = torso; vis = true
                    else part = head or char.PrimaryPart end
                else
                    part = char:FindFirstChild(Config.Combat.AimPart)
                    vis = part and IsVisible(part)
                end
                
                if part then
                    local pos, on = Camera:WorldToViewportPoint(part.Position)
                    local mag = on and (Vector2.new(pos.X, pos.Y) - m).Magnitude or math.huge
                    
                    -- Zawsze faworyzujemy cel na ekranie blisko celownika
                    if on and mag < bestMag then
                        if not Config.Combat.WallCheck or vis then
                            bestTarget = p
                            bestMag = mag
                        end
                    end
                    
                    -- Jeśli nikt nie jest na ekranie, zapisujemy najbliższego fizycznie (<50m)
                    if physDist < bestPhysDist then
                        bestPhysTarget = p
                        bestPhysDist = physDist
                    end
                end
            end
        end
    end
    
    -- Zwraca cel z celownika, albo (jeśli brak) kogoś kto zaszedł nas od tyłu
    return bestTarget or bestPhysTarget
end

table.insert(getgenv().SolarConnections, UserInputService.InputBegan:Connect(function(i) if not listening and (i.UserInputType == Config.Combat.AimKey or i.KeyCode == Config.Combat.AimKey) then Config.State.Aiming = true end end))
table.insert(getgenv().SolarConnections, UserInputService.InputEnded:Connect(function(i) if (i.UserInputType == Config.Combat.AimKey or i.KeyCode == Config.Combat.AimKey) then Config.State.Aiming = false end end))

local AimLoop = RunService.RenderStepped:Connect(function()
    if Config.State.Unloaded then return end
    
    local fovRing = getgenv().FOVRing
    if fovRing then
        fovRing.Visible = Config.Combat.ShowFOV
        fovRing.Radius  = Config.Combat.FOV
        fovRing.Position = UserInputService:GetMouseLocation()
        fovRing.Color   = Config.Colors.Main
    end
    
    if Config.State.Aiming and Config.Combat.AimAssist then
        UpdateAim()
        local char = CurrentT and CurrentT.Character
        local hum  = char and char:FindFirstChild("Humanoid")
        
        -- TARGET LOCK: Dopóki cel żyje i trzymamy bind (dla zwykłego Aima) lub zawsze (dla Silent), nie zmieniamy celu zbyt pochopnie
        if not CurrentT or not char or not hum or hum.Health <= 0 then
            CurrentT = GetClosest()
        end
        char = CurrentT and CurrentT.Character
        hum = char and char:FindFirstChild("Humanoid")
        
        if char and hum and hum.Health > 0 then
            -- Wybierz part do celowania (Zawsze Head jeśli widoczna)
            local part = nil
            local head = char:FindFirstChild("Head")
            local torso = char:FindFirstChild("UpperTorso")
            
            if Config.Combat.DynamicAim then
                if head and IsVisible(head) then part = head
                elseif torso and IsVisible(torso) then part = torso
                else part = head or char.PrimaryPart end
            else
                part = char:FindFirstChild(Config.Combat.AimPart)
            end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            if part and root then
                local aimP = part.Position
                
                if Config.Combat.AdvancedPrediction then
                    local camPos = Camera.CFrame.Position
                    local d  = (camPos - aimP).Magnitude
                    local t  = d / math.max(Config.Combat.BulletSpeed, 500)
                    local vel = root.AssemblyLinearVelocity
                    if vel.Magnitude > 250 then vel = vel.Unit * 250 end
                    
                    local pred1 = aimP + vel * t
                    local d2 = (camPos - pred1).Magnitude
                    local t2 = d2 / math.max(Config.Combat.BulletSpeed, 500)
                    
                    local lead = vel * (t2 * Config.Combat.PredictionMult)
                    local drop = Vector3.new(0, 0.5 * Config.Combat.BulletGravity * (t2 * t2), 0)
                    
                    -- KOMPENSACJA SKOKU: Jeśli cel jest w powietrzu, spada z przyspieszeniem grawitacyjnym
                    local targetGravity = Vector3.new(0, 0, 0)
                    if hum.FloorMaterial == Enum.Material.Air then
                        targetGravity = Vector3.new(0, 0.5 * workspace.Gravity * (t2 * t2), 0)
                    end
                    
                    aimP = aimP + lead - targetGravity + drop
                end
                
                -- Aktualizujemy globalną pozycję dla Silent Aima
                getgenv().PredictedPosition = aimP
                
                local scr, on = Camera:WorldToViewportPoint(aimP)
                local physDist = (root.Position - Camera.CFrame.Position).Magnitude
                
                -- Jeśli uzywamy Silent Aim, omijamy przesuwanie myszki z AimLoop
                if Config.Combat.SilentAim then
                    -- Silent Aim załatwi to przez hooka, tu tylko celownik/obliczenia są potrzebne
                    return
                end
                
                if on then
                    local m  = UserInputService:GetMouseLocation()
                    local dx = scr.X - m.X
                    local dy = scr.Y - m.Y
                    
                    -- Dynamiczne wygładzanie ruchu
                    local dist = math.sqrt(dx*dx + dy*dy)
                    local dynSmooth = Config.Combat.Smoothness
                    local mx, my = 0, 0
                    
                    if dynSmooth >= 1 then
                        -- TRYB ABSOLUTNY (MAX SPEED): Brak zwalniania, brak blokad prędkości. 
                        -- Idealnie przykleja celownik do głowy, nigdy jej nie gubi.
                        mx = dx
                        my = dy
                    else
                        -- TRYB LEGIT (Smoothness < 1): Płynne dojeżdżanie z deadzonem
                        if dist < 25 then
                            dynSmooth = dynSmooth * math.max(0.2, (dist / 25))
                        end
                        
                        mx = dx * dynSmooth
                        my = dy * dynSmooth
                        
                        if dist > 1.5 then
                            if math.abs(mx) > 0 and math.abs(mx) < 1 then mx = math.sign(dx) end
                            if math.abs(my) > 0 and math.abs(my) < 1 then my = math.sign(dy) end
                        else
                            mx, my = 0, 0
                        end
                        
                        -- Clamp tylko dla trybu Legit żeby nie rzucało ekranem
                        mx = math.clamp(mx, -100, 100)
                        my = math.clamp(my, -100, 100)
                    end
                    
                    -- Legit RCS: Jeśli strzelasz, dodajemy dodatkowy ruch w dół
                    if Config.Combat.LegitRCS and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        my = my + Config.Combat.RCSStrength
                    end
                    
                    if mousemoverel and (mx ~= 0 or my ~= 0) then mousemoverel(mx, my) end
                elseif physDist <= 50 then
                    -- CEL ZA PLECAMI (Panic Mode): Używamy CFrame żeby uniknąć wywalania myszy o 180 stopni (bug mousemoverel)
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, aimP)
                else
                    CurrentT = nil
                end
            end
        end
    else
        CurrentT = nil
    end
end)
table.insert(getgenv().SolarConnections, AimLoop)

-- ==============================================================================
--[ SILENT AIM HOOK (MAGIC BULLETS) ]
-- ==============================================================================
getgenv().PredictedPosition = nil

if getrawmetatable and setreadonly then
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    if setreadonly then setreadonly(mt, false) end
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Hookujemy Raycast (najpopularniejsza metoda detekcji strzałów)
        if method == "Raycast" and Config.Combat.SilentAim and Config.State.Aiming and getgenv().PredictedPosition then
            -- Sprawdzamy czy to Raycast od broni gracza (zwykle używają workspace:Raycast)
            -- Sprawdzamy też czy Raycast wychodzi z kamery lub z lufy broni
            local origin = args[1]
            local direction = args[2]
            
            -- Jeśli origin to prawdopodobnie lufa lub kamera, zmieniamy direction na głowę celu
            if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
                -- Omijamy raycasty UI lub inne systemy
                local camPos = Camera.CFrame.Position
                local distToOrigin = (origin - camPos).Magnitude
                
                if distToOrigin < 15 then -- Origin jest blisko naszej postaci
                    args[2] = (getgenv().PredictedPosition - origin).Unit * direction.Magnitude
                    return oldNamecall(self, unpack(args))
                end
            end
        end
        
        -- Fallback: Hookujemy FindPartOnRayWithIgnoreList (Stary system często używany przez AR2)
        if method == "FindPartOnRayWithIgnoreList" and Config.Combat.SilentAim and Config.State.Aiming and getgenv().PredictedPosition then
            local ray = args[1]
            if typeof(ray) == "Ray" then
                local origin = ray.Origin
                local camPos = Camera.CFrame.Position
                local distToOrigin = (origin - camPos).Magnitude
                
                if distToOrigin < 15 then
                    local newDirection = (getgenv().PredictedPosition - origin).Unit * ray.Direction.Magnitude
                    args[1] = Ray.new(origin, newDirection)
                    return oldNamecall(self, unpack(args))
                end
            end
        end

        return oldNamecall(self, ...)
    end)
    
    if setreadonly then setreadonly(mt, true) end
end

table.insert(getgenv().SolarConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Space and Config.Misc.HighJump and not Config.State.Unloaded then
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if root and hum and hum.FloorMaterial ~= Enum.Material.Air then
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, Config.Misc.JumpPower, root.AssemblyLinearVelocity.Z)
        end
    end
end))

-- Obiekty fizyczne do lotu pojazdu (tworzone/usuwane dynamicznie)
local FlyBV = nil  -- BodyVelocity - kontroluje prędkość
local FlyBG = nil  -- BodyGyro - stabilizuje rotację (nie dachuje)
local FlyTarget = nil -- Aktualny PrimaryPart pojazdu

local function DestroyFlyObjects()
    if FlyBV then pcall(function() FlyBV:Destroy() end); FlyBV = nil end
    if FlyBG then pcall(function() FlyBG:Destroy() end); FlyBG = nil end
    FlyTarget = nil
end

local function CreateFlyObjects(root)
    if FlyTarget == root then return end
    DestroyFlyObjects()
    FlyTarget = root
    
    -- BodyVelocity: MaxForce = 9e9 żeby masa pojazdu nie ściągała w dół
    FlyBV = Instance.new("BodyVelocity")
    FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBV.Velocity = Vector3.new(0, 0, 0)
    FlyBV.P = 9e4 -- Siła proporcjonalna - wystarczająca do szybkiej odpowiedzi
    FlyBV.Parent = root
    
    -- BodyGyro: blokuje rotację samochodu, żeby nie dachował
    FlyBG = Instance.new("BodyGyro")
    FlyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBG.P = 9e4
    FlyBG.D = 1000 -- Tłumienie oscylacji
    FlyBG.CFrame = root.CFrame -- Zamraża aktualną orientację
    FlyBG.Parent = root
end

local MiscLoop = RunService.Heartbeat:Connect(function()
    if Config.State.Unloaded then DestroyFlyObjects(); return end
    
    if Config.Misc.VehicleFly then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        
        -- Sprawdzamy czy gracz siedzi w aucie (VehicleSeat)
        if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
            local vehicle = hum.SeatPart:FindFirstAncestorOfClass("Model")
            local root = vehicle and (vehicle.PrimaryPart or hum.SeatPart) or hum.SeatPart
            
            if root then
                CreateFlyObjects(root)
                
                local cam = Workspace.CurrentCamera
                -- Usuwamy składową pionową z wektorów kamery (płaski ruch poziomy)
                local lookFlat = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z).Unit
                local rightFlat = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z).Unit
                
                local moveDir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + lookFlat end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - lookFlat end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - rightFlat end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + rightFlat end
                
                -- Normalizacja kierunku poziomego jeśli jest ruch
                if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
                
                local targetVel = moveDir * Config.Misc.FlySpeed
                -- Ruch pionowy
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    targetVel = targetVel + Vector3.new(0, Config.Misc.FlySpeed, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    targetVel = targetVel - Vector3.new(0, Config.Misc.FlySpeed, 0)
                end
                
                -- Aktualizacja BodyVelocity
                if FlyBV then FlyBV.Velocity = targetVel end
                -- Zamrożenie rotacji - BodyGyro utrzymuje poziomą orientację
                if FlyBG then FlyBG.CFrame = CFrame.new(root.Position) end
            end
        else
            -- Gracz wysiadł lub nigdy nie siedział w aucie - czyścimy obiekty
            if FlyBV or FlyBG then DestroyFlyObjects() end
        end
    else
        -- Tryb wyłączony - usuwamy obiekty fizyczne
        if FlyBV or FlyBG then DestroyFlyObjects() end
    end
end)
table.insert(getgenv().SolarConnections, MiscLoop)

local TriggerLoop = RunService.RenderStepped:Connect(function()
    if Config.State.Unloaded or not Config.Combat.TriggerBot then return end
    local m = UserInputService:GetMouseLocation()
    local rayOrigin = Camera.CFrame.Position
    local rayDirection = Camera:ScreenPointToRay(m.X, m.Y).Direction * 5000
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    rayParams.IgnoreWater = true
    
    local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, rayParams)
    if raycastResult and raycastResult.Instance then
        local model = raycastResult.Instance:FindFirstAncestorOfClass("Model")
        if model and Players:GetPlayerFromCharacter(model) and model ~= LocalPlayer.Character then
            local hum = model:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                if mouse1click then mouse1click() end
                task.wait(0.05)
            end
        end
    end
end)
table.insert(getgenv().SolarConnections, TriggerLoop)

-- ==============================================================================
--[ HELICOPTER ESP v5 ]
-- ==============================================================================

-- Słowa kluczowe identyfikujące helikoptery w grze
local HELI_KEYWORDS = {"Helicopter", "Heli", "Chopper", "Aircraft", "UH", "Blackhawk"}
-- Słowa kluczowe dla militarnych/czarnych helikopterów
local MILITARY_KEYWORDS = {"Black", "Military", "Armed", "Combat", "Attack"}

-- Cache rysunków helikopterów
local HeliCache = {}

-- Sprawdza czy model jest helikopterem na podstawie nazwy
local function IsHelicopter(model)
    local name = model.Name:lower()
    for _, kw in ipairs(HELI_KEYWORDS) do
        if name:find(kw:lower()) then return true end
    end
    return false
end

-- Sprawdza czy helikopter jest militarny
local function IsMilitary(model)
    local name = model.Name:lower()
    for _, kw in ipairs(MILITARY_KEYWORDS) do
        if name:find(kw:lower()) then return true end
    end
    return false
end

-- Tworzy obiekty Drawing dla helikoptera
local function CreateHeliDrawings(heli)
    local d = {
        Box    = Drawing.new("Square"),
        BoxOut = Drawing.new("Square"),
        Label  = Drawing.new("Text"),
        Dist   = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
    }
    d.Box.Thickness = 1; d.Box.Filled = false
    d.BoxOut.Thickness = 3; d.BoxOut.Filled = false; d.BoxOut.Color = Color3.new(0,0,0)
    d.Label.Size = 14; d.Label.Center = true; d.Label.Outline = true; d.Label.Font = 2
    d.Dist.Size = 12; d.Dist.Center = true; d.Dist.Outline = true; d.Dist.Font = 2; d.Dist.Color = Color3.fromRGB(255, 215, 0)
    d.Tracer.Thickness = 1
    HeliCache[heli] = d
end

-- Usuwa rysunki helikoptera
local function RemoveHeliDrawings(heli)
    if HeliCache[heli] then
        for _, v in pairs(HeliCache[heli]) do pcall(function() v:Remove() end) end
        HeliCache[heli] = nil
    end
end

-- Ukrywa rysunki bez usuwania (optymalizacja)
local function HideHeliDrawings(heli)
    local d = HeliCache[heli]
    if d then
        for _, v in pairs(d) do
            if type(v) ~= "table" and v.Visible then v.Visible = false end
        end
    end
end

-- Główna pętla Helicopter ESP
local HeliESP_Loop = RunService.RenderStepped:Connect(function()
    if Config.State.Unloaded then
        for heli, _ in pairs(HeliCache) do RemoveHeliDrawings(heli) end
        return
    end

    -- Budujemy zestaw aktywnych helikopterów z Workspace
    local activeHelis = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and IsHelicopter(obj) then
            activeHelis[obj] = true
        end
    end
    -- Sprawdź też Workspace.Vehicles jeśli istnieje
    local vehicleFolder = Workspace:FindFirstChild("Vehicles")
    if vehicleFolder then
        for _, obj in ipairs(vehicleFolder:GetChildren()) do
            if obj:IsA("Model") and IsHelicopter(obj) then
                activeHelis[obj] = true
            end
        end
    end

    -- Wyczyść helikoptery, które zniknęły z mapy (eksplodowały)
    for heli, _ in pairs(HeliCache) do
        if not activeHelis[heli] or not heli.Parent then
            RemoveHeliDrawings(heli)
        end
    end

    if not Config.Visuals.HeliESP then
        for heli, _ in pairs(HeliCache) do HideHeliDrawings(heli) end
        return
    end

    local camPos = Camera.CFrame.Position
    local vp = Camera.ViewportSize

    for heli, _ in pairs(activeHelis) do
        -- Utwórz cache jeśli nie istnieje
        if not HeliCache[heli] then CreateHeliDrawings(heli) end
        local d = HeliCache[heli]

        local root = heli.PrimaryPart or heli:FindFirstChildWhichIsA("BasePart")
        if not root then HideHeliDrawings(heli); continue end

        local dist = (root.Position - camPos).Magnitude
        if dist > Config.Visuals.HeliMaxDistance then HideHeliDrawings(heli); continue end

        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then HideHeliDrawings(heli); continue end

        -- Kolor zależny od typu: militarny = fiolet, normalny = zielony
        local heliColor = IsMilitary(heli)
            and Color3.fromRGB(180, 0, 255)  -- Głęboki fiolet dla militarnych
            or  Color3.fromRGB(0, 255, 80)   -- Jasny zielony dla cywilnych

        -- Oblicz rozmiar boxa ESP na podstawie dystansu
        local size = math.clamp(1500 / dist, 20, 300)
        local w = size * 1.6
        local h = size
        local bPos = Vector2.new(pos.X - w/2, pos.Y - h/2)

        -- Rysuj Box
        d.BoxOut.Visible = true
        d.BoxOut.Position = bPos
        d.BoxOut.Size = Vector2.new(w, h)
        d.Box.Visible = true
        d.Box.Position = bPos
        d.Box.Size = Vector2.new(w, h)
        d.Box.Color = heliColor

        -- Etykieta z nazwą
        d.Label.Visible = true
        d.Label.Text = "🚁 " .. heli.Name
        d.Label.Position = Vector2.new(pos.X, bPos.Y - 18)
        d.Label.Color = heliColor

        -- Dystans
        d.Dist.Visible = true
        d.Dist.Text = math.floor(dist) .. "m"
        d.Dist.Position = Vector2.new(pos.X, bPos.Y + h + 2)

        -- Tracer od dołu ekranu do helikoptera
        d.Tracer.Visible = Config.Visuals.HeliTracers
        if d.Tracer.Visible then
            d.Tracer.From = Vector2.new(vp.X / 2, vp.Y)
            d.Tracer.To = Vector2.new(pos.X, pos.Y)
            d.Tracer.Color = heliColor
            d.Tracer.Thickness = 1
        end
    end
end)
table.insert(getgenv().SolarConnections, HeliESP_Loop)

print("========================================")
print("   SOLARA AR2 ELITE v5 ZAŁADOWANA!   ")
print("   Zoptymalizowano FPS i ESP         ")
print("========================================")