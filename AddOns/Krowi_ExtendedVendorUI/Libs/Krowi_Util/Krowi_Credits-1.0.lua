--[[
    Copyright (c) 2023 Krowi

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

local lib = LibStub("Krowi_Util-1.0");

if not lib then
	return;
end

lib.Credits = {};
local credits = lib.Credits;

local specialThanks = {
    {Name = "Bur", Realm = "Frostmane EU", Class = "DRUID", Text = "Continuous support and helpful input and answers on questions that make this addon better; It wouldn't be as good without you :)"},
    {Name = "Malivil", Realm = "Defias Brotherhood EU", Class = "ROGUE", Text = "Active community member who has been very helpful with answers to questions of other users"},
    {Name = "Silden", Class = "", Text = "Contributed a lot of tooltip data, especially related to pet battles"},
}

function credits.GetSpecialThanksAsTable()
    local texts, text = {}, "";
    for _, specialTnx in next, specialThanks do
        local argbHex = specialTnx.Class ~= "" and select(4, GetClassColor(specialTnx.Class)) or "FFC0C0C0";
        text = "|c" .. argbHex .. specialTnx.Name .. "|r";
        if specialTnx.Realm then
            text = text .. " - " .. specialTnx.Realm;
        end
        if specialTnx.Text then
            text = text .. " - " .. specialTnx.Text;
        end
        tinsert(texts, text);
    end
    return texts;
end

local donations = {
    {Name = "Bur", Realm = "Frostmane EU", Class = "DRUID"},
    {Name = "Ta", Realm = "Der Rat von Dalaran EU", Class = "SHAMAN"},
    {Name = "Estellar", Realm = "Bronze Dragonflight EU", Class = "PALADIN"},
    {Name = "Seby", Realm = "TwistingNether EU", Class = "HUNTER"},
    {Name = "Swiftstrider (mains everything)", Realm = "Frostmourne NA", Class = ""},
    {Name = "Orderic", Realm = "Gul'dan EU", Class = "WARLOCK"},
    {Name = "Ilyxiana", Realm = "Ravencrest EU", Class = "PALADIN"},
    {Name = "Shizleh", Realm = "Eredar EU", Class = "WARLOCK"},
    {Name = "Ilunk", Realm = "Alleria EU", Class = "MONK"},
}

function credits.GetDonationsAsTable()
    local texts, text = {}, "";
    for _, donation in next, donations do
        local argbHex = donation.Class ~= "" and select(4, GetClassColor(donation.Class)) or "FFC0C0C0";
        text = "|c" .. argbHex .. donation.Name .. "|r";
        if donation.Realm then
            text = text .. " - " .. donation.Realm;
        end
        tinsert(texts, text);
    end
    return texts;
end

local localizations = {
    {Name = "Ta", Realm = "Der Rat von Dalaran EU", Class = "SHAMAN", Language = "German"},
    {Name = "牛奶斩", Realm = "格瑞姆巴托 CN", Class = "DRUID", Language = "Chinese (Simplified)"},
    {Name = "Astiraïs", Realm = "Elune EU", Class = "MAGE", Language = "French"},
    {Name = "Griboo", Realm = "Hyjal EU", Class = "HUNTER", Language = "French"},
    {Name = "Морфей", Realm = "Борейская тундра RU", Class = "WARLOCK", Language = "Russian"},
}

function credits.GetLocalizationsAsTable()
    local texts, text = {}, "";
    for _, localization in next, localizations do
        local argbHex = localization.Class ~= "" and select(4, GetClassColor(localization.Class)) or "FFC0C0C0";
        text = "|c" .. argbHex .. localization.Name .. "|r";
        if localization.Realm then
            text = text .. " - " .. localization.Realm;
        end
        if localization.Language then
            text = text .. " - " .. localization.Language;
        end
        tinsert(texts, text);
    end
    return texts;
end