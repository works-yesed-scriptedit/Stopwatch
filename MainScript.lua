local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StopwatchGui"
screenGui.ResetOnSpawn = false -- ← これが超重要（リセットしても消えない）
screenGui.Parent = player:WaitForChild("PlayerGui")

-- メインフレーム
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 140)
frame.Position = UDim2.new(0.5, -160, 0.5, -70)
frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 20)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0,170,255)
stroke.Thickness = 2

local gradient = Instance.new("UIGradient", frame)
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(30,30,40)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(15,15,20))
}
gradient.Rotation = 90

-- 時間表示
local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(1, -20, 0.5, 0)
timeLabel.Position = UDim2.new(0, 10, 0, 10)
timeLabel.BackgroundTransparency = 1
timeLabel.TextColor3 = Color3.fromRGB(0,200,255)
timeLabel.TextScaled = true
timeLabel.Font = Enum.Font.GothamBold
timeLabel.Text = "0.000"
timeLabel.Parent = frame

-- ボタン生成関数
local function createButton(text, posX)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.48, 0, 0.35, 0)
	button.Position = UDim2.new(posX, 0, 0.6, 0)
	button.BackgroundColor3 = Color3.fromRGB(35,35,45)
	button.TextColor3 = Color3.new(1,1,1)
	button.Font = Enum.Font.GothamSemibold
	button.TextScaled = true
	button.Text = text
	button.Parent = frame
	
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 15)

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(0,170,255)
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(35,35,45)
		}):Play()
	end)

	return button
end

local toggleButton = createButton("Start", 0.02)
local resetButton = createButton("Reset", 0.5)

-- ストップウォッチ処理（キャラ非依存）
local running = false
local startTime = 0
local elapsed = 0

local function updateDisplay()
	timeLabel.Text = string.format("%.3f", elapsed)
end

local function toggle()
	running = not running
	
	if running then
		startTime = tick()
		toggleButton.Text = "Stop"
		stroke.Color = Color3.fromRGB(0,255,150)
	else
		elapsed = tick() - startTime + elapsed
		updateDisplay()
		toggleButton.Text = "Start"
		stroke.Color = Color3.fromRGB(0,170,255)
	end
end

local function reset()
	running = false
	startTime = 0
	elapsed = 0
	updateDisplay()
	toggleButton.Text = "Start"
	stroke.Color = Color3.fromRGB(0,170,255)
end

RunService.RenderStepped:Connect(function()
	if running then
		local current = tick() - startTime + elapsed
		timeLabel.Text = string.format("%.3f", current)
	end
end)

-- ボタン
toggleButton.MouseButton1Click:Connect(toggle)
resetButton.MouseButton1Click:Connect(reset)

-- キーボード
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.F then
		toggle()
	elseif input.KeyCode == Enum.KeyCode.R then
		reset()
	end
end)
