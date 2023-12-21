
SLASH_SIMPLEVIGNETTE1, SLASH_SIMPLEVIGNETTE2 = '/sv', '/simplevignette';

-- by Kaemin

function SlashCmdList.SIMPLEVIGNETTE(msg, editbox)
	if msg == nil or msg == "" or msg == "menu" or msg == "options" or msg == "?" or msg == "help" then
		InterfaceOptionsFrame_OpenToCategory(SV_PanelName);
		InterfaceOptionsFrame_OpenToCategory(SV_PanelName);
		SVSoundNameShow:SetText(svsoundname);
	else
		DEFAULT_CHAT_FRAME:AddMessage("稀有怪與寶箱通知 SimpleVignette " ..GetAddOnMetadata("SimpleVignette", "Version").. ": /sv for options.");
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")
f:SetScript("OnEvent", function(self, event, vignetteInstanceID, onMiniMap)
	if vignetteInstanceID and onMiniMap then
		if SVInstanceID == vignetteInstanceID then
		else
			SVInstanceID = vignetteInstanceID;
			RareObjectName = "";
			RareObjectAtlasName = "";
			local SV_Table = C_VignetteInfo.GetVignetteInfo(vignetteInstanceID)
			if not SV_Table then return end
			local name = SV_Table.name
			if name then
--				Excluded Items List follows
				if name == "擺渡者"    
					or name == "邁里特"
					or name == "巨牙海民釣具箱"
					or name == "群島之風"
					or name == "青銅時空守衛者"
					or name == "外形調整台"
					or name == "任務指揮桌"
					or name == "偵察地圖"
					or name == "要塞儲物箱"
					or name == "爪鉤成長菇"
					then return
				end
				if not svchests then
					if string.find (name, "Treasure")
						or string.find (name, "Statue")
						or string.find (name, "Garrison Cache") then
							return
					end
				end
				RareObjectName = name;
				RareObjectAtlasName = SV_Table.atlasName;
			end
			if not name then
				RareObjectName = "Rare";
			end
			SVOutputOptions();
		end
	end
end)

function ChangeSoundClick()
	if svsoundnum==0 or svsoundnum==1 then 
		svsoundnum = 2; 
		svsoundname = "交響樂"; 
		svsoundfile = "Interface\\AddOns\\SimpleVignette\\sounds\\Symphony.ogg"; 
		SVSoundNameShow:SetText(svsoundname); 
	elseif svsoundnum==2 then
		svsoundnum = 3; 
		svsoundname = "水晶-貝九"; 
		svsoundfile = "Interface\\AddOns\\SimpleVignette\\sounds\\Crystal.ogg"; 
		SVSoundNameShow:SetText(svsoundname);
	elseif svsoundnum==3 then
		svsoundnum = 4; 
		svsoundname = "殺戮時刻"; 
		svsoundfile = "Interface\\AddOns\\SimpleVignette\\sounds\\Killing_moment.ogg"; 
		SVSoundNameShow:SetText(svsoundname);
	elseif svsoundnum==4 then
		svsoundnum = 5; 
		svsoundname = "喇叭無力"; 
		svsoundfile = "Interface\\AddOns\\SimpleVignette\\sounds\\party.mp3"; 
		SVSoundNameShow:SetText(svsoundname);
	elseif svsoundnum==5 then
		svsoundnum = 6; 
		svsoundname = "把晡"; 
		svsoundfile = "Interface\\AddOns\\SimpleVignette\\sounds\\bike.mp3"; 
		SVSoundNameShow:SetText(svsoundname);
	elseif svsoundnum==6 then
		svsoundnum = 7; 
		svsoundname = "叮咚"; 
		svsoundfile = "Interface\\AddOns\\SimpleVignette\\sounds\\chime.mp3"; 
		SVSoundNameShow:SetText(svsoundname);
	elseif svsoundnum==7 then
		svsoundnum = 8; 
		svsoundname = "警報"; 
		svsoundfile = "Interface\\AddOns\\SimpleVignette\\sounds\\woop.mp3"; 
		SVSoundNameShow:SetText(svsoundname);
	elseif svsoundnum==8 then
		svsoundnum = 9;
		svsoundname = "信號";
		svsoundfile = "Interface\\AddOns\\SimpleVignette\\sounds\\other_alarm.mp3";
		SVSoundNameShow:SetText(svsoundname);
	elseif svsoundnum==9 then
		svsoundnum = 10;
		svsoundname = "準備行動";
		svsoundfile = "Interface\\AddOns\\SimpleVignette\\sounds\\Action.ogg";
		SVSoundNameShow:SetText(svsoundname);
	elseif svsoundnum==10 then
		svsoundnum = 11;
		svsoundname = "殺殺殺";
		svsoundfile = "Interface\\AddOns\\SimpleVignette\\sounds\\Kill.ogg";
		SVSoundNameShow:SetText(svsoundname);
	elseif svsoundnum==11 then
		svsoundnum = 12;
		svsoundname = "蘋果派";
		svsoundfile = "Interface\\AddOns\\SimpleVignette\\sounds\\applepie.mp3";
		SVSoundNameShow:SetText(svsoundname);
	elseif svsoundnum==12 then
		svsoundnum = 1;
		svsoundname = "十塊";
		svsoundfile = "Interface\\AddOns\\SimpleVignette\\sounds\\10kwai.mp3";
		SVSoundNameShow:SetText(svsoundname);
	end
end

function TestSoundClick()
	if (svsound) then
		PlaySoundFile(svsoundfile);
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00" ..svsoundname.." 已出現！|r");
		SVMessageFrame:AddMessage(svsoundname.. " 已出現！", 0, 1, 0, .8, .5);
	else
		DEFAULT_CHAT_FRAME:AddMessage("稀有怪與寶箱通知: 音效|cffff0000已停用|r。");
	end
end

function SVSound_Check()
	SoundSelectButton:SetScript("PostClick", function(self)
		if self:GetChecked() then
			svsound = true;
		else 
			svsound = false;
		end
	end)
end

function SVChest_Check()
	ChestSelectButton:SetScript("PostClick", function(self)
		if self:GetChecked() then
			svchests = true;
		else 
			svchests = false;
		end
	end)
end

-- Codes borrow from Vignette Announcer addon.
function VAFormatAtlasString(str)
	local AtlasInfo = C_Texture.GetAtlasInfo(str)
	if (not AtlasInfo) then return "" end

	local file = AtlasInfo.filename or AtlasInfo.file;
	local width, height, leftTexCoord, rightTexCoord, topTexCoord, bottomTexCoord = AtlasInfo.width, AtlasInfo.height, AtlasInfo.leftTexCoord, AtlasInfo.rightTexCoord, AtlasInfo.topTexCoord, AtlasInfo.bottomTexCoord
	local size = 20;

	local atlasWidth = width / (rightTexCoord - leftTexCoord);
	local atlasHeight = height / (bottomTexCoord - topTexCoord);
	local pxLeft    = atlasWidth    * leftTexCoord;
	local pxRight   = atlasWidth    * rightTexCoord;
	local pxTop     = atlasHeight   * topTexCoord;
	local pxBottom  = atlasHeight   * bottomTexCoord;

	return format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t", file, size, size, atlasWidth, atlasHeight, pxLeft, pxRight, pxTop, pxBottom);
end

function SVOutputOptions()
	local msg = VAFormatAtlasString(RareObjectAtlasName).."|cff00ff00"..RareObjectName.." 已出現！|r";
			DEFAULT_CHAT_FRAME:AddMessage(msg);
			SVMessageFrame:AddMessage(msg);
			-- SVMessageFrame:AddMessage(RareObjectName.." 已出現！", 0, 1, 0, .8, .5)
	if (svsound) then
		PlaySoundFile(svsoundfile);
	end
end

function SV_MenuPanel(SV_Panel)
	SV_Panel.name = "稀有怪-通知";
	SV_Panel.okay = function (self) SV_MenuPanel_Close(); end;
    SV_Panel.cancel = function (self) SV_MenuPanel_CancelOrLoad(); end;
	SVSoundNameShow:SetText(svsoundname);
	InterfaceOptions_AddCategory(SV_Panel);
end

function SV_MenuPanel_Close()
	if SVOptions_Frame:IsShown() then
		SVOptions_Frame:Hide();
	end
end

function SV_MenuPanel_CancelOrLoad()
	if SVOptions_Frame:IsShown() then
		SVOptions_Frame:Hide();
	end
end

function SimpleVignette_OnLoad(SV_Panel)
	local fframe = CreateFrame("Frame")
	fframe:RegisterEvent("ADDON_LOADED");
	fframe:SetScript("OnEvent", function(self, event, arg1)
		if event == "ADDON_LOADED" and arg1 == "SimpleVignette" then
			SVOptions_Frame:SetScale(.75);
			if svchests == nil then
				svchests = true;
			end
			if svsound == nil then
				svsound = false;
				svsoundd = "false";
			elseif svsound ~= nil then
				if (svsound) then
					svsoundd = "true";
				elseif not svsound then
					svsoundd = "false";
				end
			end
			if svsoundfile == nil then
				svsoundfile = "Interface\\AddOns\\SimpleVignette\\sounds\\Symphony.ogg";
				svsoundnum = 2;
				svsoundname = "交響樂";
			end
			if (svchests) then
				ChestSelectButton:SetChecked(true);
			else
				ChestSelectButton:SetChecked(false);
			end
			if (svsound) then
				SoundSelectButton:SetChecked(true);
			else
				SoundSelectButton:SetChecked(false);
			end
		end
	end)
	SVOptions_Frame:Hide();
	SV_PanelName = SV_Panel
	SV_MenuPanel(SV_Panel);
	SVInstanceID = 0;
	-- DEFAULT_CHAT_FRAME:AddMessage("SimpleVignette " ..GetAddOnMetadata("SimpleVignette", "Version").. " loaded: /sv for options");
end
