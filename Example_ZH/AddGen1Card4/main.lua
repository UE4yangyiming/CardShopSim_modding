local M = {
    id          = "AddGen1Card4",
    name        = "添加第一世代每个稀有度的图片",
    version     = "1.0.0",
    author      = "yiming",
    description = "描述添加第一世代每个稀有度的图片",
}

local function AddGen1Card4()
    local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
    if not R then
        if MOD and MOD.Logger then MOD.Logger.LogScreen("找不到 UDrinkRegistryWorldSubsystem", 5,1,0,0,1) end
        return
    end
    --普通 稀有卡面分辨率：512*446
    local D = UE.FCardDataAll()
    D.Name = "ID1122"                     --卡牌名称
    D.Description = "ID1122Description"   --描述
    D.CardID = 1122                       --ID
    D.Gen = 0                             --世代 1-7世代，要从0开始
    D.TexturePath = dir .. "1122.png"     --图片
    D.Rarity = UE.ECardRarity.Common
    D.BaseAttack = 10  --攻击力
    D.BaseHealth = 30  --生命值
    D.CardElementFaction:Add(UE.ECardElementFaction.Water)
    R:RegisterCardData(D.CardID,D);
    --罕见卡
    local D = UE.FCardDataAll()
    D.Name = "ID1214"                     --卡牌名称
    D.Description = "ID1214Description"   --描述
    D.CardID = 1214                       --ID
    D.Gen = 0                             --世代
    D.TexturePath = dir .. "1214.png"     --图片
    D.Rarity = UE.ECardRarity.UnCommon
    D.BaseAttack = 15  --攻击力
    D.BaseHealth = 60  --生命值
    D.CardElementFaction:Add(UE.ECardElementFaction.Animal)
    R:RegisterCardData(D.CardID,D);
    --稀有卡
    local D = UE.FCardDataAll()
    D.Name = "ID1324"                     --卡牌名称
    D.Description = "ID1324Description"   --描述
    D.CardID = 1324                       --ID
    D.Gen = 0                             --世代
    D.TexturePath = dir .. "1324.png"     --图片
    D.Rarity = UE.ECardRarity.Rare
    D.BaseAttack = 50  --攻击力
    D.BaseHealth = 250  --生命值
    D.CardElementFaction:Add(UE.ECardElementFaction.Electric)
    R:RegisterCardData(D.CardID,D);
    --极稀有卡
    local D = UE.FCardDataAll()
    D.Name = "ID1405"                     --卡牌名称
    D.Description = "ID1405Description"   --描述
    D.CardID = 1405                       --ID
    D.Gen = 0                             --世代
    D.TexturePath = dir .. "1405.png"     --图片
    D.Rarity = UE.ECardRarity.SuperRare
    D.BaseAttack = 80  --攻击力
    D.BaseHealth = 350  --生命值
    D.CardElementFaction:Add(UE.ECardElementFaction.Dragon)
    R:RegisterCardData(D.CardID,D);


    --目前卡牌1000-9999. 当前卡牌ID*10内不允许添加新ID。（卡牌ID加一位代表的是卡框数据。例如11012就是白银卡框）
    if MOD and MOD.Logger then  MOD.Logger.LogScreen(("Mod [%s] 已经加载完成"):format(M.name), 5,1,1,0,1) end --日志
end


function M.OnInit()
    --初始化
    if MOD and MOD.Logger then  MOD.Logger.LogScreen(("Mod [%s] 开始加载"):format(M.name), 5,1,1,0,1) end --日志
    AddGen1Card4()
end

function M.OnTick(dt)

end

return M
--额外说明：
-- 稀有度：
-- UE.ECardRarity.Common       --普通
-- UE.ECardRarity.UnCommon      --罕见
-- UE.ECardRarity.Rare          --稀有
-- UE.ECardRarity.SuperRare     --极稀有
-- UE.ECardRarity.God           --神卡

-- 元素：
-- UE.ECardElementFaction.Fire   --火
-- UE.ECardElementFaction.Water  --水
-- UE.ECardElementFaction.Grass  --草
-- UE.ECardElementFaction.Electric --电
-- UE.ECardElementFaction.Insect --昆虫
-- UE.ECardElementFaction.Rock   --岩石
-- UE.ECardElementFaction.Earth --土
-- UE.ECardElementFaction.Animal --动物
-- UE.ECardElementFaction.Steel --钢
-- UE.ECardElementFaction.Dragon --龙
-- UE.ECardElementFaction.Psychic --超能
-- UE.ECardElementFaction.Mystic --神秘
-- UE.ECardElementFaction.Ice --冰