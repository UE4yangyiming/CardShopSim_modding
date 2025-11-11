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

---

### 🔧 Minimal Example (Add or Override Card Data)

```lua
-- Assume dir = image directory (same as main.lua)
-- Assume R = Card Registry Subsystem (see below)
local function ChangeCard()
    local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
    local D = UE.FCardDataAll()                  -- Create card data struct
    D.Name = "ID1122"                            -- Card name (used for localization key)
    D.Description = "ID1122Description"          -- Description (used for localization key)
    D.CardID = 1122                              -- Unique internal ID (must not conflict)
    D.Gen = 0                                    -- Generation: 0 = Gen1 (0–6)
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
local function AddGen1Card()
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
    AddGen1Card()
end

function M.OnTick(dt)
end

return M
```

---

## 📮 Contact
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
