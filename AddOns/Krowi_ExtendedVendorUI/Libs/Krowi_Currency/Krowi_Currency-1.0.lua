--[[
    Copyright (c) 2026 Krowi

    All Rights Reserved unless otherwise explicitly stated.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

---@diagnostic disable: undefined-global
---@diagnostic disable: cast-local-type

local MAJOR, MINOR = "Krowi_Currency-1.0", 3
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then	return end

local localeCache
local function GetLocale()
	if not localeCache then
		localeCache = LibStub("AceLocale-3.0"):GetLocale("Krowi_Currency-1.0", true)
	end
	return localeCache
end

local iconCache = {}
local function GetIconLabels(textureSize)
	if not iconCache[textureSize] then
		local icon_pre = "|TInterface\\MoneyFrame\\"
		local icon_post = ":" .. textureSize + 2 .. ":" .. textureSize + 2 .. ":2:0|t"
		iconCache[textureSize] = {
			gold = icon_pre .. "UI-GoldIcon" .. icon_post,
			silver = icon_pre .. "UI-SilverIcon" .. icon_post,
			copper = icon_pre .. "UI-CopperIcon" .. icon_post
		}
	end
	return iconCache[textureSize]
end

local function AbbreviateValue(value, abbreviateK, abbreviateM)
	local L = GetLocale()
	if abbreviateK and value >= 1000 then
		return math.floor(value / 1000), L["Thousands Suffix"]
	elseif abbreviateM and value >= 1000000 then
		return math.floor(value / 1000000), L["Millions Suffix"]
	end
	return value, ""
end

local function GetSeparators(thousandsSeparator)
	if thousandsSeparator == "Space" then
		return " ", "."
	elseif thousandsSeparator == "Period" then
		return ".", ","
	elseif thousandsSeparator == "Comma" then
		return ",", "."
	end
	return "", ""
end

local function BreakMoney(value)
	return math.floor(value / 10000), math.floor((value % 10000) / 100), value % 100
end

local function NumToString(amount, thousands_separator, decimal_separator)
	if type(amount) ~= "number" then
		return "0"
	end

	if amount > 99999999999999 then
		return tostring(amount)
	end

	local sign, int, frac = tostring(amount):match('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1|")
	int = int:reverse():gsub("^|", "")
	int = int:gsub("%.", decimal_separator)
	int = int:gsub("|", thousands_separator)

	return sign .. int .. frac
end

local function GetMoneyLabels(options)
	if options.MoneyLabel == "Text" then
		return options.GoldLabel or "g", options.SilverLabel or "s", options.CopperLabel or "c"
	elseif options.MoneyLabel == "Icon" then
		local textureSize = options.TextureSize or 14
		local icons = GetIconLabels(textureSize)
		return icons.gold, icons.silver, icons.copper
	end
	return "", "", ""
end

local function GetMoneyColors(options)
	local goldColor = options.MoneyColored and "ffd100" or "ffffff"
	local silverColor = options.MoneyColored and "e6e6e6" or "ffffff"
	local copperColor = options.MoneyColored and "c8602c" or "ffffff"
	return goldColor, silverColor, copperColor
end

function lib:FormatMoney(value, options)
	local thousandsSeparator, decimalSeparator = GetSeparators(options.ThousandsSeparator)
	local gold, silver, copper, abbr = BreakMoney(value)
	gold, abbr = AbbreviateValue(gold, options.MoneyAbbreviate == "1k", options.MoneyAbbreviate == "1m")
	gold = NumToString(gold, thousandsSeparator, decimalSeparator)
	local goldLabel, silverLabel, copperLabel = GetMoneyLabels(options)
	local goldColor, silverColor, copperColor = GetMoneyColors(options)

	local outstr = "|cff" .. goldColor .. gold .. abbr .. goldLabel .. "|r"
	if not options.MoneyGoldOnly then
		outstr = outstr .. " " .. "|cff" .. silverColor .. silver .. silverLabel .. "|r"
		outstr = outstr .. " " .. "|cff" .. copperColor .. copper .. copperLabel .. "|r"
	end
	return outstr
end

function lib:FormatCurrency(value, options)
	local thousandsSeparator, decimalSeparator = GetSeparators(options.ThousandsSeparator)
	local quantity, abbr = AbbreviateValue(value, options.CurrencyAbbreviate == "1k", options.CurrencyAbbreviate == "1m")
	quantity = NumToString(quantity, thousandsSeparator, decimalSeparator)
	return quantity .. abbr
end

function lib:CreateCurrencyOptionsMenu(parentMenu, menuBuilder, options, addTitle)
	local L = GetLocale()
	if addTitle ~= false then
		menuBuilder:CreateTitle(parentMenu, L["Currency Options"])
	end

	local currencyAbbreviate = menuBuilder:CreateSubmenuButton(parentMenu, L["Currency Abbreviate"])
	menuBuilder:CreateRadio(currencyAbbreviate, L["None"], options, {"CurrencyAbbreviate"}, "None")
	menuBuilder:CreateRadio(currencyAbbreviate, L["1k"], options, {"CurrencyAbbreviate"}, "1k")
	menuBuilder:CreateRadio(currencyAbbreviate, L["1m"], options, {"CurrencyAbbreviate"}, "1m")
	menuBuilder:AddChildMenu(parentMenu, currencyAbbreviate)
end

function lib:CreateMoneyOptionsMenu(parentMenu, menuBuilder, options, addTitle)
	local L = GetLocale()
	if addTitle ~= false then
		menuBuilder:CreateTitle(parentMenu, L["Money Options"])
	end

	local moneyLabel = menuBuilder:CreateSubmenuButton(parentMenu, L["Money Label"])
	menuBuilder:CreateRadio(moneyLabel, L["None"], options, {"MoneyLabel"}, "None")
	menuBuilder:CreateRadio(moneyLabel, L["Text"], options, {"MoneyLabel"}, "Text")
	menuBuilder:CreateRadio(moneyLabel, L["Icon"], options, {"MoneyLabel"}, "Icon")
	menuBuilder:AddChildMenu(parentMenu, moneyLabel)

	local moneyAbbreviate = menuBuilder:CreateSubmenuButton(parentMenu, L["Money Abbreviate"])
	menuBuilder:CreateRadio(moneyAbbreviate, L["None"], options, {"MoneyAbbreviate"}, "None")
	menuBuilder:CreateRadio(moneyAbbreviate, L["1k"], options, {"MoneyAbbreviate"}, "1k")
	menuBuilder:CreateRadio(moneyAbbreviate, L["1m"], options, {"MoneyAbbreviate"}, "1m")
	menuBuilder:AddChildMenu(parentMenu, moneyAbbreviate)

	local thousandsSeparator = menuBuilder:CreateSubmenuButton(parentMenu, L["Thousands Separator"])
	menuBuilder:CreateRadio(thousandsSeparator, L["Space"], options, {"ThousandsSeparator"}, "Space")
	menuBuilder:CreateRadio(thousandsSeparator, L["Period"], options, {"ThousandsSeparator"}, "Period")
	menuBuilder:CreateRadio(thousandsSeparator, L["Comma"], options, {"ThousandsSeparator"}, "Comma")
	menuBuilder:AddChildMenu(parentMenu, thousandsSeparator)

	menuBuilder:CreateCheckbox(parentMenu, L["Money Gold Only"], options, {"MoneyGoldOnly"})
	menuBuilder:CreateCheckbox(parentMenu, L["Money Colored"], options, {"MoneyColored"})
end