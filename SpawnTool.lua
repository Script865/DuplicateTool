-- LocalScript: ServerStorage Tools GUI Recursive
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
scrollFrame.ScrollBarThickness =
