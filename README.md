# 🃏 《卡牌店模拟器 多人联机版》 Modding 示例 (CardShopSim Modding Example)

_这是一个使用 **Lua 语言** 编写的 Mod 示例，适用于《卡牌店模拟器 多人联机版》。_  
[中文](README.md)   | [English](README_EN.md)  
[📚 当前的 APIs](NotableAPIs_CH.md)

---

## 🧩 工作原理概述

游戏会自动扫描并读取以下位置的 Mod：

- `游戏根目录/CardShopSim/Mods` 📁  
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
- `dir`：当前 Mod 的绝对路径。
---

## 📁 Mod 文件夹结构

将 Mod 放入 `游戏根目录/CardShopSim/Mods/` 目录即可在游戏内识别。

```
CardShopSim/
└── Mods/
    └── MyMod/
        ├── main.lua       # Mod 逻辑（Lua 编写）
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
> 卡牌读取与保存全部由ID存储。ID和游戏中卡牌右上角ID一致。

---

### 🔧 最小可用示例（添加 / 覆盖卡数据）

```lua
local function ChangeCard()
    local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
    local D = UE.FCardDataAll()                  -- 创建卡牌数据
    D.Name = "ID1122"                            -- 卡牌名称（用于本地化Key）
    D.Description = "ID1122Description"          -- 描述（用于本地化Key）
    D.CardID = 1122                              -- 内部唯一ID（务必不与其他卡冲突）
    D.Gen = 0                                    -- 世代：0=第一世代  （0~6）1-7世代
    D.TexturePath = dir .. "1122.png"            -- 贴图路径（与 main.lua 同目录）
    D.Rarity = UE.ECardRarity.Common             -- 稀有度（枚举见下）
    D.BaseAttack = 10                            -- 基础攻击
    D.BaseHealth = 30                            -- 基础生命
    D.CardElementFaction:Add(UE.ECardElementFaction.Water) -- 元素（水）

    -- 💥 当前攻击力与生命值计算公式（算法见下方说明）
    -- 最终攻击力 = 基础攻击力 × 当前卡框倍率
    -- 最终生命值 = 基础生命值 × 当前卡框倍率

    R:RegisterCardData(D.CardID, D)              -- 注册（添加或覆盖）
end
```

---
### 🔧 极其稀有卡图片替换示例

```lua
local function ChangeCard()
    local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
    --极稀有卡有6个图层。序号越前，距离玩家摄像机越进。TexturePath6是最底层可以放背景。前面5层可以放透明的图片。做出来分层效果
    local D = UE.FCardDataAll()
    D.Name = "ID1401"
    D.Description = "ID1401Description"
    D.CardID = 1401
    D.TexturePath = dir .. "1401.png"      --第一层的人物
    D.TexturePath2 = dir .. "1401-2.png"    --第二层的特效
    -- D.TexturePath3 = dir .. "1401-3.png" 演示中只有三层 这三层空置
    -- D.TexturePath4 = dir .. "1401-4.png" 演示中只有三层 这三层空置
    -- D.TexturePath5 = dir .. "1401-5.png" 演示中只有三层 这三层空置
    D.TexturePath6 = dir .. "1401-6.png"    --最下层的背景

    R:RegisterCardData(D.CardID, D)              -- 注册（添加或覆盖）
end
```

---

## 📊 卡框倍率参考表

| 卡框类型 | 倍率 | 示例说明 |
|-----------|------|-----------|
| 基础 | 1.0 | 基础倍率 |
| 白银 | 1.1 | 白银卡框攻击与生命 +10% |
| 黄金 | 1.2 | 黄金卡框攻击与生命 +20% |
| 镭射 | 1.3 | 镭射卡框攻击与生命 +30% |
| 闪亮 | 1.4 | 闪亮卡框攻击与生命 +40% |
| 稀世 | 1.5 | 稀世卡框攻击与生命 +50% |

> 🧮 计算示例：若基础攻击力为 100，卡框为黄金(1.2)，则最终卡面显示攻击力 = 100 × 1.2 = **120**。

---

### 🏷️ 枚举（稀有度 / 元素）

```lua
-- 稀有度：
UE.ECardRarity.Common --普通
UE.ECardRarity.UnCommon --罕见
UE.ECardRarity.Rare --稀有
UE.ECardRarity.SuperRare --极稀有
UE.ECardRarity.God --神卡

-- 元素：
UE.ECardElementFaction.Fire --火
UE.ECardElementFaction.Water --水
UE.ECardElementFaction.Grass --草
UE.ECardElementFaction.Electric --电
UE.ECardElementFaction.Insect --昆虫
UE.ECardElementFaction.Rock --岩石
UE.ECardElementFaction.Earth --土
UE.ECardElementFaction.Animal --动物
UE.ECardElementFaction.Steel --钢
UE.ECardElementFaction.Dragon --龙
UE.ECardElementFaction.Psychic --超能
UE.ECardElementFaction.Mystic --神秘
UE.ECardElementFaction.Ice --冰
```

---

## ✅ 完整可运行示例：替换\添加卡面（`main.lua`）

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

## 📮 更多API接口以及扩展：联系方式
- QQ：780231813  
- 官方QQ群（联系群主）：958628027  
- Email：yangyiming780@foxmail.com  
- Steam 社区留言 / Git issues

---

## 🛡️ 社区准则（简要）
1. 🚫 禁止违法、政治敏感、色情、暴恐等内容。  
2. 🚫 禁止恶意侮辱、引战对立、影射现实人物的内容。  
3. 🚫 禁止未获授权使用受版权保护的资源。  
4. 🚫 禁止以 Mod 形式引导广告、募捐或付费。
   
若在 Steam 创意工坊发布且违反以上条目，可能被直接删除并封禁相关创作者权限。
