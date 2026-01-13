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

local L = lib.Localization.GetLocale('zhCN')
if not L then return end
lib.L = L

-- [[ https://legacy.curseforge.com/wow/addons/krowi-currency/localization ]] --
-- [[ Everything after this line is automatically generated from CurseForge and is not meant for manual edit - SOURCETOKEN - AUTOGENTOKEN ]] --

-- [[ Exported at 2026-01-02 11-04-01 ]] --
L["1k"] = "1千"
L["1m"] = "1百万"
L["Comma"] = "逗号"
L["Currency Abbreviate"] = "缩写货币"
L["Currency Options"] = "货币选项"
L["Icon"] = "图标"
L["Millions Suffix"] = "百万"
L["Money Abbreviate"] = "缩写金币"
L["Money Colored"] = "彩色金币"
L["Money Gold Only"] = "仅显示金币"
L["Money Label"] = "金币标签"
L["Money Options"] = "金币选项"
L["None"] = "无"
L["Period"] = "句号"
L["Space"] = "空格"
L["Text"] = "文本"
L["Thousands Separator"] = "千位分隔符"
L["Thousands Suffix"] = "千"