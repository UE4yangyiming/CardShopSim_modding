# 🃏 CardShopSim Multiplayer Edition Modding Example

_This is a **Lua-based** mod example for **CardShopSim Multiplayer Edition**._  
[中文](README.md)   | [English](README_EN.md)  
[📚 Notable APIs](NotableAPIs_EN.md)

---

## 🧩 Overview

The game automatically scans and loads Mods from the following directories:

- `GameRoot/CardShopSim/Mods` 📁  
- Subscribed Workshop items from **Steam Workshop** 🛠️

When a folder contains both `main.lua` and `preview.png`, the Mod will appear and can be managed from the in-game **Mods** menu.

---

### ⚙️ Rule 1: Load and Execution Order
- About **1 second** after entering the game, all mods are loaded sequentially by path and the following functions are executed:  
  ```lua
  M.OnInit()   -- Called once after load
  M.OnTick(dt) -- Called every frame
  ```

### 🧠 Rule 2: Global Access
- `UE`: Global variable that provides access to all Unreal Engine-exposed functions.  
- `M`: Holds current Mod info, which will appear in the Mods list in the main menu.  
- `dir`: The absolute path of the current Mod.

---

## 📁 Mod Folder Structure

Place your Mod folder under `GameRoot/CardShopSim/Mods/` to be recognized by the game.

```
CardShopSim/
└── Mods/
    └── MyMod/
        ├── main.lua       # Mod logic (written in Lua)
        └── preview.png    # Preview image (256×256, square)
```

👉 [Example Mod Folder](Example_ZH/)

---

## 🧾 The `M` Table in `main.lua`

`local M = {}` should include:

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique Mod ID (English, used as a key) |
| `name` | string | Display name |
| `description` | string | Description text |
| `version` | string | Version number |
| `author` | string | Author name |

> ✅ You may also declare additional local variables beside `M` for internal Mod use.

---

## 🖼️ Card Add / Replace Example

### 📐 Image Resolution Recommendation
| Type | Recommended Resolution |
|---|---|
| Common / Uncommon / Rare | `512×446` |
| Super Rare / God | `747×1024` |

> 💡 **Card ID Rule:** Recommended range `1000–9999`, must be **unique**. Card frames use **(CardID × 10) + FrameIndex**, e.g. `11012` means card `1101` with a silver frame.
Card loading and saving are entirely based on IDs.The IDs correspond exactly to the ones shown in the top-right corner of the cards in the game.
---

### 🔧 Minimal Example (Add or Override Card Data)

```lua
local function ChangeCard()
    local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
    local D = UE.FCardDataAll()                  -- Create card data struct
    D.Name = "ID1122"                            -- Card name (used for localization key)
    D.Description = "ID1122Description"          -- Description (used for localization key)
    D.CardID = 1122                              -- Unique internal ID (must not conflict)
    D.Gen = 0                                    -- Generation: 0 = Gen1      (0–6) Gen1-7
    D.TexturePath = dir .. "1122.png"            -- Image path (same folder as main.lua)
    D.Rarity = UE.ECardRarity.Common             -- Rarity (see below)
    D.BaseAttack = 10                            -- Base attack
    D.BaseHealth = 30                            -- Base health
    D.CardElementFaction:Add(UE.ECardElementFaction.Water) -- Element (Water)

    -- 💥 Attack & Health Calculation Formula (see explanation below)
    -- FinalAttack = BaseAttack × FrameMultiplier
    -- FinalHealth = BaseHealth × FrameMultiplier

    R:RegisterCardData(D.CardID, D)              -- Register (add or override)
end
```

---


### 🔧 Ultra-Rare Card Image Replacement Example

```lua
local function ChangeCard()
    local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
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
end
```

---

## 📊 Card Frame Multiplier Reference

| Frame Type | Multiplier | Description |
|-------------|-------------|--------------|
| Basic | 1.0 | Default multiplier |
| Silver | 1.1 | +10% Attack & HP |
| Gold | 1.2 | +20% Attack & HP |
| Laser | 1.3 | +30% Attack & HP |
| Shiny | 1.4 | +40% Attack & HP |
| Mythic | 1.5 | +50% Attack & HP |

> 🧮 Example: If BaseAttack = 100 and Frame = Gold (1.2), FinalAttack = 100 × 1.2 = **120**.

---

### 🏷️ Enums (Rarity / Element)

```lua
-- Rarity:
UE.ECardRarity.Common -- Common
UE.ECardRarity.UnCommon -- Uncommon
UE.ECardRarity.Rare -- Rare
UE.ECardRarity.SuperRare -- Super Rare
UE.ECardRarity.God -- God

-- Element:
UE.ECardElementFaction.Fire -- Fire
UE.ECardElementFaction.Water -- Water
UE.ECardElementFaction.Grass -- Grass
UE.ECardElementFaction.Electric -- Electric
UE.ECardElementFaction.Insect -- Insect
UE.ECardElementFaction.Rock -- Rock
UE.ECardElementFaction.Earth -- Earth
UE.ECardElementFaction.Animal -- Animal
UE.ECardElementFaction.Steel -- Steel
UE.ECardElementFaction.Dragon -- Dragon
UE.ECardElementFaction.Psychic -- Psychic
UE.ECardElementFaction.Mystic -- Mystic
UE.ECardElementFaction.Ice -- Ice
```

---

## ✅ A Complete Example (`main.lua`)

```lua
-- Basic Info: Displayed in the Mods menu
local M = {
    id          = "ChangeGen1Card",
    name        = "Example Name",
    version     = "1.0.0",
    author      = "yiming",
    description = "Example Description",
}

-- Place assets in the same folder as main.lua
local function AddCard()
    local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
    local D = UE.FCardDataAll()
    D.Name = "ID1101"
    D.Description = "ID1101Description"
    D.CardID = 1101
    D.Gen = 0
    D.TexturePath = dir .. "1101.png"
    D.Rarity = UE.ECardRarity.Common
    D.BaseAttack = 10
    D.BaseHealth = 30
    D.CardElementFaction:Add(UE.ECardElementFaction.Water)
    R:RegisterCardData(D.CardID, D)
end

function M.OnInit()
    AddCard()
end

function M.OnTick(dt)
end

return M
```
---
## ✔ Example 1: Override Payment Method
Modify the built-in payment selection logic by overriding the original function.
Contact the author to add a simple modification interface
```lua
local function try_patch()

    if not MOD or not MOD.Playercontroller or MOD.Playercontroller.PlayerIndex == -1 then
        -- PlayerController not ready yet, retry later
        MOD.GAA.TimerManager:AddTimer(1, M, function() M:try_patch() end)
        return
    end

    local pc    = MOD.Playercontroller
    local key   = "BP_PlayerState0"   -- Get the player's BP_PlayerState
    local klass = pc.GetLuaObject and pc:GetLuaObject(key) or nil

    if not klass then
        return
    end

    -- Override the original GetPayMentOverall function
    klass.GetPayMentOverall = function(self)
        -- Original logic randomly returns 0/1/2:
        -- 0 = Cash
        -- 1 = Card reader
        -- 2 = QR scan
        -- return MOD.UE.UKismetMathLibrary.RandomIntegerInRange(0, 2)

        MOD.Logger.LogScreen("Payment Intercepted", 5, 0, 1, 0, 1)
        return 2   -- Always use QR scan
    end
end
```

## ✔ Example 2: Modify Booster Rarity Appearance Rates
Override the rarity distribution when opening booster packs.
Contact the author to add a simple modification interface
```lua
local function ConfigureBoosterRarityRates()
    local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
    if not R then
        if MOD and MOD.Logger then
            MOD.Logger.LogScreen("Cannot find UCardRegistryWorldSubsystem", 5,1,0,0,1)
        end
        return
    end

    -- Original rates are weights, NOT required to add up to 1

    -- 0: Standard Booster
    local StandardRates = {
        [UE.ECardRarity.Common]    = 0.894,
        [UE.ECardRarity.UnCommon]  = 0.010,
        [UE.ECardRarity.Rare]      = 0.005,
        [UE.ECardRarity.SuperRare] = 0.001,
    }
    R:RegisterRarityData(0, StandardRates)

    -- 1: Deluxe Booster
    local DeluxeRates = {
        [UE.ECardRarity.Common]    = 0.205,
        [UE.ECardRarity.UnCommon]  = 0.690,
        [UE.ECardRarity.Rare]      = 0.100,
        [UE.ECardRarity.SuperRare] = 0.005,
    }
    R:RegisterRarityData(1, DeluxeRates)

    -- 2: Luxury Booster
    local LuxuryRates = {
        [UE.ECardRarity.Common]    = 0.000,
        [UE.ECardRarity.UnCommon]  = 0.035,
        [UE.ECardRarity.Rare]      = 0.055,
        [UE.ECardRarity.SuperRare] = 0.010,
    }
    R:RegisterRarityData(2, LuxuryRates)

    if MOD and MOD.Logger then
        MOD.Logger.LogScreen(("Mod [%s] Loaded"):format(M.name), 5,1,1,0,1)
    end
end
```


## ✔ Example 3: Modify Trait Appearance Rates

When a card is opened, traits are selected based on the rarity of that card.
This interface allows mods to override the trait appearance weights.
Contact the author to add a simple modification interface
```lua
-- Modify trait appearance rates based on card rarity
local function ConfigureBoosterRarityRates1()
    local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
    if not R then
        if MOD and MOD.Logger then
            MOD.Logger.LogScreen("Cannot find UCardRegistryWorldSubsystem", 5,1,0,0,1)
        end
        return
    end

    -- These are original weight values. Higher weight => higher chance.

    ----------------------------------------------------------------
    -- Row 1: Common (ECardRarity.Common)
    ----------------------------------------------------------------
    local CommonTraitRates = {
        [UE.ETrait.Legendary]   = 0.001, -- EX
        [UE.ETrait.Shiny]       = 0.029, -- Shiny
        [UE.ETrait.Holographic] = 0.070, -- Holographic
        [UE.ETrait.Gold]        = 0.100, -- Gold
        [UE.ETrait.Silver]      = 0.100, -- Silver
        [UE.ETrait.Basic]       = 0.700, -- Basic
    }
    R:RegisterTraitData(UE.ECardRarity.Common, CommonTraitRates)

    ----------------------------------------------------------------
    -- Row 2: UnCommon
    ----------------------------------------------------------------
    local UnCommonTraitRates = {
        [UE.ETrait.Legendary]   = 0.003,
        [UE.ETrait.Shiny]       = 0.037,
        [UE.ETrait.Holographic] = 0.100,
        [UE.ETrait.Gold]        = 0.220,
        [UE.ETrait.Silver]      = 0.250,
        [UE.ETrait.Basic]       = 0.400,
    }
    R:RegisterTraitData(UE.ECardRarity.UnCommon, UnCommonTraitRates)

    ----------------------------------------------------------------
    -- Row 3: Rare
    ----------------------------------------------------------------
    local RareTraitRates = {
        [UE.ETrait.Leginary]   = 0.070,
        [UE.ETrait.Shiny]       = 0.140,
        [UE.ETrait.Holographic] = 0.210,
        [UE.ETrait.Gold]        = 0.300,
        [UE.ETrait.Silver]      = 0.200,
        [UE.ETrait.Basic]       = 0.080,
    }
    R:RegisterTraitData(UE.ECardRarity.Rare, RareTraitRates)

    ----------------------------------------------------------------
    -- Row 4: SuperRare
    ----------------------------------------------------------------
    local SuperRareTraitRates = {
        [UE.ETrait.Legendary]   = 0.300,
        [UE.ETrait.Shiny]       = 0.350,
        [UE.ETrait.Holographic] = 0.350,
        [UE.ETrait.Gold]        = 0.000,
        [UE.ETrait.Silver]      = 0.000,
        [UE.ETrait.Basic]       = 0.000,
    }
    R:RegisterTraitData(UE.ECardRarity.SuperRare, SuperRareTraitRates)

    ----------------------------------------------------------------
    -- Row 5: God
    ----------------------------------------------------------------
    local GodTraitRates = {
        [UE.ETrait.Legendary]   = 1.000,
        [UE.ETrait.Shiny]       = 0.000,
        [UE.ETrait.Holographic] = 0.000,
        [UE.ETrait.Gold]        = 0.000,
        [UE.ETrait.Silver]      = 0.000,
        [UE.ETrait.Basic]       = 0.000,
    }
    R:RegisterTraitData(UE.ECardRarity.God, GodTraitRates)

    if MOD and MOD.Logger then
        MOD.Logger.LogScreen(("Mod [%s] Loaded"):format(M.name), 5,1,1,0,1)
    end
end
```
---

## 📮 More API interfaces and extensions:Contact
- QQ: 780231813  
- Official QQ Group (Admin): 958628027  
- Email: yangyiming780@foxmail.com  
- Steam Community / Git issues

---

## 🛡️ Community Guidelines
1. 🚫 No illegal, political, pornographic, or violent content.  
2. 🚫 No malicious insults, trolling, or references to real-world persons/events.  
3. 🚫 No copyrighted resources without permission.  
4. 🚫 No ads, donations, or paid promotions through Mods.  

If a mod is published on the Steam Workshop and violates any of the above rules, it may be deleted and the creator’s publishing privileges may be permanently revoked.
