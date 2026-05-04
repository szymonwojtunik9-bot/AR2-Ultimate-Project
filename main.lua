-- ==============================================================================
--[ AR2 ULTIMATE PRO - v6 (SOLARA v3 OPTIMIZED) ]
-- Naprawiono: continue, dup config, FOVRing, memory leaks, performance
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
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

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
--[ KONFIGURACJA v6 (naprawiono duplikaty) ]
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
        ESP_FPS_Limit = 1,
        BulletTracers = false,
    },
    Combat = {
        AimAssist = true,
        AimKey = Enum.UserInputType.MouseButton2,
        ShowFOV = true,
        FOV = 150,
        MaxDistance = 3000,
        Smoothness = 1,
        AimPart = "Head",
        WallCheck = false,
        TeamCheck = false,
        AdvancedPrediction = true,
        PredictionMult = 1,
        DynamicAim = true,
        TriggerBot = false,
        AutoCalibration = true,
        LegitRCS = false,
        SilentAim = false,
        RCSStrength = 5,
        BulletSpeed = 3000,
        BulletGravity = 45,
        GravityScale = 1,
        VerticalOffset = 0,
        HitSound = false,
    },
    Misc = {
        HighJump = false,
        JumpPower = 50,
        VehicleFly = false,
        FlySpeed = 50,
        Fullbright = false,
        HitboxSize = 2,
        ExpandHitbox = false,
        Streamproof = false,
        FakeLag = false,
        SpeedHack = false,
        SpeedMultiplier = 1.2,
        TurboFPS = false,
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
        Distance = Color3.fromRGB(255, 215, 0),
        HealthHigh = Color3.fromRGB(100, 255, 100),
        HealthMid = Color3.fromRGB(200, 200, 100),
        HealthLow = Color3.fromRGB(255, 100, 100),
    },
    State = { Aiming = false, Unloaded = false, Rainbow = true }
}
local Config = getgenv().SolarConfig

-- Solara v3: sprawdź czy mousemoverel istnieje (niektóre executory go nie mają)
local HAS_MOUSE_MOVE = (type(mousemoverel) == "function")
local HAS_MOUSE_CLICK = (type(mouse1click) == "function")

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2), props):Play()
end

local function Round(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r or 6)
    return c
end

-- Cache oryginalnych ustawień (do resetu)
local OriginalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}
local OriginalHeadSizes = {}
local OriginalHeadColors = {}
local OriginalHeadMats = {}

-- ==============================================================================
--[ UI v6 ]
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SolarMenu_v6"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = SafeGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 400)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -200)
MainFrame.BackgroundColor3 = Config.Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
Round(MainFrame, 10)
Instance.new("UIStroke", MainFrame).Color = Config.Colors.Main

-- Dragging
local dragT, dragS, startP
MainFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragT = true
        dragS = i.Position
        startP = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement and dragT then
        local d = i.Position - dragS
        MainFrame.Position = UDim2.new(startP.X.Scale, startP.X.Offset + d.X, startP.Y.Scale, startP.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragT = false
    end
end)

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Config.Colors.Section
Sidebar.BorderSizePixel = 0
Round(Sidebar, 10)

local SideFix = Instance.new("Frame", Sidebar)
SideFix.Size = UDim2.new(0, 10, 1, 0)
SideFix.Position = UDim2.new(1, -10, 0, 0)
SideFix.BackgroundColor3 = Config.Colors.Section
Sidebar.ZIndex = 2

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, -150, 1, -20)
Content.Position = UDim2.new(0, 150, 0, 10)
Content.BackgroundTransparency = 1

-- Rainbow Footer Logic (Xeno style)
local Footer = Instance.new("TextLabel", Sidebar)
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.BackgroundTransparency = 1
Footer.Text = "Made by Antigravity x Xeno"
Footer.Font = Enum.Font.GothamBold
Footer.TextSize = 11
Footer.TextColor3 = Config.Colors.Main

task.spawn(function()
    local _hue = 0
    while true do
        task.wait(0.03)
        if Config.State.Unloaded then break end
        if Config.State.Rainbow then
            _hue = _hue + 0.005
            if _hue > 1 then _hue = _hue - 1 end
            Footer.TextColor3 = Color3.fromHSV(_hue, 0.8, 1)
        end
    end
end)

local Tabs = {}
local TabFrames = {}

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
    for name, b in pairs(Tabs) do
        if name == n then
            Tween(b, {BackgroundColor3 = Config.Colors.Main, TextColor3 = Color3.new(1,1,1)})
        else
            Tween(b, {BackgroundColor3 = Config.Colors.Element, TextColor3 = Config.Colors.TextDark})
        end
    end
end

local function CreateTab(n)
    local B = Instance.new("TextButton", Sidebar)
    B.Size = UDim2.new(0, 120, 0, 35)
    B.BackgroundColor3 = Config.Colors.Element
    B.Text = n
    B.Font = Enum.Font.GothamBold
    B.TextColor3 = Config.Colors.TextDark
    B.TextSize = 13
    B.AutoButtonColor = false
    Round(B, 6)

    local F = Instance.new("CanvasGroup", Content)
    F.Size = UDim2.new(1, 0, 1, 0)
    F.BackgroundTransparency = 1
    F.Visible = false

    local SC = Instance.new("ScrollingFrame", F)
    SC.Size = UDim2.new(1, 0, 1, 0)
    SC.BackgroundTransparency = 1
    SC.ScrollBarThickness = 2
    SC.BorderSizePixel = 0

    local L = Instance.new("UIListLayout", SC)
    L.Padding = UDim.new(0, 8)
    L.HorizontalAlignment = Enum.HorizontalAlignment.Center
    L:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SC.CanvasSize = UDim2.new(0, 0, 0, L.AbsoluteContentSize.Y + 10)
    end)

    Tabs[n] = B
    TabFrames[n] = F
    B.MouseButton1Click:Connect(function()
        SelectTab(n)
    end)
    return SC
end

local TabListL = Instance.new("UIListLayout", Sidebar)
TabListL.Padding = UDim.new(0, 5)
TabListL.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListL.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 50)

local function CreateToggle(p, t, k, c)
    local B = Instance.new("TextButton", p)
    B.Size = UDim2.new(1, -10, 0, 38)
    B.BackgroundColor3 = Config.Colors.Section
    B.Text = ""
    Round(B, 6)

    local L = Instance.new("TextLabel", B)
    L.Size = UDim2.new(1, -60, 1, 0)
    L.Position = UDim2.new(0, 12, 0, 0)
    L.Text = t
    L.Font = Enum.Font.Gotham
    L.TextColor3 = Config.Colors.Text
    L.TextSize = 13
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1

    local SB = Instance.new("Frame", B)
    SB.Size = UDim2.new(0, 32, 0, 16)
    SB.Position = UDim2.new(1, -40, 0.5, -8)
    SB.BackgroundColor3 = Config[c][k] and Config.Colors.Main or Config.Colors.Element
    Round(SB, 8)

    local SK = Instance.new("Frame", SB)
    SK.Size = UDim2.new(0, 12, 0, 12)
    SK.Position = Config[c][k] and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    SK.BackgroundColor3 = Color3.new(1,1,1)
    Round(SK, 6)

    B.MouseButton1Click:Connect(function()
        local s = not Config[c][k]
        Config[c][k] = s
        Tween(SB, {BackgroundColor3 = s and Config.Colors.Main or Config.Colors.Element}, 0.2)
        Tween(SK, {Position = s and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}, 0.2)
    end)
end

local function CreateSlider(p, t, c, k, min, max, float)
    local Cont = Instance.new("Frame", p)
    Cont.Size = UDim2.new(1, -10, 0, 45)
    Cont.BackgroundColor3 = Config.Colors.Section
    Round(Cont, 6)

    local L = Instance.new("TextLabel", Cont)
    L.Size = UDim2.new(1, -20, 0, 18)
    L.Position = UDim2.new(0, 12, 0, 4)
    L.Text = t
    L.Font = Enum.Font.Gotham
    L.TextColor3 = Config.Colors.Text
    L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1

    local VL = Instance.new("TextLabel", Cont)
    VL.Size = UDim2.new(0, 40, 0, 18)
    VL.Position = UDim2.new(1, -50, 0, 4)
    VL.Text = tostring(Config[c][k])
    VL.Font = Enum.Font.GothamBold
    VL.TextColor3 = Config.Colors.Main
    VL.TextSize = 12
    VL.BackgroundTransparency = 1

    local BG = Instance.new("Frame", Cont)
    BG.Size = UDim2.new(1, -24, 0, 4)
    BG.Position = UDim2.new(0, 12, 0, 28)
    BG.BackgroundColor3 = Config.Colors.Element
    Round(BG, 2)

    local F = Instance.new("Frame", BG)
    local scale = (Config[c][k] - min) / (max - min)
    F.Size = UDim2.new(scale, 0, 1, 0)
    F.BackgroundColor3 = Config.Colors.Main
    Round(F, 2)

    local SB = Instance.new("TextButton", BG)
    SB.Size = UDim2.new(1, 0, 1, 0)
    SB.BackgroundTransparency = 1
    SB.Text = ""

    local sliding = false
    SB.MouseButton1Down:Connect(function()
        sliding = true
    end)

    table.insert(getgenv().SolarConnections, UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end))

    table.insert(getgenv().SolarConnections, RunService.RenderStepped:Connect(function()
        if sliding then
            local mx = UserInputService:GetMouseLocation().X
            local absPos = BG.AbsolutePosition.X
            local absSize = BG.AbsoluteSize.X
            if absSize <= 0 then return end
            local p = math.clamp((mx - absPos) / absSize, 0, 1)
            local v = min + ((max - min) * p)
            v = float and (math.floor(v * 100) / 100) or math.floor(v)
            Config[c][k] = v
            F.Size = UDim2.new(p, 0, 1, 0)
            VL.Text = tostring(v)
        end
    end))
end

local function CreateKeybind(p, t, c, k)
    local B = Instance.new("TextButton", p)
    B.Size = UDim2.new(1, -10, 0, 38)
    B.BackgroundColor3 = Config.Colors.Section
    B.Text = ""
    Round(B, 6)

    local L = Instance.new("TextLabel", B)
    L.Size = UDim2.new(1, -100, 1, 0)
    L.Position = UDim2.new(0, 12, 0, 0)
    L.Text = t
    L.Font = Enum.Font.Gotham
    L.TextColor3 = Config.Colors.Text
    L.TextSize = 13
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1

    local KB = Instance.new("TextButton", B)
    KB.Size = UDim2.new(0, 100, 0, 24)
    KB.Position = UDim2.new(1, -110, 0.5, -12)
    KB.BackgroundColor3 = Config.Colors.Element
    KB.Text = typeof(Config[c][k]) == "EnumItem" and Config[c][k].Name or tostring(Config[c][k])
    KB.Font = Enum.Font.GothamBold
    KB.TextColor3 = Config.Colors.Main
    KB.TextSize = 11
    Round(KB, 6)

    local listening = false
    KB.MouseButton1Click:Connect(function()
        listening = true
        KB.Text = "..."
    end)

    table.insert(getgenv().SolarConnections, UserInputService.InputBegan:Connect(function(i)
        if listening then
            if i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode ~= Enum.KeyCode.Unknown then
                Config[c][k] = i.KeyCode
                KB.Text = i.KeyCode.Name
                listening = false
            elseif i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.MouseButton2 or i.UserInputType == Enum.UserInputType.MouseButton3 then
                Config[c][k] = i.UserInputType
                KB.Text = i.UserInputType.Name
                listening = false
            end
        end
    end))
end

local TabVis = CreateTab("Visuals")
local TabCbt = CreateTab("Combat")
local TabMisc = CreateTab("Misc")
local TabSet = CreateTab("Settings")
SelectTab("Visuals")

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
CreateToggle(TabVis, "Bullet Tracers", "BulletTracers", "Visuals")
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
CreateToggle(TabCbt, "Hit Sound (Bell)", "HitSound", "Combat")
CreateSlider(TabCbt, "RCS Strength", "Combat", "RCSStrength", 1, 20, false)
CreateSlider(TabCbt, "Smoothness", "Combat", "Smoothness", 0.1, 1, true)
CreateSlider(TabCbt, "Lead Calibration", "Combat", "PredictionMult", 0.1, 5, true)
CreateSlider(TabCbt, "Gravity Scale", "Combat", "GravityScale", 0, 2, true)
CreateSlider(TabCbt, "Vertical Offset", "Combat", "VerticalOffset", -5, 5, true)
CreateSlider(TabCbt, "FOV Size", "Combat", "FOV", 10, 600, false)

CreateToggle(TabMisc, "High Jump", "HighJump", "Misc")
CreateSlider(TabMisc, "Jump Height", "Misc", "JumpPower", 50, 300, false)
CreateToggle(TabMisc, "Vehicle Fly", "VehicleFly", "Misc")
CreateSlider(TabMisc, "Fly Speed", "Misc", "FlySpeed", 10, 300, false)
CreateToggle(TabMisc, "Fullbright", "Fullbright", "Misc")
CreateToggle(TabMisc, "Expand Hitbox", "ExpandHitbox", "Misc")
CreateSlider(TabMisc, "Hitbox Size", "Misc", "HitboxSize", 2, 15, false)
CreateToggle(TabMisc, "Streamproof (Hide UI)", "Streamproof", "Misc")
CreateToggle(TabMisc, "Fake Lag (HvH)", "FakeLag", "Misc")
CreateToggle(TabMisc, "Speed Hack", "SpeedHack", "Misc")
CreateSlider(TabMisc, "Speed Multi", "Misc", "SpeedMultiplier", 1, 3, true)
CreateToggle(TabMisc, "Turbo FPS (No Textures)", "TurboFPS", "Misc")

-- Funkcja optymalizująca silnik Roblox
local function OptimizeGame()
    if not Config.Misc.TurboFPS then return end
    
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        elseif v:IsA("Explosion") then
            v.Visible = false
        end
    end
    
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 2
end

-- Pętla optymalizacji (co 5 sekund, żeby nie obciążać CPU)
task.spawn(function()
    while true do
        task.wait(5)
        if Config.State.Unloaded then break end
        if Config.Misc.TurboFPS then
            pcall(OptimizeGame)
        end
        if Config.Misc.Fullbright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
            Lighting.FogEnd = 9e9
            Lighting.GlobalShadows = false
        end
    end
end)

local HttpService = game:GetService("HttpService")
local CfgName = "AR2_SolarV6_Config.json"

local SaveBtn = Instance.new("TextButton", TabSet)
SaveBtn.Size = UDim2.new(1, -10, 0, 45)
SaveBtn.BackgroundColor3 = Config.Colors.Element
SaveBtn.Text = "ZAPISZ CONFIG"
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.TextSize = 14
Round(SaveBtn, 8)

local LoadBtn = Instance.new("TextButton", TabSet)
LoadBtn.Size = UDim2.new(1, -10, 0, 45)
LoadBtn.BackgroundColor3 = Config.Colors.Element
LoadBtn.Text = "WCZYTAJ CONFIG"
LoadBtn.Font = Enum.Font.GothamBold
LoadBtn.TextColor3 = Color3.new(1,1,1)
LoadBtn.TextSize = 14
Round(LoadBtn, 8)

local RivalsBtn = Instance.new("TextButton", TabSet)
RivalsBtn.Size = UDim2.new(1, -10, 0, 40)
RivalsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
RivalsBtn.Text = "LOAD RIVALS (Key C)"
RivalsBtn.Font = Enum.Font.GothamBold
RivalsBtn.TextColor3 = Color3.new(0.7,0.7,1)
RivalsBtn.TextSize = 13
Round(RivalsBtn, 8)

local AR2Btn = Instance.new("TextButton", TabSet)
AR2Btn.Size = UDim2.new(1, -10, 0, 40)
AR2Btn.BackgroundColor3 = Color3.fromRGB(65, 45, 45)
AR2Btn.Text = "LOAD AR2 (Key C)"
AR2Btn.Font = Enum.Font.GothamBold
AR2Btn.TextColor3 = Color3.new(1,0.7,0.7)
AR2Btn.TextSize = 13
Round(AR2Btn, 8)

RivalsBtn.MouseButton1Click:Connect(function()
    Config.Combat.AimKey = Enum.KeyCode.C
    Config.Combat.AdvancedPrediction = false
    Config.Combat.Smoothness = 0.5
    Config.Combat.FOV = 100
    Config.Combat.GravityScale = 0
    Config.Combat.VerticalOffset = 0
    print("[Solar] Loaded Rivals Preset")
end)

AR2Btn.MouseButton1Click:Connect(function()
    Config.Combat.AimKey = Enum.KeyCode.C
    Config.Combat.AdvancedPrediction = true
    Config.Combat.Smoothness = 1
    Config.Combat.FOV = 150
    Config.Combat.GravityScale = 1
    Config.Combat.VerticalOffset = 0
    print("[Solar] Loaded AR2 Preset")
end)

SaveBtn.MouseButton1Click:Connect(function()
    if writefile then
        local t = {Visuals=Config.Visuals, Combat=Config.Combat, Misc=Config.Misc}
        local function clean(o)
            local r = {}
            for k,v in pairs(o) do
                if typeof(v) == "EnumItem" then
                    r[k] = "ENUM_"..tostring(v.EnumType).."_"..v.Name
                elseif type(v) == "table" then
                    r[k] = clean(v)
                else
                    r[k] = v
                end
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
                        if #p >= 3 then
                            pcall(function() dst[k] = Enum[p[2]][p[3]] end)
                        end
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

-- FOV Ring - zadeklarowany TYLKO RAZ
local FOVRing = Drawing.new("Circle")
FOVRing.Thickness = 1
FOVRing.NumSides = 64
FOVRing.Filled = false
FOVRing.Transparency = 1
FOVRing.Visible = false
getgenv().FOVRing = FOVRing

-- Crosshair - pre-allocated
local CrossLines = {Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line")}
for _, l in pairs(CrossLines) do
    l.Thickness = 1.5
    l.Color = Color3.new(0,1,0)
    l.ZIndex = 10
end

-- ==============================================================================
--[ Unload / Cleanup ]
-- ==============================================================================
local UnloadBtn = Instance.new("TextButton", TabSet)
UnloadBtn.Size = UDim2.new(1, -10, 0, 45)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
UnloadBtn.Text = "WYŁĄCZ I WYCZYŚĆ"
UnloadBtn.Font = Enum.Font.GothamBold
UnloadBtn.TextColor3 = Color3.new(1,1,1)
UnloadBtn.TextSize = 14
Round(UnloadBtn, 8)

getgenv().UnloadSolar = function()
    Config.State.Unloaded = true
    if getgenv().ClearESP then pcall(getgenv().ClearESP) end
    for _, c in pairs(getgenv().SolarConnections) do
        pcall(function() c:Disconnect() end)
    end
    if ScreenGui then ScreenGui:Destroy() end
    if FOVRing then pcall(function() FOVRing:Remove() end) end
    if CrossLines then
        for _, l in pairs(CrossLines) do
            pcall(function() l:Remove() end)
        end
    end

    -- Przywracanie oświetlenia
    Lighting.Brightness = OriginalLighting.Brightness
    Lighting.ClockTime = OriginalLighting.ClockTime
    Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient

    -- Przywracanie hitboxów
    for p, size in pairs(OriginalHeadSizes) do
        local char = p and p.Character
        if char then
            local head = char:FindFirstChild("Head")
            if head then
                head.Size = size
                head.Transparency = 0
                head.Color = OriginalHeadColors[p] or Color3.new(1,1,1)
                head.Material = OriginalHeadMats[p] or Enum.Material.SmoothPlastic
                head.CanCollide = true
            end
        end
    end
    OriginalHeadSizes = nil
    OriginalHeadColors = nil
    OriginalHeadMats = nil

    getgenv().SolarConfig = nil
    getgenv().UnloadSolar = nil
    getgenv().ClearESP = nil
    print("[SOLARA] Wersja v6 wyczyszczona.")
end

UnloadBtn.MouseButton1Click:Connect(getgenv().UnloadSolar)

table.insert(getgenv().SolarConnections, UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.RightControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end))

-- ==============================================================================
--[ LOGIKA ESP v6 (ULTRA OPTIMIZED) ]
-- ==============================================================================
local CurrentT = nil
local Cache = { Draw = {}, Chams = {}, Backtrack = {} }

local SkeletonConns = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"}
}

local BodyParts = {"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}

-- Pre-allocowane stałe (nie tworzone w pętli = zero GC)
local COL_GREEN   = Color3.new(0, 1, 0)
local COL_WHITE   = Color3.new(1, 1, 1)
local COL_BLACK   = Color3.new(0, 0, 0)
local V3_UP25     = Vector3.new(0, 2.5, 0)
local V3_DOWN3    = Vector3.new(0, -3, 0)
local V2_ZERO     = Vector2.new(0, 0)

-- Cache nazw graczy
local NameCache = {}
local TeamCache = {}
local ToolCache = {}
local _espTick  = 0

local function CreateDrawings(p)
    local d = {
        Box = Drawing.new("Square"),
        BoxOut = Drawing.new("Square"),
        Corners = {},
        CornersOut = {},
        HealthBG = Drawing.new("Square"),
        Health = Drawing.new("Square"),
        Tag = Drawing.new("Text"),
        Dist = Drawing.new("Text"),
        Weapon = Drawing.new("Text"),
        Team = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        Skeleton = {},
        Arrows = Drawing.new("Triangle")
    }
    for i = 1, #SkeletonConns do
        d.Skeleton[i] = Drawing.new("Line")
        d.Skeleton[i].Thickness = 1
    end
    d.Arrows.Thickness = 1
    d.Arrows.Filled = true
    d.Arrows.Color = Config.Colors.Main

    d.Box.Thickness = 1
    d.BoxOut.Thickness = 3
    d.BoxOut.Color = COL_BLACK

    for i = 1, 8 do
        d.Corners[i] = Drawing.new("Line")
        d.Corners[i].Thickness = 1
        d.CornersOut[i] = Drawing.new("Line")
        d.CornersOut[i].Thickness = 3
        d.CornersOut[i].Color = COL_BLACK
    end

    d.HealthBG.Filled = true
    d.HealthBG.Color = COL_BLACK
    d.Health.Filled = true

    d.Tag.Size = 13
    d.Tag.Center = true
    d.Tag.Outline = true
    d.Tag.Font = 2

    d.Dist.Size = 12
    d.Dist.Center = true
    d.Dist.Outline = true
    d.Dist.Font = 2
    d.Dist.Color = Config.Colors.Distance

    d.Weapon.Size = 11
    d.Weapon.Center = true
    d.Weapon.Outline = true
    d.Weapon.Font = 2
    d.Weapon.Color = Config.Colors.Accent

    d.Team.Size = 11
    d.Team.Center = true
    d.Team.Outline = true
    d.Team.Font = 2
    d.Team.Color = Color3.fromRGB(100, 200, 255)

    d.Tracer.Thickness = 1
    Cache.Draw[p] = d
end

local function HideAll(p)
    local d = Cache.Draw[p]
    if d then
        if not (d.Tag.Visible or d.Box.Visible or d.Tracer.Visible) then return end
        d.Box.Visible = false
        d.BoxOut.Visible = false
        for i = 1, 8 do
            d.Corners[i].Visible = false
            d.CornersOut[i].Visible = false
        end
        d.Health.Visible = false
        d.HealthBG.Visible = false
        d.Tag.Visible = false
        d.Dist.Visible = false
        d.Weapon.Visible = false
        d.Team.Visible = false
        d.Tracer.Visible = false
        d.Arrows.Visible = false
        for _, l in pairs(d.Skeleton) do
            l.Visible = false
        end
    end
    if Cache.Chams[p] and Cache.Chams[p].Enabled then
        Cache.Chams[p].Enabled = false
    end
end

local function RemovePlayer(p)
    if Cache.Draw[p] then
        for _, v in pairs(Cache.Draw[p]) do
            if type(v) == "table" then
                for _, l in pairs(v) do
                    pcall(function() l:Remove() end)
                end
            else
                pcall(function() v:Remove() end)
            end
        end
        Cache.Draw[p] = nil
    end
    if Cache.Chams[p] then
        pcall(function() Cache.Chams[p]:Destroy() end)
        Cache.Chams[p] = nil
    end
    if Cache.Backtrack[p] then
        Cache.Backtrack[p] = nil
    end
    NameCache[p] = nil
    TeamCache[p] = nil
    ToolCache[p] = nil
end

-- ==============================================================================
--[ ITEM ESP v6 (AUG ONLY - OPTIMIZED) ]
-- ==============================================================================
local ItemCache = {}
local ItemScanTick = 0

local function CreateItemDrawing(item)
    local t = Drawing.new("Text")
    t.Size = 13
    t.Center = true
    t.Outline = true
    t.Color = Color3.fromRGB(0, 255, 255)
    t.Visible = false
    ItemCache[item] = t
end

local ItemESPLoop = RunService.RenderStepped:Connect(function()
    if Config.State.Unloaded then
        for _, v in pairs(ItemCache) do v.Visible = false end
        return
    end

    ItemScanTick = ItemScanTick + 1
    local shouldScan = (ItemScanTick % 240 == 0) -- co ~4 sekundy (60fps * 4)

    if Config.Visuals.ItemESPAUG then
        -- Skanowanie tylko co 240 klatek
        if shouldScan then
            local newItems = {}
            for _, obj in ipairs(Workspace:GetDescendants()) do
                local name = obj.Name:lower()
                if name:find("aug") or name:find("steyr") then
                    -- Sprawdzamy czy to nie broń w ręku
                    local isHeld = false
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl.Character and obj:IsDescendantOf(pl.Character) then
                            isHeld = true
                            break
                        end
                    end
                    if not isHeld then
                        newItems[obj] = true
                        if not ItemCache[obj] then
                            CreateItemDrawing(obj)
                        end
                    end
                end
            end
            -- Usuwamy itemy które zniknęły
            for item, _ in pairs(ItemCache) do
                if not newItems[item] then
                    pcall(function() item:Remove() end) -- drawing remove
                    ItemCache[item] = nil
                end
            end
        end

        for item, draw in pairs(ItemCache) do
            if not item or not item.Parent then
                pcall(function() draw:Remove() end)
                ItemCache[item] = nil
            else
                -- Sprawdzamy czy ktoś podniósł
                local isHeld = false
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl.Character and item:IsDescendantOf(pl.Character) then
                        isHeld = true
                        break
                    end
                end
                if isHeld then
                    draw.Visible = false
                else
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
        end
    else
        for _, v in pairs(ItemCache) do v.Visible = false end
    end
end)
table.insert(getgenv().SolarConnections, ItemESPLoop)

-- Cachujemy RaycastParams raz (eliminuje GC pressure - duży boost FPS)
local _rayParams = RaycastParams.new()
_rayParams.FilterType = Enum.RaycastFilterType.Exclude
_rayParams.IgnoreWater = true

local function IsVisible(targetPart)
    if not targetPart then return false end
    if not Config.Combat.WallCheck then return true end
    -- Optymalizacja: Ignore list zawiera naszą postać i całe modele graczy by uniknąć trafiania w ich akcesoria
    _rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local rayOrigin = Camera.CFrame.Position
    local rayDir = (targetPart.Position - rayOrigin)
    local result = Workspace:Raycast(rayOrigin, rayDir, _rayParams)
    
    if result then
        local hit = result.Instance
        -- Jeśli trafiliśmy w coś, co należy do celu - jest widoczny
        return hit:IsDescendantOf(targetPart.Parent)
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
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Head"))
            
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

table.insert(getgenv().SolarConnections, UserInputService.InputBegan:Connect(function(i, g) 
    if not g and (i.UserInputType == Config.Combat.AimKey or i.KeyCode == Config.Combat.AimKey) then 
        Config.State.Aiming = true 
    end 
end))
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
        
            -- MULTIPOINT AIM & BACKTRACK
            local part = nil
            local targetPos = nil
            
            -- Szukamy najlepszej widocznej części ciała (Multipoint)
            for _, pName in ipairs(BodyParts) do
                local pObj = char:FindFirstChild(pName)
                if pObj and IsVisible(pObj) then
                    part = pObj; targetPos = pObj.Position; break
                end
            end
            
            -- Jeśli nic nie widać, sprawdzamy Backtrack (tylko dla Silent Aim)
            if not part and Config.Combat.SilentAim and Cache.Backtrack[CurrentT] then
                for i = 1, #Cache.Backtrack[CurrentT] do
                    targetPos = Cache.Backtrack[CurrentT][i]
                    part = char.PrimaryPart or char:FindFirstChild("Head") -- Placeholder
                    break
                end
            end
            
            -- Fallback
            if not part then 
                part = char:FindFirstChild("Head") or char.PrimaryPart
                targetPos = part and part.Position or Vector3.new(0,0,0)
            end
            
            local root = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
            if part and root then
                local aimP = targetPos
                
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
                    local drop = Vector3.new(0, 0.5 * (Config.Combat.BulletGravity * Config.Combat.GravityScale) * (t2 * t2), 0)
                    
                    -- KOMPENSACJA SKOKU
                    local targetGravity = Vector3.new(0, 0, 0)
                    if hum.FloorMaterial == Enum.Material.Air then
                        targetGravity = Vector3.new(0, 0.5 * workspace.Gravity * (t2 * t2), 0)
                    end
                    
                    aimP = aimP + lead - targetGravity + drop + Vector3.new(0, Config.Combat.VerticalOffset, 0)
                end
                
                -- Aktualizujemy globalną pozycję dla Silent Aima
                getgenv().PredictedPosition = aimP
                
                local scr, on = Camera:WorldToViewportPoint(aimP)
                local physDist = (root.Position - Camera.CFrame.Position).Magnitude
                
                -- Jeśli uzywamy Silent Aim, aktualizujemy tylko pozycję kuli, ale NIE przerywamy Aim Assist (ruch myszką nadal działa)
                if Config.Combat.SilentAim then
                    -- Silent Aim załatwi to przez hooka
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
                    
                    
                    if mousemoverel and (mx ~= 0 or my ~= 0) then mousemoverel(mx, my) end
                elseif physDist <= 50 then
                    -- Panic Mode (bezpośredni obrót myszy dla bliskich celów)
                    local m = UserInputService:GetMouseLocation()
                    local scr, on = Camera:WorldToViewportPoint(aimP)
                    if on then
                        mousemoverel(scr.X - m.X, scr.Y - m.Y)
                    end
                else
                    CurrentT = nil
                end
            end
        end
    else
        CurrentT = nil
    end
    
    -- LEGIT RCS (Działa zawsze podczas strzelania, nawet bez celu)
    if Config.Combat.LegitRCS and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not UserInputService:GetFocusedTextBox() then
        if mousemoverel then
            mousemoverel(0, Config.Combat.RCSStrength)
        end
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
                
                if distToOrigin < 15 then
                    local targetPos = getgenv().PredictedPosition
                    args[2] = (targetPos - origin).Unit * direction.Magnitude
                    
                    if Config.Visuals.BulletTracers then
                        task.spawn(function()
                            local l = Drawing.new("Line")
                            l.Thickness = 1.5; l.Color = Config.Colors.Main; l.Transparency = 1
                            local s, e = Camera:WorldToViewportPoint(origin), Camera:WorldToViewportPoint(targetPos)
                            l.From = Vector2.new(s.X, s.Y); l.To = Vector2.new(e.X, e.Y); l.Visible = true
                            task.wait(0.5); l:Remove()
                        end)
                    end
                    if Config.Combat.HitSound then
                        local s = Instance.new("Sound", game:GetService("SoundService"))
                        s.SoundId = "rbxassetid://160433791"; s.Volume = 2; s:Play()
                        game:GetService("Debris"):AddItem(s, 1)
                    end
                    
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
                -- Orientacja: Auto zawsze "patrzy" tam gdzie kamera (horyzontalnie)
                if FlyBG then 
                    FlyBG.CFrame = CFrame.lookAt(root.Position, root.Position + lookFlat) 
                end
            end
        else
            -- Gracz wysiadł lub nigdy nie siedział w aucie - czyścimy obiekty
            if FlyBV or FlyBG then DestroyFlyObjects() end
        end
    else
        -- Tryb wyłączony - usuwamy obiekty fizyczne
        DestroyFlyObjects()
    end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if Config.Misc.SpeedHack and hum then
        hum.WalkSpeed = 16 * Config.Misc.SpeedMultiplier
    elseif hum then
        hum.WalkSpeed = 16
    end
    
    if Config.Misc.FakeLag and root then
        _fakeLagTick = (_fakeLagTick or 0) + 1
        if _fakeLagTick % 10 == 0 then
            root.Anchored = true
            task.wait(0.05)
            root.Anchored = false
        end
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