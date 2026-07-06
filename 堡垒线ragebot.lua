-- 由 Cobalt 捕获数据优化后的动态自瞄/打击脚本

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 优化：动态获取武器实例，不再依赖死 ID
local function GetWeaponInstance(weaponName)
	-- 1. 先尝试在角色模型里找（已装备）
	if LocalPlayer.Character then
		local tool = LocalPlayer.Character:FindFirstChild(weaponName)
		if tool then return tool end
	end
	-- 2. 再尝试在背包里找（未装备）
	local tool = LocalPlayer.Backpack:FindFirstChild(weaponName)
	if tool then return tool end
	
	-- 3. 如果是特殊的 Nil 空间武器，只通过名字匹配，去掉 DebugId 限制
	for _, Object in getnilinstances() do
		if Object.Name == weaponName and Object:IsA("Instance") then
			return Object
		end
	end
	return nil
end

local function IsPlayerAlive(player)
	if not player then return false end
	local character = player.Character
	if not character then return false end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return false end
	return humanoid.Health > 0
end

local function GetNearestEnemy()
	local character = LocalPlayer.Character
	if not character then return nil end
	
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return nil end
	
	local currentPos = rootPart.Position
	local nearestDistance = 500
	local targetData = nil
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if not IsPlayerAlive(player) then continue end
			
			-- 团队检查
			local team1 = LocalPlayer.Team
			local team2 = player.Team
			if team1 and team2 and team1 == team2 then continue end
			
			local targetChar = player.Character
			if not targetChar then continue end
			
			local head = targetChar:FindFirstChild("Head")
			local humanoid = targetChar:FindFirstChild("Humanoid")
			if not head or not humanoid then continue end
			
			local distance = (currentPos - head.Position).Magnitude
			
			if distance < nearestDistance then
				nearestDistance = distance
				targetData = {
					HeadPos = head.Position,
					Part = head,
					Humanoid = humanoid,
					Character = targetChar
				}
			end
		end
	end
	
	return targetData
end

local function FireWeaponEvents()
	local target = GetNearestEnemy()
	if not target then return end
	
	-- 动态获取当前正在使用的狙击枪实例
	local weapon = GetWeaponInstance("Sniper")
	if not weapon then 
		warn("未找到指定的武器: Sniper")
		return 
	end
	
	-- 动态获取远程事件路径
	local network = ReplicatedStorage:FindFirstChild("WeaponsSystem") and ReplicatedStorage.WeaponsSystem:FindFirstChild("Network")
	if not network then return end
	
	local WeaponFired = network:FindFirstChild("WeaponFired")
	local WeaponHit = network:FindFirstChild("WeaponHit")
	if not WeaponFired or not WeaponHit then return end
	
	local character = LocalPlayer.Character
	if not character then return end
	
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	
	-- 计算位置与方向
	local origin = rootPart.Position + Vector3.new(0, 1.5, 0)
	local direction = (target.HeadPos - origin).Unit
	local distance = (origin - target.HeadPos).Magnitude
	
	-- 发射事件
	WeaponFired:FireServer(
		weapon,
		{
			id = 1,
			charge = 0,
			origin = origin,
			dir = direction
		}
	)
	
	-- 击中事件（关键修改点：全部传入动态实例与实时数据）
	WeaponHit:FireServer(
		weapon,
		{
			p = target.HeadPos,
			pid = 1,
			part = target.Part,               -- 传入当前目标的真实 Head 实例
			d = distance,
			maxDist = distance + 1,          -- 适当放宽最大距离校验，防止被拉扯卡掉
			h = target.Humanoid,             -- 传入当前目标的真实 Humanoid 实例
			m = Enum.Material.Plastic,
			n = direction * -1,
			t = workspace:GetServerTimeNow(), -- 使用服务器当前高精度时间，防止时间戳过期被拦截
			sid = 1
		}
	)
end

-- 循环执行
while task.wait(0.3) do
	pcall(function()
		FireWeaponEvents()
	end)
end
