local M = {
    id          = "AddGen1Card4",
    name        = "Add Images for Each Rarity in Generation 1",
    version     = "1.0.0",
    author      = "yiming",
    description = "Adds card images for each rarity in Generation 1",
}

local function AddGen1Card4()
    local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
    if not R then
        if MOD and MOD.Logger then MOD.Logger.LogScreen("Cannot find UCardRegistryWorldSubsystem", 5,1,0,0,1) end
        return
    end

    -- Common / Rare card face resolution: 512×446
    local D = UE.FCardDataAll()
    D.Name = "ID1122"                     -- Card name
    D.Description = "ID1122Description"   -- Description
    D.CardID = 1122                       -- ID
    D.Gen = 0                             -- Generation: starts from 0 (0–6)
    D.TexturePath = dir .. "1122.png"     -- Image
    D.Rarity = UE.ECardRarity.Common
    D.BaseAttack = 10  -- Attack
    D.BaseHealth = 30  -- Health
    D.CardElementFaction:Add(UE.ECardElementFaction.Water)
    R:RegisterCardData(D.CardID, D)

    -- Uncommon card
    local D = UE.FCardDataAll()
    D.Name = "ID1214"                     -- Card name
    D.Description = "ID1214Description"   -- Description
    D.CardID = 1214                       -- ID
    D.Gen = 0                             -- Generation
    D.TexturePath = dir .. "1214.png"     -- Image
    D.Rarity = UE.ECardRarity.UnCommon
    D.BaseAttack = 15  -- Attack
    D.BaseHealth = 60  -- Health
    D.CardElementFaction:Add(UE.ECardElementFaction.Animal)
    R:RegisterCardData(D.CardID, D)

    -- Rare card
    local D = UE.FCardDataAll()
    D.Name = "ID1324"                     -- Card name
    D.Description = "ID1324Description"   -- Description
    D.CardID = 1324                       -- ID
    D.Gen = 0                             -- Generation
    D.TexturePath = dir .. "1324.png"     -- Image
    D.Rarity = UE.ECardRarity.Rare
    D.BaseAttack = 50  -- Attack
    D.BaseHealth = 250  -- Health
    D.CardElementFaction:Add(UE.ECardElementFaction.Electric)
    R:RegisterCardData(D.CardID, D)

    -- Super Rare card
    local D = UE.FCardDataAll()
    D.Name = "ID1405"                     -- Card name
    D.Description = "ID1405Description"   -- Description
    D.CardID = 1405                       -- ID
    D.Gen = 0                             -- Generation
    D.TexturePath = dir .. "1405.png"     -- Image
    D.Rarity = UE.ECardRarity.SuperRare
    D.BaseAttack = 80  -- Attack
    D.BaseHealth = 350  -- Health
    D.CardElementFaction:Add(UE.ECardElementFaction.Dragon)
    R:RegisterCardData(D.CardID, D)

    -- Current valid CardID range: 1000–9999.
    -- Do not add new IDs within the same CardID×10 range.
    -- (For example, 11012 represents the silver frame version of card 1101.)
    if MOD and MOD.Logger then  
        MOD.Logger.LogScreen(("Mod [%s] has been successfully loaded"):format(M.name), 5,1,1,0,1)
    end
end

function M.OnInit()
    -- Initialization
    if MOD and MOD.Logger then  
        MOD.Logger.LogScreen(("Mod [%s] is loading"):format(M.name), 5,1,1,0,1)
    end
    AddGen1Card4()
end

return M

-- Additional Notes:
-- Rarity:
-- UE.ECardRarity.Common       -- Common
-- UE.ECardRarity.UnCommon     -- Uncommon
-- UE.ECardRarity.Rare         -- Rare
-- UE.ECardRarity.SuperRare    -- Super Rare
-- UE.ECardRarity.God          -- God

-- Elements:
-- UE.ECardElementFaction.Fire      -- Fire
-- UE.ECardElementFaction.Water     -- Water
-- UE.ECardElementFaction.Grass     -- Grass
-- UE.ECardElementFaction.Electric  -- Electric
-- UE.ECardElementFaction.Insect    -- Insect
-- UE.ECardElementFaction.Rock      -- Rock
-- UE.ECardElementFaction.Earth     -- Earth
-- UE.ECardElementFaction.Animal    -- Animal
-- UE.ECardElementFaction.Steel     -- Steel
-- UE.ECardElementFaction.Dragon    -- Dragon
-- UE.ECardElementFaction.Psychic   -- Psychic
-- UE.ECardElementFaction.Mystic    -- Mystic
-- UE.ECardElementFaction.Ice       -- Ice
