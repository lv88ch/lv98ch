local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local espEnabled = true
local espObjects = {}

-- 颜色表
local colors = {
    ["Coyote"] = Color3.fromRGB(255, 200, 100),
    ["Deer"] = Color3.fromRGB(150, 200, 100),
    ["Bear"] = Color3.fromRGB(200, 100, 50),
    ["Wolf"] = Color3.fromRGB(200, 180, 180),
    ["Boar"] = Color3.fromRGB(150, 100, 80),
    ["Rabbit"] = Color3.fromRGB(200, 200, 255),
    ["Fox"] = Color3.fromRGB(255, 150, 100),
    ["Lion"] = Color3.fromRGB(255, 200, 50),
    ["Tiger"] = Color3.fromRGB(255, 150, 50),
    ["Elephant"] = Color3.fromRGB(150, 150, 150),
    ["Giraffe"] = Color3.fromRGB(200, 180, 100),
    ["Zebra"] = Color3.fromRGB(200, 200, 200),
    default = Color3.fromRGB(255, 255, 255)
}

local function GetAnimalColor(animalName)
    for key, color in pairs(colors) do
        if animalName:find(key) then
            return color
        end
    end
    return colors.default
end

local function CreateEsp(animal)
    if espObjects[animal] then return end
    
    local head = animal:FindFirstChild("Head")
    local root = animal:FindFirstChild("HumanoidRootPart")
    if not head or not root then return end
    
    -- 名称标签
    local nameLabel = Instance.new("BillboardGui")
    nameLabel.Name = "AnimalESP"
    nameLabel.Size = UDim2.new(0, 200, 0, 30)
    nameLabel.Adornee = head
    nameLabel.AlwaysOnTop = true
    nameLabel.MaxDistance = 500
    nameLabel.Parent = head
    
    local nameText = Instance.new("TextLabel")
    nameText.Size = UDim2.new(1, 0, 1, 0)
    nameText.BackgroundTransparency = 1
    nameText.TextColor3 = GetAnimalColor(animal.Name)
    nameText.TextStrokeTransparency = 0.3
    nameText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameText.Font = Enum.Font.GothamBold
    nameText.TextSize = 14
    nameText.Text = animal.Name
    nameText.TextScaled = true
    nameText.Parent = nameLabel
    
    -- 血条
    local healthBar = Instance.new("BillboardGui")
    healthBar.Name = "AnimalHealth"
    healthBar.Size = UDim2.new(0, 100, 0, 6)
    healthBar.Adornee = root
    healthBar.AlwaysOnTop = true
    healthBar.MaxDistance = 500
    healthBar.Position = UDim2.new(0, -50, 0, 30)
    healthBar.Parent = root
    
    local healthBg = Instance.new("Frame")
    healthBg.Size = UDim2.new(1, 0, 1, 0)
    healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    healthBg.BorderSizePixel = 0
    healthBg.Parent = healthBar
    
    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBg
    
    espObjects[animal] = {
        NameLabel = nameLabel,
        HealthBar = healthBar,
        HealthFill = healthFill
    }
end

local function RemoveEsp(animal)
    if espObjects[animal] then
        if espObjects[animal].NameLabel then
            espObjects[animal].NameLabel:Destroy()
        end
        if espObjects[animal].HealthBar then
            espObjects[animal].HealthBar:Destroy()
        end
        espObjects[animal] = nil
    end
end

local function UpdateHealth(animal)
    local esp = espObjects[animal]
    if not esp then return end
    
    local hum = animal:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    local health = hum.Health
    local maxHealth = hum.MaxHealth
    
    if maxHealth > 0 then
        local percent = math.clamp(health / maxHealth, 0, 1)
        esp.HealthFill.Size = UDim2.new(percent, 0, 1, 0)
        
        if percent > 0.5 then
            esp.HealthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        elseif percent > 0.25 then
            esp.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        else
            esp.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end
end

local function ScanAnimals()
    local animals = Workspace:FindFirstChild("Animals")
    if not animals then return end
    
    -- 移除已不存在的动物
    for animal, _ in pairs(espObjects) do
        if not animal.Parent or not animal:IsDescendantOf(Workspace) then
            RemoveEsp(animal)
        end
    end
    
    -- 为现有动物创建ESP
    for _, animal in pairs(animals:GetChildren()) do
        if animal:IsA("Model") then
            local hum = animal:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                CreateEsp(animal)
                UpdateHealth(animal)
            else
                RemoveEsp(animal)
            end
        end
    end
end

-- 监听动物添加
local function SetupAnimalAdded()
    local animals = Workspace:FindFirstChild("Animals")
    if animals then
        animals.ChildAdded:Connect(function(animal)
            if animal:IsA("Model") then
                task.wait(0.1)
                local hum = animal:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    CreateEsp(animal)
                end
            end
        end)
        
        animals.ChildRemoved:Connect(function(animal)
            RemoveEsp(animal)
        end)
    end
end

-- 更新循环
local function StartUpdateLoop()
    RunService.Heartbeat:Connect(function()
        if not espEnabled then return end
        
        for animal, _ in pairs(espObjects) do
            if animal and animal.Parent then
                UpdateHealth(animal)
            else
                RemoveEsp(animal)
            end
        end
    end)
end

-- 扫描循环
task.spawn(function()
    while true do
        task.wait(1)
        if espEnabled then
            ScanAnimals()
        end
    end
end)

-- 初始化
local animals = Workspace:FindFirstChild("Animals")
if not animals then
    local newAnimals = Instance.new("Folder")
    newAnimals.Name = "Animals"
    newAnimals.Parent = Workspace
end

SetupAnimalAdded()
StartUpdateLoop()

print("✅ 动物透视已启动")
print("⏹ 关闭: _G.AnimalESP = false")
print("▶ 开启: _G.AnimalESP = true")

_G.AnimalESP = true

task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.AnimalESP ~= espEnabled then
            espEnabled = _G.AnimalESP
            if not espEnabled then
                for animal, _ in pairs(espObjects) do
                    RemoveEsp(animal)
                end
            end
            print(espEnabled and "▶ 动物透视已开启" or "⏹ 动物透视已关闭")
        end
    end
end)

ScanAnimals()