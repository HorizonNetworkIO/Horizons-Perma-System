local PANEL = {}

local sw = function(v) return (v / 1920) * ScrW() end
local sh = function(v) return (v / 1080) * ScrH() end

local header_size = sh(40)

function PANEL:SetUp()
    // scrollable panel
    self.scroll = vgui.Create("DScrollPanel", self)
    self.scroll:Dock(FILL)

    self.grid = vgui.Create("DGrid", self.scroll)
    self.grid:Dock(FILL)
    self.grid:DockMargin(0, 0, 0, 0)
    self.grid:SetCols(5)
    self.grid:SetColWide(sw(132.5))
    self.grid:SetRowHeight(sh(130))
    self.scroll:GetVBar():SetWide(0)

    for i=1, 30 do 
        local slot = vgui.Create("HZNPerma:Slot", self)
        slot:SetSize(sw(120), sh(120))
        slot.id = i
        self.grid:AddItem(slot)
        slot:SetUp()
    end

    self.scroll:AddItem(self.grid)
end

function PANEL:Paint()

end

vgui.Register("HZNPerma:Grid", PANEL, "DPanel")