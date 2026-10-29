
	----------------------------------------------------------------------
	-- Leatrix Plus Minimap Effects for Midnight
	----------------------------------------------------------------------

	local void, Leatrix_Plus = ...

	-- Function to create the effects (returns the effect list)
	function Leatrix_Plus.LoadMinimapEffects()

		local Effects = {}

		local TAU = math.pi * 2
		local sin, cos, abs, max, floor, random, atan2 = math.sin, math.cos, math.abs, math.max, math.floor, math.random, math.atan2
		local RUNE = 165630 -- Spells\AuraRune256
		local STAR = "Interface\\Cooldown\\star4"
		local DOT = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask"
		local WHITE = "Interface\\Buttons\\WHITE8X8"

		----------------------------------------------------------------------
		-- Arcane
		----------------------------------------------------------------------

		Effects[2] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local period, movers = 18, {}
			local points = 72
			-- Function to make a region follow the edge (path animation through points around the edge)
			local function Mover(region, phase)
				local ag = Group(e, region)
				local path = Anim(ag, "Path", period)
				path:SetCurveType(square and "NONE" or "SMOOTH")
				local cps = {}
				for i = 1, square and points + 4 or points do cps[i] = path:CreateControlPoint(); cps[i]:SetOrder(i) end
				tinsert(movers, {region = region, cps = cps, phase = phase})
				return ag
			end
			for w = 0, 2 do
				local phase = w / 3
				for k = 10, 1, -1 do
					local fade = 1 - k / 11
					local d = Tex(e.frame, DOT, "ARTWORK", 1, 1, 0.62, 0.22, 0.6 * fade)
					d:SetSize(2 + 7 * fade, 2 + 7 * fade)
					Mover(d, phase - k * 0.005)
				end
				local core = Tex(e.frame, DOT, "ARTWORK", 2, 1, 0.95, 0.75, 0.9); core:SetSize(9, 9)
				Mover(core, phase)
				local head = Tex(e.frame, STAR, "ARTWORK", 3, 1, 0.78, 0.35); head:SetSize(22, 22)
				local spin = Anim(Mover(head, phase), "Rotation", period); spin:SetDegrees(-360 * 8)
			end
			e.Layout = function()
				for _, m in ipairs(movers) do
					-- Points around the edge starting from the mover (square includes the exact corners)
					local n, ts = #m.cps, {}
					if square then
						for i = 1, n - 4 do ts[i] = i / (n - 4) end
						for c = 0, 3 do tinsert(ts, ((0.125 + c * 0.25) - m.phase) % 1) end
						table.sort(ts)
					else
						for i = 1, n do ts[i] = i / n end
					end
					local sx, sy = EdgeT(m.phase, 4)
					m.region:ClearAllPoints(); m.region:SetPoint("CENTER", e.frame, "CENTER", sx, sy)
					for i = 1, n do
						local x, y = EdgeT(m.phase + ts[i], 4)
						m.cps[i]:SetOffset(x - sx, y - sy)
					end
				end
			end
		end

		----------------------------------------------------------------------
		-- Rune
		----------------------------------------------------------------------

		Effects[3] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local r, g, b = 0.3, 0.55, 1

			-- Round minimap: rune circle
			if not square then
				local ring = Tex(e.back, RUNE, "BACKGROUND", 0, r, g, b)
				ring:SetPoint("CENTER")
				Anim(Group(e, ring), "Rotation", 120):SetDegrees(-360)
				local breathe = Anim(Group(e, ring, "BOUNCE"), "Alpha", 3); breathe:SetFromAlpha(0.5); breathe:SetToAlpha(0.2); breathe:SetSmoothing("IN_OUT")
				e.Layout = function()
					local w = Minimap:GetWidth() * 1.35
					ring:SetSize(w, w)
				end
				return
			end

			-- Square minimap: a band of runes cut from the top of the rune circle (left, right, top, bottom of the texture)
			-- If the band shows too little or too much of the runes, adjust these four numbers
			local cutL, cutR, cutT, cutB = 0.3, 0.7, 0, 0.2
			local band = 14					-- Band thickness
			local period = 3				-- Seconds for the runes to move one piece along
			local turn = 0.6				-- Seconds a piece takes to pivot round a corner

			-- Whole ward breathes like the circle
			local ward = CreateFrame("Frame", nil, e.back)
			ward:SetAllPoints()
			ward:SetFrameLevel(e.back:GetFrameLevel())
			local breathe = Anim(Group(e, ward, "BOUNCE"), "Alpha", 3); breathe:SetFromAlpha(1); breathe:SetToAlpha(0.4); breathe:SetSmoothing("IN_OUT")

			-- Soft glow behind the runes
			local glow = MakeGlow(ward, 1.2, r, g, b, 0.3)

			-- Texture corners for each side (upper left, lower left, upper right, lower right) so the top of the runes always faces outwards
			local l, rr, t, bb = cutL, cutR, cutT, cutB
			local coords = {
				{l, t, l, bb, rr, t, rr, bb},	-- Top
				{l, bb, rr, bb, l, t, rr, t},	-- Right
				{rr, bb, rr, t, l, bb, l, t},	-- Bottom
				{rr, t, l, t, rr, bb, l, bb},	-- Left
			}

			-- Number of pieces around the square (a multiple of 4 so the pieces line up with the corners)
			local nominal = band * (cutR - cutL) / (cutB - cutT)
			local count = math.max(4, floor(8 * (Minimap:GetWidth() / 2 + band / 2) / nominal / 4 + 0.5) * 4)

			-- Each piece travels clockwise round the whole square on one path and pivots as it turns each corner
			local pieces = {}
			for i = 1, count do
				local tex = Tex(ward, RUNE, "BACKGROUND", 1, r, g, b, 0.6)
				local ag = Group(e, tex)
				local path = Anim(ag, "Path", 1)
				path:SetCurveType("NONE")
				local cps = {}
				for j = 1, count * 2 do cps[j] = path:CreateControlPoint(); cps[j]:SetOrder(j) end
				local turns = {}
				for k = 1, 4 do turns[k] = Anim(ag, "Rotation", turn); turns[k]:SetDegrees(-90) end
				pieces[i] = {tex = tex, path = path, cps = cps, turns = turns}
			end

			e.Layout = function()
				if glow.Layout then glow.Layout() end
				local H = Minimap:GetWidth() / 2 + band / 2	-- Distance from the centre to the middle of the band
				local side = H * 2
				local spacing = side * 4 / count			-- Pieces fill the loop exactly
				local speed = spacing / period
				local loop = count * period

				-- Function to get a point on the band, s pixels clockwise from the top left corner
				local function At(s)
					s = s % (side * 4)
					local n = floor(s / side)
					local u = s - n * side
					if n == 0 then return -H + u, H
					elseif n == 1 then return H, H - u
					elseif n == 2 then return H - u, -H
					else return -H, -H + u end
				end

				for i = 1, count do
					local pc = pieces[i]
					local s0 = (i - 0.5) * spacing				-- Half a piece from the corners so none starts on a corner
					local startSide = floor(s0 / side) + 1
					local x0, y0 = At(s0)

					-- Size and runes for the side it starts on (pivoting at the corners turns it to suit the next side)
					if startSide == 1 or startSide == 3 then pc.tex:SetSize(spacing, band) else pc.tex:SetSize(band, spacing) end
					pc.tex:SetTexCoord(unpack(coords[startSide]))
					pc.tex:ClearAllPoints(); pc.tex:SetPoint("CENTER", e.frame, "CENTER", x0, y0)

					-- Path points every half piece all the way round (the corners fall exactly on these points)
					pc.path:SetDuration(loop)
					for j = 1, count * 2 do
						local x, y = At(s0 + j * spacing / 2)
						pc.cps[j]:SetOffset(x - x0, y - y0)
					end

					-- Pivot as each corner is reached
					local first = startSide * side - s0
					for k = 1, 4 do
						local arrive = (first + (k - 1) * side) / speed
						pc.turns[k]:SetStartDelay(arrive - turn / 2)
					end
				end
			end
		end

		----------------------------------------------------------------------
		-- Vortex
		----------------------------------------------------------------------

		Effects[4] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local glow = MakeGlow(e.back, 1.3, 0.55, 0.3, 1, 0.5, 0.12)
			local motes, steps = {}, 10
			-- Function to give a mote a new spiral (starts outside the edge and curls in)
			local function Reset(m)
				local a0, reach = random() * TAU, random(35, 55)
				local sx, sy = EdgeAt(a0, reach)
				m.tex:ClearAllPoints(); m.tex:SetPoint("CENTER", e.frame, "CENTER", sx, sy)
				for j = 1, steps do
					local f = j / steps
					local x, y = EdgeAt(a0 + f * 1.4, reach * (1 - f) - 2)
					m.cps[j]:SetOffset(x - sx, y - sy)
				end
				local d = 1.6 + random() * 1.4
				m.path:SetDuration(d); m.shrink:SetDuration(d); m.fadeOut:SetDuration(d * 0.4); m.fadeOut:SetStartDelay(d * 0.6)
			end
			for i = 1, 30 do
				local big = i <= 6
				local t = Tex(e.frame, big and STAR or DOT, "ARTWORK", 1, 0.6 + random() * 0.4, 0.4, 1)
				local size = big and random(10, 14) or random(3, 6)
				t:SetSize(size, size)
				local ag = Group(e, t)
				local m = {tex = t, cps = {}}
				m.path = Anim(ag, "Path", 2); m.path:SetCurveType("SMOOTH")
				for j = 1, steps do m.cps[j] = m.path:CreateControlPoint(); m.cps[j]:SetOrder(j) end
				m.shrink = Anim(ag, "Scale", 2); m.shrink:SetScaleFrom(1.2, 1.2); m.shrink:SetScaleTo(0.3, 0.3); m.shrink:SetSmoothing("IN")
				local fi = Anim(ag, "Alpha", 0.3); fi:SetFromAlpha(0); fi:SetToAlpha(1)
				m.fadeOut = Anim(ag, "Alpha", 0.8, 1, 1.2); m.fadeOut:SetFromAlpha(1); m.fadeOut:SetToAlpha(0)
				if big then Anim(ag, "Rotation", 2):SetDegrees(360) end
				ag:SetScript("OnLoop", function() Reset(m) end)
				motes[i] = m
			end
			e.Layout = function()
				if glow.Layout then glow.Layout() end
				for i = 1, #motes do Reset(motes[i]) end
			end
		end

		----------------------------------------------------------------------
		-- Inferno
		----------------------------------------------------------------------

		Effects[5] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local glow = MakeGlow(e.back, 1.4, 1, 0.35, 0.05, 0.7, 0.18)
			local flames, sparks = {}, {}
			for i = 1, 32 do
				local t = e.frame:CreateTexture(nil, "ARTWORK", nil, 1)
				t:SetAtlas("Fyrakk_Flame_FX")
				t:SetBlendMode("ADD")
				t:SetVertexColor(1, 0.5 + random() * 0.3, 0.15)
				t.h = random(18, 30)
				t:SetSize(t.h * 0.6, t.h)
				t.t = (i - 1) / 32 + random() * 0.01
				-- Flicker (each flame at its own speed)
				local ag = Group(e, t, "BOUNCE")
				local speed = 0.2 + random() * 0.3
				local sc = Anim(ag, "Scale", speed); sc:SetScaleFrom(0.8, 0.7); sc:SetScaleTo(1.05, 1.2); sc:SetSmoothing("IN_OUT")
				local al = Anim(ag, "Alpha", speed); al:SetFromAlpha(0.55); al:SetToAlpha(1)
				flames[i] = t
			end
			-- Function to send a spark from a random point on the edge
			local function Reset(sp)
				local t = random()
				local a = EdgeNormal(t)
				local x, y = EdgeT(t, 4)
				sp.tex:ClearAllPoints(); sp.tex:SetPoint("CENTER", e.frame, "CENTER", x, y)
				local dist = random(20, 45)
				sp.move:SetOffset(cos(a) * dist + random(-8, 8), sin(a) * dist + random(0, 12))
				local d = 0.8 + random() * 1.2
				sp.move:SetDuration(d); sp.fadeOut:SetDuration(d - 0.15)
			end
			for i = 1, 14 do
				local t = e.frame:CreateTexture(nil, "ARTWORK", nil, 2)
				t:SetAtlas("titleprestige-ember")
				t:SetBlendMode("ADD")
				local size = random(8, 14); t:SetSize(size, size)
				local ag = Group(e, t)
				local sp = {tex = t}
				sp.move = Anim(ag, "Translation", 1)
				local fi = Anim(ag, "Alpha", 0.15); fi:SetFromAlpha(0); fi:SetToAlpha(1)
				sp.fadeOut = Anim(ag, "Alpha", 1, 1, 0.15); sp.fadeOut:SetFromAlpha(1); sp.fadeOut:SetToAlpha(0)
				ag:SetScript("OnLoop", function() Reset(sp) end)
				sparks[i] = sp
			end
			e.Layout = function()
				if glow.Layout then glow.Layout() end
				for i = 1, #flames do
					local f = flames[i]
					-- Base of the flame sits on the edge and it points outwards
					local a = EdgeNormal(f.t)
					local x, y = EdgeT(f.t, 0)
					f:ClearAllPoints(); f:SetPoint("CENTER", e.frame, "CENTER", x + cos(a) * f.h * 0.4, y + sin(a) * f.h * 0.4)
					f:SetRotation(a - TAU / 4)
				end
				for i = 1, #sparks do Reset(sparks[i]) end
			end
		end

		----------------------------------------------------------------------
		-- Snow
		----------------------------------------------------------------------

		Effects[6] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local flakes = {}
			-- Function to give a flake a new column, sway and speed (first fall starts at a random time)
			local function Reset(fl, first)
				local half = Minimap:GetWidth() / 2
				fl.tex:ClearAllPoints(); fl.tex:SetPoint("CENTER", e.frame, "CENTER", random(-half - 10, half + 10), half + 12)
				local d = 6 + random() * 5
				fl.fall:SetOffset(random(-18, 18), -(half * 2 + 24)); fl.fall:SetDuration(d)
				fl.fadeIn:SetDuration(d - 1.2); fl.fadeOut:SetDuration(1.2)
				local wait = first and random() * d or random() * 1.5
				fl.fall:SetStartDelay(wait); fl.fadeIn:SetStartDelay(wait); fl.fadeOut:SetStartDelay(wait + d - 1.2)
				if fl.spin then fl.spin:SetDuration(d); fl.spin:SetStartDelay(wait) end
			end
			for i = 1, 34 do
				local big = i <= 12
				local t = Tex(e.frame, big and STAR or DOT, "ARTWORK", 1, 0.9, 0.95, 1)
				local size = big and random(7, 11) or random(2, 4)
				t:SetSize(size, size)
				t:SetAlpha(0) -- Hidden while waiting to fall
				local ag = Group(e, t)
				local fl = {tex = t}
				fl.fall = Anim(ag, "Translation", 8)
				-- Fade in quickly and stay visible until the fade out starts
				fl.fadeIn = Anim(ag, "Alpha", 1); fl.fadeIn:SetFromAlpha(0); fl.fadeIn:SetToAlpha(0.9); fl.fadeIn:SetSmoothing("OUT")
				fl.fadeOut = Anim(ag, "Alpha", 1.2); fl.fadeOut:SetFromAlpha(0.9); fl.fadeOut:SetToAlpha(0)
				if big then fl.spin = Anim(ag, "Rotation", 8); fl.spin:SetDegrees(random(-270, 270)) end
				ag:SetScript("OnLoop", function() Reset(fl) end)
				flakes[i] = fl
			end
			e.Layout = function()
				for i = 1, #flakes do Reset(flakes[i], true) end
			end
		end

		----------------------------------------------------------------------
		-- Storm
		----------------------------------------------------------------------

		Effects[7] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local bolts = {}
			local sqrt = math.sqrt
			-- Function to draw a jagged line between two points using line slots (returns the points)
			local function Jag(slots, first, x1, y1, x2, y2, segs, jitter)
				local dx, dy = x2 - x1, y2 - y1
				local len = max(sqrt(dx * dx + dy * dy), 1)
				local nx, ny = -dy / len, dx / len
				local px, py, pts = x1, y1, {}
				for j = 1, segs do
					local f = j / segs
					local off = j == segs and 0 or (random() * 2 - 1) * jitter
					local x, y = x1 + dx * f + nx * off, y1 + dy * f + ny * off
					for _, line in ipairs(slots[first + j - 1]) do
						line:SetStartPoint("CENTER", e.frame, px, py)
						line:SetEndPoint("CENTER", e.frame, x, y)
					end
					pts[j] = {x, y}
					px, py = x, y
				end
				return pts
			end
			-- Function to give a bolt a new strike point, shape and wait
			local function Reset(bolt)
				local t = random()
				local tx, ty = EdgeT(t, 0)
				local ox, oy = EdgeT(t + (random() - 0.5) * 0.06, random(50, 70))
				local pts = Jag(bolt.slots, 1, ox, oy, tx, ty, 8, 7)
				-- Two branches splitting off the main bolt
				for b = 0, 1 do
					local p = pts[random(2, 5)]
					local side = b == 0 and 1 or -1
					local bx, by = EdgeT(t + side * (0.02 + random() * 0.04), random(8, 25))
					Jag(bolt.slots, 9 + b * 3, p[1], p[2], bx, by, 3, 4)
				end
				bolt.impact:ClearAllPoints(); bolt.impact:SetPoint("CENTER", e.frame, "CENTER", tx, ty)
				bolt.star:ClearAllPoints(); bolt.star:SetPoint("CENTER", e.frame, "CENTER", tx, ty)
				bolt.wait:SetStartDelay(1 + random() * 3)
			end
			for i = 1, 3 do
				local bf = CreateFrame("Frame", nil, e.frame)
				bf:SetAllPoints(); bf:SetAlpha(0)
				local bolt = {slots = {}}
				-- 8 segments for the main bolt and 3 for each branch
				for j = 1, 14 do
					local main = j <= 8
					local glowLine = bf:CreateLine(nil, "ARTWORK", nil, 1)
					glowLine:SetColorTexture(0.55, 0.4, 1, main and 0.4 or 0.25); glowLine:SetBlendMode("ADD"); glowLine:SetThickness(main and 8 or 5)
					local core = bf:CreateLine(nil, "ARTWORK", nil, 2)
					core:SetColorTexture(0.92, 0.88, 1, 1); core:SetBlendMode("ADD"); core:SetThickness(main and 2 or 1)
					bolt.slots[j] = {glowLine, core}
				end
				-- Flash where the bolt hits and across the whole edge
				bolt.impact = Tex(bf, DOT, "ARTWORK", 3, 0.75, 0.65, 1, 0.8); bolt.impact:SetSize(36, 36)
				bolt.star = Tex(bf, STAR, "ARTWORK", 4, 1, 1, 1); bolt.star:SetSize(30, 30)
				-- Edge glow flash is a child of the bolt (so it flashes with it) but drawn behind the minimap
				local gf = CreateFrame("Frame", nil, bf)
				gf:SetAllPoints(); gf:SetFrameLevel(e.back:GetFrameLevel())
				bolt.edgeFlash = MakeGlow(gf, 1.4, 0.6, 0.5, 1, 0.6, 0.18)
				-- Strike, flicker, strike again and fade
				local ag = Group(e, bf)
				bolt.wait = Anim(ag, "Alpha", 0.04, 1); bolt.wait:SetFromAlpha(0); bolt.wait:SetToAlpha(1)
				local f1 = Anim(ag, "Alpha", 0.06, 2); f1:SetFromAlpha(1); f1:SetToAlpha(0.15)
				local f2 = Anim(ag, "Alpha", 0.04, 3); f2:SetFromAlpha(0.15); f2:SetToAlpha(1)
				local f3 = Anim(ag, "Alpha", 0.08, 4); f3:SetFromAlpha(1); f3:SetToAlpha(1)
				local f4 = Anim(ag, "Alpha", 0.5, 5); f4:SetFromAlpha(1); f4:SetToAlpha(0)
				ag:SetScript("OnLoop", function() Reset(bolt) end)
				bolts[i] = bolt
			end
			e.Layout = function()
				for i = 1, #bolts do
					if bolts[i].edgeFlash.Layout then bolts[i].edgeFlash.Layout() end
					Reset(bolts[i])
				end
			end
		end

		----------------------------------------------------------------------
		-- Corona
		----------------------------------------------------------------------

		Effects[8] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local glow = MakeGlow(e.back, 1.3, 1, 0.6, 0.15, 0.6, 0.12)
			local rays, count, step = {}, 64, 0.04
			for k = 0, count - 1 do
				local rf = CreateFrame("Frame", nil, e.frame)
				rf:SetAllPoints()
				rf:SetAlpha(0.3)
				-- Long soft ray with a short bright core
				local soft = rf:CreateLine(nil, "ARTWORK", nil, 1)
				soft:SetColorTexture(1, 0.65, 0.2, 0.35); soft:SetBlendMode("ADD"); soft:SetThickness(3)
				local core = rf:CreateLine(nil, "ARTWORK", nil, 2)
				core:SetColorTexture(1, 0.9, 0.55, 0.9); core:SetBlendMode("ADD"); core:SetThickness(1)
				-- Brighten in turn around the edge, then settle back
				local ag = Group(e, rf)
				local up = Anim(ag, "Alpha", 0.5, 1, k * step); up:SetFromAlpha(0.3); up:SetToAlpha(1)
				local down = Anim(ag, "Alpha", 1.1, 2); down:SetFromAlpha(1); down:SetToAlpha(0.3); down:SetEndDelay((count - k) * step)
				rays[k + 1] = {soft = soft, core = core, t = k / count, len = random(8, 22)}
			end
			e.Layout = function()
				if glow.Layout then glow.Layout() end
				for i = 1, #rays do
					local ray = rays[i]
					local a = EdgeNormal(ray.t)
					local x, y = EdgeT(ray.t, 1)
					local ex, ey = x + cos(a) * ray.len, y + sin(a) * ray.len
					local cx, cy = x + cos(a) * ray.len * 0.5, y + sin(a) * ray.len * 0.5
					ray.soft:SetStartPoint("CENTER", e.frame, x, y); ray.soft:SetEndPoint("CENTER", e.frame, ex, ey)
					ray.core:SetStartPoint("CENTER", e.frame, x, y); ray.core:SetEndPoint("CENTER", e.frame, cx, cy)
				end
			end
		end

		----------------------------------------------------------------------
		-- Aurora
		----------------------------------------------------------------------

		Effects[9] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local layers = {}
			local mul = square and 0.6 or 0.1 -- Round glow is made of stacked circles so each one is fainter
			for i = 1, 3 do
				-- Each layer is in its own frame so it can breathe at its own pace
				local lf = CreateFrame("Frame", nil, e.back)
				lf:SetAllPoints()
				local breathe = Anim(Group(e, lf, "BOUNCE"), "Alpha", 1.2 + i * 0.5); breathe:SetFromAlpha(1); breathe:SetToAlpha(0.35); breathe:SetSmoothing("IN_OUT")
				local pieces = MakeGlow(lf, 0.9 + i * 0.35, 1, 1, 1, 1, 0.03 + i * 0.035)
				-- Cycle each piece through the colour wheel (pieces start at different colours so they flow around square edges)
				for p = 1, #pieces do
					local ag = Group(e, pieces[p])
					local h0 = i * 0.12 + p / 8
					for j = 1, 6 do
						local r1, g1, b1 = Hue(h0 + (j - 1) / 6)
						local r2, g2, b2 = Hue(h0 + j / 6)
						local vc = Anim(ag, "VertexColor", 4, j)
						vc:SetStartColor(CreateColor(r1, g1, b1, mul))
						vc:SetEndColor(CreateColor(r2, g2, b2, mul))
					end
				end
				layers[i] = pieces
			end
			e.Layout = function()
				for i = 1, 3 do if layers[i].Layout then layers[i].Layout() end end
			end
		end

		----------------------------------------------------------------------
		-- Starfield
		----------------------------------------------------------------------

		Effects[10] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local stars = {}
			for i = 1, 32 do
				local big = i <= 8
				local t = Tex(e.frame, big and STAR or DOT, "ARTWORK", 1, 0.8, 0.9, 1)
				local size = big and random(8, 13) or random(2, 4)
				t:SetSize(size, size)
				t.t, t.d = random(), random(3, 16)
				local ag = Group(e, t, "BOUNCE")
				local tw = Anim(ag, "Alpha", 0.6 + random() * 1.6); tw:SetFromAlpha(1); tw:SetToAlpha(0.1)
				stars[i] = t
			end
			-- Shooting star (head and fading tail)
			local sf = CreateFrame("Frame", nil, e.frame); sf:SetSize(1, 1); sf:SetAlpha(0)
			local head = Tex(sf, STAR, "ARTWORK", 3, 1, 1, 1); head:SetSize(16, 16); head:SetPoint("CENTER")
			local tail = Tex(sf, WHITE, "ARTWORK", 2, 1, 1, 1); tail:SetSize(42, 2)
			tail:SetGradient("HORIZONTAL", CreateColor(0.7, 0.85, 1, 0), CreateColor(1, 1, 1, 0.9))
			local ag = Group(e, sf)
			local move = Anim(ag, "Translation", 0.9)
			local fi = Anim(ag, "Alpha", 0.5); fi:SetFromAlpha(0); fi:SetToAlpha(1); fi:SetSmoothing("OUT")
			local fo = Anim(ag, "Alpha", 0.4, 1, 0.5); fo:SetFromAlpha(1); fo:SetToAlpha(0)
			-- Function to choose a new path and wait for the shooting star
			local function Shoot()
				local t = random()
				local sx, sy = EdgeT(t, 28)
				local ex, ey = EdgeT(t + 0.12, 6)
				local dx, dy = ex - sx, ey - sy
				local ang = atan2(dy, dx)
				sf:ClearAllPoints(); sf:SetPoint("CENTER", e.frame, "CENTER", sx, sy)
				tail:ClearAllPoints(); tail:SetPoint("CENTER", head, "CENTER", -cos(ang) * 21, -sin(ang) * 21)
				tail:SetRotation(ang)
				move:SetOffset(dx, dy)
				local wait = 4 + random() * 6
				move:SetStartDelay(wait); fi:SetStartDelay(wait); fo:SetStartDelay(wait + 0.5)
			end
			ag:SetScript("OnLoop", Shoot)
			e.Layout = function()
				for i = 1, #stars do
					local x, y = EdgeT(stars[i].t, stars[i].d)
					stars[i]:ClearAllPoints(); stars[i]:SetPoint("CENTER", e.frame, "CENTER", x, y)
				end
				Shoot()
			end
		end

		----------------------------------------------------------------------
		-- Chronometer
		----------------------------------------------------------------------

		Effects[11] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local ticks, ticker = {}, nil
			for s = 0, 59 do
				local major = s % 5 == 0
				local t = Tex(e.frame, WHITE, "ARTWORK", 1, 1, 0.82, 0.35)
				t:SetSize(major and 9 or 5, major and 2 or 1.5)
				t.base = major and 0.5 or 0.25
				t:SetAlpha(t.base)
				t.angle = TAU / 4 - s * TAU / 60
				t:SetRotation(t.angle)
				-- Light up and fade back over a few seconds (leaves a short trail behind the current second)
				t.ag = t:CreateAnimationGroup()
				local a = Anim(t.ag, "Alpha", 4); a:SetFromAlpha(1); a:SetToAlpha(t.base)
				ticks[s] = t
			end
			local hand = Tex(e.frame, DOT, "ARTWORK", 2, 1, 0.9, 0.5, 0.9); hand:SetSize(8, 8)
			-- Function to light the current second
			local function Tick()
				local s = GetServerTime() % 60
				ticks[s].ag:Stop(); ticks[s].ag:Play()
				hand:ClearAllPoints(); hand:SetPoint("CENTER", ticks[s], "CENTER")
			end
			e.Layout = function()
				for s = 0, 59 do
					local x, y = EdgeAt(ticks[s].angle, 6)
					ticks[s]:ClearAllPoints(); ticks[s]:SetPoint("CENTER", e.frame, "CENTER", x, y)
				end
			end
			e.OnStart = function() Tick(); ticker = C_Timer.NewTicker(1, Tick) end
			e.OnStop = function() if ticker then ticker:Cancel(); ticker = nil end end
		end

		----------------------------------------------------------------------
		-- Heartbeat
		----------------------------------------------------------------------

		Effects[12] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local beat, wave, count = 1.2, 0.8, 60
			-- Glow that thumps twice each beat
			local gf = CreateFrame("Frame", nil, e.back); gf:SetAllPoints(); gf:SetFrameLevel(e.back:GetFrameLevel()); gf:SetAlpha(0.25)
			local glow = MakeGlow(gf, 1.3, 1, 0.12, 0.18, 0.9, 0.16)
			local ag = Group(e, gf)
			local a1 = Anim(ag, "Alpha", 0.1, 1); a1:SetFromAlpha(0.25); a1:SetToAlpha(1)
			local a2 = Anim(ag, "Alpha", 0.15, 2); a2:SetFromAlpha(1); a2:SetToAlpha(0.45)
			local a3 = Anim(ag, "Alpha", 0.1, 3); a3:SetFromAlpha(0.45); a3:SetToAlpha(1)
			local a4 = Anim(ag, "Alpha", 0.5, 4); a4:SetFromAlpha(1); a4:SetToAlpha(0.25); a4:SetEndDelay(beat - 0.85)
			-- Pulse dots (start at the top and run down both sides to meet at the bottom)
			local dots = {}
			for k = 0, count - 1 do
				local d = Tex(e.frame, DOT, "ARTWORK", 1, 1, 0.25, 0.3); d:SetSize(4, 4); d:SetAlpha(0.15)
				local fromTop = math.min(k, count - k) / (count / 2)
				local dg = Group(e, d)
				local p = Anim(dg, "Alpha", 0.4, 1, fromTop * wave); p:SetFromAlpha(1); p:SetToAlpha(0.15)
				p:SetEndDelay(beat - 0.4 - fromTop * wave)
				d.t = 0.25 - k / count -- Clockwise from the top
				dots[k + 1] = d
			end
			e.Layout = function()
				if glow.Layout then glow.Layout() end
				for i = 1, #dots do
					local x, y = EdgeT(dots[i].t, 3)
					dots[i]:ClearAllPoints(); dots[i]:SetPoint("CENTER", e.frame, "CENTER", x, y)
				end
			end
		end

		----------------------------------------------------------------------
		-- Fireworks
		----------------------------------------------------------------------

		Effects[13] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local period, climb, burst, count = 3, 0.5, 1.1, 16
			local fireworks = {}
			-- Function to choose a new launch point, burst point and colour
			local function Reset(fw)
				local t = random()
				local sx, sy = EdgeT(t, 0)
				local bx, by = EdgeT(t + (random() - 0.5) * 0.04, random(18, 30))
				fw.frame:ClearAllPoints(); fw.frame:SetPoint("CENTER", e.frame, "CENTER", bx, by)
				fw.rocket:ClearAllPoints(); fw.rocket:SetPoint("CENTER", fw.frame, "CENTER", sx - bx, sy - by)
				fw.climb:SetOffset(bx - sx, by - sy)
				local r, g, b = Hue(random())
				for i = 1, #fw.sparks do
					local sp = fw.sparks[i]
					sp.tex:SetVertexColor(r, g, b)
					local a, dist = (i / #fw.sparks) * math.pi * 2 + random() * 0.2, random(16, 26)
					sp.cps[1]:SetOffset(cos(a) * dist * 0.7, sin(a) * dist * 0.7 + 2)
					sp.cps[2]:SetOffset(cos(a) * dist, sin(a) * dist - 7)
				end
			end
			for f = 1, 4 do
				local fw = {sparks = {}, groups = {}}
				fw.frame = CreateFrame("Frame", nil, e.frame); fw.frame:SetSize(1, 1)
				-- Rocket climbs from the edge to the burst point then vanishes
				fw.rocket = Tex(fw.frame, STAR, "ARTWORK", 2, 1, 0.95, 0.75); fw.rocket:SetSize(10, 10); fw.rocket:SetAlpha(0)
				local rg = fw.rocket:CreateAnimationGroup(); rg:SetLooping("REPEAT")
				fw.climb = Anim(rg, "Translation", climb, 1); fw.climb:SetSmoothing("OUT")
				local show = Anim(rg, "Alpha", climb, 1); show:SetFromAlpha(1); show:SetToAlpha(1)
				local hide = Anim(rg, "Alpha", 0.05, 2); hide:SetFromAlpha(1); hide:SetToAlpha(0); hide:SetEndDelay(period - climb - 0.05)
				rg:SetScript("OnLoop", function() Reset(fw) end)
				tinsert(fw.groups, rg)
				-- Sparks burst outwards, droop and fade
				for i = 1, count do
					local t = Tex(fw.frame, i % 4 == 0 and STAR or DOT, "ARTWORK", 1)
					local size = i % 4 == 0 and 8 or 3
					t:SetSize(size, size); t:SetPoint("CENTER"); t:SetAlpha(0)
					local sg = t:CreateAnimationGroup(); sg:SetLooping("REPEAT")
					local sp = {tex = t, cps = {}}
					local path = Anim(sg, "Path", burst, 1, climb); path:SetCurveType("SMOOTH")
					for j = 1, 2 do sp.cps[j] = path:CreateControlPoint(); sp.cps[j]:SetOrder(j) end
					local fade = Anim(sg, "Alpha", burst, 1, climb); fade:SetFromAlpha(1); fade:SetToAlpha(0); fade:SetEndDelay(period - climb - burst)
					tinsert(fw.groups, sg)
					fw.sparks[i] = sp
				end
				fireworks[f] = fw
			end
			e.Layout = function()
				for f = 1, #fireworks do Reset(fireworks[f]) end
			end
			-- Launch the fireworks one after another (each firework's rocket and sparks start together so they stay in step)
			e.OnStart = function()
				local gen = e.gen
				for f = 1, #fireworks do
					C_Timer.After((f - 1) * period / #fireworks, function()
						if e.gen ~= gen then return end
						for _, ag in ipairs(fireworks[f].groups) do ag:Play() end
					end)
				end
			end
			e.OnStop = function()
				for f = 1, #fireworks do
					for _, ag in ipairs(fireworks[f].groups) do ag:Stop() end
				end
			end
		end

		----------------------------------------------------------------------
		-- Crystals
		----------------------------------------------------------------------

		Effects[14] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local glow = MakeGlow(e.back, 1.2, 0.4, 0.75, 1, 0.4, 0.1)
			local count, step = 36, 0.07
			local shards, glints = {}, {}
			for k = 0, count - 1 do
				-- A shard is a frame so its body and bright core shimmer together
				local sf = CreateFrame("Frame", nil, e.frame); sf:SetAllPoints(); sf:SetAlpha(0.45)
				local len = random(7, 20)
				local body = Tex(sf, WHITE, "ARTWORK", 1, 0.45, 0.75, 1, 0.55)
				local core = Tex(sf, WHITE, "ARTWORK", 2, 0.85, 0.95, 1, 0.9)
				local ag = Group(e, sf)
				local up = Anim(ag, "Alpha", 0.35, 1, k * step); up:SetFromAlpha(0.45); up:SetToAlpha(1)
				local down = Anim(ag, "Alpha", 0.8, 2); down:SetFromAlpha(1); down:SetToAlpha(0.45); down:SetEndDelay((count - k) * step)
				shards[k + 1] = {body = body, core = core, len = len, t = (k + random() * 0.6) / count}
			end
			-- Glints that sparkle on the shard tips
			local function Place(gl)
				local s = shards[random(1, #shards)]
				local a = EdgeNormal(s.t)
				local x, y = EdgeT(s.t, 0)
				gl.tex:ClearAllPoints(); gl.tex:SetPoint("CENTER", e.frame, "CENTER", x + cos(a) * s.len, y + sin(a) * s.len)
				gl.grow:SetStartDelay(random() * 2.5); gl.turn:SetStartDelay(gl.grow:GetStartDelay()); gl.fadeIn:SetStartDelay(gl.grow:GetStartDelay())
			end
			for i = 1, 6 do
				local t = Tex(e.frame, STAR, "ARTWORK", 3, 1, 1, 1); t:SetSize(14, 14); t:SetAlpha(0)
				local ag = Group(e, t)
				local gl = {tex = t}
				gl.grow = Anim(ag, "Scale", 0.3, 1); gl.grow:SetScaleFrom(0.1, 0.1); gl.grow:SetScaleTo(1, 1)
				gl.turn = Anim(ag, "Rotation", 0.3, 1); gl.turn:SetDegrees(90)
				gl.fadeIn = Anim(ag, "Alpha", 0.3, 1); gl.fadeIn:SetFromAlpha(0); gl.fadeIn:SetToAlpha(1)
				local shrink = Anim(ag, "Scale", 0.5, 2); shrink:SetScaleFrom(1, 1); shrink:SetScaleTo(0.1, 0.1)
				local fadeOut = Anim(ag, "Alpha", 0.5, 2); fadeOut:SetFromAlpha(1); fadeOut:SetToAlpha(0)
				ag:SetScript("OnLoop", function() Place(gl) end)
				glints[i] = gl
			end
			e.Layout = function()
				if glow.Layout then glow.Layout() end
				for i = 1, #shards do
					local s = shards[i]
					-- Shard points outwards with its base just inside the edge
					local a = EdgeNormal(s.t)
					local x, y = EdgeT(s.t, 0)
					local cx, cy = x + cos(a) * (s.len / 2 - 1), y + sin(a) * (s.len / 2 - 1)
					s.body:SetSize(s.len, 4); s.core:SetSize(s.len * 0.8, 1.5)
					for _, t in ipairs({s.body, s.core}) do
						t:ClearAllPoints(); t:SetPoint("CENTER", e.frame, "CENTER", cx, cy)
						t:SetRotation(a)
					end
				end
				for i = 1, #glints do Place(glints[i]) end
			end
		end

		----------------------------------------------------------------------
		-- Neon
		----------------------------------------------------------------------

		Effects[15] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local segs = square and 4 or 72
			local tubes = {}
			for i, v in ipairs({{2, 1, 0.2, 0.7}, {7, 0.2, 0.9, 1}}) do
				local tf = CreateFrame("Frame", nil, e.frame); tf:SetAllPoints()
				local tube = {frame = tf, d = v[1], lines = {}}
				for j = 1, segs do
					local glowLine = tf:CreateLine(nil, "ARTWORK", nil, 1)
					glowLine:SetColorTexture(v[2], v[3], v[4], 0.25); glowLine:SetBlendMode("ADD"); glowLine:SetThickness(7)
					local core = tf:CreateLine(nil, "ARTWORK", nil, 2)
					core:SetColorTexture(v[2] * 0.5 + 0.5, v[3] * 0.5 + 0.5, v[4] * 0.5 + 0.5, 0.95); core:SetBlendMode("ADD"); core:SetThickness(1.5)
					tube.lines[j] = {glowLine, core}
				end
				-- Steady, then a quick flicker
				local ag = Group(e, tf)
				tube.hold = Anim(ag, "Alpha", 4, 1); tube.hold:SetFromAlpha(1); tube.hold:SetToAlpha(1)
				local f1 = Anim(ag, "Alpha", 0.05, 2); f1:SetFromAlpha(1); f1:SetToAlpha(0.15)
				local f2 = Anim(ag, "Alpha", 0.05, 3); f2:SetFromAlpha(0.15); f2:SetToAlpha(1)
				local f3 = Anim(ag, "Alpha", 0.04, 4); f3:SetFromAlpha(1); f3:SetToAlpha(0.3)
				local f4 = Anim(ag, "Alpha", 0.08, 5); f4:SetFromAlpha(0.3); f4:SetToAlpha(1)
				ag:SetScript("OnLoop", function() tube.hold:SetDuration(3 + random() * 6) end)
				tube.hold:SetDuration(2 + random() * 6)
				tubes[i] = tube
			end
			e.Layout = function()
				for _, tube in ipairs(tubes) do
					for j = 1, segs do
						local x1, y1, x2, y2
						if square then
							local hh = Minimap:GetWidth() / 2 + tube.d
							local c = {{-hh, hh}, {hh, hh}, {hh, -hh}, {-hh, -hh}}
							local a, z = c[j], c[j % 4 + 1]
							x1, y1, x2, y2 = a[1], a[2], z[1], z[2]
						else
							x1, y1 = EdgeT((j - 1) / segs, tube.d)
							x2, y2 = EdgeT(j / segs, tube.d)
						end
						for _, line in ipairs(tube.lines[j]) do
							line:SetStartPoint("CENTER", e.frame, x1, y1)
							line:SetEndPoint("CENTER", e.frame, x2, y2)
						end
					end
				end
			end
		end

		----------------------------------------------------------------------
		-- Marquee
		----------------------------------------------------------------------

		Effects[16] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local bulbs, count, step = {}, 40, 0.25
			for k = 0, count - 1 do
				local bf = CreateFrame("Frame", nil, e.frame); bf:SetSize(1, 1); bf:SetAlpha(0.2)
				local halo = Tex(bf, DOT, "ARTWORK", 1, 1, 0.7, 0.25, 0.35); halo:SetSize(13, 13); halo:SetPoint("CENTER")
				local bulb = Tex(bf, DOT, "ARTWORK", 2, 1, 0.92, 0.6); bulb:SetSize(5, 5); bulb:SetPoint("CENTER")
				-- Every third bulb lights together and the pattern steps round
				local phase = k % 3
				local ag = Group(e, bf)
				local on = Anim(ag, "Alpha", 0.05, 1, phase * step); on:SetFromAlpha(0.2); on:SetToAlpha(1)
				local hold = Anim(ag, "Alpha", 0.15, 2); hold:SetFromAlpha(1); hold:SetToAlpha(1)
				local off = Anim(ag, "Alpha", 0.05, 3); off:SetFromAlpha(1); off:SetToAlpha(0.2); off:SetEndDelay(0.5 - phase * step)
				bf.t = 0.25 - k / count
				bulbs[k + 1] = bf
			end
			e.Layout = function()
				for i = 1, #bulbs do
					local x, y = EdgeT(bulbs[i].t, 5)
					bulbs[i]:ClearAllPoints(); bulbs[i]:SetPoint("CENTER", e.frame, "CENTER", x, y)
				end
			end
		end

		----------------------------------------------------------------------
		-- Glitch
		----------------------------------------------------------------------

		Effects[17] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local blocks = {}
			-- Function to give a glitch a new place, shape and wait
			local function Reset(gl)
				local x, y = EdgeT(random(), random(-4, 8))
				local w, ht = random(10, 40), random(2, 6)
				gl.frame:ClearAllPoints(); gl.frame:SetPoint("CENTER", e.frame, "CENTER", x, y)
				gl.cyan:SetSize(w, ht); gl.magenta:SetSize(w, ht)
				local j = random(-6, 6)
				gl.jitter:SetOffset(j, 0); gl.back:SetOffset(-j, 0)
				gl.on:SetStartDelay(0.3 + random() * 2.2)
			end
			for i = 1, 10 do
				local gf = CreateFrame("Frame", nil, e.frame); gf:SetSize(1, 1); gf:SetAlpha(0)
				local gl = {frame = gf}
				gl.cyan = Tex(gf, WHITE, "ARTWORK", 1, 0, 1, 1, 0.8); gl.cyan:SetPoint("CENTER", -1, 0)
				gl.magenta = Tex(gf, WHITE, "ARTWORK", 2, 1, 0, 1, 0.8); gl.magenta:SetPoint("CENTER", 1, 1)
				local ag = Group(e, gf)
				gl.on = Anim(ag, "Alpha", 0.02, 1); gl.on:SetFromAlpha(0); gl.on:SetToAlpha(1)
				gl.jitter = Anim(ag, "Translation", 0.05, 2)
				gl.back = Anim(ag, "Translation", 0.05, 3)
				local off = Anim(ag, "Alpha", 0.03, 4); off:SetFromAlpha(1); off:SetToAlpha(0)
				ag:SetScript("OnLoop", function() Reset(gl) end)
				blocks[i] = gl
			end
			-- Scanline rolling down the minimap
			local scan = Tex(e.frame, WHITE, "ARTWORK", 0, 0.6, 1, 1, 0.08)
			local roll = Anim(Group(e, scan), "Translation", 4)
			e.Layout = function()
				local w = Minimap:GetWidth()
				scan:SetSize(w, 2); scan:ClearAllPoints(); scan:SetPoint("CENTER", e.frame, "TOP", 0, 0)
				roll:SetOffset(0, -w)
				for i = 1, #blocks do Reset(blocks[i]) end
			end
		end

		----------------------------------------------------------------------
		-- Lava
		----------------------------------------------------------------------

		Effects[18] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local base = MakeGlow(e.back, 1.2, 1, 0.3, 0.1, 0.35, 0.08)
			local colours = {{1, 0.35, 0.05}, {1, 0.15, 0.1}, {1, 0.55, 0.1}, {0.9, 0.1, 0.35}}
			local blobs = {}
			for i = 1, 10 do
				local c = colours[(i - 1) % #colours + 1]
				local t = Tex(e.back, DOT, "BACKGROUND", 1, c[1], c[2], c[3], 0.45)
				-- Drift slowly back and forth and swell, each at its own pace
				local drift = Anim(Group(e, t, "BOUNCE"), "Translation", 3 + random() * 3); drift:SetSmoothing("IN_OUT")
				local swell = Anim(Group(e, t, "BOUNCE"), "Scale", 2 + random() * 3); swell:SetScaleFrom(0.85, 0.85); swell:SetScaleTo(1.15, 1.15); swell:SetSmoothing("IN_OUT")
				blobs[i] = {tex = t, drift = drift, t = (i - 1) / 10 + random() * 0.05, size = 0.3 + random() * 0.18}
			end
			e.Layout = function()
				if base.Layout then base.Layout() end
				local w = Minimap:GetWidth()
				for i = 1, #blobs do
					local bl = blobs[i]
					local size = w * bl.size
					-- Mostly hidden behind the minimap so only a rounded bulge shows past the edge
					local x, y = EdgeT(bl.t, -size * 0.3)
					bl.tex:SetSize(size, size)
					bl.tex:ClearAllPoints(); bl.tex:SetPoint("CENTER", e.frame, "CENTER", x, y)
					-- Drift along the edge and a little in and out
					local a = EdgeNormal(bl.t)
					local along, out = random(-14, 14), random(-6, 10)
					bl.drift:SetOffset(-sin(a) * along + cos(a) * out, cos(a) * along + sin(a) * out)
				end
			end
		end

		----------------------------------------------------------------------
		-- Fuse
		----------------------------------------------------------------------

		Effects[19] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local period, points = 14, 72
			-- Spark head (a frame that travels round the edge, so its sparks travel with it)
			local ff = CreateFrame("Frame", nil, e.frame); ff:SetSize(1, 1)
			local glow = Tex(ff, DOT, "ARTWORK", 1, 1, 0.55, 0.15, 0.7); glow:SetSize(22, 22); glow:SetPoint("CENTER")
			local head = Tex(ff, STAR, "ARTWORK", 3, 1, 0.95, 0.7); head:SetSize(18, 18); head:SetPoint("CENTER")
			Anim(Group(e, head), "Rotation", 0.6):SetDegrees(-360)
			local ag = Group(e, ff)
			local path = Anim(ag, "Path", period)
			path:SetCurveType(square and "NONE" or "SMOOTH")
			local cps = {}
			for i = 1, square and points + 4 or points do cps[i] = path:CreateControlPoint(); cps[i]:SetOrder(i) end
			-- Spray of sparks
			local sparks = {}
			-- Function to send a spark off in a new direction
			local function Reset(sp)
				local a, dist = random() * math.pi * 2, random(8, 24)
				sp.move:SetOffset(cos(a) * dist, sin(a) * dist)
				local d = 0.3 + random() * 0.35
				sp.move:SetDuration(d); sp.fade:SetDuration(d)
			end
			for i = 1, 16 do
				local t = Tex(ff, DOT, "ARTWORK", 2, 1, 0.6 + random() * 0.3, 0.2); t:SetSize(3, 3); t:SetPoint("CENTER")
				local sg = Group(e, t)
				local sp = {}
				sp.move = Anim(sg, "Translation", 0.4)
				sp.fade = Anim(sg, "Alpha", 0.4); sp.fade:SetFromAlpha(1); sp.fade:SetToAlpha(0)
				sg:SetScript("OnLoop", function() Reset(sp) end)
				Reset(sp)
				sparks[i] = sp
			end
			e.Layout = function()
				-- Points around the edge (square includes the exact corners)
				local n, ts = #cps, {}
				if square then
					for i = 1, n - 4 do ts[i] = i / (n - 4) end
					for c = 0, 3 do tinsert(ts, 0.125 + c * 0.25) end
					table.sort(ts)
				else
					for i = 1, n do ts[i] = i / n end
				end
				-- Travel clockwise (negative direction) from the top
				local sx, sy = EdgeT(0.25, 2)
				ff:ClearAllPoints(); ff:SetPoint("CENTER", e.frame, "CENTER", sx, sy)
				for i = 1, n do
					local x, y = EdgeT(0.25 - ts[i], 2)
					cps[i]:SetOffset(x - sx, y - sy)
				end
			end
		end

		----------------------------------------------------------------------
		-- Rain
		----------------------------------------------------------------------

		Effects[20] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local chars = "0123456789ABCDEF"
			local columns = {}
			-- Clip the rain to the minimap
			local clip = CreateFrame("Frame", nil, e.frame); clip:SetAllPoints(); clip:SetClipsChildren(true)
			-- Function to give a column new characters, speed and wait
			local function Reset(col)
				local half = Minimap:GetWidth() / 2
				local len = random(5, 10)
				local text = {}
				for i = 1, len do
					local c = random(1, #chars)
					local ch = chars:sub(c, c)
					-- Bottom character is the brightest
					text[i] = i == len and ("|cffccffcc" .. ch .. "|r") or ch
				end
				col.fs:SetText(table.concat(text, "\n"))
				col.fs:ClearAllPoints(); col.fs:SetPoint("BOTTOM", clip, "TOP", col.x, 0)
				local d = 2.5 + random() * 3
				col.fall:SetOffset(0, -(half * 2 + col.fs:GetStringHeight() + 10)); col.fall:SetDuration(d)
				col.fall:SetStartDelay(random() * 2)
			end
			for i = 1, 14 do
				local fs = clip:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
				fs:SetTextColor(0.3, 1, 0.45)
				fs:SetAlpha(0.55)
				fs:SetSpacing(1)
				local col = {fs = fs}
				local ag = Group(e, fs)
				col.fall = Anim(ag, "Translation", 4)
				ag:SetScript("OnLoop", function() Reset(col) end)
				columns[i] = col
			end
			e.Layout = function()
				local w = Minimap:GetWidth()
				for i = 1, #columns do
					columns[i].x = -w / 2 + (i - 0.5) * w / #columns
					Reset(columns[i])
				end
			end
		end

		----------------------------------------------------------------------
		-- Prism
		----------------------------------------------------------------------

		Effects[21] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local beams, count, turnTime = {}, 6, 24
			for k = 0, count - 1 do
				local t = Tex(e.back, WHITE, "BACKGROUND", 0)
				local r, g, b = Hue(k / count)
				-- Bright near the minimap edge, fading towards the tip
				t:SetGradient("HORIZONTAL", CreateColor(r, g, b, 0.7), CreateColor(r, g, b, 0))
				-- Turn to its starting angle straight away, then turn a full circle
				local ag = Group(e, t)
				local start = Anim(ag, "Rotation", 0.001, 1); start:SetDegrees(-360 * k / count); start:SetOrigin("LEFT", 0, 0)
				local spin = Anim(ag, "Rotation", turnTime, 2); spin:SetDegrees(-360); spin:SetOrigin("LEFT", 0, 0)
				beams[k + 1] = t
			end
			e.Layout = function()
				local w = Minimap:GetWidth()
				for i = 1, #beams do
					beams[i]:SetSize(w * 0.9, 12)
					beams[i]:ClearAllPoints(); beams[i]:SetPoint("LEFT", e.frame, "CENTER", 0, 0)
				end
			end
		end

		----------------------------------------------------------------------
		-- Candy
		----------------------------------------------------------------------

		Effects[22] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local palette = {{1, 0.6, 0.8}, {0.8, 0.65, 1}, {0.6, 1, 0.85}, {1, 0.95, 0.55}, {0.6, 0.85, 1}}
			local function Colour() local c = palette[random(1, #palette)]; return c[1], c[2], c[3] end

			-- Candy floss glow that drifts between pink and lilac
			local glow = MakeGlow(e.back, 3, 1, 0.6, 0.85, 1, 0.14)
			local a = square and 0.7 or 0.15
			for i = 1, #glow do
				local vc = Anim(Group(e, glow[i], "BOUNCE"), "VertexColor", 3)
				vc:SetStartColor(CreateColor(1, 0.6, 0.85, a)); vc:SetEndColor(CreateColor(0.8, 0.65, 1, a)); vc:SetSmoothing("IN_OUT")
			end

			-- Sprinkles that hop out from the edge and land again, spinning as they go
			local sprinkles = {}
			for i = 1, 36 do
				local t = Tex(e.frame, WHITE, "ARTWORK", 1, Colour())
				t:SetSize(7, 2.5)
				t:SetRotation(random() * math.pi)
				local ag = Group(e, t)
				local up = Anim(ag, "Translation", 0.35, 1, random() * 1.2); up:SetSmoothing("OUT")
				local spin1 = Anim(ag, "Rotation", 0.35, 1, up:GetStartDelay()); spin1:SetDegrees(random(0, 1) == 1 and 90 or -90)
				local down = Anim(ag, "Translation", 0.35, 2); down:SetSmoothing("IN")
				local spin2 = Anim(ag, "Rotation", 0.35, 2); spin2:SetDegrees(spin1:GetDegrees())
				down:SetEndDelay(0.2 + random() * 1.3)
				sprinkles[i] = {tex = t, up = up, down = down, t = (i - 1 + random() * 0.6) / 36}
			end

			-- Stars that pop out like confetti
			local stars = {}
			local function Pop(st)
				local x, y = EdgeT(random(), random(4, 14))
				st.tex:ClearAllPoints(); st.tex:SetPoint("CENTER", e.frame, "CENTER", x, y)
				st.tex:SetVertexColor(Colour())
				local wait = random() * 2
				st.grow:SetStartDelay(wait); st.turn:SetStartDelay(wait); st.show:SetStartDelay(wait)
			end
			for i = 1, 8 do
				local t = Tex(e.frame, STAR, "ARTWORK", 2); t:SetSize(14, 14); t:SetAlpha(0)
				local ag = Group(e, t)
				local st = {tex = t}
				st.grow = Anim(ag, "Scale", 0.25, 1); st.grow:SetScaleFrom(0.1, 0.1); st.grow:SetScaleTo(1.2, 1.2); st.grow:SetSmoothing("OUT")
				st.turn = Anim(ag, "Rotation", 0.25, 1); st.turn:SetDegrees(90)
				st.show = Anim(ag, "Alpha", 0.25, 1); st.show:SetFromAlpha(0); st.show:SetToAlpha(1)
				local shrink = Anim(ag, "Scale", 0.4, 2); shrink:SetScaleFrom(1.2, 1.2); shrink:SetScaleTo(0.1, 0.1)
				local fade = Anim(ag, "Alpha", 0.4, 2); fade:SetFromAlpha(1); fade:SetToAlpha(0)
				ag:SetScript("OnLoop", function() Pop(st) end)
				stars[i] = st
			end

			e.Layout = function()
				if glow.Layout then glow.Layout() end
				for i = 1, #sprinkles do
					local sp = sprinkles[i]
					local x, y = EdgeT(sp.t, 3)
					sp.tex:ClearAllPoints(); sp.tex:SetPoint("CENTER", e.frame, "CENTER", x, y)
					-- Hop straight out from the edge and back
					local ang, height = EdgeNormal(sp.t), random(6, 12)
					sp.up:SetOffset(cos(ang) * height, sin(ang) * height)
					sp.down:SetOffset(-cos(ang) * height, -sin(ang) * height)
				end
				for i = 1, #stars do Pop(stars[i]) end
			end
		end

		----------------------------------------------------------------------
		-- Rainbow
		----------------------------------------------------------------------

		Effects[23] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local count, band, cycle = 7, 3, 8 -- Number of rings, ring width in pixels, seconds for a ring to go through every colour
			local inset = square and 1 or 4 -- Gap so the inner ring is not lost under the minimap border
			local spread = 0.75 -- Hue range across the rings (red on the outside through to violet on the inside)
			local steps = 12 -- Colour stops per cycle (more stops keep the in-between colours bright)
			local rings = {}
			-- Solid rings stacked behind the minimap (smallest on top so each ring only shows its own band)
			for k = 1, count do
				local t = Tex(e.back, square and WHITE or DOT, "BACKGROUND", 3 - k)
				t:SetBlendMode("BLEND")
				t:SetPoint("CENTER")
				-- Each ring starts at its own place on the colour wheel (red outside to violet inside)
				local offset = (count - k) / (count - 1) * spread
				t:SetVertexColor(Hue(offset))
				-- Loop through the colour wheel (the colours flow outwards)
				local ag = Group(e, t)
				for j = 0, steps - 1 do
					local r1, g1, b1 = Hue(offset + j / steps)
					local r2, g2, b2 = Hue(offset + (j + 1) / steps)
					local vc = Anim(ag, "VertexColor", cycle / steps, j + 1)
					vc:SetStartColor(CreateColor(r1, g1, b1, 1)); vc:SetEndColor(CreateColor(r2, g2, b2, 1))
				end
				rings[k] = t
			end
			e.Layout = function()
				local w = Minimap:GetWidth()
				for k = 1, count do
					local s = w + 2 * (inset + band * k)
					rings[k]:SetSize(s, s)
				end
			end
		end

		----------------------------------------------------------------------
		-- Fireflies
		----------------------------------------------------------------------

		Effects[24] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local flies = {}
			for i = 1, 20 do
				-- Each firefly is a frame so its halo and core move together
				local ff = CreateFrame("Frame", nil, e.frame); ff:SetSize(1, 1)
				local halo = Tex(ff, DOT, "ARTWORK", 1, 0.7, 1, 0.25, 0.45); halo:SetSize(12, 12); halo:SetPoint("CENTER")
				local core = Tex(ff, DOT, "ARTWORK", 2, 0.95, 1, 0.7, 1); core:SetSize(3, 3); core:SetPoint("CENTER")
				-- Wander along a closed smooth loop
				local path = Anim(Group(e, ff), "Path", 6 + random() * 5); path:SetCurveType("SMOOTH")
				local cps = {}
				for j = 1, 5 do cps[j] = path:CreateControlPoint(); cps[j]:SetOrder(j) end
				-- Blink at its own pace
				local blink = Anim(Group(e, ff, "BOUNCE"), "Alpha", 0.6 + random() * 1.2, 1, random() * 1.5); blink:SetFromAlpha(1); blink:SetToAlpha(0.1); blink:SetSmoothing("IN_OUT")
				flies[i] = {frame = ff, cps = cps, t = random(), d = random(-4, 16)}
			end
			e.Layout = function()
				for i = 1, #flies do
					local fl = flies[i]
					local x, y = EdgeT(fl.t, fl.d)
					fl.frame:ClearAllPoints(); fl.frame:SetPoint("CENTER", e.frame, "CENTER", x, y)
					for j = 1, 4 do fl.cps[j]:SetOffset(random(-14, 14), random(-14, 14)) end
					fl.cps[5]:SetOffset(0, 0)
				end
			end
		end

		----------------------------------------------------------------------
		-- Synthwave
		----------------------------------------------------------------------

		Effects[25] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local glow = MakeGlow(e.back, 1.3, 0.6, 0.2, 1, 0.55, 0.14)
			local segs, step, pieces = 64, 0.03, {}
			for k = 0, segs - 1 do
				-- Neon tube that blends between hot pink and cyan around the edge
				local f = 0.5 + 0.5 * sin(k / segs * TAU * 2)
				local r, g, b = 1 - 0.8 * f, 0.2 + 0.7 * f, 0.8 + 0.2 * f
				local sf = CreateFrame("Frame", nil, e.frame); sf:SetAllPoints(); sf:SetAlpha(0.4)
				local glowLine = sf:CreateLine(nil, "ARTWORK", nil, 1)
				glowLine:SetColorTexture(r, g, b, 0.3); glowLine:SetBlendMode("ADD"); glowLine:SetThickness(8)
				local core = sf:CreateLine(nil, "ARTWORK", nil, 2)
				core:SetColorTexture(r * 0.4 + 0.6, g * 0.4 + 0.6, b * 0.4 + 0.6, 1); core:SetBlendMode("ADD"); core:SetThickness(2)
				-- Light pulse chases round the tube
				local ag = Group(e, sf)
				local up = Anim(ag, "Alpha", 0.2, 1, k * step); up:SetFromAlpha(0.4); up:SetToAlpha(1)
				local down = Anim(ag, "Alpha", 0.9, 2); down:SetFromAlpha(1); down:SetToAlpha(0.4); down:SetEndDelay((segs - k) * step)
				pieces[k + 1] = {lines = {glowLine, core}, t = k / segs}
			end
			-- Bright head that rides the pulse
			local head = Tex(e.frame, STAR, "ARTWORK", 3, 1, 0.85, 1); head:SetSize(20, 20)
			Anim(Group(e, head), "Rotation", 0.8):SetDegrees(360)
			local path = Anim(Group(e, head), "Path", segs * step + 1.1)
			path:SetCurveType(square and "NONE" or "SMOOTH")
			local cps = {}
			for i = 1, segs do cps[i] = path:CreateControlPoint(); cps[i]:SetOrder(i) end
			e.Layout = function()
				if glow.Layout then glow.Layout() end
				for i = 1, #pieces do
					local p = pieces[i]
					local x1, y1 = EdgeT(p.t, 3)
					local x2, y2 = EdgeT(p.t + 1 / segs, 3)
					for _, line in ipairs(p.lines) do
						line:SetStartPoint("CENTER", e.frame, x1, y1)
						line:SetEndPoint("CENTER", e.frame, x2, y2)
					end
				end
				-- Head goes once round with the pulse (pulse takes segs * step to go round, then the loop rests)
				path:SetDuration(segs * step)
				path:SetEndDelay(1.1)
				local sx, sy = EdgeT(0, 3)
				head:ClearAllPoints(); head:SetPoint("CENTER", e.frame, "CENTER", sx, sy)
				for i = 1, segs do
					local x, y = EdgeT(i / segs, 3)
					cps[i]:SetOffset(x - sx, y - sy)
				end
			end
		end

		----------------------------------------------------------------------
		-- Collider
		----------------------------------------------------------------------

		Effects[26] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local period, points, movers = 8, 72, {}
			-- Function to make a region follow the edge in a direction (1 is anticlockwise, -1 is clockwise)
			local function Mover(region, phase, dir)
				local ag = Group(e, region)
				local path = Anim(ag, "Path", period)
				path:SetCurveType(square and "NONE" or "SMOOTH")
				local cps = {}
				for i = 1, square and points + 4 or points do cps[i] = path:CreateControlPoint(); cps[i]:SetOrder(i) end
				tinsert(movers, {region = region, cps = cps, phase = phase, dir = dir})
				return ag
			end
			-- Two comets start together at the top and race round in opposite directions
			for side, c in ipairs({{1, 0.25, 0.8}, {0.2, 0.9, 1}}) do
				local dir = side == 1 and 1 or -1
				for k = 12, 1, -1 do
					local fade = 1 - k / 13
					local d = Tex(e.frame, DOT, "ARTWORK", 1, c[1], c[2], c[3], 0.7 * fade)
					d:SetSize(2 + 6 * fade, 2 + 6 * fade)
					Mover(d, 0.25 - dir * k * 0.006, dir)
				end
				local core = Tex(e.frame, DOT, "ARTWORK", 2, c[1] * 0.4 + 0.6, c[2] * 0.4 + 0.6, c[3] * 0.4 + 0.6, 0.95); core:SetSize(8, 8)
				Mover(core, 0.25, dir)
				local head = Tex(e.frame, STAR, "ARTWORK", 3, c[1], c[2], c[3]); head:SetSize(20, 20)
				local spin = Anim(Mover(head, 0.25, dir), "Rotation", period); spin:SetDegrees(360 * 6 * dir)
			end
			-- Flash where the comets meet (top at the start of each lap, bottom half way round)
			local flashes = {}
			for i, v in ipairs({{0.25, 0}, {0.75, period / 2}}) do
				local ff = CreateFrame("Frame", nil, e.frame); ff:SetSize(1, 1); ff:SetAlpha(0)
				local burst = Tex(ff, DOT, "ARTWORK", 4, 0.8, 0.6, 1, 0.8); burst:SetSize(34, 34); burst:SetPoint("CENTER")
				local star = Tex(ff, STAR, "ARTWORK", 5, 1, 1, 1); star:SetSize(30, 30); star:SetPoint("CENTER")
				local ag = Group(e, ff)
				local on = Anim(ag, "Alpha", 0.08, 1, v[2]); on:SetFromAlpha(0); on:SetToAlpha(1)
				local off = Anim(ag, "Alpha", 0.5, 2); off:SetFromAlpha(1); off:SetToAlpha(0); off:SetEndDelay(period - v[2] - 0.58)
				flashes[i] = {frame = ff, t = v[1]}
			end
			e.Layout = function()
				for _, m in ipairs(movers) do
					-- Points around the edge starting from the mover (square includes the exact corners)
					local n, ts = #m.cps, {}
					if square then
						for i = 1, n - 4 do ts[i] = i / (n - 4) end
						for c = 0, 3 do tinsert(ts, (((0.125 + c * 0.25) - m.phase) * m.dir) % 1) end
						table.sort(ts)
					else
						for i = 1, n do ts[i] = i / n end
					end
					local sx, sy = EdgeT(m.phase, 4)
					m.region:ClearAllPoints(); m.region:SetPoint("CENTER", e.frame, "CENTER", sx, sy)
					for i = 1, n do
						local x, y = EdgeT(m.phase + m.dir * ts[i], 4)
						m.cps[i]:SetOffset(x - sx, y - sy)
					end
				end
				for i = 1, #flashes do
					local x, y = EdgeT(flashes[i].t, 4)
					flashes[i].frame:ClearAllPoints(); flashes[i].frame:SetPoint("CENTER", e.frame, "CENTER", x, y)
				end
			end
		end

		----------------------------------------------------------------------
		-- Bubbles
		----------------------------------------------------------------------

		Effects[27] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local sqrt = math.sqrt
			local bubbles = {}
			-- Function to send a bubble up from the bottom of the minimap (stays inside a round minimap too)
			local function Reset(b, first)
				local half = Minimap:GetWidth() / 2 - 6
				local x = random(-half, half)
				local chord = square and half or sqrt(max(half * half - x * x, 0))
				b.frame:ClearAllPoints(); b.frame:SetPoint("CENTER", e.frame, "CENTER", x, -chord)
				for j = 1, 4 do
					local wobble = j < 4 and (j % 2 == 1 and 1 or -1) * random(2, 5) or 0
					b.cps[j]:SetOffset(wobble, chord * 2 * j / 4)
				end
				local s = random(5, 12)
				b.body:SetSize(s, s); b.shine:SetSize(s * 0.35, s * 0.35)
				b.shine:ClearAllPoints(); b.shine:SetPoint("CENTER", b.body, "CENTER", -s * 0.2, s * 0.2)
				local d = (2 + random() * 2) * max(chord, 10) / max(half, 10)
				local wait = first and random() * 4 or random() * 1.5
				b.path:SetDuration(d); b.path:SetStartDelay(wait)
				b.fadeIn:SetStartDelay(wait)
				b.fadeOut:SetStartDelay(wait + d - 0.3)
			end
			for i = 1, 18 do
				local bf = CreateFrame("Frame", nil, e.frame); bf:SetSize(1, 1); bf:SetAlpha(0)
				local b = {frame = bf, cps = {}}
				b.body = Tex(bf, DOT, "ARTWORK", 1, 0.5, 0.85, 1, 0.3); b.body:SetPoint("CENTER")
				b.shine = Tex(bf, DOT, "ARTWORK", 2, 1, 1, 1, 0.8)
				local ag = Group(e, bf)
				b.path = Anim(ag, "Path", 3); b.path:SetCurveType("SMOOTH")
				for j = 1, 4 do b.cps[j] = b.path:CreateControlPoint(); b.cps[j]:SetOrder(j) end
				b.fadeIn = Anim(ag, "Alpha", 0.4); b.fadeIn:SetFromAlpha(0); b.fadeIn:SetToAlpha(1)
				b.fadeOut = Anim(ag, "Alpha", 0.3); b.fadeOut:SetFromAlpha(1); b.fadeOut:SetToAlpha(0)
				ag:SetScript("OnLoop", function() Reset(b) end)
				bubbles[i] = b
			end
			e.Layout = function()
				for i = 1, #bubbles do Reset(bubbles[i], true) end
			end
		end

		----------------------------------------------------------------------
		-- Acid
		----------------------------------------------------------------------

		Effects[28] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local glow = MakeGlow(e.back, 1.2, 0.35, 1, 0.2, 0.45, 0.1)
			local drops = {}
			-- Function to choose a new spot on the lower edge for a drop to form and fall from
			local function Reset(dp)
				local x, y = EdgeT(0.56 + random() * 0.38, 1)
				dp.tex:ClearAllPoints(); dp.tex:SetPoint("TOP", e.frame, "CENTER", x, y)
				dp.fall:SetOffset(0, -random(22, 40))
				local wait = random() * 2.5
				dp.grow:SetStartDelay(wait); dp.show:SetStartDelay(wait)
			end
			for i = 1, 16 do
				local t = Tex(e.frame, DOT, "ARTWORK", 1, 0.45, 1, 0.25); t:SetSize(4, 6); t:SetAlpha(0)
				local ag = Group(e, t)
				local dp = {tex = t}
				-- Swell on the edge
				dp.grow = Anim(ag, "Scale", 1.4, 1); dp.grow:SetScaleFrom(0.2, 0.2); dp.grow:SetScaleTo(1, 1); dp.grow:SetOrigin("TOP", 0, 0); dp.grow:SetSmoothing("OUT")
				dp.show = Anim(ag, "Alpha", 1.4, 1); dp.show:SetFromAlpha(0); dp.show:SetToAlpha(1)
				-- Drop, stretch and fade
				dp.fall = Anim(ag, "Translation", 0.55, 2); dp.fall:SetSmoothing("IN")
				local stretch = Anim(ag, "Scale", 0.55, 2); stretch:SetScaleFrom(1, 1); stretch:SetScaleTo(0.7, 1.6); stretch:SetOrigin("TOP", 0, 0)
				local fade = Anim(ag, "Alpha", 0.55, 2); fade:SetFromAlpha(1); fade:SetToAlpha(0)
				ag:SetScript("OnLoop", function() Reset(dp) end)
				drops[i] = dp
			end
			e.Layout = function()
				if glow.Layout then glow.Layout() end
				for i = 1, #drops do Reset(drops[i]) end
			end
		end

		----------------------------------------------------------------------
		-- Shadow
		----------------------------------------------------------------------

		Effects[29] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local glow = MakeGlow(e.back, 1.3, 0.55, 0.15, 0.85, 0.5, 0.12)
			local puffs = {}
			-- Function to send a puff of smoke out from a random point on the edge (first puff starts at a random time)
			local function Reset(p, first)
				local t = random()
				local a = EdgeNormal(t)
				local x, y = EdgeT(t, 2)
				p.tex:ClearAllPoints(); p.tex:SetPoint("CENTER", e.frame, "CENTER", x, y)
				local dist = random(10, 22)
				p.move:SetOffset(cos(a) * dist, sin(a) * dist + random(2, 8))
				local d = 1.8 + random() * 1.4
				local wait = first and random() * d or 0
				p.move:SetDuration(d); p.grow:SetDuration(d); p.spin:SetDuration(d)
				p.fadeOut:SetDuration(d * 0.6)
				p.move:SetStartDelay(wait); p.grow:SetStartDelay(wait); p.spin:SetStartDelay(wait); p.fadeIn:SetStartDelay(wait)
				p.fadeOut:SetStartDelay(wait + d * 0.4)
			end
			for i = 1, 26 do
				-- Dark smoke (normal blending so it darkens rather than glows)
				local t = e.back:CreateTexture(nil, "ARTWORK", nil, 1)
				t:SetTexture(DOT); t:SetBlendMode("BLEND")
				t:SetVertexColor(0.12 + random() * 0.1, 0.02, 0.2 + random() * 0.1, 0.75)
				local size = random(14, 24); t:SetSize(size, size); t:SetAlpha(0)
				local ag = Group(e, t)
				local p = {tex = t}
				p.move = Anim(ag, "Translation", 2); p.move:SetSmoothing("OUT")
				p.grow = Anim(ag, "Scale", 2); p.grow:SetScaleFrom(0.5, 0.5); p.grow:SetScaleTo(1.6, 1.6)
				p.spin = Anim(ag, "Rotation", 2); p.spin:SetDegrees(random(-90, 90))
				p.fadeIn = Anim(ag, "Alpha", 0.4); p.fadeIn:SetFromAlpha(0); p.fadeIn:SetToAlpha(1)
				p.fadeOut = Anim(ag, "Alpha", 1); p.fadeOut:SetFromAlpha(1); p.fadeOut:SetToAlpha(0)
				ag:SetScript("OnLoop", function() Reset(p) end)
				puffs[i] = p
			end
			e.Layout = function()
				if glow.Layout then glow.Layout() end
				for i = 1, #puffs do Reset(puffs[i], true) end
			end
		end

		----------------------------------------------------------------------
		-- Radar
		----------------------------------------------------------------------

		Effects[30] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local trail, period, beams = 18, 4, {}
			-- Sweep line with a fading trail behind it (each trail beam starts a little further back)
			for k = 0, trail do
				local main = k == 0
				local t = Tex(e.frame, WHITE, "ARTWORK", main and 2 or 1, 0.25, 1, 0.45, main and 0.7 or 0.28 * (1 - k / (trail + 1)) ^ 1.5)
				local ag = Group(e, t)
				local start = Anim(ag, "Rotation", 0.001, 1); start:SetDegrees(k * 2.5); start:SetOrigin("LEFT", 0, 0)
				local spin = Anim(ag, "Rotation", period, 2); spin:SetDegrees(-360); spin:SetOrigin("LEFT", 0, 0)
				beams[k + 1] = {tex = t, main = main}
			end
			-- Blips that appear and fade
			local blips = {}
			local function Blip(b)
				local half = Minimap:GetWidth() / 2 - 8
				local a, r = random() * TAU, random() * half
				b.tex:ClearAllPoints(); b.tex:SetPoint("CENTER", e.frame, "CENTER", cos(a) * r, sin(a) * r)
				b.on:SetStartDelay(random() * 3)
			end
			for i = 1, 6 do
				local t = Tex(e.frame, DOT, "ARTWORK", 3, 0.4, 1, 0.55); t:SetSize(6, 6); t:SetAlpha(0)
				local ag = Group(e, t)
				local b = {tex = t}
				b.on = Anim(ag, "Alpha", 0.1, 1); b.on:SetFromAlpha(0); b.on:SetToAlpha(1)
				local off = Anim(ag, "Alpha", 1.8, 2); off:SetFromAlpha(1); off:SetToAlpha(0)
				ag:SetScript("OnLoop", function() Blip(b) end)
				blips[i] = b
			end
			e.Layout = function()
				local r = Minimap:GetWidth() / 2
				for i = 1, #beams do
					local b = beams[i]
					b.tex:SetSize(r, b.main and 2 or 3)
					b.tex:ClearAllPoints(); b.tex:SetPoint("LEFT", e.frame, "CENTER", 0, 0)
				end
				for i = 1, #blips do Blip(blips[i]) end
			end
		end

		----------------------------------------------------------------------
		-- Tesla
		----------------------------------------------------------------------

		Effects[31] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local glow = MakeGlow(e.back, 1.2, 0.3, 0.7, 1, 0.45, 0.1)
			local arcs, segs = {}, 7
			-- Function to give an arc a new place, shape and wait (arcs crackle along the edge between two points)
			local function Reset(arc)
				local t0, span = random(), 0.04 + random() * 0.06
				local px, py = EdgeT(t0, 2)
				arc.sparkA:ClearAllPoints(); arc.sparkA:SetPoint("CENTER", e.frame, "CENTER", px, py)
				for j = 1, segs do
					local bow = j == segs and 2 or 2 + random() * 9
					local x, y = EdgeT(t0 + span * j / segs, bow)
					for _, line in ipairs(arc.lines[j]) do
						line:SetStartPoint("CENTER", e.frame, px, py)
						line:SetEndPoint("CENTER", e.frame, x, y)
					end
					px, py = x, y
				end
				arc.sparkB:ClearAllPoints(); arc.sparkB:SetPoint("CENTER", e.frame, "CENTER", px, py)
				arc.wait:SetStartDelay(random() * 1.5)
			end
			for i = 1, 5 do
				local af = CreateFrame("Frame", nil, e.frame); af:SetAllPoints(); af:SetAlpha(0)
				local arc = {lines = {}}
				for j = 1, segs do
					local glowLine = af:CreateLine(nil, "ARTWORK", nil, 1)
					glowLine:SetColorTexture(0.35, 0.7, 1, 0.35); glowLine:SetBlendMode("ADD"); glowLine:SetThickness(6)
					local core = af:CreateLine(nil, "ARTWORK", nil, 2)
					core:SetColorTexture(0.85, 0.95, 1, 1); core:SetBlendMode("ADD"); core:SetThickness(1.5)
					arc.lines[j] = {glowLine, core}
				end
				arc.sparkA = Tex(af, STAR, "ARTWORK", 3, 0.7, 0.9, 1); arc.sparkA:SetSize(12, 12)
				arc.sparkB = Tex(af, STAR, "ARTWORK", 3, 0.7, 0.9, 1); arc.sparkB:SetSize(12, 12)
				-- Crackle on, flicker and off
				local ag = Group(e, af)
				arc.wait = Anim(ag, "Alpha", 0.03, 1); arc.wait:SetFromAlpha(0); arc.wait:SetToAlpha(1)
				local f1 = Anim(ag, "Alpha", 0.05, 2); f1:SetFromAlpha(1); f1:SetToAlpha(0.3)
				local f2 = Anim(ag, "Alpha", 0.04, 3); f2:SetFromAlpha(0.3); f2:SetToAlpha(1)
				local f3 = Anim(ag, "Alpha", 0.12, 4); f3:SetFromAlpha(1); f3:SetToAlpha(0)
				ag:SetScript("OnLoop", function() Reset(arc) end)
				arcs[i] = arc
			end
			e.Layout = function()
				if glow.Layout then glow.Layout() end
				for i = 1, #arcs do Reset(arcs[i]) end
			end
		end

		----------------------------------------------------------------------
		-- Meteor
		----------------------------------------------------------------------

		Effects[32] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue
			local ang = atan2(-0.75, -1) -- Down and to the left
			local dx, dy = cos(ang), sin(ang)
			local meteors = {}
			-- Function to choose a new line across the minimap and a new wait
			local function Reset(m)
				local half = Minimap:GetWidth() / 2
				local across = random(-half, half)
				local sx, sy = -dx * (half + 30) - dy * across, -dy * (half + 30) + dx * across
				m.frame:ClearAllPoints(); m.frame:SetPoint("CENTER", e.frame, "CENTER", sx, sy)
				local dist = half * 2 + 60
				m.move:SetOffset(dx * dist, dy * dist)
				local d = 1 + random() * 0.4
				local wait = 0.3 + random() * 3.2
				m.move:SetDuration(d); m.move:SetStartDelay(wait)
				m.fadeIn:SetStartDelay(wait)
				m.fadeOut:SetStartDelay(wait + d - 0.3)
			end
			for i = 1, 5 do
				local mf = CreateFrame("Frame", nil, e.frame); mf:SetSize(1, 1); mf:SetAlpha(0)
				local m = {frame = mf}
				local glow = Tex(mf, DOT, "ARTWORK", 1, 1, 0.55, 0.2, 0.6); glow:SetSize(12, 12); glow:SetPoint("CENTER")
				local head = Tex(mf, STAR, "ARTWORK", 3, 1, 0.9, 0.65); head:SetSize(14, 14); head:SetPoint("CENTER")
				local tail = Tex(mf, WHITE, "ARTWORK", 2, 1, 1, 1); tail:SetSize(60, 2.5)
				tail:SetGradient("HORIZONTAL", CreateColor(1, 0.5, 0.2, 0), CreateColor(1, 0.9, 0.7, 0.9))
				tail:SetPoint("CENTER", head, "CENTER", -dx * 30, -dy * 30)
				tail:SetRotation(ang)
				local ag = Group(e, mf)
				m.move = Anim(ag, "Translation", 1)
				m.fadeIn = Anim(ag, "Alpha", 0.15); m.fadeIn:SetFromAlpha(0); m.fadeIn:SetToAlpha(1)
				m.fadeOut = Anim(ag, "Alpha", 0.3); m.fadeOut:SetFromAlpha(1); m.fadeOut:SetToAlpha(0)
				ag:SetScript("OnLoop", function() Reset(m) end)
				meteors[i] = m
			end
			e.Layout = function()
				for i = 1, #meteors do Reset(meteors[i]) end
			end
		end

		----------------------------------------------------------------------
		-- Tube
		----------------------------------------------------------------------

		Effects[33] = function(e, h)
			local square, Tex, Anim, Group, MakeGlow, EdgeAt, EdgeT, EdgeNormal, Hue = h.square, h.Tex, h.Anim, h.Group, h.MakeGlow, h.EdgeAt, h.EdgeT, h.EdgeNormal, h.Hue

			-- Everything is kept inside the minimap (clipped for square, masked for round)
			local clip = CreateFrame("Frame", nil, e.frame); clip:SetAllPoints(); clip:SetClipsChildren(true)
			local mask
			if not square then
				mask = clip:CreateMaskTexture()
				mask:SetTexture(DOT, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
				mask:SetAllPoints(clip)
			end

			-- Function to create a dark texture (normal blending so it darkens rather than glows)
			local function Dark(sub, a)
				local t = clip:CreateTexture(nil, "ARTWORK", nil, sub)
				t:SetTexture(WHITE); t:SetBlendMode("BLEND")
				t:SetVertexColor(0, 0, 0, a or 1)
				if mask then t:AddMaskTexture(mask) end
				return t
			end

			-- Scanlines (created as needed in the layout so they always fill the minimap)
			local scanlines, gap = {}, 3

			-- Hum bar rolling down the minimap (same as the Glitch effect)
			local scan = Tex(clip, WHITE, "ARTWORK", 3, 0.6, 1, 1, 0.08)
			if mask then scan:AddMaskTexture(mask) end
			local roll = Anim(Group(e, scan), "Translation", 4)

			-- Soft dark band that slowly drifts up the minimap
			local bandTop, bandBottom = Dark(2), Dark(2)
			bandTop:SetGradient("VERTICAL", CreateColor(0, 0, 0, 0.1), CreateColor(0, 0, 0, 0))
			bandBottom:SetGradient("VERTICAL", CreateColor(0, 0, 0, 0), CreateColor(0, 0, 0, 0.1))
			local bandTopRoll, bandBottomRoll = Anim(Group(e, bandTop), "Translation", 11), Anim(Group(e, bandBottom), "Translation", 11)

			-- Edge darkening (makes the glass look curved)
			local edge, edgeAlpha = {}, 0.3
			if square then
				for k = 1, 4 do edge[k] = Dark(4) end
				edge[1]:SetGradient("VERTICAL", CreateColor(0, 0, 0, 0), CreateColor(0, 0, 0, edgeAlpha))	-- Top
				edge[2]:SetGradient("VERTICAL", CreateColor(0, 0, 0, edgeAlpha), CreateColor(0, 0, 0, 0))	-- Bottom
				edge[3]:SetGradient("HORIZONTAL", CreateColor(0, 0, 0, edgeAlpha), CreateColor(0, 0, 0, 0))	-- Left
				edge[4]:SetGradient("HORIZONTAL", CreateColor(0, 0, 0, 0), CreateColor(0, 0, 0, edgeAlpha))	-- Right
			else
				-- Rings of lines just inside the edge, darkest at the outside
				local rings, segs = 6, 48
				for k = 1, rings do
					local a = edgeAlpha * (1 - (k - 1) / rings) ^ 2
					for j = 1, segs do
						local line = clip:CreateLine(nil, "ARTWORK", nil, 4)
						line:SetColorTexture(0, 0, 0, a)
						tinsert(edge, {line = line, k = k, t = (j - 1) / segs, step = 1 / segs})
					end
				end
				edge.rings = rings
			end

			e.Layout = function()
				local w = Minimap:GetWidth()

				-- Scanlines
				local count = floor(w / gap)
				for i = 1, max(count, #scanlines) do
					local s = scanlines[i]
					if i <= count then
						if not s then s = Dark(1, 0.15); scanlines[i] = s end
						s:SetSize(w, 1)
						s:ClearAllPoints(); s:SetPoint("TOP", clip, "TOP", 0, -(i - 1) * gap - 1)
						s:Show()
					elseif s then
						s:Hide()
					end
				end

				-- Hum bar
				scan:SetSize(w, 2); scan:ClearAllPoints(); scan:SetPoint("CENTER", clip, "TOP", 0, 0)
				roll:SetOffset(0, -w)

				-- Dark band starts below the minimap and drifts up past the top
				local band = w * 0.3
				bandTop:SetSize(w, band / 2); bandBottom:SetSize(w, band / 2)
				bandTop:ClearAllPoints(); bandTop:SetPoint("BOTTOM", clip, "BOTTOM", 0, -band / 2)
				bandBottom:ClearAllPoints(); bandBottom:SetPoint("TOP", clip, "BOTTOM", 0, -band / 2)
				bandTopRoll:SetOffset(0, w + band); bandBottomRoll:SetOffset(0, w + band)

				-- Edge darkening
				local depth = w * 0.12
				if square then
					edge[1]:ClearAllPoints(); edge[1]:SetPoint("TOPLEFT", clip); edge[1]:SetPoint("TOPRIGHT", clip); edge[1]:SetHeight(depth)
					edge[2]:ClearAllPoints(); edge[2]:SetPoint("BOTTOMLEFT", clip); edge[2]:SetPoint("BOTTOMRIGHT", clip); edge[2]:SetHeight(depth)
					edge[3]:ClearAllPoints(); edge[3]:SetPoint("TOPLEFT", clip); edge[3]:SetPoint("BOTTOMLEFT", clip); edge[3]:SetWidth(depth)
					edge[4]:ClearAllPoints(); edge[4]:SetPoint("TOPRIGHT", clip); edge[4]:SetPoint("BOTTOMRIGHT", clip); edge[4]:SetWidth(depth)
				else
					local thick = depth / edge.rings
					for i = 1, #edge do
						local v = edge[i]
						local inset = -(v.k - 0.5) * thick
						local x1, y1 = EdgeT(v.t, inset)
						local x2, y2 = EdgeT(v.t + v.step, inset)
						v.line:SetThickness(thick)
						v.line:SetStartPoint("CENTER", clip, x1, y1)
						v.line:SetEndPoint("CENTER", clip, x2, y2)
					end
				end
			end
		end

		return Effects

	end
