local Engine = {}
Engine.__index = Engine

local ns = MikSBT.CombatEngine

function Engine:New(config)
	return setmetatable({ config = config }, self)
end

function Engine:MaintainLog()
	if not self.active then return end
	if ns.mine then ns.mine:Tidy(GetTime()) end
	if not ns.EventAvailable("COMBAT_LOG_MESSAGE") then return end
	-- Saved combat-log filters may not be restored when MSBT first starts.
	if IsLoggedIn and not IsLoggedIn() then return end
	if self.config.log:IsReady() then
		self.warned = false
		if self.config.onReady then self.config.onReady() end
		ns.KeepCombatLog(true)
	else
		ns.KeepCombatLog(false)
		if not self.warned
			and not (InCombatLockdown and InCombatLockdown()) then
			self.config.notify("Combat text needs its MSBT combat-log filter. "
				.. "Type /reload to save and activate it.")
			self.warned = true
		end
	end
end

function Engine:CreateRouter()
	local presentation = self.config.presentation
	local router = {}
	for _, name in ipairs({
		"In", "Alert", "Aura", "Healer", "Resource",
	}) do
		local method = name
		router[method] = function(_, ...)
			return presentation[method](presentation, ...)
		end
	end
	router.Out = function(_, record)
		if ns.EventAvailable("COMBAT_LOG_MESSAGE")
			and not self.config.log:IsReady() then return end
		return presentation:Out(record)
	end
	return router
end

function Engine:Start()
	if self.active then return end
	self.active = true
	ns.active = true
	ns.generation = ns.generation + 1
	ns.learned = ns.LoadLearned(self.config.getSaved())
	self.config.setSaved(ns.learned)
	ns.liveRouter = self:CreateRouter()
	self.config.log:ConfigureNamespace(ns)
	ns.Dispatch = function(event, ...) self:HandleEvent(event, ...) end
	ns.StartReader()
	local frame = ns.reader.frame
	frame:RegisterEvent("PLAYER_LOGOUT")
	frame:RegisterEvent("ADDON_LOADED")
	frame:RegisterEvent("PLAYER_LOGIN")
	self:MaintainLog()
	self.ticker = C_Timer.NewTicker(2, function() self:MaintainLog() end)
end

function Engine:HandleEvent(event, ...)
	if not self.active then return end
	if event == "PLAYER_LOGOUT" then
		if ns.EventAvailable("COMBAT_LOG_MESSAGE")
			and not self.config.log:IsReady() then
			self.config.log:WriteSettings()
		end
		return
	elseif event == "ADDON_LOADED" or event == "PLAYER_LOGIN" then
		self:MaintainLog()
		return
	end
	if not ns.EventAvailable(event) then return end
	if event == "COMBAT_LOG_MESSAGE" and not self.config.log:IsReady() then return end
	ns.ReaderEvent(nil, event, ...)
end

function Engine:Stop()
	if not self.active then return end
	self.active = false
	ns.active = false
	ns.generation = ns.generation + 1
	ns.StopReader()
	ns.Dispatch = nil
	ns.liveRouter = nil
	if self.ticker then self.ticker:Cancel(); self.ticker = nil end
	if self.config.presentation.Reset then self.config.presentation:Reset() end
end

MikSBT.Components.CombatEngine = Engine
return Engine
