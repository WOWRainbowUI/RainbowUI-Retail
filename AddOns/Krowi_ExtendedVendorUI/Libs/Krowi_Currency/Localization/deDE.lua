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

local lib = LibStub("Krowi_Currency-1.0", true)
if not lib then	return end

local L = lib.Localization.GetLocale('deDE')
if not L then return end
lib.L = L

-- [[ https://legacy.curseforge.com/wow/addons/krowi-currency/localization ]] --
-- [[ Everything after this line is automatically generated from CurseForge and is not meant for manual edit - SOURCETOKEN - AUTOGENTOKEN ]] --

-- [[ Exported at 2026-01-02 11-03-56 ]] --
L["1k"] = "1T"
L["1m"] = "1M"
L["Comma"] = "Komma"
L["Currency Abbreviate"] = "Währung Abkürzen"
L["Currency Options"] = "Währungsoptionen"
L["Icon"] = "Symbol"
L["Millions Suffix"] = "M"
L["Money Abbreviate"] = "Geld Abkürzen"
L["Money Colored"] = "Geld Farbig"
L["Money Gold Only"] = "Nur Gold Anzeigen"
L["Money Label"] = "Geldbeschriftung"
L["Money Options"] = "Geldoptionen"
L["None"] = "Keine"
L["Period"] = "Punkt"
L["Space"] = "Leerzeichen"
L["Text"] = true
L["Thousands Separator"] = "Tausendertrennzeichen"
L["Thousands Suffix"] = "T"