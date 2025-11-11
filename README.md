# 🃏 CardShopSim Modding 示例 (CardShopSim Modding Example)

_《卡牌店模拟器 多人联机版》的 Mod 示例说明。_  
中文 | [English](README_EN.md)  
[📚 值得注意的 API](Documents/NotableAPIs_CN.md)

---

## 🧩 工作原理概述

游戏会自动扫描并读取以下位置的 Mod：

- `CardShopSim/Mods` 📁  
- 从 **Steam 创意工坊** 订阅的物品文件夹 🛠️

当找到满足条件的文件：`main.lua` 与 `preview.png`，即可在 **Mods** 菜单中识别、管理并加载该 Mod。

---

### ⚙️ 规则一：加载与执行
- 进入游戏约 **1 秒** 后，按 Mod 路径顺序加载并依次执行：  
  ```lua
  M.OnInit()   -- 初始化时执行一次
  M.OnTick(dt) -- 每帧执行
  ```

### 🧠 规则二：全局访问
- `UE`：全局变量，可访问 Unreal Engine 暴露的函数集合。  
- `M`：当前 Mod 的信息结构（会在主界面 Mods 列表中显示）。

---

## 📁 Mod 文件夹结构

将 Mod 放入 `CardShopSim/Mods/` 目录即可在游戏内识别。

```
CardShopSim/
└── Mods/
    └── MyMod/
        ├── main.lua       # Mod 逻辑
        └── preview.png    # 预览图（256×256，正方形）
```

👉 [示例 Mod ](Example_ZH/)

---

## 🧾 `main.lua` 的 `M` 结构

`local M = {}` 建议包含：

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | string | Mod 唯一 ID（英文，作为 Key） |
| `name` | string | 显示名称 |
| `description` | string | 描述 |
| `version` | string | 版本号 |
| `author` | string | 作者 |

> ✅ 你可以在 `M` 旁自由声明本地状态/变量，供 Mod 内部使用。

---

## 🖼️ 卡牌添加/替换（示例）

### 📐 图片分辨率建议
| 类型 | 推荐分辨率 |
|---|---|
| 普通 / 罕见 / 稀有 | `512×446` |
| 极稀有 / 神卡 | `747×1024` |

> 💡 **卡牌 ID 规则**：建议 `1000–9999`，**不可重复**。同一张卡的“卡框”通过 **（卡牌 ID × 10）+ 框位** 表示（例：`11012` = 卡牌 1101 + 银卡框）。

### 🔧 最小可用示例（添加 / 覆盖卡数据）

```lua
-- 假设 dir = 你放置图片的目录（与 main.lua 同级）
-- 假设 R = 卡牌注册子系统（下方给出获取方式）
local function ChangeCard(dir, R)
    local D = UE.FCardDataAll()                  -- 创建卡牌数据
    D.Name = "ID1122"                            -- 卡牌名称（用于本地化Key）
    D.Description = "ID1122Description"          -- 描述（用于本地化Key）
    D.CardID = 1122                              -- 内部唯一ID（务必不与其他卡冲突）
    D.Gen = 0                                    -- 世代：0=第一世代（0~6）
    D.TexturePath = dir .. "1122.png"            -- 贴图路径（与 main.lua 同目录）
    D.Rarity = UE.ECardRarity.Common             -- 稀有度（枚举见下）
    D.BaseAttack = 10                            -- 基础攻击
    D.BaseHealth = 30                            -- 基础生命
    D.CardElementFaction:Add(UE.ECardElementFaction.Water) -- 元素（水）
    R:RegisterCardData(D.CardID, D)              -- 注册（添加或覆盖）
end
```

### 🏷️ 枚举（稀有度 / 元素）

```lua
-- 稀有度：
UE.ECardRarity.Common
UE.ECardRarity.UnCommon
UE.ECardRarity.Rare
UE.ECardRarity.SuperRare
UE.ECardRarity.God

-- 元素：
UE.ECardElementFaction.Fire
UE.ECardElementFaction.Water
UE.ECardElementFaction.Grass
UE.ECardElementFaction.Electric
UE.ECardElementFaction.Insect
UE.ECardElementFaction.Rock
UE.ECardElementFaction.Earth
UE.ECardElementFaction.Animal
UE.ECardElementFaction.Steel
UE.ECardElementFaction.Dragon
UE.ECardElementFaction.Psychic
UE.ECardElementFaction.Mystic
UE.ECardElementFaction.Ice
```

---

## ✅ 完整可运行示例：替换卡面（`main.lua`）

```lua
-- 必填信息：会显示在 Mods 界面
local M = {
    id          = "ChangeGen1Card",
    name        = "示例名称",
    version     = "1.0.0",
    author      = "yiming",
    description = "示例描述",
}

-- 你可以把资源放在与 main.lua 同级目录
local function get_mod_dir()
    -- 推荐用工程/打包通用的方式获取目录（任选其一）
    -- return UE.UModFilesystemLib.GetProjectModsDir() .. "ChangeGen1Card/"
    -- return UE.UModFilesystemLib.GetLaunchModsDir() .. "ChangeGen1Card/"
    return UE.UModFilesystemLib.GetSmartModDir("ChangeGen1Card")
end

local function AddGen1Card()
    local world = MOD.GAA.WorldUtils:GetCurrentWorld()
    local R = UE.UCardFunction.GetCardRegistryWS(world)
    if not R then
        if MOD and MOD.Logger then MOD.Logger.LogScreen("找不到 CardRegistryWS", 5,1,0,0,1) end
        return
    end

    local dir = get_mod_dir()
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
    -- 留空或做心跳逻辑
end

return M
```

---

## 📮 联系方式
- QQ：780231813  
- 官方QQ群（联系群主）：958628027  
- Email：yangyiming780@foxmail.com  
- Steam 社区留言 / 本帖留言

---

## 🛡️ 社区准则（简要）
1. 🚫 禁止违法、政治敏感、色情、暴恐等内容。  
2. 🚫 禁止恶意侮辱、引战对立、影射现实人物的内容。  
3. 🚫 禁止未获授权使用受版权保护的资源。  
4. 🚫 禁止以 Mod 形式引导广告、募捐或付费。  
5. 🤖 使用 AI 生成内容的 Mod 需明确标注。  

若在 Steam 创意工坊发布且违反以上条目，可能被直接删除并封禁相关创作者权限。
