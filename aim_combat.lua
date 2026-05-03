-- ==============================================================================
--[ MODUŁ 3: AIMBOT & COMBAT - ULTIMATE AR2 VERSION ]
-- Ten skrypt obsługuje namierzanie, FOV i zaawansowaną predykcję.
-- NOWOŚĆ: Automatyczna kalibracja balistyki pod trzymaną broń.
-- ==============================================================================

repeat task.wait() until getgenv().SolarConfig
local Config = getgenv().SolarConfig

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local FOVRing = Drawing.new("Circle")
FOVRing.Thickness = 1.5
FOVRing.NumSides = 60
FOVRing.Filled = false
FOVRing.Transparency = 0.8

local CurrentTarget = nil

-- ==============================================================================
--[ BAZA DANYCH BRONI AR2 (AUTOMATYCZNA KALIBRACJA) ]
-- ==============================================================================
local WeaponData = {
    -- SNIPER RIFLES (Bardzo szybkie, mały opad)
    ["L96A1"] = {Speed = 4000, Gravity = 150},
    ["M24"] = {Speed = 3800, Gravity = 160},
    ["PSG-1"] = {Speed = 3700, Gravity = 170},
    ["M14"] = {Speed = 3200, Gravity = 180},
    ["Model 70"] = {Speed = 3500, Gravity = 160},
    
    -- ASSAULT RIFLES / BATTLE RIFLES (Szybkie)
    ["AK-47"] = {Speed = 2600, Gravity = 196},
    ["AK-74"] = {Speed = 2800, Gravity = 196},
    ["M4A1"] = {Speed = 2900, Gravity = 196},
    ["HK416"] = {Speed = 3000, Gravity = 196},
    ["FAL"] = {Speed = 3100, Gravity = 190},
    ["G3"] = {Speed = 3100, Gravity = 190},
    ["Aug"] = {Speed = 2900, Gravity = 196},
    
    -- SMG / PISTOLS (Wolne, duży opad)
    ["MP5"] = {Speed = 2000, Gravity = 220},
    ["MP7"] = {Speed = 2100, Gravity = 210},
    ["UZI"] = {Speed = 1800, Gravity = 240},
    ["MAC-10"] = {Speed = 1700, Gravity = 250},
    ["Glock 17"] = {Speed = 1500, Gravity = 250},
    ["M1911"] = {Speed = 1400, Gravity = 260},
}

-- Domyślne wartości dla kategorii, jeśli broni nie ma na liście
local CategoryDefaults = {
    ["Rifle"] = {Speed = 2800, Gravity = 196},
    ["Sniper"] = {Speed = 3800, Gravity = 160},
    ["SMG"] = {Speed = 2000, Gravity = 220},
    ["Pistol"] = {Speed = 1500, Gravity = 250}
}

local function UpdateWeaponCalibration()
    if not Config.Combat.AutoCalibration then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        local stats = WeaponData[tool.Name]
        if stats then
            Config.Combat.BulletSpeed = stats.Speed
            Config.Combat.BulletGravity = stats.Gravity
        else
            -- Próba zgadnięcia po nazwie jeśli nie ma w bazie
            local name = tool.Name:lower()
            if name:find("ak") or name:find("m4") or name:find("hk") or name:find("ar") then
                Config.Combat.BulletSpeed = 2700; Config.Combat.BulletGravity = 196
            elseif name:find("sniper") or name:find("l9") or name:find("m24") or name:find("rifle") then
                Config.Combat.BulletSpeed = 3500; Config.Combat.BulletGravity = 160
            elseif name:find("smg") or name:find("mp") or name:find("uzi") then
                Config.Combat.BulletSpeed = 2000; Config.Combat.BulletGravity = 220
            end
        end
    end
end

-- ==============================================================================
--[ LOGIKA CELOWANIA ]
-- ==============================================================================
local function IsAlive(player)
    if Config.Combat.TeamCheck and player.Team ~= nil and player.Team == LocalPlayer.Team then return false end
    return player and player.Character 
        and player.Character:FindFirstChild("HumanoidRootPart")
        and player.Character:FindFirstChild("Humanoid")
        and player.Character.Humanoid.Health > 0
end

local function IsVisible(part)
    if not Config.Combat.WallCheck then return true end
    local ray = Camera:ViewportPointToRay(Camera:WorldToViewportPoint(part.Position).X, Camera:WorldToViewportPoint(part.Position).Y)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * Config.Combat.MaxDistance, params)
    return result and result.Instance:IsDescendantOf(part.Parent)
end

local function GetClosest()
    local target = nil
    local dist = Config.Combat.FOV
    local mouse = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) then
            local part = player.Character:FindFirstChild(Config.Combat.AimPart)
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen and IsVisible(part) then
                    local mag = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                    if mag < dist then
                        target = player
                        dist = mag
                    end
                end
            end
        end
    end
    return target
end

UserInputService.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then Config.State.Aiming = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then Config.State.Aiming = false end
end)

RunService.RenderStepped:Connect(function()
    if Config.State.Unloaded then FOVRing:Remove() return end

    -- Automatyczna kalibracja co klatkę (lub przy zmianie broni)
    UpdateWeaponCalibration()

    FOVRing.Visible = Config.Combat.ShowFOV and Config.Combat.AimAssist
    FOVRing.Radius = Config.Combat.FOV
    FOVRing.Position = UserInputService:GetMouseLocation()
    FOVRing.Color = Config.Colors.Main

    if Config.State.Aiming and Config.Combat.AimAssist then
        if not CurrentTarget or not IsAlive(CurrentTarget) then CurrentTarget = GetClosest() end
        
        if CurrentTarget and IsAlive(CurrentTarget) then
            local part = CurrentTarget.Character:FindFirstChild(Config.Combat.AimPart)
            local root = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
            
            if part and root then
                local aimPosition = part.Position

                -- ZAAWANSOWANA FIZYKA POCISKU (AR2)
                if Config.Combat.AdvancedPrediction then
                    local distance = (Camera.CFrame.Position - part.Position).Magnitude
                    local targetVelocity = root.AssemblyLinearVelocity or Vector3.new(0,0,0)
                    
                    -- Obliczanie parametrów na podstawie aktualnie skalibrowanej broni
                    local timeToTarget = distance / math.max(Config.Combat.BulletSpeed, 1)
                    local predictedMovement = targetVelocity * timeToTarget
                    local bulletDrop = 0.5 * Config.Combat.BulletGravity * (timeToTarget ^ 2)
                    
                    aimPosition = aimPosition + predictedMovement + Vector3.new(0, bulletDrop, 0)
                end

                local pos, onScreen = Camera:WorldToViewportPoint(aimPosition)
                
                if onScreen then
                    local mouse = UserInputService:GetMouseLocation()
                    local move = (Vector2.new(pos.X, pos.Y) - mouse)
                    
                    if mousemoverel then
                        mousemoverel(move.X * Config.Combat.Smoothness, move.Y * Config.Combat.Smoothness)
                    else
                        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPosition), Config.Combat.Smoothness)
                    end
                else
                    CurrentTarget = nil
                end
            end
        end
    else
        CurrentTarget = nil
    end
end)

print("[SOLARA] Moduł Aimbot (AUTO-CALIBRATION) załadowany.")
