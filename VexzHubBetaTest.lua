-- ╔══════════════════════════════════════════════════╗
-- ║  VEXZ HUB - UI TEST + BUTTON FIX               ║
-- ╚══════════════════════════════════════════════════╝

-- =====================================================
-- FLUENT UI
-- =====================================================
local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()
if not Fluent then
    print("[Vexz Hub] FATAL: Cannot load Fluent UI.")
    return
end

local SaveManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"
))()
local InterfaceManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
))()

local LP = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- =====================================================
-- FLUENT UI TẠO WINDOW
-- =====================================================
local Window = Fluent:CreateWindow({
    Title       = "Vexz Hub",
    SubTitle    = "Blox Fruit - UI Test",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 440),
    Acrylic     = true,
    Theme       = "Pink",
    MinimizeKey = Enum.KeyCode.RightShift,
})

local Tabs = {
    Farm   = Window:AddTab({ Title = "Farm",   Icon = "swords" }),
    Mob    = Window:AddTab({ Title = "Mob",    Icon = "zap" }),
    Misc   = Window:AddTab({ Title = "Misc",   Icon = "settings" }),
}

Tabs.Farm:AddSection("Auto Farm")
Tabs.Farm:AddToggle("StartFarm", {
    Title       = "Start Farm",
    Description = "Auto Quest + Farm Level",
    Default     = false,
}):OnChanged(function(v) print("[Test] StartFarm:", v) end)

Tabs.Mob:AddSection("Bring Mob")
Tabs.Mob:AddToggle("BringMob", {
    Title       = "Bring Mob",
    Description = "Keo quai ve 1 cho",
    Default     = false,
}):OnChanged(function(v) print("[Test] BringMob:", v) end)

Tabs.Misc:AddSection("Settings")
Tabs.Misc:AddParagraph({ Title = "Phim tat", Content = "RightShift — An/Hien UI" })

Window:SelectTab(1)

-- =====================================================
-- TÌM FLUENT SCREENGUI
-- =====================================================
local FluentScreenGui = nil
task.spawn(function()
    task.wait(1)
    local pGui = LP:WaitForChild("PlayerGui")
    for _, gui in ipairs(pGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            -- In ra tên tất cả ScreenGui để debug
            print("[DEBUG] ScreenGui:", gui.Name)
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("TextButton") then
                    if v.Text == "Farm" or v.Text == "Mob" or v.Text == "Misc" then
                        FluentScreenGui = gui
                        print("[Vexz Hub] ✅ Fluent ScreenGui found:", gui.Name)
                        return
                    end
                end
            end
        end
    end
    print("[Vexz Hub] ⚠️ Fluent ScreenGui NOT found via tabs, trying backup...")
    -- Backup: tìm Container
    for _, gui in ipairs(pGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("Frame") and v.Name == "Container" then
                    FluentScreenGui = gui
                    print("[Vexz Hub] ✅ Fluent ScreenGui found (backup):", gui.Name)
                    return
                end
            end
        end
    end
    print("[Vexz Hub] ❌ Fluent ScreenGui NOT FOUND")
end)

-- =====================================================
-- FLOATING BUTTON
-- =====================================================
local FloatScreenGui = Instance.new("ScreenGui")
FloatScreenGui.Name = "VexzHub_FloatingButton"
FloatScreenGui.Parent = LP:WaitForChild("PlayerGui")
FloatScreenGui.ResetOnSpawn = false
FloatScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FloatScreenGui.DisplayOrder = 999

local ImageButton = Instance.new("ImageButton")
ImageButton.Size = UDim2.new(0, 50, 0, 50)
ImageButton.Position = UDim2.new(0, 20, 0, 100)
ImageButton.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
ImageButton.BorderSizePixel = 0
ImageButton.Image = "rbxassetid://93384558628762"
ImageButton.Parent = FloatScreenGui

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = ImageButton

-- UIStroke để dễ nhìn thấy nút
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Parent = ImageButton

local clickCount = 0
ImageButton.MouseButton1Click:Connect(function()
    clickCount = clickCount + 1
    print("[Button] Click #" .. clickCount)
    print("[Button] FluentScreenGui:", FluentScreenGui and FluentScreenGui.Name or "nil")
    
    if FluentScreenGui and FluentScreenGui.Parent then
        local wasEnabled = FluentScreenGui.Enabled
        FluentScreenGui.Enabled = not FluentScreenGui.Enabled
        print("[Button] ✅ Toggled Fluent UI from", wasEnabled, "to", FluentScreenGui.Enabled)
        return
    end
    
    -- Fallback: tìm lại
    print("[Button] 🔄 Retry finding Fluent UI...")
    local pGui = LP:WaitForChild("PlayerGui")
    for _, gui in ipairs(pGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui ~= FloatScreenGui then
            for _, v in ipairs(gui:GetDescendants()) do
                if (v:IsA("TextLabel") or v:IsA("TextButton")) and (v.Text == "Farm" or v.Text == "Mob" or v.Text == "Misc") then
                    FluentScreenGui = gui
                    FluentScreenGui.Enabled = not FluentScreenGui.Enabled
                    print("[Button] ✅ Found & Toggled:", gui.Name)
                    return
                end
            end
        end
    end
    
    -- In ra tất cả ScreenGui để debug
    print("[Button] ❌ NOT FOUND. All ScreenGuis:")
    for _, gui in ipairs(pGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            print("[Button]   -", gui.Name, "| Enabled:", gui.Enabled)
        end
    end
end)

-- Kéo thả
local dragging = false
local dragStart = nil
local startPos = nil

ImageButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ImageButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        ImageButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

print("=" .. string.rep("=", 50))
print("[Vexz Hub] UI TEST LOADED!")
print("  - Fluent UI: Created")
print("  - Floating Button: Pink circle, top-left")
print("  - Click button to toggle Fluent UI")
print("  - Check console for debug info")
print("  - RightShift: Also toggle UI")
print("=" .. string.rep("=", 50)) 
