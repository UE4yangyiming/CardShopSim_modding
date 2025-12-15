local M = {
    id          = "ChangeGen1Texture",
    name        = "Modify Part of Generation 1 Textures",
    version     = "1.0.0",
    author      = "yiming",
    description = "Modifies part of Generation 1 card images",
}

local function ChangeGen1Texture()
    local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
    if not R then
        if MOD and MOD.Logger then MOD.Logger.LogScreen("Cannot find UCardRegistryWorldSubsystem", 5,1,0,0,1) end
        return
    end

    -- Common / Rare card face resolution: 512×446
    local D = UE.FCardDataAll()
    D.Name = "ID1101"
    D.Description = "ID1101Description"
    D.CardID = 1101
    D.TexturePath = dir .. "1101.png"
    -- D.BaseAttack = 0  -- Attack
    -- D.BaseHealth = 0  -- Health
    R:RegisterCardData(D.CardID, D)

    local D = UE.FCardDataAll()
    D.Name = "ID1102"
    D.Description = "ID1102Description"
    D.CardID = 1102
    D.TexturePath = dir .. "1101.png"
    R:RegisterCardData(D.CardID, D)

    -- Super Rare / God card face resolution: 747×1024
    local D = UE.FCardDataAll()
    D.Name = "ID1301"
    D.Description = "ID1301Description"
    D.CardID = 1301
    D.TexturePath = dir .. "1301.png"
    R:RegisterCardData(D.CardID, D)

    -- Ultra-rare cards have 6 layers. The earlier the index, the closer it is to the player's camera.
    -- TexturePath6 is the bottom layer and can be used for the background.
    -- The first 5 layers can use transparent images to create a multi-layer effect.
    local D = UE.FCardDataAll()
    D.Name = "ID1401"
    D.Description = "ID1401Description"
    D.CardID = 1401
    D.TexturePath = dir .. "1401.png"      -- First layer: character
    D.TexturePath2 = dir .. "1401-2.png"   -- Second layer: effect
    -- D.TexturePath3 = dir .. "1401-3.png" In this demo only three layers, these three remain empty
    -- D.TexturePath4 = dir .. "1401-4.png" In this demo only three layers, these three remain empty
    -- D.TexturePath5 = dir .. "1401-5.png" In this demo only three layers, these three remain empty
    D.TexturePath6 = dir .. "1401-6.png"   -- Bottom layer: background
    D.FlowTexturePath = dir .. "fire.PNG"  --Background floating images
    D.FlowValue = 0.5      --The transparency of the background floating image ranges from 0 to 1.



    R:RegisterCardData(D.CardID, D)        -- Register (add or override)

    -- Current valid CardID range: 1000–9999.
    -- You cannot add new IDs within the same CardID×10 range.
    -- (For example, ID 11012 refers to the silver frame version of card 1101.)
    if MOD and MOD.Logger then  
        MOD.Logger.LogScreen(("Mod [%s] has been successfully loaded"):format(M.name), 5,1,1,0,1) 
    end
end

function M.OnInit()
    -- Initialization
    if MOD and MOD.Logger then  
        MOD.Logger.LogScreen(("Mod [%s] is loading"):format(M.name), 5,1,1,0,1)
    end
    ChangeGen1Texture()
end


return M
