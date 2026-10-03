local _, RH = ...
RH.Localisation = setmetatable({ }, {__index=function (t,k) return k end})
local L = RH.Localisation
local locale = GetLocale()


-- enUS / enGB / Default
L = L or {}
L["ADDON_NAME"] = "Random Hearthstone"
L["NO_VALID_CHOSEN"] = "|cff42E400Random Hearthstone|r - No valid toy chosen. Setting macro to use Hearthstone"
L["MACRO_NAME"] = "Random Hearth"
L["RENOWN_LOCKED"] = "Renown locked"
L["THANKS"] = "Thanks for using my addon"
L["DESCRIPTION"] = "Add or remove hearthstone toys from rotation"
L["SELECT_ALL"] = "Select all"
L["DESELECT_ALL"] = "Deselect all"
L["OPT_MACRO_ICON"] = "Macro icon"
L["COV_ONLY"] = "Allow player's current Covenant hearthstone only"
L["DAL_R_CLICK"] = "Cast Dalaran Hearth on macro right click"
L["GAR_M_CLICK"] = "Cast Garrison Hearth on macro middle click"
L["SETUP_1"] = "Setting up Random Hearthstone database."
L["SETUP_2"] = "You can now cast Dalaran hearth with right click, and Garrison hearth with middle mouse button."
L["SETUP_3"] = "These settings can be changed in the options, type /rh"
L["RANDOM"] = "Random"
L["HEARTHSTONE"] = "Hearthstone"
L["MACRO_NOT_FOUND"] = "|cff42E400Random Hearthstone|r - Macro not found, creating macro named '"
L["UPDATE_MACRO_NAME"] = "|cff42E400Random Hearthstone|r - Updating macro name to '"
L["UNIQUE_NAME_ERROR"] = "Macro name in use!\nPlease pick a unique name."
L["OPT_MACRO_NAME"] = "Macro name"
L["LOGIN_MESSAGE"] = "|cff42E400Random Hearthstone|r - Macro name can now be customised. Type /rh to open options."

-- zhCN
if locale == "zhCN" then
	L = L or {}
	L["ADDON_NAME"] = "Random Hearthstone"
	L["NO_VALID_CHOSEN"] = "|cff42E400Random Hearthstone|r - 未选择炉石玩具，宏已设置为使用炉石。"
	L["MACRO_NAME"] = "随机炉石"
	L["RENOWN_LOCKED"] = "盟约未解锁"
	L["THANKS"] = "感谢您使用我的插件"
	L["DESCRIPTION"] = "将炉石玩具添加或移除随机循环"
	L["SELECT_ALL"] = "全部启用"
	L["DESELECT_ALL"] = "全部禁用"
	L["OPT_MACRO_ICON"] = "宏图标"
	L["COV_ONLY"] = "仅限使用玩家当前的盟约炉石"
	L["DAL_R_CLICK"] = "右键点击宏时使用达拉然炉石"
	L["GAR_M_CLICK"] = "中键点击宏时使用要塞炉石"
	L["SETUP_1"] = "正在初始化Random Hearthstone数据库。"
	L["SETUP_2"] = "现在您可以使用右键达拉然炉石，中键要塞炉石。"
	L["SETUP_3"] = "这些设置可以随时通过输入 /rh 进行修改。"
	L["RANDOM"] = "随机"
	L["HEARTHSTONE"] = "炉石"
	L["MACRO_NOT_FOUND"] = "|cff42E400Random Hearthstone|r - 未找到宏，正在创建名为'"
	L["UPDATE_MACRO_NAME"] = "|cff42E400Random Hearthstone|r - 正在将宏名称更新为'"
	L["UNIQUE_NAME_ERROR"] = "宏名称已被占用！\n请选择一个未被使用的名称。"
	L["OPT_MACRO_NAME"] = "宏名字"
	L["LOGIN_MESSAGE"] = "|cff42E400Random Hearthstone|r - 现在可以自定义宏名称了。输入 /rh 打开选项。"
end

-- zhTW
if locale == "zhTW" then
    L = L or {}
    L["ADDON_NAME"] = "隨機爐石"
    L["NO_VALID_CHOSEN"] = "|cff42E400隨機爐石|r - 沒有選擇有效的爐石玩具。 設定巨集來使用爐石玩具"
    L["MACRO_NAME"] = "隨機爐石"
    L["RENOWN_LOCKED"] = "誓盟鎖定"
    L["THANKS"] = "感謝您使用我的插件"
    L["DESCRIPTION"] = "在清單中選擇使用的循環爐石玩具"
    L["SELECT_ALL"] = "全選"
    L["DESELECT_ALL"] = "取消全選"
    L["OPT_MACRO_ICON"] = "巨集圖示"
    L["COV_ONLY"] = "只允許使用當前誓盟的爐石"
    L["DAL_R_CLICK"] = "滑鼠右鍵點擊使用達拉然爐石"
    L["GAR_M_CLICK"] = "滑鼠中鍵點擊使用要塞爐石"
    L["SETUP_1"] = "設定隨機爐石數據庫"
    L["SETUP_2"] = "現在您可以滑鼠右鍵使用達拉然爐石，滑鼠中鍵使用要塞爐石。"
    L["SETUP_3"] = "這些設定可以在選項中更改，請輸入 /rh"
    L["RANDOM"] = "隨機"
    L["HEARTHSTONE"] = "爐石"
    L["MACRO_NOT_FOUND"] = "|cff42E400隨機爐石|r - 未找到巨集，正在建立巨集名為 '"
    L["UPDATE_MACRO_NAME"] = "|cff42E400隨機爐石|r - 更新巨集名為 '"
    L["UNIQUE_NAME_ERROR"] = "使用中的巨集名稱！\n請選擇一個唯一的名字。"
    L["OPT_MACRO_NAME"] = "巨集名字"
end

-- ptBR
if locale == "ptBR" then
    L = L or {}
    L["ADDON_NAME"] = "Pedra de Regresso Instável"
    L["NO_VALID_CHOSEN"] = "|cff42E400Pedra de Regresso Instável|r - Brinquedo inválido. Voltando para Pedra de Regresso padrão."
    L["MACRO_NAME"] = "Pedra Instável"
    L["RENOWN_LOCKED"] = "Renome bloqueado"
    L["THANKS"] = "Obrigado por usar meu addon"
    L["DESCRIPTION"] = "Adiciona ou remove Pedras da rotação"
    L["SELECT_ALL"] = "Marcar tudo"
    L["DESELECT_ALL"] = "Desmarcar tudo"
    L["OPT_MACRO_ICON"] = "Ícone da macro"
    L["COV_ONLY"] = "Permitir apenas Pedra de Regresso do Pacto do jogador"
    L["DAL_R_CLICK"] = "Use a Pedra de Dalaran com botão direito do mouse"
    L["GAR_M_CLICK"] = "Use a Pedra da Guarnição com botão do meio do mouse"
    L["SETUP_1"] = "Configurando o banco de dados da Pedra de Regresso Instável."
    L["SETUP_2"] = "Você pode usar a pedra de Dalaran com o botão direito e a pedra da Guarnição com o botão do meio do mouse."
    L["SETUP_3"] = "Estas configurações podem ser modificadas nas opções, digite /rh."
    L["RANDOM"] = "Instável"
    L["HEARTHSTONE"] = "Pedra de Regresso"
    L["MACRO_NOT_FOUND"] = "|cff42E400Pedra de Regresso Instável|r - Macro não encontrada, criando a macro '"
    L["UPDATE_MACRO_NAME"] = "|cff42E400Pedra de Regresso Instável|r - Atualizando nome da macro para '"
    L["UNIQUE_NAME_ERROR"] = "Nome da macro em uso!\nPor favor escolha um nome diferente."
    L["OPT_MACRO_NAME"] = "Nome da macro"
    L["LOGIN_MESSAGE"] = "|cff42E400Pedra de Regresso Instável|r - Nome da macro pode ser customizada. Digite /rh para as opções."
end
