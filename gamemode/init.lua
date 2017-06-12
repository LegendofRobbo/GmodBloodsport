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