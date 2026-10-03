local _, MySlot = ...

local L = setmetatable({}, {
    __index = function(table, key)
        if key then
            table[key] = tostring(key)
        end
        return tostring(key)
    end,
})


MySlot.L = L

--
-- Use http://www.wowace.com/addons/myslot/localization/ to translate thanks
--
local locale = GetLocale()

if locale == 'enUs' then
L[" before Import"] = true
L[" during Export"] = true
L[" during Import"] = true
L["%s is busy sharing other profiles, try again later."] = true
L["%s is no longer sharing '%s'."] = true
L["%s is offline."] = true
L["[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"] = true
L["[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"] = true
L["[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"] = true
L["<- share your profile here"] = true
L["Addon messages are restricted right now (combat, encounter, Mythic+ or PvP). Try again later."] = true
L["All slots were restored"] = true
L["Allow"] = true
L["Already requesting '%s' from %s..."] = true
L["Apply talents"] = true
L["'Apply talents' can still load it, but talents changed since it was saved: check the loadout in the talent window before clicking 'Apply Changes'."] = true
L["Applying..."] = true
L["Are you SURE to delete '%s'?"] = true
L["Are you SURE to import ?"] = true
L["Backup"] = true
L["Backup failed"] = true
L["Bad importing text [CRC32]"] = true
L["Bad importing text [TEXT]"] = true
L["Battle.net friend"] = true
L["Before Last Import"] = true
L["By class"] = true
L["By date"] = true
L["By name"] = true
L["CLEAR"] = true
L["Click Cast Bindings"] = true
L["Cooldown Manager"] = true
L["Copy this string and import it in the talent window"] = true
L["Could not delete %d 'Myslot' talent loadout(s)"] = true
L["Could not send the request, try again later."] = true
L["DANGEROUS"] = true
L["Deleted %d 'Myslot' talent loadout(s)"] = true
L["Deleting %d 'Myslot' talent loadout(s)..."] = true
L["Export"] = true
L["Failed to apply talents"] = true
L["Failed to send profile '%s' to %s."] = true
L["Feedback"] = true
L["Force Import"] = true
L["IGNORE"] = true
L["Ignore missing item [id=%s]"] = true
L["Ignore unattained companion [id=%s], %s"] = true
L["Ignore unattained pet [id=%s]"] = true
L["Ignore unknown macro [id=%s]"] = true
L["Ignore unknown outfit [id=%s, name=%s]"] = true
L["Ignore unlearned skill [flyoutid=%s], %s"] = true
L["Ignore unlearned skill [id=%s], %s"] = true
L["Import"] = true
L["Import failed"] = true
L["Import is not allowed when you are in combat"] = true
L["Importing..."] = true
L["Kept your text, discarded the received profile '%s'."] = true
L["Key Binding"] = true
L["Link in chat"] = true
L["Macro %s was ignored, check if there is enough space to create"] = true
L["Main Action Bar Page"] = true
L["Minimap Icon"] = true
L["Myslot"] = true
L["Name of exported text"] = true
L["No response from %s. They may be offline, busy, or not running Myslot."] = true
L["No talent string in this profile"] = true
L["Nothing to import"] = true
L["Nothing to share, save the profile first"] = true
L["Only my class"] = true
L["Open Myslot"] = true
L["Please type %s to confirm"] = true
L["Post a link to the selected profile in chat. Other Myslot users can click it to get a copy."] = true
L["Received a damaged profile from %s."] = true
L["Received profile '%s' from %s. Review it, then click Import to apply."] = true
L["Remove all Click Cast Bindings"] = true
L["Remove all Cooldown Manager"] = true
L["Remove all Key Bindings"] = true
L["Remove all Macros"] = true
L["Remove everything in ActionBar"] = true
L["Remove 'Myslot' talent loadouts"] = true
L["Rename"] = true
L["Replace the unsaved text with the received profile '%s'? Your unsaved changes will be lost."] = true
L["Requesting profile '%s' from %s..."] = true
L["Save the profile before sharing it."] = true
L["Save the talents of this profile as the talent loadout 'Myslot', replacing the previous one, and open it in the talent window. Click 'Apply Changes' there to use it."] = true
L["Save your changes before sharing, only saved profiles can be shared."] = true
L["Select a profile"] = true
L["Select a saved profile to share it."] = true
L["Sending profile '%s' to %s..."] = true
L["Skip bad CRC32"] = true
L["Skyriding Bar"] = true
L["Sort by"] = true
L["Stance Action Bar"] = true
L["Starting backup..."] = true
L["Stopped sending a shared profile."] = true
L["Talent loadout 'Myslot' is ready, click 'Apply Changes' in the talent window to use it"] = true
L["Talent loadouts are not supported by this game version"] = true
L["Talents are already being applied"] = true
L["Talents cannot be changed in combat"] = true
L["Talents differ"] = true
L["Talents for another spec"] = true
L["Talents match"] = true
L["Talents out of date"] = true
L["That Battle.net friend is not online in World of Warcraft."] = true
L["The talents of this profile are different from your current talents."] = true
L["These talents are for %s, switch to that specialization first"] = true
L["These talents were saved from an older talent tree, check them before applying"] = true
L["This profile is no longer shared, link it again."] = true
L["Time"] = true
L["Timed out applying talents"] = true
L["TOC_NOTES"] = "Myslot is for transferring settings between accounts. Feedback farmer1992@gmail.com"
L["Too many profiles, please delete before create new one."] = true
L["Too many saved talent loadouts, delete one first"] = true
L["Try force importing"] = true
L["Unsaved"] = true
L["Use random mount instead of an unattained mount"] = true


elseif locale == 'zhCN' then
L[" before Import"] = " 导入前"
L[" during Export"] = " 导出中"
L[" during Import"] = " 导入中"
L["[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"] = "[警告] 因未知错误忽略插槽 调试信息 = [S=%s T=%s I=%s] 请发送导入文本和调试信息到 %s"
L["[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"] = "[警告] 忽略不支持的按键绑定 [ %s ] ，请联系 %s"
L["[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"] = "[警告] 忽略不支持的插槽类型 [ %s ] ，请联系 %s"
L["<- share your profile here"] = "<- 在这里分享你的配置文件"
L["All slots were restored"] = "所有插槽已恢复"
L["Allow"] = "允许"
L["Are you SURE to delete '%s'?"] = "你确定要删除 '%s' 吗？"
L["Are you SURE to import ?"] = "你确定要导入吗？"
L["Backup failed"] = "备份失败"
L["Bad importing text [CRC32]"] = "无效的导入文本 [CRC32]"
L["Bad importing text [TEXT]"] = "无效的导入文本 [TEXT]"
L["Before Last Import"] = "上次导入之前"
L["CLEAR"] = "清除"
L["DANGEROUS"] = "危险"
L["Export"] = "导出"
L["Feedback"] = "反馈"
L["Force Import"] = "强制导入"
L["IGNORE"] = "忽略"
L["Ignore missing item [id=%s]"] = "忽略缺失的物品 [id=%s]"
L["Ignore unattained companion [id=%s], %s"] = "忽略未获得的伙伴 [id=%s], %s"
L["Ignore unattained pet [id=%s]"] = "忽略未获得的宠物 [id=%s]"
L["Ignore unknown macro [id=%s]"] = "忽略未知的宏 [id=%s]"
L["Ignore unlearned skill [flyoutid=%s], %s"] = "忽略未学会的技能 [flyoutid=%s], %s"
L["Ignore unlearned skill [id=%s], %s"] = "忽略未学会的技能 [id=%s], %s"
L["Import"] = "导入"
L["Import is not allowed when you are in combat"] = "战斗中无法导入"
L["Key Binding"] = "按键绑定"
L["Macro %s was ignored, check if there is enough space to create"] = "宏 %s 被忽略，请检查是否有足够空间创建"
L["Main Action Bar Page"] = "主动作条页面"
L["Minimap Icon"] = "小地图图标"
L["Myslot"] = "Myslot"
L["Name of exported text"] = "导出文本的名称"
L["Open Myslot"] = "打开Myslot"
L["Please type %s to confirm"] = "请输入 %s 以确认"
L["Remove all Key Bindings"] = "移除所有按键绑定"
L["Remove all Macros"] = "移除所有宏"
L["Remove everything in ActionBar"] = "移除动作条上的所有内容"
L["Rename"] = "重命名"
L["Skip bad CRC32"] = "跳过无效的 CRC32"
L["Skyriding Bar"] = "飞行栏"
L["Stance Action Bar"] = "姿态动作条"
L["Starting backup..."] = "正在开始备份..."
L["Time"] = "时间"
L["TOC_NOTES"] = "Myslot 用于在账户之间传输设置。反馈: farmer1992@gmail.com"
L["Too many profiles, please delete before create new one."] = "配置文件过多，请删除后再创建新文件。"
L["Try force importing"] = "尝试强制导入"
L["Unsaved"] = "未保存"
L["Use random mount instead of an unattained mount"] = "使用随机坐骑替代未获得的坐骑"


L["%s is busy sharing other profiles, try again later."] = "%s 正在分享其他配置文件，请稍后再试。"

L["%s is no longer sharing '%s'."] = "%s 已不再分享'%s'。"

L["%s is offline."] = "%s 已离线。"

L["Addon messages are restricted right now (combat, encounter, Mythic+ or PvP). Try again later."] = "插件消息当前受限（战斗、首领战、史诗钥石或PvP）。请稍后再试。"

L["Already requesting '%s' from %s..."] = "已在请求'%s'（来自 %s）..."

L["Apply talents"] = "应用天赋"

L["'Apply talents' can still load it, but talents changed since it was saved: check the loadout in the talent window before clicking 'Apply Changes'."] = "仍可通过'应用天赋'加载，但保存后天赋已发生变化：点击'应用改动'前请在天赋窗口中检查配置。"

L["Applying..."] = "正在应用..."

L["Backup"] = "备份"

L["Battle.net friend"] = "战网好友"

L["By class"] = "按职业"

L["By date"] = "按日期"

L["By name"] = "按名称"

L["Click Cast Bindings"] = "点击施法绑定"

L["Cooldown Manager"] = "冷却管理器"

L["Copy this string and import it in the talent window"] = "复制此字符串并在天赋窗口中导入"

L["Could not delete %d 'Myslot' talent loadout(s)"] = "无法删除 %d 个'Myslot'天赋配置"

L["Could not send the request, try again later."] = "无法发送请求，请稍后再试。"

L["Deleted %d 'Myslot' talent loadout(s)"] = "已删除 %d 个'Myslot'天赋配置"

L["Deleting %d 'Myslot' talent loadout(s)..."] = "正在删除 %d 个'Myslot'天赋配置..."

L["Failed to apply talents"] = "应用天赋失败"

L["Failed to send profile '%s' to %s."] = "发送配置文件'%s'给 %s 失败。"

L["Ignore unknown outfit [id=%s, name=%s]"] = "忽略未知的外观方案 [id=%s, name=%s]"

L["Import failed"] = "导入失败"

L["Importing..."] = "正在导入..."

L["Kept your text, discarded the received profile '%s'."] = "已保留你的文本，丢弃收到的配置文件'%s'。"

L["Link in chat"] = "链接至聊天栏"

L["No response from %s. They may be offline, busy, or not running Myslot."] = "%s 没有响应。对方可能离线、忙碌或未运行Myslot。"

L["No talent string in this profile"] = "此配置文件中没有天赋字符串"

L["Nothing to import"] = "没有可导入的内容"

L["Nothing to share, save the profile first"] = "没有可分享的内容，请先保存配置文件"

L["Only my class"] = "仅限我的职业"

L["Post a link to the selected profile in chat. Other Myslot users can click it to get a copy."] = "在聊天中发布所选配置文件的链接。其他Myslot用户点击即可获取副本。"

L["Received a damaged profile from %s."] = "收到来自 %s 的损坏配置文件。"

L["Received profile '%s' from %s. Review it, then click Import to apply."] = "已收到配置文件'%s'（来自 %s）。检查后点击'导入'即可应用。"

L["Remove all Click Cast Bindings"] = "移除所有点击施法绑定"

L["Remove all Cooldown Manager"] = "移除所有冷却管理器设置"

L["Remove 'Myslot' talent loadouts"] = "移除'Myslot'天赋配置"

L["Replace the unsaved text with the received profile '%s'? Your unsaved changes will be lost."] = "用收到的配置文件'%s'替换未保存的文本？未保存的更改将会丢失。"

L["Requesting profile '%s' from %s..."] = "正在请求配置文件'%s'（来自 %s）..."

L["Save the profile before sharing it."] = "分享前请先保存配置文件。"

L["Save the talents of this profile as the talent loadout 'Myslot', replacing the previous one, and open it in the talent window. Click 'Apply Changes' there to use it."] = "将此配置文件的天赋保存为天赋配置'Myslot'（替换之前的配置），并在天赋窗口中打开。在那里点击'应用改动'即可使用。"

L["Save your changes before sharing, only saved profiles can be shared."] = "分享前请保存更改，只能分享已保存的配置文件。"

L["Select a profile"] = "选择配置文件"

L["Select a saved profile to share it."] = "选择一个已保存的配置文件进行分享。"

L["Sending profile '%s' to %s..."] = "正在发送配置文件'%s'给 %s..."

L["Sort by"] = "排序"

L["Stopped sending a shared profile."] = "已停止发送分享的配置文件。"

L["Talent loadout 'Myslot' is ready, click 'Apply Changes' in the talent window to use it"] = "天赋配置'Myslot'已就绪，在天赋窗口中点击'应用改动'即可使用"

L["Talent loadouts are not supported by this game version"] = "此游戏版本不支持天赋配置"

L["Talents are already being applied"] = "天赋正在应用中"

L["Talents cannot be changed in combat"] = "战斗中无法更改天赋"

L["Talents differ"] = "天赋不同"

L["Talents for another spec"] = "其他专精的天赋"

L["Talents match"] = "天赋一致"

L["Talents out of date"] = "天赋已过时"

L["That Battle.net friend is not online in World of Warcraft."] = "该战网好友未在魔兽世界中在线。"

L["The talents of this profile are different from your current talents."] = "此配置文件的天赋与你当前的天赋不同。"

L["These talents are for %s, switch to that specialization first"] = "这些天赋属于%s，请先切换到该专精"

L["These talents were saved from an older talent tree, check them before applying"] = "这些天赋保存自旧版天赋树，应用前请检查"

L["This profile is no longer shared, link it again."] = "此配置文件已不再分享，请重新链接。"

L["Timed out applying talents"] = "应用天赋超时"

L["Too many saved talent loadouts, delete one first"] = "已保存的天赋配置过多，请先删除一个"

elseif locale == 'zhTW' then
L[" before Import"] = " 匯入前"
L[" during Export"] = " 匯出中"
L[" during Import"] = " 匯入中"
L["[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"] = "[警告] 因未知錯誤忽略插槽 調試信息 = [S=%s T=%s I=%s] 請將匯入文本和調試信息發送至 %s"
L["[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"] = "[警告] 忽略不支援的按鍵綁定 [ %s ] ，請聯繫 %s"
L["[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"] = "[警告] 忽略不支援的插槽類型 [ %s ] ，請聯繫 %s"
L["<- share your profile here"] = "<- 在此分享你的設定檔"
L["All slots were restored"] = "所有插槽已恢復"
L["Allow"] = "允許"
L["Are you SURE to delete '%s'?"] = "你確定要刪除 '%s' 嗎？"
L["Are you SURE to import ?"] = "你確定要匯入嗎？"
L["Backup failed"] = "備份失敗"
L["Bad importing text [CRC32]"] = "無效的匯入文本 [CRC32]"
L["Bad importing text [TEXT]"] = "無效的匯入文本 [TEXT]"
L["Before Last Import"] = "上次匯入前"
L["CLEAR"] = "清除"
L["DANGEROUS"] = "危險"
L["Export"] = "匯出"
L["Feedback"] = "反饋"
L["Force Import"] = "強制匯入"
L["IGNORE"] = "忽略"
L["Ignore missing item [id=%s]"] = "忽略缺失的物品 [id=%s]"
L["Ignore unattained companion [id=%s], %s"] = "忽略未獲得的夥伴 [id=%s], %s"
L["Ignore unattained pet [id=%s]"] = "忽略未獲得的寵物 [id=%s]"
L["Ignore unknown macro [id=%s]"] = "忽略未知的巨集 [id=%s]"
L["Ignore unlearned skill [flyoutid=%s], %s"] = "忽略未學會的技能 [flyoutid=%s], %s"
L["Ignore unlearned skill [id=%s], %s"] = "忽略未學會的技能 [id=%s], %s"
L["Import"] = "匯入"
L["Import is not allowed when you are in combat"] = "戰鬥中無法匯入"
L["Key Binding"] = "按鍵綁定"
L["Macro %s was ignored, check if there is enough space to create"] = "巨集 %s 被忽略，請檢查是否有足夠空間創建"
L["Main Action Bar Page"] = "主快捷列頁面"
L["Minimap Icon"] = "小地圖按鈕"
L["Myslot"] = "快捷列-匯出/匯入"
L["Name of exported text"] = "匯出文本名稱"
L["Open Myslot"] = "開啟快捷列設定檔"
L["Please type %s to confirm"] = "請輸入 %s 以確認"
L["Remove all Key Bindings"] = "移除所有按鍵綁定"
L["Remove all Macros"] = "移除所有巨集"
L["Remove everything in ActionBar"] = "移除快捷列上的所有內容"
L["Rename"] = "重新命名"
L["Skip bad CRC32"] = "跳過無效的 CRC32"
L["Skyriding Bar"] = "飛行欄"
L["Stance Action Bar"] = "姿態快捷列"
L["Starting backup..."] = "正在開始備份..."
L["Time"] = "時間"
L["TOC_NOTES"] = "Myslot 用於在帳號之間傳輸設定。反饋: farmer1992@gmail.com"
L["Too many profiles, please delete before create new one."] = "設定檔過多，請刪除後再創建新的。"
L["Try force importing"] = "嘗試強制匯入"
L["Unsaved"] = "未保存"
L["Use random mount instead of an unattained mount"] = "使用隨機坐騎替代未獲得的坐騎"


L["%s is busy sharing other profiles, try again later."] = "%s 正在分享其他設定檔，請稍後再試。"

L["%s is no longer sharing '%s'."] = "%s 已不再分享'%s'。"

L["%s is offline."] = "%s 已離線。"

L["Addon messages are restricted right now (combat, encounter, Mythic+ or PvP). Try again later."] = "插件訊息目前受到限制（戰鬥、首領戰、傳奇鑰石或PvP）。請稍後再試。"

L["Already requesting '%s' from %s..."] = "已在請求'%s'（來自 %s）..."

L["Apply talents"] = "套用天賦"

L["'Apply talents' can still load it, but talents changed since it was saved: check the loadout in the talent window before clicking 'Apply Changes'."] = "仍可透過'套用天賦'載入，但儲存後天賦已變更：點擊'套用變更'前請在天賦視窗中檢查配置。"

L["Applying..."] = "正在套用..."

L["Backup"] = "備份"

L["Battle.net friend"] = "Battle.net好友"

L["By class"] = "依職業"

L["By date"] = "依日期"

L["By name"] = "依名稱"

L["Click Cast Bindings"] = "點擊施放綁定"

L["Cooldown Manager"] = "技能監控"

L["Copy this string and import it in the talent window"] = "複製此字串並在天賦視窗中匯入"

L["Could not delete %d 'Myslot' talent loadout(s)"] = "無法刪除 %d 個'Myslot'天賦配置"

L["Could not send the request, try again later."] = "無法傳送請求，請稍後再試。"

L["Deleted %d 'Myslot' talent loadout(s)"] = "已刪除 %d 個'Myslot'天賦配置"

L["Deleting %d 'Myslot' talent loadout(s)..."] = "正在刪除 %d 個'Myslot'天賦配置..."

L["Failed to apply talents"] = "套用天賦失敗"

L["Failed to send profile '%s' to %s."] = "傳送設定檔'%s'給 %s 失敗。"

L["Ignore unknown outfit [id=%s, name=%s]"] = "忽略未知的服裝 [id=%s, name=%s]"

L["Import failed"] = "匯入失敗"

L["Importing..."] = "正在匯入..."

L["Kept your text, discarded the received profile '%s'."] = "已保留你的文本，捨棄收到的設定檔'%s'。"

L["Link in chat"] = "分享到對話窗"

L["No response from %s. They may be offline, busy, or not running Myslot."] = "%s 沒有回應。對方可能離線、忙碌或未執行Myslot。"

L["No talent string in this profile"] = "此設定檔中沒有天賦字串"

L["Nothing to import"] = "沒有可匯入的內容"

L["Nothing to share, save the profile first"] = "沒有可分享的內容，請先儲存設定檔"

L["Only my class"] = "僅限我的職業"

L["Post a link to the selected profile in chat. Other Myslot users can click it to get a copy."] = "在聊天中發佈所選設定檔的連結。其他Myslot使用者點擊即可取得副本。"

L["Received a damaged profile from %s."] = "收到來自 %s 的損壞設定檔。"

L["Received profile '%s' from %s. Review it, then click Import to apply."] = "已收到設定檔'%s'（來自 %s）。檢查後點擊'匯入'即可套用。"

L["Remove all Click Cast Bindings"] = "移除所有點擊施放綁定"

L["Remove all Cooldown Manager"] = "移除所有技能監控設定"

L["Remove 'Myslot' talent loadouts"] = "移除'Myslot'天賦配置"

L["Replace the unsaved text with the received profile '%s'? Your unsaved changes will be lost."] = "用收到的設定檔'%s'取代未儲存的文本？未儲存的變更將會遺失。"

L["Requesting profile '%s' from %s..."] = "正在請求設定檔'%s'（來自 %s）..."

L["Save the profile before sharing it."] = "分享前請先儲存設定檔。"

L["Save the talents of this profile as the talent loadout 'Myslot', replacing the previous one, and open it in the talent window. Click 'Apply Changes' there to use it."] = "將此設定檔的天賦儲存為天賦配置'Myslot'（取代先前的配置），並在天賦視窗中開啟。在那裡點擊'套用變更'即可使用。"

L["Save your changes before sharing, only saved profiles can be shared."] = "分享前請儲存變更，只能分享已儲存的設定檔。"

L["Select a profile"] = "選擇設定檔"

L["Select a saved profile to share it."] = "選擇一個已儲存的設定檔進行分享。"

L["Sending profile '%s' to %s..."] = "正在傳送設定檔'%s'給 %s..."

L["Sort by"] = "分類方式"

L["Stopped sending a shared profile."] = "已停止傳送分享的設定檔。"

L["Talent loadout 'Myslot' is ready, click 'Apply Changes' in the talent window to use it"] = "天賦配置'Myslot'已就緒，在天賦視窗中點擊'套用變更'即可使用"

L["Talent loadouts are not supported by this game version"] = "此遊戲版本不支援天賦配置"

L["Talents are already being applied"] = "天賦正在套用中"

L["Talents cannot be changed in combat"] = "戰鬥中無法變更天賦"

L["Talents differ"] = "天賦不同"

L["Talents for another spec"] = "其他專精的天賦"

L["Talents match"] = "天賦一致"

L["Talents out of date"] = "天賦已過時"

L["That Battle.net friend is not online in World of Warcraft."] = "該Battle.net好友未在魔獸世界中上線。"

L["The talents of this profile are different from your current talents."] = "此設定檔的天賦與你目前的天賦不同。"

L["These talents are for %s, switch to that specialization first"] = "這些天賦屬於%s，請先切換到該專精"

L["These talents were saved from an older talent tree, check them before applying"] = "這些天賦儲存自舊版天賦樹，套用前請檢查"

L["This profile is no longer shared, link it again."] = "此設定檔已不再分享，請重新連結。"

L["Timed out applying talents"] = "套用天賦逾時"

L["Too many saved talent loadouts, delete one first"] = "已儲存的天賦配置過多，請先刪除一個"

end
