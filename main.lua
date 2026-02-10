--[[
    TOUCH-TO-SPY (UI DETECTOR)
    Oleh: Gemini Assistant
    Fitur: Klik tombol game -> Muncul Path-nya.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- 1. BERSIHKAN UI LAMA
if CoreGui:FindFirstChild("TouchSpyUI") then
    CoreGui.TouchSpyUI:Destroy()
end

-- 2. GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TouchSpyUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 140) -- Kecil saja
MainFrame.Position = UDim2.new(0.5, -150, 0.2, 0) -- Di atas tengah
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
local MC = Instance.new("UICorner"); MC.CornerRadius=UDim.new(0,10); MC.Parent=MainFrame
local MS = Instance.new("UIStroke"); MS.Color=Color3.fromRGB(255,180,0); MS.Thickness=2; MS.Parent=MainFrame

-- JUDUL
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "TOUCH SPY (DETEKTOR)"
Title.TextColor3 = Color3.fromRGB(255, 180, 0)
Title.Font = Enum.Font.GothamBlack
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- TOMBOL ON/OFF
local SpyBtn = Instance.new("TextButton")
SpyBtn.Size = UDim2.new(0.9, 0, 0, 40)
SpyBtn.Position = UDim2.new(0.05, 0, 0, 35)
SpyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpyBtn.Text = "MODE SPY: MATI 🔴"
SpyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpyBtn.Font = Enum.Font.GothamBold
SpyBtn.Parent = MainFrame
local SC = Instance.new("UICorner"); SC.CornerRadius=UDim.new(0,6); SC.Parent=SpyBtn

-- HASIL PATH
local PathBox = Instance.new("TextBox")
PathBox.Size = UDim2.new(0.9, 0, 0, 40)
PathBox.Position = UDim2.new(0.05, 0, 0, 85)
PathBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
PathBox.Text = "Klik 'Mode Spy', lalu klik tombol game..."
PathBox.TextColor3 = Color3.fromRGB(100, 255, 100)
PathBox.PlaceholderText = "Path muncul disini"
PathBox.Font = Enum.Font.Code
PathBox.TextSize = 10
PathBox.TextWrapped = true
PathBox.ClearTextOnFocus = false
PathBox.Parent = MainFrame
local PC = Instance.new("UICorner"); PC.CornerRadius=UDim.new(0,6); PC.Parent=PathBox

-- TUTUP
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Parent = MainFrame
local CC = Instance.new("UICorner"); CC.CornerRadius=UDim.new(0,6); CC.Parent=CloseBtn
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- LOGIKA SPY
local IsSpying = false
local Connection = nil

local function Highlight(obj)
    local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true)
    local tween = TweenService:Create(obj, tInfo, {BackgroundColor3 = Color3.fromRGB(255, 0, 0)})
    tween:Play()
end

local function GetPath(obj)
    local pathStr = "game.Players.LocalPlayer.PlayerGui"
    local current = obj
    local pathParts = {}
    
    while current and current.Name ~= "PlayerGui" do
        table.insert(pathParts, 1, current.Name)
        current = current.Parent
    end
    
    for _, part in ipairs(pathParts) do
        if string.find(part, " ") or string.match(part, "^%d") then
            pathStr = pathStr .. '["' .. part .. '"]'
        else
            pathStr = pathStr .. "." .. part
        end
    end
    return pathStr
end

SpyBtn.MouseButton1Click:Connect(function()
    IsSpying = not IsSpying
    
    if IsSpying then
        SpyBtn.Text = "MODE SPY: AKTIF 🟢 (KLIK TOMBOL SKILL!)"
        SpyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        -- Mulai Mendengarkan Input
        Connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                
                -- Dapatkan posisi sentuhan
                local pos = input.Position
                -- Dapatkan SEMUA UI di posisi itu
                local objects = PlayerGui:GetGuiObjectsAtPosition(pos.X, pos.Y)
                
                for _, obj in ipairs(objects) do
                    -- Filter: Kita hanya peduli tombol (TextButton/ImageButton)
                    -- Dan jangan deteksi UI Spy kita sendiri
                    if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and not obj:IsDescendantOf(ScreenGui) then
                        
                        -- KETEMU!
                        local fullPath = GetPath(obj)
                        PathBox.Text = fullPath
                        Highlight(obj) -- Kedipkan tombolnya
                        
                        -- Matikan Spy otomatis setelah ketemu (biar gak spam)
                        IsSpying = false
                        SpyBtn.Text = "MODE SPY: MATI 🔴"
                        SpyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                        if Connection then Connection:Disconnect() end
                        return
                    end
                end
            end
        end)
    else
        SpyBtn.Text = "MODE SPY: MATI 🔴"
        SpyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        if Connection then Connection:Disconnect() end
    end
end)
