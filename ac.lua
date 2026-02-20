-- =========================
-- Services
-- =========================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local character
local humanoid
local root

local airJumpUsed = false
local debounce = false
local pushPower = 150 -- Tキー前吹っ飛び強さ

-- =========================
-- キャラ取得
-- =========================
local function setupCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")
	airJumpUsed = false
	
	-- 地面に着いたら空中ジャンプリセット
	humanoid.StateChanged:Connect(function(old, new)
		if new == Enum.HumanoidStateType.Landed then
			airJumpUsed = false
		end
	end)
end

player.CharacterAdded:Connect(setupCharacter)
if player.Character then
	setupCharacter(player.Character)
end

local function getCharacter()
	return player.Character or player.CharacterAdded:Wait()
end

-- =========================
-- 吹っ飛び処理（C / V）
-- =========================
local function launch(forwardPower, upPower, getUpDelay)
	local char = getCharacter()
	local hum = char:WaitForChild("Humanoid")
	local rootPart = char:WaitForChild("HumanoidRootPart")
	
	-- Physicsにする
	hum:ChangeState(Enum.HumanoidStateType.Physics)
	
	-- すぐ前方向へ
	rootPart.AssemblyLinearVelocity =
		rootPart.CFrame.LookVector * forwardPower + Vector3.new(0, 5, 0)
	
	-- 0.5秒後に上方向ブースト
	task.delay(0.5, function()
		if rootPart and rootPart.Parent then
			rootPart.AssemblyLinearVelocity =
				Vector3.new(
					rootPart.AssemblyLinearVelocity.X,
					upPower,
					rootPart.AssemblyLinearVelocity.Z
				)
		end
	end)
	
	-- 指定秒後に起き上がる
	task.delay(getUpDelay, function()
		if hum and hum.Parent then
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end)
end

-- =========================
-- 入力処理
-- =========================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not humanoid then return end
	
	-- 空中ジャンプ（E）
	if input.KeyCode == Enum.KeyCode.E then
		if humanoid:GetState() == Enum.HumanoidStateType.Freefall and not airJumpUsed then
			airJumpUsed = true
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
	
	-- Tキー前吹っ飛び（シンプル版）
	if input.KeyCode == Enum.KeyCode.T then
		if debounce then return end
		debounce = true
		
		local forward = root.CFrame.LookVector
		
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		root.AssemblyLinearVelocity = forward * pushPower
		
		task.wait(1)
		
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		debounce = false
	end
	
	-- 吹っ飛び（C / V）
	if input.KeyCode == Enum.KeyCode.C then
		launch(75, 100, 1)
	elseif input.KeyCode == Enum.KeyCode.V then
		launch(100, 350, 2)
	end
end)
