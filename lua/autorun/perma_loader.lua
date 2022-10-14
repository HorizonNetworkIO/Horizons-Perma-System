// Steel's Addon Loader
// Fuck off

local AddonSubFolder = "hznperma"
local AddonName = "Perma"
local AddonColor = Color(204, 59, 170)
local DebugAddon = true

HZNPerma = {}

function HZNPerma:Log(str)
    MsgC(AddonColor, "[" .. AddonName .. "] ", Color(255, 255, 255), str .. "\n")
end

local function loadServerFile(str)
    if CLIENT then return end
    include(str)
    HZNPerma:Log("Loaded Server File " .. str)
end

local function loadClientFile(str)
    if SERVER then AddCSLuaFile(str) return end
    include(str)
    HZNPerma:Log("Loaded Client File " .. str)
end

local function loadSharedFile(str)
    if SERVER then AddCSLuaFile(str) end
    include(str)
    HZNPerma:Log("Loaded Shared File " .. str)
end

local function load()
    local clientFiles = file.Find(AddonSubFolder .. "/cl/*.lua", "LUA")
    local sharedFiles = file.Find(AddonSubFolder .. "/sh/*.lua", "LUA")
    local serverFiles = file.Find(AddonSubFolder .. "/sv/*.lua", "LUA")
    local vguiFiles = file.Find(AddonSubFolder .. "/cl/vgui/*.lua", "LUA")

    for _, file in pairs(clientFiles) do
        loadClientFile(AddonSubFolder .. "/cl/" .. file)
    end

    for _, file in pairs(sharedFiles) do
        loadSharedFile(AddonSubFolder .. "/sh/" .. file)
    end

    for _, file in pairs(serverFiles) do
        loadServerFile(AddonSubFolder .. "/sv/" .. file)
    end

    for _, file in pairs(vguiFiles) do
        loadClientFile(AddonSubFolder .. "/cl/vgui/" .. file)
    end

    HZNPerma:Log("Loaded " .. #clientFiles + #sharedFiles + #serverFiles + #vguiFiles .. " files")

    if (DebugAddon and SERVER) then
        for k,v in ipairs(player.GetAll()) do
            HZNPerma:SyncData(v:SteamID())
        end
    end
end

load()