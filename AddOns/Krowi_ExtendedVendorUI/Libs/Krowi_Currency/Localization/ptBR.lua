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

local L = lib.Localization.GetLocale('ptBR')
if not L then return end
lib.L = L

-- [[ https://legacy.curseforge.com/wow/addons/krowi-currency/localization ]] --
-- [[ Everything after this line is automatically generated from CurseForge and is not meant for manual edit - SOURCETOKEN - AUTOGENTOKEN ]] --

-- [[ Exported at 2026-01-02 11-04-00 ]] --
L["1k"] = true
L["1m"] = true
L["Comma"] = "Vírgula"
L["Currency Abbreviate"] = "Abreviar Moeda"
L["Currency Options"] = "Opções de Moeda"
L["Icon"] = "Ícone"
L["Millions Suffix"] = "m"
L["Money Abbreviate"] = "Abreviar Dinheiro"
L["Money Colored"] = "Dinheiro Colorido"
L["Money Gold Only"] = "Apenas Ouro"
L["Money Label"] = "Rótulo de Dinheiro"
L["Money Options"] = "Opções de Dinheiro"
L["None"] = "Nenhum"
L["Period"] = "Ponto"
L["Space"] = "Espaço"
L["Text"] = "Texto"
L["Thousands Separator"] = "Separador de Milhares"
L["Thousands Suffix"] = "k"