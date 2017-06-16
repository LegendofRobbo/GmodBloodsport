GM.Name 	= "Bloodsport"
GM.Author 	= "LegendofRobbo, LIES, zultan, malus"
GM.Email 	= ""
GM.Website 	= ""

DeriveGamemode("base")

AddCSLuaFile( "cl_init.lua" )

team.SetUp( 1, "Niggers", Color( 150, 150, 150, 255 ) )

hook.Add( "CanProperty", "nope", function( ply, property, ent) if !ply:IsSuperAdmin() then return false end end)

util.AddNetworkString( "GMC_ReloadModules" )

local gmname = "bloodsport"
for k, v in pairs( file.Find( "gamemodes/"..gmname.."/gamemode/server/*", "GAME" ) ) do
	MsgC(Color(255,255,255), "loaded server file: "..v.."\n")
	include( "server/"..v )
end

for k, v in pairs( file.Find( "gamemodes/"..gmname.."/gamemode/shared/*", "GAME" ) ) do
	MsgC(Color(255,255,255), "loaded shared file: "..v.."\n")
	AddCSLuaFile("shared/"..v)
	include("shared/"..v)
end

for k, v in pairs( file.Find( "gamemodes/"..gmname.."/gamemode/client/*", "GAME" ) ) do
	MsgC(Color(255,255,255), "sending clientside file: "..v.."\n")
	AddCSLuaFile("client/"..v)
end


hook.Add( "OnReloaded", "ModuleLoading", function() 
--	LoadModules()
end )

local playa = FindMetaTable("Player")


function GM:PlayerDisconnected( ply )
	-- cuck
end

function GM:ShutDown()
	-- do some shit here maybe
end


function GM:PlayerConnect( name, ip )
	--bat me
end

local testers = {
	"76561198028288732", -- me
	"76561198083117557", -- lies
	"76561198035059571", -- erad
	"76561198097352513", -- zultan
	"76561198028646454", -- malus
	"76561198090537451", -- sync
}

function GM:CheckPassword( id64, ip, password, theirpass, name ) 
	if password != "" and theirpass != password then
		for k, v in pairs( player.GetAll() ) do v:ChatPrint( name.." [ "..id64.." ] tried to connect with the wrong password" ) end
		return false, "Wrong password faggot!" 
	end
	if !table.HasValue( testers, id64 ) then
		for k, v in pairs( player.GetAll() ) do v:ChatPrint( name.." [ "..id64.." ] tried to connect but isn't whitelisted" ) end
		return false, "You aren't on the whitelist! contact LegendofRobbo if you want to get in"
	end
	return true
end


function GM:PlayerSpawn( ply )
	self.BaseClass:PlayerSpawn( ply )
	ply:SetPVarFloat( "CanWallJump", 1 )
	ply:SetTeam( 1 )
	ply:SetModel( "models/player/kleiner.mdl" )
	ply:AllowFlashlight( true )
	ply:SetCanZoom( false )
end

function GM:PlayerInitialSpawn( ply )
	self.BaseClass:PlayerInitialSpawn( ply )
	ply:SetTeam(1)
end

function GM:ShowSpare1( ply )
	ply:ChatPrint( "ur gay lmao" )
end

function GM:ShowSpare2( ply )
end

function GM:ShowHelp( ply )
	return
end

function GM:PlayerLoadout( ply )
--	ply:Give( "weapon_physgun" )
	ply:Give( "weapon_bs_knife" )
	ply:Give( "weapon_bs_magnum" )
	ply:Give( "weapon_bs_harpoonbow" )
	ply:SetRunSpeed( 400 )
	ply:SetWalkSpeed( 350 )
--	ply:SetJumpPower( 200 )
end

function GM:PlayerNoClip( ply )
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		return true
	end
	
	if ply:GetMoveType(MOVETYPE_NOCLIP) then
		ply:SetMoveType(MOVETYPE_WALK)
	end
	return false
end


function GM:PlayerShouldTaunt( ply, actid )
	return true
end


function GM:OnPlayerHitGround( ply, water, floating_obj, speed )
	if !water then 
		ply:SetPVarFloat( "CanWallJump", 1 ) 
	end
end

hook.Add("SetupMove", "Walljumping", function( ply, cmd )
	if ply:IsOnGround() or !ply:Alive() or ply:WaterLevel() > 1 or !cmd:KeyPressed( IN_JUMP ) or (ply:GetPVar( "CanWallJump" ) and ply:GetPVar( "CanWallJump" ) < 1) or (ply.NextWallJump and ply.NextWallJump > CurTime()) then return end

	local trcstart = ply:GetPos() + ply:GetAngles():Up() * 40 + ply:GetAngles():Right() * 10
	local trcend = ply:GetPos() + ply:GetAngles():Up() * 40 + ply:GetAngles():Right() * -10
	local siz = 10
	local tr = util.TraceHull( {
		start = trcstart,
		endpos = trcend,
		filter = ply,
		mask = MASK_SOLID_BRUSHONLY,
		mins = Vector( -siz, -siz, -siz ),
		maxs = Vector( siz, siz, siz )
	} )

	if tr.Hit then
		if tr.Fraction < 1 then
			ply:SetVelocity( ply:GetAngles():Right() * 300 + Vector( 0, 0, 10000 ) )
		else
			ply:SetVelocity( ply:GetAngles():Right() * -300 + Vector( 0, 0, 10000 ) )
		end
		ply:EmitSound( "physics/flesh/flesh_impact_hard1.wav" )
		ply:SetPVarFloat( "CanWallJump", 0 )
		ply.NextWallJump = CurTime() + 0.3

		local ef = EffectData()
		ef:SetOrigin( ply:GetPos() )
		ef:SetScale( 2 )
		ef:SetStart( Vector(225, 225, 225) )
		util.Effect( "bs_smoke_puff", ef )

	end

end)