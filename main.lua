-- ==============================================================================
--[ VISUAL & COMBAT UTILITY - FINAL VERSION (READABLE ESP + AR2 FIX) ]
-- Zoptymalizowano pod: Solara v3 + Apocalypse Rising 2
-- Klawisz Menu: INSERT (Pokaż / Ukryj)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--[ BEZPIECZNE GUI (SOLARA FIX) ]
local SafeGui
local success = pcall(function() SafeGui = (gethui and gethui()) or CoreGui end)
if not success or not SafeGui then SafeGui = LocalPlayer:WaitForChild("PlayerGui") end

-- ==============================================================================
--[ 1. GLOBALNA KONFIGURACJA ]
-- ==============================================================================
local Config = {
    Visuals = {
        BoxESP = true,
        NameTags = true,
        Tracers = false,
        Chams = true,
        MaxDistance = 5000
    },
    Combat = {
        AimAssist = true,
        ShowFOV = true,
        FOV = 150,
        MaxDistance = 5000,
        Smoothness = 0.15,
        AimPart = "Head"
    },
    Colors = {
        Main = Color3.fromRGB(0, 170, 255),
        Enemy = Color3.fromRGB(255, 50, 50),
        UI_BG = Color3.fromRGB(20, 20, 25)
    }
}

local Cache = { Draw = {}, Chams = {}, Connections = {} }
local Aiming = false
local CurrentTarget = nil

local FOVRing = Drawing.new("Circle")
FOVRing.Visible = Config.Combat.ShowFOV
FOVRing.Thickness = 1.5
FOVRing.Color = Config.Colors.Main
FOVRing.Filled = false
FOVRing.Transparency = 0.8
FOVRing.NumSides = 60

-- ==============================================================================
--[ 2. TWORZENIE OKIENKA (MENU) ]
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SolarMenu_Final"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = SafeGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 480)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -240)
MainFrame.BackgroundColor3 = Config.Colors.UI_BG
MainFrame.BorderSizePixel = 0
MainFrame.Active = true

-- Przeciąganie okienka
local dragToggle, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
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

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "  SOLARA MENU (AR2 FIX)"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Config.Colors.Main
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtnX = Instance.new("TextButton", MainFrame)
CloseBtnX.Size = UDim2.new(0, 40, 0, 40)
CloseBtnX.Position = UDim2.new(1, -40, 0, 0)
CloseBtnX.BackgroundTransparency = 1
CloseBtnX.Text = "X"
CloseBtnX.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtnX.Font = Enum.Font.GothamBold
CloseBtnX.TextSize = 18

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, 0, 1, -50)
Scroll.Position = UDim2.new(0, 0, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 15)
end)

local function CreateToggle(text, configKey, category)
    local Btn = Instance.new("TextButton", Scroll)
    Btn.Size = UDim2.new(0, 270, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Btn.Text = "  " .. text
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    Btn.TextSize = 14
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local Indicator = Instance.new("Frame", Btn)
    Indicator.Size = UDim2.new(0, 16, 0, 16)
    Indicator.Position = UDim2.new(1, -25, 0.5, -8)
    Indicator.BackgroundColor3 = Config[category][configKey] and Config.Colors.Main or Color3.fromRGB(60, 60, 65)
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 4)

    Btn.MouseButton1Click:Connect(function()
        Config[category][configKey] = not Config[category][configKey]
        Indicator.BackgroundColor3 = Config[category][configKey] and Config.Colors.Main or Color3.fromRGB(60, 60, 65)
    end)
end

local function CreateSlider(text, category, key, min, max, isFloat)
    local Container = Instance.new("Frame", Scroll)
    Container.Size = UDim2.new(0, 270, 0, 45)
    Container.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.Text = text .. ": " .. tostring(Config[category][key])
    Label.Font = Enum.Font.GothamSemibold
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local BG = Instance.new("Frame", Container)
    BG.Size = UDim2.new(1, -20, 0, 6)
    BG.Position = UDim2.new(0, 10, 0, 30)
    BG.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    Instance.new("UICorner", BG)

    local Fill = Instance.new("Frame", BG)
    local startScale = (Config[category][key] - min) / (max - min)
    Fill.Size = UDim2.new(startScale, 0, 1, 0)
    Fill.BackgroundColor3 = Config.Colors.Main
    Instance.new("UICorner", Fill)

    local Btn = Instance.new("TextButton", BG)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""

    local sliding = false
    Btn.MouseButton1Down:Connect(function() sliding = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)

    RunService.RenderStepped:Connect(function()
        if sliding then
            local mousePos = UserInputService:GetMouseLocation().X
            local bgPos = BG.AbsolutePosition.X
            local bgSize = BG.AbsoluteSize.X
            local percent = math.clamp((mousePos - bgPos) / bgSize, 0, 1)
            
            local value = min + ((max - min) * percent)
            value = isFloat and (math.floor(value * 100) / 100) or math.floor(value)
            
            Config[category][key] = value
            Fill.Size = UDim2.new(percent, 0, 1, 0)
            Label.Text = text .. ": " .. tostring(value)
        end
    end)
end

local function CreateDivider()
    local Divider = Instance.new("Frame", Scroll)
    Divider.Size = UDim2.new(0, 270, 0, 2)
    Divider.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Divider.BorderSizePixel = 0
end

CreateToggle("Włącz Box ESP", "BoxESP", "Visuals")
CreateToggle("Włącz Nick & HP", "NameTags", "Visuals")
CreateToggle("Włącz Chamsy (Postać)", "Chams", "Visuals")
CreateSlider("Zasięg Widzenia ESP", "Visuals", "MaxDistance", 100, 20000, false)

CreateDivider()

CreateToggle("Włącz Aimbota (Prawy Myszki)", "AimAssist", "Combat")
CreateToggle("Pokaż Kółko Aimbota (FOV)", "ShowFOV", "Combat")
CreateSlider("Wielkość Kółka (FOV)", "Combat", "FOV", 10, 800, false)
CreateSlider("Zasięg Aimbota (Odległość)", "Combat", "MaxDistance", 100, 20000, false)
CreateSlider("Płynność Aimbota", "Combat", "Smoothness", 0.01, 1.0, true)

CreateDivider()

local UnloadBtn = Instance.new("TextButton", Scroll)
UnloadBtn.Size = UDim2.new(0, 270, 0, 35)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
UnloadBtn.Text = "WYŁĄCZ CAŁY SKRYPT"
UnloadBtn.Font = Enum.Font.GothamBold
UnloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadBtn.TextSize = 14
Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 6)

-- ==============================================================================
--[ 3. UNLOAD ]
-- ==============================================================================
local function UnloadScript()
    ScreenGui:Destroy()
    FOVRing:Remove()
    for _, connection in pairs(Cache.Connections) do connection:Disconnect() end
    for _, d in pairs(Cache.Draw) do d.Box:Remove(); d.Line:Remove(); d.Tag:Remove() end
    for _, cham in pairs(Cache.Chams) do cham:Destroy() end
    table.clear(Cache)
    Aiming = false
    CurrentTarget = nil
end

CloseBtnX.MouseButton1Click:Connect(UnloadScript)
UnloadBtn.MouseButton1Click:Connect(UnloadScript)

-- ==============================================================================
--[ 4. SYSTEM WYZNACZANIA CELU ]
-- ==============================================================================
local function IsAlive(player)
    return player and player.Character 
        and player.Character:FindFirstChild("HumanoidRootPart")
        and player.Character:FindFirstChild("Humanoid")
        and player.Character.Humanoid.Health > 0
end

local function GetClosestPlayer()
    local target = nil
    local shortestDist = Config.Combat.FOV
    local mouseLoc = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) then
            local aimPart = player.Character:FindFirstChild(Config.Combat.AimPart)
            if aimPart then
                local dist3D = (Camera.CFrame.Position - aimPart.Position).Magnitude
                if dist3D <= Config.Combat.MaxDistance then
                    local pos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                    if onScreen then
                        local dist2D = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                        if dist2D < shortestDist then
                            target = player
                            shortestDist = dist2D
                        end
                    end
                end
            end
        end
    end
    return target
end

-- ==============================================================================
--[ 5. ZAAWANSOWANE RENDEROWANIE ESP (SUPER CZYTELNE) ]
-- ==============================================================================
local function CreateDrawings(player)
    local d = { Box = Drawing.new("Square"), Line = Drawing.new("Line"), Tag = Drawing.new("Text") }
    
    -- Konfiguracja ramek (Box)
    d.Box.Visible = false
    d.Box.Thickness = 1.5
    d.Box.Filled = false
    
    -- Konfiguracja linii (Tracers)
    d.Line.Visible = false
    d.Line.Thickness = 1.5
    
    -- ULEPSZONA KONFIGURACJA TEKSTU (Czystość i kontrast)
    d.Tag.Visible = false
    d.Tag.Size = 16 -- Powiększony tekst
    d.Tag.Center = true
    d.Tag.Outline = true -- Wymuszony mocny obrys
    d.Tag.OutlineColor = Color3.fromRGB(0, 0, 0) -- Czarny obrys dla kontrastu
    d.Tag.Color = Color3.fromRGB(255, 255, 255) -- Czysty biały tekst
    d.Tag.Font = 3 -- Font 3 to "Plex" (wyraźny, pogrubiony, idealny do ESP)
    
    Cache.Draw[player] = d
end

local function UpdateVisuals()
    -- Renderowanie kółka FOV
    if Config.Combat.ShowFOV and Config.Combat.AimAssist then
        FOVRing.Visible = true
        FOVRing.Position = UserInputService:GetMouseLocation()
        FOVRing.Radius = Config.Combat.FOV
    else
        FOVRing.Visible = false
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        if not Cache.Draw[player] then CreateDrawings(player) end
        local drawings = Cache.Draw[player]

        local success = pcall(function()
            if IsAlive(player) then
                local char = player.Character
                local root = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChild("Humanoid")
                
                if not root or not head or not hum then return end
                
                local dist = (Camera.CFrame.Position - root.Position).Magnitude
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen and dist <= Config.Visuals.MaxDistance then
                    local espColor = Config.Colors.Enemy
                    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height * 0.65
                    
                    drawings.Box.Visible = Config.Visuals.BoxESP
                    drawings.Box.Size = Vector2.new(width, height)
                    drawings.Box.Position = Vector2.new(pos.X - width/2, headPos.Y)
                    drawings.Box.Color = espColor
                    
                    drawings.Line.Visible = Config.Visuals.Tracers
                    drawings.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    drawings.Line.To = Vector2.new(pos.X, legPos.Y)
                    drawings.Line.Color = espColor
                    
                    -- ULEPSZONE FORMATOWANIE NAPISÓW
                    if Config.Visuals.NameTags then
                        -- Zastosowanie lepszych proporcji i spacji między informacjami
                        drawings.Tag.Text = string.format("%s\n[%dm] | %d HP", player.Name, math.floor(dist), math.floor(hum.Health))
                        drawings.Tag.Position = Vector2.new(pos.X, headPos.Y - 35) -- Przesunięto nieco wyżej
                        drawings.Tag.Visible = true
                    else
                        drawings.Tag.Visible = false
                    end
                    
                    if Config.Visuals.Chams then
                        if not Cache.Chams[player] then
                            local h = Instance.new("Highlight")
                            h.Adornee = char
                            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            h.FillColor = espColor
                            h.FillTransparency = 0.5
                            h.OutlineColor = Color3.new(1,1,1)
                            h.Parent = SafeGui
                            Cache.Chams[player] = h
                        else
                            Cache.Chams[player].Enabled = true
                            Cache.Chams[player].FillColor = espColor
                            Cache.Chams[player].Adornee = char
                        end
                    elseif Cache.Chams[player] then
                        Cache.Chams[player].Enabled = false
                    end
                else
                    drawings.Box.Visible = false; drawings.Line.Visible = false; drawings.Tag.Visible = false
                    if Cache.Chams[player] then Cache.Chams[player].Enabled = false end
                end
            else
                drawings.Box.Visible = false; drawings.Line.Visible = false; drawings.Tag.Visible = false
                if Cache.Chams[player] then Cache.Chams[player].Enabled = false end
            end
        end)
        
        if not success then
            drawings.Box.Visible = false; drawings.Line.Visible = false; drawings.Tag.Visible = false
        end
    end
end

-- ==============================================================================
--[ 6. ZAAWANSOWANA LOGIKA AIMBOTA (MOUSEMOVEREL FIX DLA AR2) ]
-- ==============================================================================
local function UpdateAim()
    if not Config.Combat.AimAssist then CurrentTarget = nil return end

    if Aiming then
        if not CurrentTarget or not IsAlive(CurrentTarget) then
            CurrentTarget = GetClosestPlayer()
        end

        if CurrentTarget and IsAlive(CurrentTarget) then
            local aimPart = CurrentTarget.Character:FindFirstChild(Config.Combat.AimPart)
            if aimPart then
                if (Camera.CFrame.Position - aimPart.Position).Magnitude > Config.Combat.MaxDistance then
                    CurrentTarget = nil
                    return
                end

                local pos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                if not onScreen then
                    CurrentTarget = nil
                    return
                end
                
                local mouseLoc = UserInputService:GetMouseLocation()
                
                local moveX = (pos.X - mouseLoc.X)
                local moveY = (pos.Y - mouseLoc.Y)
                
                if mousemoverel then
                    mousemoverel(moveX * Config.Combat.Smoothness, moveY * Config.Combat.Smoothness)
                else
                    local targetCFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Combat.Smoothness)
                end
            end
        end
    else
        CurrentTarget = nil 
    end
end

-- ==============================================================================
--[ 7. KONTROLA KLAWISZY I PĘTLE ]
-- ==============================================================================
Cache.Connections.InputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then 
        Aiming = true 
    end
    if input.KeyCode == Enum.KeyCode.Insert then 
        ScreenGui.Enabled = not ScreenGui.Enabled 
    end
end)

Cache.Connections.InputEnded = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then 
        Aiming = false 
    end
end)

Cache.Connections.Render = RunService.RenderStepped:Connect(function()
    UpdateAim()
    UpdateVisuals()
end)

Cache.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
    if CurrentTarget == player then CurrentTarget = nil end
    if Cache.Draw[player] then
        Cache.Draw[player].Box:Remove()
        Cache.Draw[player].Line:Remove()
        Cache.Draw[player].Tag:Remove()
        Cache.Draw[player] = nil
    end
    if Cache.Chams[player] then
        Cache.Chams[player]:Destroy()
        Cache.Chams[player] = nil
    end
end)