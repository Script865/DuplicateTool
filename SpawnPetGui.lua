-- LocalScript: Spawn & Hold Persistent Pets for Grow a Garden (No Model Input, Auto Generic)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create RemoteEvent
local REMOTE_NAME = "SpawnPersistentPet"
local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = REMOTE_NAME
    remote.Parent = ReplicatedStorage
end

-- Server-side: spawn pet and keep persistent
if RunService:IsServer() then
    remote.OnServerEvent:Connect(function(player, petName, age, weight)
        -- Create a generic part as pet model
        local pet = Instance.new("Part")
        pet.Name = petName or "Pet"
        pet.Size = Vector3.new(2,2,2)
        pet.Anchored = false
        pet.CanCollide = true
        pet:SetAttribute("Age", age or 1)
        pet:SetAttribute("Weight", weight or 1)

        -- Optional: color by pet type (example)
        if petName:lower():find("raccoon") then
            pet.BrickColor = BrickColor.new("Really black")
        elseif petName:lower():find("chicken") then
            pet.BrickColor = BrickColor.new("Bright yellow")
        else
            pet.BrickColor = BrickColor.Random()
        end

        -- Position near player
        local character = player.Character or player.CharacterAdded:Wait()
        pet.CFrame = character:GetPivot() * CFrame.new(0,3,0)

        -- Parent to Workspace
        pet.Parent = workspace

        -- Store in ReplicatedStorage for persistence
        local storage = ReplicatedStorage:FindFirstChild("PersistentPets")
        if not storage then
            storage = Instance.new("Folder")
            storage.Name = "PersistentPets"
            storage.Parent = ReplicatedStorage
        end
        pet.Parent = storage

        -- Example ability: if raccoon, steal nearby fruits
        if petName:lower():find("raccoon") then
            spawn(function()
                while pet.Parent do
                    for _, obj in ipairs(workspace:GetChildren()) do
                        if obj:IsA("Part") and obj.Name:lower():find("fruit") then
                            obj.CFrame = pet.CFrame * CFrame.new(0,2,0)
                        end
                    end
                    task.wait(2)
                end
            end)
        end

        -- Equip as Tool if player wants to hold
        local tool = Instance.new("Tool")
        tool.Name = petName
        tool.RequiresHandle = false
        pet.Parent = tool
        tool.Parent = player.Backpack
    end)
    return
end

-- ========= GUI =========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpawnPetGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.fromScale(0.5,0.5)
frame.Size = UDim2.fromScale(0.25,0.25)
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

-- Labels & TextBoxes
local function createLabel(text, position)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(220,220,220)
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(0.9,0.15)
    label.Position = position
    label.Parent = frame
    return label
end

local function createTextbox(placeholder, position)
    local tb = Instance.new("TextBox")
    tb.PlaceholderText = placeholder
    tb.Text = ""
    tb.TextScaled = true
    tb.BackgroundColor3 = Color3.fromRGB(50,50,50)
    tb.BorderSizePixel = 0
    tb.Size = UDim2.fromScale(0.9,0.12)
    tb.Position = position
    tb.TextColor3 = Color3.fromRGB(220,220,220)
    local corner = Instance.new("UICorner", tb)
    corner.CornerRadius = UDim.new(0,6)
    tb.Parent = frame
    return tb
end

createLabel("Pet Name:", UDim2.fromScale(0.05,0.05))
local nameBox = createTextbox("Enter pet name", UDim2.fromScale(0.05,0.15))
createLabel("Age:", UDim2.fromScale(0.05,0.3))
local ageBox = createTextbox("Enter age", UDim2.fromScale(0.05,0.4))
createLabel("Weight:", UDim2.fromScale(0.05,0.55))
local weightBox = createTextbox("Enter weight", UDim2.fromScale(0.05,0.65))

-- Spawn Button
local spawnBtn = Instance.new("TextButton")
spawnBtn.Text = "Spawn Pet"
spawnBtn.TextScaled = true
spawnBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
spawnBtn.Size = UDim2.fromScale(0.9,0.12)
spawnBtn.Position = UDim2.fromScale(0.05,0.8)
spawnBtn.Parent = frame
local cornerBtn = Instance.new("UICorner", spawnBtn)
cornerBtn.CornerRadius = UDim.new(0,8)

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
    local age = tonumber(ageBox.Text) or 1
    local weight = tonumber(weightBox.Text) or 1
    if petName ~= "" then
        remote:FireServer(petName, age, weight)
    end
end)

-- Clamp GUI
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
