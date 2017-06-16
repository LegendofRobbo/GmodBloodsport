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


local lerproll = 0
local inair = 0

function GM:CalcView( ply, origin, angles, fov, znear, zfar )

	local Vehicle	= ply:GetVehicle()
	local Weapon	= ply:GetActiveWeapon()

	local view = {}
	view.origin		= origin
	view.angles		= angles
	view.fov		= fov
	view.znear		= znear
	view.zfar		= zfar
	view.drawviewer	= false

	--
	-- Let the vehicle override the view and allows the vehicle view to be hooked
	--
	if ( IsValid( Vehicle ) ) then return hook.Run( "CalcVehicleView", Vehicle, ply, view ) end

	--
	-- Let drive possibly alter the view
	--
	if ( drive.CalcView( ply, view ) ) then return view end

	--
	-- Give the player manager a turn at altering the view
	--
	player_manager.RunClass( ply, "CalcView", view )

	-- Give the active weapon a go at changing the viewmodel position
	if ( IsValid( Weapon ) ) then

		local func = Weapon.CalcView
		if ( func ) then
			view.origin, view.angles, view.fov = func( Weapon, ply, origin * 1, angles * 1, fov ) -- Note: *1 to copy the object so the child function can't edit it.
		end

	end

--	if !ply:IsOnGround() then inair = inair + 0.01 else inair = 0 end
	local onground = ply:IsOnGround()
	local airtarg = 0
	if !onground then airtarg = -1 end

	local rolltarget = math.Clamp( ply:GetVelocity():Dot(ply:EyeAngles():Right()) / 200, -3, 3 )

	if !onground and ply:GetPVar( "CanWallJump" ) and ply:GetPVar( "CanWallJump" ) >= 1 then
		local trcstart = ply:GetPos() + ply:GetAngles():Up() * 40 + ply:GetAngles():Right() * 10
		local trcend = ply:GetPos() + ply:GetAngles():Up() * 40 + ply:GetAngles():Right() * -10
		local siz = 10
		local tr = util.TraceHull( {
			start = trcstart,
			endpos = trcend,
			filter = ply,
			mask = MASK_SOLID_BRUSHONLY,
			mins = Vector( -siz, -siz, -siz ),
			maxs = Vector( siz, siz, siz ),
		} )

		if tr.Hit then
			if tr.Fraction < 1 then
				rolltarget = rolltarget + 10
			else
				rolltarget = rolltarget - 10
			end
		end
	end

	inair = Lerp( 0.05, inair, airtarg )
	lerproll = Lerp( 0.05, lerproll, rolltarget )

	view.angles.r = lerproll


	local walkspeedmul = ply:GetVelocity():Length() / 500
	walkspeedmul = math.Clamp( walkspeedmul, 0, 1 ) / 2
	local right, up = math.sin( CurTime() * 6 ) * walkspeedmul * 2, math.cos( CurTime() * 15 ) * walkspeedmul

	view.origin = view.origin + (ply:EyeAngles():Up() * up) + (ply:EyeAngles():Right() * right)
	view.angles.p = view.angles.p - inair
	view.origin.z = view.origin.z + inair

	return view

end