-- LocalScript: ServerStorage Tools GUI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") -- ضمان وجود PlayerGui

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
        local function findToolRecursive(parent, name)
            for _, obj in ipairs(parent:GetChildren()) do
                if obj:IsA("Tool") and obj.Name == name then
                    return obj
                end
                local found = findToolRecursive(obj, name)
                if found then return found end
            end
            return nil
        end

        local tool = findToolRecursive(ServerStorage, toolName)
        if tool then
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
screenGui.Parent = playerGui -- وضعه بعد التأكد من PlayerGui

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
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = frame

-- UIListLayout ثابت
local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0,5)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Parent = scrollFrame

-- Recursive function to find all Tools
local function getAllTools(parent)
    local tools = {}
    for _, obj in ipairs(parent:GetChildren()) do
        if obj:IsA("Tool") then
            table.insert(tools, obj)
        elseif #obj:GetChildren() > 0 then
            local subTools = getAllTools(obj)
            for _, t in ipairs(subTools) do
                table.insert(tools, t)
            end
        end
    end
    return tools
end

-- Populate Tools
local function updateTools()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local tools = getAllTools(ServerStorage)
    for _, tool in ipairs(tools) do
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

    scrollFrame.CanvasSize = UDim2.new(0,0,0,uiList.AbsoluteContentSize.Y + 10)
end

-- تحديث Tools بعد PlayerGui جاهز
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
