local PANEL = {}

local sw = function(v) return (v / 1920) * ScrW() end
local sh = function(v) return (v / 1080) * ScrH() end

local header_size = sh(45)

function PANEL:Init()
    if HZNPerma.Menu then
        HZNPerma.Menu:Remove()
    end
    HZNPerma.Menu = self

    wimg.Register("delete", "https://i.imgur.com/OunTuKU.png")
    self.closeMat = wimg.Create("delete")

    wimg.Register("mp5", "https://i.imgur.com/VE5gcwj.png")
    self.mp5Mat = wimg.Create("mp5")

    wimg.Register("mp5flipped", "https://i.imgur.com/5LduNFe.png")
    self.mp5Matflipped = wimg.Create("mp5flipped")

    self:ShowCloseButton(false)
    self:SetTitle("")
    self:SetDraggable(true)

    self:SetUp()
end

function PANEL:SetUp()
    self:SetSize(sw(670), sh(435))
    self:Center()
    self:MakePopup()

    self.closeBtn = vgui.Create("DButton", self)
    self.closeBtn:SetSize(sh(25), sh(25))
    self.closeBtn:SetPos(self:GetWide() - self.closeBtn:GetWide() - sw(15), header_size/2 - self.closeBtn:GetTall()/2)
    self.closeBtn:SetText("")
    self.closeBtn.Paint = function(s, w, h)
        local col = color_white
        if (s:IsHovered()) then 
            col = HZNPerma.Colors[4]
        end
        self.closeMat(0, 0, w, h, col)
    end
    self.closeBtn.DoClick = function()
        self:Remove()
    end

    self.grid = vgui.Create("HZNPerma:Grid", self)
    self.grid:SetSize(self:GetWide() - sw(20), self:GetTall() - header_size - sw(20))
    self.grid:SetPos(sw(10), header_size + sh(10))
    self.grid:SetUp()
end

local title = "Perma Weapons"
surface.SetFont("HZNPerma:N:35")
local headSize = select(1, surface.GetTextSize(title))

function PANEL:Paint(w, h)
    HZNShadows.BeginShadow( "HZNPerma:Menu2" )
    local x, y = self:LocalToScreen( 0, 0 )

    draw.RoundedBox(4, x, y, w, h, HZNPerma.Colors[1])
    draw.RoundedBoxEx(4, x, y, w,  header_size, HZNPerma.Colors[2], true, true, false, false)
    draw.SimpleText(title, "HZNPerma:N:35", x + w / 2, y + header_size / 2, HZNPerma.Colors[3], 1, 1)

    HZNShadows.EndShadow( "HZNPerma:Menu2", x, y, 2, 2, 1, 255, 0, 1, false )
    self.mp5Mat(w/2-sw(headSize/2 + 30 + 15), header_size/2-sh(30)/2, sw(30), sh(30), HZNPerma.Colors[4])
    self.mp5Matflipped(w/2+sw(headSize/2 + 30 - 15), header_size/2-sh(30)/2, sw(30), sh(30), HZNPerma.Colors[4])
end

vgui.Register("HZNPerma:Frame", PANEL, "DFrame")