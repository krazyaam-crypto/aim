local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- // STATE // --
local AIMBOT_ENABLED = false
local ESP_ENABLED = false
local TARGET_PART_NAME = "Head"
local espFolder = Instance.new("Folder", game.CoreGui)
espFolder.Name = "Omni_ESP_System"

-- // UI CONSTRUCTION // --
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "CombatSuite_Omni"
screenGui.ResetOnSpawn = false

-- Credit Pop-up (Omni_mark2015)
local creditFrame = Instance.new("Frame", screenGui)
creditFrame.Size = UDim2.new(0, 150, 0, 30)
creditFrame.Position = UDim2.new(1, 20, 0.9, 0)
creditFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", creditFrame)

local creditLabel = Instance.new("TextLabel", creditFrame)
creditLabel.Size = UDim2.new(1, 0, 1, 0)
creditLabel.Text = "Made by Omni_mark2015"
creditLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
creditLabel.Font = Enum.Font.GothamBold
creditLabel.TextSize = 10
creditLabel.BackgroundTransparency = 1

creditFrame:TweenPosition(UDim2.new(1, -160, 0.9, 0), "Out", "Quad", 1)

-- Main Menu
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 180, 0, 130)
mainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(255, 50, 50)
stroke.Thickness = 2

local function createBtn(text, pos, color)
	local btn = Instance.new("TextButton", mainFrame)
	btn.Size = UDim2.new(0.9, 0, 0.3, 0)
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.Text = text .. ": OFF"
	btn.TextColor3 = color
	btn.Font = Enum.Font.GothamBold
	Instance.new("UICorner", btn)
	return btn
end

local aimBtn = createBtn("AIMBOT", UDim2.new(0.05, 0, 0.25, 0), Color3.fromRGB(255, 100, 100))
local espBtn = createBtn("ESP", UDim2.new(0.05, 0, 0.6, 0), Color3.fromRGB(100, 200, 255))

-- // TARGETING // --
local function getClosestNPC()
	local closest = nil
	local shortestDist = math.huge
	
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild(TARGET_PART_NAME) then
			if not Players:GetPlayerFromCharacter(v) and v.Humanoid.Health > 0 then
				local part = v[TARGET_PART_NAME]
				local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
				
				if onScreen then
					local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
					if dist < shortestDist then
						closest = part
						shortestDist = dist
					end
				end
			end
		end
	end
	return closest
end

-- // LOOPS // --

RunService.RenderStepped:Connect(function()
	if AIMBOT_ENABLED then
		local targetPart = getClosestNPC()
		if targetPart then
			camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
		end
	end
end)

task.spawn(function()
	while task.wait(0.3) do
		espFolder:ClearAllChildren()
		if ESP_ENABLED then
			for _, v in pairs(workspace:GetDescendants()) do
				if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("Head") then
					if not Players:GetPlayerFromCharacter(v) and v.Humanoid.Health > 0 then
						local hl = Instance.new("Highlight", espFolder)
						hl.Adornee = v
						hl.FillColor = Color3.fromRGB(255, 50, 50)
						
						local bb = Instance.new("BillboardGui", espFolder)
						bb.Adornee = v.Head
						bb.Size = UDim2.new(0, 100, 0, 40)
						bb.AlwaysOnTop = true
						
						local tl = Instance.new("TextLabel", bb)
						tl.Size = UDim2.new(1, 0, 1, 0)
						tl.BackgroundTransparency = 1
						tl.TextColor3 = Color3.new(1, 1, 1)
						tl.Font = Enum.Font.GothamBold
						tl.TextSize = 11
						
						local dist = math.floor((camera.CFrame.Position - v.Head.Position).Magnitude)
						tl.Text = v.Name .. " [" .. dist .. "m]\nHP: " .. math.floor(v.Humanoid.Health) .. "%"
					end
				end
			end
		end
	end
end)

-- // BUTTONS // --
aimBtn.MouseButton1Click:Connect(function()
	AIMBOT_ENABLED = not AIMBOT_ENABLED
	aimBtn.Text = "AIMBOT: " .. (AIMBOT_ENABLED and "ON" or "OFF")
	aimBtn.BackgroundColor3 = AIMBOT_ENABLED and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(30, 30, 30)
	stroke.Color = AIMBOT_ENABLED and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(255, 50, 50)
end)

espBtn.MouseButton1Click:Connect(function()
	ESP_ENABLED = not ESP_ENABLED
	espBtn.Text = "ESP: " .. (ESP_ENABLED and "ON" or "OFF")
	espBtn.BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(30, 30, 30)
end)
