local addonName, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local L = LibStub("AceLocale-3.0"):GetLocale(C.Addon.AceName)
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceSerializer = LibStub("AceSerializer-3.0")

local EXPORT_PREFIX = C.ImportExport.Prefix
local COMPRESSION_MODE = C.ImportExport.CompressionMode

local MAX_IMPORT_STRING_LENGTH = 262144
local MAX_DECODED_LENGTH = 196608
local MAX_DECOMPRESSED_LENGTH = 524288
local MAX_PROFILE_DEPTH = 8
local MAX_PROFILE_ENTRIES = 2048
local MAX_PROFILE_STRING_LENGTH = 4096

local function IsFiniteNumber(value)
    return value == value and value ~= math.huge and value ~= -math.huge
end

local function ValidateProfileBounds(value, depth, state, ancestors)
    if depth > MAX_PROFILE_DEPTH or ancestors[value] then
        return false
    end

    ancestors[value] = true

    for key, child in pairs(value) do
        state.entries = state.entries + 1
        if state.entries > MAX_PROFILE_ENTRIES then
            ancestors[value] = nil
            return false
        end

        local keyType = type(key)
        if (keyType ~= "string" and keyType ~= "number")
           or (keyType == "string" and #key > MAX_PROFILE_STRING_LENGTH)
           or (keyType == "number" and not IsFiniteNumber(key)) then
            ancestors[value] = nil
            return false
        end

        local childType = type(child)
        if childType == "table" then
            if not ValidateProfileBounds(child, depth + 1, state, ancestors) then
                ancestors[value] = nil
                return false
            end
        elseif childType == "string" then
            if #child > MAX_PROFILE_STRING_LENGTH then
                ancestors[value] = nil
                return false
            end
        elseif childType == "number" then
            if not IsFiniteNumber(child) then
                ancestors[value] = nil
                return false
            end
        elseif childType ~= "boolean" then
            ancestors[value] = nil
            return false
        end
    end

    ancestors[value] = nil
    return true
end

local function BuildValidatedConfig(defaultValue, importedValue)
    local expectedType = type(defaultValue)
    if type(importedValue) ~= expectedType then
        return false
    end

    if expectedType ~= "table" then
        if expectedType == "number" and not IsFiniteNumber(importedValue) then
            return false
        end
        return true, importedValue
    end

    local result = CopyTable(defaultValue)
    for key, defaultChild in pairs(defaultValue) do
        local importedChild = importedValue[key]
        if importedChild ~= nil then
            local ok, validatedChild = BuildValidatedConfig(defaultChild, importedChild)
            if not ok then
                return false
            end
            result[key] = validatedChild
        end
    end

    return true, result
end

local function EncodeBase64(value)
    local ok, encoded = pcall(C_EncodingUtil.EncodeBase64, value)
    if ok and type(encoded) == "string" then
        return encoded
    end

    return nil
end

local function DecodeBase64(value)
    local ok, decoded = pcall(C_EncodingUtil.DecodeBase64, value)
    if ok and type(decoded) == "string" then
        return decoded
    end

    return nil
end

local function CompressPayload(value)
    local ok, compressed = pcall(C_Compression.CompressString, value)
    if ok and type(compressed) == "string" and compressed ~= "" then
        return COMPRESSION_MODE.Compressed, compressed
    end

    return COMPRESSION_MODE.None, value
end

local function DecompressPayload(mode, value)
    if mode == COMPRESSION_MODE.Compressed then
        local ok, decompressed = pcall(C_Compression.DecompressString, value)
        if ok and type(decompressed) == "string" and decompressed ~= "" then
            return decompressed
        end

        return nil
    end

    if mode == COMPRESSION_MODE.None then
        return value
    end

    return nil
end

local function ReplaceTableContents(destination, source)
    wipe(destination)
    for key, value in pairs(source) do
        destination[key] = value
    end
end

local function EnsureBuffers()
    MCE.profileImportBuffer = MCE.profileImportBuffer or ""
    MCE.profileExportBuffer = MCE.profileExportBuffer or ""
end

function MCE:ClearProfileImportExportBuffers()
    self.profileImportBuffer = ""
    self.profileExportBuffer = ""
end

function MCE:ExportConfig()
    EnsureBuffers()

    local profile = self.db and self.db.profile
    if type(profile) ~= "table" then
        return nil, L["No active profile available."]
    end

    local exportTable = CopyTable(profile)
    local serialized = AceSerializer:Serialize(exportTable)
    local compressionMode, compressed = CompressPayload(serialized)
    local encoded = EncodeBase64(compressed)

    if type(encoded) ~= "string" or encoded == "" then
        return nil, L["Failed to encode export string."]
    end

    local exportString = EXPORT_PREFIX .. ":" .. compressionMode .. ":" .. encoded
    self.profileExportBuffer = exportString
    return exportString
end

function MCE:ImportConfig(importString)
    EnsureBuffers()

    if type(importString) ~= "string" or strtrim(importString) == "" then
        return false, L["Paste an import string first."]
    end

    if #importString > MAX_IMPORT_STRING_LENGTH then
        return false, L["Import string is too large."]
    end

    local trimmedImportString = strtrim(importString)
    local prefix, compressionMode, payload = trimmedImportString:match(C.ImportExport.ImportPattern)
    if prefix ~= EXPORT_PREFIX or not compressionMode or not payload then
        return false, L["Invalid import string format."]
    end

    local decoded = DecodeBase64(payload)
    if type(decoded) ~= "string" then
        return false, L["Failed to decode import string."]
    end
    if #decoded > MAX_DECODED_LENGTH then
        return false, L["Import string is too large."]
    end

    local decompressed = DecompressPayload(compressionMode, decoded)
    if type(decompressed) ~= "string" then
        return false, L["Failed to decompress import string."]
    end
    if #decompressed > MAX_DECOMPRESSED_LENGTH then
        return false, L["Import string is too large."]
    end

    local deserializeCallOk, deserializeOk, importedProfile =
        pcall(AceSerializer.Deserialize, AceSerializer, decompressed)
    if not deserializeCallOk or not deserializeOk or type(importedProfile) ~= "table" then
        return false, L["Failed to deserialize import string."]
    end

    if not ValidateProfileBounds(importedProfile, 1, { entries = 0 }, {}) then
        return false, L["Import profile contains invalid data."]
    end

    local schemaOk, stagedProfile = BuildValidatedConfig(self.defaults.profile, importedProfile)
    if not schemaOk then
        return false, L["Import profile contains invalid data."]
    end

    local activeProfile = self.db and self.db.profile
    if type(activeProfile) ~= "table" then
        return false, L["No active profile available."]
    end

    local backupOk, profileBackup = pcall(CopyTable, activeProfile)
    if not backupOk or type(profileBackup) ~= "table" then
        return false, L["Failed to apply imported profile."]
    end

    local previousSuppressProfileCallbacks = self.suppressProfileCallbacks
    self.suppressProfileCallbacks = true

    local applied = pcall(function()
        ReplaceTableContents(activeProfile, stagedProfile)
        self:UpgradeProfile()
    end)

    if not applied then
        pcall(function()
            ReplaceTableContents(activeProfile, profileBackup)
        end)
        self.suppressProfileCallbacks = previousSuppressProfileCallbacks
        return false, L["Failed to apply imported profile."]
    end

    self.suppressProfileCallbacks = previousSuppressProfileCallbacks

    self.profileImportBuffer = trimmedImportString
    self.profileExportBuffer = ""

    self:ForceUpdateAll(true)
    AceConfigRegistry:NotifyChange(addonName)
    self:Print(L["Profile import completed."])

    return true
end
