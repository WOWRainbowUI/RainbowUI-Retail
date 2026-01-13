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

local L = lib.Localization.GetLocale('itIT')
if not L then return end
lib.L = L

-- [[ https://legacy.curseforge.com/wow/addons/krowi-currency/localization ]] --
-- [[ Everything after this line is automatically generated from CurseForge and is not meant for manual edit - SOURCETOKEN - AUTOGENTOKEN ]] --

-- [[ Exported at 2026-01-02 11-03-59 ]] --
L["1k"] = true
L["1m"] = true
L["Comma"] = "Virgola"
L["Currency Abbreviate"] = "Abbrevia Valuta"
L["Currency Options"] = "Opzioni Valuta"
L["Icon"] = "Icona"
L["Millions Suffix"] = "m"
L["Money Abbreviate"] = "Abbrevia Denaro"
L["Money Colored"] = "Denaro Colorato"
L["Money Gold Only"] = "Solo Oro"
L["Money Label"] = "Etichetta Denaro"
L["Money Options"] = "Opzioni Denaro"
L["None"] = "Nessuno"
L["Period"] = "Punto"
L["Space"] = "Spazio"
L["Text"] = "Testo"
L["Thousands Separator"] = "Separatore Migliaia"
L["Thousands Suffix"] = "k"