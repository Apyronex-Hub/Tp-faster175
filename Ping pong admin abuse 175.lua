local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "AdminNuko175"
screenGui.ResetOnSpawn = false

-- Border Frame (borde ROJO fijo, sin girar)
local borderFrame = Instance.new("Frame")
borderFrame.Size = UDim2.new(0, 206, 0, 180)
borderFrame.Position = UDim2.new(0.5, -103, 0.5, -90)
borderFrame.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
borderFrame.BorderSizePixel = 0
borderFrame.Active = true
borderFrame.Parent = screenGui

local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0, 17)
borderCorner.Parent = borderFrame

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 174)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -87)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = borderFrame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "Admin-Nuko175"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextStrokeColor3 = Color3.fromRGB(139, 0, 0)
title.TextStrokeTransparency = 0
title.Parent = mainFrame

-- Button factory
local function createButton(name, pos, color)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 160, 0, 35)
	btn.Position = pos
	btn.BackgroundColor3 = color
	btn.Text = name
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 14
	btn.Parent = mainFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn
	return btn
end

local autoBuyBtn = createButton("Auto Buy: OFF", UDim2.new(0.5, -80, 0, 50), Color3.fromRGB(40, 40, 40))
local anchoredBtn = createButton("Anchored: OFF", UDim2.new(0.5, -80, 0, 95), Color3.fromRGB(40, 40, 40))

-- DINERO
local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(1, 0, 0, 30)
moneyLabel.Position = UDim2.new(0, 0, 0, 140)
moneyLabel.Text = "$0"
moneyLabel.Font = Enum.Font.GothamBold
moneyLabel.TextSize = 14
moneyLabel.BackgroundTransparency = 1
moneyLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
moneyLabel.TextXAlignment = Enum.TextXAlignment.Center
moneyLabel.Parent = mainFrame

--- DRAGGING
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local dragging = false
local dragStartPos = nil
local frameStartPos = nil

if isMobile then
	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStartPos = input.Position
			frameStartPos = borderFrame.Position
		end
	end)

	title.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStartPos
			borderFrame.Position = UDim2.new(
				frameStartPos.X.Scale,
				frameStartPos.X.Offset + delta.X,
				frameStartPos.Y.Scale,
				frameStartPos.Y.Offset + delta.Y
			)
		end
	end)

	title.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
else
	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStartPos = input.Position
			frameStartPos = borderFrame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and dragStartPos and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStartPos
			borderFrame.Position = UDim2.new(
				frameStartPos.X.Scale,
				frameStartPos.X.Offset + delta.X,
				frameStartPos.Y.Scale,
				frameStartPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

--- LOGICA
local autoBuyActive = false
local anchored = false

-- Auto Buy
autoBuyBtn.MouseButton1Click:Connect(function()
	autoBuyActive = not autoBuyActive
	autoBuyBtn.Text = autoBuyActive and "Auto Buy: ON" or "Auto Buy: OFF"
	autoBuyBtn.BackgroundColor3 = autoBuyActive and Color3.fromRGB(139, 0, 0) or Color3.fromRGB(40, 40, 40)
end)

RunService.Stepped:Connect(function()
	if autoBuyActive then
		for _, prompt in pairs(workspace:GetDescendants()) do
			if prompt:IsA("ProximityPrompt") then
				prompt.HoldDuration = 0
				prompt:InputHoldBegin()
				prompt:InputHoldEnd()
			end
		end
	end
end)

-- Anchored
anchoredBtn.MouseButton1Click:Connect(function()
	anchored = not anchored
	anchoredBtn.Text = anchored and "Anchored: ON" or "Anchored: OFF"
	anchoredBtn.BackgroundColor3 = anchored and Color3.fromRGB(139, 0, 0) or Color3.fromRGB(40, 40, 40)

	local char = player.Character or player.CharacterAdded:Wait()
	if char then
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = anchored
			end
		end
	end
end)

-- FUNCIÓN PARA OBTENER DINERO REAL
local function updateMoney()
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local cash = leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Brainrot")
		if cash then
			local amount = cash.Value
			moneyLabel.Text = "$" .. amount
		end
	end
end

updateMoney()
task.spawn(function()
	while true do
		task.wait(1)
		updateMoney()
	end
end)

game.StarterGui:SetCore("SendNotification", {
	Title = "Admin-Nuko175",
	Text = "Script listo - Dinero actualizado",
	Duration = 2
})
