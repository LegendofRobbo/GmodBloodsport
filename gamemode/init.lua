GM.Name 	= "Bloodsport"
GM.Author 	= "LegendofRobbo, LIES, zultan, malus"
GM.Email 	= ""
GM.Website 	= ""

DeriveGamemode("base")

AddCSLuaFile( "cl_init.lua" )

resource.AddWorkshop( "1096827799" )

team.SetUp( 1, "Dead People", Color( 150, 150, 150, 255 ) )
team.SetUp( 2, "Blue Team", Color( 150, 150, 250, 255 ) )
team.SetUp( 3, "Red Team", Color( 250, 150, 150, 255 ) )

team.SetUp( 4, "Red", Color( 250, 150, 150, 255 ) )
team.SetUp( 5, "Green", Color( 150, 250, 150, 255 ) )
team.SetUp( 6, "Blue", Color( 150, 150, 250, 255 ) )
team.SetUp( 7, "Yellow", Color( 250, 250, 150, 255 ) )
team.SetUp( 8, "Purple", Color( 150, 100, 250, 255 ) )
team.SetUp( 9, "Sky", Color( 150, 255, 255 ) )
team.SetUp( 10, "Orange", Color( 255, 155, 55 ) )

hook.Add( "CanProperty", "nope", function( ply, property, ent) if !ply:IsSuperAdmin() then return false end end)

--util.AddNetworkString( "GMC_ReloadModules" )

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
	ply:SetPVarFloat( "CanWallJump", 1 )
--	ply:SetTeam( 1 )
	ply:SetModel( "models/player/kleiner.mdl" )
	ply:AllowFlashlight( true )
	ply:SetCanZoom( false )
	ply:SetNWBool( "X2Combo", false )
end

function GM:RollNewDeathmatchTeam( ply )
	if !ply:IsValid() then return end
	ply:SetTeam( math.random( 4, 10 ) )
end

function GM:PlayerInitialSpawn( ply )
	self.BaseClass:PlayerInitialSpawn( ply )
	self:RollNewDeathmatchTeam( ply )
end

hook.Add( "PlayerDeath", "NoBurnieGlitches", function( ply ) timer.Simple( 0.1, function() if ply:IsValid() then ply:Extinguish() end end ) end )

function GM:ShowSpare1( ply )
	ply:ChatPrint( "ur gay lmao" )
end

function GM:ShowSpare2( ply )
end

function GM:ShowHelp( ply )
	return
end

function GM:PlayerLoadout( ply )
	ply:Give( "weapon_bs_knife" )
	ply:SetRunSpeed( 450 )
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

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )

	if ( hitgroup == HITGROUP_HEAD ) then
		dmginfo:ScaleDamage( 2 )
	end

	local wep = ply:GetActiveWeapon()
	if wep and wep:IsValid() and wep:GetClass() == "weapon_bs_gravhammer" then
		if wep:GetBlocking() then dmginfo:ScaleDamage( 0.5 ) end
	end

end

function GM:PlayerShouldTaunt( ply, actid )
	return true
end

function GM:OnDamagedByExplosion( ply, dmginfo )
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
		local ppos = ply:GetPos()
		-- fixes some weird networking issue where players can't see their own walljump smoke puffs
		timer.Simple( 0, function()
			local ef = EffectData()
			ef:SetOrigin( ppos )
			ef:SetScale( 1.5 )
			ef:SetStart( Vector(125, 125, 125) )
			util.Effect( "bs_smoke_puff", ef )
		end)

	end

end)




util.AddNetworkString( "DamageFlashes" )
hook.Add( "EntityTakeDamage", "BSTakeDamage", function( ent, dmg )
	if ent:IsPlayer() and ent:Alive() then
		net.Start( "DamageFlashes" )
		net.Send( ent )
	end

	if ent:IsPlayer() and dmg:GetDamageType() == DMG_CRUSH or dmg:GetDamageType() == DMG_FALL then return true end

end )
