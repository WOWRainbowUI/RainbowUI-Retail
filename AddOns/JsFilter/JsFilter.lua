--默认需要添加的语言过滤. 去掉注释就是打开.
--有些语言你发现你已经去掉了注释,但是过滤器不显示,或者过滤器里没有你设置的这个语言,那就说明你当前的客户端默认的过滤器已经有这个语言过滤了.不需要再次添加
--比如你简体客户端,你添加了ruRU,但是过滤器里并不会有俄文. 因为简体客户端已经默认就是自带简体过滤.
local default_filter = 
{
	"zhCN",              --简体中文
	"zhTW",              --繁体中文
	"enUS",              --英文
	--"esES",              --西班牙语
	--"ruRU",              --俄文
	--"koKR",              --韩文
	--"frFR",              --法语
	--"deDE",              --德语
	--"esMX",              --墨西哥
	--"ptBR",              --巴西葡萄牙语
}

local filter = {}

local defaultLanguages = C_LFGList.GetDefaultLanguageSearchFilter()


for i=1, #default_filter do
	if ( not defaultLanguages[default_filter[i]] ) then
		table.insert(filter,default_filter[i])
	end
end
	
C_LFGList.GetAvailableLanguageSearchFilter = function()
	return filter
end

	
	