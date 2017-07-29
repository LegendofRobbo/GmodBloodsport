local ScoreBoard = {}

local grad = Material( "gui/gradient" )
local upgrad = Material( "gui/gradient_up" )
local downgrad = Material( "gui/gradient_down" )

function GM:CreateScoreboard()
	return false
end

function GM:ScoreboardShow()
	gui.EnableScreenClicker( true )
	ScoreBoard:Create()
	ScoreBoardFrame:SetVisible( true )
end

function GM:ScoreboardHide()
if ScoreBoardFrame:IsValid() then
	ScoreBoardFrame:SetVisible( false )
	ScoreBoardFrame:Remove()
	gui.EnableScreenClicker( false )
end
end

local hudc1 = Color( 205, 205, 255, 25 )
local hudc2 = Color(205,205,255, 155)
local shadowc = Color(0,0,0, 150)

local function DrawSimpleShadowText( txt, font, x, y, col, alignx, aligny, shadowlen )
    draw.SimpleText( txt, font, x + shadowlen, y + shadowlen, Color( 0, 0, 0, 150 ), alignx, aligny )
    local nx, ny = draw.SimpleText( txt, font, x, y, col, alignx, aligny )
    return nx, ny
end

function ScoreBoard:Create()

	ScoreBoardFrame = vgui.Create( "DFrame" )
	ScoreBoardFrame:SetSize( 450, 600 )
    ScoreBoardFrame:Center()
	ScoreBoardFrame:SetTitle ( "" )
	ScoreBoardFrame:SetDraggable( false )
	ScoreBoardFrame:SetVisible( true )
	ScoreBoardFrame:ShowCloseButton( false )
	ScoreBoardFrame:MakePopup()
	ScoreBoardFrame.Paint = function( self, w, h )
		surface.SetDrawColor(hudc1)
        surface.DrawRect( 0, 0, w, 3 )
		surface.DrawRect( 0, 5, w, 42 )
        if !CurrentActiveRound then return end
        DrawSimpleShadowText( "ROUND TYPE: "..CurrentActiveRound.Name, "BSHUDFont1", w / 2, 8, hudc2, 1, 0, 1 )
	end

    local FacList = vgui.Create( "DScrollPanel", ScoreBoardFrame )
    FacList:SetSize( 450, 350 )
    FacList:SetPos( 0, 60 )

    local spacer = 0

    local players = player.GetAll()
    table.sort( players, function( a, b ) return a:GetNWInt( "BS_Score", 0 ) > b:GetNWInt( "BS_Score", 0 ) end )
    for k, ply in ipairs( players ) do
        
        local plypanel = vgui.Create( "DPanel", FacList )
        plypanel:SetPos( 0, spacer )
        spacer = spacer + 27
        plypanel:SetSize( 450, 25 )
        plypanel.Paint = function( self, w, h )
            if !ply:IsValid() then return end
            surface.SetDrawColor(hudc1)
            surface.DrawRect( 0, 0, w, h )
            surface.DrawRect( 0, 0, w, 2 )

            DrawSimpleShadowText( ply:Nick(), "BSHUDFont2", 5, 2, team.GetColor( ply:Team() ), 0, 0, 1 )
            DrawSimpleShadowText( "Score: "..ply:GetNWInt( "BS_Score", 0 ), "BSHUDFont2", w - 15, 2, Color( 200, 255, 200 ), 2, 0, 1 )
        end


    end
end
