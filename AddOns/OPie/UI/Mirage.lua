local ADDON, T = ...
if T.TenEnv then T.TenEnv() end
local XU = T.exUI
local _assert, getWidgetData, newWidgetData, _setWidgetData, _AddObjectMethods, _CallObjectScript = XU:GetImpl()

local IndicatorData, Indicator = {}, {}
local IndicatorProps = {
	api=Indicator,
	iconAspect=1,
	ustate=-1,
	rcTextShown=false,
	cdTextShown=false,
}

local gx do
	local b = ([[Interface\AddOns\%s\gfx\]]):format(ADDON)
	gx = {
		BorderLow = b .. "borderlo",
		BorderHigh = b .. "borderhi",
		OuterGlow = b .. "oglow",
		InnerGlow = b .. "iglow",
		Ribbon = b .. "ribbon",
		CooldownStar = [[Interface\cooldown\star4]],
		CooldownSpark = b .. "spark",
		Tri = b .. "tri",
		IconMask = b .. "iconmask",
	}
end
local darken do
	local CSL = CreateFrame("ColorSelect")
	function darken(r,g,b, vf, sf)
		CSL:SetColorRGB(r,g,b)
		local h,s,v = CSL:GetColorHSV()
		CSL:SetColorHSV(h, s*(sf or 1), v*(vf or 1))
		return CSL:GetColorRGB()
	end
end
local qualAtlas = {} do
	for i=1,5 do
		qualAtlas[i] = "Professions-Icon-Quality-Tier" .. i .. "-Small"
	end
end

local function cooldownFormat(cd)
	if (cd or 0) == 0 then return "" end
	local f, n, unit = cd >= 9.95 and "%d%s" or "%.1f", cd, ""
	if n > 86400 then n, unit = ceil(n/86400), "d"
	elseif n > 3600 then n, unit = ceil(n/3600), "h"
	elseif n > 89 then n, unit = ceil(n/60), "m"
	elseif n > 60 then f, n, unit = "%d:%02d", n/60, ceil(n % 60)
	elseif cd >= 9.95 then n = ceil(n) end
	return f, n, unit
end
local function adjustIconAspect(d, aspect)
	if d.iconAspect ~= aspect then
		d.iconAspect = aspect
		local w, h = d.iconbg:GetSize()
		d.icon:SetSize(aspect < 1 and h*aspect or w, aspect > 1 and w/aspect or h)
	end
end

function Indicator:SetIcon(texture, aspect)
	local d = getWidgetData(self, IndicatorData)
	d.icon:SetTexture(texture)
	local ofs = 2.5/64
	d.icon:SetTexCoord(ofs, 1-ofs, ofs, 1-ofs)
	return adjustIconAspect(d, aspect)
end
function Indicator:SetIconAtlas(atlas, aspect)
	local d = getWidgetData(self, IndicatorData)
	d.icon:SetAtlas(atlas)
	return adjustIconAspect(d, aspect)
end
function Indicator:SetIconTexCoord(a,b,c,dc, e,f,g,h)
	if a and b and c and dc then
		local d = getWidgetData(self, IndicatorData)
		if e and f and g and h then
			d.icon:SetTexCoord(a,b,c,dc, e,f,g,h)
		else
			d.icon:SetTexCoord(a,b,c,dc)
		end
	end
end
function Indicator:SetIconVertexColor(r,g,b)
	local d = getWidgetData(self, IndicatorData)
	d.icon:SetVertexColor(r,g,b)
end
function Indicator:SetUsable(usable, _usableCharge, _cd, nomana, norange)
	local d = getWidgetData(self, IndicatorData)
	local state = usable and 0 or (norange and 1 or (nomana and 2 or 3))
	d.veil:SetAlpha(usable and 0 or 0.40)
	if d.ustate == state then return end
	d.ustate = state
	if not usable and (nomana or norange) then
		d.ribbon:Show()
		if norange then
			d.ribbon:SetVertexColor(1, 0.20, 0.15)
		else
			d.ribbon:SetVertexColor(0.15, 0.75, 1)
		end
	else
		d.ribbon:Hide()
	end
end
function Indicator:SetDominantColor(r,g,b)
	local d = getWidgetData(self, IndicatorData)
	r, g, b = r or 1, g or 1, b or 0.6
	local cd, r2, g2, b2 = d.cd, darken(r,g,b, 0.20)
	local r3, g3, b3 = darken(r,g,b, 0.10, 0.50)
	d.hiEdge:SetVertexColor(r, g, b)
	d.iglow:SetVertexColor(r, g, b)
	d.oglow:SetVertexColor(r, g, b)
	d.edge:SetVertexColor(darken(r,g,b, 0.80))
	d.cdText:SetTextColor(r, g, b)
	d.cdSpark:SetVertexColor(r, g, b)
	for i=1,4 do
		cd[i]:SetVertexColor(r2, g2, b2)
		cd[i+4]:SetVertexColor(r3, g3, b3)
	end
	cd[9]:SetVertexColor(r3, g3, b3)
end
function Indicator:SetOverlayIcon(tex, w, h, ...)
	local oi = getWidgetData(self, IndicatorData).overIcon
	if not tex then
		return oi:Hide()
	end
	oi:Show()
	oi:SetTexture(tex)
	oi:SetSize(w, h)
	if ... then
		oi:SetTexCoord(...)
	else
		oi:SetTexCoord(0,1, 0,1)
	end
end
function Indicator:SetOverlayIconVertexColor(...)
	getWidgetData(self, IndicatorData).overIcon:SetVertexColor(...)
end
function Indicator:SetCount(count)
	getWidgetData(self, IndicatorData).count:SetText(count or "")
end
function Indicator:SetBinding(binding)
	binding = binding and GetBindingText(binding, 1) or ""
	getWidgetData(self, IndicatorData).key:SetText(binding)
end
function Indicator:SetCooldown(remain, duration, usable)
	local d = getWidgetData(self, IndicatorData)
	d.cooldownHintID = nil
	if (duration or 0) <= 0 or (remain or 0) <= 0 then
		d.cd:Hide()
		d.cdText:SetText("")
	else
		local now = GetTime()
		local expire, usable, cd = now + remain, not not usable, d.cd
		local td = expire - (cd.expire or 0)
		if td < -0.05 or td > 0.05 then
			cd.duration, cd.expire, cd.updateCooldownStep, cd.updateCooldown = duration, expire, duration/1536/d.self:GetEffectiveScale()
			cd:Show()
			d.cdSpark:SetShown(usable)
		end
		if d.cdUsable ~= usable then
			d.cdUsable = usable
			for i=1,4 do cd[i]:SetAlpha(usable and 0.45 or 1) end
			for i=5,9 do cd[i]:SetAlpha(usable and 0.25 or 0.85) end
			d.cdSpark:SetShown(usable)
		end
		local gcS, gcL = GetSpellCooldown(61304)
		if (duration ~= gcL or gcS+gcL-now < remain) and d[usable and "rcTextShown" or "cdTextShown"] then
			d.cdText:SetFormattedText(cooldownFormat(remain))
		else
			d.cdText:SetText("")
		end
	end
end
function Indicator:SetCooldownTextShown(cooldownShown, rechargeShown)
	local d = getWidgetData(self, IndicatorData)
	d.cdTextShown, d.rcTextShown = cooldownShown, rechargeShown
end
function Indicator:SetHighlighted(highlight)
	getWidgetData(self, IndicatorData).hiEdge:SetShown(highlight)
end
function Indicator:SetActive(active)
	getWidgetData(self, IndicatorData).iglow:SetShown(active)
end
function Indicator:SetOuterGlow(shown)
	getWidgetData(self, IndicatorData).oglow:SetShown(shown)
end
function Indicator:SetEquipState(isInContainer, isInInventory)
	local s = getWidgetData(self, IndicatorData).equipBanner
	local v, r, g, b = isInContainer or isInInventory, 0.1, 0.9, 0.15
	s:SetShown(v)
	if v then
		if not isInInventory then
			r, g, b = 1, 0.9, 0.2
		end
		s:SetVertexColor(r, g, b)
	end
end
function Indicator:SetShortLabel(text)
	getWidgetData(self, IndicatorData).label:SetText(text)
end
function Indicator:SetQualityOverlay(qual)
	local s = getWidgetData(self, IndicatorData).qualityMark
	local qa = qualAtlas[qual]
	s:SetAtlas(qa)
	s:SetShown(qa ~= nil)
end
function Indicator:SetCooldownPH(hintID, qf, _holdCount)
	local d = getWidgetData(self, IndicatorData)
	local dur = d.ustate == 0 and qf(hintID, "cooldownDuration")
	d.cooldownHintID = hintID
	if dur then
		d.veil:SetAlpha(C_CurveUtil.EvaluateColorValueFromBoolean(dur:IsZero(), 0, 0.40))
		d.cd:Hide()
		d.cdText:SetText("")
	end
end

local CreateCooldown do
	local function cdOnUpdate(self, elapsed)
		local ucd, expire, time = self.updateCooldown or 0, self.expire or 0, GetTime()
		if ucd > elapsed and time < expire then
			self.updateCooldown = ucd - elapsed
			return
		end
		self.updateCooldown = self.updateCooldownStep
		local duration, progress = self.duration or 0, expire - time

		if progress >= duration or duration == 0 then
			self:Hide()
		else
			progress = progress < 0 and 0 or (1 - progress/duration)
			local tri, pos, sp, pp, scale = self[9], 1+4*(progress - progress % 0.25), progress % 0.25 >= 0.125, (progress % 0.125) * 8, self.scale
			if self.pos ~= pos then
				for i=1,4 do
					self[i]:SetShown(i >= pos)
					self[4+i]:SetShown(i > pos or (i == pos and not sp))
					if i > pos then
						self[i]:SetSize(24, 24)
						local l, t = i > 2, i == 1 or i == 4
						self[i]:SetTexCoord(l and 0 or 0.5, l and 0.5 or 1, t and 0 or 0.5, t and 0.5 or 1)
						self[4+i]:SetSize(21*scale, 21*scale)
					end
				end
				tri:ClearAllPoints()
				tri:SetPoint((pos % 4 < 2 and "BOTTOM" or "TOP") .. (pos < 3 and "LEFT" or "RIGHT") , self, "CENTER")
				local iH, iV = pos == 2 or pos == 3, pos > 2
				tri:SetTexCoord(iH and 1 or 0, iH and 0 or 1, iV and 1 or 0, iV and 0 or 1)
				self.pos = pos
			end

			local l, r, inv = sp and 21 or (pp * 21), 21 - (sp and pp * 21 or 0), pos == 2 or pos == 4
			l, r = l > 0 and l or 0.00000001, r > 0 and r or 0.00000001
			tri:SetSize((inv and r or l)*scale, (inv and l or r)*scale)

			local chunk, shrunk = self[4+pos], 21 - 21*pp
			chunk:SetSize((inv and 21 or shrunk)*scale, (inv and shrunk or 21)*scale)
			chunk:SetShown(not sp or pp >= 0.9999)

			local p1, p2, e, p1a, p2a = sp and 1 or pp, sp and pp or 0, self[pos]
			if p1 > 0.9 and p2 < 0.1 then
				p1a = 0.9 + (p1 + p2 - 0.9)/2
				p2a = 1-(1.81 - p1a*p1a)^0.5
			else
				p1a, p2a = p1, p2
			end
			if p2 > 0.5 then
			elseif p2 > 0.06 then
				p2 = 0.20 + (p2 - 0.06)*30/44
			elseif p1 > 0.96 then
				p1, p2 = 1, (p2 + p1 - 0.96) * 2
			elseif p1 > 0.56 then
				p1 = p1 + (p1 - 0.56)*0.1
			end
			local p1c, p2c = 24 - 21*p1, 24 - 24*p2
			e:SetSize(inv and p2c or p1c, inv and p1c or p2c)
			if pos == 1 then
				e:SetTexCoord(0.5 + 28/64*p1, 1, 0.5*p2, 0.5)
				self.spark:SetPoint("CENTER", self, "TOP", 22.5 * p1a, -22.5*p2a-1.5)
			elseif pos == 2 then
				e:SetTexCoord(0.5, 1-0.5*p2, 0.5 + 28/64*p1, 1)
				self.spark:SetPoint("CENTER", self, "RIGHT", -22.5*p2a-1.5, -22.5*p1a)
			elseif pos == 3 then
				e:SetTexCoord(0, 0.5 - 28/64*p1, 0.5, 1 - 0.5*p2)
				self.spark:SetPoint("CENTER", self, "BOTTOM", -22.5 * p1a, 1.5+22.5*p2a)
			else
				e:SetTexCoord(0.5*p2, 0.5, 0, 0.5 - 28/64*p1)
				self.spark:SetPoint("CENTER", self, "LEFT", 1.5+22.5*p2a, 22.5*p1a)
			end
			if p2 >= 0.9999 then
				e:Hide()
			end
		end
	end
	local function cdOnHide(self)
		local toExpire = GetTime() - (self.expire or 0)
		self.expire, self.pos = nil
		for i=5,9 do self[i]:Hide() end
		if -0.1 < toExpire and toExpire < 0.25 then
			self.flashAG:Play()
		end
		self:Hide()
		self.spark:Hide()
	end
	local function cdOnShow(self)
		self[9]:Show()
		self.pos = nil -- Forces quad texture update; probably redundant with onHide
		return cdOnUpdate(self, 0)
	end
	function CreateCooldown(parent, size, overParent)
		local cd, scale, b = CreateFrame("Frame", nil, parent), size * 87/4032
		local w, cdText, cdSpark
		cd:SetScale(size/48)
		cd:SetAllPoints()
		cd:SetScript("OnShow", cdOnShow)
		cd:SetScript("OnHide", cdOnHide)
		cd:SetScript("OnUpdate", cdOnUpdate)
		w, cd.scale = cd:CreateFontString(nil, "OVERLAY", "GameFontNormalLargeOutline"), scale
		w:SetPoint("CENTER")
		w, cdText = (overParent or cd):CreateTexture(nil, "OVERLAY", nil, 2), w
		w:SetTexture(gx.CooldownSpark)
		w:SetSize(24,24)
		w, cd.spark, cdSpark = w:CreateAnimationGroup(), w, w
		w:SetLooping("REPEAT")
		b = w:CreateAnimation("Rotation")
		b:SetDegrees(90)
		b:SetDuration(1/3)
		w:Play()
		
		w = parent:CreateTexture(nil, "OVERLAY")
		w:SetSize(60*size/64, 60*size/64)
		w:SetPoint("CENTER")
		w:SetTexture(gx.CooldownStar)
		w:SetBlendMode("ADD")
		w:SetAlpha(0)
		w, cd.flash = w:CreateAnimationGroup(), w
		b, cd.flashAG = w:CreateAnimation("ROTATION"), w
		b:SetDuration(1/2)
		b:SetDegrees(-90)
		b = w:CreateAnimation("Alpha")
		b:SetFromAlpha(0)
		b:SetToAlpha(0.7)
		b:SetDuration(1/8)
		b = w:CreateAnimation("Alpha")
		b:SetFromAlpha(0.7)
		b:SetToAlpha(0)
		b:SetDuration(1/8)
		b:SetStartDelay(3/8)
		
		for i=1,4 do
			cd[i] = cd:CreateTexture(nil, "ARTWORK")
			cd[i]:SetTexture(gx.BorderLow)
		end
		cd[1]:SetPoint("BOTTOMRIGHT", cd, "RIGHT")
		cd[2]:SetPoint("BOTTOMLEFT", cd, "BOTTOM")
		cd[3]:SetPoint("TOPLEFT", cd, "LEFT")
		cd[4]:SetPoint("TOPRIGHT", cd, "TOP")
		for i=1,4 do
			w = parent:CreateTexture(nil, "ARTWORK", nil, 3)
			w:SetColorTexture(1,1,1)
			w:SetPoint((i % 4 < 2 and "TOP" or "BOTTOM") .. (i < 3 and "RIGHT" or "LEFT"), cd, "CENTER", (i < 3 and 21 or -21)*scale, (i % 4 < 2 and 21 or -21)*scale)
			cd[4+i] = w
		end
		cd[9] = parent:CreateTexture(nil, "ARTWORK", nil, 3)
		cd[9]:SetTexture(gx.Tri)
		
		return cd, cdText, cdSpark
	end
end

local function CreateIndicator(name, parent, size, nested)
	local cf, d, w, ef = CreateFrame("Frame", name, parent)
		cf:SetSize(size, size)
	d = newWidgetData(cf, IndicatorData, IndicatorProps)
	ef = CreateFrame("Frame", nil, cf)
		ef:SetAllPoints()
	w = CreateFrame("Frame", nil, cf)
		w:SetAllPoints()
		w:SetFrameLevel(ef:GetFrameLevel()+5)
	d.cd, d.cdText, d.cdSpark = CreateCooldown(ef, size, w)
	w = ef:CreateTexture(nil, "OVERLAY")
		w:SetAllPoints()
		w:SetTexture(gx.BorderLow)
	w, d.edge = ef:CreateTexture(nil, "OVERLAY", nil, 1), w
		w:SetAllPoints()
		w:SetTexture(gx.BorderHigh)
	w, d.hiEdge = T.CreateQuadTexture("BACKGROUND", size*2, gx.OuterGlow, cf), w
		w:SetShown(false)
	w, d.oglow = ef:CreateTexture(nil, "ARTWORK", nil, 1), w
		w:SetAllPoints()
		w:SetTexture(gx.InnerGlow)
		w:SetAlpha(nested and 0.6 or 1)
	w, d.iglow = ef:CreateTexture(nil, "ARTWORK"), w
		w:SetPoint("CENTER")
		w:SetSize(60*size/64, 60*size/64)
	w, d.icon = ef:CreateTexture(nil, "ARTWORK", nil, -2), w
		w:SetPoint("CENTER")
		w:SetSize(60*size/64, 60*size/64)
		w:SetColorTexture(0.15, 0.15, 0.15, 0.85)
	w, d.iconbg = ef:CreateTexture(nil, "ARTWORK", nil, 2), w
		w:SetSize(60*size/64, 60*size/64)
		w:SetPoint("CENTER")
		w:SetColorTexture(0,0,0)
	w, d.veil = ef:CreateTexture(nil, "ARTWORK", nil, 3), w
		w:SetAllPoints()
		w:SetTexture(gx.Ribbon)
		w:Hide()
	w, d.ribbon = ef:CreateTexture(nil, "ARTWORK", nil, 4), w
		w:SetPoint("BOTTOMLEFT", 4, 4)
	w, d.overIcon = ef:CreateFontString(nil, "OVERLAY", "NumberFontNormal"), w
		w:SetJustifyH("RIGHT")
		w:SetPoint("BOTTOMRIGHT", -2, 4)
	w, d.count = ef:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray"), w
		w:SetJustifyH("RIGHT")
		w:SetPoint("TOPRIGHT", -2, -3)
	w, d.key = ef:CreateTexture(nil, "ARTWORK", nil, 2), w
		w:SetSize(size/5, size/4)
		w:SetTexture("Interface\\GuildFrame\\GuildDifficulty")
		w:SetTexCoord(0, 42/128, 6/64, 52/64)
		w:SetPoint("TOPLEFT", 6*size/64, -3*size/64)
	w, d.equipBanner = ef:CreateFontString(nil, "OVERLAY", "TextStatusBarText", -1), w
		w:SetSize(size-4, 12)
		w:SetJustifyH("CENTER")
		w:SetJustifyV("BOTTOM")
		w:SetMaxLines(1)
		w:SetPoint("BOTTOMLEFT", 3, 4)
		w:SetPoint("BOTTOMRIGHT", d.count, "BOTTOMLEFT", 2, 0)
	w, d.label = ef:CreateTexture(nil, "ARTWORK", nil, 3), w
		w:SetPoint("TOPLEFT", 4, -4)
		w:SetSize(14,14)
		w:Hide()
	w, d.qualityMark = ef:CreateMaskTexture(), w
		w:SetTexture(gx.IconMask)
		w:SetAllPoints()
		d.icon:AddMaskTexture(w)
		d.iconMask = w
	return cf
end

XU:RegisterFactory("OPie:MirageIndicator", CreateIndicator)