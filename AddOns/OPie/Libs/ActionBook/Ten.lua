local COMPAT, _, T = select(4, GetBuildInfo()), ...

if COMPAT >= 10e4 then
	local pv = {}
	local function SetCVarQuietly(k, v)
		CVarCallbackRegistry:UnregisterEvent("CVAR_UPDATE")
		SetCVar(k, v)
		CVarCallbackRegistry:RegisterEvent("CVAR_UPDATE")
	end
	local function PreClick(self, _, down)
		local pa = pv[self] or {}
		pv[self], pa[#pa+1] = pa, GetCVar("ActionButtonUseKeyDown")
		SetCVarQuietly("ActionButtonUseKeyDown", down and 1 or 0)
	end
	local function PostClick(self)
		local pa, lv = pv[self]
		if pa and pa[1] ~= nil then
			lv, pa[#pa] = pa[#pa], nil
			SetCVarQuietly("ActionButtonUseKeyDown", lv)
		end
	end
	function T.TenSABT(self)
		self:HookScript("PreClick", PreClick)
		self:HookScript("PostClick", PostClick)
		return self
	end
else
	function T.TenSABT(self)
		return self
	end
end