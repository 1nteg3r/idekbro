local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local VirtualInputManager = game:GetService("VirtualInputManager")

local function simulateClick()
    local viewportSize = game:GetService("Workspace").CurrentCamera.ViewportSize
    local clickPosition = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2) 
    VirtualInputManager:SendMouseButtonEvent(clickPosition.X, clickPosition.Y, 0, true, game, 0)
    task.wait(0.05) 
    VirtualInputManager:SendMouseButtonEvent(clickPosition.X, clickPosition.Y, 0, false, game, 0)
end

-- local function simulateEKeyPress()
--     -- Simulate pressing the "E" key (KeyCode = Enum.KeyCode.E)
--     VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game) -- Press
--     task.wait(0.1) -- Hold for a short duration
--     VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game) -- Release
-- end

local function handleClickPrompt(clickPrompt)
    local viewportSize = game:GetService("Workspace").CurrentCamera.ViewportSize
    local clickPosition = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2) 

    while clickPrompt do
        local promptText = clickPrompt.Text

        if promptText == "Press & Hold" then
            -- Hold click
            print("[DEBUG] Holding click...")
            VirtualInputManager:SendMouseButtonEvent(clickPosition.X, clickPosition.Y, 0, true, game, 0)

            -- Wait until text changes
            repeat
                task.wait(0.1)
            until clickPrompt.Text ~= "Press & Hold"

            -- Release click
            VirtualInputManager:SendMouseButtonEvent(clickPosition.X, clickPosition.Y, 0, false, game, 0)
            print("[DEBUG] Released hold!")
        else
            -- Click rapidly
            print("[DEBUG] Clicking rapidly...")
            simulateClick()
            task.wait(0.01) -- Adjust for clicking speed ||||||||stefstefstefstefstefsstefst|||||||| systefsestewfansfsatfstfgstefsgsfetsfewtfetsfetafshggsftefsteftfsftfteftastefstefssnbastfeftsaftftdsftftgasghghsdsghkjadhjgsaghdjksahkgjdghkjasdghjkashgjdkashgjkdstefstefststefastefstefst
        end
    end
end



local keycodemap = {
    ["a"] = 0x41, ["b"] = 0x42, ["c"] = 0x43, ["d"] = 0x44,
    ["e"] = 0x45, ["f"] = 0x46, ["g"] = 0x47, ["h"] = 0x48,
    ["i"] = 0x49, ["j"] = 0x4A, ["k"] = 0x4B, ["l"] = 0x4C,
    ["m"] = 0x4D, ["n"] = 0x4E, ["o"] = 0x4F, ["p"] = 0x50,
    ["q"] = 0x51, ["r"] = 0x52, ["s"] = 0x53, ["t"] = 0x54,
    ["u"] = 0x55, ["v"] = 0x56, ["w"] = 0x57, ["x"] = 0x58,
    ["y"] = 0x59, ["z"] = 0x5A, ["enter"] = 0x0D,
}

local Window = Rayfield:CreateWindow({
    Name = "txf0 hub -- Be a silly seal!",
    LoadingTitle = "still waiting chat",
    LoadingSubtitle = "by tefan <3",
    ConfigurationSaving = {
        Enabled = false,
    },
})

local Tab = Window:CreateTab("Main")


local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Infinite Stamina Toggle
local InfiniteStaminaEnabled = false
local InfiniteStaminaToggle = Tab:CreateToggle({
    Name = "Infinite Stamina",
    CurrentValue = false,
    Callback = function(state)
        InfiniteStaminaEnabled = state
        print("[DEBUG] Infinite Stamina:", state and "Enabled" or "Disabled")
    end,
})

-- Infinite Stamina Loop
spawn(function()
    while true do
        task.wait(0.1) -- Adjust delay for smoother updates
        if InfiniteStaminaEnabled then
            local player = workspace:FindFirstChild(game.Players.LocalPlayer.Name)
            if player then
                local swimStamina = player:FindFirstChild("Vars") and player.Vars:FindFirstChild("Swimming") and player.Vars.Swimming:FindFirstChild("SwimStamina")
                if swimStamina then
                    swimStamina.Value = 100 -- Set SwimStamina to 100
                else
                    warn("[DEBUG] SwimStamina not found!")
                end
            else
                warn("[DEBUG] Player not found in workspace!")
            end
        end
    end
end)

-- Auto-Fishing Farm Toggle
local AutoFishingEnabled = false
local AutoFishingToggle = Tab:CreateToggle({
    Name = "Auto-Fishing Farm",
    CurrentValue = false,
    Callback = function(state)
        AutoFishingEnabled = state
        print("[DEBUG] Auto-Fishing Farm:", state and "Enabled" or "Disabled")
    end,
})

local function isProximityPromptVisible(prompt)
    if not prompt.Enabled then
        return false -- Prompt is disabled
    end

    if not prompt.Active then
        return false -- Prompt is disabled
    end

    return true
end

local function getClosestFishingSpot()
    local player = game.Players.LocalPlayer
    if not player.Character then return nil end

    local playerPos = player.Character:GetPivot().Position -- Use GetPivot() for models without PrimaryPart
    local closestSpot = nil
    local minDistance = math.huge

    for _, spot in pairs(workspace.FishingSpots:GetChildren()) do
        local prompt = spot:FindFirstChild("ProximityPrompt", true) -- Search recursively

        if prompt and spot:IsA("BasePart") then -- Ensure it's a valid part
            local distance = (spot.Position - playerPos).Magnitude
            print("[DEBUG] Found FishingSpot:", spot.Name, "Distance:", distance)

            if distance < minDistance and distance <= 30 then
                minDistance = distance
                closestSpot = spot
            end
        else
            print("[ERROR] No valid ProximityPrompt or BasePart found in", spot.Name)
        end
    end

    if closestSpot then
        print("[DEBUG] Closest Fishing Spot:", closestSpot.Name, "at distance:", minDistance)
    else
        print("[ERROR] No valid fishing spot found!")
    end

    return closestSpot
end



local function checkForFishingPrompt()
    if not AutoFishingEnabled then
        print("[DEBUG] AutoFishing is disabled.")
        return false
    end

    -- Find the closest fishing spot and fire the prompt
    local closestSpot = getClosestFishingSpot()
    if closestSpot then
        local prompt = closestSpot:FindFirstChild("ProximityPrompt", true)
        if prompt then
            print("[DEBUG] Activating FishingSpot ProximityPrompt...")
            fireproximityprompt(prompt)

            print("[DEBUG] Waiting for FishingGameUI to appear...")
            task.wait(1)
        end
    end

    -- Ensure FishingGameUI exists
    local fishingGameUI = PlayerGui:FindFirstChild("FishingGameUI")
    if not fishingGameUI then
        print("[ERROR] FishingGameUI not found! Aborting fishing process.")
        return false
    end

    -- Wait for the fishing minigame to start
    print("[DEBUG] Waiting for fishing game to start...")
    local timeout = 10
    local startTime = tick()

    while AutoFishingEnabled and not fishingGameUI.Enabled do
        simulateClick()
        task.wait(0.2)

        if tick() - startTime > timeout then
            print("[ERROR] FishingGameUI did not enable in time! Aborting.")
            return false
        end
    end

    -- Double-check AutoFishing state
    if not AutoFishingEnabled then
        print("[DEBUG] AutoFishing is disabled. Resetting isFishing flag.")
        return false
    end

    print("[DEBUG] Fishing game started!")

    -- Check for the click prompt inside the UI
    local clickPrompt = fishingGameUI:FindFirstChild("CatchBar") and fishingGameUI.CatchBar:FindFirstChild("ClickPrompt")
    if clickPrompt then
        print("[DEBUG] Monitoring ClickPrompt text...")

        spawn(function()
            print("[DEBUG] Executing handleClickPrompt()...")
            handleClickPrompt(clickPrompt)
            print("[DEBUG] handleClickPrompt() finished execution.")
        end)
    else
        print("[ERROR] ClickPrompt not found! Aborting.")
    end

    -- ✅ **Wait for FishingGameUI to disappear before fishing again**
    print("[DEBUG] Waiting for FishingGameUI to close before next attempt...")
    while fishingGameUI.Enabled do
        task.wait(0.5)
    end
    print("[DEBUG] FishingGameUI closed. Ready for next fishing attempt.")

    return true
end




-- Existing Toggle for Selling Fish
local AutoSellEnabled = false -- Track the state of the toggle
local SellFishButton = Tab:CreateToggle({
    Name = "Sell All Fish after catching",
    CurrentValue = false,
    Callback = function(state)
        AutoSellEnabled = state
        print("[DEBUG] Auto-Sell All Fish:", state and "Enabled" or "Disabled")
    end
})

-- Spawn function to handle FishGetUI and auto-selling
spawn(function()
    while true do
        task.wait(1) -- Check every 0.3 seconds

        -- Find the FishGetUI in the PlayerGui
        local fishGetUI = PlayerGui:FindFirstChild("FishGetUI")
        if fishGetUI and fishGetUI.Enabled then
            print("[DEBUG] FishGetUI detected. Fish caught!")

            -- Simulate a click to confirm the catch (if needed)
            simulateClick()

            -- If Auto-Sell is enabled, trigger the selling process
            if AutoSellEnabled then
                local sellfishprompt = workspace.fishIgloo.SellFish:FindFirstChild("SellAllFish")
                if sellfishprompt and sellfishprompt:IsA("ProximityPrompt") then
                    fireproximityprompt(sellfishprompt)
                    print("[DEBUG] Sold all fish!")
                else
                    warn("[DEBUG] SellAllFish ProximityPrompt not found or is not a ProximityPrompt!")
                end
            end
        end
    end
end)
-- Auto-Fishing Loop

spawn(function()
    while true do
        task.wait(1)
        if AutoFishingEnabled then
            print("[DEBUG] Checking for fishing prompt...")
            local success = checkForFishingPrompt()
            if success then
                print("[DEBUG] Fishing in progress...")
                task.wait(2)
            else
                print("[DEBUG] No fishing prompt found. Checking again...")
            end
        else
            print("[DEBUG] AutoFishing is disabled.")
            task.wait(2)
        end
    end
end)

local function getClosestSparklyFishingSpot()
    local player = game.Players.LocalPlayer
    if not player.Character then return nil end

    local playerPos = player.Character:GetPivot().Position
    local closestSpot = nil
    local minDistance = math.huge

    for _, spot in pairs(workspace.FishingSpots:GetChildren()) do
        local isSparkly = spot:FindFirstChild("IsSparkly")
        local isEnabled = spot:FindFirstChild("IsEnabled")
        local prompt = spot:FindFirstChild("ProximityPrompt", true) -- Search recursively

        -- Ensure the spot is valid and meets conditions
        if isSparkly and isEnabled and prompt and isSparkly.Value and isEnabled.Value then
            local distance = (prompt.Parent.Position - playerPos).Magnitude

            if distance < minDistance then
                minDistance = distance
                closestSpot = prompt.Parent -- Use the part that has the ProximityPrompt
            end
        end
    end

    if closestSpot then
        print("[DEBUG] Closest Sparkly Fishing Spot:", closestSpot.Name, "Distance:", minDistance)
    else
        print("[ERROR] No Sparkly fishing spot found!")
    end

    return closestSpot
end

-- Button to teleport to the closest Sparkly Fishing Spot
Tab:CreateButton({
    Name = "Teleport to Sparkly Fishing Spot",
    Callback = function()
        local sparklySpot = getClosestSparklyFishingSpot()
        if sparklySpot then
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = sparklySpot.CFrame + Vector3.new(0, 3, 0) -- Teleport slightly above
                print("[DEBUG] Teleported to:", sparklySpot.Name)
            end
        else
            print("[ERROR] No Sparkly Fishing Spot found!")
        end
    end
})

