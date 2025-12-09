script_name("Simple Tracker")
script_author("Ryu S. Yamaguchi (Discord: ryu.sql)")
script_version("1.4")

local success, sampev = pcall(require, "samp.events")
if not success then
    print("Failed to load samp.events library")
    return
end

local filePath = string.format('%s\\config\\tracker_stats.json', getWorkingDirectory())

local stats = {
    findCount = 0,
    fishCount = 0,
    truckerCount = 0,
    materialsCount = 0,
    garbageCount = 0,
    carsCount = 0,
    farmingCount = 0,
    newbCount = 0
}

local function repairTable(target, default)
    for k, v in pairs(default) do
        if type(v) == "table" then
            if type(target[k]) ~= "table" then target[k] = {} end
            repairTable(target[k], v)
        else
            if target[k] == nil then target[k] = v end
        end
    end
end

local function loadJson(defaultTable)
    local file = io.open(filePath, "r")
    local tbl

    if not file then
        tbl = defaultTable
    else
        local content = file:read("*a")
        file:close()
        local ok, data = pcall(decodeJson, content)
        tbl = (ok and type(data) == "table") and data or defaultTable
    end

    repairTable(tbl, defaultTable)
    return tbl
end

stats = loadJson(stats)

function main()
    repeat wait(0) until isSampAvailable()
    sampAddChatMessage("{00FF00}[ Simple Tracker ] {FFFFFF}: Made by: {AA0000}Ryu S. Yamaguchi{FFFFFF} | Use {66CCFF}(/trackhelp){FFFFFF} for commands.", -1)
end

local function sanitizeMessage(text)
    return text:gsub("{.-}", ""):gsub("%c", ""):match("^%s*(.-)%s*$")
end

-- SERVER MESSAGE DETECTIONS
function sampev.onServerMessage(color, text)
    local clean = sanitizeMessage(text)

    -- FIND
    if clean:match("has been last seen at") or clean:match("SMS: I need the where%-abouts of") then
        stats.findCount = stats.findCount + 1
        local file = io.open(filePath, "w")
        if file then file:write(encodeJson(stats)) file:close() end
        sampAddChatMessage(string.format("{00FF00}[Simple Tracker]: {FFFFFF}Successful find! Total: {00FF00}%d", stats.findCount), -1)
    end

    -- FISH
    if clean:match("You have caught a") and clean:match("weighing") then
        stats.fishCount = stats.fishCount + 1
        local file = io.open(filePath, "w")
        if file then file:write(encodeJson(stats)) file:close() end
        sampAddChatMessage(string.format("{00FF00}[Simple Tracker]: {FFFFFF}Caught a fish! Total: {00FF00}%d", stats.fishCount), -1)
    end

    -- TRUCKER
    if clean:match("You were paid %$.- for delivering the goods and returning the truck") then
        stats.truckerCount = stats.truckerCount + 1
        local file = io.open(filePath, "w")
        if file then file:write(encodeJson(stats)) file:close() end
        sampAddChatMessage(string.format("{00FF00}[Simple Tracker]: {FFFFFF}Goods delivered! Total: {00FF00}%d", stats.truckerCount), -1)
    end

    -- MATERIALS
    if clean:match("The factory gave you .- materials for your delivery") then
        stats.materialsCount = stats.materialsCount + 1
        local file = io.open(filePath, "w")
        if file then file:write(encodeJson(stats)) file:close() end
        sampAddChatMessage(string.format("{00FF00}[Simple Tracker]: {FFFFFF}Materials delivered! Total: {00FF00}%d", stats.materialsCount), -1)
    end

    -- GARBAGE
    if clean:match("You have been paid %$1,300 for picking up the garbage and returning the garbage truck") then
        stats.garbageCount = stats.garbageCount + 1
        local file = io.open(filePath, "w")
        if file then file:write(encodeJson(stats)) file:close() end
        sampAddChatMessage(string.format("{00FF00}[Simple Tracker]: {FFFFFF}Garbage delivered! Total: {00FF00}%d", stats.garbageCount), -1)
    end

    -- SELLING CARS
    if clean:match("You sold a car for %$.-, your reload time is .- minutes") then
        stats.carsCount = stats.carsCount + 1
        local file = io.open(filePath, "w")
        if file then file:write(encodeJson(stats)) file:close() end
        sampAddChatMessage(string.format("{00FF00}[Simple Tracker]: {FFFFFF}Sold a car! Total: {00FF00}%d", stats.carsCount), -1)
    end

    -- FARMING / HARVEST
    if clean:match("You received %$.- for delivering the harvest") then
        stats.farmingCount = stats.farmingCount + 1
        local file = io.open(filePath, "w")
        if file then file:write(encodeJson(stats)) file:close() end
        sampAddChatMessage(string.format("{00FF00}[Simple Tracker]: {FFFFFF}Harvest delivered! Total: {00FF00}%d", stats.farmingCount), -1)
    end
end

-- NEWB / N REPLY COUNTER
function sampev.onSendCommand(cmd)
    local msg = cmd:match("^/newb%s+(.+)") or cmd:match("^/n%s+(.+)")
    if not msg then return end

    local letters = msg:gsub("%s+", "")
    local count = #letters
    local min_required = 10

    if count >= min_required then
        stats.newbCount = stats.newbCount + 1
        local file = io.open(filePath, "w")
        if file then file:write(encodeJson(stats)) file:close() end
        sampAddChatMessage(string.format("{00FF00}[Simple Tracker]: {FFFFFF}Newb reply added! Total: {00FF00}%d", stats.newbCount), -1)
    else
        sampAddChatMessage(string.format(
            "{00FF00}[Simple Tracker]: {AA0000}Error!  Reply too short.",
            (min_required - count)
        ), -1)
    end
end

-- COMMANDS
sampRegisterChatCommand("trackhelp", function()
    sampAddChatMessage("{66CCFF}======== [ Simple Tracker Help ] ========", -1)
    sampAddChatMessage("{66CCFF}/trackstats {FFFFFF}- Show your total stats summary.", -1)
    sampAddChatMessage("{66CCFF}/trackreset {FFFFFF}- Reset all stats to 0.", -1)
    sampAddChatMessage("{66CCFF}===================================", -1)
end)

sampRegisterChatCommand("trackstats", function()
    sampAddChatMessage("{66CCFF}======== [ Simple Tracker Stats ] ========", -1)
    sampAddChatMessage(string.format("{66CCFF} || {FFFFFF}Finds: {00FF00}%d", stats.findCount), -1)
    sampAddChatMessage(string.format("{66CCFF} || {FFFFFF}Sold Cars: {00FF00}%d", stats.carsCount), -1)
    sampAddChatMessage(string.format("{66CCFF} || {FFFFFF}Fish Caught: {00FF00}%d", stats.fishCount), -1)
    sampAddChatMessage(string.format("{66CCFF} || {FFFFFF}Goods Delivered: {00FF00}%d", stats.truckerCount), -1)
    sampAddChatMessage(string.format("{66CCFF} || {FFFFFF}Harvest Delivered: {00FF00}%d", stats.farmingCount), -1)
    sampAddChatMessage(string.format("{66CCFF} || {FFFFFF}Garbage Delivered: {00FF00}%d", stats.garbageCount), -1)
    sampAddChatMessage(string.format("{66CCFF} || {FFFFFF}Materials Delivered: {00FF00}%d", stats.materialsCount), -1)
    sampAddChatMessage(string.format("{66CCFF} || {FFFFFF}Newb Replies: {00FF00}%d", stats.newbCount), -1)
    sampAddChatMessage("{66CCFF}===================================", -1)
end)

sampRegisterChatCommand("trackreset", function()
    for k in pairs(stats) do stats[k] = 0 end
    local file = io.open(filePath, "w")
    if file then file:write(encodeJson(stats)) file:close() end
    sampAddChatMessage("{00FF00}[Simple Tracker]: {FFFFFF}All stats reset to {00FF00}0{FFFFFF}.", -1)
end)

function onScriptTerminate(scr)
    if scr ~= thisScript() then return end
    local file = io.open(filePath, "w")
    if file then file:write(encodeJson(stats)) file:close() end
end
