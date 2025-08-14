-- LocalScript: Spawn Pet with Beautiful GUI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- RemoteEvent
local REMOTE_NAME = "SpawnPersistentPet"
local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = REMOTE_NAME
    remote.Parent = ReplicatedStorage
end

-- Search function
local function findPetByName(name)
    local locations = {workspace, game:GetService("ServerStorage"), game:GetService("ServerScriptService"), ReplicatedStorage}
    for _, loc in ipairs(locations) do
        for _, obj in ipairs(loc:GetDescendants()) do
            if obj.Name:lower() == name:lower() and (obj:IsA("Model") or obj:IsA("Tool")) then
                return obj
            end
        end
    end
    return nil
end

-- Server-side spawn
if RunService:IsServer() then
    remote.OnServerEvent:Connect(function(player, petName)
        local original = findPetByName(petName)
        if not original then return end

        local clone
        pcall(function() clone = original:Clone() end)
        if not clone then return end

        -- Random Age & Weight
        local age = math.random(1,20)
        local weight = math.random(1,50)
        clone.Name = petName
        clone:SetAttribute("Age", age)
        clone:SetAttribute("Weight", weight)

        -- Position near player
        local character = player.Character or player.CharacterAdded:Wait()
        if clone:IsA("Model") and clone.PrimaryPart then
            clone:SetPrimaryPartCFrame(character:GetPivot() * CFrame.new(0,3,0))
        elseif clone:IsA("Tool") then
            clone.Parent = player.Backpack
        end

        -- Equip Model as Tool
        if clone:IsA("Model") then
            local tool = Instance.new("Tool")
            tool.Name = petName
            tool.RequiresHandle = false
            clone.Parent = tool
            tool.Parent = player.Backpack
        end

        -- Persistent storage
        local storage = ReplicatedStorage:FindFirstChild("PersistentPets")
        if not storage then
            storage = Instance.new("Folder")
            storage.Name = "PersistentPets"
            storage.Parent = ReplicatedStorage
        end
        clone.Parent = storage
    end)
    return
end

-- ========= Beautiful GUI =========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpawnPetGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Main Frame
local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.fromScale(0.5,0.5)
frame.Size = UDim2.fromScale(0.3,0.2)
frame.BackgroundColor3 = Color3.fromRGB(45,45,60)
frame.BackgroundTransparency = 0
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
title.Text = "🌟 Spawn Pet 🌟"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(240,240,255)
title.BackgroundTransparency = 1
title.Size = UDim2.fromScale(1,0.3)
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Pet Name Box
local nameBox = Instance.new("TextBox")
nameBox.PlaceholderText = "Enter Pet Name"
nameBox.Text = ""
nameBox.TextScaled = true
nameBox.BackgroundColor3 = Color3.fromRGB(65,65,90)
nameBox.BorderSizePixel = 0
nameBox.Size = UDim2.fromScale(0.9,0.35)
nameBox.Position = UDim2.fromScale(0.05,0.35)
nameBox.TextColor3 = Color3.fromRGB(255,255,255)
nameBox.Font = Enum.Font.Gotham
local cornerName = Instance.new("UICorner", nameBox)
cornerName.CornerRadius = UDim.new(0,10)
nameBox.Parent = frame

-- Spawn Button
local spawnBtn = Instance.new("TextButton")
spawnBtn.Text = "Spawn Pet"
spawnBtn.TextScaled = true
spawnBtn.BackgroundColor3 = Color3.fromRGB(100,100,200)
spawnBtn.Size = UDim2.fromScale(0.9,0.25)
spawnBtn.Position = UDim2.fromScale(0.05,0.75)
spawnBtn.TextColor3 = Color3.fromRGB(255,255,255)
spawnBtn.Font = Enum.Font.GothamBold
local cornerBtn = Instance.new("UICorner", spawnBtn)
cornerBtn.CornerRadius = UDim.new(0,10)
spawnBtn.Parent = frame

-- Hover effect
spawnBtn.MouseEnter:Connect(function()
    spawnBtn.BackgroundColor3 = Color3.fromRGB(130,130,230)
end)
spawnBtn.MouseLeave:Connect(function()
    spawnBtn.BackgroundColor3 = Color3.fromRGB(100,100,200)
end)

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

-- Spawn action
spawnBtn.Activated:Connect(function()
    local petName = nameBox.Text
    if petName ~= "" then
        remote:FireServer(petName)
    end
end)
