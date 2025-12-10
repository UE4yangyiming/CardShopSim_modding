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
M.OnTick(dt) -- Executes every frame
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

function M.OnTick(dt)
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

---
## Existing IDs （The following is an AI translation only.）
```lua
1102 Miniature Gen 1st Generation
1103 Tough Bear Cub Gen - Generation 1
1104 Turabi Gen Generation 1
1105 Electivire Gen (First Generation)
1106 MuTi Gen First Generation
1107 Electric Dog Gen First Generation
1108 Ice Hole Rat Gen Generation 1
1109 Butterfly Gen - Generation 1
1110 AmyNyan Gen First Generation
1111 Ice Cave Otter Gen. First Generation
1112 Strange Itachi Gen 1st Generation
1113 Lesson Fox Gen 1st Generation
1114 Koos Gen 1st Generation
1115 Berry-tailed Monkey Gen 1
1116 Bouncing Mouse Gen 1st Generation
1117 Crocus Gen 1st Generation
1118 Leafy Gen Generation 1
1119 Gautama Gen Generation 1
1120 Gen 1
1121 Cursed Owl Gen Generation 1
1201 Rockhelmi Gen Generation 1
1202 White Pigmon Gen Generation 1
1203 Snow Fairy Gen 1
1204 Zhang Bobo Gen First Generation
1205 Kaki Fox Gen 1st Generation
1206 Pan Xiaoda Gen First Generation
1207 Volcano Spider Gen Generation 1
1208 Thunder Sculptor Gen 1st Generation
1209 Vampire Bat Gen Generation 1
1210 Whitebat Gen Generation 1
1211 Disaster Lizard Gen. Generation 1
1212 Ice Spine Dragon Gen Generation 1
1213 Young Ice Spine Dragon Gen. Generation 1
1301 Mineral Eye King Gen First Generation
1302 Desmo Gen 1st Generation
1303 Fire Emblem Wolf Gen. First Generation
1304 Tidal Wave Gen Generation 1
1305 Ghost Butterfly Gen (First Generation)
1306 Articuno Gen Generation 1
1307 Mischief Gen.1
1308 Articuno Gen Generation 1
1309 Magnet Beetle Gen First Generation
1310 Strike Demon Gen. First Generation
1311 Rainbow Catfish Gen Generation 1
1312 Bubu Gen - Generation 1
1313 Gekirai-Gen (First Generation)
1401 Heterochromatic Eyes Gen 1st Generation
1402 Flame Feather Owl Gen First Generation
1403 Mind Reading Cat Gen (First Generation)
1404 King of Fighters Gen.1
2101 Gen. 2
2102 Zhang Pipi Gen Second Generation
2103 Grasstail Gen 2
2104 Rock Kusunoki Gen 2nd Generation
2105 Dazzling Monkey Gen 2
2106 Gem Bear Gen 2
2107 Shadow Dragon Gen 2nd Generation
2108 Ghost Jellyfish Gen 2nd Generation
2109 Burning Mane Fox Gen 2nd Generation
2110 Bifin Dragon Gen 2
2111 Mushroom Bunny Gen 2nd Generation
2112 Gekiramon Gen 2nd Generation
2113 Mimi Fox Gen 2nd Generation
2114 Ender Rat Gen 2
2115 Tree Imp Gen 2nd Generation
2201 Magma Gen 2nd Generation
2202 Fossil Fish Gen Second Generation
2203 Boomtail Frog Gen 2
2204 Butterfly Rabbit Gen 2nd Generation
2205 Gullion Gen 2nd Generation
2206 Silk Songworm Gen 2nd Generation
2301 Valley Hedgehog Gen 2
2302 Tsunami Otter Gen 2nd Generation
2303 Liluya Gen (Second Generation)
2304 Shenmo Lamp Gen 2
2305 Pokémon Gen 2nd Generation
2306 Cang Guan Gen second generation
2307 Raichugen Gen 2nd Generation
2308 Stone-breaking Pig Gen 2
2309 Hammersmith Gen 2
2310 Fugui Gen 2nd generation
2311 Sleepy Otter Gen 2nd Generation
2312 Dora Gen 2nd Generation
2401 Elysium Gen 2nd Generation
2402 Cactus Gen 2nd Generation
2403 Phantasmon Gen 2nd Generation
2404 Ancient Rock Whale Gen 2nd Generation
2405 Fujiyu Itachi Gen 2
3101 Urodi Gen (Third Generation)
3102 Masked Bear Gen (Third Generation)
3103 Mechanical Snake Gen 3rd Generation
3104 Locktooth Gen 3rd Generation
3105 Paipai Gen (Third Generation)
3106 Wind Fang Gen (Third Generation)
3107 Electric Monkey Gen 3rd Generation
3108 Ice Storm Gen 3rd Generation
3109 BitCat Gen 3rd Generation
3110 Starmon Gen 3rd Generation
3111 Graveyard Sheep Gen 3rd Generation
3112 Centrino Gen 3rd Generation
3113 Jaeger Gen 3rd Generation
3114 Steel Guardian Gen 3rd Generation
3115 Banteli Gen 3rd Generation
3201 Snowfoot Meerkat Gen, Third Generation
3202 Electric Claw Dragon Gen 3rd Generation
3203 Yuta Gen (Third Generation)
3204 Clean Sheep Gen 3rd Generation
3205 Maple Deer Gen 3rd Generation
3206 Ant King Gen 3rd Generation
3207 Honeywing Bee Gen, Third Generation
3208 Honeywing Ant Gen 3rd Generation
3209 Asamizu Kasumi Gen 3rd Generation
3210 Cherry Eye Shark Gen 3rd Generation
3301 Fire Nugget Gen 3rd Generation
3302 Bloodmoon Gen (Third Generation)
3303 Bag Gen 3rd Generation
3304 Fighting Priest Gen 3rd Generation
3305 Wu Kong Gen third generation
3306 Mad Golden Leopard Gen 3rd Generation
3307 Ziralus Gen (Third Generation)
3308 Mudmo Gen (Third Generation)
3309 Dawn Traveler Luna Gen Third Generation
3310 Sunshine Captain Linda Gen (Third Generation)
3401 Poppy & Ramby Gen 3rd Generation
3402 Damu Gen (Third Generation)
3403 Slug Gen (Third Generation)
3404 Sea of the Female Gen, Third Generation
3405 Herul Gen 3rd Generation
3406 Sunny Holiday · Freya Gen 3rd Generation
4101 Spyder Gen 4th Generation
4102 Arrowbird Gen 4th Generation
4103 Burning Mane Lion Gen 4th Generation
4104 Phantasy Dragon Gen 4th Generation
4105 Trifolium Gen 4th Generation
4106 Sunflower Gen 4th Generation
4107 Spiky Bunny Gen 4th Generation
4108 Little Bear Gen 4th Generation
4109 Chef Lizard Gen 4th Generation
4110 Maple-tailed Fox Gen 4th Generation
4111 Border Fox Gen 4
4112 Dorindor Gen 4th Generation
4113 Electric Dragon Gen 4th Generation
4114 Aoandon Gen 4th Generation
4115 Pipi Gen 4th Generation
4116 Dora Fat Gen 4th Generation
4117 Black Snail Beast Gen 4th Generation
4201 Steel Armor Gen 4th Generation
4202 Ishiyama Armor Gen 4th Generation
4203 Timid Crab Gen 4th Generation
4204 Mushroom Cap Crab Gen 4th Generation
4301 Jinshanjia Gen 4th Generation
4302 Mysterious Dragon Gen 4th Generation
4303 Thundermon Gen 4th Generation
4304 Bitter Demon Gen 4th Generation
4305 Toxtricity Gen 4th Generation
4306 Rabi Gen 4th Generation
4307 Rockbiter Gen 4
4308 Imagine Dragons Gen 4
4309 Raichan Gen 4th Generation
4310 Wetland Dragon Lizard Gen 4th Generation
4311 Blazing Vision: Elena Gen 4th Generation
4312 Dawn Caroline Gen 4th Generation
4401 Phantom Sturgeon Gen 4th Generation
4402 Glossopteryx Gen 4th Generation
4403 Ancient Dog Scorpion Gen 4th Generation
4404 Ghost Butterfly Gen 4th Generation
4405 Crystal Turtle Gen 4th Generation
4406 Forest Lord Gen 4th Generation
4407 Vitality Bomb - Ji Chenyin Gen 4th Generation
5101 Night Demon Gen 5th Generation
5102 Rengoku Gen 5th Generation
5103 Rockhorn Gen 5
5104 Pharaoh Cats Gen 5th Generation
5105 White Rock Giant Gen fifth generation
5106 White Rock Statue Gen 5
5107 Aubon Deer Gen 5th Generation
5108 Manbang Deer Gen 5th Generation
5110 Mini Sheep Gen 5th Generation
5111 Dobby Gen 5th Generation
5112 Polar Bear Gen 5th Generation
5113 Polar Seal Gen 5th Generation
5114 Articuno Gen 5th Generation
5115 BeeBee Gen 5th Generation
5116 Komodo Gen (Fifth Generation)
5117 Nemo Gen 5th Generation
5118 Electric Haima Gen 5th Generation
5119 Bomb Crocodile Gen 5th Generation
5120 Fat Fugu Gen fifth generation
5121 Abyss Octopus Gen 5th Generation
5122 Ravenclaw Gen 5th Generation
5123 Firefox Gen 5th Generation
5124 Firefox Gen 5th Generation
5201 Steel Crystal Turtle Gen 5th Generation
5202 Darkrat Gen 5th Generation
5203 Leafwing Frog Gen 5th Generation
5204 Pharaoh Gen 5th Generation
5205 Gen. V: Ice Giant
5206 Akame Madara Gen 5th Generation
5207 Bubble Cat Gen 5th Generation
5208 Coldwind Bear Gen 5th Generation
5209 Noctiluca Gen 5th Generation
5210 Horned Beast Gen 5th Generation
5301 Octopus Cocoa Gen 5th Generation
5302 Dream Bug Gen 5th Generation
5303 DragonDodo Gen 5th Generation
5304 Folios Gen 5
5305 Tower Flower Beast Gen 5th Generation
5306 Raikou Gen 5th Generation
5307 Lava Tomb Dragon Gen 5th Generation
5308 Thunder Beast Gen 5th Generation
5309 Winterspring Gen 5th Generation
5310 Shining Gen 5th Generation
5311 Swimming Queen Su Liyin Gen 5th Generation
5312 Blazing Youth: Kasugana Gen 5
5401 Stone Bean Little Tyrant Gen 5th Generation
5402 Mushroom Fish Gen 5th Generation
5403 Armored Lizard Gen 5th Generation
5404 Icefang Mammoth Gen 5th Generation
5405 Grasshopper Gen 5th Generation
5406 Steel Stone Gen 5th Generation
5407 Gale Punch Boy - Nitta Hikaru Gen. 5th Generation
6101 Ripple Gen VI
6102 Glass Butterfly Gen 6th Generation
6103 Corrupted Thunder Beast Gen VI
6104 Ice Ape Gen VI
6105 Ghost Shark Gen VI
6106 Ghost Hedgehog Gen VI
6107 One-Eyed Octopus Gen VI
6108 Blue Finch Gen VI
6109 Soul-Stealing Insect Gen VI
6110 Nemesis Gen 6th Generation
6111 Starlight Jellyfish Gen 6th Generation
6112 Turtle Gen VI
6113 Tusked Boar Gen VI
6114 Crystal Beetle Gen VI
6115 Rock Lizard Gen VI
6116 Boxing Kangaroo Gen 6th Generation
6117 Steel Rhino Gen VI
6118 Mewbat Gen VI
6119 Hypnotic Peacock Gen 6th Generation
6120 Steelix Gen VI
6121 Mechanical Bird Gen VI
6123 Engineering Gen 6th Generation
6124 Volcano Dragon Gen VI
6125 Electromagnetic Dog Gen 6th Generation
6126 Chameleon Gen 6
6127 Gluttonous Dragon Gen VI
6201 Rainbow Koala Gen 6th Generation
6202 Hyōyuki Ryōbō Gen (Sixth Generation)
6203 Faki Gen 6th Generation
6204 Comic Sheep Gen 6th Generation
6205 Rainbow Dragon Gen VI
6206 Duck Gen 6
6207 Steel-Toothed Dog Gen 6th Generation
6208 Gore-Gen (Generation VI)
6209 Angel Hawk Gen VI
6301 Goblin Egg Gen VI
6302 Lightning Sheep Gen VI
6303 Radial Serpent Flower Gen 6th Generation
6304 Bubble Gen 6th Generation
6305 Bubble Jellyfish Gen 6th Generation
6306 Gugu Gen 6th Generation
6307 Lala Gen 6th Generation
6308 Mud Hippo Gen 6th Generation
6309 Sunshine Trainee - Natsume Rin Gen 6th Generation
6310 Fighting Girl Emily Gen 6th Generation
6311 Candle Fox Gen VI
6312 Palmtail Gen VI
6313 Naniwa Gen 6th Generation
6314 Star Core Electric Spider Gen VI
6315 Pod Gen 6th Generation
6316 Velvet Vine Gen 6th Generation
6317 Nightflower Gen 6th Generation
6401 Sporodon Gen VI
6402 Three-headed Man-eating Flower Gen VI
6403 Pot Pot Gen 6th Generation
6404 Flower Dream Gen 6th Generation
6405 Giant Rock Gen VI
6406 Squid Gen 6
6407 Street Guy Bruno Gen 6th Generation
6408 Cotton Seedling Gen 6th Generation
7101 Raibou Gen (7th Generation)
7102 Leaf Blade Gen VII
7103 Leafclaw Gen VII
7104 Garchomp Gen VII
7105 Rockfist Gen VII
7106 BabuGen (Seventh Generation)
7107 Lakamon Gen VII
7108 PK Cobra Gen VII
7109 Starflow Deer Gen 7th Generation
7110 Dark Bird Gen (Seventh Generation)
7111 Gen VII (Gen)
7112 Bubble Spirit Gen 7th Generation
7113 Tidewing Gen 7th Generation
7114 Thunderfish Gen 7th Generation
7115 Firetail Gen VII
7116 Fire Tiger Gen 7th Generation
7117 Firewing Gen VII
7118 Gen 7 (Squirrel Generation 7)
7119 Embergron Gen VII
7120 Lava Fang Gen (7th Generation)
7201 Leafeon Gen 7th Generation
7202 Winged Raider Gen VII
7203 Flower Fairy Gen VII
7204 Flower Winged Spirit Gen 7th Generation
7205 Flower Spirit Gen 7th Generation
7206 Blue Flame Spirit Gen VII
7207 Bluebat Gen VII
7208 Fujiyuu Rei Gen 7th Generation
7209 Mushroom Spirit Gen 7th Generation
7210 Crab Gen 7th Generation
7211 Bubble Fox Gen 7th Generation
7212 Greedy Spirits Gen VII
7213 Fox Leap Gen 7th Generation
7214 Leafeon Gen VII
7301 Protocore Sequence - Kira Gen 7th Generation
7302 Neon Girls: Rion Gen 7th Generation
7303 Ember Gen 7th Generation
7304 Sugar Horse Gen (Seventh Generation)
7305 Bubble Chug Gen (Seventh Generation)
7306 Blazing Wolf Gen 7th Generation
7307 Frost Azure Wings Gen VII
7308 Burning Shadow Gen 7th Generation
7309 Moonlit Spirit Gen 7th Generation
7310 Leaping Star Monkey Gen 7th Generation
7311 Rock-type Beast Gen VII
7312 Kola Gen 7th Generation
7313 Thunder Explosion Charge - Guardian Rumble Gen 7th Generation
7401 Bubblefin Gen VII
7402 Runbo Whale Gen 7th Generation
7403 Genmiaoling Gen 7th Generation
7404 Starstrike Beast Gen VII
7405 Flame Demon Gen VII
7406 Illusionary Divine Messenger - Zhimiao Gen (Seventh Generation)
7407 Hot-Blooded Chronicle: Blazing Sun Gen 7th Generation
7408 Azron Gen 7th Generation
7409 Enchanted Mumu Gen 7th Generation
7410 Bladescale Shark Gen VII
7411 Deathfin Whale Gen VII
7412 Spinybug Gen VII
7413 Lion of the Seventh Generation
100001 Rain God - Ripple Gage Gen First Generation
100002 Luna Aragon Gen First Generation
100003 Vulcan·Lieluo Huangni Gen First Generation
100004 Grass God Sprout Tree Gen First Generation
9001 A-Yin Purple Gen Souvenir
9002 Eric Gen Souvenir
9003 Lingxue Gen Souvenir
9004 KF Gen Souvenirs
9005 Wawa Gen Souvenirs
9006 Tobe Gen Souvenirs
9007 EXIA Gen Souvenir
9008 YIMING Gen Souvenirs
9060 Killa Gen Souvenirs
9061 An-chan Gen Souvenir
9062 Snow White Maid Gen Souvenir
9063 Bunny Girl Gen Souvenir
9064 Alice Gen Souvenirs
9065 ANO Gen Souvenirs
9066 Dragon's Nest Princess Gen Souvenir
9067 Fool's Gen Souvenir
9068 ANT Gen Souvenirs
9069 Sakura Girl Gen Souvenir
9071 KaiKai is here - Gen Souvenir
9072 Iron Pot Stewed Goose (Gen) Souvenir
9073 Saka Cai Cai Gen Souvenirs
9074 Cold Sun Junior Gen Souvenir
1314 Cloud Fairy Gen Holiday Card Pack
1315 Hozuki Gen Holiday Card Pack
1316 Poisonous Mist Gen Holiday Card Pack
1317 Komondo Gen Holiday Card Pack
1318 Shadow Spectre Gen Holiday Card Pack
1319 Pumpkin Head Gen Holiday Card Pack
1320 Firebat Gen Holiday Card Pack
1321 Giant Mouth Demon Gen Holiday Card Pack
1322 White Pepper Gen Holiday Card Pack
1323 Little Bone Gen Holiday Card Pack
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


