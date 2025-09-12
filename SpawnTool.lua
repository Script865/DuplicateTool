local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer

local event = ReplicatedStorage:WaitForChild("DuplicateToolEvent")

-- إنشاء GUI
local gui = Instance.new("ScreenGui")
gui.Name = "DuplicateGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 300)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local scrolling = Instance.new("ScrollingFrame")
scrolling.Size = UDim2.new(1, -10, 1, -10)
scrolling.Position = UDim2.new(0, 5, 0, 5)
scrolling.CanvasSize = UDim2.new(0,0,0,0)
scrolling.ScrollBarThickness = 6
scrolling.Parent = frame

local uiList = Instance.new("UIListLayout")
uiList.Parent = scrolling
uiList.Padding = UDim.new(0,5)

-- تحديث الأدوات
local function refreshTools()
	scrolling:ClearAllChildren()
	uiList.Parent = scrolling

	for _,tool in ipairs(player.Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(1, -10, 0, 40)
			button.BackgroundColor3 = Color3.fromRGB(70,70,70)
			button.TextColor3 = Color3.fromRGB(255,255,255)
			button.Text = "Duplicate: " .. tool.Name
			button.Parent = scrolling

			button.MouseButton1Click:Connect(function()
				event:FireServer(tool.Name)
			end)
		end
	end
end

-- تحديث عند إضافة/إزالة أدوات
player.Backpack.ChildAdded:Connect(refreshTools)
player.Backpack.ChildRemoved:Connect(refreshTools)

-- تحديث أول مرة
refreshTools()
