-- ==============================================================================
--[ AR2 ULTIMATE PRO - WERSJA JEDNOPLIKOWA (SINGLE SCRIPT) ]
-- Złączono wszystkie moduły w jeden plik, aby uniknąć problemów z Solara.
-- ==============================================================================

if getgenv().UnloadSolar then getgenv().UnloadSolar() end
task.wait(0.2)

-- Usuwanie starych GUI (force)
for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v:IsA("ScreenGui") and (v.Name:find("Solar") or v.Name:find("Menu")) then
        v:Destroy()
    end
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Odświeżanie kamery po respawnie (krytyczny fix)
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    Camera = Workspace.CurrentCamera
end)

local SafeGui
local success = pcall(function() SafeGui = (gethui and gethui()) or CoreGui end)
if not success or not SafeGui then SafeGui = LocalPlayer:WaitForChild("PlayerGui") end

getgenv().SolarConnections = {}

-- ==============================================================================
--[ KONFIGURACJA ]
-- ==============================================================================
getgenv().SolarConfig = {
    Visuals = {
        BoxESP = true,
        CornerBox = true,
        NameTags = true,
        HealthBar = true,
        Skeleton = true,
        WeaponESP = true,
        Tracers = false,
        OffScreenArrows = true,
        Chams = true,
        MaxDistance = 5000,
        MinDistance = 0,
        Crosshair = true
    },
    Combat = {
        AimAssist = true,
        ShowFOV = true,
        FOV = 150,
        MaxDistance = 5000,
        Smoothness = 0.5, -- 0.01 = wolno, 1.0 = natychmiast
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
    State = { Aiming = false, Unloaded = false }
}
local Config = getgenv().SolarConfig

local function Tween(obj, props, time) TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() end
local function Round(obj, radius) local c = Instance.new("UICorner", obj); c.CornerRadius = UDim.new(0, radius or 6); return c end

-- ==============================================================================
--[ PREMIUM UI ]
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SolarMenu_v4"; ScreenGui.ResetOnSpawn = false; ScreenGui.Parent = SafeGui
local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 520, 0, 400); MainFrame.Position = UDim2.new(0.5, -260, 0.5, -200)
MainFrame.BackgroundColor3 = Config.Colors.Background; MainFrame.BorderSizePixel = 0; MainFrame.Active = true; Round(MainFrame, 10)
Instance.new("UIStroke", MainFrame).Color = Config.Colors.Main

local dragToggle, dragStart, startPos
MainFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragToggle = true; dragStart = input.Position; startPos = MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement and dragToggle then local delta = input.Position - dragStart; MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragToggle = false end end)

local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 140, 1, 0); Sidebar.BackgroundColor3 = Config.Colors.Section; Sidebar.BorderSizePixel = 0; Round(Sidebar, 10)
local SideFix = Instance.new("Frame", Sidebar); SideFix.Size = UDim2.new(0, 10, 1, 0); SideFix.Position = UDim2.new(1, -10, 0, 0); SideFix.BackgroundColor3 = Config.Colors.Section; SideFix.BorderSizePixel = 0
local Title = Instance.new("TextLabel", Sidebar); Title.Size = UDim2.new(1, 0, 0, 50); Title.Text = "AR2 PRO v4"; Title.Font = Enum.Font.GothamBlack; Title.TextColor3 = Config.Colors.Main; Title.TextSize = 20; Title.BackgroundTransparency = 1

local ContentContainer = Instance.new("Frame", MainFrame); ContentContainer.Size = UDim2.new(1, -150, 1, -20); ContentContainer.Position = UDim2.new(0, 150, 0, 10); ContentContainer.BackgroundTransparency = 1
local Tabs = {}; local TabFrames = {}

local function SelectTab(tabName)
    for name, frame in pairs(TabFrames) do frame.Visible = (name == tabName) end
    for name, btn in pairs(Tabs) do if name == tabName then Tween(btn, {BackgroundColor3 = Config.Colors.Main, TextColor3 = Color3.fromRGB(255,255,255)}) else Tween(btn, {BackgroundColor3 = Config.Colors.Element, TextColor3 = Config.Colors.TextDark}) end end
end

local function CreateTab(name)
    local Btn = Instance.new("TextButton", Sidebar); Btn.Size = UDim2.new(0, 120, 0, 35); Btn.BackgroundColor3 = Config.Colors.Element; Btn.Text = name; Btn.Font = Enum.Font.GothamBold; Btn.TextColor3 = Config.Colors.TextDark; Btn.TextSize = 14; Btn.AutoButtonColor = false; Round(Btn, 6)
    local Frame = Instance.new("ScrollingFrame", ContentContainer); Frame.Size = UDim2.new(1, 0, 1, 0); Frame.BackgroundTransparency = 1; Frame.ScrollBarThickness = 2; Frame.Visible = false
    local Layout = Instance.new("UIListLayout", Frame); Layout.Padding = UDim.new(0, 8); Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Frame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10) end)
    Tabs[name] = Btn; TabFrames[name] = Frame; Btn.MouseButton1Click:Connect(function() SelectTab(name) end)
    return Frame
end

local TabListLayout = Instance.new("UIListLayout", Sidebar); TabListLayout.Padding = UDim.new(0, 5); TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder; Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 50)

local function CreateToggle(parent, text, configKey, category)
    local Btn = Instance.new("TextButton", parent); Btn.Size = UDim2.new(1, -10, 0, 40); Btn.BackgroundColor3 = Config.Colors.Section; Btn.Text = ""; Btn.AutoButtonColor = false; Round(Btn, 8)
    local Label = Instance.new("TextLabel", Btn); Label.Size = UDim2.new(1, -60, 1, 0); Label.Position = UDim2.new(0, 15, 0, 0); Label.Text = text; Label.Font = Enum.Font.GothamSemibold; Label.TextColor3 = Config.Colors.Text; Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.BackgroundTransparency = 1
    local SwitchBG = Instance.new("Frame", Btn); SwitchBG.Size = UDim2.new(0, 36, 0, 18); SwitchBG.Position = UDim2.new(1, -45, 0.5, -9); SwitchBG.BackgroundColor3 = Config[category][configKey] and Config.Colors.Main or Config.Colors.Element; Round(SwitchBG, 9)
    local SwitchKnob = Instance.new("Frame", SwitchBG); SwitchKnob.Size = UDim2.new(0, 14, 0, 14); SwitchKnob.Position = Config[category][configKey] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7); SwitchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Round(SwitchKnob, 7)
    Btn.MouseButton1Click:Connect(function() local state = not Config[category][configKey]; Config[category][configKey] = state; Tween(SwitchBG, {BackgroundColor3 = state and Config.Colors.Main or Config.Colors.Element}, 0.2); Tween(SwitchKnob, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.2) end)
end

local function CreateSlider(parent, text, category, key, min, max, isFloat)
    local Container = Instance.new("Frame", parent); Container.Size = UDim2.new(1, -10, 0, 50); Container.BackgroundColor3 = Config.Colors.Section; Round(Container, 8)
    local Label = Instance.new("TextLabel", Container); Label.Size = UDim2.new(1, -20, 0, 20); Label.Position = UDim2.new(0, 15, 0, 5); Label.Text = text; Label.Font = Enum.Font.GothamSemibold; Label.TextColor3 = Config.Colors.Text; Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.BackgroundTransparency = 1
    local ValueLabel = Instance.new("TextLabel", Container); ValueLabel.Size = UDim2.new(0, 50, 0, 20); ValueLabel.Position = UDim2.new(1, -65, 0, 5); ValueLabel.Text = tostring(Config[category][key]); ValueLabel.Font = Enum.Font.GothamBold; ValueLabel.TextColor3 = Config.Colors.Main; ValueLabel.TextSize = 14; ValueLabel.TextXAlignment = Enum.TextXAlignment.Right; ValueLabel.BackgroundTransparency = 1
    local BG = Instance.new("Frame", Container); BG.Size = UDim2.new(1, -30, 0, 6); BG.Position = UDim2.new(0, 15, 0, 32); BG.BackgroundColor3 = Config.Colors.Element; Round(BG, 3)
    local Fill = Instance.new("Frame", BG); local startScale = (Config[category][key] - min) / (max - min); Fill.Size = UDim2.new(startScale, 0, 1, 0); Fill.BackgroundColor3 = Config.Colors.Main; Round(Fill, 3)
    local Btn = Instance.new("TextButton", BG); Btn.Size = UDim2.new(1, 0, 1, 0); Btn.BackgroundTransparency = 1; Btn.Text = ""
    local sliding = false; Btn.MouseButton1Down:Connect(function() sliding = true end)
    local endConn = UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
    table.insert(getgenv().SolarConnections, endConn)
    local renderConn = RunService.RenderStepped:Connect(function()
        if sliding then
            local percent = math.clamp((UserInputService:GetMouseLocation().X - BG.AbsolutePosition.X) / BG.AbsoluteSize.X, 0, 1)
            local value = min + ((max - min) * percent); value = isFloat and (math.floor(value * 100) / 100) or math.floor(value); Config[category][key] = value
            Tween(Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.05); ValueLabel.Text = tostring(value)
        end
    end)
    table.insert(getgenv().SolarConnections, renderConn)
end

local TabVis = CreateTab("Visuals"); local TabCbt = CreateTab("Combat"); local TabSet = CreateTab("Settings"); SelectTab("Visuals")

CreateToggle(TabVis, "Full Box ESP", "BoxESP", "Visuals")
CreateToggle(TabVis, "Corner Box ESP", "CornerBox", "Visuals")
CreateToggle(TabVis, "Health Bar", "HealthBar", "Visuals")
CreateToggle(TabVis, "Skeleton ESP", "Skeleton", "Visuals")
CreateToggle(TabVis, "Nicknames", "NameTags", "Visuals")
CreateToggle(TabVis, "Weapon/Item ESP", "WeaponESP", "Visuals")
CreateToggle(TabVis, "Tracers (Lines)", "Tracers", "Visuals")
CreateToggle(TabVis, "Off-Screen Arrows", "OffScreenArrows", "Visuals")
CreateToggle(TabVis, "Custom Crosshair", "Crosshair", "Visuals")
CreateSlider(TabVis, "Max Distance", "Visuals", "MaxDistance", 100, 15000, false)
CreateSlider(TabVis, "Min Distance", "Visuals", "MinDistance", 0, 1000, false)

CreateToggle(TabCbt, "Aim Assist", "AimAssist", "Combat")
CreateToggle(TabCbt, "Show FOV", "ShowFOV", "Combat")
CreateToggle(TabCbt, "Wall Check", "WallCheck", "Combat")
CreateToggle(TabCbt, "Team Check", "TeamCheck", "Combat")
CreateToggle(TabCbt, "Advance Physics", "AdvancedPrediction", "Combat")
CreateToggle(TabCbt, "Auto Calibration", "AutoCalibration", "Combat")
CreateSlider(TabCbt, "Aim Smooth", "Combat", "Smoothness", 0.01, 1, true)
CreateSlider(TabCbt, "FOV Size", "Combat", "FOV", 10, 800, false)

local UnloadBtn = Instance.new("TextButton", TabSet); UnloadBtn.Size = UDim2.new(1, -10, 0, 45); UnloadBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50); UnloadBtn.Text = "WYŁĄCZ CAŁY SKRYPT I GUI"; UnloadBtn.Font = Enum.Font.GothamBold; UnloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255); UnloadBtn.TextSize = 14; Round(UnloadBtn, 8)
getgenv().UnloadSolar = function()
    Config.State.Unloaded = true
    for _, conn in pairs(getgenv().SolarConnections) do pcall(function() conn:Disconnect() end) end
    table.clear(getgenv().SolarConnections)
    -- Czyszczenie WSZYSTKICH rysunków
    pcall(function() FOVRing:Remove() end)
    pcall(function() CrosshairX:Remove() end)
    pcall(function() CrosshairY:Remove() end)
    for p, _ in pairs(Cache.Draw) do pcall(function() RemoveDrawings(p) end) end
    for p, c in pairs(Cache.Chams) do pcall(function() c:Destroy() end) end
    table.clear(Cache.Draw); table.clear(Cache.Chams)
    if ScreenGui then ScreenGui:Destroy() end
    getgenv().SolarConfig = nil; getgenv().UnloadSolar = nil
end
UnloadBtn.MouseButton1Click:Connect(getgenv().UnloadSolar)

local inputConn = UserInputService.InputBegan:Connect(function(input, gpe) if not gpe and input.KeyCode == Enum.KeyCode.Insert then ScreenGui.Enabled = not ScreenGui.Enabled end end)
table.insert(getgenv().SolarConnections, inputConn)

-- ==============================================================================
--[ ESP & VISUALS LOGIC ]
-- ==============================================================================
local Cache = { Draw = {}, Chams = {} }
local SkeletonConnections = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}}

local function CreateDrawing(class, props) local d = Drawing.new(class); for i, v in pairs(props) do d[i] = v end; return d end
local function CreateDrawings(player)
    local d = {
        Box = CreateDrawing("Square", {Thickness = 1, Filled = false, ZIndex = 10, Visible = false}),
        BoxOutline = CreateDrawing("Square", {Thickness = 3, Color = Color3.new(0,0,0), ZIndex = 9, Visible = false}),
        HealthBarBG = CreateDrawing("Square", {Thickness = 1, Color = Color3.new(0,0,0), Filled = true, ZIndex = 8, Visible = false}),
        HealthBar = CreateDrawing("Square", {Thickness = 1, Filled = true, ZIndex = 9, Visible = false}),
        Tag = CreateDrawing("Text", {Size = 14, Center = true, Outline = true, Font = 3, ZIndex = 11, Visible = false}),
        WeaponTag = CreateDrawing("Text", {Size = 13, Center = true, Outline = true, Font = 3, ZIndex = 11, Visible = false}),
        Tracer = CreateDrawing("Line", {Thickness = 1, ZIndex = 10, Visible = false}),
        OOF_Arrow = CreateDrawing("Triangle", {Thickness = 1, Filled = true, ZIndex = 10, Visible = false}),
        OOF_ArrowOutline = CreateDrawing("Triangle", {Thickness = 3, Color = Color3.new(0,0,0), Filled = false, ZIndex = 9, Visible = false}),
        Corners = {}, Skeleton = {}
    }
    for i=1, 8 do table.insert(d.Corners, CreateDrawing("Line", {Thickness = 1.5, ZIndex = 10, Visible = false})) end
    for i=1, #SkeletonConnections do table.insert(d.Skeleton, CreateDrawing("Line", {Thickness = 1, ZIndex = 7, Visible = false})) end
    Cache.Draw[player] = d
end

local function HideDrawings(player)
    if Cache.Draw[player] then
        local d = Cache.Draw[player]
        d.Box.Visible = false; d.BoxOutline.Visible = false; d.HealthBar.Visible = false; d.HealthBarBG.Visible = false
        d.Tag.Visible = false; d.WeaponTag.Visible = false; d.Tracer.Visible = false
        d.OOF_Arrow.Visible = false; d.OOF_ArrowOutline.Visible = false
        for _, l in pairs(d.Corners) do l.Visible = false end; for _, l in pairs(d.Skeleton) do l.Visible = false end
    end
    if Cache.Chams[player] then Cache.Chams[player].Enabled = false end
end

local function RemoveDrawings(player)
    if Cache.Draw[player] then
        local d = Cache.Draw[player]
        d.Box:Remove(); d.BoxOutline:Remove(); d.HealthBar:Remove(); d.HealthBarBG:Remove(); d.Tag:Remove(); d.WeaponTag:Remove(); d.Tracer:Remove(); d.OOF_Arrow:Remove(); d.OOF_ArrowOutline:Remove()
        for _, l in pairs(d.Corners) do l:Remove() end; for _, l in pairs(d.Skeleton) do l:Remove() end
        Cache.Draw[player] = nil
    end
    if Cache.Chams[player] then Cache.Chams[player]:Destroy(); Cache.Chams[player] = nil end
end

local CrosshairX = CreateDrawing("Line", {Thickness = 1.5, Color = Config.Colors.Main, Visible = false, ZIndex = 20})
local CrosshairY = CreateDrawing("Line", {Thickness = 1.5, Color = Config.Colors.Main, Visible = false, ZIndex = 20})

local ESP_Connection = RunService.RenderStepped:Connect(function()
    if Config.State.Unloaded then
        for p, _ in pairs(Cache.Draw) do RemoveDrawings(p) end
        CrosshairX:Remove(); CrosshairY:Remove()
        return
    end

    if Config.Visuals.Crosshair then
        local center = UserInputService:GetMouseLocation()
        CrosshairX.Visible = true; CrosshairY.Visible = true
        CrosshairX.Color = Config.Colors.Main; CrosshairY.Color = Config.Colors.Main
        CrosshairX.From = center - Vector2.new(8, 0); CrosshairX.To = center + Vector2.new(8, 0)
        CrosshairY.From = center - Vector2.new(0, 8); CrosshairY.To = center + Vector2.new(0, 8)
    else CrosshairX.Visible = false; CrosshairY.Visible = false end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not Cache.Draw[player] then CreateDrawings(player) end
        local d = Cache.Draw[player]

        local success, err = pcall(function()
            local char = player.Character
            if not char then HideDrawings(player) return end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if not root or not hum or hum.Health <= 0 then HideDrawings(player) return end
            if Config.Combat.TeamCheck and player.Team ~= nil and player.Team == LocalPlayer.Team then HideDrawings(player) return end
            
            -- Head jest opcjonalny - fallback do root+offset jeśli go brak
            local head = char:FindFirstChild("Head")
            local headPos = head and head.Position or (root.Position + Vector3.new(0, 1.5, 0))
            
            local dist = (Camera.CFrame.Position - root.Position).Magnitude
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if dist >= Config.Visuals.MinDistance and dist <= Config.Visuals.MaxDistance then
                local color = Config.Colors.Enemy
                
                if onScreen then
                    d.OOF_Arrow.Visible = false; d.OOF_ArrowOutline.Visible = false
                    local hPos = Camera:WorldToViewportPoint(headPos + Vector3.new(0, 0.8, 0))
                    local lPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(hPos.Y - lPos.Y)
                    if height < 5 then HideDrawings(player) return end -- Za mały do rysowania
                    local width = height * 0.6
                    local boxPos = Vector2.new(pos.X - width/2, hPos.Y); local boxSize = Vector2.new(width, height)

                    local showBox = Config.Visuals.BoxESP and not Config.Visuals.CornerBox
                    d.Box.Visible = showBox; d.BoxOutline.Visible = showBox
                    if showBox then d.Box.Position = boxPos; d.Box.Size = boxSize; d.Box.Color = color; d.BoxOutline.Position = boxPos; d.BoxOutline.Size = boxSize end

                    for i, l in pairs(d.Corners) do l.Visible = Config.Visuals.CornerBox; l.Color = color end
                    if Config.Visuals.CornerBox then
                        local cL = width / 4
                        d.Corners[1].From = boxPos; d.Corners[1].To = boxPos + Vector2.new(cL, 0); d.Corners[2].From = boxPos; d.Corners[2].To = boxPos + Vector2.new(0, cL)
                        d.Corners[3].From = boxPos + Vector2.new(width, 0); d.Corners[3].To = boxPos + Vector2.new(width - cL, 0); d.Corners[4].From = boxPos + Vector2.new(width, 0); d.Corners[4].To = boxPos + Vector2.new(width, cL)
                        d.Corners[5].From = boxPos + Vector2.new(0, height); d.Corners[5].To = boxPos + Vector2.new(cL, height); d.Corners[6].From = boxPos + Vector2.new(0, height); d.Corners[6].To = boxPos + Vector2.new(0, height - cL)
                        d.Corners[7].From = boxPos + Vector2.new(width, height); d.Corners[7].To = boxPos + Vector2.new(width - cL, height); d.Corners[8].From = boxPos + Vector2.new(width, height); d.Corners[8].To = boxPos + Vector2.new(width, height - cL)
                    end

                    d.HealthBar.Visible = Config.Visuals.HealthBar; d.HealthBarBG.Visible = Config.Visuals.HealthBar
                    if Config.Visuals.HealthBar then
                        local maxHp = math.max(hum.MaxHealth, 1)
                        local barH = height * math.clamp(hum.Health / maxHp, 0, 1)
                        local barP = boxPos - Vector2.new(6, 0)
                        d.HealthBarBG.Position = barP; d.HealthBarBG.Size = Vector2.new(3, height)
                        d.HealthBar.Position = barP + Vector2.new(0, height - barH); d.HealthBar.Size = Vector2.new(3, barH)
                        d.HealthBar.Color = Color3.fromHSV(math.clamp(hum.Health / maxHp, 0, 1) * 0.3, 1, 1)
                    end

                        for i, l in pairs(d.Skeleton) do
                            l.Visible = Config.Visuals.Skeleton
                            if Config.Visuals.Skeleton then
                                local c = SkeletonConnections[i]; local p1, p2 = char:FindFirstChild(c[1]), char:FindFirstChild(c[2])
                                if p1 and p2 then
                                    local pos1, vis1 = Camera:WorldToViewportPoint(p1.Position); local pos2, vis2 = Camera:WorldToViewportPoint(p2.Position)
                                    if vis1 and vis2 then l.From = Vector2.new(pos1.X, pos1.Y); l.To = Vector2.new(pos2.X, pos2.Y); l.Color = Color3.new(1,1,1) else l.Visible = false end
                                else l.Visible = false end
                            end
                        end

                    d.Tag.Visible = Config.Visuals.NameTags
                    if Config.Visuals.NameTags then d.Tag.Text = string.format("%s\n[%dm] %dHP", player.Name, math.floor(dist), math.floor(hum.Health)); d.Tag.Position = Vector2.new(pos.X, boxPos.Y - 30); d.Tag.Color = Color3.new(1,1,1) end

                    if Config.Visuals.WeaponESP then
                        local w = char:FindFirstChildOfClass("Tool")
                        if w then d.WeaponTag.Visible = true; d.WeaponTag.Text = w.Name; d.WeaponTag.Position = Vector2.new(pos.X, boxPos.Y + height + 2); d.WeaponTag.Color = Color3.fromRGB(200, 200, 200) else d.WeaponTag.Visible = false end
                    else d.WeaponTag.Visible = false end

                    d.Tracer.Visible = Config.Visuals.Tracers
                    if Config.Visuals.Tracers then d.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); d.Tracer.To = Vector2.new(pos.X, pos.Y); d.Tracer.Color = color end

                    if Config.Visuals.Chams then
                        if not Cache.Chams[player] then local h = Instance.new("Highlight"); h.Adornee = char; h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; h.OutlineColor = Color3.new(1,1,1); h.Parent = SafeGui; Cache.Chams[player] = h end
                        Cache.Chams[player].Enabled = true; Cache.Chams[player].Adornee = char; Cache.Chams[player].FillColor = color; Cache.Chams[player].FillTransparency = 0.5
                    elseif Cache.Chams[player] then Cache.Chams[player].Enabled = false end

                elseif Config.Visuals.OffScreenArrows then
                    HideDrawings(player); d.OOF_Arrow.Visible = true; d.OOF_ArrowOutline.Visible = true
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local sPos = Vector3.new(pos.X, pos.Y, pos.Z); if pos.Z < 0 then sPos = Vector3.new(-pos.X, -pos.Y, pos.Z) end
                    local dir = (Vector2.new(sPos.X, sPos.Y) - center).Unit; local aD = 200 
                    local aP, aB = center + (dir * (aD + 20)), center + (dir * aD)
                    local perp = Vector2.new(-dir.Y, dir.X); local lB, rB = aB + (perp * 12), aB - (perp * 12)
                    d.OOF_Arrow.PointA = aP; d.OOF_Arrow.PointB = lB; d.OOF_Arrow.PointC = rB; d.OOF_Arrow.Color = color
                    d.OOF_ArrowOutline.PointA = aP; d.OOF_ArrowOutline.PointB = lB; d.OOF_ArrowOutline.PointC = rB
                else HideDrawings(player) end
            else HideDrawings(player) end
        end)
        if not success then warn("[SOLARA ESP ERROR]", err); HideDrawings(player) end
    end
end)
table.insert(getgenv().SolarConnections, ESP_Connection)
local PlayerRemovingConn = Players.PlayerRemoving:Connect(RemoveDrawings)
table.insert(getgenv().SolarConnections, PlayerRemovingConn)

-- ==============================================================================
--[ AIMBOT & COMBAT LOGIC ]
-- ==============================================================================
local FOVRing = Drawing.new("Circle"); FOVRing.Thickness = 1.5; FOVRing.NumSides = 60; FOVRing.Filled = false; FOVRing.Transparency = 0.8
local CurrentTarget = nil

local WeaponData = {
    ["L96A1"] = {Speed = 4000, Gravity = 150}, ["M24"] = {Speed = 3800, Gravity = 160}, ["PSG-1"] = {Speed = 3700, Gravity = 170},
    ["M14"] = {Speed = 3200, Gravity = 180}, ["Model 70"] = {Speed = 3500, Gravity = 160}, ["AK-47"] = {Speed = 2600, Gravity = 196},
    ["AK-74"] = {Speed = 2800, Gravity = 196}, ["M4A1"] = {Speed = 2900, Gravity = 196}, ["HK416"] = {Speed = 3000, Gravity = 196},
    ["FAL"] = {Speed = 3100, Gravity = 190}, ["G3"] = {Speed = 3100, Gravity = 190}, ["Aug"] = {Speed = 2900, Gravity = 196},
    ["MP5"] = {Speed = 2000, Gravity = 220}, ["MP7"] = {Speed = 2100, Gravity = 210}, ["UZI"] = {Speed = 1800, Gravity = 240},
    ["MAC-10"] = {Speed = 1700, Gravity = 250}, ["Glock 17"] = {Speed = 1500, Gravity = 250}, ["M1911"] = {Speed = 1400, Gravity = 260},
}

local function UpdateWeaponCalibration()
    if not Config.Combat.AutoCalibration then return end
    local char = LocalPlayer.Character; if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local stats = WeaponData[tool.Name]
        if stats then Config.Combat.BulletSpeed = stats.Speed; Config.Combat.BulletGravity = stats.Gravity
        else
            local n = tool.Name:lower()
            if n:find("ak") or n:find("m4") or n:find("hk") or n:find("ar") then Config.Combat.BulletSpeed = 2700; Config.Combat.BulletGravity = 196
            elseif n:find("sniper") or n:find("l9") or n:find("m24") or n:find("rifle") then Config.Combat.BulletSpeed = 3500; Config.Combat.BulletGravity = 160
            elseif n:find("smg") or n:find("mp") or n:find("uzi") then Config.Combat.BulletSpeed = 2000; Config.Combat.BulletGravity = 220 end
        end
    end
end

local function IsAimAlive(player)
    if Config.Combat.TeamCheck and player.Team ~= nil and player.Team == LocalPlayer.Team then return false end
    return player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

local function IsVisible(part)
    if not Config.Combat.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(origin, direction, params)
    if not result then return true end -- Nic nie blokuje = widoczny
    return result.Instance:IsDescendantOf(part.Parent)
end

local function GetClosest()
    local target = nil; local dist = Config.Combat.FOV; local mouse = UserInputService:GetMouseLocation()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAimAlive(player) then
            local part = player.Character:FindFirstChild(Config.Combat.AimPart)
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen and IsVisible(part) then
                    local mag = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                    if mag < dist then target = player; dist = mag end
                end
            end
        end
    end
    return target
end

local AimBeganConn = UserInputService.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 then Config.State.Aiming = true end end)
local AimEndedConn = UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 then Config.State.Aiming = false end end)
table.insert(getgenv().SolarConnections, AimBeganConn)
table.insert(getgenv().SolarConnections, AimEndedConn)

local AimRenderConn = RunService.RenderStepped:Connect(function()
    if Config.State.Unloaded then FOVRing:Remove() return end
    UpdateWeaponCalibration()
    FOVRing.Visible = Config.Combat.ShowFOV and Config.Combat.AimAssist; FOVRing.Radius = Config.Combat.FOV; FOVRing.Position = UserInputService:GetMouseLocation(); FOVRing.Color = Config.Colors.Main
    if Config.State.Aiming and Config.Combat.AimAssist then
        if not CurrentTarget or not IsAimAlive(CurrentTarget) then CurrentTarget = GetClosest() end
        if CurrentTarget and IsAimAlive(CurrentTarget) then
            local part, root = CurrentTarget.Character:FindFirstChild(Config.Combat.AimPart), CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
            if part and root then
                local aimP = part.Position
                if Config.Combat.AdvancedPrediction then
                    local d = (Camera.CFrame.Position - part.Position).Magnitude
                    local vel = root.AssemblyLinearVelocity or Vector3.new(0,0,0)
                    -- Clamp: ignoruj absurdalne prędkości (pojazdy, bugi)
                    if vel.Magnitude > 100 then vel = vel.Unit * 100 end
                    local t = math.clamp(d / math.max(Config.Combat.BulletSpeed, 500), 0, 0.5)
                    aimP = aimP + (vel * t) + Vector3.new(0, 0.5 * Config.Combat.BulletGravity * (t * t), 0)
                end
                local pos, onScreen = Camera:WorldToViewportPoint(aimP)
                if onScreen then
                    local m = UserInputService:GetMouseLocation()
                    local moveX = (pos.X - m.X) * Config.Combat.Smoothness
                    local moveY = (pos.Y - m.Y) * Config.Combat.Smoothness
                    -- Clamp ruch myszy żeby nie wyrzucało losowo
                    moveX = math.clamp(moveX, -150, 150)
                    moveY = math.clamp(moveY, -150, 150)
                    if mousemoverel then
                        mousemoverel(moveX, moveY)
                    else
                        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimP), Config.Combat.Smoothness)
                    end
                else CurrentTarget = nil end
            end
        end
    else CurrentTarget = nil end
end)
table.insert(getgenv().SolarConnections, AimRenderConn)

print("========================================")
print("   SOLARA AR2 ELITE v4 ZAŁADOWANA!   ")
print("   Klawisz: INSERT do menu           ")
print("========================================")
warn("[SOLARA] Jeśli nie widzisz ESP, sprawdź czy masz włączone opcje w menu!")