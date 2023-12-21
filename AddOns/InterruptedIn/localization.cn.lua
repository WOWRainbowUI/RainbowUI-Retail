if GetLocale() ~= "zhCN" then return end

IIN_XCMD_CMDHELP = {
	["TITLE"] = "\124cffFFFF00InterruptedIn\124r 版本:",
	["HELP"] = {
		"\124cff00FF00指令\124r说明:",
		"\124cff00FF00/iin [sec] [%AFGITSPY5-9][%W someone] [words] \124r- 将讯息内容 [words] 加入队列, 等待 [sec] 秒后, 自动选择频道发送讯息.",
		"  %S, %Y, %P, %A, %G, %E, %5-%9: 不自动选择频道, 指定使用 说/大喊/队伍/团队/公会/表情/5-9 频道.",
		"  %I: 不自动选择频道, 指定发送讯息至默认对话窗口.",
		"  %T, %F: 不自动选择频道, 指定发送讯息给 Target/Focus.",
		"  %W: 不自动选择频道, 指定发送讯息给特定人选 [someone].",
		"  ps1:在讯息 [words] 中, 可以使用 %Bx-y 来替换成第x个包包, 第y格物品的连结.",
		"  ps2:在讯息 [words] 中, 可以使用 %L 来替换成拾取窗口中, 第1个顺位的物品.",
		"\124cff00FF00/iin rcd [%AFGIRTSPY5-9][%W someone] 法术1 法术2 ... \124r- 报送法术的CD时间.",
		"  %R: 不自动选择频道, 指定发送讯息至团队队长.",
		"\124cff00FF00/iin [btn:n] start \124r- 启动/停止 先前设定于队列中, 所要发送的讯息.",
		"\124cff00FF00/iin [btn:n] stop \124r- 停止并清除队列中, 所要发送的讯息..",
		"\124cff00FF00/iin [btn:n] nosolo \124r- 自动选择发送频道时, 独自一人时不发话.",
		"\124cff00FF00/iin [btn:n] say \124r- 自动选择发送频道时, 独自一人时使用[说]发话.",
		"\124cff00FF00/iin [btn:n] yell \124r- 自动选择发送频道时, 独自一人时使用[大喊]发话.",
		"\124cff00FF00/iin start \124r- \124cffcc5233必须加此行命令才能执行倒数发话\124r",
		"通用参数 [btn:n] - 以鼠标按键过滤是否执行. n=1为左键, 2为右键, 3为中键, 类推至9.",
	},
}