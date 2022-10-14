local PANEL = {}

local sw = function(v) return (v / 1920) * ScrW() end
local sh = function(v) return (v / 1080) * ScrH() end

local header_size = sh(40)

function PANEL:Init()
    self:SetText("")
end

function PANEL:SetUp()
    self.weapon = HZNPerma.Weapons[self.id]
    if (self.weapon) then
        self.weaponTbl = weapons.Get(self.weapon.weapon)
    end

    self.model = vgui.Create("DModelPanel", self)
    self.model:SetSize(self:GetWide() - sw(10), self:GetTall() - header_size - sw(25))
    self.model:SetPos(sw(5), sh(30))
    self.model:SetFOV(50)
    self.model:SetCamPos(Vector(0, 40, 10))
    self.model:SetLookAt(Vector(0, 0, 2))
    // can't be clicked on
    self.model:SetMouseInputEnabled(false)

    if (self.weaponTbl) then
        self.model:SetModel(self.weaponTbl.WorldModel)
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, HZNPerma.Colors[2])

    if (self.weaponTbl) then
        // is the text bigger than the box?
        local text = self.weaponTbl.PrintName
        surface.SetFont("HZNPerma:B:20")
        local text_w, text_h = surface.GetTextSize(text)
        if (text_w > w) then
            local xPos = sw(5)

            // sin wave from 5 to text_w
            local intensity = 1
            local range = ((text_w - w) / 2) + sw(10)
            local offset = range * math.sin(RealTime() * intensity)
            draw.SimpleText(text, "HZNPerma:B:20", w/2 + offset, sh(5), HZNPerma.Colors[3], 1)
        else
            draw.SimpleText(text, "HZNPerma:B:20", w / 2, sh(5), HZNPerma.Colors[3], 1)
        end

    end

    if (HZNPerma.Weapons[self.id]) then
        if (HZNPerma.Weapons[self.id].active) then
            draw.TextShadow({
                text = "Active",
                font = "HZNPerma:B:20",
                pos = {w / 2, h - sh(20)},
                color = color_black,
                xalign = 1,
                yalign = 1
            }, 1.4, 245)
            draw.SimpleText("Active", "HZNPerma:B:20", w / 2, h - sh(20), HZNPerma.Colors[5], 1, 1)
        end
    end
end

function PANEL:DoClick()
    if (self.weaponTbl) then
        net.Start("HZNPerma:UseItem")
        net.WriteUInt(self.id, 8)
        net.SendToServer()
    end
end

vgui.Register("HZNPerma:Slot", PANEL, "DButton")