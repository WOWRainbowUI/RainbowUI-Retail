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
---@diagnostic disable: duplicate-set-field

local lib = LibStub:NewLibrary("Krowi_MenuUtil-1.0", 5);

if not lib then
	return;
end

do -- Modern
    function lib:CreateTitle(menu, text)
        menu:CreateTitle(text);
    end

    function lib:CreateButton(menu, text, func, isEnabled)
        local button = menu:CreateButton(text, func);
        if isEnabled == false then
            button:SetEnabled(false);
        end
        return button;
    end

    function lib:CreateDivider(menu)
        menu:CreateDivider();
    end

    function lib:AddChildMenu(menu, child)

    end

    function lib:CreateButtonAndAdd(menu, text, func, isEnabled)
        return self:CreateButton(menu, text, func, isEnabled);
    end
end

if LibStub("Krowi_Util-1.0").IsMainline then
    return;
end

do -- Classic
    function lib:CreateTitle(menu, text)
        menu:AddTitle(text);
    end

    function lib:CreateButton(menu, text, func, isEnabled)
        return LibStub("Krowi_MenuItem-1.0"):New({
            Text = text,
            Func = func,
            Disabled = isEnabled == false
        });
    end

    function lib:CreateDivider(menu)
        menu:AddSeparator();
    end

    function lib:AddChildMenu(menu, child)
        if not menu or not child then
            return;
        end
        menu:Add(child);
    end

    function lib:CreateButtonAndAdd(menu, text, func, isEnabled)
        self:AddChildMenu(menu, self:CreateButton(nil, text, func, isEnabled));
    end
end