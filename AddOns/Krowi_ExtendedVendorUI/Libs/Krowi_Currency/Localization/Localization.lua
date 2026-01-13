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
if lib.Localization then return end

lib.Localization = {}
local localization = lib.Localization

local localeIsLoaded, defaultLocale = {}, 'enUS'
function localization.GetDefaultLocale()
    if localeIsLoaded[defaultLocale] then return end

    localeIsLoaded[defaultLocale] = true
    return LibStub("AceLocale-3.0"):NewLocale("Krowi_Currency-1.0", defaultLocale, true, true)
end

function localization.GetLocale(locale)
    if localeIsLoaded[locale] then return end

    localeIsLoaded[locale] = true
    return LibStub("AceLocale-3.0"):NewLocale("Krowi_Currency-1.0", locale)
end