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


function GM:PlayerSpawn( ply )
	self.BaseClass:PlayerSpawn( ply )
	ply:SetPVarBool( "CanWallJump", 1 )
	ply:SetTeam(1)
	ply:SetModel( "models/player/kleiner.mdl" )
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
	ply:Give( "weapon_physgun" )
	ply:Give( "weapon_bs_knife" )
	ply:Give( "weapon_bs_magnum" )
	ply:SetRunSpeed( 500 )
	ply:SetWalkSpeed( 350 )
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

/*
hook.Add( "Think", "Walljumping", function() 
	for k, v in pairs( player.GetAll() ) do

		if !v:Alive() or v:GetPVar( "CanWallJump" ) < 1 or v.NextWallJump > CurTime() then continue end

		local trcstart = v:GetPos() + v:GetAngles():Up() * 40 + v:GetAngles():Right() * 10
		local trcend = v:GetPos() + v:GetAngles():Up() * 40 + v:GetAngles():Right() * -10
		local siz = 10
		local tr = util.TraceHull( {
			start = trcstart,
			endpos = trcend,
			filter = v,
			mins = Vector( -siz, -siz, -siz ),
			maxs = Vector( siz, siz, siz )
		} )

		if tr.Hit and v:KeyDown( IN_JUMP ) then
			if tr.Fraction < 1 then
				v:SetVelocity( v:GetAngles():Up() * 250 + v:GetAngles():Right() * 300 )
			else
				v:SetVelocity( v:GetAngles():Up() * 250 + v:GetAngles():Right() * -300 )
			end
			v:EmitSound( "physics/flesh/flesh_impact_hard1.wav" )
			v:SetPVarFloat( "CanWallJump", 0 )
			v.NextWallJump = CurTime() + 0.2
		end

	end
end )
*/


hook.Add("SetupMove", "Walljumping", function( ply, cmd )
	if ply:IsOnGround() or !ply:Alive() or !cmd:KeyPressed( IN_JUMP ) or (ply:GetPVar( "CanWallJump" ) and ply:GetPVar( "CanWallJump" ) < 1) or (ply.NextWallJump and ply.NextWallJump > CurTime()) then return end

	local trcstart = ply:GetPos() + ply:GetAngles():Up() * 40 + ply:GetAngles():Right() * 10
	local trcend = ply:GetPos() + ply:GetAngles():Up() * 40 + ply:GetAngles():Right() * -10
	local siz = 10
	local tr = util.TraceHull( {
		start = trcstart,
		endpos = trcend,
		filter = ply,
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
		ef:SetStart( Vector(255, 255, 255) )
		util.Effect( "bs_smoke_puff", ef )

	end

end)