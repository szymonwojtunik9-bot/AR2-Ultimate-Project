-- ==============================================================================
--[ MODUŁ 2: ESP & VISUALS - ULTIMATE AR2 VERSION ]
-- Dodano obsługę MinDistance oraz całkowite wyłączanie połączeń.
-- ==============================================================================

repeat task.wait() until getgenv().SolarConfig
local Config = getgenv().SolarConfig

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Cache = { Draw = {}, Chams = {} }

local SkeletonConnections = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

local function IsAlive(player)
    return player and player.Character 
        and player.Character:FindFirstChild("HumanoidRootPart")
        and player.Character:FindFirstChild("Humanoid")
        and player.Character.Humanoid.Health > 0
end

local function CreateDrawing(class, props)
    local d = Drawing.new(class)
    for i, v in pairs(props) do d[i] = v end
    return d
end

local function CreateDrawings(player)
    local d = {
        Box = CreateDrawing("Square", {Thickness = 1, Filled = false, ZIndex = 10, Visible = false}),
        BoxOutline = CreateDrawing("Square", {Thickness = 3, Color = Color3.new(0,0,0), ZIndex = 9, Visible = false}),
        Corners = {},
        HealthBarBG = CreateDrawing("Square", {Thickness = 1, Color = Color3.new(0,0,0), Filled = true, ZIndex = 8, Visible = false}),
        HealthBar = CreateDrawing("Square", {Thickness = 1, Filled = true, ZIndex = 9, Visible = false}),
        Tag = CreateDrawing("Text", {Size = 14, Center = true, Outline = true, Font = 3, ZIndex = 11, Visible = false}),
        WeaponTag = CreateDrawing("Text", {Size = 13, Center = true, Outline = true, Font = 3, ZIndex = 11, Visible = false}),
        OOF_Arrow = CreateDrawing("Triangle", {Thickness = 1, Filled = true, ZIndex = 10, Visible = false}),
        OOF_ArrowOutline = CreateDrawing("Triangle", {Thickness = 3, Color = Color3.new(0,0,0), Filled = false, ZIndex = 9, Visible = false}),
        Skeleton = {}
    }
    for i=1, 8 do table.insert(d.Corners, CreateDrawing("Line", {Thickness = 1.5, ZIndex = 10, Visible = false})) end
    for i=1, #SkeletonConnections do table.insert(d.Skeleton, CreateDrawing("Line", {Thickness = 1, ZIndex = 7, Visible = false})) end
    Cache.Draw[player] = d
end

local function HideDrawings(player)
    if Cache.Draw[player] then
        local d = Cache.Draw[player]
        d.Box.Visible = false; d.BoxOutline.Visible = false
        d.HealthBar.Visible = false; d.HealthBarBG.Visible = false
        d.Tag.Visible = false; d.WeaponTag.Visible = false
        d.OOF_Arrow.Visible = false; d.OOF_ArrowOutline.Visible = false
        for _, l in pairs(d.Corners) do l.Visible = false end
        for _, l in pairs(d.Skeleton) do l.Visible = false end
    end
    if Cache.Chams[player] then Cache.Chams[player].Enabled = false end
end

local function RemoveDrawings(player)
    if Cache.Draw[player] then
        local d = Cache.Draw[player]
        d.Box:Remove(); d.BoxOutline:Remove()
        d.HealthBar:Remove(); d.HealthBarBG:Remove()
        d.Tag:Remove(); d.WeaponTag:Remove()
        d.OOF_Arrow:Remove(); d.OOF_ArrowOutline:Remove()
        for _, l in pairs(d.Corners) do l:Remove() end
        for _, l in pairs(d.Skeleton) do l:Remove() end
        Cache.Draw[player] = nil
    end
    if Cache.Chams[player] then Cache.Chams[player]:Destroy(); Cache.Chams[player] = nil end
end

local ESP_Connection = RunService.RenderStepped:Connect(function()
    if Config.State.Unloaded then
        for p, _ in pairs(Cache.Draw) do RemoveDrawings(p) end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not Cache.Draw[player] then CreateDrawings(player) end
        local d = Cache.Draw[player]

        local success = pcall(function()
            if IsAlive(player) then
                local char = player.Character
                local root = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChild("Humanoid")
                
                if not root or not head or not hum then HideDrawings(player) return end
                
                local dist = (Camera.CFrame.Position - root.Position).Magnitude
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                -- Dodano sprawdzanie MinDistance i MaxDistance
                if dist >= Config.Visuals.MinDistance and dist <= Config.Visuals.MaxDistance then
                    local color = (Config.Combat.TeamCheck and player.Team == LocalPlayer.Team) and Color3.new(0,1,0) or Config.Colors.Enemy
                    
                    if onScreen then
                        d.OOF_Arrow.Visible = false; d.OOF_ArrowOutline.Visible = false
                        local hPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.8, 0))
                        local lPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                        local height = math.abs(hPos.Y - lPos.Y)
                        local width = height * 0.6
                        local boxPos = Vector2.new(pos.X - width/2, hPos.Y)
                        local boxSize = Vector2.new(width, height)

                        local showBox = Config.Visuals.BoxESP and not Config.Visuals.CornerBox
                        d.Box.Visible = showBox; d.BoxOutline.Visible = showBox
                        if showBox then d.Box.Position = boxPos; d.Box.Size = boxSize; d.Box.Color = color; d.BoxOutline.Position = boxPos; d.BoxOutline.Size = boxSize end

                        for i, l in pairs(d.Corners) do l.Visible = Config.Visuals.CornerBox; l.Color = color end
                        if Config.Visuals.CornerBox then
                            local cL = width / 4
                            d.Corners[1].From = boxPos; d.Corners[1].To = boxPos + Vector2.new(cL, 0)
                            d.Corners[2].From = boxPos; d.Corners[2].To = boxPos + Vector2.new(0, cL)
                            d.Corners[3].From = boxPos + Vector2.new(width, 0); d.Corners[3].To = boxPos + Vector2.new(width - cL, 0)
                            d.Corners[4].From = boxPos + Vector2.new(width, 0); d.Corners[4].To = boxPos + Vector2.new(width, cL)
                            d.Corners[5].From = boxPos + Vector2.new(0, height); d.Corners[5].To = boxPos + Vector2.new(cL, height)
                            d.Corners[6].From = boxPos + Vector2.new(0, height); d.Corners[6].To = boxPos + Vector2.new(0, height - cL)
                            d.Corners[7].From = boxPos + Vector2.new(width, height); d.Corners[7].To = boxPos + Vector2.new(width - cL, height)
                            d.Corners[8].From = boxPos + Vector2.new(width, height); d.Corners[8].To = boxPos + Vector2.new(width, height - cL)
                        end

                        d.HealthBar.Visible = Config.Visuals.HealthBar; d.HealthBarBG.Visible = Config.Visuals.HealthBar
                        if Config.Visuals.HealthBar then
                            local barH = height * (math.clamp(hum.Health / hum.MaxHealth, 0, 1))
                            local barP = boxPos - Vector2.new(6, 0)
                            d.HealthBarBG.Position = barP; d.HealthBarBG.Size = Vector2.new(3, height)
                            d.HealthBar.Position = barP + Vector2.new(0, height - barH); d.HealthBar.Size = Vector2.new(3, barH)
                            d.HealthBar.Color = Color3.fromHSV(math.clamp(hum.Health/hum.MaxHealth, 0, 1) * 0.3, 1, 1)
                        end

                        for i, l in pairs(d.Skeleton) do
                            l.Visible = Config.Visuals.Skeleton
                            if Config.Visuals.Skeleton then
                                local c = SkeletonConnections[i]
                                local p1, p2 = char:FindFirstChild(c[1]), char:FindFirstChild(c[2])
                                if p1 and p2 then
                                    local pos1, vis1 = Camera:WorldToViewportPoint(p1.Position)
                                    local pos2, vis2 = Camera:WorldToViewportPoint(p2.Position)
                                    if vis1 and vis2 then l.From = Vector2.new(pos1.X, pos1.Y); l.To = Vector2.new(pos2.X, pos2.Y); l.Color = Color3.new(1,1,1) else l.Visible = false end
                                else l.Visible = false end
                            end
                        end

                        d.Tag.Visible = Config.Visuals.NameTags
                        if Config.Visuals.NameTags then d.Tag.Text = string.format("%s\n[%dm]", player.Name, math.floor(dist)); d.Tag.Position = Vector2.new(pos.X, boxPos.Y - 30); d.Tag.Color = Color3.new(1,1,1) end

                        if Config.Visuals.WeaponESP then
                            local w = char:FindFirstChildOfClass("Tool")
                            if w then d.WeaponTag.Visible = true; d.WeaponTag.Text = w.Name; d.WeaponTag.Position = Vector2.new(pos.X, boxPos.Y + height + 2); d.WeaponTag.Color = Color3.fromRGB(200, 200, 200) else d.WeaponTag.Visible = false end
                        else d.WeaponTag.Visible = false end

                        if Config.Visuals.Chams then
                            if not Cache.Chams[player] then local h = Instance.new("Highlight", game:GetService("CoreGui")); h.Adornee = char; h.OutlineColor = Color3.new(1,1,1); Cache.Chams[player] = h end
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
            else HideDrawings(player) end
        end)
        if not success then HideDrawings(player) end
    end
end)
table.insert(getgenv().SolarConnections, ESP_Connection)

local PlayerRemovingConn = Players.PlayerRemoving:Connect(RemoveDrawings)
table.insert(getgenv().SolarConnections, PlayerRemovingConn)

print("[SOLARA] Moduł ESP załadowany.")
