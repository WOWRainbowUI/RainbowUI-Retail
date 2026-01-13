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

local L = lib.Localization.GetLocale('zhTW')
if not L then return end
lib.L = L

-- [[ https://legacy.curseforge.com/wow/addons/krowi-currency/localization ]] --
-- [[ Everything after this line is automatically generated from CurseForge and is not meant for manual edit - SOURCETOKEN - AUTOGENTOKEN ]] --

-- [[ Exported at 2026-01-02 11-04-01 ]] --
L["1k"] = "1千"
L["1m"] = "1百萬"
L["Comma"] = "逗號"
L["Currency Abbreviate"] = "縮寫貨幣"
L["Currency Options"] = "貨幣選項"
L["Icon"] = "圖示"
L["Millions Suffix"] = "百萬"
L["Money Abbreviate"] = "縮寫金幣"
L["Money Colored"] = "彩色金幣"
L["Money Gold Only"] = "僅顯示金幣"
L["Money Label"] = "金幣標籤"
L["Money Options"] = "金幣選項"
L["None"] = "無"
L["Period"] = "句號"
L["Space"] = "空格"
L["Text"] = "文字"
L["Thousands Separator"] = "千位分隔符"
L["Thousands Suffix"] = "千"