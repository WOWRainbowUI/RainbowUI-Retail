local ProfileSnapshots = {}
ProfileSnapshots.__index = ProfileSnapshots

local CopyTable = MikSBT.CopyTable
local EraseTable = MikSBT.EraseTable

local EMPTY = {}

-- The marks of the Blizzard text switches live in each profile but stay out of the snapshots:
-- they are not listed, counted, reverted or restored here, as they follow the client.
local MARKS = "blizzardSwitches"
-- The note that a profile's ranged events were made is written when the profile is selected. It is
-- no setting, so it is not listed or counted; a restore still takes it back with the rest.
local MIGRATED = "rangedEventsMigrated"

function ProfileSnapshots:New(options)
	local snapshots = setmetatable({}, self)

	snapshots.savedVariables = options.savedVariables
	snapshots.savedVariablesPerChar = options.savedVariablesPerChar
	snapshots.selectProfile = options.selectProfile
	snapshots.masterProfile = options.masterProfile
	snapshots.state = {}

	return snapshots
end

-- The tracked state, refilled on each call; profiles is the live table, so it is never stored as is.
function ProfileSnapshots:GetState()
	local state = self.state
	state.profiles = self.savedVariables.profiles
	state.currentProfileName = self.savedVariablesPerChar.currentProfileName
	state.userDisabled = self.savedVariables.userDisabled
	return state
end

function ProfileSnapshots:Take()
	local snapshot = CopyTable(self:GetState())
	for _, profile in pairs(snapshot.profiles) do
		if type(profile) == "table" then profile[MARKS] = nil end
	end
	return snapshot
end

function ProfileSnapshots:Apply(state)
	self.savedVariables.userDisabled = state.userDisabled
	self.selectProfile(state.currentProfileName)
end

function ProfileSnapshots:Restore(snapshot)
	local profiles = self.savedVariables.profiles
	for name in pairs(profiles) do
		if not snapshot.profiles[name] then profiles[name] = nil end
	end
	-- Existing profile tables are refilled because the running addon holds them.
	for name, saved in pairs(snapshot.profiles) do
		local profile = profiles[name]
		local marks = profile and rawget(profile, MARKS)
		if profile then
			EraseTable(profile)
			-- As after loading: a profile that was selected earlier would otherwise still look for its
			-- defaults where they are gone once another profile is selected.
			setmetatable(profile, nil)
		else
			profile = {}
			profiles[name] = profile
		end
		for key, value in pairs(saved) do
			if key ~= MARKS then profile[key] = type(value) == "table" and CopyTable(value) or value end
		end
		profile[MARKS] = marks
	end
	self:Apply(snapshot)
end

local CompareTables
-- State of the running comparison: differences found, where to stop, the master profile.
local found, limit, master

-- Profiles sit at depth 2; inside one, a missing raw value is the master value at that path.
local function CompareValues(entries, path, depth, key, old, new, default)
	if depth == 3 and (key == MARKS or key == MIGRATED) then return end
	path[depth] = key
	local oldIsTable, newIsTable = type(old) == "table", type(new) == "table"
	-- A profile on one side only is one entry, so a revert copies or removes it whole.
	if (oldIsTable or newIsTable) and (oldIsTable or old == nil)
		and (newIsTable or new == nil) and (depth ~= 2 or (oldIsTable and newIsTable)) then
		local defaults = depth == 2 and master or default
		CompareTables(entries, path, depth + 1, old or EMPTY, new or EMPTY,
			type(defaults) == "table" and defaults or nil)
	else
		if old == nil then old = default end
		if new == nil then new = default end
		if old ~= new then
			found = found + 1
			if entries then
				local entryPath, names = {}, {}
				for index = 1, depth do
					entryPath[index] = path[index]
					names[index] = tostring(path[index])
				end
				entries[#entries + 1] = {
					path = entryPath, key = table.concat(names, "."), old = old, new = new,
				}
			end
		end
	end
	path[depth] = nil
end

-- Raw access only: the selected profile inherits its defaults through metatables.
CompareTables = function(entries, path, depth, old, new, defaults)
	for key, value in pairs(old) do
		if limit and found >= limit then return end
		CompareValues(entries, path, depth, key, value, rawget(new, key),
			defaults and rawget(defaults, key))
	end
	for key, value in pairs(new) do
		if limit and found >= limit then return end
		if rawget(old, key) == nil then
			CompareValues(entries, path, depth, key, nil, value, defaults and rawget(defaults, key))
		end
	end
end

local function SortByKey(left, right)
	return left.key < right.key
end

function ProfileSnapshots:Diff(snapshot)
	local entries = {}
	found, limit, master = 0, nil, self.masterProfile
	CompareTables(entries, {}, 1, snapshot, self:GetState())
	table.sort(entries, SortByKey)
	return entries
end

local countPath = {}

-- Counts the differences Diff would list, up to maximum when given, without creating any table.
function ProfileSnapshots:Count(snapshot, maximum)
	found, limit, master = 0, maximum, self.masterProfile
	CompareTables(nil, countPath, 1, snapshot, self:GetState())
	return found
end

function ProfileSnapshots:Revert(snapshot, path)
	local state = self:GetState()
	local tables, bases = { [0] = state }, { [0] = snapshot }
	local last = #path
	for depth = 1, last - 1 do
		local key, parent, base = path[depth], tables[depth - 1], bases[depth - 1]
		if type(rawget(parent, key)) ~= "table" then rawset(parent, key, {}) end
		tables[depth] = rawget(parent, key)
		bases[depth] = type(base) == "table" and rawget(base, key) or nil
	end

	local base, value = bases[last - 1], nil
	if type(base) == "table" then value = rawget(base, path[last]) end
	-- Restoring the login selection also restores its profile if it was deleted.
	if last == 1 and path[1] == "currentProfileName" and value
		and not state.profiles[value] then
		local profile = snapshot.profiles[value]
		if type(profile) ~= "table" then return end
		state.profiles[value] = CopyTable(profile)
	end
	if type(value) == "table" then value = CopyTable(value) end
	rawset(tables[last - 1], path[last], value)

	-- Tables emptied by the revert go when the snapshot has none; profiles itself stays.
	for depth = last - 1, 2, -1 do
		if next(tables[depth]) == nil and type(bases[depth]) ~= "table" then
			rawset(tables[depth - 1], path[depth], nil)
		end
	end
	self:Apply(state)
end

function ProfileSnapshots:GetLoginSnapshot()
	return self.savedVariables.loginSnapshot
end

-- A UI reload keeps the snapshot, so changes since login survive /reload.
function ProfileSnapshots:UpdateLoginSnapshot(isInitialLogin)
	if isInitialLogin or not self.savedVariables.loginSnapshot then
		self.savedVariables.loginSnapshot = self:Take()
	end
end

MikSBT.Configuration.ProfileSnapshots = ProfileSnapshots

return ProfileSnapshots
