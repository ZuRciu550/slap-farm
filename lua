-- ==========================================
-- 1. YÜKLENME KONTROLÜ
-- ==========================================
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

-- ==========================================
-- 2. GUI GÜVENLİĞİ VE ANTI-DUPLICATE
-- ==========================================
local GuiParent = (gethui and gethui()) or game:GetService("CoreGui")
if not pcall(function() local _ = GuiParent.Name end) then
    GuiParent = LocalPlayer:WaitForChild("PlayerGui")
end

if getgenv().XenoSlappleFarmLoaded then
    if GuiParent:FindFirstChild("XenoSlappleUI") then
        GuiParent.XenoSlappleUI:Destroy()
    end
end
getgenv().XenoSlappleFarmLoaded = true

local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ==========================================
-- 3. DURUM KAYDI
-- ==========================================
local stateFileName = "XenoSlappleFarmState.txt"

local function isFarmingActive()
    if isfile and isfile(stateFileName) then
        return readfile(stateFileName) == "true"
    end
    return false
end

local function saveFarmingState(state)
    if writefile then
        writefile(stateFileName, tostring(state))
    end
end

local isFarming = isFarmingActive()

-- ==========================================
-- 4. ARAYÜZ (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XenoSlappleUI"
ScreenGui.Parent = GuiParent
ScreenGui.ResetOnSpawn = false

local MainButton = Instance.new("TextButton")
MainButton.Size = UDim2.new(0, 150, 0, 50)
MainButton.Position = UDim2.new(0.5, -75, 0.1, 0)
MainButton.BackgroundColor3 = isFarming and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
MainButton.Text = isFarming and "Farm: AÇIK" or "Farm: KAPALI"
MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainButton.Font = Enum.Font.GothamBold
MainButton.TextSize = 18
MainButton.BorderSizePixel = 0
MainButton.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainButton

local dragging, dragInput, dragStart, startPos
MainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- ==========================================
-- 5. ANINDA RASTGELE SERVER HOP & FARM MANTIĞI
-- ==========================================
local function serverHop()
    if not isFarming then return end
    MainButton.Text = "Geçiliyor..."
    MainButton.BackgroundColor3 = Color3.fromRGB(200, 150, 40)
    
    -- Teleport olurken GitHub kodunu tekrar enjekte etmeyi sıraya al
    if queue_on_teleport then
        queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/ZuRciu550/slap-farm/refs/heads/main/lua"))()')
    end
    
    -- API'den sunucu aramak yerine oyuna doğrudan bizi rastgele bir sunucuya atmasını söylüyoruz
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

local function startFarmingLogic()
    if not isFarming then return end
    
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    
    if not hrp then return end 

    -- Başlangıç noktasına ışınlan
    hrp.CFrame = CFrame.new(-1310.16211, 329.901642, 3.98608398, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    task.wait(0.5)
    
    if not isFarming then return end

    -- Slapple'ları bul
    local slapples = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "Slapple" or obj.Name == "GoldenSlapple" then
            local glove = obj:FindFirstChild("Glove")
            if glove and glove:IsA("MeshPart") and glove.Transparency == 0 then
                table.insert(slapples, glove)
            end
        end
    end
    
    -- Meyveleri topla
    for _, glove in ipairs(slapples) do
        if not isFarming then return end
        
        if glove and glove.Parent and glove.Transparency == 0 then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = glove.CFrame
                task.wait(0.25) 
            end
        end
    end
    
    -- İş bitince anında zıpla
    if isFarming then
        serverHop()
    end
end

-- ==========================================
-- 6. BAŞLATMA 
-- ==========================================
MainButton.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    saveFarmingState(isFarming)
    
    if isFarming then
        MainButton.BackgroundColor3 = Color3.fromRGB(40, 200, 40)
        MainButton.Text = "Farm: AÇIK"
        task.spawn(startFarmingLogic)
    else
        MainButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        MainButton.Text = "Farm: KAPALI"
    end
end)

if isFarming then
    task.spawn(function()
        task.wait(2) 
        startFarmingLogic()
    end)
end
