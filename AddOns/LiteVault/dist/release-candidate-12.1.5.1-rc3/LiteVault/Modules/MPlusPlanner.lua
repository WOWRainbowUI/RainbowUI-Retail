local addonName, lv = ...

lv.MPlusPlanner = lv.MPlusPlanner or {}
local Planner = lv.MPlusPlanner

local BASE_SCORE = {
    [2]=155, [3]=170, [4]=200, [5]=215, [6]=230, [7]=260, [8]=275, [9]=290,
    [10]=320, [11]=335, [12]=365, [13]=380, [14]=395, [15]=410, [16]=425,
    [17]=440, [18]=455, [19]=470, [20]=485,
}

function Planner.EstimateTimedScore(level, durationSec, timeLimit)
    level, durationSec, timeLimit = tonumber(level), tonumber(durationSec), tonumber(timeLimit)
    local base = level and BASE_SCORE[level]
    if not (base and durationSec and timeLimit and timeLimit > 0) or durationSec > timeLimit then return nil end
    local timePercent = math.min((timeLimit - durationSec) / timeLimit, 0.40)
    return base + (timePercent * 37.5)
end

function Planner.NormalizeProjectedScore(score)
    score = tonumber(score)
    return score and math.floor(score + 0.000001) or nil
end

local function FindDisplayScores(...)
    for index=1,select("#", ...) do
        local candidate = select(index, ...)
        if type(candidate) == "table" then
            if type(candidate.displayScores) == "table" then return candidate.displayScores end
            if #candidate > 0 and type(candidate[1]) == "table" then return candidate end
        end
    end
    return {}
end

function Planner.GetCurrentMapPool()
    local pool, scoresByMap = {}, {}
    if C_ChallengeMode and C_ChallengeMode.GetMapScoreInfo then
        local displayScores = FindDisplayScores(C_ChallengeMode.GetMapScoreInfo())
        for _, info in ipairs(displayScores) do
            local mapID = info.mapChallengeModeID or info.challengeMapID
            if mapID then scoresByMap[mapID] = info end
        end
    end
    if not (C_ChallengeMode and C_ChallengeMode.GetMapTable and C_ChallengeMode.GetMapUIInfo) then return pool end
    for _, mapID in ipairs(C_ChallengeMode.GetMapTable() or {}) do
        local name, _, timeLimit, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(mapID)
        if name and tonumber(timeLimit) then
            local scoreInfo = scoresByMap[mapID] or {}
            pool[#pool + 1] = {
                mapChallengeModeID=mapID, name=name, timeLimit=tonumber(timeLimit),
                texture=texture or backgroundTexture, dungeonScore=tonumber(scoreInfo.dungeonScore) or 0,
                level=tonumber(scoreInfo.level), completedInTime=scoreInfo.completedInTime,
            }
        end
    end
    return pool
end

function Planner.GetCurrentOverallScore()
    return C_ChallengeMode and C_ChallengeMode.GetOverallDungeonScore and tonumber(C_ChallengeMode.GetOverallDungeonScore()) or 0
end

local function CopyRoute(route)
    local copy = {}
    for i, entry in ipairs(route or {}) do copy[i] = entry end
    return copy
end

local function RouteMetrics(route, gain, requiredGain)
    local maxKey, sumKeys = 0, 0
    for _, entry in ipairs(route) do maxKey=math.max(maxKey, entry.level); sumKeys=sumKeys+entry.level end
    return {route=route, gain=gain, runCount=#route, maxKey=maxKey, sumKeys=sumKeys, overshoot=math.max(0,gain-requiredGain)}
end

local function IsBetter(a, b, strategy)
    if not b then return true end
    local fields = strategy == "fastest" and {"runCount","maxKey","sumKeys","overshoot"}
        or strategy == "easiest" and {"maxKey","sumKeys","runCount","overshoot"}
        or {"balanceCost","sumKeys","overshoot","runCount"}
    a.balanceCost=a.maxKey+(a.runCount*2); b.balanceCost=b.maxKey+(b.runCount*2)
    for _, field in ipairs(fields) do if a[field] ~= b[field] then return a[field] < b[field] end end
    return false
end

local function BuildCandidates(pool, minimumKey, maximumKey, avoided)
    local groups = {}
    for _, dungeon in ipairs(pool) do
        if not avoided[dungeon.mapChallengeModeID] then
            local choices = {}
            for level=minimumKey,maximumKey do
                local projected = Planner.NormalizeProjectedScore(Planner.EstimateTimedScore(level, dungeon.timeLimit, dungeon.timeLimit))
                local gain = projected and math.max(0, projected - dungeon.dungeonScore) or 0
                if gain > 0 then choices[#choices+1]={dungeon=dungeon,level=level,projectedScore=projected,gain=gain} end
            end
            groups[#groups+1] = choices
        end
    end
    return groups
end

local function Search(groups, requiredGain, strategy)
    local maxSingleGain = 0
    for _, group in ipairs(groups) do for _, choice in ipairs(group) do maxSingleGain=math.max(maxSingleGain,choice.gain) end end
    local cap = requiredGain + maxSingleGain
    local states = {[0]=RouteMetrics({},0,requiredGain)}
    for _, group in ipairs(groups) do
        local nextStates = {}
        for gain, state in pairs(states) do
            local existing = nextStates[gain]
            if IsBetter(state, existing, strategy) then nextStates[gain]=state end
            for _, choice in ipairs(group) do
                local actualGain = gain + choice.gain
                local stateGain = math.min(actualGain, cap)
                local route=CopyRoute(state.route); route[#route+1]=choice
                local candidate=RouteMetrics(route,actualGain,requiredGain)
                if IsBetter(candidate,nextStates[stateGain],strategy) then nextStates[stateGain]=candidate end
            end
        end
        states=nextStates
    end
    local best
    for _, state in pairs(states) do if state.gain >= requiredGain and IsBetter(state,best,strategy) then best=state end end
    return best
end

function Planner.Calculate(targetRating, minimumKey, maximumKey, avoided)
    local current = Planner.GetCurrentOverallScore()
    targetRating, minimumKey, maximumKey = tonumber(targetRating), tonumber(minimumKey), tonumber(maximumKey)
    if not targetRating or targetRating % 1 ~= 0 then return {status="invalidTarget",current=current} end
    if targetRating <= current then return {status="alreadyReached",current=current,target=targetRating} end
    if not minimumKey or minimumKey % 1 ~= 0 or minimumKey < 2 then return {status="invalidMinimum",current=current,target=targetRating} end
    if not maximumKey or maximumKey % 1 ~= 0 or maximumKey < minimumKey or maximumKey > 20 then return {status="invalidMaximum",current=current,target=targetRating} end
    local pool=Planner.GetCurrentMapPool()
    local groups=BuildCandidates(pool,minimumKey,maximumKey,avoided or {})
    local required=targetRating-current
    local maximumGain=0
    for _, group in ipairs(groups) do local best=0; for _, choice in ipairs(group) do best=math.max(best,choice.gain) end; maximumGain=maximumGain+best end
    if maximumGain < required then return {status="unreachable",current=current,target=targetRating,maximumProjected=current+maximumGain,pool=pool} end
    return {status="ok",current=current,target=targetRating,pool=pool,routes={
        fastest=Search(groups,required,"fastest"), balanced=Search(groups,required,"balanced"), easiest=Search(groups,required,"easiest"),
    }}
end

function Planner.RouteSignature(route)
    local parts={}
    for _, entry in ipairs(route or {}) do parts[#parts+1]=entry.dungeon.mapChallengeModeID .. ":" .. entry.level end
    table.sort(parts)
    return table.concat(parts,"|")
end
