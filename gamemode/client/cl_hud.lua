surface.CreateFont( "BSHUDFont1", { font = "Trebuchet MS", size = 34, weight = 100, antialias = true } )
surface.CreateFont( "BSHUDFont2", { font = "Trebuchet MS", size = 20, weight = 100, antialias = true } )
surface.CreateFont( "BSHUDFont3", { font = "Trebuchet MS", size = 18, weight = 100, antialias = true } )
surface.CreateFont( "BSHUDFontEpic", { font = "Trebuchet MS", size = 74, weight = 100, antialias = true } )

CurrentActiveRound = {
    Name = "Warm Up",
    Objective = "Get ready and limbered up for the big game night",
    TimeLeft = -1,
    Score = -1,
}

net.Receive( "BS_SendRoundInfo", function() 
    local name = net.ReadString()
    local objective = net.ReadString()
    local mutators = util.JSONToTable( net.ReadString() )
    local timeleft = net.ReadFloat()
    local scoreleft = net.ReadFloat()

    CurrentActiveRound = {
        Name = name,
        Objective = objective,
        TimeLeft = CurTime() + timeleft,
        Score = scoreleft,
    }

end )

local announcetext = ""
local announcetime = 0
net.Receive( "BS_SendAnnounce", function() 
    local txt = net.ReadString()
    announcetext = txt
    announcetime = CurTime() + 5
end )

function GM:HUDShouldDraw( name )
    local donotdraw = 
    { 
    
    "CHudHealth",
    "CHudAmmo",
    "CHudSecondaryAmmo",
    "CHudBattery",
    "CHudDeathNotice",
    }
    
    for k, v in pairs( donotdraw ) do
        if( name == v ) then return false end
    end
    
    return true
end


function GM:DrawDeathNotice( x, y ) return end

local killfeed = {}
    
net.Receive( "BS_Killfeed", function( len )
    local ded, atk, modstr, points = net.ReadEntity(), net.ReadEntity(), net.ReadString(), net.ReadUInt( 16 )
    if !atk:IsValid() then
        table.insert( killfeed, { p1 = { name = ded:Nick(), col = team.GetColor( ded:Team() )}, trap = true, time = CurTime() + 10 } )
        return
    elseif ded == atk then
        table.insert( killfeed, { p1 = { name = ded:Nick(), col = team.GetColor( ded:Team() )}, suicide = true, time = CurTime() + 10 } )
        return
    end
    if atk == LocalPlayer() and math.random( 1, 2 ) == 1 then surface.PlaySound( "bloodsport/crowdroar1.wav" )  end
    table.insert( killfeed, { p1 = { name = atk:Nick(), col = team.GetColor( atk:Team() )}, p2 = { name = ded:Nick(), col = team.GetColor( ded:Team() ) }, mid = " killed ", mods = modstr, pts = points, time = CurTime() + 10 } )
end)


local function DrawSimpleShadowText( txt, font, x, y, col, alignx, aligny, shadowlen )
    draw.SimpleText( txt, font, x + shadowlen, y + shadowlen, Color( 0, 0, 0, 150 ), alignx, aligny )
    local nx, ny = draw.SimpleText( txt, font, x, y, col, alignx, aligny )
    return nx, ny
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
--    local beat = math.abs( math.sin( CurTime() * 1 ) * 5 )
    local beat = 15
    if damageflash > 0 or me:Health() < 30 then
        beat = beat - math.random( 0, 15 )
    end


    local beat2 = math.abs( math.sin( CurTime() * 5 ) * 5 )
    local hudc1 = Color( 205, 205, 255, 10 + beat )
    local hudc2 = Color(205,205,255, 155)
    local shadowc = Color(0,0,0, 150)

    if !me:Alive() then
        surface.SetDrawColor( Color( 205, 205, 255, 10 + beat ) )
        surface.SetMaterial( skull )
        surface.DrawTexturedRect( (scrw / 2) - 400, (scrh / 2) - 400, 800, 800 )
        surface.SetDrawColor( Color( 205, 0, 0, beat2 * 10 ) )
        surface.DrawTexturedRect( (scrw / 2) - 400 - (beat2 * 2), (scrh / 2) - 400 - (beat2 * 4), 800 + (beat2 * 4), 800 + (beat2 * 8) + math.random( 0, 1 ) * 50 )
        DrawJitterText1( "[RDVITAL] CRITICAL MODULE FAILURE", scrw / 2, scrh / 2, Color( 205, 0, 0, 205 ) )
        DrawJitterText1( "ERRORCODE: UDED", scrw / 2, (scrh / 2) + 25, Color( 205, 0, 0, 205 ) )
        DrawJitterText1( "0x0W4S73D", scrw / 2, (scrh / 2) + 50, Color( 205, 0, 0, 205 ) )

        return
    end

    local x, y = 60 + hor, scrh - 120 + ver
    local x2, y2 = scrw - 360 + hor, scrh - 120 + ver
    local x3, y3 = (scrw / 2) + hor, 30 + ver

    -- left side boxes
    surface.SetDrawColor( hudc1 )
    surface.DrawRect( x, y, 300, 50 )
    surface.DrawRect( x + 150, y, 5, 50 )
    surface.DrawRect( x, y + 55, 300, 5 )
    surface.DrawRect( x, y + 65, 300, 5 )

    -- right side boxes
    surface.DrawRect( x2, y2, 300, 50 )
    surface.DrawRect( x2 + 150, y2, 5, 50 )

    surface.DrawRect( x2, y2 + 55, 300, 5 )

    -- right side text
    draw.SimpleText( "HP: "..me:Health().."%", "BSHUDFont1", x + 9, y + 8, shadowc, 0, 0 ) -- shadow
    draw.SimpleText( "HP: "..me:Health().."%", "BSHUDFont1", x + 8, y + 7, hudc2, 0, 0 )
    draw.SimpleText( "AP: "..me:Armor().."%", "BSHUDFont1", x + 166, y + 8, shadowc, 0, 0 ) -- shadow
    draw.SimpleText( "AP: "..me:Armor().."%", "BSHUDFont1", x + 165, y + 7, hudc2, 0, 0 )

    surface.SetDrawColor( hudc1 )
    surface.DrawRect( x, y - 35, 300, 5 )

    local mypts = me:GetNWInt( "BS_Score", 0 )

    draw.SimpleText( "POINTS: "..mypts, "BSHUDFont2", x + 1, y - 27, shadowc, 0, 0 ) -- shadow
    draw.SimpleText( "POINTS: "..mypts, "BSHUDFont2", x, y - 28, hudc2, 0, 0 )
    draw.SimpleText( "CASH: $0", "BSHUDFont2", x + 301, y - 27, shadowc, 2, 0 ) -- shadow
    draw.SimpleText( "CASH: $0", "BSHUDFont2", x + 300, y - 28, hudc2, 2, 0 )

    -- left side text

    local gun = me:GetActiveWeapon()
    local mag = -1
    local gunname = "Unarmed"
    if gun and gun:IsValid() then
        mag = 100
        gunname = gun:GetPrintName()
    end
    if mag == -1 then mag = "N/A" end

    draw.SimpleText( "AMMO: "..mag, "BSHUDFont2", x2 + 74, y2 + 13, shadowc, 1, 0 ) -- shadow
    draw.SimpleText( "AMMO: "..mag, "BSHUDFont2", x2 + 73, y2 + 12, hudc2, 1, 0 )

    draw.SimpleText( gunname, "BSHUDFont2", x2 + 225, y2 + 13, shadowc, 1, 0 ) -- shadow
    draw.SimpleText( gunname, "BSHUDFont2", x2 + 224, y2 + 12, hudc2, 1, 0 )

    -- left side bars
    surface.SetDrawColor( hudc1 )
    surface.DrawRect( x, y + 55, math.Clamp( 3 * me:Health(), 0, 300 ), 5 )
    surface.DrawRect( x, y + 65, math.Clamp( 3 * me:Armor(), 0, 300 ), 5 )

    if damageflash > 0 then
        surface.SetDrawColor( Color( 205, 0, 0, (10 + beat + (beat2 * 5)) * damageflash + 50 ) )
        surface.DrawRect( x - (beat * 5), y - (beat * 5), 300 + (beat * 10), 70 + (beat * 10) )
        damageflash = damageflash - 0.04
    end

    if me:Health() < 30 then
        surface.SetDrawColor( Color( 205, 0, 0, (10 + beat + (beat2 * 5)) ) )
        local flic = math.random( 0, 5 )
        surface.DrawRect( x - flic, y - flic, 300 + (flic * 2), 50 + (flic * 2) )
    end

    if me:GetNWBool( "X2Combo" ) then
        local oflash = math.abs( math.sin( CurTime() * 5 ) )
        DrawSimpleShadowText( "x2", "BSHUDFont1", x, y - 70, Color( 100 + (oflash * 150), oflash * 100, oflash * 50 ), 0, 0, 1 )
    end


    -- killfeed


    local x, y = 60 + hor, 30 + ver
    local i = 0
    for k, v in pairs( killfeed ) do

        local gay = DrawSimpleShadowText( v.p1.name, "BSHUDFont2", x + 4, y + 2 + i, v.p1.col, 0, 0, 1 )

        if v.suicide or v.trap then
            local gay2 = 0
            if v.trap then
                gay2 = DrawSimpleShadowText( " died to a trap", "BSHUDFont2", x + 5 + gay, y + 2 + i, hudc2, 0, 0, 1 )
            else
                gay2 = DrawSimpleShadowText( " killed himself like an idiot", "BSHUDFont2", x + 5 + gay, y + 2 + i, hudc2, 0, 0, 1 )
            end
            surface.SetDrawColor( hudc1 )
            surface.DrawRect( x, y + 25 + i, (8 + gay + gay2) * (v.time - CurTime()) / 10, 2 )
            local ttr = ((v.time - 9.5) - CurTime()) * 2
            if ttr > 0 then
                surface.DrawRect( x, y + i, (8 + gay + gay2) * ttr, 25 )
            end
            if (v.time - 9.5) - CurTime() > 0 then
                surface.SetDrawColor( Color( 205, 0, 0, (10 + beat + (beat2 * 5)) ) )
                local flic = math.random( 0, 5 )
                surface.DrawRect( x - flic, y + i - flic, 8 + gay + gay2 + (flic * 2), 25 + (flic*2) )
            end

            i = i + 30
            if v.time < CurTime() then table.remove( killfeed, k ) end
            continue
        end

        local gay2 = DrawSimpleShadowText( v.mid, "BSHUDFont2", x + 5 + gay, y + 2 + i, hudc2, 0, 0, 1 )
        local gay3 = DrawSimpleShadowText( v.p2.name, "BSHUDFont2", x + 6 + gay + gay2, y + 2 + i, v.p2.col, 0, 0, 1 )
        local gay4 = DrawSimpleShadowText( v.mods, "BSHUDFont2", x + 7 + gay + gay2 + gay3, y + 2 + i, hudc2, 0, 0, 1 )
        local gay5 = DrawSimpleShadowText( "+"..v.pts, "BSHUDFont2", x + 12 + gay + gay2 + gay3 + gay4, y + 2 + i, Color( 200, 255, 200 ), 0, 0, 1 )

        surface.SetDrawColor( hudc1 )
        surface.DrawRect( x, y + 25 + i, (8 + gay + gay2 + gay3 + gay4 + gay5) * (v.time - CurTime()) / 10, 2 )
        local ttr = ((v.time - 9.5) - CurTime()) * 2
        if ttr > 0 then
            surface.DrawRect( x, y + i, (8 + gay + gay2 + gay3 + gay4 + gay5) * ttr, 25 )
        end
        if (v.time - 9.5) - CurTime() > 0 then
            surface.SetDrawColor( Color( 205, 0, 0, (10 + beat + (beat2 * 5)) ) )
            local flic = math.random( 0, 5 )
            surface.DrawRect( x - flic, y + i - flic, 8 + gay + gay2 + gay3 + gay4 + gay5 + (flic * 2), 25 + (flic*2) )
        end

        i = i + 30
        if v.time < CurTime() then table.remove( killfeed, k ) end
    end

    local highscore = 0
    local matchleader = me

    for k, v in pairs( player.GetAll() ) do
        if !v:IsValid() then continue end
        local pscore = v:GetNWInt( "BS_Score", 0 ) -- 2 birds, 1 stone
        if pscore > highscore then matchleader = v highscore = pscore end

        if !v:Alive() then continue end
        if v:GetPos():Distance( me:GetPos() ) > 3000 then continue end
        local scrl = v:GetPos():ToScreen()
        if ( scrl.x < 2 or scrl.x > (ScrW() - 2) ) or ( scrl.y < 2 or scrl.y > (ScrH() - 2) ) then continue end
        local trr = util.TraceLine( {start = EyePos(),  endpos = v:GetPos() + Vector( 0, 0, 50 ), filter = {me, v} } )
        if trr.Hit then continue end
        
        local scpos = (v:GetPos() + Vector( 0, 0, 80 )):ToScreen()
        local x, y = scpos.x, scpos.y

        y = y - (v:GetPos():Distance( me:GetPos() ) / 100)
        local gey = DrawSimpleShadowText( v:Nick(), "BSHUDFont2", x, y, team.GetColor( v:Team() ), 1, 0, 1 )
        surface.SetDrawColor( hudc1 )
        surface.DrawRect( x - (gey / 2), y + 22, gey, 2 )
        surface.DrawRect( x - (gey / 2), y, gey, 2 )
    end

    -- overhead round info box
    local x, y = scrw / 2 + hor, 8 + ver


    if CurrentActiveRound.Score > 0 then
        local pww = DrawSimpleShadowText( "MATCH LEADER: "..matchleader:Nick().." with "..highscore.." pts", "BSHUDFont2", x, y + 10, team.GetColor( matchleader:Team() ), 1, 0, 1 )
        surface.SetDrawColor( hudc1 )
        surface.DrawRect( x - ( pww / 2 ), y + 35, pww, 2 )
    end

    DrawSimpleShadowText( "Round Type: "..CurrentActiveRound.Name, "BSHUDFont2", x, y + 40, hudc2, 1, 0, 1 )
    local hudc2t = Color( hudc2.r, hudc2.g, hudc2.b, 80 )

    DrawSimpleShadowText( "Objective: "..CurrentActiveRound.Objective, "BSHUDFont3", x, y + 60, hudc2t, 1, 0, 1 )
    if CurrentActiveRound.TimeLeft > CurTime() then DrawSimpleShadowText( "Time Left: "..math.ceil( CurrentActiveRound.TimeLeft - CurTime() ).." seconds", "BSHUDFont3", x, y + 75, Color( hudc2.r, hudc2.g + 30, hudc2.b, 80 ), 1, 0, 1 ) end
    if CurrentActiveRound.Score > 0 then DrawSimpleShadowText( "Score to Win: "..CurrentActiveRound.Score, "BSHUDFont3", x, y + 90, Color( hudc2.r + 30, hudc2.g, hudc2.b, 80 ), 1, 0, 1 ) end

    if announcetime >= CurTime() then
        local x, y = scrw / 2 + hor, scrh / 2 + ver
        local wang = DrawSimpleShadowText( announcetext, "BSHUDFontEpic", x, y - 100, Color(205,205,255, 55), 1, 0, 1 )
        DrawSimpleShadowText( announcetext, "BSHUDFontEpic", x + math.random( -2, 2 ), y - 100 + math.random( -2, 2 ), Color(205,205,255, 55), 1, 0, 1 )
        surface.SetDrawColor( hudc1 )
        surface.DrawRect( x - (wang / 2), y - 30, wang, 2 )
        surface.DrawRect( x - (wang / 2) + math.random( -2, 2 ), y - 30 + math.random( -2, 2 ), wang, 2 + math.random( -2, 2 ) )
    end

end)
