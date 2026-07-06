local function GetNil(Name, DebugId)
	for _, Object in getnilinstances() do
		if Object.Name == Name and Object:GetDebugId() == DebugId then
			return Object
		end
	end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")


local function GetCurrentTool()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            return child
        end
    end
    return nil
end


local function GetToolStats(tool)
    if not tool then return nil, nil end
    
    local ammoCapacity = tool:FindFirstChild("AmmoCapacity")
    local fireDelay = tool:FindFirstChild("FireDelay")
    
    local ammoValue = ammoCapacity and ammoCapacity.Value or 5
    local fireValue = 0.001
    
    return ammoValue, fireValue
end


local function GetToolParts(tool)
    if not tool then return nil, nil, nil end
    
    local hold = tool:FindFirstChild("Hold")
    local sounds = hold and hold:FindFirstChild("Sounds")
    local meleeTrail = hold and hold:FindFirstChild("MeleeTrail")
    
    return hold, sounds, meleeTrail
end


local function IsPlayerAlive(player)
    if not player then return false end
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0
end


local function HasCover(startPos, endPos)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character, workspace.CurrentCamera}
    params.IgnoreWater = true
    
    local direction = (endPos - startPos)
    local distance = direction.Magnitude
    local rayResult = Workspace:Raycast(startPos, direction, params)
    
    if rayResult then
        local hit = rayResult.Instance
        local hitParent = hit and hit.Parent
        if hitParent then
            local humanoid = hitParent:FindFirstChild("Humanoid")
            if humanoid then
                return false
            end
            local head = hitParent:FindFirstChild("Head")
            if head then
                return false
            end
        end
        if distance > 10 and rayResult.Distance < distance - 2 then
            return true
        end
        return false
    end
    return false
end


local targetData = {}

local function GetBestEnemy()
    local character = LocalPlayer.Character
    if not character then return nil, nil, nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil, nil, nil end
    
    local currentPos = rootPart.Position
    local bestTarget = nil
    local bestDistance = 150
    local bestPos = nil
    local bestVelocity = nil
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not IsPlayerAlive(player) then
                continue
            end
            
            local team1 = LocalPlayer.Team
            local team2 = player.Team
            if team1 and team2 and team1 == team2 then
                continue
            end
            
            local targetChar = player.Character
            if not targetChar then continue end
            
            local head = targetChar:FindFirstChild("Head")
            if not head then continue end
            
            local distance = (currentPos - head.Position).Magnitude
            if distance > 150 then
                continue
            end
            
            if HasCover(currentPos, head.Position) then
                continue
            end
            
            if distance < bestDistance then
                bestDistance = distance
                bestTarget = player
                bestPos = head.Position
                bestVelocity = head.Velocity
            end
        end
    end
    
    return bestTarget, bestPos, bestDistance, bestVelocity
end

local function GetTargetPositions()
    local target, targetPos, distance, velocity = GetBestEnemy()
    
    if target and targetPos then
        local predictTime = distance / 2000
        local predictedPos = targetPos + (velocity * predictTime)
        return predictedPos, predictedPos + Vector3.new(0, 0.3, 0), true
    end
    
    return nil, nil, false
end


local function CreateBulletTrail(startPos, endPos)
    local trail = Instance.new("Part")
    trail.Name = "BulletTrail"
    trail.Anchored = true
    trail.CanCollide = false
    trail.CanQuery = false
    trail.CanTouch = false
    trail.Material = Enum.Material.Neon
    trail.Size = Vector3.new(0.3, 0.3, (startPos - endPos).Magnitude)
    trail.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -(startPos - endPos).Magnitude / 2)
    trail.BrickColor = BrickColor.new("Bright blue")
    trail.Transparency = 0.2
    
    local attachment1 = Instance.new("Attachment")
    attachment1.Parent = trail
    attachment1.Position = Vector3.new(0, 0, trail.Size.Z / 2)
    
    local attachment2 = Instance.new("Attachment")
    attachment2.Parent = trail
    attachment2.Position = Vector3.new(0, 0, -trail.Size.Z / 2)
    
    local beam = Instance.new("Beam")
    beam.Parent = trail
    beam.Attachment0 = attachment1
    beam.Attachment1 = attachment2
    beam.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 200, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 100, 255))
    })
    beam.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.1),
        NumberSequenceKeypoint.new(1, 0.3)
    })
    beam.Width0 = 0.8
    beam.Width1 = 0.8
    beam.LightEmission = 1
    beam.LightInfluence = 1
    
    trail.Parent = workspace.CurrentCamera
    
    local glow = Instance.new("Part")
    glow.Name = "Glow"
    glow.Anchored = true
    glow.CanCollide = false
    glow.CanQuery = false
    glow.CanTouch = false
    glow.Material = Enum.Material.Neon
    glow.Size = Vector3.new(2, 2, 2)
    glow.CFrame = CFrame.new((startPos + endPos) / 2)
    glow.BrickColor = BrickColor.new("Bright blue")
    glow.Transparency = 0.5
    glow.Parent = trail
    
    game:GetService("Debris"):AddItem(trail, 0.3)
    game:GetService("Debris"):AddItem(glow, 0.3)
    
    spawn(function()
        for i = 1, 10 do
            trail.Transparency = trail.Transparency + 0.08
            glow.Transparency = glow.Transparency + 0.08
            trail.Size = trail.Size * 0.95
            wait(0.03)
        end
        trail:Destroy()
    end)
end


local function RainbowCharacter()
    local character = LocalPlayer.Character
    if not character then return end
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.Neon
            part.Transparency = 0.3
        end
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        humanoid.AutoRotate = true
    end
    
    spawn(function()
        local hue = 0
        while character and character.Parent do
            hue = (hue + 0.01) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.BrickColor = BrickColor.new(color)
                end
            end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.BrickColor = BrickColor.new(Color3.fromHSV((hue + 0.5) % 1, 1, 1))
            end
            
            wait(0.05)
        end
    end)
end


local function FireShootEvent()
    local Event = game:GetService("ReplicatedStorage").ServerEvents.Shoot
    if not Event then return end
    
    local tool = GetCurrentTool()
    if not tool then
        return
    end
    
    local pos1, pos2, hasTarget = GetTargetPositions()
    
    if not hasTarget then
        return
    end
    
    if not IsPlayerAlive(LocalPlayer) then
        return
    end
    
    if not LocalPlayer.Character then
        return
    end
    
    local hold, sounds, meleeTrail = GetToolParts(tool)
    if not hold then
        return
    end
    
    local ammoCapacity, fireDelay = GetToolStats(tool)
    
    local camera = workspace.CurrentCamera
    if camera then
        local origin = camera.CFrame.Position
        CreateBulletTrail(origin, pos1)
    end
    
    Event:FireServer(
        {
            currentShots = 1,
            LoadedAnimations = true,
            hapticLeftTrigger = false,
            animationList = {
                boltCycleAnimation = GetNil("boltCycle", "0_2701986"),
                runAnimation = GetNil("run", "0_2701989"),
                aimAnimation = GetNil("aim", "0_2701983"),
                aimFireAnimation = GetNil("aimFire", "0_2701985"),
                meleeAnimation = GetNil("melee", "0_2701988"),
                hipFireAnimation = GetNil("hipFire", "0_2701987"),
                reloadAnimation = GetNil("reload", "0_2701984"),
                equipAnimation = GetNil("equip", "0_2701982")
            },
            Sounds = sounds,
            Character = LocalPlayer.Character,
            clientCanFire = true,
            handleAction = function(arg1, arg2, arg3)
                return
            end,
            LoadedEvents = true,
            Tool = tool,
            hapticRightTrigger = false,
            actionBinds = {
                Shoot = {
                    true,
                    Enum.UserInputType.MouseButton1,
                    Enum.KeyCode.ButtonR2
                },
                Melee = {
                    true,
                    Enum.UserInputType.MouseButton3,
                    Enum.KeyCode.V,
                    Enum.KeyCode.ButtonB
                },
                Aim = {
                    true,
                    Enum.UserInputType.MouseButton2,
                    Enum.KeyCode.Q,
                    Enum.KeyCode.ButtonL2
                },
                Perspective = {
                    true,
                    Enum.KeyCode.E,
                    Enum.KeyCode.ButtonR3
                },
                Reload = {
                    true,
                    Enum.KeyCode.R,
                    Enum.KeyCode.ButtonX
                }
            },
            isVibrationSupported = true,
            meleeTrail = meleeTrail,
            Player = LocalPlayer,
            hapticLeftHand = false,
            RecoilPattern = {
                {
                    ammoCapacity,
                    fireDelay,
                    -1,
                    0,
                    -0
                },
                {
                    ammoCapacity,
                    fireDelay,
                    -1,
                    0,
                    0
                },
                {
                    ammoCapacity,
                    fireDelay,
                    0,
                    0
                }
            },
            Cycle = true,
            resetBool = {
                meleeHoldRepeat = false,
                shootHoldRepeat = false
            },
            hapticLarge = true,
            Camera = workspace.Camera,
            lastClick = tick(),
            hapticRightHand = false,
            hapticSmall = true
        },
        pos1,
        true,
        1,
        {},
        pos2
    )
end

spawn(function()
    RainbowCharacter()
end)

while wait(0.05) do
    pcall(function()
        FireShootEvent()
    end)
end