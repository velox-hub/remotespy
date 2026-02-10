--[[
    TOUCH-TO-SPY V2 (WITH COPY BUTTON)
    Oleh: Gemini Assistant
    Fitur: Deteksi tombol game -> Copy Path otomatis.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- 1. BERSIHKAN UI LAMA
if CoreGui:FindFirstChild("TouchSpyUI_V2") then
    CoreGui.TouchSpyUI_V2:Destroy()
end

-- 2. GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TouchSpyUI_V2"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 190) -- Lebih tinggi untuk tombol copy
MainFrame.Position = UDim2.new(0.5, -160, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Active = true
MainFrame.Draggable = true -- Bisa digeser
MainFrame.Parent = ScreenGui
local MC = Instance.new("UICorner"); MC.CornerRadius=UDim.new(0,10); MC.Parent=MainFrame
local MS = Instance.new("UIStroke"); MS.Color=Color3.fromRGB(255,180,0); MS.Thickness=2; MS.Parent=MainFrame

-- JUDUL
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "UI SPY DETECTOR V2"
Title.TextColor3 = Color3.fromRGB(255, 180, 0)
Title.Font = Enum.Font.GothamBlack
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- TOMBOL ON/OFF (SPY)
local SpyBtn = Instance.new("TextButton")
SpyBtn.Size = UDim2.new(0.9, 0, 0, 40)
SpyBtn.Position = UDim2.new(0.05, 0, 0, 35)
SpyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpyBtn.Text = "MODE SPY: MATI 🔴"
SpyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpyBtn.Font = Enum.Font.GothamBold
SpyBtn.Parent = MainFrame
local SC = Instance.new("UICorner"); SC.CornerRadius=UDim.new(0,6); SC.Parent=SpyBtn

-- KOTAK HASIL PATH
local PathBox = Instance.new("TextBox")
PathBox.Size = UDim2.new(0.9, 0, 0, 40)
PathBox.Position = UDim2.new(0.05, 0, 0, 85)
PathBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
PathBox.Text = "Klik 'Mode Spy', lalu sentuh tombol game..."
PathBox.TextColor3 = Color3.fromRGB(150, 150, 150)
PathBox.PlaceholderText = "Path muncul disini"
PathBox.Font = Enum.Font.Code
PathBox.TextSize = 10
PathBox.TextWrapped = true
PathBox.ClearTextOnFocus = false
PathBox.Parent = MainFrame
local PC = Instance.new("UICorner"); PC.CornerRadius=UDim.new(0,6); PC.Parent=PathBox

-- TOMBOL COPY (BARU!)
local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.9, 0, 0, 40)
CopyBtn.Position = UDim2.new(0.05, 0, 0, 135)
CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255) -- Biru
CopyBtn.Text = "COPY PATH 📋"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.GothamBlack
CopyBtn.TextSize = 14
CopyBtn.Parent = MainFrame
local CC = Instance.new("UICorner"); CC.CornerRadius=UDim.new(0,6); CC.Parent=CopyBtn

-- TOMBOL TUTUP (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Parent = MainFrame
local XC = Instance.new("UICorner"); XC.CornerRadius=UDim.new(0,6); XC.Parent=CloseBtn
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- LOGIKA SPY & COPY
local IsSpying = false
local InputConnection = nil

-- Fungsi Animasi Kedip
local function BlinkHighlight(obj)
    local originalColor = obj.BackgroundColor3
    local tInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true)
    local tween = TweenService:Create(obj, tInfo, {BackgroundColor3 = Color3.fromRGB(255, 0, 0)})
    tween:Play()
end

-- Fungsi Membuat Path String
local function GeneratePath(obj)
    local pathStr = "game.Players.LocalPlayer.PlayerGui"
    local current = obj
    local pathParts = {}
    
    -- Naik ke atas sampai ketemu PlayerGui
    while current and current.Name ~= "PlayerGui" do
        table.insert(pathParts, 1, current.Name)
        current = current.Parent
    end
    
    -- Gabung string
    for _, part in ipairs(pathParts) do
        -- Cek spasi atau angka di depan
        if string.find(part, " ") or string.match(part, "^%d") then
            pathStr = pathStr .. '["' .. part .. '"]'
        else
            pathStr = pathStr .. "." .. part
        end
    end
    return pathStr
end

-- EVENT: COPY BUTTON CLICK
CopyBtn.MouseButton1Click:Connect(function()
    if PathBox.Text ~= "" and not string.find(PathBox.Text, "Klik") then
        setclipboard(PathBox.Text) -- FUNGSI COPY CLIPBOARD
        
        -- Efek Visual "Copied"
        local oldText = CopyBtn.Text
        local oldColor = CopyBtn.BackgroundColor3
        
        CopyBtn.Text = "TERSALIN! ✅"
        CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Hijau
        
        task.delay(1, function()
            CopyBtn.Text = oldText
            CopyBtn.BackgroundColor3 = oldColor
        end)
    else
        CopyBtn.Text = "KOSONG! ❌"
        task.delay(1, function() CopyBtn.Text = "COPY PATH 📋" end)
    end
end)

-- EVENT: SPY TOGGLE
SpyBtn.MouseButton1Click:Connect(function()
    IsSpying = not IsSpying
    
    if IsSpying then
        SpyBtn.Text = "SPY: AKTIF 🟢 (KLIK TOMBOL SKILL)"
        SpyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        -- Mulai Deteksi Input
        if InputConnection then InputConnection:Disconnect() end
        InputConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                
                local pos = input.Position
                local objects = PlayerGui:GetGuiObjectsAtPosition(pos.X, pos.Y)
                
                for _, obj in ipairs(objects) do
                    -- Filter: Tombol (Visible) dan BUKAN UI SPY kita sendiri
                    if (obj:IsA("TextButton") or obj:IsA("ImageButton")) 
                        and obj.Visible 
                        and not obj:IsDescendantOf(ScreenGui) then
                        
                        -- TOMBOL DITEMUKAN!
                        local fullPath = GeneratePath(obj)
                        
                        -- Update UI
                        PathBox.Text = fullPath
                        PathBox.TextColor3 = Color3.fromRGB(100, 255, 255)
                        BlinkHighlight(obj)
                        
                        -- Matikan Spy Otomatis
                        IsSpying = false
                        SpyBtn.Text = "MODE SPY: MATI 🔴"
                        SpyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                        if InputConnection then InputConnection:Disconnect() end
                        return
                    end
                end
            end
        end)
    else
        SpyBtn.Text = "MODE SPY: MATI 🔴"
        SpyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        if InputConnection then InputConnection:Disconnect() end
    end
end)
