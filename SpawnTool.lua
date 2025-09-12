-- LocalScript داخل StarterGui

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Create RemoteEvent if not found
local event = ReplicatedStorage:FindFirstChild("DuplicateToolEvent")
if not event then
	event = Instance.new("RemoteEvent")
	event.Name = "DuplicateToolEvent"
	event.Parent = ReplicatedStorage
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "DuplicateGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,250,0,150)
frame.Position = UDim2.new(0.5,-125,0.5,-75)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)
title.Text = "Duplicate Tool"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0,200,0,50)
button.Position = UDim2.new(0.5,-100,0.5,-25)
button.Text = "Duplicate"
button.BackgroundColor3 = Color3.fromRGB(0,170,255)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Parent = frame

-- Button click
button.MouseButton1Click:Connect(function()
	event:FireServer()
end)
