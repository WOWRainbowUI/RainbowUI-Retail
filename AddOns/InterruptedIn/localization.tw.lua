if GetLocale() ~= "zhTW" then return end

IIN_XCMD_CMDHELP = {
	["TITLE"] = "\124cffFFFF00InterruptedIn\124r 版本:",
	["HELP"] = {
		"\124cff00FF00指令\124r說明:",
		"\124cff00FF00/iin [btn:n] [sec] [%AEFGITSPY5-9][%W someone] [words] \124r- 將訊息內容 [words] 加入佇列, 等待 [sec] 秒後, 自動選擇頻道發送訊息.",
		"  %S, %Y, %P, %A, %G, %E, %5-%9: 不自動選擇頻道, 指定使用 說/大喊/隊伍/團隊/公會/表情/5-9 頻道.",
		"  %I: 不自動選擇頻道, 指定發送訊息至預設對話視窗.",
		"  %T, %F: 不自動選擇頻道, 指定發送訊息給 Target/Focus.",
		"  %W: 不自動選擇頻道, 指定發送訊息給特定人選 [someone].",
		"  ps1:在訊息 [words] 中, 可以使用 %Bx-y 來替換成第x個包包, 第y格物品的連結.",
		"  ps2:在訊息 [words] 中, 可以使用 %L 來替換成拾取視窗中, 第1個順位的物品.",
		"\124cff00FF00/iin [btn:n] rcd [%AEFGIRTSPY5-9][%W someone] 法術1 法術2 ... \124r- 報送法術的CD時間.",
		"  %R: 不自動選擇頻道, 指定發送訊息至團隊隊長.",
		"\124cff00FF00/iin [btn:n] start \124r- 啟動/停止 先前設定於佇列中, 所要發送的訊息.",
		"\124cff00FF00/iin [btn:n] stop \124r- 停止並清除佇列中, 所要發送的訊息..",
		"\124cff00FF00/iin [btn:n] nosolo \124r- 自動選擇發送頻道時, 獨自一人時不發話.",
		"\124cff00FF00/iin [btn:n] say \124r- 自動選擇發送頻道時, 獨自一人時使用[說]發話.",
		"\124cff00FF00/iin [btn:n] yell \124r- 自動選擇發送頻道時, 獨自一人時使用[大喊]發話.",
		"通用參數 [btn:n] - 以滑鼠按鍵過濾是否執行. n=1為左鍵, 2為右鍵, 3為中鍵, 類推至9.",
	},
}