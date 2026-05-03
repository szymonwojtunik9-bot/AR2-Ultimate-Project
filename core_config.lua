-- ==============================================================================
--[ MODUŁ 1: KONFIGURACJA I PREMIUM UI ]
-- Ten skrypt inicjuje globalne ustawienia i nowoczesne menu.
-- ==============================================================================

if getgenv().SolarConfig then 
    if getgenv().UnloadSolar then getgenv().UnloadSolar() end
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

--[ GLOBALNE POŁĄCZENIA (DO CAŁKOWITEGO WYŁĄCZENIA) ]
getgenv().SolarConnections = {}

--[ GLOBALNE USTAWIENIA ]
getgenv().SolarConfig = {
    Visuals = {
        BoxESP = true,
        CornerBox = true,
        NameTags = true,
        HealthBar = true,
        Skeleton = true,
        WeaponESP = true,
        OffScreenArrows = true,
        Chams = true,
        MaxDistance = 5000,
        MinDistance = 0 -- Nowość: Od jakiej odległości pokazywać
    },
    Combat = {
        AimAssist = true,
        ShowFOV = true,
        FOV = 150,
        MaxDistance = 5000,
        Smoothness = 0.15,
        AimPart = "Head",
        WallCheck = true,
        TeamCheck = false,
        AdvancedPrediction = true,
        AutoCalibration = true,
        BulletSpeed = 2500,
        BulletGravity = 196.2
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
    },
    State = {
        Aiming = false,
        MenuOpen = true,
        Unloaded = false
    }
}

local Config = getgenv().SolarConfig

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function Round(obj, radius)
    local corner = Instance.new("UICorner", obj)
    corner.CornerRadius = UDim.new(0, radius or 6)
    return corner
end

--[ GŁÓWNE OKNO ]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SolarMenu_Modular"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (gethui and gethui()) or CoreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 380)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -190)
MainFrame.BackgroundColor3 = Config.Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
Round(MainFrame, 10)

Instance.new("UIStroke", MainFrame).Color = Config.Colors.Main

-- Przeciąganie
local dragToggle, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragToggle then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragToggle = false end
end)

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Config.Colors.Section
Sidebar.BorderSizePixel = 0
Round(Sidebar, 10)

local SideFix = Instance.new("Frame", Sidebar)
SideFix.Size = UDim2.new(0, 10, 1, 0)
SideFix.Position = UDim2.new(1, -10, 0, 0)
SideFix.BackgroundColor3 = Config.Colors.Section
SideFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "AR2 PRO"
Title.Font = Enum.Font.GothamBlack
Title.TextColor3 = Config.Colors.Main
Title.TextSize = 20
Title.BackgroundTransparency = 1

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -150, 1, -20)
ContentContainer.Position = UDim2.new(0, 150, 0, 10)
ContentContainer.BackgroundTransparency = 1

local Tabs = {}
local TabFrames = {}

local function SelectTab(tabName)
    for name, frame in pairs(TabFrames) do frame.Visible = (name == tabName) end
    for name, btn in pairs(Tabs) do
        if name == tabName then
            Tween(btn, {BackgroundColor3 = Config.Colors.Main, TextColor3 = Color3.fromRGB(255,255,255)})
        else
            Tween(btn, {BackgroundColor3 = Config.Colors.Element, TextColor3 = Config.Colors.TextDark})
        end
    end
end

local function CreateTab(name)
    local Btn = Instance.new("TextButton", Sidebar)
    Btn.Size = UDim2.new(0, 120, 0, 35)
    Btn.BackgroundColor3 = Config.Colors.Element
    Btn.Text = name
    Btn.Font = Enum.Font.GothamBold
    Btn.TextColor3 = Config.Colors.TextDark
    Btn.TextSize = 14
    Btn.AutoButtonColor = false
    Round(Btn, 6)
    
    local Frame = Instance.new("ScrollingFrame", ContentContainer)
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundTransparency = 1
    Frame.ScrollBarThickness = 2
    Frame.Visible = false
    
    local Layout = Instance.new("UIListLayout", Frame)
    Layout.Padding = UDim.new(0, 8)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Frame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)
    
    Tabs[name] = Btn
    TabFrames[name] = Frame
    Btn.MouseButton1Click:Connect(function() SelectTab(name) end)
    return Frame
end

-- Layout dla przycisków tabów
local TabListLayout = Instance.new("UIListLayout", Sidebar)
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 50)

local function CreateToggle(parent, text, configKey, category)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.BackgroundColor3 = Config.Colors.Section
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Round(Btn, 8)

    local Label = Instance.new("TextLabel", Btn)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Text = text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextColor3 = Config.Colors.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local SwitchBG = Instance.new("Frame", Btn)
    SwitchBG.Size = UDim2.new(0, 36, 0, 18)
    SwitchBG.Position = UDim2.new(1, -45, 0.5, -9)
    SwitchBG.BackgroundColor3 = Config[category][configKey] and Config.Colors.Main or Config.Colors.Element
    Round(SwitchBG, 9)

    local SwitchKnob = Instance.new("Frame", SwitchBG)
    SwitchKnob.Size = UDim2.new(0, 14, 0, 14)
    SwitchKnob.Position = Config[category][configKey] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    SwitchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Round(SwitchKnob, 7)

    Btn.MouseButton1Click:Connect(function()
        local state = not Config[category][configKey]
        Config[category][configKey] = state
        Tween(SwitchBG, {BackgroundColor3 = state and Config.Colors.Main or Config.Colors.Element}, 0.2)
        Tween(SwitchKnob, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.2)
    end)
end

local function CreateSlider(parent, text, category, key, min, max, isFloat)
    local Container = Instance.new("Frame", parent)
    Container.Size = UDim2.new(1, -10, 0, 50)
    Container.BackgroundColor3 = Config.Colors.Section
    Round(Container, 8)

    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 15, 0, 5)
    Label.Text = text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextColor3 = Config.Colors.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    
    local ValueLabel = Instance.new("TextLabel", Container)
    ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    ValueLabel.Position = UDim2.new(1, -65, 0, 5)
    ValueLabel.Text = tostring(Config[category][key])
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextColor3 = Config.Colors.Main
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.BackgroundTransparency = 1

    local BG = Instance.new("Frame", Container)
    BG.Size = UDim2.new(1, -30, 0, 6)
    BG.Position = UDim2.new(0, 15, 0, 32)
    BG.BackgroundColor3 = Config.Colors.Element
    Round(BG, 3)

    local Fill = Instance.new("Frame", BG)
    local startScale = (Config[category][key] - min) / (max - min)
    Fill.Size = UDim2.new(startScale, 0, 1, 0)
    Fill.BackgroundColor3 = Config.Colors.Main
    Round(Fill, 3)

    local Btn = Instance.new("TextButton", BG)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""

    local sliding = false
    Btn.MouseButton1Down:Connect(function() sliding = true end)
    local endConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    table.insert(getgenv().SolarConnections, endConn)

    local renderConn = game:GetService("RunService").RenderStepped:Connect(function()
        if sliding then
            local mousePos = UserInputService:GetMouseLocation().X
            local bgPos = BG.AbsolutePosition.X
            local bgSize = BG.AbsoluteSize.X
            local percent = math.clamp((mousePos - bgPos) / bgSize, 0, 1)
            local value = min + ((max - min) * percent)
            value = isFloat and (math.floor(value * 100) / 100) or math.floor(value)
            Config[category][key] = value
            Tween(Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.05)
            ValueLabel.Text = tostring(value)
        end
    end)
    table.insert(getgenv().SolarConnections, renderConn)
end

-- ==============================================================================
--[ UNLOAD LOGIC ]
-- ==============================================================================
getgenv().UnloadSolar = function()
    Config.State.Unloaded = true
    for _, conn in pairs(getgenv().SolarConnections) do pcall(function() conn:Disconnect() end) end
    table.clear(getgenv().SolarConnections)
    ScreenGui:Destroy()
    getgenv().SolarConfig = nil
    getgenv().UnloadSolar = nil
    print("[SOLARA] Skrypt został całkowicie wyłączony.")
end

-- ==============================================================================
--[ ZAKŁADKI ]
-- ==============================================================================
local TabVis = CreateTab("Visuals")
local TabCbt = CreateTab("Combat")
local TabSet = CreateTab("Settings")

SelectTab("Visuals")

-- VISUALS
CreateToggle(TabVis, "Full Box ESP", "BoxESP", "Visuals")
CreateToggle(TabVis, "Corner Box ESP", "CornerBox", "Visuals")
CreateToggle(TabVis, "Health Bar", "HealthBar", "Visuals")
CreateToggle(TabVis, "Skeleton ESP", "Skeleton", "Visuals")
CreateToggle(TabVis, "Nicknames", "NameTags", "Visuals")
CreateToggle(TabVis, "Weapon/Item ESP", "WeaponESP", "Visuals")
CreateToggle(TabVis, "Off-Screen Arrows", "OffScreenArrows", "Visuals")
CreateToggle(TabVis, "Chams (Highlight)", "Chams", "Visuals")
CreateSlider(TabVis, "Max Distance", "Visuals", "MaxDistance", 100, 15000, false)
CreateSlider(TabVis, "Min Distance (Hide Close)", "Visuals", "MinDistance", 0, 1000, false)

-- COMBAT
CreateToggle(TabCbt, "Aim Assist", "AimAssist", "Combat")
CreateToggle(TabCbt, "Show FOV", "ShowFOV", "Combat")
CreateToggle(TabCbt, "Wall Check", "WallCheck", "Combat")
CreateToggle(TabCbt, "Team Check", "TeamCheck", "Combat")
CreateToggle(TabCbt, "Advance Physics", "AdvancedPrediction", "Combat")
CreateToggle(TabCbt, "Auto Calibration", "AutoCalibration", "Combat")
CreateSlider(TabCbt, "Aim Smooth", "Combat", "Smoothness", 0.01, 1, true)
CreateSlider(TabCbt, "FOV Size", "Combat", "FOV", 10, 800, false)

-- SETTINGS
local UnloadBtn = Instance.new("TextButton", TabSet)
UnloadBtn.Size = UDim2.new(1, -10, 0, 45)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
UnloadBtn.Text = "WYŁĄCZ CAŁY SKRYPT I GUI"
UnloadBtn.Font = Enum.Font.GothamBold
UnloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadBtn.TextSize = 14
Round(UnloadBtn, 8)
UnloadBtn.MouseButton1Click:Connect(getgenv().UnloadSolar)

local inputConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)
table.insert(getgenv().SolarConnections, inputConn)

print("[SOLARA] Moduł UI załadowany.")
