-- LocalScript: ServerStorage Tools GUI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- RemoteEvent
local REMOTE_NAME = "SpawnSingleToolEvent"
local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = REMOTE_NAME
    remote.Parent = ReplicatedStorage
end

-- Server-side spawn
if RunService:IsServer() then
    remote.OnServerEvent:Connect(function(player, toolName)
        local tool = ServerStorage:FindFirstChild(toolName)
        if tool and tool:IsA("Tool") then
            local clone = tool:Clone()
            clone.Parent = player.Backpack
        end
    end)
    return
end

-- ========= GUI =========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ToolsGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Main Frame
local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.fromScale(0.5,0.5)
frame.Size = UDim2.fromScale(0.3,0.5)
frame.BackgroundColor3 = Color3.fromRGB(40,40,55)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0,15)

local uiStroke = Instance.new("UIStroke", frame)
uiStroke.Thickness = 2
uiStroke.Color = Color3.fromRGB(100,100,180)
uiStroke.Transparency = 0.2

-- Title
local title = Instance.new("TextLabel")
title.Text = "🛠 ServerStorage Tools"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(240,240,255)
title.BackgroundTransparency = 1
title.Size = UDim2.fromScale(1,0.1)
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- ScrollingFrame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.fromScale(0.95,0.85)
scrollFrame.Position = UDim2.fromScale(0.025,0.1)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = frame

local uiList = Instance.new("UIListLayout", scrollFrame)
uiList.Padding = UDim.new(0,5)
uiList.SortOrder = Enum.SortOrder.LayoutOrder

-- Populate Tools
local function updateTools()
    scrollFrame:ClearAllChildren()
    local uiList = Instance.new("UIListLayout", scrollFrame)
    uiList.Padding = UDim.new(0,5)
    uiList.SortOrder = Enum.SortOrder.LayoutOrder

    for _, tool in ipairs(ServerStorage:GetChildren()) do
        if tool:IsA("Tool") then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,0,40)
            btn.BackgroundColor3 = Color3.fromRGB(70,70,120)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Text = tool.Name
            btn.Font = Enum.Font.Gotham
            btn.TextScaled = true
            local corner = Instance.new("UICorner", btn)
            corner.CornerRadius = UDim.new(0,8)
            btn.Parent = scrollFrame

            btn.Activated:Connect(function()
                remote:FireServer(tool.Name)
            end)
        end
    end

    local contentSize = uiList.AbsoluteContentSize
    scrollFrame.CanvasSize = UDim2.new(0,0,0,contentSize.Y + 10)
end

updateTools()

-- Dragging GUI
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.fromOffset(startPos.X + delta.X, startPos.Y + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton2 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        dragInput = input
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        update(input)
    end
end)
