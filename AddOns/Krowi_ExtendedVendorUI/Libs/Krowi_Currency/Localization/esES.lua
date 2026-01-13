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

local L = lib.Localization.GetLocale('esES')
if not L then return end
lib.L = L

-- [[ https://legacy.curseforge.com/wow/addons/krowi-currency/localization ]] --
-- [[ Everything after this line is automatically generated from CurseForge and is not meant for manual edit - SOURCETOKEN - AUTOGENTOKEN ]] --

-- [[ Exported at 2026-01-02 11-03-57 ]] --
L["1k"] = true
L["1m"] = true
L["Comma"] = "Coma"
L["Currency Abbreviate"] = "Abreviar Moneda"
L["Currency Options"] = "Opciones de Moneda"
L["Icon"] = "Icono"
L["Millions Suffix"] = "m"
L["Money Abbreviate"] = "Abreviar Dinero"
L["Money Colored"] = "Dinero Coloreado"
L["Money Gold Only"] = "Solo Oro"
L["Money Label"] = "Etiqueta de Dinero"
L["Money Options"] = "Opciones de Dinero"
L["None"] = "Ninguno"
L["Period"] = "Punto"
L["Space"] = "Espacio"
L["Text"] = "Texto"
L["Thousands Separator"] = "Separador de Miles"
L["Thousands Suffix"] = "k"