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

local L = lib.Localization.GetLocale('ruRU')
if not L then return end
lib.L = L

-- [[ https://legacy.curseforge.com/wow/addons/krowi-currency/localization ]] --
-- [[ Everything after this line is automatically generated from CurseForge and is not meant for manual edit - SOURCETOKEN - AUTOGENTOKEN ]] --

-- [[ Exported at 2026-01-02 11-04-00 ]] --
L["1k"] = "1к"
L["1m"] = "1м"
L["Comma"] = "Запятая"
L["Currency Abbreviate"] = "Сокращать Валюту"
L["Currency Options"] = "Настройки Валюты"
L["Icon"] = "Значок"
L["Millions Suffix"] = "м"
L["Money Abbreviate"] = "Сокращать Деньги"
L["Money Colored"] = "Цветные Деньги"
L["Money Gold Only"] = "Только Золото"
L["Money Label"] = "Метка Денег"
L["Money Options"] = "Настройки Денег"
L["None"] = "Нет"
L["Period"] = "Точка"
L["Space"] = "Пробел"
L["Text"] = "Текст"
L["Thousands Separator"] = "Разделитель Тысяч"
L["Thousands Suffix"] = "т"