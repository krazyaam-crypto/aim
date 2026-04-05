local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- STATE
local AIMBOT_ENABLED = false
local HOLD = false
local currentTarget = nil

-- UI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,200,0,200)
frame.Position = UDim2.new(0.05,0,0.4,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

-- 🌈 RAINBOW BORDER
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 3

task.spawn(function()
	while true do
		for i = 0,1,0.01 do
			stroke.Color = Color3.fromHSV(i,1,1)
			task.wait()
		end
	end
end)

-- 🏷️ TITLE
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0.2,0)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "KienDepTrai"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- BUTTON
local function makeBtn(text, pos)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0.9,0,0.2,0)
	b.Position = pos
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(40,40,40)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	Instance.new("UICorner", b)
	return b
end

local aimBtn = makeBtn("AIMBOT: OFF", UDim2.new(0.05,0,0.22,0))
local switchBtn = makeBtn("NEXT TARGET", UDim2.new(0.05,0,0.45,0))

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(0.9,0,0.2,0)
label.Position = UDim2.new(0.05,0,0.7,0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1,1,1)
label.Text = "Target: None"
label.Font = Enum.Font.GothamBold
label.TextScaled = true

-- HOLD CHUỘT PHẢI
UIS.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton2 then
		HOLD = true
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton2 then
		HOLD = false
	end
end)

-- NEAREST
local function getNearest()
	local nearest = nil
	local dist = math.huge
	
	for _,v in pairs(Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			local d = (player.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
			if d < dist then
				dist = d
				nearest = v
			end
		end
	end
	
	return nearest
end

-- NEXT TARGET (GẦN → XA)
local function getNextTarget()
	local list = {}

	for _,v in pairs(Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (player.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
			table.insert(list, {player = v, distance = dist})
		end
	end

	table.sort(list, function(a,b)
		return a.distance < b.distance
	end)

	if #list == 0 then return nil end

	if not currentTarget then
		return list[1].player
	end

	for i,v in pairs(list) do
		if v.player == currentTarget then
			return list[i+1] and list[i+1].player or list[1].player
		end
	end

	return list[1].player
end

-- LOOP AIM
RunService.RenderStepped:Connect(function()
	if AIMBOT_ENABLED and currentTarget and HOLD then
		local char = currentTarget.Character
		if char and char:FindFirstChild("Head") then
			local targetCF = CFrame.new(camera.CFrame.Position, char.Head.Position)
			camera.CFrame = camera.CFrame:Lerp(targetCF, 0.15)
		end
	end

	if currentTarget then
		label.Text = "Target: "..currentTarget.Name
	else
		label.Text = "Target: None"
	end
end)

-- BUTTONS
aimBtn.MouseButton1Click:Connect(function()
	AIMBOT_ENABLED = not AIMBOT_ENABLED
	aimBtn.Text = "AIMBOT: "..(AIMBOT_ENABLED and "ON" or "OFF")
	
	if AIMBOT_ENABLED then
		currentTarget = getNearest()
	end
end)

switchBtn.MouseButton1Click:Connect(function()
	currentTarget = getNextTarget()
end)
