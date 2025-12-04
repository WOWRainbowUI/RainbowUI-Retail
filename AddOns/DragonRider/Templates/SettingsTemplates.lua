DragonRiderColorSwatchSettingMixin = {};

local dr_clipboardColor = nil

local LOCALE = GetLocale()
local L = {};


if LOCALE == "enUS" then
	-- The EU English game client also
	-- uses the US English locale code.
	L["LC_OpenColorPicker"] = "Left-Click: Open Color Picker"
	L["RC_OpenDropdown"] = "Right-Click: Additional Settings"
	L["ColorOptions"] = "Color Options"
	L["CopyColor"] = "Copy Color"
	L["PasteColor"] = "Paste Color"

end

if LOCALE == "esES" or LOCALE == "esMX" then
	-- Spanish translations go here
	L["LC_OpenColorPicker"] = "Clic izquierdo: Abrir selector de color"
	L["RC_OpenDropdown"] = "Clic derecho: Configuración adicional"
	L["ColorOptions"] = "Opciones de color"
	L["CopyColor"] = "Copiar color"
	L["PasteColor"] = "Pegar color"

end

if LOCALE == "deDE" then
	-- German translations go here
	L["LC_OpenColorPicker"] = "Links-Klick: Farbwähler öffnen"
	L["RC_OpenDropdown"] = "Rechts-Klick: Zusätzliche Einstellungen"
	L["ColorOptions"] = "Farboptionen"
	L["CopyColor"] = "Farbe kopieren"
	L["PasteColor"] = "Farbe einfügen"

end

if LOCALE == "frFR" then
	-- French translations go here
	L["LC_OpenColorPicker"] = "Clic gauche : Ouvrir le sélecteur de couleur"
	L["RC_OpenDropdown"] = "Clic droit : Paramètres supplémentaires"
	L["ColorOptions"] = "Options de couleur"
	L["CopyColor"] = "Copier la couleur"
	L["PasteColor"] = "Coller la couleur"

end

if LOCALE == "itIT" then
	-- French translations go here
	L["LC_OpenColorPicker"] = "Clic sinistro: Apri selettore colore"
	L["RC_OpenDropdown"] = "Clic destro: Impostazioni aggiuntive"
	L["ColorOptions"] = "Opzioni colore"
	L["CopyColor"] = "Copia colore"
	L["PasteColor"] = "Incolla colore"

end

if LOCALE == "ptBR" then
	-- Brazilian Portuguese translations go here
	L["LC_OpenColorPicker"] = "Clique esquerdo: Abrir seletor de cores"
	L["RC_OpenDropdown"] = "Clique direito: Configurações adicionais"
	L["ColorOptions"] = "Opções de cor"
	L["CopyColor"] = "Copiar cor"
	L["PasteColor"] = "Colar cor"

-- Note that the EU Portuguese WoW client also
-- uses the Brazilian Portuguese locale code.
end

if LOCALE == "ruRU" then
	-- Russian translations go here
	L["LC_OpenColorPicker"] = "ЛКМ: Открыть палитру цветов"
	L["RC_OpenDropdown"] = "ПКМ: Дополнительные настройки"
	L["ColorOptions"] = "Параметры цвета"
	L["CopyColor"] = "Копировать цвет"
	L["PasteColor"] = "Вставить цвет"

end

if LOCALE == "koKR" then
	-- Korean translations go here
	L["LC_OpenColorPicker"] = "좌클릭: 색상 선택기 열기"
	L["RC_OpenDropdown"] = "우클릭: 추가 설정"
	L["ColorOptions"] = "색상 옵션"
	L["CopyColor"] = "색상 복사"
	L["PasteColor"] = "색상 붙여넣기"

end

if LOCALE == "zhCN" then
	-- Simplified Chinese translations go here
	L["LC_OpenColorPicker"] = "左键：打开颜色选择器"
	L["RC_OpenDropdown"] = "右键：更多设置"
	L["ColorOptions"] = "颜色选项"
	L["CopyColor"] = "复制颜色"
	L["PasteColor"] = "粘贴颜色"

end

if LOCALE == "zhTW" then
	-- Traditional Chinese translations go here
	L["LC_OpenColorPicker"] = "左鍵：開啟顏色選擇器"
	L["RC_OpenDropdown"] = "右鍵：其他設定"
	L["ColorOptions"] = "顏色選項"
	L["CopyColor"] = "複製顏色"
	L["PasteColor"] = "貼上顏色"

end

function DragonRiderColorSwatchSettingMixin:OnLoad()
	SettingsListElementMixin.OnLoad(self);
end

function DragonRiderColorSwatchSettingMixin:Init(initializer)
	SettingsListElementMixin.Init(self, initializer);

	local data = initializer:GetData();
	local colorTable = data.setting:GetValue(); -- Gets the {r,g,b,a} table

		self.ColorSwatch:SetScript("OnEnter", function()
			GameTooltip:SetOwner(self.ColorSwatch, "ANCHOR_RIGHT")
			GameTooltip:SetText(COLOR_PICKER)
			GameTooltip:AddLine(L["LC_OpenColorPicker"], 1, 1, 1)
			GameTooltip:AddLine(L["RC_OpenDropdown"], 1, 1, 1)
			GameTooltip:Show()
		end)

		self.ColorSwatch:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)

	local function UpdateSwatchVisuals(t)
		if not t then return end
		self.ColorSwatch.Color:SetVertexColor(t.r, t.g, t.b, t.a)
	end

	local colorTable = data.setting:GetValue();

	if type(colorTable) ~= "table" then 
		colorTable = {r = 1, g = 1, b = 1, a = 1};
	end


	-- Create a color object from the RGBA table to set the swatch color
	local colorObj = CreateColor(colorTable.r, colorTable.g, colorTable.b, colorTable.a);
	self.ColorSwatch:SetColor(colorObj);

	self.ColorSwatch:RegisterForClicks("AnyUp");

	self.ColorSwatch:SetScript("OnClick", function(_, button)
		if button == "RightButton" then
			MenuUtil.CreateContextMenu(self.ColorSwatch, function(owner, rootDescription)
				rootDescription:CreateTitle(L["ColorOptions"]);

				rootDescription:CreateButton(L["CopyColor"], function()
					local current = data.setting:GetValue();
					if type(current) ~= "table" then current = {r=1, g=1, b=1, a=1} end
					dr_clipboardColor = CopyTable(current);
				end);

				local pasteBtn = rootDescription:CreateButton(L["PasteColor"], function()
					if not dr_clipboardColor then return end
					local newTable = CopyTable(dr_clipboardColor);
					data.setting:SetValue(newTable);
					UpdateSwatchVisuals(newTable);
				end);
				if not dr_clipboardColor then pasteBtn:SetEnabled(false); end

				rootDescription:CreateButton(RESET_TO_DEFAULT, function()
					local default = data.setting:GetDefaultValue()
					if not default and data.setting.defaultValue then 
						default = data.setting.defaultValue 
					end
					if default and type(default) == "table" then
						local newTable = CopyTable(default);
						data.setting:SetValue(newTable);
						UpdateSwatchVisuals(newTable);
					end
				end);
			end);
			return; 
		end

		local info = {};
		local currentColorTable = data.setting:GetValue();
		if type(currentColorTable) ~= "table" then
			currentColorTable = {r = 1, g = 1, b = 1, a = 1};
		end

		-- Set the color picker's initial values from our table
		info.r, info.g, info.b, info.opacity = currentColorTable.r, currentColorTable.g, currentColorTable.b, currentColorTable.a;
		info.hasOpacity = true; -- Assuming all your colors use alpha

		-- This function runs when the color is changed
		info.swatchFunc = function()
			local r, g, b = ColorPickerFrame:GetColorRGB();
			local a = ColorPickerFrame:GetColorAlpha();
			
			self.ColorSwatch.Color:SetVertexColor(r, g, b, a);

			-- Get the original table and modify its values directly
			local savedColorTable = data.setting:GetValue();
			savedColorTable.r, savedColorTable.g, savedColorTable.b, savedColorTable.a = r, g, b, a;

			-- Save the modified table back. This also triggers the OnValueChanged callback.
			data.setting:SetValue(savedColorTable);

			if ColorPickerFrame.Content and ColorPickerFrame.Content.HexBox then
				local c = CreateColor(r, g, b, a)
				ColorPickerFrame.Content.HexBox:SetText(c:GenerateHexColor())
				ColorPickerFrame.Content.HexBox:SetCursorPosition(0)
			end
		end;

		-- This function runs if the user cancels
		info.cancelFunc = function ()
			local r, g, b, a = ColorPickerFrame:GetPreviousValues();
			self.ColorSwatch.Color:SetVertexColor(r, g, b, a);

			local savedColorTable = data.setting:GetValue();
			savedColorTable.r, savedColorTable.g, savedColorTable.b, savedColorTable.a = r, g, b, a;
			data.setting:SetValue(savedColorTable);
		end;

		ColorPickerFrame:SetupColorPickerAndShow(info);
		
		if ColorPickerFrame.Content and ColorPickerFrame.Content.HexBox then
			local c = CreateColor(info.r, info.g, info.b, info.opacity)
			ColorPickerFrame.Content.HexBox:SetText(c:GenerateHexColor())
		end
	end);
end