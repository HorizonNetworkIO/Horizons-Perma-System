if SERVER then
    util.AddNetworkString("HZNPerma:Say")
    function HZNPerma:Say(ply, msg)
        net.Start("HZNPerma:Say")
        net.WriteString(msg)
        net.Send(ply)
    end
else
    net.Receive("HZNPerma:Say", function()
        local msg = net.ReadString()
        
        chat.AddText(Color(199, 112, 46), "[Perma] ", Color(255, 255, 255), msg)
    end)
end