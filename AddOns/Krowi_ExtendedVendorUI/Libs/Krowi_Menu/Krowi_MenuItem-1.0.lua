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

-- Define shared minor version for all Krowi_Menu libraries
KROWI_MENU_LIBRARY_MINOR = 11

local MAJOR, MINOR = "Krowi_MenuItem-1.0", KROWI_MENU_LIBRARY_MINOR
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then
	return
end

-- Store version constants
lib.MAJOR = MAJOR
lib.MINOR = MINOR

lib.__index = lib
function lib:New(info, hideOnClick)
    local instance = setmetatable({}, lib)
    if type(info) == "string" then
        info = {
            Text = info,
            KeepShownOnClick = not hideOnClick
        }
    end
    for k, v in next, info do
        instance[k] = v
    end
    return instance
end

function lib:Add(item)
    if self.Children == nil then
        self.Children = {} -- By creating the children table here we reduce memory usage because not every category has children
    end
    tinsert(self.Children, item)
    return item
end

function lib:AddFull(info)
    return self:Add(self:New(info))
end

function lib:AddTitle(text)
    self:AddFull({
		Text = text,
		IsTitle = true
	})
end

function lib:AddSeparator()
    return self:AddFull({IsSeparator = true})
end