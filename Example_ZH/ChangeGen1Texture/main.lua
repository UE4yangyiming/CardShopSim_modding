local M = {
    id          = "ChangeGen1Texture",
    name        = "修改第一世代的部分图片",
    version     = "1.0.0",
    author      = "yiming",
    description = "描述修改第一世代的部分图片",
}

local function ChangeGen1Texture()
    local R = UE.UCardFunction.GetCardRegistryWS(MOD.GAA.WorldUtils:GetCurrentWorld())
    if not R then
        if MOD and MOD.Logger then MOD.Logger.LogScreen("找不到 UDrinkRegistryWorldSubsystem", 5,1,0,0,1) end
        return
    end
    --普通 稀有卡面分辨率：512*446
    local D = UE.FCardDataAll()
    D.Name = "ID1101"
    D.Description = "ID1101Description"
    D.CardID = 1101
    D.TexturePath = dir .. "1101.png"
    -- D.BaseAttack = 0  --攻击力
    -- D.BaseHealth = 0  --生命值
    R:RegisterCardData(D.CardID,D);
    local D = UE.FCardDataAll()
    D.Name = "ID1102"
    D.Description = "ID1102Description"
    D.CardID = 1102
    D.TexturePath = dir .. "1101.png"
    R:RegisterCardData(D.CardID,D);

    
    --稀有极其稀有卡面分辨率：747*1024
    local D = UE.FCardDataAll()
    D.Name = "ID1301"
    D.Description = "ID1301Description"
    D.CardID = 1301
    D.TexturePath = dir .. "1301.png"
    R:RegisterCardData(D.CardID,D);
    local D = UE.FCardDataAll()
    D.Name = "ID1302"
    D.Description = "ID1302Description"
    D.CardID = 1302
    D.TexturePath = dir .. "1302.png"
    R:RegisterCardData(D.CardID,D);




    --目前卡牌1000-9999. 当前卡牌ID*10内不允许添加新ID。（卡牌ID加一位代表的是卡框数据。例如11012就是白银卡框）
    if MOD and MOD.Logger then  MOD.Logger.LogScreen(("Mod [%s] 已经加载完成"):format(M.name), 5,1,1,0,1) end --日志
end


function M.OnInit()
    --初始化
    if MOD and MOD.Logger then  MOD.Logger.LogScreen(("Mod [%s] 开始加载"):format(M.name), 5,1,1,0,1) end --日志
    ChangeGen1Texture()
end

function M.OnTick(dt)

end

return M
