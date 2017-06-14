--[[=====================================================
Private Networked Variables Plugin
Creator: LegendofRobbo
Purpose: privately networked data (sends to owner only)
=======================================================]]

local ply = FindMetaTable( "Player" )

-- this give me aids just looking at it
local function WriteWildcard( typ, data )
	net.WriteUInt( typ, 4 )
	-- string
	if typ == 1 then
		net.WriteString( data )
	-- entity
	elseif typ == 2 then
		local idx = 0
		if data:IsValid() then idx = data:EntIndex() end
		net.WriteUInt( idx, 16 )
	-- float
	elseif typ == 3 then
		net.WriteFloat( data )
	-- vector
	elseif typ == 4 then
		net.WriteVector( data )
	-- bool
	elseif typ == 5 then
		net.WriteBool( data )
	-- angle
	elseif typ == 6 then
		net.WriteAngle( data )
	end
end

local function ReadWildcard()
	local typ = net.ReadUInt( 4 )
	local val
	-- string
	if typ == 1 then
		val = net.ReadString()
	-- entity
	elseif typ == 2 then
		local idx = net.ReadUInt( 16 )
		val = ents.GetByIndex( idx )
	-- float
	elseif typ == 3 then
		val = net.ReadFloat()
	-- vector
	elseif typ == 4 then
		val = net.ReadVector()
	-- bool
	elseif typ == 5 then
		val = net.ReadBool()
	-- angle
	elseif typ == 6 then
		val = net.ReadAngle()
	end
	return val
end


--============================================================================================================================================
-- Case specfic stuff
--============================================================================================================================================


if SERVER then 
	util.AddNetworkString( "PVar" )
	local meta = FindMetaTable("Player")

	local function SendPVar( ply, addr, typ )
		if !ply.PVars then ply.PVars = {} end
		if !ply.PVars[addr] then return end
		local data = ply.PVars[addr]
		net.Start( "PVar" )
		net.WriteString( addr )
		WriteWildcard( typ, data )
		net.Send( ply )
	end
	
	--[[
	-- note: if your gonna add this you can't do local function local function meta:SendPVar, metafunctions cannot be local

	local function meta:SendPVar(addr, typ)
		if !self.PVars then self.PVars = {} end // meta function
		if !ply.PVars[addr] then return end
		local data = self.PVars[addr]
		net.Start( "PVar" )
		net.WriteString( addr )
		WriteWildcard( typ, data )
		net.Send( self )
	end
	]]-- 
end

if CLIENT then
	net.Receive( "PVar", function() 
		local addr = net.ReadString()
		local val = ReadWildcard()
		local me = LocalPlayer()

		if !me.PVars then me.PVars = {} end
		me.PVars[addr] = val
	end )
end



--============================================================================================================================================
-- These functions are all SHARED
-- Calling them on the server will set them both serverside and clientside for the owning player
-- Calling them on the client will overwrite the value sent by the server (until the server sends a new value)
--============================================================================================================================================



-- retrieves wildcard PVar data ( <address> = string )
function ply:GetPVar( address )
	if !self.PVars then self.PVars = {} end
	return self.PVars[address]
end




-- sets a PVar string on a player ( <address> = string, <value> = string )
-- Example: ply:SetPVarString( "RPName", "Gay" )
function ply:SetPVarString( address, value )
	if !self.PVars then self.PVars = {} end
	self.PVars[address] = value
	if SERVER then SendPVar( self, address, 1 ) end
end

-- sets a PVar entity on a player ( <address> = string, <value> = entity )
function ply:SetPVarEntity( address, value )
	if !self.PVars then self.PVars = {} end
	self.PVars[address] = value
	if SERVER then SendPVar( self, address, 2 ) end
end

-- sets a PVar float (number with digits) on a player ( <address> = string, <value> = number )
function ply:SetPVarFloat( address, value )
	if !self.PVars then self.PVars = {} end
	self.PVars[address] = value
	if SERVER then SendPVar( self, address, 3 ) end
end

-- sets a PVar vector on a player ( <address> = string, <value> = vector )
function ply:SetPVarVector( address, value )
	if !self.PVars then self.PVars = {} end
	self.PVars[address] = value
	if SERVER then SendPVar( self, address, 4 ) end
end

-- sets a PVar boolean (true or false) on a player ( <address> = string, <value> = boolean )
function ply:SetPVarBool( address, value )
	if !self.PVars then self.PVars = {} end
	self.PVars[address] = value
	if SERVER then SendPVar( self, address, 5 ) end
end

-- sets a PVar angle on a player ( <address> = string, <value> = angle )
function ply:SetPVarAngle( address, value )
	if !self.PVars then self.PVars = {} end
	self.PVars[address] = value
	if SERVER then SendPVar( self, address, 6 ) end
end