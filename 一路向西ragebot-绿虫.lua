--本源码功能全部由绿虫虫绿自主开发开源
--请自主查看备弹够不够，别没子弹了来说没有效果
--没有添加穿墙请自主寻找大部分掩体遮挡的人
--如果无效请重进试试
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoShootGUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local HitSound = Instance.new("Sound")
HitSound.SoundId = "rbxassetid://4817809188"
HitSound.Volume = 0.5
HitSound.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 210)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 28)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
MainFrame.Parent = ScreenGui

local GlowBorder = Instance.new("Frame")
GlowBorder.Size = UDim2.new(1, 4, 1, 4)
GlowBorder.Position = UDim2.new(0, -2, 0, -2)
GlowBorder.BackgroundColor3 = Color3.fromRGB(30, 150, 255)
GlowBorder.BackgroundTransparency = 0.85
GlowBorder.BorderSizePixel = 0
Instance.new("UICorner", GlowBorder).CornerRadius = UDim.new(0, 12)
GlowBorder.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(16, 16, 38)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "Ragebot"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(80, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextYAlignment = Enum.TextYAlignment.Center
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -26, 0, 4)
CloseBtn.Text = "×"
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
CloseBtn.Parent = TitleBar

local WeaponLabel = Instance.new("TextLabel")
WeaponLabel.Size = UDim2.new(1, -20, 0, 22)
WeaponLabel.Position = UDim2.new(0, 10, 0, 38)
WeaponLabel.Text = "武器: 无"
WeaponLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
WeaponLabel.BackgroundTransparency = 0.4
WeaponLabel.TextColor3 = Color3.fromRGB(170, 190, 230)
WeaponLabel.Font = Enum.Font.GothamBold
WeaponLabel.TextSize = 12
Instance.new("UICorner", WeaponLabel).CornerRadius = UDim.new(0, 6)
WeaponLabel.TextXAlignment = Enum.TextXAlignment.Center
WeaponLabel.Parent = MainFrame

local AmmoLabel = Instance.new("TextLabel")
AmmoLabel.Size = UDim2.new(1, -20, 0, 22)
AmmoLabel.Position = UDim2.new(0, 10, 0, 64)
AmmoLabel.Text = "弹药: 无"
AmmoLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
AmmoLabel.BackgroundTransparency = 0.4
AmmoLabel.TextColor3 = Color3.fromRGB(170, 190, 230)
AmmoLabel.Font = Enum.Font.GothamBold
AmmoLabel.TextSize = 12
Instance.new("UICorner", AmmoLabel).CornerRadius = UDim.new(0, 6)
AmmoLabel.TextXAlignment = Enum.TextXAlignment.Center
AmmoLabel.Parent = MainFrame

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, -20, 0, 22)
TargetLabel.Position = UDim2.new(0, 10, 0, 90)
TargetLabel.Text = "目标: 无"
TargetLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
TargetLabel.BackgroundTransparency = 0.4
TargetLabel.TextColor3 = Color3.fromRGB(170, 190, 230)
TargetLabel.Font = Enum.Font.GothamBold
TargetLabel.TextSize = 12
Instance.new("UICorner", TargetLabel).CornerRadius = UDim.new(0, 6)
TargetLabel.TextXAlignment = Enum.TextXAlignment.Center
TargetLabel.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 118)
StatusLabel.Text = "待命"
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(140, 140, 180)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.Parent = MainFrame

local ActionButton = Instance.new("TextButton")
ActionButton.Size = UDim2.new(0.8, 0, 0, 36)
ActionButton.Position = UDim2.new(0.1, 0, 0, 146)
ActionButton.Text = "启动"
ActionButton.BackgroundColor3 = Color3.fromRGB(0, 170, 90)
ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionButton.Font = Enum.Font.GothamBold
ActionButton.TextSize = 14
ActionButton.BorderSizePixel = 0
Instance.new("UICorner", ActionButton).CornerRadius = UDim.new(0, 8)
ActionButton.Parent = MainFrame

local BottomLine = Instance.new("Frame")
BottomLine.Size = UDim2.new(0.5, 0, 0, 1)
BottomLine.Position = UDim2.new(0.25, 0, 1, -10)
BottomLine.BackgroundColor3 = Color3.fromRGB(30, 150, 255)
BottomLine.BackgroundTransparency = 0.5
BottomLine.BorderSizePixel = 0
BottomLine.Parent = MainFrame

local isActive = false
local currentTarget = nil
local targetName = nil
local currentWeaponName = nil
local currentAmmoType = "PistolAmmo"
local shootingCoroutine = nil

local weaponAmmoMap = {
    ["Pistol"] = "PistolAmmo",
    ["Colt.45"] = "PistolAmmo",
    ["Revolver"] = "PistolAmmo",
    ["Rifle"] = "RifleAmmo",
    ["AK47"] = "RifleAmmo",
    ["M4A1"] = "RifleAmmo",
    ["AR15"] = "RifleAmmo",
    ["Shotgun"] = "ShotgunAmmo",
    ["Spas12"] = "ShotgunAmmo",
    ["Sniper"] = "SniperAmmo",
    ["AWP"] = "SniperAmmo",
    ["Mosin"] = "SniperAmmo",
}

local function GetAmmoType(weaponName)
    for key, ammoType in pairs(weaponAmmoMap) do
        if weaponName:find(key) then
            return ammoType
        end
    end
    return "PistolAmmo"
end

local function GetCurrentWeapon()
    local char = LocalPlayer.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then tool = bp:FindFirstChildOfClass("Tool") end
    end
    return tool
end

local function GetAmmo(ammoType)
    local consumables = LocalPlayer:FindFirstChild("Consumables")
    if not consumables then return nil end
    return consumables:FindFirstChild(ammoType)
end

local function CreateBeam(startPos, endPos)
    local distance = (endPos - startPos).Magnitude
    if distance < 1 then return end
    
    local beam = Instance.new("Part")
    beam.Size = Vector3.new(0.2, 0.2, distance)
    beam.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance / 2)
    beam.Anchored = true
    beam.CanCollide = false
    beam.Material = Enum.Material.Neon
    beam.Color = Color3.fromRGB(0, 180, 255)
    beam.Transparency = 0.2
    beam.Parent = Workspace
    
    local attachment0 = Instance.new("Attachment")
    attachment0.Position = Vector3.new(0, 0, distance / 2)
    attachment0.Parent = beam
    
    local attachment1 = Instance.new("Attachment")
    attachment1.Position = Vector3.new(0, 0, -distance / 2)
    attachment1.Parent = beam
    
    local trail = Instance.new("Trail")
    trail.Texture = "rbxassetid://0"
    trail.Color = ColorSequence.new(Color3.fromRGB(0, 180, 255))
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    })
    trail.Lifetime = 0.25
    trail.MinLength = 0
    trail.Attachment0 = attachment0
    trail.Attachment1 = attachment1
    trail.Parent = beam
    
    task.spawn(function()
        task.wait(0.3)
        beam:Destroy()
    end)
end

local function SetupButton(btn)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.3
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0
        }):Play()
    end)
end
SetupButton(ActionButton)

CloseBtn.MouseButton1Click:Connect(function()
    isActive = false
    if shootingCoroutine then
        task.cancel(shootingCoroutine)
        shootingCoroutine = nil
    end
    ScreenGui:Destroy()
end)

local function IsVisible(myChar, targetHead)
    if not myChar then return false end
    local myHead = myChar:FindFirstChild("Head")
    if not myHead then return false end
    
    local direction = targetHead.Position - myHead.Position
    local distance = direction.Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {myChar, targetHead.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    
    local result = Workspace:Raycast(myHead.Position, direction.Unit * distance, raycastParams)
    return result == nil
end

local function FindBestTarget()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local nearest = nil
    local minDist = math.huge
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local targetChar = p.Character
            if targetChar then
                local head = targetChar:FindFirstChild("Head")
                local hum = targetChar:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 then
                    if IsVisible(myChar, head) then
                        local dist = (myRoot.Position - head.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            nearest = p
                        end
                    end
                end
            end
        end
    end
    return nearest
end

local function ShootOnce()
    if not targetName then return false end
    
    local target = Players:FindFirstChild(targetName)
    if not target then return false end
    
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local myHead = myChar:FindFirstChild("Head")
    if not myRoot or not myHead then return false end
    
    local targetChar = target.Character
    if not targetChar then return false end
    
    local targetHead = targetChar:FindFirstChild("Head")
    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar.PrimaryPart or targetHead
    if not targetHead or not targetHum or targetHum.Health <= 0 then return false end
    
    if not IsVisible(myChar, targetHead) then
        StatusLabel.Text = "掩体遮挡"
        return true
    end
    
    local tool = GetCurrentWeapon()
    if not tool then return false end
    
    currentWeaponName = tool.Name
    WeaponLabel.Text = "武器: " .. currentWeaponName
    
    local ammoType = GetAmmoType(currentWeaponName)
    currentAmmoType = ammoType
    AmmoLabel.Text = "弹药: " .. ammoType
    
    local ammo = GetAmmo(ammoType)
    if not ammo then
        StatusLabel.Text = "无弹药"
        return false
    end
    
    local hitPos = targetHead.Position
    local cf = CFrame.lookAt(myHead.Position, hitPos)
    
    local shot = nil
    local bullets = Workspace:FindFirstChild("Bullets")
    if bullets then
        shot = bullets:FindFirstChild("Shot")
    end
    if not shot then shot = targetHead end
    
    local GunScripts = ReplicatedStorage:FindFirstChild("GunScripts")
    if not GunScripts then return false end
    local Events = GunScripts:FindFirstChild("Events")
    if not Events then return false end
    local gunShotEvent = Events:FindFirstChild("GunShot")
    local useAmmoEvent = Events:FindFirstChild("UseAmmo")
    if not gunShotEvent or not useAmmoEvent then return false end
    
    CreateBeam(myHead.Position, targetHead.Position)
    
    local myName = LocalPlayer.Name
    local targetModel = Workspace:FindFirstChild(targetName)
    local toolModel = Workspace:FindFirstChild(myName)
    local toolPart = toolModel and toolModel:FindFirstChild(tool.Name)
    
    local gunArgs = {
        [1] = {
            ["HitPart"] = targetModel and targetModel:FindFirstChild("Head") or targetHead,
            ["EndPoint"] = hitPos,
            ["HitCallback"] = "Bullet",
            ["BulletOwner"] = Players[myName],
            ["Lifetime"] = 1,
            ["Speed"] = 80,
            ["cframe"] = cf,
            ["Tool"] = toolPart or tool,
            ["Normal"] = (myHead.Position - hitPos).Unit,
            ["StartTime"] = tick(),
            ["HitPosition"] = hitPos,
            ["AmmoType"] = ammoType,
            ["Material"] = Enum.Material.SmoothPlastic,
            ["PlayerRootPos"] = myRoot.Position,
            ["HitHum"] = targetModel and targetModel:FindFirstChild("Humanoid") or targetHum,
            ["ToolName"] = tool.Name,
            ["StartPoint"] = cf,
            ["MaxDistance"] = 1000,
            ["Shot"] = shot,
            ["ShotID"] = math.random(100000, 9999999),
            ["FirstFrame"] = true,
            ["GunType"] = "Pistol",
            ["Delay"] = 0.22885417938232422 + math.random() * 0.05,
            ["RootPosition"] = targetRoot.Position
        }
    }
    
    local ammoArgs = {[1] = ammo}
    
    pcall(function()
        gunShotEvent:FireServer(unpack(gunArgs))
    end)
    pcall(function()
        useAmmoEvent:FireServer(unpack(ammoArgs))
    end)
    
    pcall(function()
        HitSound:Play()
    end)
    
    return true
end

local function ShootingLoop()
    while isActive do
        local target = Players:FindFirstChild(targetName)
        if not target then
            StatusLabel.Text = "目标离线"
            task.wait(0.3)
            continue
        end
        
        local targetChar = target.Character
        if not targetChar then
            StatusLabel.Text = "等待目标出生"
            task.wait(0.3)
            continue
        end
        
        local hum = targetChar:FindFirstChildOfClass("Humanoid")
        if not hum then
            StatusLabel.Text = "等待目标"
            task.wait(0.3)
            continue
        end
        
        if hum.Health <= 0 then
            StatusLabel.Text = "目标已死亡，已停止"
            isActive = false
            currentTarget = nil
            targetName = nil
            TargetLabel.Text = "目标: 无"
            ActionButton.Text = "启动"
            ActionButton.BackgroundColor3 = Color3.fromRGB(0, 170, 90)
            shootingCoroutine = nil
            break
        end
        
        local success = ShootOnce()
        if not success then
            StatusLabel.Text = "等待"
        else
            StatusLabel.Text = "杀戮中 " .. targetName
        end
        
        task.wait(0.08)
    end
end

local function StartShooting(target)
    if shootingCoroutine then
        isActive = false
        task.cancel(shootingCoroutine)
        task.wait(0.05)
        shootingCoroutine = nil
    end
    
    isActive = true
    currentTarget = target
    targetName = target.Name
    TargetLabel.Text = "目标: " .. targetName
    ActionButton.Text = "停止"
    ActionButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    StatusLabel.Text = "杀戮中 " .. targetName
    
    shootingCoroutine = task.spawn(ShootingLoop)
end

local function StopShooting()
    isActive = false
    
    if shootingCoroutine then
        task.cancel(shootingCoroutine)
        shootingCoroutine = nil
    end
    
    currentTarget = nil
    targetName = nil
    TargetLabel.Text = "目标: 无"
    StatusLabel.Text = "已停止"
    ActionButton.Text = "启动"
    ActionButton.BackgroundColor3 = Color3.fromRGB(0, 170, 90)
end

ActionButton.MouseButton1Click:Connect(function()
    if isActive then
        StopShooting()
    else
        local target = FindBestTarget()
        if target then
            StartShooting(target)
        else
            StatusLabel.Text = "未找到目标"
            task.wait(1)
            StatusLabel.Text = "待命"
        end
    end
end)

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.5)
        local tool = GetCurrentWeapon()
        if tool then
            currentWeaponName = tool.Name
            WeaponLabel.Text = "武器: " .. currentWeaponName
            local ammoType = GetAmmoType(currentWeaponName)
            currentAmmoType = ammoType
            AmmoLabel.Text = "弹药: " .. ammoType
        else
            WeaponLabel.Text = "武器: 无"
            AmmoLabel.Text = "弹药: 无"
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if isActive then
        StatusLabel.Text = "重生中"
        task.wait(1)
    end
end)

local dragging = false
local dragStart = nil
local frameStart = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        frameStart = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)