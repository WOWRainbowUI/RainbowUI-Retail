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
L["[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"] = true
L["[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"] = true
L["[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"] = true
L["<- share your profile here"] = true
L["All slots were restored"] = true
L["Allow"] = true
L["Are you SURE to delete '%s'?"] = true
L["Are you SURE to import ?"] = true
L["Backup failed"] = true
L["Bad importing text [CRC32]"] = true
L["Bad importing text [TEXT]"] = true
L["Before Last Import"] = true
L["CLEAR"] = true
L["DANGEROUS"] = true
L["Export"] = true
L["Feedback"] = true
L["Force Import"] = true
L["IGNORE"] = true
L["Ignore missing item [id=%s]"] = true
L["Ignore unattained companion [id=%s], %s"] = true
L["Ignore unattained pet [id=%s]"] = true
L["Ignore unknown macro [id=%s]"] = true
L["Ignore unlearned skill [flyoutid=%s], %s"] = true
L["Ignore unlearned skill [id=%s], %s"] = true
L["Import"] = true
L["Import is not allowed when you are in combat"] = true
L["Key Binding"] = true
L["Macro %s was ignored, check if there is enough space to create"] = true
L["Main Action Bar Page"] = true
L["Minimap Icon"] = true
L["Myslot"] = true
L["Name of exported text"] = true
L["Open Myslot"] = true
L["Please type %s to confirm"] = true
L["Remove all Key Bindings"] = true
L["Remove all Macros"] = true
L["Remove everything in ActionBar"] = true
L["Rename"] = true
L["Skip bad CRC32"] = true
L["Skyriding Bar"] = true
L["Stance Action Bar"] = true
L["Starting backup..."] = true
L["Time"] = true
L["TOC_NOTES"] = "Myslot is for transferring settings between accounts. Feedback farmer1992@gmail.com"
L["Too many profiles, please delete before create new one."] = true
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

end
