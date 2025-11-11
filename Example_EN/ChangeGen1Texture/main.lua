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

    local D = UE.FCardDataAll()
    D.Name = "ID1302"
    D.Description = "ID1302Description"
    D.CardID = 1302
    D.TexturePath = dir .. "1302.png"
    R:RegisterCardData(D.CardID, D)

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

function M.OnTick(dt)
    -- Called every frame (optional)
end

return M
