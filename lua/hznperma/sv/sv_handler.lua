util.AddNetworkString("HZNPerma:SyncData")
function HZNPerma:SyncData(steamid)
    local ply = player.GetBySteamID(steamid)
    if (!ply) then return end

    HZNPerma:GetPermaData(steamid, function(permaData)
        net.Start("HZNPerma:SyncData")
        net.WriteTable(permaData)
        net.Send(ply)
    end)
end

hook.Add("HZNLib:FullSpawn", "HZNPerma:FullSpawn", function(ply)
    HZNPerma:SyncData(ply:SteamID())
end)

hook.Add("PlayerLoadout", "HZNPerma:PlayerLoadout", function(ply)
    HZNPerma:GiveLoadout(ply)
end)

hook.Add("PlayerSay", "HZNPerma:PlayerSay", function(ply, text)
    if (string.lower(text) == "!perma" or string.lower(text) == "/text") then
        ply:ConCommand("hznperma_menu")
        return ""
    end
end)

util.AddNetworkString("HZNPerma:UseItem")
net.Receive("HZNPerma:UseItem", function(len, ply)
    if (ply.hznperma_lastuse and ((ply.hznperma_lastuse + 5) > os.time())) then
        HZNPerma:Say(ply, "You can only use an item every 5 seconds.")
        return
    end

    ply.hznperma_lastuse = os.time()

    local item = net.ReadUInt(8)
    local steamid = ply:SteamID()

    HZNPerma:GetPermaData(steamid, function(data)
        local slot = data[item]
        if (!slot) then return end

        local weapon = slot.weapon
        if (!weapon) then return end

        if (slot.active) then
            HZNPerma:SetActive(steamid, weapon, false)
        else
            HZNPerma:DeactivateAll(steamid, function()
                HZNPerma:SetActive(steamid, weapon, true)
            end)
        end
    end)
end)

concommand.Add("hznperma_add", function(ply, cmd, args)
    if (!args[1]) then return end
    if (!args[2]) then return end

    local steamid = args[1]
    local weapon = args[2]
    
    steamid = util.SteamIDFrom64(steamid)

    HZNPerma:AddPermaToPly(steamid, weapon, function(added)
        if (!added) then
            HZNPerma:Log("Failed to add "..weapon.." to "..steamid)
        else
            HZNPerma:Log("Added "..weapon.." to "..steamid)
        end
    end)
end)

concommand.Add("hznperma_remove", function(ply, cmd, args)
    if (!args[1]) then return end
    if (!args[2]) then return end

    local steamid = args[1]
    local weapon = args[2]
    
    steamid = util.SteamIDFrom64(steamid)
    print("Takeing " .. weapon .. " from " .. steamid)

    HZNPerma:RemovePermaFromPly(steamid, weapon)
end)