HZNPerma.Weapons = {}

net.Receive("HZNPerma:SyncData", function()
    local data = net.ReadTable()
    HZNPerma.Weapons = data
    HZNPerma:Log("Synced Data.")
end)

concommand.Add("hznperma_menu", function()
    vgui.Create("HZNPerma:Frame")
end)