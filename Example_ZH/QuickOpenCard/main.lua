local M = {
	id = "QuickOpenCard",
	name = "更快的开卡包速度",
	version = "1.0.0",
	author = "yiming",
	description = "开卡包速度x5",
}

function M:try_patch()
	if MOD and MOD.Logger then MOD.Logger.LogScreen("开始初始化QuickOpenCard", 5,1,0,0,1) end
	if not MOD or not MOD.Playercontroller or MOD.Playercontroller.PlayerIndex == -1 then
		MOD.GAA.TimerManager:AddTimer(1, M, function() M:try_patch() end)
		return
	end
	local pc         = MOD.Playercontroller
	local key        = "BP_CardPlayer" .. tostring(pc.PlayerIndex) --获得当前玩家的 BP_PlayerState
	local klass      = pc.GetLuaObject and pc:GetLuaObject(key) or nil  --获得当前BP_PlayerState的lua文件
	if not klass then
		if MOD.GAA and MOD.GAA.TimerManager then
			MOD.GAA.TimerManager:AddTimer(1, M, function() M:try_patch() end)
		end
		return
	end
	--最终设置变量（自己控制的玩家）
    klass.OpenCardSpeed = 5
	if MOD and MOD.Logger then MOD.Logger.LogScreen("QuickOpenCard设置完成", 5,1,0,0,1) end
end

function M.OnInit()
	M:try_patch()
end

return M
