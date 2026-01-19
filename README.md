# 《卡牌店模拟器 多人联机版》 Modding 示例 (CardShopSim Modding Example)

_这是一个使用 **Lua 语言** 编写的 Mod 示例，适用于《卡牌店模拟器 多人联机版》。_  
[中文](README.md)   | [English](README_EN.md)  
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
| 普通 / 罕见 | `512×446` |
| 稀有 / 极稀有 / 神卡 | `747×1024` |

> 💡 **卡牌 ID 规则**：建议 `1000–9999`，**不可重复**。同一张卡的“卡框”通过 **（卡牌 ID × 10）+ 框位** 表示（例：`11012` = 卡牌 1101 + 银卡框）。
> 卡牌读取与保存全部由ID存储。ID和游戏中卡牌右上角ID一致。



> 💡 **一个函数中最多加入200个loacl变量，加入卡数量过多可以分成两个local function函数**
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
	--D.CardValueMulti = 1.0                     --新增基础价格倍率
	--D.UseBigImage = true                 		 --使用极其稀有的材质 稀有卡牌默认是没有6层材质的。只有D.TexturePath
    D.CardElementFaction:Add(UE.ECardElementFaction.Water) -- 元素（水）

    -- 💥 当前攻击力与生命值计算公式（算法见下方说明）
    -- 最终攻击力 = 基础攻击力 × 当前卡框倍率
    -- 最终生命值 = 基础生命值 × 当前卡框倍率

    R:RegisterCardData(D.CardID, D)              -- 注册（添加或覆盖）
end
```
---

---
### 🔧 极其稀有卡图片替换示例
> 💡 **如果希望普通罕见稀有卡使用极其稀有卡面**：需要在设置属性中 加入D.UseBigImage = true
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

    --D.FlowTexturePath = dir .. "fire.PNG"  --背景漂浮例子的图片  (可以添加背景漂浮粒子图片 半透明）
    --D.FlowValue = 1      --背景漂浮粒子图片的透明度 0-1  （默认0不显示）
	--D.FlowSpeedX = 0.1     --背景漂浮粒子向左持续移动0.1 
    --D.FlowSpeedY = -0.1     --背景漂浮粒子向下持续移动0.1

	--D.CardValueMulti = 1.0                     --基础价格倍率 （默认1.0倍）

    R:RegisterCardData(D.CardID, D)              -- 注册（添加或覆盖）
end
```
---


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
--所有卡牌的稀有度都需要你填入，不然就会是默认的稀有度“普通”。
--神卡可以使用任何元素。
--开启神卡时可以开出卡牌表格中所有有的神卡类型。
--目前游戏中只做了四种特效、其他神卡特效开出时使用雨神特效。
--自定义添加的神卡边框会闪亮、属性为神卡，价格相同。 中心飘动效果因为无法自定义设置材质，无法设置为闪亮。

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
	--D.CardValueMulti = 1.0                     --新增基础价格倍率
    D.CardElementFaction:Add(UE.ECardElementFaction.Water)
    R:RegisterCardData(D.CardID, D)
end

function M.OnInit()
    AddCard()
end

return M
```

---
## ✅ 示例：添加的接口 修改支付方式  仅用扫码支付
将设置支付方式的函数通过覆盖函数 修改原逻辑 
>2026.1.19更新

>本示例展示了如何通过 Hook（覆盖）原有的 GetPayMentOverall 函数，将所有收银台的支付方式强制锁定为 扫码支付。
>
> ⚠️ 注意事项 (Host Only) 此脚本仅在主机端（房主）运行有效。
>
> 由于收银功能完全在服务器端运行，修改主机的逻辑将同步影响所有连接的客户端（其他玩家）。
>
> 🛠️ 实现原理
>
> 获取状态：顾客在支付时会获取主机的 PlayerState。（这里要使用M的函数，而不是localFunction，可能PlayerState的加载时间在Mod之后，所以Timer和函数区域不能写错）。
>
> 拦截调用：系统调用 GetPayMentOverall 获取支付方式（原逻辑为随机返回 0~2）。
>
> 覆盖结果：我们拦截该函数并强制返回 2（扫码），从而改变收银台的具体表现
>
> 联系作者添加简单的修改接口
```lua
function M:try_patch()  --这里注意M:

	if not MOD or not MOD.Playercontroller or MOD.Playercontroller.PlayerIndex == -1 then
		-- PlayerController 还没就绪，稍后重试
		MOD.GAA.TimerManager:AddTimer(1, M, M.try_patch)
		return
	end

	local pc         = MOD.Playercontroller
	local key        = "BasePlayerState0" --获得玩家的BP_PlayerState
	local klass      = pc.GetLuaObject and pc:GetLuaObject(key) or nil  --获得当前BP_PlayerState的lua文件

    if pc.PlayerIndex and pc.PlayerIndex ~= 0  then
        return --客户端找不到BasePlayerState0，这里要return。防止客户端重复检查。
    end

    if not klass then
		MOD.GAA.TimerManager:AddTimer(1, M, M.try_patch)
        return
    end

    klass.GetPayMentOverall = function(self)
        --原函数是随机三个数值
        --0 --现金
        --1 --刷卡器
        --2 --扫码
        -- return MOD.UE.UKismetMathLibrary.RandomIntegerInRange(0, 2) --调用UE函数随机数值

        MOD.Logger.LogScreen("拦截收银", 5, 0, 1, 0, 1)
        return 2
    end
end
-- OnInit 也要改一下调用方式
function M.OnInit()
    M:try_patch()  --这里M:
end
```
> 💡 **额外PlayerState接口**：使用方法是加入到上方klassfunction之后。
```lua
	--当结账完成时，结账的每一张卡触发一次事件
    klass.OnCardSoldOverall = function(self,CardID)
        MOD.Logger.LogScreen("收银结账卡牌完成, CardID = " .. tostring(CardID),5, 0, 1, 0, 1)
        -- 执行代码
    end
	--当开启一包卡牌是，每一张卡牌触发一次事件
    klass.OnCardOpenedOverall = function(self,CardID)
        MOD.Logger.LogScreen("卡包中开了一张卡, CardID = " .. tostring(CardID),5, 0, 1, 0, 1)
        -- 执行代码
    end
```
---
## ✅ 示例：添加的接口 修改开启卡包的概率
联系作者添加简单的修改接口
```lua
local function ConfigureBoosterRarityRates()
    local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
    if not R then
        if MOD and MOD.Logger then MOD.Logger.LogScreen("找不到 UDrinkRegistryWorldSubsystem", 5,1,0,0,1) end
        return
    end

    --原版概率 概率不用加起来等于1， 所有的概率其实是一个权重，占比大的概率会高

    -- 0：标准包
    local StandardRates = {
        [UE.ECardRarity.Common]    = 0.894,
        [UE.ECardRarity.UnCommon]  = 0.01,
        [UE.ECardRarity.Rare]      = 0.005,
        [UE.ECardRarity.SuperRare] = 0.001,
    }
    R:RegisterRarityData(0, StandardRates)

    -- 1：豪华包
    local DeluxeRates = {
        [UE.ECardRarity.Common]    = 0.205,
        [UE.ECardRarity.UnCommon]  = 0.690,
        [UE.ECardRarity.Rare]      = 0.100,
        [UE.ECardRarity.SuperRare] = 0.005,
    }
    R:RegisterRarityData(1, DeluxeRates)

    -- 2：稀奢包
    local LuxuryRates = {
        [UE.ECardRarity.Common]    = 0.000,
        [UE.ECardRarity.UnCommon]  = 0.035,
        [UE.ECardRarity.Rare]      = 0.055,
        [UE.ECardRarity.SuperRare] = 0.010,
    }
    R:RegisterRarityData(2, LuxuryRates)

    if MOD and MOD.Logger then  MOD.Logger.LogScreen(("Mod [%s] 已经加载完成"):format(M.name), 5,1,1,0,1) end --日志
end
```

---
## ✅ 示例：添加的接口 开启出来的卡牌后 当前稀有度卡牌的特质概率
联系作者添加简单的修改接口
```lua
--修改当前卡牌稀有度抽卡时的特质出现概率 
local function ConfigureBoosterRarityRates1()
    local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
    if not R then
        if MOD and MOD.Logger then MOD.Logger.LogScreen("找不到 UDrinkRegistryWorldSubsystem", 5,1,0,0,1) end
        return
    end

    --原版概率 概率不用加起来等于1， 所有的概率其实是一个权重，占比大的概率会高
    -- 行 1：常见（ECardRarity.Common） 常见卡牌中 出现各种特质的概率
    ----------------------------------------------------------------
    local CommonTraitRates = {
        [UE.ETrait.Legendary]   = 0.001, -- 稀世概率
        [UE.ETrait.Shiny]       = 0.029, -- 闪亮概率
        [UE.ETrait.Holographic] = 0.070, -- 镭射概率
        [UE.ETrait.Gold]        = 0.100, -- 黄金概率
        [UE.ETrait.Silver]      = 0.100, -- 白银概率
        [UE.ETrait.Basic]       = 0.700, -- 基础概率
    }
    R:RegisterTraitData(UE.ECardRarity.Common, CommonTraitRates)

    ----------------------------------------------------------------
    -- 行 2：罕见（ECardRarity.UnCommon）
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
    -- 行 3：稀有（ECardRarity.Rare）
    ----------------------------------------------------------------
    local RareTraitRates = {
        [UE.ETrait.Legendary]   = 0.070,
        [UE.ETrait.Shiny]       = 0.140,
        [UE.ETrait.Holographic] = 0.210,
        [UE.ETrait.Gold]        = 0.300,
        [UE.ETrait.Silver]      = 0.200,
        [UE.ETrait.Basic]       = 0.080,
    }
    R:RegisterTraitData(UE.ECardRarity.Rare, RareTraitRates)

    ----------------------------------------------------------------
    -- 行 4：极稀有（ECardRarity.SuperRare）
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
    -- 行 5：神（ECardRarity.God）
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


    if MOD and MOD.Logger then  MOD.Logger.LogScreen(("Mod [%s] 已经加载完成"):format(M.name), 5,1,1,0,1) end --日志
end
```

---
## ✅ 示例：添加的接口 修改稀有度价格倍率
联系作者添加简单的修改接口
```lua
--修改当前卡牌稀有度的价值倍率 当前卡牌最终价格 = 基础价格CardValueMulti * 稀有度价值倍率 * 特质价值倍率 * 世代价值倍率（1-7世代对应1-7倍 目前没有设置渠道）
local function RarityValue()
    local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
    if not R then
        if MOD and MOD.Logger then MOD.Logger.LogScreen("找不到 UDrinkRegistryWorldSubsystem", 5,1,0,0,1) end
        return
    end
    -- 现在游戏中默认的倍率
    R:RegisterRarityValueData(UE.ECardRarity.Common, 0.1) -- 常见
    R:RegisterRarityValueData(UE.ECardRarity.UnCommon, 0.5) -- 罕见
    R:RegisterRarityValueData(UE.ECardRarity.Rare, 2) -- 稀有
    R:RegisterRarityValueData(UE.ECardRarity.SuperRare, 10) -- 极稀有
    R:RegisterRarityValueData(UE.ECardRarity.God, 500)  -- 神

    if MOD and MOD.Logger then  MOD.Logger.LogScreen(("Mod [%s] 已经加载完成"):format(M.name), 5,1,1,0,1) end --日志
end
```
## ✅ 示例：添加的接口 修改特质价格倍率
联系作者添加简单的修改接口
```lua
--修改当前卡牌特质的价值倍率 当前卡牌最终价格 = 基础价格CardValueMulti * 稀有度价值倍率 * 特质价值倍率 * 世代价值倍率（1-7世代对应1-7倍 目前没有设置渠道）
local function TraitValue()
    local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
    if not R then
        if MOD and MOD.Logger then MOD.Logger.LogScreen("找不到 UDrinkRegistryWorldSubsystem", 5,1,0,0,1) end
        return
    end
    -- 现在游戏中默认的倍率
    R:RegisterTraitValueData(UE.ETrait.Basic, 1) -- 基础特质
    R:RegisterTraitValueData(UE.ETrait.Silver, 2) -- 白银特质
    R:RegisterTraitValueData(UE.ETrait.Gold, 5) -- 黄金特质
    R:RegisterTraitValueData(UE.ETrait.Holographic, 20) -- 镭射特质
    R:RegisterTraitValueData(UE.ETrait.Shiny, 50) -- 闪亮特质
    R:RegisterTraitValueData(UE.ETrait.Legendary, 200) -- 稀世特质

    if MOD and MOD.Logger then  MOD.Logger.LogScreen(("Mod [%s] 已经加载完成"):format(M.name), 5,1,1,0,1) end --日志
end

```

## ✅ 完整可运行示例：本地化（多语言支持）
本示例展示了如何根据游戏当前的语言设置（如中文、英文、日文），动态加载对应的卡牌名称和描述。
```lua
-- ==========================================================================
-- 1. 工具函数：获取当前语言
--    注意：必须放在最前面，这样后面的逻辑才能调用它。
-- ==========================================================================
local function GetGameLanguage()
    local culture = "en" -- 默认回退语言
    
    -- 增加安全检查：确保 UE 对象存在
    -- (防止 Mod 加载器在非游戏环境下仅扫描文件时报错)
    if UE and UE.UKismetInternationalizationLibrary and UE.UKismetInternationalizationLibrary.GetCurrentCulture then
        local fullCulture = UE.UKismetInternationalizationLibrary.GetCurrentCulture() 
        if fullCulture then
            -- 截取前两个字母并转为小写 (例如 "zh-Hans-CN" -> "zh")
            culture = string.sub(tostring(fullCulture), 1, 2):lower()
        end
    end
    
    -- 定义支持的语言列表，不在列表内的统一回退到 en
    local supported = {
        ["en"]=true, -- 英语
        ["zh"]=true, -- 中文
        ["ja"]=true, -- 日语
        ["es"]=true, -- 西班牙语
        ["fr"]=true, -- 法语
        ["de"]=true, -- 德语
        ["it"]=true, -- 意大利语
        ["pt"]=true, -- 葡萄牙语
        ["ru"]=true  -- 俄语
    }
    return supported[culture] and culture or "en"
end

-- 获取当前语言并存入变量，供后续使用
local CurrentLang = GetGameLanguage()


-- ==========================================================================
-- 2. Mod 元数据定义 (给 C++ 正则解析器看)
--    C++ 代码会扫描这些行来显示 Mod 列表的名字。
--    这里使用全局变量格式，确保正则能匹配到 `key = "value"`。
-- ==========================================================================

-- --- 英文 (默认) ---
name            = "Localization Example"
description     = "Example mod showing how to support multiple languages."

-- --- 中文 (Chinese) ---
name_zh         = "多语言本地化示例"
description_zh  = "这是一个演示如何支持多种语言的 Mod 示例。"

-- --- 日文 (Japanese) ---
name_ja         = "ローカライズ例"
description_ja  = "多言語対応の方法を示すMod例です。"

-- --- 西班牙文 (Spanish) ---
name_es         = "Ejemplo de Localización"
description_es  = "Un mod de ejemplo que muestra cómo admitir varios idiomas."

-- --- 法文 (French) ---
name_fr         = "Exemple de Localisation"
description_fr  = "Exemple de mod montrant comment supporter plusieurs langues."

-- --- 德文 (German) ---
name_de         = "Lokalisierungsbeispiel"
description_de  = "Beispiel-Mod, der zeigt, wie mehrere Sprachen unterstützt werden."

-- --- 俄文 (Russian) ---
name_ru         = "Пример локализации"
description_ru  = "Пример мода, показывающий поддержку нескольких языков."

-- (你可以继续添加其他语言，例如 name_it, name_pt 等)


-- ==========================================================================
-- 3. Mod 主表 (M) (给 Lua 虚拟机运行看)
--    这里实现了在 Lua 内部也动态获取名字。
--    _G["name_"..CurrentLang] 的意思是：
--    如果当前是 zh，就去找全局变量 name_zh，找不到就用默认的 name。
-- ==========================================================================
local M = {
    id          = "LocalizedCardExample",
    -- 动态赋值：尝试获取 name_zh, name_ja 等，失败则用 name
    name        = _G["name_" .. CurrentLang] or name, 
    description = _G["description_" .. CurrentLang] or description,
    version     = "1.0.2",
    author      = "yiming",
}


-- ==========================================================================
-- 4. 游戏内内容翻译表 (卡牌数据)
--    Key = 卡牌ID, Value = 各语言的文本
-- ==========================================================================
local CardLocalizationDB = {
    [1102] = {
        -- 英语
        en = { Name = "Blue Slime",     Desc = "A sticky friend found in the water." },
        -- 中文
        zh = { Name = "蓝色史莱姆",     Desc = "在水中发现的粘粘的朋友。" },
        -- 日语
        ja = { Name = "ブルースライム",  Desc = "水辺で見つかるネバネバした友達。" },
        -- 西班牙语
        es = { Name = "Limo Azul",      Desc = "Un amigo pegajoso encontrado en el agua." },
        -- 法语
        fr = { Name = "Slime Bleu",     Desc = "Un ami gluant trouvé dans l'eau." },
        -- 德语
        de = { Name = "Blauer Schleim", Desc = "Ein klebriger Freund aus dem Wasser." },
        -- 俄语
        ru = { Name = "Синий Слизень",  Desc = "Липкий друг, найденный в воде." },
    },
    -- 你可以在这里添加更多卡牌...
    -- [1103] = { ... }
}


-- ==========================================================================
-- 5. 核心逻辑：注册卡牌
-- ==========================================================================
local function AddLocalizedCard()
    local W = MOD.GAA.WorldUtils:GetCurrentWorld()
    local R = UE.UCardFunction.GetCardRegistryWS(W)
    
    local cardId = 1102
    
    -- --- 1. 获取翻译数据 ---
    local cardData = CardLocalizationDB[cardId]
    
    -- 默认使用英文作为保底
    local finalName = cardData["en"].Name
    local finalDesc = cardData["en"].Desc

    -- 如果当前语言有翻译，则覆盖默认值
    if cardData[CurrentLang] then
        finalName = cardData[CurrentLang].Name
        finalDesc = cardData[CurrentLang].Desc
    end
    -- -----------------------

    -- --- 2. 组装卡牌数据 ---
    local D = UE.FCardDataAll()
    D.CardID = cardId
    D.Name = finalName
    D.Description = finalDesc
    D.Gen = 0
    -- 确保你的 Mod 文件夹里有这张图片
    D.TexturePath = dir .. "1102.png"
    D.Rarity = UE.ECardRarity.Common
    D.BaseAttack = 15
    D.BaseHealth = 25
    D.CardElementFaction:Add(UE.ECardElementFaction.Water)
    
    -- --- 3. 注册到游戏 ---
    R:RegisterCardData(D.CardID, D)
end

-- ==========================================================================
-- 6. Mod 初始化入口
-- ==========================================================================
function M.OnInit()
    AddLocalizedCard()
end

return M

```



---
## 目前已有的ID 更新至2026.1.8
```lua
1101  沙焰狗  第一世代  常见 火
1102  迷尼特  第一世代  常见 动物
1103  顽熊仔  第一世代  常见 动物
1104  土拉比  第一世代  常见 土
1105  电击熊  第一世代  常见 电
1106  牧缇  第一世代  常见 冰
1107  电气狗  第一世代  常见 电
1108  冰穴鼠  第一世代  常见 冰
1109  彩蝶  第一世代  常见 昆虫
1110  爱米喵  第一世代  常见 动物
1111  冰穴獭  第一世代  常见 冰
1112  怪怪鼬  第一世代  常见 动物
1113  乐松狐  第一世代  常见 动物
1114  柯厄斯  第一世代  常见 龙
1115  莓尾猴  第一世代  常见 草
1116  蹦蹦鼠  第一世代  常见 动物
1117  伏草龙  第一世代  常见 动物
1118  叶皮皮  第一世代  常见 草
1119  嘎乌鸟  第一世代  常见 岩石
1120  大耳猴  第一世代  常见 动物
1121  奇咒鸮  第一世代  常见 神秘
1201  岩盔蜥  第一世代  罕见 岩石
1202  白豚兽  第一世代  罕见 水
1203  雪妖精  第一世代  罕见 冰
1204  章波波  第一世代  罕见 水
1205  卡奇狐  第一世代  罕见 火
1206  潘小达  第一世代  罕见 动物
1207  火山蛛  第一世代  罕见 火
1208  迅雷雕  第一世代  罕见 电
1209  吸血蝠龙  第一世代  罕见 龙
1210  白蝠兽  第一世代  罕见 神秘
1211  灾热蜥龙  第一世代  罕见 龙
1212  冰脊龙  第一世代  罕见 冰
1213  幼冰脊龙  第一世代  罕见 冰
1301  矿眼皇  第一世代  稀有 岩石
1302  戴斯魔  第一世代  稀有 超能
1303  火纹狼  第一世代  稀有 火
1304  激浪龙  第一世代  稀有 龙
1305  幽幽蝶  第一世代  稀有 草
1306  急烈鸟  第一世代  稀有 火
1307  捣蛋魔  第一世代  稀有 动物
1308  急冻龙  第一世代  稀有 冰
1309  磁甲虫  第一世代  稀有 钢
1310  袭烈魔  第一世代  稀有 火
1311  虹猫鱼  第一世代  稀有 水
1312  布卜  第一世代  稀有 冰
1313  激雷熊  第一世代  稀有 电
1324  袋拳拳  第一世代  稀有 动物
1325  灯帽林妖  第一世代  稀有 草
1326  莓鹿鹿  第一世代  稀有 动物
1327  梦帽呆呆  第一世代  稀有 超能
1328  烟炉假人  第一世代  稀有 钢
1401  异瞳贝  第一世代  极稀有 水
1402  焰羽枭  第一世代  极稀有 火
1403  读心猫  第一世代  极稀有 动物
1404  拳帝猩彼  第一世代  极稀有 火
2101  窃籽兽  第二世代  常见 动物
2102  章皮皮  第二世代  常见 水
2103  草尾雀  第二世代  常见 草
2104  岩栗子  第二世代  常见 土
2105  炫尾猴  第二世代  常见 草
2106  宝石熊  第二世代  常见 土
2107  暗影龙  第二世代  常见 龙
2108  幽灵水母  第二世代  常见 水
2109  焚鬃狐  第二世代  常见 火
2110  双鳍龙  第二世代  常见 草
2111  菇壳兔  第二世代  常见 动物
2112  激雷兽  第二世代  常见 电
2113  迷迷狐  第二世代  常见 电
2114  末影鼠  第二世代  常见 超能
2115  树小鬼  第二世代  常见 草
2201  炽熔兽  第二世代  罕见 火
2202  化石鱼  第二世代  罕见 水
2203  爆尾蛙  第二世代  罕见 火
2204  蝶兔妖  第二世代  罕见 神秘
2205  古力甲虫  第二世代  罕见 昆虫
2206  丝歌虫  第二世代  罕见 昆虫
2301  谷猬猬  第二世代  稀有 动物
2302  海啸獭  第二世代  稀有 水
2303  利路亚  第二世代  稀有 超能
2304  神末灯  第二世代  稀有 神秘
2305  宝贝兽  第二世代  稀有 动物
2306  苍观  第二世代  稀有 神秘
2307  烈冲兽  第二世代  稀有 火
2308  破石猪  第二世代  稀有 岩石
2309  锻锤仔  第二世代  稀有 土
2310  符鬼  第二世代  稀有 神秘
2311  困困獭  第二世代  稀有 水
2312  矮朵拉  第二世代  稀有 草
2313  绒雪绵  第二世代  稀有 冰
2314  冬夜铃音  第二世代  稀有 冰
2315  幻光兽  第二世代  稀有 电
2316  绿涌  第二世代  稀有 草
2317  霓裳裂影  第二世代  稀有 神秘
2318  灼频  第二世代  稀有 火
2319  冰灵灵  第二世代  稀有 冰
2401  鞘绒仙  第二世代  极稀有 草
2402  仙人掌兽  第二世代  极稀有 草
2403  幻光兽  第二世代  极稀有 电
2404  古岩鲸  第二世代  极稀有 岩石
2405  藤幽鼬  第二世代  极稀有 草
3101  乌洛迪  第三世代  常见 神秘
3102  面具熊  第三世代  常见 钢
3103  机械蛇  第三世代  常见 钢
3104  锁牙  第三世代  常见 冰
3105  派派特  第三世代  常见 动物
3106  风牙  第三世代  常见 动物
3107  电激猿  第三世代  常见 电
3108  冰暴龙  第三世代  常见 冰
3109  比特猫  第三世代  常见 超能
3110  星星兽  第三世代  常见 火
3111  墓巡羊  第三世代  常见 电
3112  迅驰  第三世代  常见 火
3113  捷翅  第三世代  常见 火
3114  钢御  第三世代  常见 钢
3115  斑特力  第三世代  常见 火
3201  雪足獴  第三世代  罕见 冰
3202  电爪龙  第三世代  罕见 电
3203  尤塔  第三世代  罕见 草
3204  可丽羊  第三世代  罕见 火
3205  麋枫鹿  第三世代  罕见 火
3206  蚁宿王  第三世代  罕见 昆虫
3207  蜜翅蜂  第三世代  罕见 昆虫
3208  蜜翅蚁  第三世代  罕见 昆虫
3209  浅水霞  第三世代  罕见 水
3210  樱眼鲨  第三世代  罕见 水
3301  火努狄  第三世代  稀有 火
3302  血月兽  第三世代  稀有 神秘
3303  袋袋  第三世代  稀有 动物
3304  格斗牧  第三世代  稀有 动物
3305  武空  第三世代  稀有 水
3306  狂金豹  第三世代  稀有 电
3307  齐拉鲁斯  第三世代  稀有 冰
3308  泥古莫  第三世代  稀有 昆虫
3309  晨光旅者·露娜  第三世代  稀有 草
3310  阳光队长·琳达  第三世代  稀有 水
3311  糖冲冲  第三世代  稀有 神秘
3312  独眼石  第三世代  稀有 岩石
3313  铃叮匣  第三世代  稀有 钢
3314  青锁  第三世代  稀有 神秘
3315  吐星鱼  第三世代  稀有 水
3401  波比浪比  第三世代  极稀有 水
3402  达木  第三世代  极稀有 草
3403  奇涡螺  第三世代  极稀有 昆虫
3404  海溟牝  第三世代  极稀有 水
3405  海鲁尔  第三世代  极稀有 超能
3406  阳光假日·芙蕾娅  第三世代  极稀有 神秘
4101  斯必达  第四世代  常见 动物
4102  箭羽鸟  第四世代  常见 火
4103  焚鬃狮  第四世代  常见 火
4104  梦幻龙  第四世代  常见 神秘
4105  三叶掌  第四世代  常见 草
4106  葵花兽  第四世代  常见 草
4107  多刺兔  第四世代  常见 草
4108  迷小熊  第四世代  常见 火
4109  厨师蜥  第四世代  常见 动物
4110  枫尾狐  第四世代  常见 动物
4111  边境狐  第四世代  常见 超能
4112  多灵朵  第四世代  常见 电
4113  电龙蜥  第四世代  常见 电
4114  长尾龙  第四世代  常见 龙
4115  皮皮  第四世代  常见 电
4116  朵拉肥  第四世代  常见 神秘
4117  黑蜗兽  第四世代  常见 神秘
4201  钢山甲  第四世代  罕见 钢
4202  石山甲  第四世代  罕见 岩石
4203  胆小蟹  第四世代  罕见 土
4204  菇帽蟹  第四世代  罕见 岩石
4301  金山甲  第四世代  稀有 钢
4302  谜龙  第四世代  稀有 神秘
4303  雷雨兽  第四世代  稀有 水
4304  苦恶魔  第四世代  稀有 超能
4305  幽鳞螈  第四世代  稀有 水
4306  拉比  第四世代  稀有 动物
4307  岩钳兽  第四世代  稀有 岩石
4308  梦龙  第四世代  稀有 龙
4309  雷喵  第四世代  稀有 电
4310  湿地龙蜥  第四世代  稀有 龙
4311  炽热视线·艾琳娜  第四世代  稀有 草
4312  晨光·卡洛琳  第四世代  稀有 岩石
4313  宝藏龙  第四世代  稀有 龙
4314  发条鸭  第四世代  稀有 神秘
4315  幻珀鲟  第四世代  稀有 水
4316  裂锋  第四世代  稀有 草
4317  砂电蝎  第四世代  稀有 电
4318  幽鳞螈  第四世代  稀有 水
4401  幻珀鲟  第四世代  极稀有 水
4402  舌蜥兽  第四世代  极稀有 动物
4403  古犬蝎  第四世代  极稀有 昆虫
4404  幽澜蝶  第四世代  极稀有 水
4405  晶贝龟  第四世代  极稀有 水
4406  森蔓霸者  第四世代  极稀有 草
4407  活力爆弹·纪晨音  第四世代  极稀有 超能
5101  白夜魔  第五世代  常见 火
5102  涟萌虎  第五世代  常见 火
5103  岩角龙  第五世代  常见 土
5104  法老猫  第五世代  常见 钢
5105  白岩巨人  第五世代  常见 岩石
5106  白岩石像  第五世代  常见 岩石
5107  澳邦鹿  第五世代  常见 火
5108  蛮邦鹿  第五世代  常见 土
5110  迷你羊  第五世代  常见 火
5111  多比  第五世代  常见 草
5112  极冻熊  第五世代  常见 冰
5113  极地海豹  第五世代  常见 冰
5114  急冻鸟  第五世代  常见 冰
5115  比萌蜂  第五世代  常见 电
5116  科莫多  第五世代  常见 电
5117  尼莫  第五世代  常见 电
5118  电海马  第五世代  常见 电
5119  炸弹鳄  第五世代  常见 电
5120  胖河豚  第五世代  常见 水
5121  幽渊章鱼  第五世代  常见 水
5122  极鸦  第五世代  常见 神秘
5123  火狐  第五世代  常见 火
5124  小火狐  第五世代  常见 火
5201  钢晶龟  第五世代  罕见 钢
5202  暗夜鼠  第五世代  罕见 动物
5203  叶翅蛙  第五世代  罕见 草
5204  法老犬  第五世代  罕见 超能
5205  冰原猩  第五世代  罕见 冰
5206  赤瞳斑  第五世代  罕见 火
5207  泡泡猫  第五世代  罕见 水
5208  寒风熊  第五世代  罕见 冰
5209  夜星虫  第五世代  罕见 电
5210  角突兽  第五世代  罕见 钢
5301  章鱼可可  第五世代  稀有 水
5302  美梦虫  第五世代  稀有 昆虫
5303  龙多多  第五世代  稀有 龙
5304  福叶蛙  第五世代  稀有 草
5305  塔花兽  第五世代  稀有 土
5306  雷焰牙  第五世代  稀有 龙
5307  熔墓龙  第五世代  稀有 龙
5308  袭雷兽  第五世代  稀有 电
5309  冬泉  第五世代  稀有 冰
5310  辉耀  第五世代  稀有 神秘
5311  泳日女王·苏梨音  第五世代  稀有 水
5312  炽阳小将·春日奈  第五世代  稀有 火
5313  冰牙猛犸  第五世代  稀有 冰
5314  福叶蛙  第五世代  稀有 草
5315  糕糕  第五世代  稀有 昆虫
5316  礼盒拳手  第五世代  稀有 钢
5317  圣诞象  第五世代  稀有 动物
5318  塔花兽  第五世代  稀有 土
5319  扁扁鳐  第五世代  稀有 水
5401  石豆小霸  第五世代  极稀有 岩石
5402  蘑菇鱼  第五世代  极稀有 水
5403  裂甲龙蜥  第五世代  极稀有 龙
5404  冰牙猛犸  第五世代  极稀有 冰
5405  草墩墩  第五世代  极稀有 草
5406  殁钢石  第五世代  极稀有 钢
5407  疾风拳童·新田光  第五世代  极稀有 岩石
6101  涟漪蛇  第六世代  常见 冰
6102  玻璃蝶  第六世代  常见 昆虫
6103  腐化雷兽  第六世代  常见 电
6104  冰峰猿  第六世代  常见 冰
6105  幽魂鲨  第六世代  常见 水
6106  幽魂刺猬  第六世代  常见 神秘
6107  独眼章鱼  第六世代  常见 神秘
6108  蓝羽雀  第六世代  常见 超能
6109  离魂虫  第六世代  常见 超能
6110  克星象  第六世代  常见 超能
6111  星光水母  第六世代  常见 神秘
6112  土山龟  第六世代  常见 土
6113  獠牙猪  第六世代  常见 土
6114  晶石甲虫  第六世代  常见 岩石
6115  岩漠蜥蜴  第六世代  常见 火
6116  拳击袋鼠  第六世代  常见 火
6117  钢甲犀  第六世代  常见 钢
6118  梦幻蝠  第六世代  常见 神秘
6119  催眠孔雀  第六世代  常见 超能
6120  钢刺兽  第六世代  常见 钢
6121  机械鸟  第六世代  常见 钢
6123  工程象  第六世代  常见 钢
6124  火山龙  第六世代  常见 火
6125  电磁犬  第六世代  常见 电
6126  变色鹿  第六世代  常见 草
6127  贪吃龙  第六世代  常见 电
6201  彩虹考拉  第六世代  罕见 神秘
6202  冰雪灵波  第六世代  罕见 冰
6203  法奇  第六世代  罕见 超能
6204  可米羊  第六世代  罕见 钢
6205  彩虹龙  第六世代  罕见 超能
6206  达达鸭  第六世代  罕见 动物
6207  钢牙犬  第六世代  罕见 钢
6208  矿石兽  第六世代  罕见 神秘
6209  天使鹰  第六世代  罕见 电
6301  鬼怪蛋  第六世代  稀有 神秘
6302  闪电羊  第六世代  稀有 电
6303  辐蛇花  第六世代  稀有 草
6304  泡泡  第六世代  稀有 水
6305  泡泡水母  第六世代  稀有 水
6306  咕咕  第六世代  稀有 动物
6307  拉拉  第六世代  稀有 草
6308  泥河马  第六世代  稀有 水
6309  阳光训练生·夏目凛  第六世代  稀有 电
6310  奋战少女·艾米丽  第六世代  稀有 土
6311  烛狸  第六世代  稀有 火
6312  掌尾蛙  第六世代  稀有 水
6313  浪花妖  第六世代  稀有 草
6314  星核电蛛  第六世代  稀有 电
6315  荚荚  第六世代  稀有 草
6316  绒绒藤  第六世代  稀有 草
6317  夜花  第六世代  稀有 神秘
6318  澜浮  第六世代  稀有 水
6319  棉花苗  第六世代  稀有 土
6320  雪锤姆  第六世代  稀有 冰
6321  鸮狮鹫  第六世代  稀有 火
6322  布欧  第六世代  稀有 土
6323  可拉可拉  第六世代  稀有 电
6401  孢子龙  第六世代  极稀有 龙
6402  三头食人花  第六世代  极稀有 草
6403  盆盆  第六世代  极稀有 草
6404  花梦  第六世代  极稀有 超能
6405  巨嘴岩  第六世代  极稀有 岩石
6406  猎菌鱿  第六世代  极稀有 冰
6407  街头老哥 · 布鲁诺  第六世代  极稀有 土
6408  棉花苗  第六世代  极稀有 土
7101  乐羽鸟  第七世代  常见 动物
7102  叶刃  第七世代  常见 昆虫
7103  叶爪兽  第七世代  常见 草
7104  地龙兽  第七世代  常见 土
7105  岩拳兽  第七世代  常见 岩石
7106  巴布  第七世代  常见 神秘
7107  拉卡兽  第七世代  常见 超能
7108  拳浣熊  第七世代  常见 钢
7109  星流鹿  第七世代  常见 电
7110  暗恋鸟  第七世代  常见 动物
7111  树象兽  第七世代  常见 土
7112  水泡灵  第七世代  常见 水
7113  潮浪翼  第七世代  常见 火
7114  激雷鱼  第七世代  常见 电
7115  火尾兽  第七世代  常见 火
7116  火火虎  第七世代  常见 火
7117  火翼龙  第七世代  常见 龙
7118  灵松鼠  第七世代  常见 动物
7119  焰角兽  第七世代  常见 岩石
7120  熔岩牙  第七世代  常见 火
7201  绿叶精  第七世代  罕见 草
7202  翅雷虫  第七世代  罕见 电
7203  花妖精  第七世代  罕见 神秘
7204  花翼灵  第七世代  罕见 超能
7205  花韵灵  第七世代  罕见 超能
7206  蓝焰灵  第七世代  罕见 火
7207  蓝蝠兽  第七世代  罕见 冰
7208  藤跃灵  第七世代  罕见 草
7209  蘑灵  第七世代  罕见 土
7210  趴趴蟹  第七世代  罕见 水
7211  闪泡狐  第七世代  罕见 电
7212  闪石灵  第七世代  罕见 冰
7213  闪跃狐  第七世代  罕见 火
7214  鹿叶兽  第七世代  罕见 草
7301  原核序体·绮弥  第七世代  稀有 超能
7302  霓锋少女·璃音  第七世代  稀有 神秘
7303  影烬  第七世代  稀有 龙
7304  糖驹  第七世代  稀有 动物
7305  泡泡啾  第七世代  稀有 水
7306  炽狼裂  第七世代  稀有 动物
7307  霜苍天翼  第七世代  稀有 龙
7308  燃影  第七世代  稀有 火
7309  魅月灵  第七世代  稀有 神秘
7310  跃星猴  第七世代  稀有 动物
7311  岩炼兽  第七世代  稀有 岩石
7312  跃动少女·柯拉  第七世代  稀有 电
7313  雷爆冲锋·卫鸣  第七世代  稀有 电
7314  尖嵴虫  第七世代  稀有 昆虫
7315  姜饼霜霜  第七世代  稀有 超能
7316  雪凌凌  第七世代  稀有 冰
7317  海马星  第七世代  稀有 水
7318  团鲁兽  第七世代  稀有 草
7319  赞达拉龙  第七世代  稀有 龙
7401  泡鳍兽  第七世代  极稀有 神秘
7402  润波鲸  第七世代  极稀有 水
7403  根苗灵  第七世代  极稀有 草
7404  星袭兽  第七世代  极稀有 超能
7405  焰影魔  第七世代  极稀有 火
7406  幻律神使·芷渺  第七世代  极稀有 冰
7407  热血风纪·烈阳  第七世代  极稀有 火
7408  阿兹隆  第七世代  极稀有 岩石
7409  缠幽姆姆  第七世代  极稀有 神秘
7410  刃鳞鲛  第七世代  极稀有 龙
7411  亡鳍鲸  第七世代  极稀有 水
7412  尖嵴虫  第七世代  极稀有 昆虫
7413  烁纹狮  第七世代  极稀有 超能
100001  雨神·漪涟迦祇  第一世代  神 水
100002  月神·阿拉古斯  第一世代  神 神秘
100003  火神·烈洛煌涅  第一世代  神 火
100004  草神·芽花礼木  第一世代  神 草
9001  阿银紫  纪念品  极稀有 火
9002  艾瑞克  纪念品  极稀有 神秘
9003  灵雪  纪念品  极稀有 冰
9004  KF  纪念品  极稀有 电
9005  wawa  纪念品  极稀有 火
9006  Tobe  纪念品  极稀有 岩石
9007  EXIA  纪念品  极稀有 超能
9008  YIMING  纪念品  极稀有 超能
9060  Killa  纪念品  极稀有 岩石
9061  安酱  纪念品  极稀有 神秘
9062  白雪女仆  纪念品  极稀有 冰
9063  兔女郎  纪念品  极稀有 水
9064  Alice  纪念品  极稀有 钢
9065  ANO  纪念品  极稀有 神秘
9066  龙栖之姬  纪念品  极稀有 龙
9067  愚人  纪念品  极稀有 超能
9068  ANT  纪念品  极稀有 超能
9069  樱花少女  纪念品  极稀有 神秘
9071  凯凯在此  纪念品  极稀有 神秘
9072  铁锅炖大鹅  纪念品  极稀有 神秘
9073  Saka采采  纪念品  极稀有 神秘
9074  冷阳学弟  纪念品  极稀有 神秘
1314  云雾妖  节日卡包  稀有 电
1315  鬼灯  节日卡包  稀有 火
1316  毒瘴覃  节日卡包  稀有 草
1317  可萌多  节日卡包  稀有 超能
1318  影鬼  节日卡包  稀有 神秘
1319  南瓜头  节日卡包  稀有 土
1320  魔火蝠  节日卡包  稀有 动物
1321  巨口魔  节日卡包  稀有 动物
1322  白椒灵  节日卡包  极稀有 草
1323  小骨  节日卡包  极稀有 超能
```

---
## 上传创意工坊
请查看https://partner.steamgames.com/doc/features/workshop/implementation
的Steam CMD 集成部分。下面是复制内容：
- 当前游戏的appid = 3569500
- 初次上传publishedfileid 请填0 。之后会生成一个新的publishedfileid。更新就使用这个新的publishedfileid。
``` lua
SteamCmd 集成
除 ISteamUGC API 之外，steamcmd.exe 命令行工具也可用于为测试目的创建和更新创意工坊物品。 由于此工具要求用户输入 Steam 凭据（我们不希望顾客提供），因此仅限于测试使用。

如要使用 steamcmd.exe 创建新的 Steam 创意工坊物品，首先须创建一个纯文本 VDF 文件， 并包含以下键值。
"workshopitem"
{
 "appid" "480"
 "publishedfileid" "5674"
 "contentfolder" "D:\\Content\\workshopitem"
 "previewfile" "D:\\Content\\preview.jpg"
 "visibility" "0"
 "title" "《军团要塞》的绿色帽子"
 "description" "《军团要塞》的绿色帽子"
 "changenote" "1.2 版本"
}

注意：
键值与各种 ISteamUGC::SetItem[...] 方法对应。 请见上方文献了解更多信息。
所示值为均为示例，应根据情况而适当调整。
要创建新物品，必须设置 appid，并且 publishedfileid 必须为未设置或设为 0。
要更新现有物品，appid 与 publishedfileid 均需设置。
如果某个键需要更新，则其余的键/值对也应包含在 VDF 中。
创建 VDF 后，可按 workshop_build_item <build config filename> 的文件参数运行 steamcmd.exe。 如：
steamcmd.exe +login myLoginName myPassword +workshop_build_item workshop_green_hat.vdf +quit
如果命令成功，VDF 中的 publishedfileid 值会自动更新，以包含创意工坊物品 ID。 由此，同一个 VDF 的 steamcmd.exe 后续调用将会更新而非创建新物品。

```

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
