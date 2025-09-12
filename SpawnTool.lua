-- LocalScript: Inventory Tool Duplicator with Draggable GUI
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryDuplicatorGUI"
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
frame.Active = true -- مهم عشان Drag
frame.Parent = screenGui

local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0,15)

local uiStroke = Instance.new("UIStroke", frame)
uiStroke.Thickness = 2
uiStroke.Color = Color3.fromRGB(100,100,180)
uiStroke.Transparency = 0.2

-- Title
local title = Instance.new("TextLabel")
title.Text = "🛠 Inventory Tools"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(240,240,255)
title.BackgroundTransparency = 1
title.Size = UDim2.fromScale(1,0.1)
title.Font = Enum.Font.GothamBold
title.ZIndex = 2
title.Parent = frame

-- ScrollingFrame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.fromScale(0.95,0.85)
scrollFrame.Position = UDim2.fromScale(0.025,0.1)
scrollFrame.BackgroundTransparency = 0.1
scrollFrame.BackgroundColor3 = Color3.fromRGB(60,60,80)
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = frame
scrollFrame.ZIndex = 1

-- UIListLayout
local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0,5)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Parent = scrollFrame

-- دالة تجيب كل Tools من Inventory
local function getInventoryTools()
    local tools = {}
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(tools, tool)
            end
        end
    end
    local character = player.Character
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(tools, tool)
            end
        end
    end
    return tools
end

-- Populate Tools مع Duplicate مباشر للInventory
local function updateTools()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local tools = getInventoryTools()
    for _, tool in ipairs(tools) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,40)
        btn.BackgroundColor3 = Color3.fromRGB(100,100,160)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Text = tool.Name
        btn.Font = Enum.Font.Gotham
        btn.TextScaled = true
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0,8)
        btn.Parent = scrollFrame
        btn.ZIndex = 3

        btn.Activated:Connect(function()
            local clone = tool:Clone()
            clone.Parent = player.Backpack -- Duplicate مباشرة في الـ Inventory
        end)
    end

    scrollFrame.CanvasSize = UDim2.new(0,0,0,uiList.AbsoluteContentSize.Y + 10)
end

-- تحديث Tools كل 3 ثواني
updateTools()
task.spawn(function()
    while true do
        task.wait(3)
        updateTools()
    end
end)

-- Dragging GUI
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.fromOffset(startPos.X + delta.X, startPos.Y + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        dragInput = input
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        update(input)
    end
end)
