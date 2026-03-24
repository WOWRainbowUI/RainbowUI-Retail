local addonName, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local L = LibStub("AceLocale-3.0"):GetLocale(C.Addon.AceName)
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceSerializer = LibStub("AceSerializer-3.0")

local EXPORT_PREFIX = C.ImportExport.Prefix
local BASE64_ALPHABET = C.ImportExport.Base64Alphabet
local BASE64_LOOKUP = C.ImportExport.Base64Lookup
local COMPRESSION_MODE = C.ImportExport.CompressionMode

local function Base64EncodeChunk(a, b, c)
    local n = a * 65536 + (b or 0) * 256 + (c or 0)
    local c1 = math.floor(n / 262144) % 64 + 1
    local c2 = math.floor(n / 4096) % 64 + 1
    local c3 = math.floor(n / 64) % 64 + 1
    local c4 = n % 64 + 1

    if b == nil then
        return BASE64_ALPHABET:sub(c1, c1) .. BASE64_ALPHABET:sub(c2, c2) .. "=="
    end

    if c == nil then
        return BASE64_ALPHABET:sub(c1, c1) .. BASE64_ALPHABET:sub(c2, c2) .. BASE64_ALPHABET:sub(c3, c3) .. "="
    end

    return BASE64_ALPHABET:sub(c1, c1)
        .. BASE64_ALPHABET:sub(c2, c2)
        .. BASE64_ALPHABET:sub(c3, c3)
        .. BASE64_ALPHABET:sub(c4, c4)
end

local function FallbackBase64Encode(value)
    if type(value) ~= "string" or value == "" then
        return ""
    end

    local parts = {}
    for i = 1, #value, 3 do
        parts[#parts + 1] = Base64EncodeChunk(value:byte(i, i + 2))
    end

    return table.concat(parts)
end

local function FallbackBase64Decode(value)
    if type(value) ~= "string" then
        return nil
    end

    value = value:gsub("%s+", "")
    if value == "" then
        return ""
    end

    if (#value % 4) ~= 0 then
        return nil
    end

    local parts = {}
    for i = 1, #value, 4 do
        local chunk = value:sub(i, i + 3)
        local padding = 0

        if chunk:sub(3, 3) == "=" then
            padding = 2
        elseif chunk:sub(4, 4) == "=" then
            padding = 1
        end

        local c1 = BASE64_LOOKUP[chunk:sub(1, 1)]
        local c2 = BASE64_LOOKUP[chunk:sub(2, 2)]
        local c3 = padding >= 2 and 0 or BASE64_LOOKUP[chunk:sub(3, 3)]
        local c4 = padding >= 1 and 0 or BASE64_LOOKUP[chunk:sub(4, 4)]

        if c1 == nil or c2 == nil or (padding < 2 and c3 == nil) or (padding < 1 and c4 == nil) then
            return nil
        end

        local n = c1 * 262144 + c2 * 4096 + c3 * 64 + c4
        local b1 = math.floor(n / 65536) % 256
        local b2 = math.floor(n / 256) % 256
        local b3 = n % 256

        if padding == 2 then
            parts[#parts + 1] = string.char(b1)
        elseif padding == 1 then
            parts[#parts + 1] = string.char(b1, b2)
        else
            parts[#parts + 1] = string.char(b1, b2, b3)
        end
    end

    return table.concat(parts)
end

local function EncodeBase64(value)
    if C_EncodingUtil and C_EncodingUtil.EncodeBase64 then
        local ok, encoded = pcall(C_EncodingUtil.EncodeBase64, value)
        if ok and type(encoded) == "string" then
            return encoded
        end
    end

    if C_Base64 and C_Base64.Encode then
        local ok, encoded = pcall(C_Base64.Encode, value)
        if ok and type(encoded) == "string" then
            return encoded
        end
    end

    return FallbackBase64Encode(value)
end

local function DecodeBase64(value)
    if C_EncodingUtil and C_EncodingUtil.DecodeBase64 then
        local ok, decoded = pcall(C_EncodingUtil.DecodeBase64, value)
        if ok and type(decoded) == "string" then
            return decoded
        end
    end

    if C_Base64 and C_Base64.Decode then
        local ok, decoded = pcall(C_Base64.Decode, value)
        if ok and type(decoded) == "string" then
            return decoded
        end
    end

    return FallbackBase64Decode(value)
end

local function CompressPayload(value)
    if C_Compression and C_Compression.CompressString then
        local ok, compressed = pcall(C_Compression.CompressString, value)
        if ok and type(compressed) == "string" and compressed ~= "" then
            return COMPRESSION_MODE.Compressed, compressed
        end
    end

    return COMPRESSION_MODE.None, value
end

local function DecompressPayload(mode, value)
    if mode == COMPRESSION_MODE.Compressed then
        if not (C_Compression and C_Compression.DecompressString) then
            return nil
        end

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

local function MergeTableDeep(destination, source)
    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(destination[key]) ~= "table" then
                destination[key] = {}
            end
            MergeTableDeep(destination[key], value)
        else
            destination[key] = value
        end
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

    local prefix, compressionMode, payload = strtrim(importString):match(C.ImportExport.ImportPattern)
    if prefix ~= EXPORT_PREFIX or not compressionMode or not payload then
        return false, L["Invalid import string format."]
    end

    local decoded = DecodeBase64(payload)
    if type(decoded) ~= "string" then
        return false, L["Failed to decode import string."]
    end

    local decompressed = DecompressPayload(compressionMode, decoded)
    if type(decompressed) ~= "string" then
        return false, L["Failed to decompress import string."]
    end

    local ok, importedProfile = AceSerializer:Deserialize(decompressed)
    if not ok or type(importedProfile) ~= "table" then
        return false, L["Failed to deserialize import string."]
    end

    self.suppressProfileCallbacks = true
    self.db:ResetProfile()
    wipe(self.db.profile)
    MergeTableDeep(self.db.profile, CopyTable(self.defaults.profile))
    MergeTableDeep(self.db.profile, importedProfile)
    self.suppressProfileCallbacks = nil

    self:UpgradeProfile()
    self.profileImportBuffer = importString
    self.profileExportBuffer = ""

    self:ForceUpdateAll(true)
    AceConfigRegistry:NotifyChange(addonName)
    self:Print(L["Profile import completed."])

    return true
end
