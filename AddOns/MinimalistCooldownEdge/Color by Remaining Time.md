Voici un document technique détaillé pour implémenter la gestion des couleurs par seuils (thresholds) dans votre addon **MiniCE**, en extrayant la logique de *PartyTimers*.

L'enjeu principal depuis les récentes mises à jour de WoW (et pour *Midnight*) est de **ne pas déclencher d'erreurs Lua (taint)** lors de la manipulation de cadres protégés, d'où l'utilisation de l'API des "Secret Values".

Voici comment architecturer cette intégration étape par étape de manière totalement sécurisée.

### 1. La fondation : Créer une Courbe de Couleurs Native

Au lieu d'utiliser des conditions manuelles complexes dans une boucle de mise à jour, l'API WoW propose `C_CurveUtil.CreateColorCurve()`. Cela délègue le calcul au moteur du jeu, ce qui est très performant.

**À ajouter dans MiniCE :**

```lua
local colorCurve
local function GetColorCurve()
    if colorCurve then return colorCurve end
    colorCurve = C_CurveUtil.CreateColorCurve()
    colorCurve:SetType(Enum.LuaCurveType.Step) -- "Step" permet des changements nets, sans dégradé
    
    -- Définissez vos seuils ici (ex: Rouge sous 5s, Jaune sous 60s, Blanc au-delà)
    colorCurve:AddPoint(0, CreateColor(1, 0, 0, 1))   -- 0 à 5 secondes
    colorCurve:AddPoint(5, CreateColor(1, 1, 0, 1))   -- 5 à 60 secondes
    colorCurve:AddPoint(60, CreateColor(1, 1, 1, 1))  -- 60+ secondes
    
    return colorCurve
end

```

### 2. Le système de Secours (Fallback) pour les valeurs secrètes

C'est le cœur du contournement légal. Si WoW refuse de vous donner la durée d'un cooldown (parce qu'il appartient à une unité ennemie en PvP par exemple), vous ne devez pas forcer la lecture. Vous devez aller chercher la durée depuis les API de données publiques du jeu (`C_ActionBar`, `C_UnitAuras`, `C_Spell`).

**La fonction d'extraction :**

```lua
local function GetAuraDuration(cooldown)
    local parent = cooldown:GetParent()
    if not parent then return nil end
    
    -- Priorité 1 : Boutons d'action
    local action = parent.action
    if action then
        if parent.chargeCooldown == cooldown then
            return C_ActionBar.GetActionChargeDuration(action)
        end
        return C_ActionBar.GetActionCooldownDuration(action)
    end
    
    -- Priorité 2 : Auras / Buffs
    local auraInstanceID = parent.auraInstanceID
    local unitToken = parent.unitToken or parent.unit or parent.auraDataUnit
    
    -- Chercher dans les parents si non trouvé
    if not (auraInstanceID and unitToken) then
        local grandparent = parent:GetParent()
        if grandparent then
            auraInstanceID = auraInstanceID or grandparent.auraInstanceID
            unitToken = unitToken or grandparent.unitToken or grandparent.unit or grandparent.auraDataUnit
        end
    end
    
    if auraInstanceID and unitToken then
        return C_UnitAuras.GetAuraDuration(unitToken, auraInstanceID)
    end
    
    -- Priorité 3 : Sorts classiques
    local spellID = (type(parent.GetSpellID) == 'function') and parent:GetSpellID() or parent.spellID
    if spellID then
        if parent.chargeCooldown == cooldown then
            return C_Spell.GetSpellChargeDuration(spellID)
        end
        return C_Spell.GetSpellCooldownDuration(spellID)
    end
    
    return nil
end

```

### 3. L'interception sécurisée (Hooks) des Cooldowns

Pour que MiniCE puisse styliser les temps de recharge, vous devez intercepter la création des chronomètres. Il est **crucial** d'utiliser `issecretvalue(cooldown)` en toute première ligne pour avorter si le cadre est strictement interdit.

Ensuite, vous utilisez `canaccessallvalues()` pour vérifier si vous avez le droit de lire le temps. Si oui, vous créez un objet de durée natif. Sinon, vous appelez le *Fallback* créé à l'étape 2.

```lua
-- Table avec clés faibles pour que le ramasse-miettes (Garbage Collector) 
-- nettoie les vieux cadres automatiquement
local cooldownInfo = setmetatable({}, { __mode = "k" })

local function HookCooldownMethods()
    local cooldown_mt = getmetatable(ActionButton1Cooldown).__index
    
    -- Gestionnaire commun
    local function handleCooldown(cooldown, durationObject)
        if issecretvalue(cooldown) then return end
        
        -- Initialiser le cache pour ce cooldown
        if not cooldownInfo[cooldown] then
            cooldownInfo[cooldown] = { 
                cooldown = cooldown,
                textChild = nil -- Dans MiniCE, trouvez et stockez votre FontString ici
            }
        end
        
        -- Trouvez le texte (FontString) si ce n'est pas déjà fait
        if not cooldownInfo[cooldown].textChild then
            local regions = {cooldown:GetRegions()}
            for _, region in ipairs(regions) do
                if region:GetObjectType() == "FontString" then
                    cooldownInfo[cooldown].textChild = region
                    break
                end
            end
        end
        
        if durationObject then
            cooldownInfo[cooldown].durationObject = durationObject
            EnsureTickerRunning() -- Démarre la boucle de mise à jour (voir étape 4)
        end
    end

    hooksecurefunc(cooldown_mt, 'SetCooldown', function(cooldown, start, duration, modRate)
        if issecretvalue(cooldown) then return end
        local durationObject
        if canaccessallvalues(start, duration, modRate) then
            durationObject = C_DurationUtil.CreateDuration()
            durationObject:SetTimeFromEnd(start + duration, duration, modRate or 1)
        else
            durationObject = GetAuraDuration(cooldown)
        end
        handleCooldown(cooldown, durationObject)
    end)

    -- Faites de même pour SetCooldownDuration, SetCooldownFromDurationObject, et SetCooldownFromExpirationTime...
    
    -- N'oubliez pas de nettoyer quand le cooldown disparaît
    hooksecurefunc(cooldown_mt, 'Clear', function(cooldown)
        if issecretvalue(cooldown) then return end
        cooldownInfo[cooldown] = nil
    end)
end

```

### 4. La Boucle de Mise à Jour (Le Ticker)

Enfin, pour appliquer les couleurs en temps réel, vous utilisez un chronomètre (`C_Timer.NewTicker`) qui tourne toutes les 0.1 secondes. Il évalue le temps restant via l'objet de durée et la courbe de couleur.

```lua
local updateTicker
local function UpdateCooldownColors()
    for cooldown, info in pairs(cooldownInfo) do
        if cooldown:IsVisible() and info.durationObject and info.textChild then
            -- Évaluation native de la couleur selon le temps restant
            local color = info.durationObject:EvaluateRemainingDuration(GetColorCurve())
            if color then
                info.textChild:SetTextColor(color:GetRGBA())
            end
        end
    end
end

function EnsureTickerRunning()
    if not updateTicker and next(cooldownInfo) then
        updateTicker = C_Timer.NewTicker(0.1, function()
            if next(cooldownInfo) then
                UpdateCooldownColors()
            else
                -- Arrête proprement le ticker s'il n'y a plus aucun cooldown actif pour économiser le CPU
                if updateTicker then
                    updateTicker:Cancel()
                    updateTicker = nil
                end
            end
        end)
    end
end

```

### En résumé pour MiniCE

Pour intégrer cela dans votre addon existant :

1. Remplacez votre boucle de mise à jour de texte/couleur actuelle par le `C_Timer.NewTicker` couplé à `EvaluateRemainingDuration()`.
2. Assurez-vous que toutes vos interceptions (hooks) de `Cooldown` commencent systématiquement par `if issecretvalue(cooldown) then return end`.
3. Stockez les objets (frames, fontstrings) dans une table avec `__mode = "k"` pour éviter les fuites de mémoire.