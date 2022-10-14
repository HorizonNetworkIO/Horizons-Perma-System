function HZNPerma:CreateTables()
    local query = "CREATE TABLE IF NOT EXISTS `hznperma_data` ( `steamid` VARCHAR(255) NOT NULL, `perma_data` TEXT NOT NULL, PRIMARY KEY (`steamid`) )"
    HZNPerma:QueryDB(query, function()
        HZNPerma:Log("Created tables.")
    end)
end

function HZNPerma:UpdateData(steamid, data, callback)
    local query = "INSERT INTO `hznperma_data` (`steamid`, `perma_data`) VALUES ('" .. steamid .. "', '" .. data .. "') ON DUPLICATE KEY UPDATE `perma_data` = '" .. data .. "'"
    HZNPerma:QueryDB(query, function(as)
        callback()
    end)
end

function HZNPerma:AddPermaToPly(steamid, wep, callback)
    HZNPerma:HasPerma(steamid, wep, function(has)
        if (has) then
            if (callback) then
                callback(false)
            end
            return
        end

        // get player's perma weapons
        HZNPerma:GetPermaData(steamid, function(data)
            local tbl = {
                weapon = wep,
                active = false
            }
            // add weapon to perma weapons
            table.insert(data, tbl)
            data = util.TableToJSON(data)

            // update data
            local query = "INSERT INTO `hznperma_data` (`steamid`, `perma_data`) VALUES ('" .. steamid .. "', '" .. data .. "') ON DUPLICATE KEY UPDATE `perma_data` = '" .. data .. "'"
            HZNPerma:QueryDB(query, function(as)
                HZNPerma:SyncData(steamid)
            end)

            HZNPerma:DeactivateAll(steamid, function()
                HZNPerma:SetActive(steamid, wep, true)
            end)

            local ply = player.GetBySteamID(steamid)
            if (IsValid(ply)) then
                HZNPerma:Say(ply, "You have been given a " .. wep .. "!")
            end

            if (callback) then
                callback(true)
            end
        end)
    end)    
end

function HZNPerma:DeactivateAll(steamid, callback)
    // get player's perma weapons
    HZNPerma:GetPermaData(steamid, function(perma_data)
        // deactivate all weapons
        for k, v in pairs(perma_data) do
            v.active = false
        end

        perma_data = util.TableToJSON(perma_data)
    
        // update data
        HZNPerma:UpdateData(steamid, perma_data, function()
            HZNPerma:SyncData(steamid)
            callback()
        end)

        local ply = player.GetBySteamID(steamid)
        if IsValid(ply) and ply:Alive() then
            for k, v in pairs(ply:GetWeapons()) do
                if v.isPermanent then
                    ply:StripWeapon(v:GetClass())
                end
            end
        end
    end)
end

function HZNPerma:SetActive(steamid, weapon, active, callback)
    // get player's perma weapons
    HZNPerma:GetPermaData(steamid, function(perma_data)
        // set weapon to active
        for k, v in pairs(perma_data) do
            if v.weapon == weapon then
                v.active = active
            end
        end
        perma_data = util.TableToJSON(perma_data)
    
        // update sql data
        local query = "INSERT INTO `hznperma_data` (`steamid`, `perma_data`) VALUES ('" .. steamid .. "', '" .. perma_data .. "') ON DUPLICATE KEY UPDATE `perma_data` = '" .. perma_data .. "'"
        HZNPerma:QueryDB(query, function()
            HZNPerma:SyncData(steamid)
        end)

        local ply = player.GetBySteamID(steamid)
        if IsValid(ply) and ply:Alive() then
            if active then
                local wep = ply:Give(weapon, true)
                if IsValid(wep) then
                    wep.isPermanent = true
                end
            else
                ply:StripWeapon(weapon)
            end
        end
    end)
end

function HZNPerma:GiveLoadout(ply)
    local steamid = ply:SteamID()
    HZNPerma:GetPermaData(steamid, function(perma_data)
        for k, v in pairs(perma_data) do
            if (v.active) then
                local wep = ply:Give(v.weapon)
                if IsValid(wep) then
                    wep.isPermanent = true
                end
            end
        end
    end)
end

function HZNPerma:RemovePermaFromPly(steamid, weapon)
    // get player's perma weapons
    HZNPerma:GetPermaData(steamid, function(perma_data)
        local ind

        // check if weapon is in perma weapons
        for k, v in pairs(perma_data) do
            if v.weapon == weapon then
                ind = k
                break
            end
        end

        if (ind != nil) then
            // remove weapon from perma weapons
            table.remove(perma_data, ind)
            perma_data = util.TableToJSON(perma_data)

            // update sql data
            HZNPerma:UpdateData(steamid, perma_data, function()
                HZNPerma:SyncData(steamid)
            end)

            local ply = player.GetBySteamID(steamid)
            if IsValid(ply) and ply:Alive() then
                ply:StripWeapon(weapon)
            end
        else
            HZNPerma:Log("Weapon " .. weapon .. " not found in " .. steamid)
        end
    end)
end

function HZNPerma:GetPermaData(steamid, callback)
    local query = "SELECT `perma_data` FROM `hznperma_data` WHERE `steamid` = '" .. steamid .. "'"
    HZNPerma:QueryDB(query, function(data)
        if data[1] then
            callback(util.JSONToTable(data[1].perma_data))
        else
            callback({})
        end
    end)
end

function HZNPerma:HasPerma(steamid, weapon, callback)
    HZNPerma:GetPermaData(steamid, function(perma_data)
        // check if weapon is in perma weapons
        for k, v in pairs(perma_data) do
            if v.weapon == weapon then
                callback(true)
                return
            end
        end
        callback(false)
    end)
end

function HZNPerma:QueryDB(query, callback)
    if (not HZNLib.DatabaseConnected) then
        timer.Simple(3, function()
            HZNLib:Query(query, callback)
        end)
        HZNPerma:Log("Couldn't connect to the database! Retrying in 3 seconds...")
        return
    end
    HZNLib:Query(query, callback)
end

hook.Add("HZNLib:DatabaseConnected", "HZNPerma:DBConnect", function()
    HZNPerma:CreateTables()
end)
