local _, T = ...
local function assert(cnd, text, el)
	return cnd or error(text, el or 3)((0)[0])
end

local XU, factory = {}, {}
function XU:Create(otype, ...)
	return assert(factory[otype], 'unknown object type')(...)
end
function XU:RegisterFactory(otype, createfunc)
	assert(type(otype) == "string", 'invalid object type')
	assert(type(createfunc) == "function", 'invalid factory function')
	assert(factory[otype] == nil, 'object type already registered')
	factory[otype] = createfunc
end

local getWidgetData, newWidgetData, setWidgetData do
	local S, skipProtoKeys = {}, {api=1, super=1, meta=1, init=1, ObjectType=1}
	function getWidgetData(self, dataType)
		local r = S[dataType]
		return r and r[self[0]]
	end
	function newWidgetData(self, dataType, proto)
		local d, pin = setWidgetData(self, dataType, {}), proto.init
		if proto.super == nil then
			local api = proto.api
			proto.super = getmetatable(self).__index
			for k,v in next, proto.super do
				if api[k] == nil then
					api[k] = v
				end
			end
			proto.meta = {__index=api}
		end
		for k,v in next, proto do
			if not skipProtoKeys[k] then
				d[k] = v
			end
		end
		d.self, d.proto = self, proto
		setmetatable(self, proto.meta)
		for i=1, pin and #pin or 0 do
			pin[i](self, proto)
		end
		return d
	end
	function setWidgetData(self, dataType, dat)
		local SD = S[dataType] or {}
		if SD[self[0]] == nil then
			S[dataType], SD[self[0]] = SD, dat
		end
		return dat
	end
end
local AddObjectMethods, CallObjectScript do
	local Object, loScriptName, loObjectType, temp = {}, {}, {exuiobject="exUIObject"}, {}
	local ObjectData, objectProto = {}, {}
	local function NIL_HANDLER() end
	local function findScriptName(d, q)
		local p = d.proto
		if p[q] == NIL_HANDLER then
			return q
		end
		local lq = loScriptName[q:lower()]
		if p[lq] == NIL_HANDLER then
			return lq
		end
	end
	local function initObject(self, proto)
		local d, op = {}, objectProto[proto]
		for k, v in next, op do
			if v == NIL_HANDLER then
				d[k] = v
			end
		end
		d.proto, op.super = op, op.super or proto.super
		setWidgetData(self, ObjectData, d)
	end
	function CallObjectScript(self, handlerName, ...)
		local d = assert(getWidgetData(self, ObjectData), "Invalid object type")
		local dh = d[findScriptName(d, handlerName)]
		if dh and dh ~= NIL_HANDLER then
			return securecall(dh, self, ...)
		end
	end

	function Object:GetObjectType()
		local d = assert(getWidgetData(self, ObjectData), "Invalid object type")
		return d.proto.ObjectType
	end
	function Object:IsObjectType(objectType)
		local d = assert(getWidgetData(self, ObjectData), "Invalid object type")
		assert(type(objectType) == "string", 'Syntax: is = Object:IsObjectType("objectType")')
		local r = d.proto.isa[objectType]
		if r == nil then
			r = d.proto.isa[loObjectType[objectType:lower()]]
		end
		if r == nil then
			return d.proto.super.IsObjectType(self, objectType)
		end
		return r ~= false
	end
	function Object:SetScript(handlerName, callback)
		local d = assert(getWidgetData(self, ObjectData), "Invalid object type")
		assert(type(handlerName) == 'string', 'Syntax: Object:SetScript("handlerName", callback)')
		local hn = findScriptName(d, handlerName)
		if not hn then
			return d.proto.super.SetScript(self, handlerName, callback)
		end
		d[hn] = callback == nil and NIL_HANDLER or callback
	end
	function Object:HookScript(handlerName, callback)
		local d = assert(getWidgetData(self, ObjectData), "Invalid object type")
		assert(type(handlerName) == 'string', 'Syntax: Object:HookScript("handlerName", callback)')
		local hn = findScriptName(d, handlerName)
		if not hn then
			return d.proto.super.HookScript(self, handlerName, callback)
		end
		local oc = Object.GetScript(self, hn)
		if oc then
			temp.f = oc
			hooksecurefunc(temp, "f", callback)
			callback, temp.f = temp.f
		end
		return Object.SetScript(self, hn, callback)
	end
	function Object:GetScript(handlerName)
		local d = assert(getWidgetData(self, ObjectData), "Invalid object type")
		assert(type(handlerName) == 'string', 'Syntax: callback = Object:GetScript("handlerName")')
		local hn = findScriptName(d, handlerName)
		if not hn then
			return d.proto.super.GetScript(self, handlerName)
		end
		local dh = d[hn]
		return dh ~= NIL_HANDLER and dh or nil
	end
	function Object:HasScript(handlerName)
		local d = assert(getWidgetData(self, ObjectData), "Invalid object type")
		assert(type(handlerName) == 'string', 'Syntax: hasScript = Object:HasScript("handlerName")')
		return findScriptName(d, handlerName) and true or d.proto.super.HasScript(self, handlerName)
	end

	local function buildCaselessMap(sourceArray, caseMap, sideMap, sideValue, errorText)
		for i=1, sourceArray and #sourceArray or 0 do
			local ik = sourceArray[i]
			local lo = ik:lower()
			assert((caseMap[lo] or ik) == ik, errorText, 4)
			sideMap[ik], caseMap[lo] = sideValue, ik
		end
	end
	function AddObjectMethods(isarr, proto)
		local api, scripts, pin = proto.api, proto.scripts, proto.init or {}
		local op, isa = {}, {exUIObject=true}
		proto.init, proto.scripts = pin, nil
		for k,v in next, Object do
			if api[k] == nil then
				api[k] = v
			end
		end
		for i=1,#pin+1 do
			if (pin[i] or initObject) == initObject then
				pin[i] = initObject
				break
			end
		end
		buildCaselessMap(isarr, loObjectType, isa, true, 'divergent object type case')
		buildCaselessMap(scripts, loScriptName, op, NIL_HANDLER, 'divergent script name case')
		objectProto[proto], op.isa, op.ObjectType, op.scripts = op, isa, isarr[1], scripts
		return proto
	end
end
do -- ObjectGroup
	local mcache = {}
	local function genMethod(t, k)
		if k ~= nil and type(t[1][k]) == "function" then
			local r = mcache[k]
			if r == nil then
				r = function(self, ...)
					for i=#self,2,-1 do
						securecall(self[i][k], self[i], ...)
					end
					return securecall(self[1][k], self[1], ...)
				end
				mcache[k] = r
			end
			return r
		end
	end
	local groupMeta = {__index=genMethod, __metatable=false}
	XU:RegisterFactory("ObjectGroup", function(...)
		return setmetatable({...}, groupMeta)
	end)
end

local hum = {}
function hum:GetImpl()
	return assert, getWidgetData, newWidgetData, setWidgetData, AddObjectMethods, CallObjectScript
end

T.exUI, hum.HUM = setmetatable(XU, {__index=hum}), hum