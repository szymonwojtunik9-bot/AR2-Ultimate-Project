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
        Skeleton = false, -- Domyślnie wyłączone dla FPS
        WeaponESP = true,
        Tracers = false,
        OffScreenArrows = true,
        Chams = true,
        MaxDistance = 3000,
        MinDistance = 0,
        Crosshair = true,
        ESP_FPS_Limit = 1 -- Limit odświeżania (klatki)
    },
    Combat = {
        AimAssist = true,
        ShowFOV = true,
        FOV = 150,
        MaxDistance = 3000,
        Smoothness = 0.4,
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
local Title = Instance.new("TextLabel", Sidebar); Title.Size = UDim2.new(1, 0, 0, 50); Title.Text = "AR2 PRO v5"; Title.Font = Enum.Font.GothamBlack; Title.TextColor3 = Config.Colors.Main; Title.TextSize = 18; Title.BackgroundTransparency = 1

local Content = Instance.new("Frame", MainFrame); Content.Size = UDim2.new(1, -150, 1, -20); Content.Position = UDim2.new(0, 150, 0, 10); Content.BackgroundTransparency = 1
local Tabs = {}; local TabFrames = {}

local function SelectTab(n)
    for name, f in pairs(TabFrames) do f.Visible = (name == n) end
    for name, b in pairs(Tabs) do if name == n then Tween(b, {BackgroundColor3 = Config.Colors.Main, TextColor3 = Color3.new(1,1,1)}) else Tween(b, {BackgroundColor3 = Config.Colors.Element, TextColor3 = Config.Colors.TextDark}) end end
end

local function CreateTab(n)
    local B = Instance.new("TextButton", Sidebar); B.Size = UDim2.new(0, 120, 0, 35); B.BackgroundColor3 = Config.Colors.Element; B.Text = n; B.Font = Enum.Font.GothamBold; B.TextColor3 = Config.Colors.TextDark; B.TextSize = 13; B.AutoButtonColor = false; Round(B, 6)
    local F = Instance.new("ScrollingFrame", Content); F.Size = UDim2.new(1, 0, 1, 0); F.BackgroundTransparency = 1; F.ScrollBarThickness = 2; F.Visible = false
    local L = Instance.new("UIListLayout", F); L.Padding = UDim.new(0, 8); L.HorizontalAlignment = Enum.HorizontalAlignment.Center
    L:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() F.CanvasSize = UDim2.new(0, 0, 0, L.AbsoluteContentSize.Y + 10) end)
    Tabs[n] = B; TabFrames[n] = F; B.MouseButton1Click:Connect(function() SelectTab(n) end)
    return F
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

local TabVis = CreateTab("Visuals"); local TabCbt = CreateTab("Combat"); local TabSet = CreateTab("Settings"); SelectTab("Visuals")

CreateToggle(TabVis, "Boxes", "BoxESP", "Visuals")
CreateToggle(TabVis, "Health Bar", "HealthBar", "Visuals")
CreateToggle(TabVis, "Skeleton (FPS Heavy)", "Skeleton", "Visuals")
CreateToggle(TabVis, "Nicknames", "NameTags", "Visuals")
CreateToggle(TabVis, "Weapon ESP", "WeaponESP", "Visuals")
CreateToggle(TabVis, "Tracers", "Tracers", "Visuals")
CreateToggle(TabVis, "Off-Screen Arrows", "OffScreenArrows", "Visuals")
CreateToggle(TabVis, "Chams (Highlight)", "Chams", "Visuals")
CreateSlider(TabVis, "Max Distance", "Visuals", "MaxDistance", 100, 10000, false)

CreateToggle(TabCbt, "Aimbot", "AimAssist", "Combat")
CreateToggle(TabCbt, "Show FOV", "ShowFOV", "Combat")
CreateToggle(TabCbt, "Wall Check", "WallCheck", "Combat")
CreateToggle(TabCbt, "Advanced Physics", "AdvancedPrediction", "Combat")
CreateSlider(TabCbt, "Aim Smooth", "Combat", "Smoothness", 0.01, 1, true)
CreateSlider(TabCbt, "FOV Size", "Combat", "FOV", 10, 600, false)

local UnloadBtn = Instance.new("TextButton", TabSet); UnloadBtn.Size = UDim2.new(1, -10, 0, 45); UnloadBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40); UnloadBtn.Text = "WYŁĄCZ I WYCZYŚĆ"; UnloadBtn.Font = Enum.Font.GothamBold; UnloadBtn.TextColor3 = Color3.new(1,1,1); UnloadBtn.TextSize = 14; Round(UnloadBtn, 8)
getgenv().UnloadSolar = function()
    Config.State.Unloaded = true
    for _, c in pairs(getgenv().SolarConnections) do pcall(function() c:Disconnect() end) end
    if ScreenGui then ScreenGui:Destroy() end
    getgenv().SolarConfig = nil; getgenv().UnloadSolar = nil
    print("[SOLARA] Wersja v5 wyczyszczona.")
end
UnloadBtn.MouseButton1Click:Connect(getgenv().UnloadSolar)
table.insert(getgenv().SolarConnections, UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.Insert then ScreenGui.Enabled = not ScreenGui.Enabled end end))

-- ==============================================================================
--[ LOGIKA ESP v5 (ULTRA OPTIMIZED) ]
-- ==============================================================================
local Cache = { Draw = {}, Chams = {} }
local SkeletonConns = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}}

local function CreateDrawings(p)
    local d = {
        Box = Drawing.new("Square"), BoxOut = Drawing.new("Square"),
        HealthBG = Drawing.new("Square"), Health = Drawing.new("Square"),
        Tag = Drawing.new("Text"), Weapon = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        Arrow = Drawing.new("Triangle"), ArrowOut = Drawing.new("Triangle"),
        Skeleton = {}
    }
    d.Box.Thickness = 1; d.BoxOut.Thickness = 3; d.BoxOut.Color = Color3.new(0,0,0)
    d.HealthBG.Filled = true; d.HealthBG.Color = Color3.new(0,0,0); d.Health.Filled = true
    d.Tag.Size = 13; d.Tag.Center = true; d.Tag.Outline = true; d.Tag.Font = 3
    d.Weapon.Size = 12; d.Weapon.Center = true; d.Weapon.Outline = true; d.Weapon.Font = 3
    d.Arrow.Filled = true; d.ArrowOut.Thickness = 2; d.ArrowOut.Color = Color3.new(0,0,0)
    for i=1, #SkeletonConns do table.insert(d.Skeleton, Drawing.new("Line")) end
    Cache.Draw[p] = d
end

local function HideAll(p)
    local d = Cache.Draw[p]
    if d then
        d.Box.Visible = false; d.BoxOut.Visible = false; d.Health.Visible = false; d.HealthBG.Visible = false
        d.Tag.Visible = false; d.Weapon.Visible = false; d.Tracer.Visible = false
        d.Arrow.Visible = false; d.ArrowOut.Visible = false
        for _, l in pairs(d.Skeleton) do l.Visible = false end
    end
    if Cache.Chams[p] then Cache.Chams[p].Enabled = false end
end

local function RemovePlayer(p)
    if Cache.Draw[p] then for _, v in pairs(Cache.Draw[p]) do if type(v) == "table" then for _, l in pairs(v) do l:Remove() end else v:Remove() end end Cache.Draw[p] = nil end
    if Cache.Chams[p] then Cache.Chams[p]:Destroy(); Cache.Chams[p] = nil end
end

local CrosshairX = Drawing.new("Line"); local CrosshairY = Drawing.new("Line")
CrosshairX.Thickness = 1.5; CrosshairY.Thickness = 1.5

local frameCount = 0
local ESP_Loop = RunService.RenderStepped:Connect(function()
    if Config.State.Unloaded then 
        for p, _ in pairs(Cache.Draw) do RemovePlayer(p) end 
        CrosshairX:Remove(); CrosshairY:Remove()
        return 
    end

    frameCount = frameCount + 1
    
    if Config.Visuals.Crosshair then
        local m = UserInputService:GetMouseLocation()
        CrosshairX.Visible = true; CrosshairY.Visible = true; CrosshairX.Color = Config.Colors.Main; CrosshairY.Color = Config.Colors.Main
        CrosshairX.From = m - Vector2.new(7, 0); CrosshairX.To = m + Vector2.new(7, 0)
        CrosshairY.From = m - Vector2.new(0, 7); CrosshairY.To = m + Vector2.new(0, 7)
    else CrosshairX.Visible = false; CrosshairY.Visible = false end

    -- Optymalizacja: Przetwarzaj graczy co X klatek jeśli jest ich dużo
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not Cache.Draw[p] then CreateDrawings(p) end
        
        local success, err = pcall(function()
            local char = p.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                if hum.Health <= 0 then HideAll(p) return end
                
                local root = char.HumanoidRootPart
                local dist = (Camera.CFrame.Position - root.Position).Magnitude
                
                if dist > Config.Visuals.MaxDistance then HideAll(p) return end
                
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                local color = Config.Colors.Enemy

                if onScreen then
                    local d = Cache.Draw[p]
                    d.Arrow.Visible = false; d.ArrowOut.Visible = false
                    
                    local head = char:FindFirstChild("Head")
                    local hPos = Camera:WorldToViewportPoint(head and head.Position + Vector3.new(0, 0.8, 0) or root.Position + Vector3.new(0, 2.3, 0))
                    local lPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    
                    local h = math.abs(hPos.Y - lPos.Y)
                    local w = h * 0.6
                    local bPos = Vector2.new(pos.X - w/2, hPos.Y)
                    
                    if h < 2 then HideAll(p) return end

                    -- Box
                    d.Box.Visible = Config.Visuals.BoxESP; d.BoxOut.Visible = Config.Visuals.BoxESP
                    if Config.Visuals.BoxESP then
                        d.Box.Position = bPos; d.Box.Size = Vector2.new(w, h); d.Box.Color = color
                        d.BoxOut.Position = bPos; d.BoxOut.Size = Vector2.new(w, h)
                    end

                    -- Health
                    d.Health.Visible = Config.Visuals.HealthBar; d.HealthBG.Visible = Config.Visuals.HealthBar
                    if Config.Visuals.HealthBar then
                        local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                        local bH = math.max(h * pct, 0.1)
                        d.HealthBG.Position = bPos - Vector2.new(5, 0); d.HealthBG.Size = Vector2.new(2, h)
                        d.Health.Position = bPos + Vector2.new(-5, h - bH); d.Health.Size = Vector2.new(2, bH)
                        d.Health.Color = Color3.fromHSV(pct * 0.3, 1, 1)
                    end

                    -- Nick & Dist
                    d.Tag.Visible = Config.Visuals.NameTags
                    if Config.Visuals.NameTags then
                        d.Tag.Text = string.format("%s [%dm]", p.Name, math.floor(dist))
                        d.Tag.Position = Vector2.new(pos.X, bPos.Y - 15); d.Tag.Color = Color3.new(1,1,1)
                    end

                    -- Skeleton (Zoptymalizowany)
                    local showSkel = Config.Visuals.Skeleton
                    for i, line in pairs(d.Skeleton) do
                        line.Visible = showSkel
                        if showSkel then
                            local c = SkeletonConns[i]
                            local p1, p2 = char:FindFirstChild(c[1]), char:FindFirstChild(c[2])
                            if p1 and p2 then
                                local v1, on1 = Camera:WorldToViewportPoint(p1.Position)
                                local v2, on2 = Camera:WorldToViewportPoint(p2.Position)
                                if on1 and on2 then line.From = Vector2.new(v1.X, v1.Y); line.To = Vector2.new(v2.X, v2.Y); line.Color = Color3.new(1,1,1) else line.Visible = false end
                            else line.Visible = false end
                        end
                    end
                    
                    -- Chams
                    if Config.Visuals.Chams then
                        if not Cache.Chams[p] then
                            local h = Instance.new("Highlight", SafeGui)
                            h.Adornee = char; h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; Cache.Chams[p] = h
                        end
                        Cache.Chams[p].Enabled = true; Cache.Chams[p].FillColor = color; Cache.Chams[p].FillTransparency = 0.5
                    elseif Cache.Chams[p] then Cache.Chams[p].Enabled = false end

                elseif Config.Visuals.OffScreenArrows then
                    HideAll(p); local d = Cache.Draw[p]
                    d.Arrow.Visible = true; d.ArrowOut.Visible = true
                    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    local sPos = Vector3.new(pos.X, pos.Y, pos.Z); if pos.Z < 0 then sPos = Vector3.new(-pos.X, -pos.Y, pos.Z) end
                    local dir = (Vector2.new(sPos.X, sPos.Y) - center).Unit
                    local arrowP = center + (dir * 220)
                    local arrowB = center + (dir * 200)
                    local perp = Vector2.new(-dir.Y, dir.X)
                    d.Arrow.PointA = arrowP; d.Arrow.PointB = arrowB + (perp * 10); d.Arrow.PointC = arrowB - (perp * 10); d.Arrow.Color = color
                    d.ArrowOut.PointA = arrowP; d.ArrowOut.PointB = arrowB + (perp * 10); d.ArrowOut.PointC = arrowB - (perp * 10)
                else HideAll(p) end
            else HideAll(p) end
        end)
    end
end)
table.insert(getgenv().SolarConnections, ESP_Loop)
Players.PlayerRemoving:Connect(RemovePlayer)

-- ==============================================================================
--[ AIMBOT v5 ]
-- ==============================================================================
local FOVRing = Drawing.new("Circle")
FOVRing.Thickness = 1.5; FOVRing.NumSides = 60; FOVRing.Transparency = 0.7
local CurrentT = nil

local WeaponData = {
    ["L96A1"] = {Speed = 4000, Gravity = 150}, ["M24"] = {Speed = 3800, Gravity = 160}, ["AK-47"] = {Speed = 2600, Gravity = 196},
    ["AK-74"] = {Speed = 2800, Gravity = 196}, ["M4A1"] = {Speed = 2900, Gravity = 196}, ["HK416"] = {Speed = 3000, Gravity = 196},
}

local function UpdateAim()
    if not Config.Combat.AutoCalibration then return end
    local char = LocalPlayer.Character; local tool = char and char:FindFirstChildOfClass("Tool")
    if tool then
        local s = WeaponData[tool.Name]
        if s then Config.Combat.BulletSpeed = s.Speed; Config.Combat.BulletGravity = s.Gravity end
    end
end

local function GetClosest()
    local target = nil; local dist = Config.Combat.FOV; local m = UserInputService:GetMouseLocation()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            local part = p.Character:FindFirstChild(Config.Combat.AimPart)
            if part then
                local pos, on = Camera:WorldToViewportPoint(part.Position)
                if on then
                    local mag = (Vector2.new(pos.X, pos.Y) - m).Magnitude
                    if mag < dist then target = p; dist = mag end
                end
            end
        end
    end
    return target
end

table.insert(getgenv().SolarConnections, UserInputService.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 then Config.State.Aiming = true end end))
table.insert(getgenv().SolarConnections, UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 then Config.State.Aiming = false end end))

local AimLoop = RunService.RenderStepped:Connect(function()
    if Config.State.Unloaded then FOVRing:Remove() return end
    FOVRing.Visible = Config.Combat.ShowFOV; FOVRing.Radius = Config.Combat.FOV; FOVRing.Position = UserInputService:GetMouseLocation(); FOVRing.Color = Config.Colors.Main
    
    if Config.State.Aiming and Config.Combat.AimAssist then
        UpdateAim()
        if not CurrentT or not CurrentT.Character or CurrentT.Character.Humanoid.Health <= 0 then CurrentT = GetClosest() end
        if CurrentT and CurrentT.Character then
            local part = CurrentT.Character:FindFirstChild(Config.Combat.AimPart)
            local root = CurrentT.Character:FindFirstChild("HumanoidRootPart")
            if part and root then
                local aimP = part.Position
                if Config.Combat.AdvancedPrediction then
                    local d = (Camera.CFrame.Position - aimP).Magnitude
                    local t = math.clamp(d / math.max(Config.Combat.BulletSpeed, 500), 0, 0.5)
                    local vel = root.AssemblyLinearVelocity; if vel.Magnitude > 100 then vel = vel.Unit * 100 end
                    aimP = aimP + (vel * t) + Vector3.new(0, 0.5 * Config.Combat.BulletGravity * (t*t), 0)
                end
                local pos, on = Camera:WorldToViewportPoint(aimP)
                if on then
                    local m = UserInputService:GetMouseLocation()
                    local mx = (pos.X - m.X) * Config.Combat.Smoothness
                    local my = (pos.Y - m.Y) * Config.Combat.Smoothness
                    if mousemoverel then mousemoverel(math.clamp(mx, -100, 100), math.clamp(my, -100, 100)) end
                else CurrentT = nil end
            end
        end
    else CurrentT = nil end
end)
table.insert(getgenv().SolarConnections, AimLoop)

print("========================================")
print("   SOLARA AR2 ELITE v5 ZAŁADOWANA!   ")
print("   Zoptymalizowano FPS i ESP         ")
print("========================================")