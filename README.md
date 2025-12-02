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
    D.FlowTexturePath = dir .. "fire.PNG"  --背景漂浮的图片
    D.FlowValue = 0.5      --背景漂浮图片的透明度 0-1

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
##目前已有的ID
```lua
1102 迷尼特 Gen 第一世代
1103 顽熊仔 Gen 第一世代
1104 土拉比 Gen 第一世代
1105 电击熊 Gen 第一世代
1106 牧缇 Gen 第一世代
1107 电气狗 Gen 第一世代
1108 冰穴鼠 Gen 第一世代
1109 彩蝶 Gen 第一世代
1110 爱米喵 Gen 第一世代
1111 冰穴獭 Gen 第一世代
1112 怪怪鼬 Gen 第一世代
1113 乐松狐 Gen 第一世代
1114 柯厄斯 Gen 第一世代
1115 莓尾猴 Gen 第一世代
1116 蹦蹦鼠 Gen 第一世代
1117 伏草龙 Gen 第一世代
1118 叶皮皮 Gen 第一世代
1119 嘎乌鸟 Gen 第一世代
1120 大耳猴 Gen 第一世代
1121 奇咒鸮 Gen 第一世代
1201 岩盔蜥 Gen 第一世代
1202 白豚兽 Gen 第一世代
1203 雪妖精 Gen 第一世代
1204 章波波 Gen 第一世代
1205 卡奇狐 Gen 第一世代
1206 潘小达 Gen 第一世代
1207 火山蛛 Gen 第一世代
1208 迅雷雕 Gen 第一世代
1209 吸血蝠龙 Gen 第一世代
1210 白蝠兽 Gen 第一世代
1211 灾热蜥龙 Gen 第一世代
1212 冰脊龙 Gen 第一世代
1213 幼冰脊龙 Gen 第一世代
1301 矿眼皇 Gen 第一世代
1302 戴斯魔 Gen 第一世代
1303 火纹狼 Gen 第一世代
1304 激浪龙 Gen 第一世代
1305 幽幽蝶 Gen 第一世代
1306 急烈鸟 Gen 第一世代
1307 捣蛋魔 Gen 第一世代
1308 急冻龙 Gen 第一世代
1309 磁甲虫 Gen 第一世代
1310 袭烈魔 Gen 第一世代
1311 虹猫鱼 Gen 第一世代
1312 布卜 Gen 第一世代
1313 激雷熊 Gen 第一世代
1401 异瞳贝 Gen 第一世代
1402 焰羽枭 Gen 第一世代
1403 读心猫 Gen 第一世代
1404 拳帝猩彼 Gen 第一世代
2101 窃籽兽 Gen 第二世代
2102 章皮皮 Gen 第二世代
2103 草尾雀 Gen 第二世代
2104 岩栗子 Gen 第二世代
2105 炫尾猴 Gen 第二世代
2106 宝石熊 Gen 第二世代
2107 暗影龙 Gen 第二世代
2108 幽灵水母 Gen 第二世代
2109 焚鬃狐 Gen 第二世代
2110 双鳍龙 Gen 第二世代
2111 菇壳兔 Gen 第二世代
2112 激雷兽 Gen 第二世代
2113 迷迷狐 Gen 第二世代
2114 末影鼠 Gen 第二世代
2115 树小鬼 Gen 第二世代
2201 炽熔兽 Gen 第二世代
2202 化石鱼 Gen 第二世代
2203 爆尾蛙 Gen 第二世代
2204 蝶兔妖 Gen 第二世代
2205 古力甲虫 Gen 第二世代
2206 丝歌虫 Gen 第二世代
2301 谷猬猬 Gen 第二世代
2302 海啸獭 Gen 第二世代
2303 利路亚 Gen 第二世代
2304 神末灯 Gen 第二世代
2305 宝贝兽 Gen 第二世代
2306 苍观 Gen 第二世代
2307 烈冲兽 Gen 第二世代
2308 破石猪 Gen 第二世代
2309 锻锤仔 Gen 第二世代
2310 符鬼 Gen 第二世代
2311 困困獭 Gen 第二世代
2312 矮朵拉 Gen 第二世代
2401 鞘绒仙 Gen 第二世代
2402 仙人掌兽 Gen 第二世代
2403 幻光兽 Gen 第二世代
2404 古岩鲸 Gen 第二世代
2405 藤幽鼬 Gen 第二世代
3101 乌洛迪 Gen 第三世代
3102 面具熊 Gen 第三世代
3103 机械蛇 Gen 第三世代
3104 锁牙 Gen 第三世代
3105 派派特 Gen 第三世代
3106 风牙 Gen 第三世代
3107 电激猿 Gen 第三世代
3108 冰暴龙 Gen 第三世代
3109 比特猫 Gen 第三世代
3110 星星兽 Gen 第三世代
3111 墓巡羊 Gen 第三世代
3112 迅驰 Gen 第三世代
3113 捷翅 Gen 第三世代
3114 钢御 Gen 第三世代
3115 斑特力 Gen 第三世代
3201 雪足獴 Gen 第三世代
3202 电爪龙 Gen 第三世代
3203 尤塔 Gen 第三世代
3204 可丽羊 Gen 第三世代
3205 麋枫鹿 Gen 第三世代
3206 蚁宿王 Gen 第三世代
3207 蜜翅蜂 Gen 第三世代
3208 蜜翅蚁 Gen 第三世代
3209 浅水霞 Gen 第三世代
3210 樱眼鲨 Gen 第三世代
3301 火努狄 Gen 第三世代
3302 血月兽 Gen 第三世代
3303 袋袋 Gen 第三世代
3304 格斗牧 Gen 第三世代
3305 武空 Gen 第三世代
3306 狂金豹 Gen 第三世代
3307 齐拉鲁斯 Gen 第三世代
3308 泥古莫 Gen 第三世代
3309 晨光旅者·露娜 Gen 第三世代
3310 阳光队长·琳达 Gen 第三世代
3401 波比浪比 Gen 第三世代
3402 达木 Gen 第三世代
3403 奇涡螺 Gen 第三世代
3404 海溟牝 Gen 第三世代
3405 海鲁尔 Gen 第三世代
3406 阳光假日·芙蕾娅 Gen 第三世代
4101 斯必达 Gen 第四世代
4102 箭羽鸟 Gen 第四世代
4103 焚鬃狮 Gen 第四世代
4104 梦幻龙 Gen 第四世代
4105 三叶掌 Gen 第四世代
4106 葵花兽 Gen 第四世代
4107 多刺兔 Gen 第四世代
4108 迷小熊 Gen 第四世代
4109 厨师蜥 Gen 第四世代
4110 枫尾狐 Gen 第四世代
4111 边境狐 Gen 第四世代
4112 多灵朵 Gen 第四世代
4113 电龙蜥 Gen 第四世代
4114 长尾龙 Gen 第四世代
4115 皮皮 Gen 第四世代
4116 朵拉肥 Gen 第四世代
4117 黑蜗兽 Gen 第四世代
4201 钢山甲 Gen 第四世代
4202 石山甲 Gen 第四世代
4203 胆小蟹 Gen 第四世代
4204 菇帽蟹 Gen 第四世代
4301 金山甲 Gen 第四世代
4302 谜龙 Gen 第四世代
4303 雷雨兽 Gen 第四世代
4304 苦恶魔 Gen 第四世代
4305 幽鳞螈 Gen 第四世代
4306 拉比 Gen 第四世代
4307 岩钳兽 Gen 第四世代
4308 梦龙 Gen 第四世代
4309 雷喵 Gen 第四世代
4310 湿地龙蜥 Gen 第四世代
4311 炽热视线·艾琳娜 Gen 第四世代
4312 晨光·卡洛琳 Gen 第四世代
4401 幻珀鲟 Gen 第四世代
4402 舌蜥兽 Gen 第四世代
4403 古犬蝎 Gen 第四世代
4404 幽澜蝶 Gen 第四世代
4405 晶贝龟 Gen 第四世代
4406 森蔓霸者 Gen 第四世代
4407 活力爆弹·纪晨音 Gen 第四世代
5101 白夜魔 Gen 第五世代
5102 涟萌虎 Gen 第五世代
5103 岩角龙 Gen 第五世代
5104 法老猫 Gen 第五世代
5105 白岩巨人 Gen 第五世代
5106 白岩石像 Gen 第五世代
5107 澳邦鹿 Gen 第五世代
5108 蛮邦鹿 Gen 第五世代
5110 迷你羊 Gen 第五世代
5111 多比 Gen 第五世代
5112 极冻熊 Gen 第五世代
5113 极地海豹 Gen 第五世代
5114 急冻鸟 Gen 第五世代
5115 比萌蜂 Gen 第五世代
5116 科莫多 Gen 第五世代
5117 尼莫 Gen 第五世代
5118 电海马 Gen 第五世代
5119 炸弹鳄 Gen 第五世代
5120 胖河豚 Gen 第五世代
5121 幽渊章鱼 Gen 第五世代
5122 极鸦 Gen 第五世代
5123 火狐 Gen 第五世代
5124 小火狐 Gen 第五世代
5201 钢晶龟 Gen 第五世代
5202 暗夜鼠 Gen 第五世代
5203 叶翅蛙 Gen 第五世代
5204 法老犬 Gen 第五世代
5205 冰原猩 Gen 第五世代
5206 赤瞳斑 Gen 第五世代
5207 泡泡猫 Gen 第五世代
5208 寒风熊 Gen 第五世代
5209 夜星虫 Gen 第五世代
5210 角突兽 Gen 第五世代
5301 章鱼可可 Gen 第五世代
5302 美梦虫 Gen 第五世代
5303 龙多多 Gen 第五世代
5304 福叶蛙 Gen 第五世代
5305 塔花兽 Gen 第五世代
5306 雷焰牙 Gen 第五世代
5307 熔墓龙 Gen 第五世代
5308 袭雷兽 Gen 第五世代
5309 冬泉 Gen 第五世代
5310 辉耀 Gen 第五世代
5311 泳日女王·苏梨音 Gen 第五世代
5312 炽阳小将·春日奈 Gen 第五世代
5401 石豆小霸 Gen 第五世代
5402 蘑菇鱼 Gen 第五世代
5403 裂甲龙蜥 Gen 第五世代
5404 冰牙猛犸 Gen 第五世代
5405 草墩墩 Gen 第五世代
5406 殁钢石 Gen 第五世代
5407 疾风拳童·新田光 Gen 第五世代
6101 涟漪蛇 Gen 第六世代
6102 玻璃蝶 Gen 第六世代
6103 腐化雷兽 Gen 第六世代
6104 冰峰猿 Gen 第六世代
6105 幽魂鲨 Gen 第六世代
6106 幽魂刺猬 Gen 第六世代
6107 独眼章鱼 Gen 第六世代
6108 蓝羽雀 Gen 第六世代
6109 离魂虫 Gen 第六世代
6110 克星象 Gen 第六世代
6111 星光水母 Gen 第六世代
6112 土山龟 Gen 第六世代
6113 獠牙猪 Gen 第六世代
6114 晶石甲虫 Gen 第六世代
6115 岩漠蜥蜴 Gen 第六世代
6116 拳击袋鼠 Gen 第六世代
6117 钢甲犀 Gen 第六世代
6118 梦幻蝠 Gen 第六世代
6119 催眠孔雀 Gen 第六世代
6120 钢刺兽 Gen 第六世代
6121 机械鸟 Gen 第六世代
6123 工程象 Gen 第六世代
6124 火山龙 Gen 第六世代
6125 电磁犬 Gen 第六世代
6126 变色鹿 Gen 第六世代
6127 贪吃龙 Gen 第六世代
6201 彩虹考拉 Gen 第六世代
6202 冰雪灵波 Gen 第六世代
6203 法奇 Gen 第六世代
6204 可米羊 Gen 第六世代
6205 彩虹龙 Gen 第六世代
6206 达达鸭 Gen 第六世代
6207 钢牙犬 Gen 第六世代
6208 矿石兽 Gen 第六世代
6209 天使鹰 Gen 第六世代
6301 鬼怪蛋 Gen 第六世代
6302 闪电羊 Gen 第六世代
6303 辐蛇花 Gen 第六世代
6304 泡泡 Gen 第六世代
6305 泡泡水母 Gen 第六世代
6306 咕咕 Gen 第六世代
6307 拉拉 Gen 第六世代
6308 泥河马 Gen 第六世代
6309 阳光训练生·夏目凛 Gen 第六世代
6310 奋战少女·艾米丽 Gen 第六世代
6311 烛狸 Gen 第六世代
6312 掌尾蛙 Gen 第六世代
6313 浪花妖 Gen 第六世代
6314 星核电蛛 Gen 第六世代
6315 荚荚 Gen 第六世代
6316 绒绒藤 Gen 第六世代
6317 夜花 Gen 第六世代
6401 孢子龙 Gen 第六世代
6402 三头食人花 Gen 第六世代
6403 盆盆 Gen 第六世代
6404 花梦 Gen 第六世代
6405 巨嘴岩 Gen 第六世代
6406 猎菌鱿 Gen 第六世代
6407 街头老哥 · 布鲁诺 Gen 第六世代
6408 棉花苗 Gen 第六世代
7101 乐羽鸟 Gen 第七世代
7102 叶刃 Gen 第七世代
7103 叶爪兽 Gen 第七世代
7104 地龙兽 Gen 第七世代
7105 岩拳兽 Gen 第七世代
7106 巴布 Gen 第七世代
7107 拉卡兽 Gen 第七世代
7108 拳浣熊 Gen 第七世代
7109 星流鹿 Gen 第七世代
7110 暗恋鸟 Gen 第七世代
7111 树象兽 Gen 第七世代
7112 水泡灵 Gen 第七世代
7113 潮浪翼 Gen 第七世代
7114 激雷鱼 Gen 第七世代
7115 火尾兽 Gen 第七世代
7116 火火虎 Gen 第七世代
7117 火翼龙 Gen 第七世代
7118 灵松鼠 Gen 第七世代
7119 焰角兽 Gen 第七世代
7120 熔岩牙 Gen 第七世代
7201 绿叶精 Gen 第七世代
7202 翅雷虫 Gen 第七世代
7203 花妖精 Gen 第七世代
7204 花翼灵 Gen 第七世代
7205 花韵灵 Gen 第七世代
7206 蓝焰灵 Gen 第七世代
7207 蓝蝠兽 Gen 第七世代
7208 藤跃灵 Gen 第七世代
7209 蘑灵 Gen 第七世代
7210 趴趴蟹 Gen 第七世代
7211 闪泡狐 Gen 第七世代
7212 闪石灵 Gen 第七世代
7213 闪跃狐 Gen 第七世代
7214 鹿叶兽 Gen 第七世代
7301 原核序体·绮弥 Gen 第七世代
7302 霓锋少女·璃音 Gen 第七世代
7303 影烬 Gen 第七世代
7304 糖驹 Gen 第七世代
7305 泡泡啾 Gen 第七世代
7306 炽狼裂 Gen 第七世代
7307 霜苍天翼 Gen 第七世代
7308 燃影 Gen 第七世代
7309 魅月灵 Gen 第七世代
7310 跃星猴 Gen 第七世代
7311 岩炼兽 Gen 第七世代
7312 跃动少女·柯拉 Gen 第七世代
7313 雷爆冲锋·卫鸣 Gen 第七世代
7401 泡鳍兽 Gen 第七世代
7402 润波鲸 Gen 第七世代
7403 根苗灵 Gen 第七世代
7404 星袭兽 Gen 第七世代
7405 焰影魔 Gen 第七世代
7406 幻律神使·芷渺 Gen 第七世代
7407 热血风纪·烈阳 Gen 第七世代
7408 阿兹隆 Gen 第七世代
7409 缠幽姆姆 Gen 第七世代
7410 刃鳞鲛 Gen 第七世代
7411 亡鳍鲸 Gen 第七世代
7412 尖嵴虫 Gen 第七世代
7413 烁纹狮 Gen 第七世代
100001 雨神·漪涟迦祇 Gen 第一世代
100002 月神·阿拉古斯 Gen 第一世代
100003 火神·烈洛煌涅 Gen 第一世代
100004 草神·芽花礼木 Gen 第一世代
9001 阿银紫 Gen 纪念品
9002 艾瑞克 Gen 纪念品
9003 灵雪 Gen 纪念品
9004 KF Gen 纪念品
9005 wawa Gen 纪念品
9006 Tobe Gen 纪念品
9007 EXIA Gen 纪念品
9008 YIMING Gen 纪念品
9060 Killa Gen 纪念品
9061 安酱 Gen 纪念品
9062 白雪女仆 Gen 纪念品
9063 兔女郎 Gen 纪念品
9064 Alice Gen 纪念品
9065 ANO Gen 纪念品
9066 龙栖之姬 Gen 纪念品
9067 愚人 Gen 纪念品
9068 ANT Gen 纪念品
9069 樱花少女 Gen 纪念品
9071 凯凯在此 Gen 纪念品
9072 铁锅炖大鹅 Gen 纪念品
9073 Saka采采 Gen 纪念品
9074 冷阳学弟 Gen 纪念品
1314 云雾妖 Gen 节日卡包
1315 鬼灯 Gen 节日卡包
1316 毒瘴覃 Gen 节日卡包
1317 可萌多 Gen 节日卡包
1318 影鬼 Gen 节日卡包
1319 南瓜头 Gen 节日卡包
1320 魔火蝠 Gen 节日卡包
1321 巨口魔 Gen 节日卡包
1322 白椒灵 Gen 节日卡包
1323 小骨 Gen 节日卡包
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
