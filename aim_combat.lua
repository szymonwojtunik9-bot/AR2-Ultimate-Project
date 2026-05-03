-- ==============================================================================
--[ MODUŁ 3: AIMBOT & COMBAT - ULTIMATE AR2 VERSION ]
-- Dodano całkowite wyłączanie połączeń.
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

-- Baza broni (bez zmian)
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
    local char = LocalPlayer.Character
    if not char then return end
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

local function IsAlive(player)
    if Config.Combat.TeamCheck and player.Team ~= nil and player.Team == LocalPlayer.Team then return false end
    return player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

local function IsVisible(part)
    if not Config.Combat.WallCheck then return true end
    local ray = Camera:ViewportPointToRay(Camera:WorldToViewportPoint(part.Position).X, Camera:WorldToViewportPoint(part.Position).Y)
    local params = RaycastParams.new(); params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}; params.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * Config.Combat.MaxDistance, params)
    return result and result.Instance:IsDescendantOf(part.Parent)
end

local function GetClosest()
    local target = nil; local dist = Config.Combat.FOV; local mouse = UserInputService:GetMouseLocation()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) then
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
        if not CurrentTarget or not IsAlive(CurrentTarget) then CurrentTarget = GetClosest() end
        if CurrentTarget and IsAlive(CurrentTarget) then
            local part, root = CurrentTarget.Character:FindFirstChild(Config.Combat.AimPart), CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
            if part and root then
                local aimP = part.Position
                if Config.Combat.AdvancedPrediction then
                    local d = (Camera.CFrame.Position - part.Position).Magnitude
                    local t = d / math.max(Config.Combat.BulletSpeed, 1)
                    aimP = aimP + (root.AssemblyLinearVelocity * t) + Vector3.new(0, 0.5 * Config.Combat.BulletGravity * (t ^ 2), 0)
                end
                local pos, onScreen = Camera:WorldToViewportPoint(aimP)
                if onScreen then
                    local m = UserInputService:GetMouseLocation(); local move = (Vector2.new(pos.X, pos.Y) - m)
                    if mousemoverel then mousemoverel(move.X * Config.Combat.Smoothness, move.Y * Config.Combat.Smoothness)
                    else Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimP), Config.Combat.Smoothness) end
                else CurrentTarget = nil end
            end
        end
    else CurrentTarget = nil end
end)
table.insert(getgenv().SolarConnections, AimRenderConn)

print("[SOLARA] Moduł Aimbot załadowany.")
