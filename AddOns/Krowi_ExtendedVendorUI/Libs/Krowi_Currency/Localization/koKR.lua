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

local L = lib.Localization.GetLocale('koKR')
if not L then return end
lib.L = L

-- [[ https://legacy.curseforge.com/wow/addons/krowi-currency/localization ]] --
-- [[ Everything after this line is automatically generated from CurseForge and is not meant for manual edit - SOURCETOKEN - AUTOGENTOKEN ]] --

-- [[ Exported at 2026-01-02 11-03-59 ]] --
L["1k"] = "1천"
L["1m"] = "1백만"
L["Comma"] = "쉼표"
L["Currency Abbreviate"] = "화폐 줄이기"
L["Currency Options"] = "화폐 옵션"
L["Icon"] = "아이콘"
L["Millions Suffix"] = "백만"
L["Money Abbreviate"] = "골드 줄이기"
L["Money Colored"] = "골드 색상 표시"
L["Money Gold Only"] = "골드만 표시"
L["Money Label"] = "골드 라벨"
L["Money Options"] = "골드 옵션"
L["None"] = "없음"
L["Period"] = "마침표"
L["Space"] = "공백"
L["Text"] = "텍스트"
L["Thousands Separator"] = "천 단위 구분자"
L["Thousands Suffix"] = "천"