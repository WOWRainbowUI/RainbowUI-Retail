local AddonName, Addon = ...

Addon.newsList = {
    ['1.4.0'] = {
        title = '1.4.0. Timer bar added',
        text = 'Of course, you can customise this bar.\nTo do so, click on the "Edit Theme" button ("Pencil" in "Settings" window) and find the "Timer Bar" block.\nAnd if you don\'t need this bar, you can hide it altogether. Just click "Eye" in the same block.\n\n\nAnd also was added this window with news about addon :)',
        picture = "Interface\\AddOns\\IPMythicTimer\\media\\news\\1_4_0.png",
    },
    ['1.4.11'] = {
        title = '1.4.11. Farewell!',
        text = 'First of all, I want to thank you for using this addon. It\'s the only thing that gave me the strength to develop it. You are the best! <3\nUnfortunately, I haven\'t played WoW since mid-DF. I don\'t have TWW, and I don\'t plan to play in Midnight. However, I tried to keep the addon working with the PTR. But that\'s no longer possible for Midnight.\nI\'m not sure my addon will work in the future, so I want to thank you and advise you to look for an alternative.\nGoodbye!',
        picture = "Interface\\AddOns\\IPMythicTimer\\media\\news\\1_4_11.png",
    },
}

if GetLocale() == 'ruRU' then
    Addon.newsList['1.4.0'].title = '1.4.0. Добавлена полоса таймера'
    Addon.newsList['1.4.0'].text = 'Разумеется, эту полосу можно настроить.\nДля этого нажмите кнопку "Редактировать тему" ("Карандаш" в окне "Настройки") и найдите блок "Полоса времени".\nА если эта полоса не нужна, то можно её вообще скрыть. Просто нажмите "Глазик" в том же блоке.\n\n\nА ещё добавлено это окно с обзором новинок :)'

    Addon.newsList['1.4.11'].title = '1.4.11. Прощание!'
    Addon.newsList['1.4.11'].text = 'В первую очередь хочу поблагодарить тебя за пользование этим аддоном. Только это придавало мне сил для разработки. Ты лучше всех! <3\nК сожалению, я уже не играю в WoW с середины DF\'а. TWW у меня нет и в Midnight тоже не планирую играть. Тем не менее я старался поддерживать аддон в рабочем состоянии с помощью ПТРа. Но для Midnight уже так не получается.\nЯ не уверен, что мой аддон будет работать в будущем, поэтому хочу поблагодарить тебя и посоветовать искать альтернативу.\nПрощай!'
end
if GetLocale() == 'frFR' then
    Addon.newsList['1.4.0'].title = '1.4.0. La barre de minutage a été ajoutée'
    Addon.newsList['1.4.0'].text = 'Vous pouvez bien entendu personnaliser cette barre.\nPour ce faire, cliquez sur le bouton "Edit Theme" ("Pencil" dans la fenêtre "Settings") et trouvez le bloc "Timer Bar".\nSi vous n\'avez pas besoin de cette barre, vous pouvez la cacher. Il vous suffit de cliquer sur "Eye" dans le même bloc.\n\n\nCette fenêtre d\'information sur l\'addon a également été ajoutée :)'
end

function Addon:ShowNews(news)
    Addon.fNews.title:SetText(news.title)
    Addon.fNews.text:SetText(news.text)
    Addon.fNews.picture:SetTexture(news.picture)
end

function Addon:InitNews()
    local showHelp = false
    if IPMTOptions.news == nil then
        IPMTOptions.news = {}
        Addon:ShowOptions()
        Addon:ShowHelp()
        showHelp = true
    end

    local version = C_AddOns.GetAddOnMetadata(AddonName, 'Version')
    local news = Addon.newsList[version]
    if news ~= nil and IPMTOptions.news[version] == nil then
        IPMTOptions.news[version] = true
        if not showHelp or version == '1.4.0' then -- remove 1.4.0 then
            if Addon.fNews == nil then
                Addon:RenderNews()
            end
            Addon:ShowOptions()
            Addon:ShowNews(news)
        end
    end
end

function Addon:CloseNews()
    Addon.fNews:Hide()
end
