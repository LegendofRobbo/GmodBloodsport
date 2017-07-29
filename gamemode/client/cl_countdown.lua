local epoch = 1496962800 + 4492800
// this timer should shut itself down after the competition, rendering this file obsolete
if epoch - os.time() >= 0 then
    hook.Add( "HUDPaint", "FinalCountdown", function()
        local stamp = os.time()
        local curdate = os.date( "%H:%M:%S - %d/%m/%Y" , stamp )
        local epoch = 1496962800 + 4492800
        local epochdate = os.date( "%H:%M:%S - %d/%m/%Y" , epoch )
        local remaining = epoch - stamp
        local fmat = string.FormattedTime( remaining ) 

        local x, y = ScrW() - 250, 80

        surface.SetDrawColor( Color( 0, 0, 0, 150 ) )
        surface.DrawRect( x, y, 150, 60 )
        draw.DrawText( "Time: "..curdate, "DermaDefault", x + 4, y, Color(255,255,255, 200) )
        draw.DrawText( "Ends: "..epochdate, "DermaDefault", x + 4, y + 15, Color(255,255,255, 200) )
        draw.DrawText( "Days Left: "..math.Round( fmat.h / 24 ), "DermaDefault", x + 4, y + 30, Color(255,255,205, 200) )
        draw.DrawText( "Hours Left: "..math.Round( fmat.h ), "DermaDefault", x + 4, y + 45, Color(205,205,255, 200) )
    end)
end