local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- STATE
local AIMBOT_ENABLED = false
local currentTarget = nil

-- UI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,200,0,150)
frame.Position = UDim2.new(0.05,0,0.4,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local function makeBtn(text, pos)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0.9,0,0.25,0)
	b.Position = pos
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(40,40,40)
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", b)
	return b
end

local aimBtn = makeBtn("AIMBOT: OFF", UDim2.new(0.05,0,0.1,0))
local switchBtn = makeBtn("NEXT TARGET", UDim2.new(0.05,0,0.4,0))

-- GET PLAYERS
local function getPlayers()
	local t = {}
	for _,v in pairs(Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
			table.insert(t, v)
		end
	end
	return t
end

-- GET NEAREST
local function getNearest()
	local nearest = nil
	local dist = math.huge
	
	for _,v in pairs(getPlayers()) do
		local char = v.Character
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local d = (player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
			if d < dist then
				dist = d
				nearest = v
			end
		end
	end
	
	return nearest
end

-- SWITCH TARGET
local function getNextTarget()
	local list = getPlayers()
	if #list == 0 then return nil end
	
	if not currentTarget then
		return list[1]
	end
	
	for i,v in pairs(list) do
		if v == currentTarget then
			return list[i+1] or list[1]
		end
	end
	
	return list[1]
end

-- LOOP
RunService.RenderStepped:Connect(function()
	if AIMBOT_ENABLED and currentTarget then
		local char = currentTarget.Character
		if char and char:FindFirstChild("Head") then
			camera.CFrame = CFrame.new(camera.CFrame.Position, char.Head.Position)
		end
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
