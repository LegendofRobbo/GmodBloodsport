surface.CreateFont( "BSHUDFont1", { font = "Trebuchet MS", size = 34, weight = 100, antialias = true } )
surface.CreateFont( "BSHUDFont2", { font = "Trebuchet MS", size = 20, weight = 100, antialias = true } )

function GM:HUDShouldDraw( name )
    local donotdraw = 
    { 
    
    "CHudHealth",
    "CHudAmmo",
    "CHudSecondaryAmmo",
    "CHudBattery",
--  "CHudChat"
    
    }
    
    for k, v in pairs( donotdraw ) do
        if( name == v ) then return false end
    end
    
    return true
end


local function DrawJitterText1( tx, x, y, col )
    draw.SimpleText( tx, "BSHUDFont2", x, y, col, 1, 0 )
    draw.SimpleText( tx, "BSHUDFont2", x + math.random( -2, 2 ), y + math.random( -2, 2 ), col, 1, 0 )
end

local skull = Material( "legendofrobbo/bloodsport/bigskull.png", "Smooth" )


local damageflash = 0
net.Receive( "DamageFlashes", function() 
    damageflash = 1
end)

hook.Add( "HUDPaint", "MainHUD", function()
    local me = LocalPlayer()
    if !me:IsValid() then return end
    local scrw, scrh = ScrW(), ScrH()
    local hor = me:GetVelocity():Dot(me:EyeAngles():Right()) / 100
    local ver = me:GetVelocity():Dot(me:EyeAngles():Forward()) / 80
    hor = math.Clamp( hor, -5, 5 )
    local beat = math.abs( math.sin( CurTime() * 50 ) * 5 )
    local beat2 = math.abs( math.sin( CurTime() * 5 ) * 5 )

    if !me:Alive() then
        surface.SetDrawColor( Color( 205, 205, 255, 10 + beat ) )
        surface.SetMaterial( skull )
        surface.DrawTexturedRect( (scrw / 2) - 350, (scrh / 2) - 400, 700, 800 )
        surface.SetDrawColor( Color( 205, 0, 0, beat2 * 10 ) )
        surface.DrawTexturedRect( (scrw / 2) - 350 - (beat2 * 2), (scrh / 2) - 400 - (beat2 * 4), 700 + (beat2 * 4), 800 + (beat2 * 8) + math.random( 0, 1 ) * 50 )
        DrawJitterText1( "[RDVITAL] CRITICAL MODULE FAILURE", scrw / 2, scrh / 2, Color( 205, 0, 0, 205 ) )
        DrawJitterText1( "ERRORCODE: UDED", scrw / 2, (scrh / 2) + 25, Color( 205, 0, 0, 205 ) )
        DrawJitterText1( "0x0W4S73D", scrw / 2, (scrh / 2) + 50, Color( 205, 0, 0, 205 ) )

        return
    end

    local x, y = 60 + hor, scrh - 120 + ver
    local x2, y2 = scrw - 360 + hor, scrh - 120 + ver
    local x3, y3 = (scrw / 2) + hor, 30 + ver

    -- left side boxes
    surface.SetDrawColor( Color( 205, 205, 255, 10 + beat ) )
    surface.DrawRect( x, y, 300, 50 )
    surface.DrawRect( x + 150, y, 5, 50 )
    surface.DrawRect( x, y + 55, 300, 5 )
    surface.DrawRect( x, y + 65, 300, 5 )

    -- right side boxes
    surface.DrawRect( x2, y2, 300, 50 )
    surface.DrawRect( x2 + 150, y2, 5, 50 )

    surface.DrawRect( x2, y2 + 55, 300, 5 )

    -- right side text
    draw.SimpleText( "HP: "..me:Health().."%", "BSHUDFont1", x + 9, y + 8, Color(205,205,255, 155), 0, 0 ) -- shadow
    draw.SimpleText( "HP: "..me:Health().."%", "BSHUDFont1", x + 8, y + 7, Color(205,205,255, 155), 0, 0 )
    draw.SimpleText( "AP: "..me:Armor().."%", "BSHUDFont1", x + 166, y + 8, Color(205,205,255, 155), 0, 0 ) -- shadow
    draw.SimpleText( "AP: "..me:Armor().."%", "BSHUDFont1", x + 165, y + 7, Color(205,205,255, 155), 0, 0 )

    draw.SimpleText( "K/D: 0 - 0", "BSHUDFont2", x, y - 28, Color(205,205,255, 100), 0, 0 )
    draw.SimpleText( "CASH: $0", "BSHUDFont2", x + 300, y - 28, Color(205,205,255, 100), 2, 0 )

    -- left side text

    local gun = me:GetActiveWeapon()
    local mag = -1
    local gunname = "Unarmed"
    if gun and gun:IsValid() then
        mag = 100
        gunname = gun:GetPrintName()
    end
    if mag == -1 then mag = "N/A" end

    draw.SimpleText( "AMMO: "..mag, "BSHUDFont2", x2 + 74, y2 + 13, Color(205,205,255, 155), 1, 0 ) -- shadow
    draw.SimpleText( "AMMO: "..mag, "BSHUDFont2", x2 + 73, y2 + 12, Color(205,205,255, 155), 1, 0 )

    draw.SimpleText( gunname, "BSHUDFont2", x2 + 225, y2 + 13, Color(205,205,255, 155), 1, 0 ) -- shadow
    draw.SimpleText( gunname, "BSHUDFont2", x2 + 224, y2 + 12, Color(205,205,255, 155), 1, 0 )

    -- left side bars
    surface.SetDrawColor( Color( 205, 205, 255, 50 + beat ) )
    surface.DrawRect( x, y + 55, math.Clamp( 3 * me:Health(), 0, 300 ), 5 )
    surface.DrawRect( x, y + 65, math.Clamp( 3 * me:Armor(), 0, 300 ), 5 )

    if damageflash > 0 then
        surface.SetDrawColor( Color( 205, 0, 0, (10 + beat + (beat2 * 5)) * damageflash ) )
        surface.DrawRect( x - (beat * 5), y - (beat * 5), 300 + (beat * 10), 70 + (beat * 10) )
        damageflash = damageflash - 0.04
    end

    if me:Health() < 30 then
        surface.SetDrawColor( Color( 205, 0, 0, (10 + beat + (beat2 * 5)) ) )
        surface.DrawRect( x, y, 300, 50 )
    end


    -- overhead round info box

    surface.SetDrawColor( Color( 205, 205, 255, 10 + beat ) )
    surface.DrawRect( x3 - 150, y3, 300, 50 )
    surface.DrawRect( x3 - 150, y3 - 10, 300, 5 )

    -- mutator boxes
    surface.DrawRect( x3 - 15, y3 + 55, 30, 30 )
    surface.DrawRect( x3 - 50, y3 + 55, 30, 30 )
    surface.DrawRect( x3 + 20, y3 + 55, 30, 30 )

    local roundname = "DEATHMATCH"
--    draw.SimpleText( roundname, "BSHUDFont2", x3, y3 + 2, Color(205,205,255, 155), 1, 0 ) -- shadow
    draw.SimpleText( roundname, "BSHUDFont2", x3, y3 + 1, Color(205,205,255, 155), 1, 0 )

    draw.SimpleText( "Time Remaining: 5:00", "BSHUDFont2", x3, y3 + 21, Color(205,205,255, 155), 1, 0 )

end)