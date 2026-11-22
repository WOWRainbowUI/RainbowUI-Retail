-- Italian localization for Accountant Classic
local L = LibStub("AceLocale-3.0"):NewLocale("Accountant_Classic", "itIT", false)

if not L then return end

-- Amount string for CHAT_MESSAGE_MONEY search
L["(%d+) Gold"] = "(%d+) oro"
L["(%d+) Silver"] = "(%d+) argento"
L["(%d+) Copper"] = "(%d+) rame"

-- History ledger
L["Remove, keep history"] = "Rimuovi e conserva la cronologia"
L["Remove with history"] = "Rimuovi insieme alla cronologia"
L["Delete the entire Accountant Classic history ledger of all characters?\nThe classic period data is not affected."] = "Eliminare l'intera cronologia di Accountant Classic di tutti i personaggi?\nI dati per periodo delle statistiche tradizionali non verranno modificati."
L["The history ledger has been deleted."] = "La cronologia è stata eliminata."
L["The history ledger was saved by a newer version of Accountant Classic and is read-only."] = "La cronologia è stata salvata con una versione più recente di Accountant Classic ed è di sola lettura."
L["History matches today's classic data (%d categories)."] = "La cronologia corrisponde ai dati odierni delle statistiche tradizionali (%d categorie)."
L["%d categories differ from today's classic data."] = "%d categorie differiscono dai dati odierni delle statistiche tradizionali."
L["History tracking started today, so money logged earlier today exists only in the classic data."] = "La registrazione della cronologia è iniziata oggi, quindi i movimenti di denaro registrati oggi prima della sua attivazione sono presenti solo nelle statistiche tradizionali."
L["Resetting the Day tab also causes differences; the history ledger is never reset with it."] = "Anche l'azzeramento della scheda del giorno causa differenze; la cronologia non viene mai azzerata insieme a questa scheda."
