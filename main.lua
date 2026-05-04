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
        AimKey = Enum.UserInputType.MouseButton2,
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
CreateKeybind(TabCbt, "Aim Key", "Combat", "AimKey")
CreateToggle(TabCbt, "Show FOV", "ShowFOV", "Combat")
CreateToggle(TabCbt, "Wall Check", "WallCheck", "Combat")
CreateToggle(TabCbt, "Advanced Physics", "AdvancedPrediction", "Combat")
CreateSlider(TabCbt, "Aim Smooth", "Combat", "Smoothness", 0.01, 1, true)
CreateSlider(TabCbt, "FOV Size", "Combat", "FOV", 10, 600, false)

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
        Tracer = Drawing.new("Line")
    }
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
        d.Tag.Visible = false; d.Dist.Visible = false; d.Weapon.Visible = false; d.Team.Visible = false; d.Tracer.Visible = false 
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

getgenv().ClearESP = function()
    for p, _ in pairs(Cache.Draw) do RemovePlayer(p) end
end

local ESP_Loop = RunService.RenderStepped:Connect(function()
    if Config.State.Unloaded then 
        for p, _ in pairs(Cache.Draw) do RemovePlayer(p) end 
        return 
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not Cache.Draw[p] then CreateDrawings(p) end
        local char = p.Character
        local root = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"))
        local hum = char and char:FindFirstChild("Humanoid")
        
        if root and hum and hum.Health > 0 then
            local dist = (Camera.CFrame.Position - root.Position).Magnitude
            if dist > Config.Visuals.MaxDistance then HideAll(p) continue end
            
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local d = Cache.Draw[p]
                local hPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.5, 0))
                local lPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local h = math.abs(hPos.Y - lPos.Y); local w = h * 0.6; local bPos = Vector2.new(pos.X - w/2, hPos.Y)
                
                local showC = Config.Visuals.CornerBox
                if d.Box.Visible ~= (Config.Visuals.BoxESP and not showC) then
                    d.Box.Visible = Config.Visuals.BoxESP and not showC; d.BoxOut.Visible = d.Box.Visible
                end
                
                if d.Box.Visible then d.Box.Position = bPos; d.Box.Size = Vector2.new(w, h); d.Box.Color = Config.Colors.Enemy; d.BoxOut.Position = bPos; d.BoxOut.Size = Vector2.new(w, h) end
                
                local cVis = Config.Visuals.BoxESP and showC
                if d.Corners[1].Visible ~= cVis then
                    for i=1, 8 do d.Corners[i].Visible = cVis; d.CornersOut[i].Visible = cVis end
                end
                
                if cVis then
                    local cl = w/4; local c, co = d.Corners, d.CornersOut
                    c[1].From = bPos; c[1].To = bPos + Vector2.new(cl, 0); c[2].From = bPos; c[2].To = bPos + Vector2.new(0, cl)
                    c[3].From = bPos + Vector2.new(w, 0); c[3].To = bPos + Vector2.new(w - cl, 0); c[4].From = bPos + Vector2.new(w, 0); c[4].To = bPos + Vector2.new(w, cl)
                    c[5].From = bPos + Vector2.new(0, h); c[5].To = bPos + Vector2.new(cl, h); c[6].From = bPos + Vector2.new(0, h); c[6].To = bPos + Vector2.new(0, h - cl)
                    c[7].From = bPos + Vector2.new(w, h); c[7].To = bPos + Vector2.new(w - cl, h); c[8].From = bPos + Vector2.new(w, h); c[8].To = bPos + Vector2.new(w, h - cl)
                    for i=1, 8 do c[i].Color = Config.Colors.Enemy; co[i].From = c[i].From; co[i].To = c[i].To end
                end

                if d.Health.Visible ~= Config.Visuals.HealthBar then d.Health.Visible = Config.Visuals.HealthBar; d.HealthBG.Visible = Config.Visuals.HealthBar end
                if d.Health.Visible then
                    local pct = hum.Health / hum.MaxHealth; d.HealthBG.Position = bPos - Vector2.new(5, 0); d.HealthBG.Size = Vector2.new(2, h)
                    d.Health.Position = bPos + Vector2.new(-5, h - (h*pct)); d.Health.Size = Vector2.new(2, h*pct); d.Health.Color = pct > 0.6 and Config.Colors.HealthHigh or (pct > 0.3 and Config.Colors.HealthMid or Config.Colors.HealthLow)
                end
                
                local showTags = Config.Visuals.NameTags
                if d.Tag.Visible ~= showTags then d.Tag.Visible = showTags; d.Dist.Visible = showTags; d.Team.Visible = showTags end
                if d.Weapon.Visible ~= Config.Visuals.WeaponESP then d.Weapon.Visible = Config.Visuals.WeaponESP end
                
                if showTags then
                    d.Tag.Text = p.Name; d.Tag.Position = Vector2.new(pos.X, bPos.Y - 15)
                    d.Dist.Text = math.floor(dist) .. "m"; d.Dist.Position = Vector2.new(pos.X, bPos.Y + h + 2)
                    d.Team.Text = "👥 " .. (p.Team and p.Team.Name or "No Team"); d.Team.Position = Vector2.new(pos.X, bPos.Y + h + 14)
                end
                if d.Weapon.Visible then
                    local tool = char:FindFirstChildOfClass("Tool"); d.Weapon.Text = "🔫 " .. (tool and tool.Name or "None"); d.Weapon.Position = Vector2.new(pos.X, bPos.Y + h + (showTags and 26 or 2))
                end

                if d.Tracer.Visible ~= Config.Visuals.Tracers then d.Tracer.Visible = Config.Visuals.Tracers end
                if d.Tracer.Visible then
                    d.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    d.Tracer.To = Vector2.new(pos.X, bPos.Y + h)
                    d.Tracer.Color = (CurrentT == p) and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
                end

                if Config.Visuals.Chams and dist < 800 then
                    if not Cache.Chams[p] then 
                        local hInst = Instance.new("Highlight")
                        hInst.Parent = SafeGui
                        hInst.Adornee = char
                        hInst.FillColor = Config.Colors.Enemy
                        hInst.FillTransparency = 0.5
                        hInst.OutlineColor = Color3.new(1,1,1)
                        hInst.OutlineTransparency = 0
                        hInst.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        Cache.Chams[p] = hInst
                    end
                    if not Cache.Chams[p].Enabled then Cache.Chams[p].Enabled = true end
                elseif Cache.Chams[p] and Cache.Chams[p].Enabled then 
                    Cache.Chams[p].Enabled = false 
                end

            else HideAll(p) end
        else HideAll(p) end
    end
end)
table.insert(getgenv().SolarConnections, ESP_Loop)
Players.PlayerRemoving:Connect(RemovePlayer)

-- ==============================================================================
--[ AIMBOT v5 ]
-- ==============================================================================


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
        if p ~= LocalPlayer then
            local char = p.Character
            local root = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"))
            local hum = char and char:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local part = char:FindFirstChild(Config.Combat.AimPart)
                if part then
                    local pos, on = Camera:WorldToViewportPoint(part.Position)
                    if on then
                        local mag = (Vector2.new(pos.X, pos.Y) - m).Magnitude
                        if mag < dist then target = p; dist = mag end
                    end
                end
            end
        end
    end
    return target
end

table.insert(getgenv().SolarConnections, UserInputService.InputBegan:Connect(function(i) if not listening and (i.UserInputType == Config.Combat.AimKey or i.KeyCode == Config.Combat.AimKey) then Config.State.Aiming = true end end))
table.insert(getgenv().SolarConnections, UserInputService.InputEnded:Connect(function(i) if (i.UserInputType == Config.Combat.AimKey or i.KeyCode == Config.Combat.AimKey) then Config.State.Aiming = false end end))

local AimLoop = RunService.RenderStepped:Connect(function()
    if Config.State.Unloaded then return end
    
    local fovRing = getgenv().FOVRing
    if fovRing then
        fovRing.Visible = Config.Combat.ShowFOV
        fovRing.Radius = Config.Combat.FOV
        fovRing.Position = UserInputService:GetMouseLocation()
        fovRing.Color = Config.Colors.Main
    end
    
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