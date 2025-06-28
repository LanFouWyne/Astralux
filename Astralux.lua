--! luanes
-- KODE VALIDASI DARI LOADER (DITINGKATKAN)

-- Cek apakah script ini dijalankan secara paksa tanpa loader,
-- ATAU jika loader dijalankan tetapi tidak pernah berhasil memvalidasi key.
if not getgenv()._astralux_key_valid or getgenv()._astralux_key_valid ~= true then
    game.Players.LocalPlayer:Kick("Script dijalankan secara paksa atau validasi key gagal. Harap gunakan loader Astralux.")
    return
end

-- Hapus flag setelah validasi berhasil untuk mencegah penggunaan ulang atau bypass mudah.
getgenv()._astralux_key_valid = nil

-- SCRIPT UTAMA ANDA DIMULAI DARI SINI
local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local Window = Library:CreateWindow{
    Title = "Peta Peta",
    SubTitle = "by Astralux",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark"
}

local Tabs = {
    Main = Window:CreateTab{
        Title = "Main",
        Icon = "phosphor-users-bold"
    }
}

local function applyHighlight(object, color)
    if not object:FindFirstChildOfClass("Highlight") then
        local hl = Instance.new("Highlight")
        hl.FillColor = color
        hl.FillTransparency = 0.2
        hl.OutlineTransparency = 1
        hl.Parent = object
    end
end

local function removeHighlight(object)
    local highlight = object:FindFirstChildOfClass("Highlight")
    if highlight then
        highlight:Destroy()
    end
end

local Toggle = Tabs.Main:CreateToggle("ESPToggle", {
    Title = "Enable All ESP",
    Default = false
})

-- Toggle untuk bypass ProximityPrompt
local ProximityBypassToggle = Tabs.Main:CreateToggle("ProximityBypassToggle", {
    Title = "Bypass ProximityPrompt",
    Description = "Instantly triggers proximity prompts without holding",
    Default = false
})

-- Toggle untuk teleport ke enemy
local TeleportToEnemyToggle = Tabs.Main:CreateToggle("TeleportToEnemyToggle", {
    Title = "Dynamic Enemy Follow",
    Description = "Dynamically teleport in front of enemy (Requires Ofuda)",
    Default = false
})

-- Toggle baru untuk teleport enemy ke ofuda
local TeleportEnemyToOfudaToggle = Tabs.Main:CreateToggle("TeleportEnemyToOfudaToggle", {
    Title = "Teleport Enemy to Ofuda",
    Description = "Teleports the enemy directly to your ofuda location",
    Default = false
})

-- Fungsi untuk bypass ProximityPrompt
ProximityBypassToggle:OnChanged(function()
    if ProximityBypassToggle.Value then
        -- Enable bypass
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                -- Store original HoldDuration if not already stored
                if not prompt:GetAttribute("OriginalHoldDuration") then
                    prompt:SetAttribute("OriginalHoldDuration", prompt.HoldDuration)
                end
                prompt.HoldDuration = 0
            end
        end
        
        -- Watch for new prompts
        local connection
        connection = workspace.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("ProximityPrompt") and ProximityBypassToggle.Value then
                if not descendant:GetAttribute("OriginalHoldDuration") then
                    descendant:SetAttribute("OriginalHoldDuration", descendant.HoldDuration)
                end
                descendant.HoldDuration = 0
            end
        end)
        
        -- Store connection for later cleanup
        getgenv().ProximityBypassConnection = connection
        
        Library:Notify{
            Title = "Proximity Bypass",
            Content = "Proximity prompt bypass enabled",
            Duration = 3
        }
    else
        -- Disable bypass
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                -- Restore original HoldDuration
                prompt.HoldDuration = prompt:GetAttribute("OriginalHoldDuration") or 1
                prompt:SetAttribute("OriginalHoldDuration", nil) -- Clear attribute
            end
        end
        
        -- Clean up connection
        if getgenv().ProximityBypassConnection then
            getgenv().ProximityBypassConnection:Disconnect()
            getgenv().ProximityBypassConnection = nil
        end
        
        Library:Notify{
            Title = "Proximity Bypass",
            Content = "Proximity prompt bypass disabled",
            Duration = 3
        }
    end
end)

-- Fungsi untuk teleport ke enemy secara otomatis
TeleportToEnemyToggle:OnChanged(function()
    if TeleportToEnemyToggle.Value then
        -- Aktifkan teleport ke enemy
        local enemyFollowLoop
        enemyFollowLoop = game:GetService("RunService").Heartbeat:Connect(function()
            local character = game.Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            -- Cek apakah karakter masih ada
            if not character or not character.Parent or not rootPart or not rootPart.Parent then
                return
            end

            -- [[ START: Pengecekan item Ofuda yang diperbaiki dan bebas spam ]]
            local hasOfudaEquipped = false
            -- Periksa apakah pemain memegang item yang namanya mengandung "Ofuda" atau "Talisman"
            for _, child in ipairs(character:GetChildren()) do
                if child:IsA("Tool") and (string.match(child.Name:lower(), "ofuda") or string.match(child.Name:lower(), "talisman")) then
                    hasOfudaEquipped = true
                    break
                end
            end

            if not hasOfudaEquipped then
                -- Jika Ofuda tidak dipegang
                if not getgenv().OfudaRequirementWarningShown then
                    -- Tampilkan notifikasi hanya jika belum pernah ditampilkan sejak terakhir kali Ofuda dipegang
                    Library:Notify{
                        Title = "Dynamic Enemy Follow",
                        Content = "Anda harus memegang Ofuda untuk mengikuti musuh!",
                        Duration = 3
                    }
                    getgenv().OfudaRequirementWarningShown = true -- Setel flag agar notifikasi tidak diulang
                end
                return -- Hentikan loop jika Ofuda tidak dipegang
            else
                -- Jika Ofuda dipegang, pastikan flag notifikasi direset
                if getgenv().OfudaRequirementWarningShown then
                    getgenv().OfudaRequirementWarningShown = false -- Reset flag agar notifikasi bisa muncul lagi jika Ofuda dilepas
                end
            end
            -- [[ END: Pengecekan item Ofuda yang diperbaiki dan bebas spam ]]
            
            -- Cek apakah enemy client ada di path yang ditentukan
            local currentEnemy = workspace.Client.Enemy.ClientEnemy:FindFirstChild("EnemyModel")
            
            -- Jika tidak ditemukan di path utama, coba cari di lokasi lain sebagai fallback
            if not currentEnemy then
                currentEnemy = workspace.Server.Enemy:FindFirstChild("Enemy") or workspace:FindFirstChild("EnemyModel", true) or workspace:FindFirstChild("EnemyModels", true)
            end
            
            -- Teleport ke enemy secara otomatis
            if currentEnemy then
                -- Dapatkan posisi enemy terbaru dan arah hadapnya
                local currentEnemyPosition
                local enemyLookVector
                local enemyHeight = 0
                
                -- Cari HumanoidRootPart atau bagian utama dari enemy
                if currentEnemy:FindFirstChild("HumanoidRootPart") then
                    local enemyRootPart = currentEnemy.HumanoidRootPart
                    currentEnemyPosition = enemyRootPart.Position
                    enemyLookVector = enemyRootPart.CFrame.LookVector
                    
                    local humanoid = currentEnemy:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        enemyHeight = humanoid.HipHeight * 2
                    end
                elseif typeof(currentEnemy.GetPivot) == "function" then
                    local enemyCFrame = currentEnemy:GetPivot()
                    currentEnemyPosition = enemyCFrame.Position
                    enemyLookVector = enemyCFrame.LookVector
                    
                    if currentEnemy:IsA("Model") then
                        enemyHeight = currentEnemy:GetExtentsSize().Y / 2
                    end
                elseif currentEnemy:IsA("BasePart") then
                    currentEnemyPosition = currentEnemy.Position
                    enemyLookVector = currentEnemy.CFrame.LookVector
                    enemyHeight = currentEnemy.Size.Y / 2
                else
                    -- Coba temukan bagian utama enemy dan dapatkan tinggi
                    for _, child in pairs(currentEnemy:GetDescendants()) do
                        if child:IsA("BasePart") and (child.Name:lower():find("head")) then
                            currentEnemyPosition = child.Position
                            enemyLookVector = child.CFrame.LookVector
                            enemyHeight = child.Size.Y * 0.8
                            break
                        elseif child:IsA("BasePart") and (child.Name:lower():find("torso") or child.Name:lower():find("upper")) then
                            currentEnemyPosition = child.Position
                            enemyLookVector = child.CFrame.LookVector
                            enemyHeight = child.Size.Y
                            break
                        elseif child:IsA("BasePart") and child.Name:lower():find("root") then
                            currentEnemyPosition = child.Position
                            enemyLookVector = child.CFrame.LookVector
                            break
                        end
                    end
                    
                    if not currentEnemyPosition then
                        for _, child in pairs(currentEnemy:GetDescendants()) do
                            if child:IsA("BasePart") then
                                currentEnemyPosition = child.Position
                                enemyLookVector = child.CFrame.LookVector
                                enemyHeight = child.Size.Y / 2
                                break
                            end
                        end
                    end
                end
                
                if enemyHeight < 1 then
                    enemyHeight = 5
                end
                
                if currentEnemyPosition and enemyLookVector then
                    -- Cek jarak enemy dari ofuda box
                    local ofudaBox = workspace.Server.SpawnedItems:FindFirstChild("OfudaBox2")
                    local isSafeToTeleport = true
                    
                    if ofudaBox then
                        local ofudaBoxPosition
                        
                        if typeof(ofudaBox.GetPivot) == "function" then
                            ofudaBoxPosition = ofudaBox:GetPivot().Position
                        elseif ofudaBox:IsA("BasePart") then
                            ofudaBoxPosition = ofudaBox.Position
                        else
                            for _, child in pairs(ofudaBox:GetDescendants()) do
                                if child:IsA("BasePart") then
                                    ofudaBoxPosition = child.Position
                                    break
                                end
                            end
                        end
                        
                        if ofudaBoxPosition then
                            local distanceToOfudaBox = (currentEnemyPosition - ofudaBoxPosition).Magnitude
                            if distanceToOfudaBox < 20 then
                                isSafeToTeleport = false
                                if not getgenv().WarningShown then
                                    Library:Notify{
                                        Title = "Warning",
                                        Content = "Enemy terlalu dekat dengan ofuda box! Menunggu enemy menjauh...",
                                        Duration = 3
                                    }
                                    getgenv().WarningShown = true
                                    task.delay(5, function()
                                        getgenv().WarningShown = false
                                    end)
                                end
                            end
                        end
                    end
                    
                    if isSafeToTeleport then
                        local distanceFromEnemy = -35
                        local targetPosition = currentEnemyPosition - (enemyLookVector * distanceFromEnemy)
                        targetPosition = Vector3.new(targetPosition.X, currentEnemyPosition.Y + (enemyHeight * 0.67), targetPosition.Z)
                        rootPart.CFrame = CFrame.new(targetPosition, currentEnemyPosition)
                        task.wait(0.03)
                    end
                end
            end
        end)
        
        getgenv().EnemyFollowLoop = enemyFollowLoop
        
        Library:Notify{
            Title = "Auto Follow Enemy",
            Content = "Dynamic enemy following enabled",
            Duration = 3
        }
    else
        -- Nonaktifkan teleport ke enemy
        if getgenv().EnemyFollowLoop then
            getgenv().EnemyFollowLoop:Disconnect()
            getgenv().EnemyFollowLoop = nil
        end
        getgenv().OfudaRequirementWarningShown = false
        
        Library:Notify{
            Title = "Auto Follow Enemy",
            Content = "Dynamic enemy following disabled",
            Duration = 3
        }
    end
end)

-- Fungsi untuk teleport enemy ke ofuda
TeleportEnemyToOfudaToggle:OnChanged(function()
    if TeleportEnemyToOfudaToggle.Value then
        -- Aktifkan teleport enemy ke ofuda
        local enemyToOfudaLoop
        enemyToOfudaLoop = game:GetService("RunService").Heartbeat:Connect(function()
            local ofudaModel = workspace.Client.VFX.Ofuda:FindFirstChild("Model")
            if not ofudaModel then
                for _, child in pairs(workspace.Client.VFX.Ofuda:GetChildren()) do
                    if child:IsA("Model") then
                        ofudaModel = child
                        break
                    end
                end
            end
            
            local currentEnemy = workspace.Server.Enemy:FindFirstChild("Enemy") or workspace:FindFirstChild("EnemyModel", true) or workspace:FindFirstChild("EnemyModels", true)
            
            if currentEnemy and ofudaModel then
                local ofudaPosition
                
                if typeof(ofudaModel.GetPivot) == "function" then
                    ofudaPosition = ofudaModel:GetPivot().Position
                elseif ofudaModel:IsA("BasePart") then
                    ofudaPosition = ofudaModel.Position
                else
                    for _, child in pairs(ofudaModel:GetDescendants()) do
                        if child:IsA("BasePart") then
                            ofudaPosition = child.Position
                            break
                        end
                    end
                end
                
                if ofudaPosition then
                    -- Ensure currentEnemy has a HumanoidRootPart or a primary part to pivot
                    local rootPartToMove = currentEnemy:FindFirstChild("HumanoidRootPart") or (typeof(currentEnemy.GetPivot) == "function" and currentEnemy.PrimaryPart)
                    if rootPartToMove then
                        currentEnemy:PivotTo(CFrame.new(ofudaPosition))
                    elseif currentEnemy:IsA("BasePart") then
                        currentEnemy.CFrame = CFrame.new(ofudaPosition)
                    else
                        -- Fallback for models without HumanoidRootPart or PrimaryPart
                        for _, child in pairs(currentEnemy:GetDescendants()) do
                            if child:IsA("BasePart") and (child.Name:lower():find("humanoidrootpart") or child.Name:lower():find("root")) then
                                child.CFrame = CFrame.new(ofudaPosition)
                                break
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end
        end)
        
        local enemyAddedConnection
        enemyAddedConnection = workspace.Server.Enemy.ChildAdded:Connect(function(child)
            if child.Name == "Enemy" and TeleportEnemyToOfudaToggle.Value then
                task.wait(0.5)
                local ofudaModel = workspace.Client.VFX.Ofuda:FindFirstChild("Model")
                if not ofudaModel then
                    for _, mdl in pairs(workspace.Client.VFX.Ofuda:GetChildren()) do
                        if mdl:IsA("Model") then
                            ofudaModel = mdl
                            break
                        end
                    end
                end
                
                if ofudaModel then
                    local ofudaPosition
                    if typeof(ofudaModel.GetPivot) == "function" then
                        ofudaPosition = ofudaModel:GetPivot().Position
                    elseif ofudaModel:IsA("BasePart") then
                        ofudaPosition = ofudaModel.Position
                    else
                        for _, part in pairs(ofudaModel:GetDescendants()) do
                            if part:IsA("BasePart") then
                                ofudaPosition = part.Position
                                break
                            end
                        end
                    end
                    
                    if ofudaPosition and child:IsA("Model") then
                        if typeof(child.GetPivot) == "function" then
                            child:PivotTo(CFrame.new(ofudaPosition))
                        else
                            for _, part in pairs(child:GetDescendants()) do
                                if part:IsA("BasePart") and (part.Name:lower():find("humanoidrootpart") or part.Name:lower():find("root")) then
                                    part.CFrame = CFrame.new(ofudaPosition)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end)
        
        getgenv().EnemyToOfudaLoop = enemyToOfudaLoop
        getgenv().EnemyAddedConnection = enemyAddedConnection
        
        Library:Notify{
            Title = "Enemy to Ofuda",
            Content = "Enemy teleport to ofuda enabled",
            Duration = 3
        }
    else
        if getgenv().EnemyToOfudaLoop then
            getgenv().EnemyToOfudaLoop:Disconnect()
            getgenv().EnemyToOfudaLoop = nil
        end
        if getgenv().EnemyAddedConnection then
            getgenv().EnemyAddedConnection:Disconnect()
            getgenv().EnemyAddedConnection = nil
        end
        
        Library:Notify{
            Title = "Enemy to Ofuda",
            Content = "Enemy teleport to ofuda disabled",
            Duration = 3
        }
    end
end)

local function applyESP()
    if Toggle.Value then
        -- ESP Peta Peta
        for _, model in ipairs(workspace:GetDescendants()) do
            if model:IsA("Model") and (model.Name == "EnemyModel" or model.Name == "EnemyModels" or model.Name == "Enemy") then -- Added "Enemy"
                applyHighlight(model, Color3.fromRGB(255, 100, 100))
            end
        end
        
        -- ESP Box
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "BoxBottom" then
                applyHighlight(part, Color3.fromRGB(100, 255, 100))
            end
        end
        
        -- ESP Safe
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "Meshes/safe_Safe" then
                applyHighlight(part, Color3.fromRGB(255, 255, 0))
            end
        end
        
        -- ESP DollBlackHead
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "DollBlackHead" then
                applyHighlight(obj, Color3.fromRGB(35, 33, 126))
            end
        end
        
        -- ESP DollBlue
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "DollBlue" then
                applyHighlight(obj, Color3.fromRGB(59, 72, 255))
            end
        end
        
        -- ESP DollRed
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "DollRed" then
                applyHighlight(obj, Color3.fromRGB(177, 46, 46))
            end
        end

        -- ESP DollYellow
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "DollYellow" then
                applyHighlight(obj, Color3.fromRGB(210, 212, 52))
            end
        end

        -- ESP DollWhite
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "DollWhite" then
                applyHighlight(obj, Color3.fromRGB(255, 255, 255))
            end
        end

        -- ESP Key
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == "Key" then
                applyHighlight(obj, Color3.fromRGB(255, 215, 0))
            end
        end

        -- ESP Hint Paper
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == "HintPaper" then
                applyHighlight(obj, Color3.fromRGB(47, 231, 255))
            end
        end

        -- ESP DollHouseGimic
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "DollHouseGimic" then
                applyHighlight(obj, Color3.fromRGB(255, 192, 203))
            end
        end
    end
end

Toggle:OnChanged(function()
    if Toggle.Value then
        applyESP()
    else
        -- Remove all highlights when toggle is off
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                removeHighlight(obj)
            end
        end
    end
end)

-- Watch for new objects being added to workspace
workspace.DescendantAdded:Connect(function(obj)
    if Toggle.Value then
        if obj:IsA("Model") and (obj.Name == "EnemyModel" or obj.Name == "EnemyModels" or obj.Name == "Enemy") then -- Added "Enemy"
            applyHighlight(obj, Color3.fromRGB(255, 100, 100))
        elseif obj:IsA("BasePart") then
            if obj.Name == "BoxBottom" then
                applyHighlight(obj, Color3.fromRGB(100, 255, 100))
            elseif obj.Name == "Meshes/safe_Safe" then
                applyHighlight(obj, Color3.fromRGB(255, 0, 212))
            elseif obj.Name == "DollBlackHead" then
                applyHighlight(obj, Color3.fromRGB(23, 22, 77))
            elseif obj.Name == "DollBlue" then
                applyHighlight(obj, Color3.fromRGB(59, 72, 255))
            elseif obj.Name == "DollRed" then
                applyHighlight(obj, Color3.fromRGB(177, 46, 46))
            elseif obj.Name == "DollYellow" then
                applyHighlight(obj, Color3.fromRGB(210, 212, 52))
            elseif obj.Name == "DollWhite" then
                applyHighlight(obj, Color3.fromRGB(255, 255, 255))
            elseif obj.Name == "Key" then
                applyHighlight(obj, Color3.fromRGB(255, 215, 0))
            elseif obj.Name == "HintPaper" then
                applyHighlight(obj, Color3.fromRGB(80, 229, 255))
            end
        elseif obj:IsA("Model") and obj.Name == "DollHouseGimic" then
            applyHighlight(obj, Color3.fromRGB(255, 192, 203))
        end
    end
end)

local selectedSpeed = 16

-- Function to set walk speed
local function setWalkSpeed(speed)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = speed
    end
end

-- Create speed slider
local SpeedSlider = Tabs.Main:CreateSlider("SpeedSlider", {
    Title = "Walk Speed",
    Description = "Adjust your character's speed",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        selectedSpeed = Value
        setWalkSpeed(Value)
    end
})

-- Monitor character spawning
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    setWalkSpeed(selectedSpeed)
    
    -- Monitor WalkSpeed changes
    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if humanoid.WalkSpeed ~= selectedSpeed then
            humanoid.WalkSpeed = selectedSpeed
        end
    end)
end)

-- Initial setup for existing character
if game.Players.LocalPlayer.Character then
    local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        setWalkSpeed(selectedSpeed)
        humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if humanoid.WalkSpeed ~= selectedSpeed then
                humanoid.WalkSpeed = selectedSpeed
            end
        end)
    end
end

Tabs.Main:CreateParagraph("Info", {
    Title = "⚠️ Important Notes",
    Content = [[
- Speed will persist even when hiding or sprinting
- ESPs will automatically appear on new objects
- ESP Doll affects all dolls globally
    ]]
})

---
-- Stage 1 Auto Complete
Tabs.Main:CreateParagraph("Stage 1 Auto Complete", {
    Title = "Stage 1 Auto Complete",
    Content = "Automatically complete Stage 1 tasks"
})

Tabs.Main:CreateButton({
    Title = "Auto Complete Stage 1",
    Description = "Find key, take it, open ofuda box, take ofuda, and approach enemy",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        if not character or not rootPart then
            Library:Notify{
                Title = "Failed",
                Content = "Could not find player character. Please ensure you are spawned in.",
                Duration = 3
            }
            return
        end

        -- Function to interact with proximity prompt
        -- Enhanced to attempt interaction multiple times and check for successful pickup/opening
        local function interactWithPrompt(obj, itemType, maxAttempts)
            maxAttempts = maxAttempts or 5
            if not obj then return false end
            
            local prompt
            if obj:IsA("ProximityPrompt") then
                prompt = obj
            else
                prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                
                if not prompt then
                    for _, descendant in pairs(obj:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") then
                            prompt = descendant
                            break
                        end
                    end
                end
            end
            
            if prompt then
                local promptParent = prompt.Parent
                local promptPos = nil
                if promptParent:IsA("BasePart") then
                    promptPos = promptParent.Position
                else
                    local part = promptParent:FindFirstChildWhichIsA("BasePart")
                    if part then
                        promptPos = part.Position
                    end
                end
                
                if promptPos then
                    local distance = (rootPart.Position - promptPos).Magnitude
                    if distance > prompt.MaxActivationDistance then
                        rootPart.CFrame = CFrame.new(promptPos + Vector3.new(0, 2, 0))
                        task.wait(0.2)
                    end
                end

                for i = 1, maxAttempts do
                    fireproximityprompt(prompt)
                    task.wait(0.3) -- Small delay to allow game to process
                    
                    -- Check if item was picked up or box opened
                    if itemType == "key" then
                        -- Check if key is now in inventory or equipped
                        local success = player.Backpack:FindFirstChild("Key") or (character and character:FindFirstChild("Key"))
                        if success then return true end
                    elseif itemType == "ofudaBox" then
                        -- Check if OfudaBox2 is open (e.g., if it has a child named "Ofuda" or if it changes state)
                        local success = obj:FindFirstChild("Ofuda") or workspace.Server.SpawnedItems:FindFirstChild("Ofuda")
                        if success then return true end
                    elseif itemType == "ofuda" then
                        -- Check if Ofuda is now in inventory or equipped
                        local success = player.Backpack:FindFirstChild("Ofuda") or (character and character:FindFirstChild("Ofuda"))
                        if success then return true end
                    else
                        return true -- For generic prompts if no specific check is needed
                    end
                end
            end
            return false
        end
        
        -- Step 1: Find and teleport to key
        Library:Notify{
            Title = "Stage 1 Auto",
            Content = "Step 1: Finding and going to key...",
            Duration = 2
        }
        
        local key = workspace.Server.SpawnedItems:FindFirstChild("Key")
        if not key then
            Library:Notify{
                Title = "Failed",
                Content = "Could not find key.",
                Duration = 3
            }
            return
        end
        
        rootPart.CFrame = CFrame.new(key:GetPivot().Position + Vector3.new(0, 2, 0))
        task.wait(0.5)
        
        -- Step 2: Interact with key to pick it up
        Library:Notify{
            Title = "Stage 1 Auto",
            Content = "Step 2: Taking key...",
            Duration = 2
        }
        
        local keyPickedUp = interactWithPrompt(key, "key")
        if not keyPickedUp then
            Library:Notify{
                Title = "Failed",
                Content = "Failed to pick up key. Retrying manually or check for game updates.",
                Duration = 3
            }
            return
        end
        task.wait(0.5)
        
        -- Step 2.5: Equip the key (slot 1) - **Improved Logic**
        Library:Notify{
            Title = "Stage 1 Auto",
            Content = "Step 2.5: Equipping key (slot 1)...",
            Duration = 2
        }

        local keyInInventory = player.Backpack:FindFirstChild("Key")
        local keyEquipped = false
        if keyInInventory then
            keyInInventory.Parent = character -- Equip the key directly
            keyEquipped = true
            Library:Notify{
                Title = "Stage 1 Auto",
                Content = "Key equipped successfully!",
                Duration = 1
            }
        else
            -- Fallback: simulate pressing 1 if direct equip fails or key wasn't immediately picked up in Character
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.One, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.One, false, game)
            task.wait(0.5)
            -- Verify if key is now equipped
            keyEquipped = character:FindFirstChild("Key") ~= nil
            if not keyEquipped then
                Library:Notify{
                    Title = "Warning",
                    Content = "Could not confirm key equipped via slot 1. Proceeding anyway.",
                    Duration = 3
                }
            end
        end
        
        -- Step 3: Teleport to ofuda box
        Library:Notify{
            Title = "Stage 1 Auto",
            Content = "Step 3: Going to ofuda box...",
            Duration = 2
        }
        
        local ofudaBox = workspace.Server.SpawnedItems:FindFirstChild("OfudaBox2")
        if not ofudaBox then
            Library:Notify{
                Title = "Failed",
                Content = "Could not find ofuda box.",
                Duration = 3
            }
            return
        end
        
        local ofudaBoxPosition = ofudaBox:GetPivot().Position
        local frontPosition = ofudaBoxPosition + (ofudaBox:GetPivot().LookVector * -3) -- Position in front of the box
        rootPart.CFrame = CFrame.new(frontPosition, ofudaBoxPosition)
        task.wait(0.5)
            
        -- Step 4: Open the ofuda box
        Library:Notify{
            Title = "Stage 1 Auto",
            Content = "Step 4: Opening ofuda box...",
            Duration = 2
        }
        
        local boxOpened = interactWithPrompt(ofudaBox, "ofudaBox")
        if not boxOpened then
            Library:Notify{
                Title = "Failed",
                Content = "Failed to open ofuda box. Ensure key is equipped and you are close.",
                Duration = 3
            }
            return
        end
        task.wait(1.0) -- Wait for box to fully open and ofuda to spawn
        
        -- Step 5: Look for ofuda and pick it up
        Library:Notify{
            Title = "Stage 1 Auto",
            Content = "Step 5: Looking for and picking up ofuda...",
            Duration = 2
        }
        
        local ofudaItem = nil
        local maxOfudaAttempts = 10
        for attempt = 1, maxOfudaAttempts do
            ofudaItem = workspace.Server.SpawnedItems:FindFirstChild("Ofuda") or
                                     workspace.Server.SpawnedItems:FindFirstChild("Ofuda Onya") or
                                     workspace.Server.SpawnedItems:FindFirstChild("Talisman")

            if not ofudaItem then
                -- Broad search for any item containing "ofuda" or "talisman" in its name or its descendants
                for _, item in pairs(workspace.Server.SpawnedItems:GetChildren()) do
                    if string.match(item.Name:lower(), "ofuda") or string.match(item.Name:lower(), "talisman") then
                        ofudaItem = item
                        break
                    end
                end
            end

            if ofudaItem then break end
            task.wait(0.2) -- Small delay before retrying
        end
        
        if not ofudaItem then
            Library:Notify{
                Title = "Failed",
                Content = "Could not find Ofuda after opening box.",
                Duration = 3
            }
            return
        end

        -- Teleport directly to ofuda to ensure reliable pickup
        rootPart.CFrame = CFrame.new(ofudaItem:GetPivot().Position + Vector3.new(0, 2, 0))
        task.wait(0.3)

        local ofudaPickedUp = interactWithPrompt(ofudaItem, "ofuda")
        if not ofudaPickedUp then
            Library:Notify{
                Title = "Failed",
                Content = "Failed to pick up Ofuda.",
                Duration = 3
            }
            return
        end
        task.wait(0.5)

        -- Step 6: Equip the ofuda (slot 1) - **Improved Logic**
        Library:Notify{
            Title = "Stage 1 Auto",
            Content = "Step 6: Equipping ofuda (slot 1)...",
            Duration = 2
        }
        local ofudaInInventory = player.Backpack:FindFirstChildOfClass("Tool", function(tool)
            return string.match(tool.Name:lower(), "ofuda") or string.match(tool.Name:lower(), "talisman")
        end)
        local ofudaEquipped = false

        if ofudaInInventory then
            ofudaInInventory.Parent = character -- Equip the ofuda directly
            ofudaEquipped = true
            Library:Notify{
                Title = "Stage 1 Auto",
                Content = "Ofuda equipped successfully!",
                Duration = 1
            }
        else
            -- Fallback: simulate pressing 1 if direct equip fails
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.One, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.One, false, game)
            task.wait(0.5)
            -- Verify if ofuda is now equipped
            ofudaEquipped = character:FindFirstChildOfClass("Tool", function(tool)
                return string.match(tool.Name:lower(), "ofuda") or string.match(tool.Name:lower(), "talisman")
            end) ~= nil
            if not ofudaEquipped then
                Library:Notify{
                    Title = "Warning",
                    Content = "Could not confirm Ofuda equipped via slot 1. Proceeding anyway.",
                    Duration = 3
                }
            end
        end

        if ofudaEquipped then
            Library:Notify{
                Title = "Stage 1 Auto",
                Content = "Stage 1 Auto Complete: **Success!** Key and Ofuda secured.",
                Duration = 5
            }
        else
            Library:Notify{
                Title = "Stage 1 Auto",
                Content = "Stage 1 Auto Complete: Finished steps, but Ofuda might not be equipped.",
                Duration = 5
            }
        end
    end
})

---
-- Stage 2/3 Auto Complete
Tabs.Main:CreateParagraph("Stage 2/3 Auto Complete", {
    Title = "Stage 2/3 Auto Complete",
    Content = "Automatically complete Stage 2/3 tasks"
})

Tabs.Main:CreateButton({
    Title = "Auto Complete Stage 2/3",
    Description = "Teleport to safe, open vault, get key and go to ofuda box",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        if not character or not rootPart then
            Library:Notify{
                Title = "Failed",
                Content = "Could not find player character. Please ensure you are spawned in.",
                Duration = 3
            }
            return
        end

        -- Function to interact with proximity prompt (re-defined for local scope with success check)
        local function interactWithPrompt(obj, itemType, maxAttempts)
            maxAttempts = maxAttempts or 5
            if not obj then return false end
            
            local prompt
            if obj:IsA("ProximityPrompt") then
                prompt = obj
            else
                prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                
                if not prompt then
                    for _, descendant in pairs(obj:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") then
                            prompt = descendant
                            break
                        end
                    end
                end
            end
            
            if prompt then
                local promptParent = prompt.Parent
                local promptPos = nil
                if promptParent:IsA("BasePart") then
                    promptPos = promptParent.Position
                else
                    local part = promptParent:FindFirstChildWhichIsA("BasePart")
                    if part then
                        promptPos = part.Position
                    end
                end
                
                if promptPos then
                    local distance = (rootPart.Position - promptPos).Magnitude
                    if distance > prompt.MaxActivationDistance then
                        rootPart.CFrame = CFrame.new(promptPos + Vector3.new(0, 2, 0))
                        task.wait(0.2)
                    end
                end

                for i = 1, maxAttempts do
                    fireproximityprompt(prompt)
                    task.wait(0.3) -- Small delay to allow game to process
                    
                    -- Check for specific outcomes
                    if itemType == "key" then
                        local success = player.Backpack:FindFirstChild("Key") or (character and character:FindFirstChild("Key"))
                        if success then return true end
                    elseif itemType == "safe" then
                        -- Check if safe is opened (this might need to be more specific based on game's mechanics)
                        local success = obj:FindFirstChild("Open") and obj.Open.Value == true or -- Example: if safe has a BoolValue named "Open"
                                                 (obj:FindFirstChildOfClass("ProximityPrompt") == nil) -- Or if the prompt disappears
                        if success then return true end
                    elseif itemType == "ofudaBox" then
                        local success = obj:FindFirstChild("Ofuda") or workspace.Server.SpawnedItems:FindFirstChild("Ofuda")
                        if success then return true end
                    elseif itemType == "ofuda" then
                        local success = player.Backpack:FindFirstChildOfClass("Tool", function(tool) return string.match(tool.Name:lower(), "ofuda") or string.match(tool.Name:lower(), "talisman") end)
                        if success then return true end
                    else
                        return true -- For generic prompts if no specific check is needed
                    end
                end
            end
            return false
        end

        -- Step 1: Find and teleport to safe
        Library:Notify{
            Title = "Stage 2/3 Auto",
            Content = "Step 1: Finding safe...",
            Duration = 2
        }
        
        local safe = nil
        -- Search for Safe in all rooms or directly in workspace
        for _, room in pairs(workspace.Server.MapGenerated.Rooms:GetChildren()) do
            if room:FindFirstChild("Props") then
                local safeInRoom = room.Props:FindFirstChild("Safe")
                if safeInRoom then
                    safe = safeInRoom
                    break
                end
            end
        end
        
        if not safe then
            safe = workspace:FindFirstChild("Safe", true) -- Broader search as fallback
        end

        if not safe then
            Library:Notify{
                Title = "Failed",
                Content = "Could not find safe in any room.",
                Duration = 3
            }
            return
        end
        
        local safePosition
        if typeof(safe.GetPivot) == "function" then
            safePosition = safe:GetPivot().Position
        else
            local part = safe:FindFirstChildOfClass("BasePart") or safe.PrimaryPart
            if part then
                safePosition = part.Position
            else
                for _, child in pairs(safe:GetDescendants()) do
                    if child:IsA("BasePart") then
                        safePosition = child.Position
                        break
                    end
                end
            end
        end
        
        if not safePosition then
            Library:Notify{
                Title = "Failed",
                Content = "Could not determine safe position.",
                Duration = 3
            }
            return
        end
        
        -- Teleport in front of the safe
        rootPart.CFrame = CFrame.new(safePosition + Vector3.new(0, 1, 2), safePosition)
        task.wait(0.5)
        
        -- Step 2: Unlock the safe (assuming a BoolValue named "Unlocked")
        Library:Notify{
            Title = "Stage 2/3 Auto",
            Content = "Step 2: Unlocking safe...",
            Duration = 2
        }
        
        local unlockedValue = safe:FindFirstChild("Unlocked")
        if unlockedValue and unlockedValue:IsA("BoolValue") then
            unlockedValue.Value = true
            task.wait(0.5)
            Library:Notify{
                Title = "Stage 2/3 Auto",
                Content = "Safe 'Unlocked' value set to true.",
                Duration = 1
            }
        else
            Library:Notify{
                Title = "Warning",
                Content = "Could not find 'Unlocked' BoolValue in safe. Attempting to open via prompt.",
                Duration = 2
            }
        end
        
        -- Step 3: Interact with safe to open it
        Library:Notify{
            Title = "Stage 2/3 Auto",
            Content = "Step 3: Opening safe...",
            Duration = 2
        }
        
        local safeOpened = interactWithPrompt(safe, "safe")
        if not safeOpened then
            Library:Notify{
                Title = "Failed",
                Content = "Failed to open safe. Check if key is required or game mechanics changed.",
                Duration = 3
            }
            return
        end
        task.wait(1.0) -- Wait for safe to fully open and items to appear
        
        -- Step 4: Look for key inside safe
        Library:Notify{
            Title = "Stage 2/3 Auto",
            Content = "Step 4: Checking for key...",
            Duration = 2
        }
        
        local key = nil
        local maxKeyAttempts = 5
        for attempt = 1, maxKeyAttempts do
            key = workspace.Server.SpawnedItems:FindFirstChild("Key")
            if not key then
                -- Try finding key inside the safe model directly
                key = safe:FindFirstChild("Key", true)
            end
            if key then break end
            task.wait(0.2)
        end
        
        if not key then
            Library:Notify{
                Title = "Warning",
                Content = "Could not find key after opening safe. Proceeding to ofuda box.",
                Duration = 3
            }
        else
            -- Step 5: If key found, grab it and equip it
            Library:Notify{
                Title = "Stage 2/3 Auto",
                Content = "Step 5: Taking key...",
                Duration = 2
            }
            
            rootPart.CFrame = CFrame.new(key:GetPivot().Position + Vector3.new(0, 2, 0), key:GetPivot().Position)
            task.wait(0.5)
            
            local keyPickedUp = interactWithPrompt(key, "key")
            if not keyPickedUp then
                Library:Notify{
                    Title = "Warning",
                    Content = "Failed to pick up key. Manual pickup might be needed.",
                    Duration = 3
                }
            else
                task.wait(0.5)
                -- Equip the key directly
                local keyInInventory = player.Backpack:FindFirstChild("Key")
                if keyInInventory then
                    keyInInventory.Parent = character
                    Library:Notify{
                        Title = "Stage 2/3 Auto",
                        Content = "Key equipped successfully!",
                        Duration = 1
                    }
                else
                    -- Fallback to key press if direct parent change fails
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.One, false, game)
                    task.wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.One, false, game)
                    task.wait(0.5)
                    if not character:FindFirstChild("Key") then
                        Library:Notify{
                            Title = "Warning",
                            Content = "Could not confirm key equipped. Proceeding anyway.",
                            Duration = 2
                        }
                    end
                end
            end
        end
        
        -- Step 6: Teleport to ofuda box
        Library:Notify{
            Title = "Stage 2/3 Auto",
            Content = "Step 6: Going to ofuda box...",
            Duration = 2
        }
        
        local ofudaBox = workspace.Server.SpawnedItems:FindFirstChild("OfudaBox2")
        if not ofudaBox then
            Library:Notify{
                Title = "Failed",
                Content = "Could not find ofuda box.",
                Duration = 3
            }
            return
        end
        
        local ofudaBoxPosition
        if typeof(ofudaBox.GetPivot) == "function" then
            ofudaBoxPosition = ofudaBox:GetPivot().Position
        else
            local part = ofudaBox:FindFirstChildOfClass("BasePart") or ofudaBox.PrimaryPart
            if part then
                ofudaBoxPosition = part.Position
            else
                for _, child in pairs(ofudaBox:GetDescendants()) do
                    if child:IsA("BasePart") then
                        ofudaBoxPosition = child.Position
                        break
                    end
                end
            end
        end
        
        if not ofudaBoxPosition then
            Library:Notify{
                Title = "Warning",
                Content = "Could not determine ofuda box position.",
                Duration = 3
            }
            return
        end
        
        local frontPosition = ofudaBoxPosition + Vector3.new(0, 0, -3) -- Position in front of the ofuda box
        rootPart.CFrame = CFrame.new(frontPosition, ofudaBoxPosition)
        task.wait(0.5)
            
        -- Step 7: Open the ofuda box
        Library:Notify{
            Title = "Stage 2/3 Auto",
            Content = "Step 7: Opening ofuda box...",
            Duration = 2
        }
        
        local boxOpenedAgain = interactWithPrompt(ofudaBox, "ofudaBox")
        if not boxOpenedAgain then
            Library:Notify{
                Title = "Warning",
                Content = "Failed to re-open ofuda box. Manual interaction might be needed.",
                Duration = 3
            }
        end
        task.wait(1.0) -- Wait for ofuda to be available
        
        -- Step 8: Look for ofuda and pick it up
        Library:Notify{
            Title = "Stage 2/3 Auto",
            Content = "Step 8: Looking for and picking up ofuda...",
            Duration = 2
        }
        
        local ofudaItem = nil
        local maxOfudaPickupAttempts = 10
        for attempt = 1, maxOfudaPickupAttempts do
            ofudaItem = workspace.Server.SpawnedItems:FindFirstChild("Ofuda") or
                                     workspace.Server.SpawnedItems:FindFirstChild("Ofuda Onya") or
                                     workspace.Server.SpawnedItems:FindFirstChild("Talisman")
            if not ofudaItem then
                for _, item in pairs(workspace.Server.SpawnedItems:GetChildren()) do
                    if string.match(item.Name:lower(), "ofuda") or string.match(item.Name:lower(), "talisman") then
                        ofudaItem = item
                        break
                    end
                end
            end
            if ofudaItem then break end
            task.wait(0.2)
        end
        
        if not ofudaItem then
            Library:Notify{
                Title = "Failed",
                Content = "Could not find Ofuda after opening box.",
                Duration = 3
            }
            return
        end

        rootPart.CFrame = CFrame.new(ofudaItem:GetPivot().Position + Vector3.new(0, 2, 0), ofudaItem:GetPivot().Position)
        task.wait(0.3)
        
        local ofudaPickedUp = interactWithPrompt(ofudaItem, "ofuda")
        if not ofudaPickedUp then
            Library:Notify{
                Title = "Failed",
                Content = "Failed to pick up Ofuda.",
                Duration = 3
            }
            return
        end
        task.wait(0.5)
        
        -- Step 9: Equip the ofuda
        Library:Notify{
            Title = "Stage 2/3 Auto",
            Content = "Step 9: Equipping ofuda...",
            Duration = 2
        }
        
        local ofudaInInventory = player.Backpack:FindFirstChildOfClass("Tool", function(tool)
            return string.match(tool.Name:lower(), "ofuda") or string.match(tool.Name:lower(), "talisman")
        end)
        local ofudaEquipped = false

        if ofudaInInventory then
            ofudaInInventory.Parent = character
            ofudaEquipped = true
            Library:Notify{
                Title = "Stage 2/3 Auto",
                Content = "Ofuda equipped successfully!",
                Duration = 1
            }
        else
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.One, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.One, false, game)
            task.wait(0.5)
            ofudaEquipped = character:FindFirstChildOfClass("Tool", function(tool)
                return string.match(tool.Name:lower(), "ofuda") or string.match(tool.Name:lower(), "talisman")
            end) ~= nil
            if not ofudaEquipped then
                Library:Notify{
                    Title = "Warning",
                    Content = "Could not confirm Ofuda equipped. Manual equip might be needed.",
                    Duration = 2
                }
            end
        end

        Library:Notify{
            Title = "Stage 2/3 Auto",
            Content = "Stage 2/3 Auto Complete: **Sequence Finished!**",
            Duration = 5
        }
    end
})

-- Add a dedicated button just for taking ofuda
Tabs.Main:CreateButton({
    Title = "Take Ofuda Only",
    Description = "Teleport to ofuda box, open it, and take ofuda",
    Callback = function()
        -- Function to interact with proximity prompt
        local function interactWithPrompt(obj, itemType, maxAttempts)
            maxAttempts = maxAttempts or 5
            if not obj then return false end
            
            local prompt
            if obj:IsA("ProximityPrompt") then
                prompt = obj
            else
                prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                
                if not prompt then
                    -- Search deeper in descendants
                    for _, descendant in pairs(obj:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") then
                            prompt = descendant
                            break
                        end
                    end
                end
            end
            
            if prompt then
                -- Make sure we're close enough to interact
                local character = game.Players.LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                
                if rootPart then
                    -- Get prompt parent position
                    local promptParent = prompt.Parent
                    local promptPos
                    
                    if promptParent:IsA("BasePart") then
                        promptPos = promptParent.Position
                    else
                        local part = promptParent:FindFirstChildWhichIsA("BasePart")
                        if part then
                            promptPos = part.Position
                        end
                    end
                    
                    if promptPos then
                        -- Teleport close to the prompt if needed
                        local distance = (rootPart.Position - promptPos).Magnitude
                        if distance > prompt.MaxActivationDistance then
                            rootPart.CFrame = CFrame.new(promptPos + Vector3.new(0, 2, 0))
                            task.wait(0.2) -- Small delay after teleport
                        end
                    end
                end
                
                -- Fire the prompt and check for success based on itemType
                for i = 1, maxAttempts do
                    fireproximityprompt(prompt)
                    task.wait(0.3)

                    if itemType == "ofudaBox" then
                        local success = obj:FindFirstChild("Ofuda") or workspace.Server.SpawnedItems:FindFirstChild("Ofuda")
                        if success then return true end
                    elseif itemType == "ofuda" then
                        local success = game.Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool", function(tool)
                            return string.match(tool.Name:lower(), "ofuda") or string.match(tool.Name:lower(), "talisman")
                        end)
                        if success then return true end
                    else
                        return true -- For generic prompts
                    end
                end
            end
            
            return false
        end

        local character = game.Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            Library:Notify{
                Title = "Failed",
                Content = "Could not find player character",
                Duration = 3
            }
            return
        end
        
        -- Step 1: Teleport to ofuda box
        Library:Notify{
            Title = "Ofuda Take",
            Content = "Step 1: Going to ofuda box...",
            Duration = 2
        }
        
        local ofudaBox = workspace.Server.SpawnedItems:FindFirstChild("OfudaBox2")
        if not ofudaBox then
            Library:Notify{
                Title = "Failed",
                Content = "Could not find ofuda box",
                Duration = 3
            }
            return
        end
        
        -- Get ofuda box position for teleport
        local ofudaBoxPosition
        
        if typeof(ofudaBox.GetPivot) == "function" then
            ofudaBoxPosition = ofudaBox:GetPivot().Position
        elseif ofudaBox:IsA("BasePart") then
            ofudaBoxPosition = ofudaBox.Position
        else
            -- Try to find a part to use as reference
            for _, child in pairs(ofudaBox:GetDescendants()) do
                if child:IsA("BasePart") then
                    ofudaBoxPosition = child.Position
                    break
                end
            end
        end
        
        if ofudaBoxPosition then
            -- Position in front of the ofuda box at a reasonable distance
            local frontPosition = ofudaBoxPosition + Vector3.new(0, 0, -3)
            
            -- Teleport to position, facing the box
            rootPart.CFrame = CFrame.new(frontPosition, ofudaBoxPosition)
            
            -- Add small delay before interaction
            task.wait(0.5)
            
            -- Try to open the box
            Library:Notify{
                Title = "Ofuda Take",
                Content = "Step 2: Opening ofuda box...",
                Duration = 2
            }
            
            local boxOpened = interactWithPrompt(ofudaBox, "ofudaBox")
            if not boxOpened then
                Library:Notify{
                    Title = "Failed",
                    Content = "Failed to open ofuda box.",
                    Duration = 3
                }
                return
            end
            task.wait(1.0) -- Wait for box to open
            
            -- Step 3: Wait for ofuda to be available and take it
            Library:Notify{
                Title = "Ofuda Take",
                Content = "Step 3: Looking for ofuda...",
                Duration = 2
            }
            
            local ofudaItem = nil
            local maxOfudaAttempts = 10
            for attempt = 1, maxOfudaAttempts do
                ofudaItem = workspace.Server.SpawnedItems:FindFirstChild("Ofuda") or
                                     workspace.Server.SpawnedItems:FindFirstChild("Ofuda Onya") or
                                     workspace.Server.SpawnedItems:FindFirstChild("Talisman")
                if not ofudaItem then
                    for _, item in pairs(workspace.Server.SpawnedItems:GetChildren()) do
                        if string.match(item.Name:lower(), "ofuda") or string.match(item.Name:lower(), "talisman") then
                            ofudaItem = item
                            break
                        end
                    end
                end
                if ofudaItem then break end
                task.wait(0.2)
            end
            
            if not ofudaItem then
                Library:Notify{
                    Title = "Failed",
                    Content = "Could not find Ofuda after opening box.",
                    Duration = 3
                }
                return
            end
            
            -- Teleport directly to ofuda to ensure we can pick it up
            rootPart.CFrame = CFrame.new(ofudaItem:GetPivot().Position + Vector3.new(0, 2, 0), ofudaItem:GetPivot().Position)
            task.wait(0.3)
            
            local ofudaPickedUp = interactWithPrompt(ofudaItem, "ofuda")
            if not ofudaPickedUp then
                Library:Notify{
                    Title = "Failed",
                    Content = "Failed to pick up Ofuda.",
                    Duration = 3
                }
                return
            end
            task.wait(0.5)
            
            -- Step 4: Equip the ofuda (slot 1)
            Library:Notify{
                Title = "Ofuda Take",
                Content = "Step 4: Equipping ofuda...",
                Duration = 2
            }
            
            local ofudaInInventory = game.Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool", function(tool)
                return string.match(tool.Name:lower(), "ofuda") or string.match(tool.Name:lower(), "talisman")
            end)
            local ofudaEquipped = false

            if ofudaInInventory then
                ofudaInInventory.Parent = character
                ofudaEquipped = true
                Library:Notify{
                    Title = "Ofuda Take",
                    Content = "Ofuda equipped successfully!",
                    Duration = 1
                }
            else
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.One, false, game)
                task.wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.One, false, game)
                task.wait(0.5)
                ofudaEquipped = character:FindFirstChildOfClass("Tool", function(tool)
                    return string.match(tool.Name:lower(), "ofuda") or string.match(tool.Name:lower(), "talisman")
                end) ~= nil
                if not ofudaEquipped then
                    Library:Notify{
                        Title = "Warning",
                        Content = "Could not confirm Ofuda equipped. Manual equip might be needed.",
                        Duration = 2
                    }
                end
            end
            
            Library:Notify{
                Title = "Success",
                Content = "Successfully retrieved and equipped ofuda!",
                Duration = 3
            }
        else
            Library:Notify{
                Title = "Warning",
                Content = "Could not determine ofuda box position",
                Duration = 3
            }
        end
    end
})

---
-- Stage 4 Finisher
Tabs.Main:CreateParagraph("Stage 4 Finisher", {
    Title = "Stage 4 Finisher",
    Content = "Tools to help complete Stage 4"
})

-- Improved teleport function that places character in front of object
Tabs.Main:CreateButton({
    Title = "Move to Doll Room (Front)",
    Description = "Teleports you in front of the doll house",
    Callback = function()
        -- Cari DollHouseGimic di lokasi yang tepat berdasarkan screenshot
        local dollHouse = workspace.Server.MapGenerated.Rooms.Room:FindFirstChild("DollHouseGimic")
        
        if not dollHouse then
            -- Fallback: coba cari di semua Room
            for _, room in pairs(workspace.Server.MapGenerated.Rooms:GetChildren()) do
                if room:FindFirstChild("DollHouseGimic") then
                    dollHouse = room.DollHouseGimic
                    break
                end
            end
        end
        
        if dollHouse and game.Players.LocalPlayer.Character then
            local rootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- Get the position and orientation of the doll house
                local dollCFrame
                
                if typeof(dollHouse.GetPivot) == "function" then
                    dollCFrame = dollHouse:GetPivot()
                elseif dollHouse:IsA("BasePart") then
                    dollCFrame = dollHouse.CFrame
                elseif dollHouse:IsA("Model") then
                    local primaryPart = dollHouse.PrimaryPart
                    if primaryPart then
                        dollCFrame = primaryPart.CFrame
                    else
                        -- Try to find a part to use as reference
                        for _, child in pairs(dollHouse:GetChildren()) do
                            if child:IsA("BasePart") then
                                dollCFrame = child.CFrame
                                break
                            end
                        end
                    end
                end
                
                if dollCFrame then
                    -- Position character 10 studs in front of the doll house
                    local frontOffset = dollCFrame.LookVector * 10
                    local teleportCFrame = dollCFrame + frontOffset
                    
                    -- Make sure character is looking at the doll house
                    teleportCFrame = CFrame.new(teleportCFrame.Position, dollCFrame.Position)
                    
                    -- Teleport
                    rootPart.CFrame = teleportCFrame
                    
                    Library:Notify{
                        Title = "Teleported",
                        Content = "Successfully teleported in front of doll house",
                        Duration = 3
                    }
                else
                    Library:Notify{
                        Title = "Teleport Failed",
                        Content = "Could not determine doll house position",
                        Duration = 3
                    }
                end
            end
        else
            Library:Notify{
                Title = "Teleport Failed",
                Content = "Could not find DollHouseGimic in Server/MapGenerated/Rooms",
                Duration = 3
            }
        end
    end
})

-- Improved teleport function that places character behind of object
Tabs.Main:CreateButton({
    Title = "Move to Doll Room (Back)",
    Description = "Teleports you behind the doll house",
    Callback = function()
        -- Cari DollHouseGimic di lokasi yang tepat berdasarkan screenshot
        local dollHouse = workspace.Server.MapGenerated.Rooms.Room:FindFirstChild("DollHouseGimic")
        
        if not dollHouse then
            -- Fallback: coba cari di semua Room
            for _, room in pairs(workspace.Server.MapGenerated.Rooms:GetChildren()) do
                if room:FindFirstChild("DollHouseGimic") then
                    dollHouse = room.DollHouseGimic
                    break
                end
            end
        end
        
        if dollHouse and game.Players.LocalPlayer.Character then
            local rootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- Get the position and orientation of the doll house
                local dollCFrame
                
                if typeof(dollHouse.GetPivot) == "function" then
                    dollCFrame = dollHouse:GetPivot()
                elseif dollHouse:IsA("BasePart") then
                    dollCFrame = dollHouse.CFrame
                elseif dollHouse:IsA("Model") then
                    local primaryPart = dollHouse.PrimaryPart
                    if primaryPart then
                        dollCFrame = primaryPart.CFrame
                    else
                        -- Try to find a part to use as reference
                        for _, child in pairs(dollHouse:GetChildren()) do
                            if child:IsA("BasePart") then
                                dollCFrame = child.CFrame
                                break
                            end
                        end
                    end
                end
                
                if dollCFrame then
                    -- Position character 10 studs behind the doll house
                    local backOffset = dollCFrame.LookVector * -10
                    local teleportCFrame = dollCFrame + backOffset
                    
                    -- Make sure character is looking at the doll house
                    teleportCFrame = CFrame.new(teleportCFrame.Position, dollCFrame.Position)
                    
                    -- Teleport
                    rootPart.CFrame = teleportCFrame
                    
                    Library:Notify{
                        Title = "Teleported",
                        Content = "Successfully teleported behind doll house",
                        Duration = 3
                    }
                else
                    Library:Notify{
                        Title = "Teleport Failed",
                        Content = "Could not determine doll house position",
                        Duration = 3
                    }
                end
            end
        else
            Library:Notify{
                Title = "Teleport Failed",
                Content = "Could not find DollHouseGimic in Server/MapGenerated/Rooms",
                Duration = 3
            }
        end
    end
})

Tabs.Main:CreateButton({
    Title = "Auto Set All Dolls",
    Description = "Sets all dolls as completed",
    Callback = function()
        -- Path yang benar ke Stage4 berdasarkan informasi user
        local stage4Path = game:GetService("ReplicatedStorage").GameStatus.Stage4
        
        -- Daftar semua nilai yang perlu diatur untuk setiap doll
        local dollSettings = {
            -- Format: [nama doll] = {daftar nilai yang perlu diset}
            ["DollBlack"] = {"Finished", "Installed", "Obtained", "HeadConnect", "HeadObtained"},
            ["DollBlue"] = {"Finished", "Installed", "Obtained"},
            ["DollWhite"] = {"Finished", "Installed", "Obtained"},
            ["DollRed"] = {"Finished", "Installed", "Obtained"},
            ["DollYellow"] = {"Finished", "Installed", "Obtained"}
        }
        
        local totalValues = 0
        local successCount = 0
        
        -- Fungsi untuk mengatur nilai
        local function setValue(name, value)
            totalValues = totalValues + 1
            local boolValue = stage4Path:FindFirstChild(name)
            if boolValue and boolValue:IsA("BoolValue") then
                boolValue.Value = true
                successCount = successCount + 1
                return true
            end
            return false
        end
        
        -- Mengatur semua nilai untuk setiap doll
        for dollName, valueTypes in pairs(dollSettings) do
            for _, valueType in ipairs(valueTypes) do
                local fullName
                if valueType == "HeadConnect" or valueType == "HeadObtained" then
                    fullName = dollName .. valueType
                else
                    fullName = dollName .. valueType
                end
                setValue(fullName, true)
            end
        end
        
        -- Mengatur DollAllSet juga
        setValue("DollAllSet", true)
        
        Library:Notify{
            Title = "Doll Status",
            Content = "Set " .. successCount .. "/" .. totalValues .. " doll values",
            Duration = 3
        }
    end
})

Tabs.Main:CreateButton({
    Title = "Finish",
    Description = "Completes the doll sequence",
    Callback = function()
        -- Path yang benar ke Stage4 berdasarkan informasi user
        local stage4Path = game:GetService("ReplicatedStorage").GameStatus.Stage4
        local dollAllSet = stage4Path:FindFirstChild("DollAllSet")
        
        if dollAllSet and dollAllSet:IsA("BoolValue") then
            dollAllSet.Value = true
            
            Library:Notify{
                Title = "Success",
                Content = "Successfully completed doll sequence",
                Duration = 3
            }
        else
            Library:Notify{
                Title = "Failed",
                Content = "Could not find DollAllSet value",
                Duration = 3
            }
        end
    end
})

-- Button to auto-unlock safes
Tabs.Main:CreateButton({
    Title = "Unlock All Safes",
    Description = "Unlocks all vault safes in the game",
    Callback = function()
        local unlockCount = 0
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "Safe" and obj:FindFirstChild("Unlocked") and obj.Unlocked:IsA("BoolValue") then
                obj.Unlocked.Value = true
                unlockCount = unlockCount + 1
            end
        end
        
        Library:Notify{
            Title = "Safe Unlocking",
            Content = "Attempted to unlock " .. unlockCount .. " safes",
            Duration = 3
        }
    end
})

---
-- Stage 5 Finisher
Tabs.Main:CreateParagraph("Stage 5 Finisher", {
    Title = "Stage 5 Finisher",
    Content = "Tools to help complete Stage 5"
})

Tabs.Main:CreateButton({
    Title = "Complete Stage 5",
    Description = "Sets all Stage 5 values to complete the stage",
    Callback = function()
        -- Path ke Stage5
        local stage5Path = game:GetService("ReplicatedStorage").GameStatus.Stage5
        
        -- Daftar nilai yang perlu diatur berdasarkan gambar
        local valuesToSet = {
            "DialOpened",
            "DishInstalled",
            "DishObtained",
            "LighterInstalled",
            "LighterObtained",
            "RopeInstalled",
            "RopeObtained",
            "StageEnd"
        }
        
        local totalValues = #valuesToSet
        local successCount = 0
        
        -- Mengatur semua nilai ke true
        for _, valueName in ipairs(valuesToSet) do
            local boolValue = stage5Path:FindFirstChild(valueName)
            if boolValue and boolValue:IsA("BoolValue") then
                boolValue.Value = true
                successCount = successCount + 1
            end
        end
        
        Library:Notify{
            Title = "Stage 5 Status",
            Content = "Set " .. successCount .. "/" .. totalValues .. " stage values",
            Duration = 3
        }
    end
})

---
-- Stage 6 Finisher
Tabs.Main:CreateParagraph("Stage 6 Finisher", {
    Title = "Stage 6 Finisher",
    Content = "Tools to help complete Stage 6"
})

Tabs.Main:CreateButton({
    Title = "Teleport to Finish",
    Description = "Teleports you to the ShoeRack at the finish",
    Callback = function()
        -- Mencari ShoeRack di path yang diberikan
        local shoeRack = workspace.Server.MapCore._1stFloor["1st_6"].Entrance:FindFirstChild("ShoeRack")
        
        if shoeRack and game.Players.LocalPlayer.Character then
            local rootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- Get the position and orientation of the shoe rack
                local shoeRackCFrame
                
                if typeof(shoeRack.GetPivot) == "function" then
                    shoeRackCFrame = shoeRack:GetPivot()
                elseif shoeRack:IsA("BasePart") then
                    shoeRackCFrame = shoeRack.CFrame
                elseif shoeRack:IsA("Model") then
                    local primaryPart = shoeRack.PrimaryPart
                    if primaryPart then
                        shoeRackCFrame = primaryPart.CFrame
                    else
                        -- Try to find a part to use as reference
                        for _, child in pairs(shoeRack:GetChildren()) do
                            if child:IsA("BasePart") then
                                shoeRackCFrame = child.CFrame
                                break
                            end
                        end
                    end
                end
                
                if shoeRackCFrame then
                    -- Position character 5 studs BEHIND the shoe rack
                    local backOffset = shoeRackCFrame.LookVector * -5
                    local teleportCFrame = shoeRackCFrame + backOffset
                    
                    -- Make sure character is looking at the shoe rack
                    teleportCFrame = CFrame.new(teleportCFrame.Position, shoeRackCFrame.Position)
                    
                    -- Teleport
                    rootPart.CFrame = teleportCFrame
                    
                    Library:Notify{
                        Title = "Teleported",
                        Content = "Successfully teleported behind ShoeRack",
                        Duration = 3
                    }
                else
                    Library:Notify{
                        Title = "Teleport Failed",
                        Content = "Could not determine ShoeRack position",
                        Duration = 3
                    }
                end
            end
        else
            Library:Notify{
                Title = "Teleport Failed",
                Content = "Could not find ShoeRack at specified path",
                Duration = 3
            }
        end
    end
})

---
-- Teleport Options
Tabs.Main:CreateParagraph("Teleport Options", {
    Title = "Teleport Options",
    Content = "Teleport to important items and locations"
})

-- Teleport to Key
Tabs.Main:CreateButton({
    Title = "Teleport to Key",
    Description = "Teleports you to the key location",
    Callback = function()
        local key = workspace.Server.SpawnedItems:FindFirstChild("Key")
        
        if key and game.Players.LocalPlayer.Character then
            local rootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- Teleport slightly above the key to avoid getting stuck and face it
                local keyPosition = key:GetPivot().Position
                rootPart.CFrame = CFrame.new(keyPosition + Vector3.new(0, 3, 0), keyPosition)
                
                Library:Notify{
                    Title = "Teleported",
                    Content = "Successfully teleported to key",
                    Duration = 3
                }
            end
        else
            Library:Notify{
                Title = "Teleport Failed",
                Content = "Could not find key in SpawnedItems",
                Duration = 3
            }
        end
    end
})

-- Teleport to Safe
Tabs.Main:CreateButton({
    Title = "Teleport to Safe",
    Description = "Teleports you to the safe location",
    Callback = function()
        local safe = nil
        
        -- Search for Safe in all rooms
        for _, room in pairs(workspace.Server.MapGenerated.Rooms:GetChildren()) do
            if room:FindFirstChild("Props") then
                local safeInRoom = room.Props:FindFirstChild("Safe")
                if safeInRoom then
                    safe = safeInRoom
                    break
                end
            end
        end
        
        if safe and game.Players.LocalPlayer.Character then
            local rootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- Get safe position
                local safePosition
                
                if typeof(safe.GetPivot) == "function" then
                    safePosition = safe:GetPivot().Position
                else
                    -- Try to find a part to use as reference
                    for _, child in pairs(safe:GetDescendants()) do
                        if child:IsA("BasePart") then
                            safePosition = child.Position
                            break
                        end
                        -- Check for Models and find a primary part within them
                        if child:IsA("Model") and child.PrimaryPart then
                            safePosition = child.PrimaryPart.Position
                            break
                        end
                    end
                end
                
                if safePosition then
                    -- Teleport in front of the safe and face it
                    rootPart.CFrame = CFrame.new(safePosition + Vector3.new(0, 1, 2), safePosition)
                    
                    Library:Notify{
                        Title = "Teleported",
                        Content = "Successfully teleported to safe",
                        Duration = 3
                    }
                else
                    Library:Notify{
                        Title = "Teleport Failed",
                        Content = "Could not determine safe position reliably.",
                        Duration = 3
                    }
                end
            end
        else
            Library:Notify{
                Title = "Teleport Failed",
                Content = "Could not find safe in any room",
                Duration = 3
            }
        end
    end
})

-- Teleport to Ofuda Box
Tabs.Main:CreateButton({
    Title = "Teleport to Ofuda Box",
    Description = "Teleports you to the Ofuda Box location",
    Callback = function()
        local ofudaBox = workspace.Server.SpawnedItems:FindFirstChild("OfudaBox2")
        
        if ofudaBox and game.Players.LocalPlayer.Character then
            local rootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- Teleport slightly above the ofuda box to avoid getting stuck and face it
                local boxPosition = ofudaBox:GetPivot().Position
                rootPart.CFrame = CFrame.new(boxPosition + Vector3.new(0, 3, 0), boxPosition)
                
                Library:Notify{
                    Title = "Teleported",
                    Content = "Successfully teleported to Ofuda Box",
                    Duration = 3
                }
            end
        else
            Library:Notify{
                Title = "Teleport Failed",
                Content = "Could not find Ofuda Box",
                Duration = 3
            }
        end
    end
})

Library:Notify{
    Title = "Script Loaded",
    Content = "Enjoy!",
    Duration = 5
}

Window:SelectTab(1)
