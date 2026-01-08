# CardShopSim Modding Example (Multiplayer Version)

This is a mod example written in Lua for the game "Card Shop Simulator Multiplayer".  

💡This is just a machine-translated English version - please see the original Chinese README for detailed instructions.
[中文](README.md)   | [English](README_EN.md)  
---

## 🧩Working Principle Overview

The game will automatically scan and read mods from the following locations:

- `game root directory/CardShopSim/Mods` 📁  
Item folders subscribed from the Steam Workshop 🛠️

Once the files that meet the criteria `main.lua` and `preview.png` are found, the Mod can be identified, managed, and loaded in the **Mods** menu.

---

### ⚙️Rule 1: Loading and Execution
- Approximately **1 second** after entering the game, mods will be loaded and executed sequentially according to their path:
```lua
M.OnInit() -- Executes once during initialization
```

### 🧠Rule Two: Global Access
- `UE`: A global variable that provides access to the set of functions exposed by Unreal Engine.
- `M`: The information structure of the current Mod (displayed in the Mods list on the main interface).
- `dir`: The absolute path of the current Mod.
---

## 📁 Mod Folder Structure

Simply place the mod in the `game root directory/CardShopSim/Mods/` directory to make it recognized in the game.

```
CardShopSim/
└── Mods/
└── MyMod/
├── main.lua # Mod logic (written in Lua)
└── preview.png # Preview image (256×256, square)
```

👉 [Example Mod]( Example_ZH/ )

---

## 🧾 The `M` structure of `main.lua`

`local M = {}` is recommended to include:

| Field | Type | Description |
|---|---|---|
| `id` | string | Mod Unique ID (English, used as a key) |
| `name` | string | Display Name |
| `description` | string | Description |
| `version` | string | version number |
| `author` | string | author|

> ✅You can freely declare local state/variables next to `M` for use within the Mod.

---

## 🖼️Adding /Replacing Cards (Example)

### 📐Image Resolution Recommendations
| Type | Recommended Resolution |
|---|---|
| Common/Rare | `512×446` |
| Rare/Extremely Rare/God-tier Card | `747×1024` |

> 💡 **Card ID Rules** : Recommended range is `1000–9999`, **no duplicates allowed** . The "card frame" of the same card is represented by **(card ID × 10) + frame size** (e.g., `11012` = card 1101 + silver card frame).
Card loading and saving are all handled by ID storage. The ID matches the ID in the upper right corner of the card in the game.

> 💡 **To use a larger card image for common and rare cards :** Add `D.UseBigImage = true` to the settings below.

> 💡 A single local function can contain a maximum of 200 local variables. If the number of variables is too large, it can be split into two local functions.
---

### 🔧Minimum Usable Example (Adding/Overwriting Card Data)
> 💡**If you want to use the extremely rare card image on the common or rare cards**: You need to add D.UseBigImage = true in the attribute settings.
```lua
local function ChangeCard()
local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
local D = UE.FCardDataAll() -- Create card data
D.Name = "ID1122" -- Card name (used for localization key)
D.Description = "ID1122Description" -- Description (used for localizing the key)
D.CardID = 1122 -- Internally unique ID (must not conflict with other cards)
D.Gen = 0 -- Generation: 0=first generation (0~6) 1-7 generations
D.TexturePath = dir .. "1122.png" -- Texture path (same directory as main.lua)
D.Rarity = UE.ECardRarity.Common -- Rarity (see enumeration below)
D.BaseAttack = 10 -- Basic attack
D.BaseHealth = 30 -- Base Health
--D.CardValueMulti = 1.0 --Added base price multiplier
-- D.UseBigImage = true                 		 -- Use extremely rare materials  The rare cards do not have 6-layer materials by default. Only D.TexturePath
D.CardElementFaction:Add(UE.ECardElementFaction.Water) -- element (water)

-- 💥Current attack power and health calculation formula (see explanation below for algorithm)
-- Final Attack Power = Base Attack Power × Current Card Frame Multiplier
-- Final Health = Base Health × Current Card Frame Multiplier

R:RegisterCardData(D.CardID, D) -- Register (add or overwrite)
end
```
---

---
### 🔧Example of replacing images for extremely rare cards

```lua
local function ChangeCard()
local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
--This extremely rare card has 6 layers. The earlier the layer number, the closer it is to the player's camera. TexturePath6 is the bottom layer and can hold the background. The first 5 layers can hold transparent images. This creates a layered effect.
local D = UE.FCardDataAll()
D.Name = "ID1401"
D.Description = "ID1401Description"
D.CardID = 1401
D.TexturePath = dir .. "1401.png" -- The character on the first layer
D.TexturePath2 = dir .. "1401-2.png" -- Second layer effect
-- D.TexturePath3 = dir .. "1401-3.png" The demo only shows three layers, and these three layers are empty.
-- D.TexturePath4 = dir .. "1401-4.png" The demo only shows three layers, and these three layers are empty.
-- D.TexturePath5 = dir .. "1401-5.png" The demo only shows three layers, and these three layers are empty.
D.TexturePath6 = dir .. "1401-6.png" -- Bottom layer background

--D.FlowTexturePath = dir .. "fire.PNG" --Image of the floating background example (you can add semi-transparent floating background particle images)
--D.FlowValue = 1 --Opacity of the background floating particle image (0-1, default 0, no display)
--D.FlowSpeedX = 0.1 -- Background floating particles continuously move to the left by 0.1
--D.FlowSpeedY = -0.1 -- Background floating particles continue to move downwards by 0.1

--D.CardValueMulti = 1.0 --Base price multiplier (default 1.0x)

R:RegisterCardData(D.CardID, D) -- Register (add or overwrite)
end
```
---

---

## 📊Card Frame Multiplier Reference Table

| Card Frame Type | Multiplier | Example Description |
|-----------|------|-----------|
| Basic | 1.0 | Base Multiplier |
| Silver | 1.1 | Silver card frame: Attack and HP +10% |
| Gold | 1.2 | Gold card frame: Attack and HP +20% |
| Laser | 1.3 | Laser card frame attack and health +30% |
| Shining | 1.4 | Shining card frame: Attack and HP +40% |
| Rare | 1.5 | Rare card frame: Attack and HP +50% |

> 🧮 Calculation example: If the base attack power is 100 and the card frame is gold (1.2), then the final card display attack power = 100 × 1.2 = **120** .

---

### 🏷️ Enumeration (Rarity/Element)

```lua
-- Rarity:
UE.ECardRarity.Common -- Common
UE.ECardRarity.UnCommon -- Rare
UE.ECardRarity.Rare -- Rare
UE.ECardRarity.SuperRare -- Extremely Rare
UE.ECardRarity.God -- God Card
--For all the cards, you need to specify their rarity levels. Otherwise, they will default to the common rarity.
--God Card can use any element.
--When you unlock a God Card, you can unlock all God Card types available in the card table.
--Currently, only four special effects have been implemented in the game. Other God Card effects will use the Rain God effect when activated.
--Custom-added "god card" borders will sparkle, have the "god card" attribute, and the same price. The center floating effect cannot be set to sparkle because the material cannot be customized.

-- Element:
UE.ECardElementFaction.Fire -- fire
UE.ECardElementFaction.Water --water
UE.ECardElementFaction.Grass --Grass
UE.ECardElementFaction.Electric --Electric
UE.ECardElementFaction.Insect -- Insects
UE.ECardElementFaction.Rock -- Rock
UE.ECardElementFaction.Earth --Earth
UE.ECardElementFaction.Animal -- Animal
UE.ECardElementFaction.Steel --Steel
UE.ECardElementFaction.Dragon --Dragon
UE.ECardElementFaction.Psychic -- Superpowers
UE.ECardElementFaction.Mystic -- Mysterious
UE.ECardElementFaction.Ice -- Ice
```

---

## ✅Complete , working example: Replacing/Adding card art (`main.lua`)

```lua
-- Required information: will be displayed in the Mods interface.
local M = {
id = "ChangeGen1Card",
name = "Example Name",
version = "1.0.0",
author = "yiming",
description = "Example Description",
}

-- You can place the resources in the same directory as main.lua.

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
--D.CardValueMulti = 1.0 --Added base price multiplier
D.CardElementFaction:Add(UE.ECardElementFaction.Water)
R:RegisterCardData(D.CardID, D)
end

function M.OnInit()
AddCard()
end


return M
```

---
## ✅Example : Add an interface to change the payment method to only accept QR code payments
The function for setting the payment method will be modified using an overriding function to change its original logic.
> 💡 **Only effective when added by the host** : This will modify the payment settings for everyone's cashier.

** Principle :** The entire cashier function runs on the server; the client only receives the message. When a customer pays, they obtain the host's `playerState`, then call `GetPayMent` to get the return value—which sets the specific implementation effect of the cashier.

Contact the author to add a simple modification interface.
```lua
local function try_patch()

if not MOD or not MOD.Playercontroller or MOD.Playercontroller.PlayerIndex == -1 then
-- PlayerController is not ready yet, please try again later.
MOD.GAA.TimerManager:AddTimer(1, M, function() M:try_patch() end)
return
end

local pc = MOD.Playercontroller
local key = "BasePlayerState0" -- Get the player's BP_PlayerState
local klass = pc.GetLuaObject and pc:GetLuaObject(key) or nil -- Get the Lua file of the current BP_PlayerState.

if not klass then
MOD.GAA.TimerManager:AddTimer(1, M, function() M:try_patch() end)
return
end

klass.GetPayMentOverall = function(self)
--The original function is three random values.
--0 --Cash
--1 --Card reader
--2 --Scan QR code
-- return MOD.UE.UKismetMathLibrary.RandomIntegerInRange(0, 2) -- Call the UE function to generate a random value

MOD.Logger.LogScreen("Intercepting cashier", 5, 0, 1, 0, 1)
return 2
end
end
```
> 💡 **Additional PlayerState Interface** : To use it, add it after the klassfunction above.
```lua
--When checkout is complete, each card processed triggers an event once.
klass.OnCardSoldOverall = function(self,CardID)
MOD.Logger.LogScreen("Checkout completed, CardID = " .. tostring(CardID),5, 0, 1, 0, 1)
-- Execution code
end
--When a pack of cards is opened, each card triggers an event once.
klass.OnCardOpenedOverall = function(self,CardID)
MOD.Logger.LogScreen("A card was opened in the card pack, CardID = " .. tostring(CardID),5, 0, 1, 0, 1)
-- Execution code
end
```
---
## ✅Example : Adding an interface to modify the probability of opening card packs
Contact the author to add a simple modification interface.
```lua
local function ConfigureBoosterRarityRates()
local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
If not R then
If MOD and MOD.Logger are both present, then MOD.Logger.LogScreen("UDrinkRegistryWorldSubsystem not found", 5,1,0,0,1) end
return
end

--In the original version, the probabilities don't need to be added together to equal 1. All probabilities are actually weighted; the probability with a larger weighting will be higher.

-- 0: Standard Package
local StandardRates = {
[UE.ECardRarity.Common] = 0.894,
[UE.ECardRarity.UnCommon] = 0.01,
[UE.ECardRarity.Rare] = 0.005,
[UE.ECardRarity.SuperRare] = 0.001,
}
R:RegisterRarityData(0, StandardRates)

-- 1: Deluxe Package
local DeluxeRates = {
[UE.ECardRarity.Common] = 0.205,
[UE.ECardRarity.UnCommon] = 0.690,
[UE.ECardRarity.Rare] = 0.100,
[UE.ECardRarity.SuperRare] = 0.005,
}
R:RegisterRarityData(1, DeluxeRates)

-- 2: Rare Luxury Bags
local LuxuryRates = {
[UE.ECardRarity.Common] = 0.000,
[UE.ECardRarity.UnCommon] = 0.035,
[UE.ECardRarity.Rare] = 0.055,
[UE.ECardRarity.SuperRare] = 0.010,
}
R:RegisterRarityData(2, LuxuryRates)

If MOD and MOD.Logger are both loaded, then MOD.Logger.LogScreen(("Mod [%s] has finished loading"):format(M.name), 5,1,1,0,1) end --log
end
```

---
## ✅Example : The trait probability of cards of the current rarity after the added interface is enabled.
Contact the author to add a simple modification interface.
```lua
--Modify the probability of traits appearing when drawing cards of the current card rarity.
local function ConfigureBoosterRarityRates1()
local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
If not R then
If MOD and MOD.Logger are both present, then MOD.Logger.LogScreen("UDrinkRegistryWorldSubsystem not found", 5,1,0,0,1) end
return
end

--In the original version, the probabilities don't need to be added together to equal 1. All probabilities are actually weighted; the probability with a larger weighting will be higher.
-- Line 1: Common (ECardRarity.Common) The probability of various traits appearing in common cards.
----------------------------------------------------------------
local CommonTraitRates = {
[UE.ETrait.Legendary] = 0.001, -- Probability of being a rare item
[UE.ETrait.Shiny] = 0.029, -- Shiny probability
[UE.ETrait.Holographic] = 0.070, -- Laser probability
[UE.ETrait.Gold] = 0.100, -- Probability of achieving the gold standard
[UE.ETrait.Silver] = 0.100, -- Probability of Silver
[UE.ETrait.Basic] = 0.700, -- Base probability
}
R:RegisterTraitData(UE.ECardRarity.Common, CommonTraitRates)

----------------------------------------------------------------
-- Line 2: Rare (ECardRarity.UnCommon)
----------------------------------------------------------------
local UnCommonTraitRates = {
[UE.ETrait.Legendary] = 0.003,
[UE.ETrait.Shiny] = 0.037,
[UE.ETrait.Holographic] = 0.100,
[UE.ETrait.Gold] = 0.220,
[UE.ETrait.Silver] = 0.250,
[UE.ETrait.Basic] = 0.400,
}
R:RegisterTraitData(UE.ECardRarity.UnCommon, UnCommonTraitRates)

----------------------------------------------------------------
-- Line 3: Rare (ECardRarity.Rare)
----------------------------------------------------------------
local RareTraitRates = {
[UE.ETrait.Legendary] = 0.070,
[UE.ETrait.Shiny] = 0.140,
[UE.ETrait.Holographic] = 0.210,
[UE.ETrait.Gold] = 0.300,
[UE.ETrait.Silver] = 0.200,
[UE.ETrait.Basic] = 0.080,
}
R:RegisterTraitData(UE.ECardRarity.Rare, RareTraitRates)

----------------------------------------------------------------
-- Line 4: Extremely Rare (ECardRarity.SuperRare)
----------------------------------------------------------------
local SuperRareTraitRates = {
[UE.ETrait.Legendary] = 0.300,
[UE.ETrait.Shiny] = 0.350,
[UE.ETrait.Holographic] = 0.350,
[UE.ETrait.Gold] = 0.000,
[UE.ETrait.Silver] = 0.000,
[UE.ETrait.Basic] = 0.000,
}
R:RegisterTraitData(UE.ECardRarity.SuperRare, SuperRareTraitRates)

----------------------------------------------------------------
-- Line 5: God (ECardRarity.God)
----------------------------------------------------------------
local GodTraitRates = {
[UE.ETrait.Legendary] = 1.000,
[UE.ETrait.Shiny] = 0.000,
[UE.ETrait.Holographic] = 0.000,
[UE.ETrait.Gold] = 0.000,
[UE.ETrait.Silver] = 0.000,
[UE.ETrait.Basic] = 0.000,
}
R:RegisterTraitData(UE.ECardRarity.God, GodTraitRates)

If MOD and MOD.Logger are both loaded, then MOD.Logger.LogScreen(("Mod [%s] has finished loading"):format(M.name), 5,1,1,0,1) end --log
end
```

---
## ✅Example : Adding an interface to modify rarity price multiplier
Contact the author to add a simple modification interface.
```lua
--Modify the value multiplier for the current card's rarity. The final price of the current card = base price CardValueMulti * rarity value multiplier * trait value multiplier * generation value multiplier (generations 1-7 correspond to 1-7x; no channel is currently set).
local function RarityValue()
local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
If not R then
If MOD and MOD.Logger are both present, then MOD.Logger.LogScreen("UDrinkRegistryWorldSubsystem not found", 5,1,0,0,1) end
return
end
-- The default multiplier in the game now
R:RegisterRarityValueData(UE.ECardRarity.Common, 0.1) -- Common
R:RegisterRarityValueData(UE.ECardRarity.UnCommon, 0.5) -- rare
R:RegisterRarityValueData(UE.ECardRarity.Rare, 2) -- Rare
R:RegisterRarityValueData(UE.ECardRarity.SuperRare, 10) -- Extremely rare
R:RegisterRarityValueData(UE.ECardRarity.God, 500) -- God

If MOD and MOD.Logger are both loaded, then MOD.Logger.LogScreen(("Mod [%s] has finished loading"):format(M.name), 5,1,1,0,1) end --log
end
```
## ✅Example : Adding an interface to modify the trait price multiplier
Contact the author to add a simple modification interface.
```lua
--Modify the current card's trait value multiplier. The current card's final price = base price CardValueMulti * rarity value multiplier * trait value multiplier * generation value multiplier (generations 1-7 correspond to 1-7x; no channel is currently set).
local function TraitValue()
local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
If not R then
If MOD and MOD.Logger are both present, then MOD.Logger.LogScreen("UDrinkRegistryWorldSubsystem not found", 5,1,0,0,1) end
return
end
-- The default multiplier in the game now
R:RegisterTraitValueData(UE.ETrait.Basic, 1) -- Basic Trait
R:RegisterTraitValueData(UE.ETrait.Silver, 2) -- Silver Trait
R:RegisterTraitValueData(UE.ETrait.Gold, 5) -- Gold Trait
R:RegisterTraitValueData(UE.ETrait.Holographic, 20) -- Laser Trait
R:RegisterTraitValueData(UE.ETrait.Shiny, 50) -- Shiny trait
R:RegisterTraitValueData(UE.ETrait.Legendary, 200) -- Rare Trait

If MOD and MOD.Logger are both loaded, then MOD.Logger.LogScreen(("Mod [%s] has finished loading"):format(M.name), 5,1,1,0,1) end --log
end

```




## ✅ Complete Runnable Example: Localization (Multi-language Support) Update 2026.1.8
This example demonstrates how to dynamically load card names and descriptions based on the game's current language settings (e.g., Chinese, English, Japanese).
```lua
-- ==========================================================================
-- 1. Utility Function: Get Current Language
--    Note: Must be placed at the top so subsequent logic can call it.
-- ==========================================================================
local function GetGameLanguage()
    local culture = "en" -- Default fallback language
    
    -- Safety check: Ensure UE objects exist
    -- (Prevents errors if the Mod Loader scans files outside of the game environment)
    if UE and UE.UKismetInternationalizationLibrary and UE.UKismetInternationalizationLibrary.GetCurrentCulture then
        local fullCulture = UE.UKismetInternationalizationLibrary.GetCurrentCulture() 
        if fullCulture then
            -- Extract first two characters and convert to lowercase (e.g., "zh-Hans-CN" -> "zh")
            culture = string.sub(tostring(fullCulture), 1, 2):lower()
        end
    end
    
    -- Define supported languages list; fallback to 'en' if not in list
    local supported = {
        ["en"]=true, -- English
        ["zh"]=true, -- Chinese
        ["ja"]=true, -- Japanese
        ["es"]=true, -- Spanish
        ["fr"]=true, -- French
        ["de"]=true, -- German
        ["it"]=true, -- Italian
        ["pt"]=true, -- Portuguese
        ["ru"]=true  -- Russian
    }
    return supported[culture] and culture or "en"
end

-- Get current language and store it for later use
local CurrentLang = GetGameLanguage()


-- ==========================================================================
-- 2. Mod Metadata Definition (For C++ Regex Parser)
--    The C++ code scans these lines to display the Mod name in the UI list.
--    We use the global variable format to ensure Regex matches `key = "value"`.
-- ==========================================================================

-- --- English (Default) ---
name            = "Localization Example"
description     = "Example mod showing how to support multiple languages."

-- --- Chinese ---
name_zh         = "多语言本地化示例"
description_zh  = "这是一个演示如何支持多种语言的 Mod 示例。"

-- --- Japanese ---
name_ja         = "ローカライズ例"
description_ja  = "多言語対応の方法を示すMod例です。"

-- --- Spanish ---
name_es         = "Ejemplo de Localización"
description_es  = "Un mod de ejemplo que muestra cómo admitir varios idiomas."

-- --- French ---
name_fr         = "Exemple de Localisation"
description_fr  = "Exemple de mod montrant comment supporter plusieurs langues."

-- --- German ---
name_de         = "Lokalisierungsbeispiel"
description_de  = "Beispiel-Mod, der zeigt, wie mehrere Sprachen unterstützt werden."

-- --- Russian ---
name_ru         = "Пример локализации"
description_ru  = "Пример мода, показывающий поддержку нескольких языков."

-- (You can continue adding other languages, e.g., name_it, name_pt, etc.)


-- ==========================================================================
-- 3. Main Mod Table (M) (For Lua VM Execution)
--    This implements dynamic name retrieval inside Lua.
--    _G["name_"..CurrentLang] means:
--    If the current lang is 'zh', look for the global variable 'name_zh';
--    otherwise, use the default 'name'.
-- ==========================================================================
local M = {
    id          = "LocalizedCardExample",
    -- Dynamic assignment: Try to get name_zh, name_ja, etc., fallback to name
    name        = _G["name_" .. CurrentLang] or name, 
    description = _G["description_" .. CurrentLang] or description,
    version     = "1.0.2",
    author      = "yiming",
}


-- ==========================================================================
-- 4. In-Game Content Translation Table (Card Data)
--    Key = Card ID, Value = Text for each language
-- ==========================================================================
local CardLocalizationDB = {
    [1102] = {
        -- English
        en = { Name = "Blue Slime",     Desc = "A sticky friend found in the water." },
        -- Chinese
        zh = { Name = "蓝色史莱姆",     Desc = "在水中发现的粘粘的朋友。" },
        -- Japanese
        ja = { Name = "ブルースライム",  Desc = "水辺で見つかるネバネバした友達。" },
        -- Spanish
        es = { Name = "Limo Azul",      Desc = "Un amigo pegajoso encontrado en el agua." },
        -- French
        fr = { Name = "Slime Bleu",     Desc = "Un ami gluant trouvé dans l'eau." },
        -- German
        de = { Name = "Blauer Schleim", Desc = "Ein klebriger Freund aus dem Wasser." },
        -- Russian
        ru = { Name = "Синий Слизень",  Desc = "Липкий друг, найденный в воде." },
    },
    -- You can add more cards here...
    -- [1103] = { ... }
}


-- ==========================================================================
-- 5. Core Logic: Register Card
-- ==========================================================================
local function AddLocalizedCard()
    local W = MOD.GAA.WorldUtils:GetCurrentWorld()
    local R = UE.UCardFunction.GetCardRegistryWS(W)
    
    local cardId = 1102
    
    -- --- 1. Get translation data ---
    local cardData = CardLocalizationDB[cardId]
    
    -- Default fallback to English
    local finalName = cardData["en"].Name
    local finalDesc = cardData["en"].Desc

    -- If translation exists for the current language, override the default
    if cardData[CurrentLang] then
        finalName = cardData[CurrentLang].Name
        finalDesc = cardData[CurrentLang].Desc
    end
    -- -------------------------------

    -- --- 2. Assemble card data ---
    local D = UE.FCardDataAll()
    D.CardID = cardId
    D.Name = finalName
    D.Description = finalDesc
    D.Gen = 0
    -- Ensure this image exists in your Mod folder
    D.TexturePath = dir .. "1102.png"
    D.Rarity = UE.ECardRarity.Common
    D.BaseAttack = 15
    D.BaseHealth = 25
    D.CardElementFaction:Add(UE.ECardElementFaction.Water)
    
    -- --- 3. Register to game ---
    R:RegisterCardData(D.CardID, D)
end

-- ==========================================================================
-- 6. Mod Initialization Entry Point
-- ==========================================================================
function M.OnInit()
    AddLocalizedCard()
end

return M

```

---
## Upload to Steam Workshop
Please see https://partner.steamgames.com/doc/features/workshop/implementation
The Steam CMD integration section. Below is the copied content:
- The current game's appid = 3569500
- For the first upload, please enter 0 for the publishedfileid. A new publishedfileid will be generated afterwards. Updates will use this new publishedfileid.
``` lua
SteamCmd integration
In addition to the ISteamUGC API, the steamcmd.exe command-line tool can also be used to create and update Workshop items for testing purposes. Because this tool requires users to enter Steam credentials (which we do not want customers to provide), it is limited to testing use only.

To create a new Steam Workshop item using steamcmd.exe, you must first create a plain text VDF file containing the following key-value pairs.
"workshopitem"
{
"appid" "480"
"publishedfileid" "5674"
"contentfolder" "D:\\Content\\workshopitem"
"previewfile" "D:\\Content\\preview.jpg"
"visibility" "0"
"title" "The Green Hat of Team Fortress"
"description" "The Green Hat in Team Fortress"
"changenote" "version 1.2"
}

Notice:
The key-value pairs correspond to various ISteamUGC::SetItem[...] methods. Please see the documentation above for more information.
The values shown are for illustrative purposes only and should be adjusted as needed.
To create a new item, you must set the appid, and the publishedfileid must be either not set or set to 0.
To update existing items, both the appid and publishedfileid must be set.
If a key needs to be updated, the remaining key/value pairs should also be included in the VDF.
After creating the VDF, you can run steamcmd.exe with the file parameters `workshop_build_item <build config filename>`. For example:
steamcmd.exe +login myLoginName myPassword +workshop_build_item workshop_green_hat.vdf +quit
If the command succeeds, the publishedfileid value in the VDF will be automatically updated to include the Workshop item ID. Therefore, subsequent calls to steamcmd.exe within the same VDF will update, rather than create, new items.

```

---
## Existing IDs （The following is an AI translation only.）Update 2026.1.8
```lua
1101 Sand Flame Dog, First Generation, Common, Fire

1102 Minite, First Generation, Common, Animal

1103 Stubborn Bear Cub, First Generation, Common, Animal

1104 Turabi, First Generation, Common, Ground

1105 Electric Bear, First Generation, Common, Electric

1106 Muti, First Generation, Common, Ice

1107 Electric Dog, First Generation, Common, Electric

1108 Ice Cave Mouse, First Generation, Common, Ice

1109 Rainbow Butterfly, First Generation, Common, Insect

1110 Aiminyao, First Generation, Common, Animal

1111 Ice Cave Otter, First Generation, Common, Ice

1112 Strange Weasel, First Generation, Common, Animal

1113 Le Song Fox, First Generation, Common, Animal

1114 Coeus, First Generation, Common, Dragon

1115 Berry-tailed Monkey, First Generation, Common, Grass

1116 Bouncing Mouse, First Generation, Common, Animal

1117 Grass Dragon, First Generation, Common, Animal

1118 Leafy Pip, First Generation, Common, Grass

1119 Gawu Bird, First Generation, Common, Rock

1120 Big-eared Monkey, First Generation, Common, Animal

1121 Mysterious Owl, First Generation, Common, Mystic

1201 Rock-armored Lizard, First Generation, Rare, Rock

1202 White Dolphin Beast, First Generation, Rare, Water

1203 Snow Fairy, First Generation, Rare, Ice

1204 Octopus, First Generation, Rare, Water

1205 Kachi Fox, First Generation, Rare, Fire

1206 Pan Xiaoda, First Generation, Rare, Animal

1207 Volcano Spider, First Generation, Rare, Fire

1208 Thunder Eagle, First Generation, Rare, Electric

1209 Vampire Bat Dragon, First Generation, Rare, Dragon

1210 White Bat Beast, First Generation, Rare, Mystic

1211 Disaster Heat Lizard Dragon, First Generation, Rare, Dragon

1212 Ice Ridge Dragon, First Generation, Rare, Ice

1213 Young Ice Ridge Dragon First Generation Rare Ice

1301 Mine Eye Emperor First Generation Rare Rock

1302 Desmo First Generation Rare Psychic

1303 Fire Pattern Wolf First Generation Rare Fire

1304 Surging Dragon First Generation Rare Dragon

1305 Ghostly Butterfly First Generation Rare Grass

1306 Fierce Bird First Generation Rare Fire

1307 Mischievous Demon First Generation Rare Animal

1308 Frost Dragon First Generation Rare Ice

1309 Magnetic Beetle First Generation Rare Steel

1310 Assault Demon First Generation Rare Fire

1311 Rainbow Catfish First Generation Rare Water

1312 Bub First Generation Rare Ice

1313 Thunder Bear First Generation Rare Electric

1324 Pouch Punch First Generation Rare Animal

1325 Lamp Hat Forest Spirit First Generation Rare Grass

1326 Berry Deer First Generation Rare Animal

1327 Dream Hat Dodo First Generation Rare Psychic

1328 Smoke Furnace Dummy First Generation Rare Steel

1401 Heterochromatic Shell First Generation Extremely Rare Water

1402 Flame Feather Owl First Generation Extremely Rare Fire

1403 Mind Reading Cat First Generation Extremely Rare Animal

1404 Fist Emperor Ape First Generation Extremely Rare Fire

2101 Seed Thief Beast Second Generation Common Animal

2102 Octopus Skin Second Generation Common Water

2103 Grass Tail Sparrow Second Generation Common Grass

2104 Rock Chestnut Second Generation Common Earth

2105 Dazzling Tail Monkey Second Generation Common Grass

2106 Gem Bear Second Generation Common Earth

2107 Shadow Dragon Second Generation Common Dragon

2108 Ghost Jellyfish Second Generation Common Water

2109 Burning Mane Fox Second Generation Common Fire

2110 Double Fin Dragon Second Generation Common Grass

2111 Mushroom Rabbit  Second Generation Common Animal

2112 Thunder Beast Second Generation Common Electric

2113 Bewitching Fox Second Generation Common Electric

2114 Enderman Mouse Second Generation Common Psychic

2115 Tree Goblin Second Generation Common Grass

2201 Blazing Beast Second Generation Rare Fire

2202 Fossil Fish Second Generation Rare Water

2203 Exploding Tail Frog Second Generation Rare Fire

2204 Butterfly Rabbit Fairy Second Generation Rare Mysterious

2205 Golem Beetle Second Generation Rare Insect

2206 Silk Song Insect Second Generation Rare Insect

2301 Valley Hedgehog Second Generation Rare Animal

2302 Tsunami Otter Second Generation Rare Water

2303 Lilua Second Generation Rare Psychic

2304 Divine Lantern Second Generation Rare Mysterious

2305 Baby Beast Second Generation Rare Animal

2306 Azure Gaze Second Generation Rare Mysterious

2307 Fierce Charge Beast Second Generation Rare Fire

2308 Stonebreaker Pig Second Generation Rare Rock

2309 Forge Hammer Second Generation Rare Ground

2310 Rune Ghost Second Generation Rare Mysterious

2311 Sleepy Otter Second Generation Rare Water

2312 Dwarf Dora Second Generation Rare Grass

2313 Fluffy Snow Second Generation Rare Ice

2314 Winter Night Bell Second Generation Rare Ice

2315 Phantom Light Beast Second Generation Rare Electric

2316 Green Surge Second Generation Rare Grass

2317 Neon Shadow Second Generation Rare Mysterious

2318 Scorching Frequency Second Generation Rare Fire

2319 Ice Spirit Second Generation Rare Ice

2401 Sheath Fluff Fairy Second Generation Extremely Rare Grass

2402 Cactus Beast Second Generation Extremely Rare Grass

2403 Phantasm Beast Second Generation Extremely Rare Electric

2404 Ancient Rock Whale Second Generation Extremely Rare Rock

2405 Vine Shadow Weasel Second Generation Extremely Rare Grass

3101 Urodi Third Generation Common Mysterious

3102 Mask Bear Third Generation Common Steel

3103 Mechanical Snake Third Generation Common Steel

3104 Lockfang Third Generation Common Ice

3105 Pipette Third Generation Common Animal

3106 Windfang Third Generation Common Animal

3107 Electric Ape Third Generation Common Electric

3108 Ice Storm Dragon Third Generation Common Ice

3109 Bit Cat Third Generation Common Psychic

3110 Star Beast Third Generation Common Fire

3111 Graveyard Sheep Third Generation Common Electric

3112 Swift Third Generation Common Fire

3113 Jet Wing Third Generation Common Fire

3114 Steel Guard Third Generation Common Steel

3115 Bantley Third Generation Common Fire

3201 Snowfoot Mongoose Third Generation Rare Ice

3202 Electric Claw Dragon Third Generation Rare Electric

3203 Yuta Third Generation Rare Grass

3204 Kori Sheep Third Generation Rare Fire

3205 Maple Deer Third Generation Rare Fire

3206 Ant Nest King Third Generation Rare Insect

3207 Honey Wing Bee Third Generation Rare Insect

3208 Honey Wing Ant Third Generation Rare Insect

3209 Shallow Water Mist Third Generation Rare Water

3210 Cherry Eye Shark Third Generation Rare Water

3301 Fire Nudi Third Generation Rare Fire

3302 Blood Moon Beast Third Generation Rare Mysterious

3303 Bag Third Generation Rare Animal

3304 Fighting Shepherd Third Generation Rare Animal

3305 Wukong Third Generation Rare Water

3306 3306  Furious Golden Leopard  Third Generation  Rare Electric

3307  Zilarus  Third Generation  Rare Ice

3308  Mudgumo  Third Generation  Rare Insect

3309  Morning Light Traveler Luna  Third Generation  Rare Grass

3310  Sunshine Captain Linda  Third Generation  Rare Water

3311  Candy Rush  Third Generation  Rare Mystic

3312  One-Eyed Stone  Third Generation  Rare Rock

3313  Bell Box  Third Generation  Rare Steel

3314  Azure Lock  Third Generation  Rare Mystic

3315  Star-Spitting Fish  Third Generation  Rare Water

3401  Bobby Langby  Third Generation  Extremely Rare Water

3402  Damu  Third Generation  Extremely Rare Grass

3403  Whirlpool Snail  Third Generation  Extremely Rare Insect

3404  Sea Serpent  Third Generation  Extremely Rare Water

3405  Hyrule  Third Generation  Extremely Rare Psychic

3406  Sunshine Holiday Freya  Third Generation  Extremely Rare Mystic

4101  Spida  Fourth Generation  Common Animal

4102  Arrow Feather Bird  Fourth Generation  Common Fire

4103  Blazing Mane Lion  Fourth Generation  Common Fire

4104  Dream Dragon  Fourth Generation  Common Mystic

4105  Three-Leaf Palm  Fourth Generation  Common Grass

4106  Sunflower Beast  Fourth Generation  Common Grass

4107  Spiny Rabbit  Fourth Generation  Common Grass

4108  Mysterious Little Bear  Fourth Generation  Common Fire

4109  Chef Lizard  Fourth Generation  Common Animal

4110  Maple Tail Fox  Fourth Generation  Common Animal

4111  Border Fox  Fourth Generation  Common Psychic

4112  Multi-Spirit Flower  Fourth Generation  Common Electric

4113  Electric Dragon Lizard  Fourth Generation  Common Electric

4114  Long-Tailed Dragon  Fourth Generation  Common Dragon

4115  Pipi  Fourth Generation  Common Electric

4116 Dora Fat  Fourth Generation  Common  Mysterious

4117  Black Snail Beast  Fourth Generation  Common  Mysterious

4201  Steel Armadillo  Fourth Generation  Rare  Steel

4202  Stone Armadillo  Fourth Generation  Rare  Rock

4203  Timid Crab  Fourth Generation  Rare  Ground

4204  Mushroom Hat Crab  Fourth Generation  Rare  Rock

4301  Golden Armadillo  Fourth Generation  Rare  Steel

4302  Mystery Dragon  Fourth Generation  Rare  Mysterious

4303  Thunderstorm Beast  Fourth Generation  Rare  Water

4304  Bitter Demon  Fourth Generation  Rare  Psychic

4305  Ghost Scale Salamander  Fourth Generation  Rare  Water

4306  Rabi  Fourth Generation  Rare  Animal

4307  Rock Pincer Beast  Fourth Generation  Rare  Rock

4308  Dream Dragon  Fourth Generation  Rare  Dragon

4309  Thunder Cat  Fourth Generation  Rare  Electric

4310  Wetland Dragon Lizard  Fourth Generation  Rare  Dragon

4311  Blazing Gaze Elena  Fourth Generation  Rare  Grass

4312  Morning Light Caroline  Fourth Generation  Rare  Rock

4313  Treasure Dragon  Fourth Generation  Rare  Dragon

4314  Clockwork Duck  Fourth Generation  Rare  Mysterious

4315  Phantom Amber Sturgeon  Fourth Generation  Rare  Water

4316  Split Blade  Fourth Generation  Rare  Grass

4317  Sand Electric Scorpion  Fourth Generation  Rare  Electric

4318  Ghost Scale Salamander  Fourth Generation  Rare  Water

4401  Phantom Amber Sturgeon  Fourth Generation  Extremely Rare  Water

4402  Tongue Lizard Beast  Fourth Generation  Extremely Rare  Animal

4403  Ancient Dog Scorpion  Fourth Generation  Extremely Rare  Insect

4404  Ghost Wave Butterfly  Fourth Generation  Extremely Rare  Water

4405  Crystal Shell Turtle  Fourth Generation  Extremely Rare  Water

4406  Forest Vine Overlord  Fourth Generation Extremely Rare Grass

4407 Energetic Bomb - Ji Chenyin  Fourth Generation Extremely Rare Psychic

5101 White Night Demon Fifth Generation Common Fire

5102 Ripple Tiger Fifth Generation Common Fire

5103 Rock Horn Dragon Fifth Generation Common Earth

5104 Pharaoh Cat Fifth Generation Common Steel

5105 White Rock Giant Fifth Generation Common Rock

5106 White Rock Statue Fifth Generation Common Rock

5107 Australian Deer Fifth Generation Common Fire

5108 Barbarian Deer Fifth Generation Common Earth

5110 Mini Sheep Fifth Generation Common Fire

5111 Dobby Fifth Generation Common Grass

5112 Extreme Frost Bear Fifth Generation Common Ice

5113 Arctic Seal Fifth Generation Common Ice

5114 Arctic Bird Fifth Generation Common Ice

5115 Bimong Bee Fifth Generation Common Electric

5116 Komodo Fifth Generation Common Electric

5117 Nemo Fifth Generation Common Electric

5118 Electric Seahorse Fifth Generation Common Electric

5119 Bomb Crocodile Fifth Generation Common Electric

5120 Fat Pufferfish Fifth Generation Common Water
5121 Abyssal Octopus  Fifth Generation Common Water

5122 Dark Crow Fifth Generation Common Mystery

5123 Fire Fox Fifth Generation Common Fire

5124 Little Fire Fox Fifth Generation Common Fire

5201 Steel Crystal Turtle Fifth Generation Rare Steel

5202 Dark Night Mouse Fifth Generation Rare Animal

5203 Leaf-Winged Frog Fifth Generation Rare Grass

5204 Pharaoh Dog Fifth Generation Rare Psychic

5205 Ice Plain Ape Fifth Generation Rare Ice

5206 Red-Eyed Spotted Beast Fifth Generation Rare Fire

5207 Bubble Cat Fifth Generation Rare Water

5208 Cold Wind Bear Fifth Generation Rare Ice

5209 Night Star Worm Fifth Generation Rare Electric

5210 Horned Beast Fifth Generation Rare Steel

5301 Octopus Cocoa Fifth Generation Rare Water

5302 Dream Bug Fifth Generation Rare Insect

5303 Dragon多多 Fifth Generation Rare Dragon

5304 Lucky Leaf Frog Fifth Generation Rare Grass

5305 Tower Flower Beast Fifth Generation Rare Ground

5306 Thunder Flame Fang Fifth Generation Rare Dragon

5307 Molten Tomb Dragon Fifth Generation Rare Dragon

5308 Thunder Strike Beast Fifth Generation Rare Electric

5309 Winter Spring Fifth Generation Rare Ice

5310 Radiance Fifth Generation Rare Mystery

5311 Swimming Sun Queen · Suriyin Fifth Generation Rare Water

5312 Blazing Sun General · Haruna Fifth Generation Rare Fire

5313 Ice Fang Mammoth Fifth Generation Rare Ice

5314 Lucky Leaf Frog Fifth Generation Rare Grass

5315 Cake Fifth Generation Rare Insect

5316 Gift Box Boxer Fifth Generation Rare Steel

5317 Christmas Elephant Fifth Generation Rare Animal

5318 Tower Flower Beast Fifth Generation Rare Ground

5319 Flat Ray Fifth Generation Rare Water

5401 Stone Bean Tyrant Fifth Generation Extremely Rare Rock

5402 Mushroom Fish Fifth Generation Extremely Rare Water

5403 Split-Shelled Dragon Lizard Fifth Generation Extremely Rare Dragon

5404 Ice Fang Mammoth Fifth Generation Extremely Rare Ice

5405 Grass Mound Fifth Generation Extremely Rare Grass

5406 Death Steel Stone Fifth Generation Extremely Rare Steel

5407 Gale Fist Kid - Nitta Hikaru Fifth Generation Extremely Rare Rock

6101 Ripple Snake Sixth Generation Common Ice

6102 Glass Butterfly Sixth Generation Common Insect

6103 Corrupted Thunder Beast Sixth Generation Common Electric

6104 Ice Peak Ape Sixth Generation Common Ice

6105 Ghost Shark Sixth Generation Common Mystery

6106 Ghost Hedgehog Sixth Generation Common Mystery

6107 One-Eyed Octopus Sixth Generation Common Mystery

6108 Blue Feather Sparrow Sixth Generation Common Psychic

6109 Soul-Leaving Insect Sixth Generation Common Psychic

6110 Nemesis Elephant Sixth Generation Common Psychic

6111 Starlight Jellyfish Sixth Generation Common Mystery

6112 Earth Mountain Turtle Sixth Generation Common Ground

6113 Tusked Pig Sixth Generation Common Ground

6114 Crystal Beetle Sixth Generation Common Rock

6115 Desert Lizard Sixth Generation Common Fire

6116 Boxing Kangaroo Sixth Generation Common Fire

6117 Steel Armored Rhino Sixth Generation Common Steel

6118 Dream Bat Sixth Generation Common Mystery

6119 Hypnotic Peacock Sixth Generation Common Psychic

6120 Steel Spike Beast  Sixth Generation  Common Steel

6121 Mechanical Bird  Sixth Generation  Common Steel

6123 Engineering Elephant  Sixth Generation  Common Steel

6124 Volcano Dragon  Sixth Generation  Common Fire

6125 Electromagnetic Dog  Sixth Generation  Common Electric

6126 Chameleon Deer  Sixth Generation  Common Grass

6127 Gluttonous Dragon  Sixth Generation  Common Electric

6201 Rainbow Koala  Sixth Generation  Rare Mystic

6202 Ice Snow Spirit Wave  Sixth Generation  Rare Ice

6203 Fachi  Sixth Generation  Rare Psychic

6204 Komi Sheep  Sixth Generation  Rare Steel

6205 Rainbow Dragon  Sixth Generation  Rare Psychic

6206 Dada Duck  Sixth Generation  Rare Animal

6207 Steel Fang Dog  Sixth Generation  Rare Steel

6208 Ore Beast  Sixth Generation  Rare Mystic

6209 Angel Eagle  Sixth Generation  Rare Electric

6301 Ghost Egg  Sixth Generation  Rare Mystic

6302 Lightning Sheep  Sixth Generation  Rare Electric

6303 Radiation Snake Flower  Sixth Generation  Rare Grass

6304 Bubble  Sixth Generation  Rare Water

6305 Bubble Jellyfish  Sixth Generation  Rare Water

6306 Gugu  Sixth Generation  Rare Animal

6307 Lala  Sixth Generation  Rare Grass

6308 Mud Hippo  Sixth Generation  Rare Water

6309 Sunshine Trainee - Natsume Rin  Sixth Generation  Rare Electric

6310 Fighting Girl - Emily  Sixth Generation  Rare Ground

6311 Candle Fox  Sixth Generation  Rare Fire

6312 Palm-tailed Frog  Sixth Generation  Rare Water

6313 Wave Sprite  Sixth Generation  Rare Grass

6314 Star Core Electric Spider  Sixth Generation  Rare Electric

6315 Pod Pod  Sixth Generation Rare Grass

6316 Fluffy Vine Sixth Generation Rare Grass

6317 Night Flower Sixth Generation Rare Mysterious

6318 Lanfu Sixth Generation Rare Water

6319 Cotton Seedling Sixth Generation Rare Ground

6320 Snow Hammer Sixth Generation Rare Ice

6321 Owl Griffin Sixth Generation Rare Fire

6322 Buu Sixth Generation Rare Ground

6323 Korokoro Sixth Generation Rare Electric

6401 Spore Dragon Sixth Generation Extremely Rare Dragon

6402 Three-Headed Carnivorous Plant Sixth Generation Extremely Rare Grass

6403 Potpot Sixth Generation Extremely Rare Grass

6404 Flower Dream Sixth Generation Extremely Rare Psychic

6405 Giant Beak Rock Sixth Generation Extremely Rare Rock

6406 Hunter Squid Sixth Generation Extremely Rare Ice

6407 Street Brother Bruno Sixth Generation Extremely Rare Ground

6408 Cotton Seedling Sixth Generation Extremely Rare Ground

7101 Joyful Feather Bird Seventh Generation Common Animal

7102 Leaf Blade Seventh Generation Common Insect

7103 Leaf Claw Beast Seventh Generation Common Grass

7104 Earth Dragon Beast Seventh Generation Common Ground

7105 Rock Fist Beast Seventh Generation Common Rock

7106 Babu Seventh Generation Common Mysterious

7107 Rakas Beast Seventh Generation Common Psychic

7108 Punch Raccoon Seventh Generation Common Steel

7109 Star Stream Deer Seventh Generation Common Electric

7110 Secret Love Bird Seventh Generation Common Animal

7111 Tree Elephant Beast Seventh Generation Common Ground

7112 Water Bubble Spirit Seventh Generation Common Water

7113 Tide Wave Wing Seventh Generation Common Fire

7114 Thunderclap Fish Seventh Generation Common Fire

7116 Fire Tiger  Seventh Generation Common Fire

7117 Fire-Winged Dragon Seventh Generation Common Dragon

7118 Spirit Squirrel Seventh Generation Common Animal

7119 Flame-Horned Beast Seventh Generation Common Rock

7120 Lava Fang Seventh Generation Common Fire

7201 Green Leaf Spirit Seventh Generation Rare Grass

7202 Winged Thunder Bug Seventh Generation Rare Electric

7203 Flower Fairy Seventh Generation Rare Mystic

7204 Flower-Winged Spirit Seventh Generation Rare Psychic

7205 Flower Melody Spirit Seventh Generation Rare Psychic

7206 Blue Flame Spirit Seventh Generation Rare Fire

7207 Blue Bat Beast Seventh Generation Rare Ice

7208 Vine Leaping Spirit Seventh Generation Rare Grass

7209 Mushroom Spirit Seventh Generation Rare Ground

7210 Crawling Crab Seventh Generation Rare Water

7211 Sparkling Bubble Fox Seventh Generation Rare Electric

7212 Sparkling Stone Spirit Seventh Generation Rare Ice

7213 Sparkling Leaping Fox Seventh Generation Rare Fire

7214 Deer Leaf Beast Seventh Generation Rare Grass

7301 Primordial Nucleus Organism - Qimi Seventh Generation Rare Psychic

7302 Neon Blade Maiden - Liyin Seventh Generation Rare Mystic

7303 Shadow Ember Seventh Generation Rare Dragon

7304 Candy Colt Seventh Generation Rare Animal

7305 Bubble Chirp Seventh Generation Rare Water

7306 Blazing Wolf Split Seventh Generation Rare Animal

7307 Frost Azure Sky Wing Seventh Generation Rare Dragon

7308 Burning Shadow Seventh Generation Rare Fire

7309 Enchanting Moon Spirit Seventh Generation Rare Mystic

7310 Leaping Star Monkey Seventh Generation Rare Animal

7311 Rock Refining Beast Seventh Generation Rare Rock

7312  Leaping Girl Kora  Seventh Generation  Rare Electric

7313  Thunderbolt Charge Weiming  Seventh Generation  Rare Electric

7314  Spine Beetle  Seventh Generation  Rare Insect

7315  Gingerbread Frost  Seventh Generation  Rare Psychic

7316  Snowflake  Seventh Generation  Rare Ice

7317  Seahorse Star  Seventh Generation  Rare Water

7318  Tuanlu Beast  Seventh Generation  Rare Grass

7319  Zandara Dragon  Seventh Generation  Rare Dragon

7401  Bubblefin Beast  Seventh Generation  Extremely Rare Mysterious

7402  潤波鯨  Seventh Generation  Extremely Rare Water

7403  Rootling Spirit  Seventh Generation  Extremely Rare Grass

7404  Star Strike Beast  Seventh Generation  Extremely Rare Psychic

7405  Flame Shadow Demon  Seventh Generation  Extremely Rare Fire

7406  Illusionary Law Divine Envoy Zhimiao  Seventh Generation  Extremely Rare Ice

7407  Passionate Discipline Lieyang  Seventh Generation  Extremely Rare Fire

7408  Azulon  Seventh Generation  Extremely Rare Rock

7409  Entwining Ghost  Seventh Generation  Extremely Rare Mysterious

7410  Blade Scale Shark  Seventh Generation  Extremely Rare Dragon

7411  Deadfin Whale  Seventh Generation  Extremely Rare Water

7412  Spine Beetle  Seventh Generation  Extremely Rare Insect

7413  Shimmering Mane Lion  Seventh Generation  Extremely Rare Psychic

100001  Rain God Yilianjiaqi  First Generation  Divine Water

100002  Moon God Alagus  First Generation  Divine Mysterious

100003  Fire God Lieluohuangnie  First Generation  Divine Fire

100004  Grass God Yahualimu  First Generation  Divine Grass

9001  Aiyinzi  Souvenir  Extremely Rare Fire

9002  Eric  Souvenir  Extremely Rare Mysterious

9003 Lingxue Commemorative Item Extremely Rare Ice

9004 KF Commemorative Item Extremely Rare Electric

9005 wawa Commemorative Item Extremely Rare Fire

9006 Tobe Commemorative Item Extremely Rare Rock

9007 EXIA Commemorative Item Extremely Rare Psychic

9008 YIMING Commemorative Item Extremely Rare Psychic

9060 Killa Commemorative Item Extremely Rare Rock

9061 An-chan Commemorative Item Extremely Rare Mysterious

9062 Snow White Maid Commemorative Item Extremely Rare Ice

9063 Bunny Girl Commemorative Item Extremely Rare Water

9064 Alice Commemorative Item Extremely Rare Steel

9065 ANO Commemorative Item Extremely Rare Mysterious

9066 Dragon's Dwelling Princess Commemorative Item Extremely Rare Dragon

9067 Fool Commemorative Item Extremely Rare Psychic

9068 ANT Commemorative Item Extremely Rare Psychic

9069 Cherry Blossom Girl Commemorative Item Extremely Rare Mysterious

9071 KaiKai is Here Commemorative Item Extremely Rare Mysterious

9072 Iron Pot Stewed Goose Commemorative Item Extremely Rare Mysterious

9073 Saka Caicai Commemorative Item Extremely Rare Mysterious

9074 Lengyang Junior Commemorative Item Extremely Rare Mysterious

1314 Cloud Mist Demon Holiday Card Pack Rare Electric

1315 Ghost Lantern Holiday Card Pack Rare Fire

1316 Poisonous Mushroom Holiday Card Pack Rare Grass

1317 Kemengduo Holiday Card Pack Rare Psychic

1318 Shadow Ghost Holiday Card Pack Rare Mysterious

1319 Pumpkin Head Holiday Card Pack Rare Earth

1320 Magic Fire Bat Holiday Card Pack Rare Animal

1321 Giant Mouth Demon Holiday Card Pack Rare Animal

1322 White Pepper Spirit Holiday Card Pack Extremely Rare Grass

1323 Little Bone Holiday Card Pack Extremely Rare Psychic
```



## 📮More API interfaces and extensions: Contact information
- QQ: 780231813
- Official QQ group (contact group owner): 958628027
- Email: yangyiming780@foxmail.com
- Steam Community Comments / Git Issues

---

## 🛡️Community Guidelines (Brief)
1. 🚫Content that is illegal, politically sensitive, pornographic, or violent/terrorist is prohibited.
2. Content that maliciously insults, incites conflict, or alludes to real-life figures is prohibited .
3. Unauthorized use of copyrighted resources is prohibited .
4. 🚫 It is prohibited to use mods to direct advertising, fundraising, or payment.
   
If a post on the Steam Workshop violates the above rules, it may be deleted immediately and the creator's privileges may be suspended.


