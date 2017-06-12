GM.Name 	= "Bloodsport"
GM.Author 	= "LegendofRobbo"
GM.Email 	= ""
GM.Website 	= ""

DeriveGamemode("base")


team.SetUp( 1, "Niggers", Color( 150, 150, 150, 255 ) )
hook.Add( "CanProperty", "nope", function( ply, property, ent) if !ply:IsSuperAdmin() then return false end end)

function GM:Initialize()
	self.BaseClass:Initialize()
end

local gmname = "bloodsport"
for k, v in pairs( file.Find( gmname.."/gamemode/shared/*", "LUA" ) ) do
	include("shared/"..v)
end

for k, v in pairs( file.Find( gmname.."/gamemode/client/*", "LUA" ) ) do
	include("client/"..v)
end

net.Receive( "SystemMessage", function( length, client )
local msg = net.ReadString()
local col = net.ReadColor()
local sys = net.ReadBool()

if sys then
chat.AddText( Color(255,255,255,255), "[System] ", col, msg )
else
chat.AddText( col, msg )
end

end)

function GM:OnUndo( name, strCustomString )
notification.AddLegacy( "Undo: "..name, 2, 3 )
surface.PlaySound( "buttons/button15.wav" )
end


function GM:ShowHelp()
	return
end