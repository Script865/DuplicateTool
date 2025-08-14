-- LocalScript: Persistent Duplicate any held item

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create RemoteEvent
local REMOTE_NAME = "RequestPersistentDuplicate"
local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = REMOTE_NAME
    remote.Parent = ReplicatedStorage
end

-- Server-side duplication
if RunService:IsServer() then
    remote.OnServerEvent:Connect(function(player, item)
        if typeof(item) ~= "Instance" then return end
        local character = player.Character or player.CharacterAdded:Wait()

        local clone
        pcall(function() clone = item:Clone() end)
        if not clone then return end

        -- Parent clone to character to stay in hand
        clone.Parent = character
        if clone:IsA("Tool") then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:EquipTool(clone)
            end
        elseif clone:IsA("Model") and clone.PrimaryPart then
            clone:SetPrimaryPartCFrame(character:GetPivot())
        end

        -- Store clone in ReplicatedStorage to persist across respawn
        local storage = ReplicatedStorage:FindFirstChild("PersistentDuplicates")
        if not storage then
            storage = Instance.new("Folder")
            storage.Name = "PersistentDuplicates"
            storage.Parent = ReplicatedStorage
        end
        clone.Parent = storage
    end)
    return
end

-- ========= GUI =========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DuplicateItemGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "DragFrame"
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.fromScale(0.5,0.5)
frame.Size = UDim2.fromScale(0.22,0.085)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0,12)
uicorner.Parent = frame

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 2
uiStroke.Transparency = 0.25
uiStroke.Parent = frame

local button = Instance.new("TextButton")
button.Name = "DuplicateButton"
button.AnchorPoint = Vector2.new(0.5,0.5)
button.Position = UDim2.fromScale(0.5,0.5)
button.Size = UDim2.fromScale(0.95,0.8)
button.Text = "Duplicate"
button.TextScaled = true
button.AutoButtonColor = true
button.BackgroundColor3 = Color3.fromRGB(50,50,50)
button.BorderSizePixel = 0
button.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0,10)
btnCorner.Parent = button

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0,6)
padding.PaddingBottom = UDim.new(0,6)
padding.PaddingLeft = UDim.new(0,6)
padding.PaddingRight = UDim.new(0,6)
padding.Parent = frame

local tip = Instance.new("TextLabel")
tip.AnchorPoint = Vector2.new(0.5,0)
tip.Position = UDim2.fromScale(0.5,1)
tip.Size = UDim2.fromScale(1,0.6)
tip.BackgroundTransparency = 1
tip.Text = "Drag (Mobile) or Right Click (PC)"
tip.TextScaled = true
tip.TextColor3 = Color3.fromRGB(220,220,220)
tip.Parent = frame

-- ========= Dragging =========
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

-- ========= Get held item =========
local function getHeldItem()
    local character = player.Character
    if not character then return nil end
    for _, inst in ipairs(character:GetChildren()) do
        if inst:IsA("Tool") then return inst end
        if inst:IsA("Model") and inst.PrimaryPart then return inst end
    end
    return nil
end

-- ========= Button click =========
button.Activated:Connect(function()
    local item = getHeldItem()
    if item then
        remote:FireServer(item)
        button.AutoButtonColor = false
        local old = button.BackgroundColor3
        button.BackgroundColor3 = Color3.fromRGB(80,120,80)
        task.wait(0.1)
        button.BackgroundColor3 = old
        button.AutoButtonColor = true
    else
        button.AutoButtonColor = false
        local old = button.BackgroundColor3
        button.BackgroundColor3 = Color3.fromRGB(150,60,60)
        task.wait(0.15)
        button.BackgroundColor3 = old
        button.AutoButtonColor = true
    end
end)

-- ========= Clamp GUI to screen =========
local function clampToScreen()
    local guiInset = GuiService:GetGuiInset()
    local absSize = screenGui.AbsoluteSize
    local pos = frame.AbsolutePosition
    local size = frame.AbsoluteSize
    local x = math.clamp(pos.X, 0, absSize.X - size.X)
    local y = math.clamp(pos.Y, guiInset.Y, absSize.Y - size.Y)
    frame.Position = UDim2.fromOffset(x, y)
end

screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(clampToScreen)
