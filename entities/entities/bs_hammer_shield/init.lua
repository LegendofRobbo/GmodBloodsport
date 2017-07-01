AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

--Called when the SENT is spawned
function ENT:Initialize()
	self.Entity:SetModel( "models/props_trainstation/trainstation_clock001.mdl" )
 	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
 	self:SetColor( Color( 255, 255, 255, 55 ) )
 	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	timer.Simple( 5, function() if self:IsValid() then self:Remove() end end)
	local PhysAwake = self.Entity:GetPhysicsObject()
	if ( PhysAwake:IsValid() ) then
		PhysAwake:Wake()
		PhysAwake:EnableMotion( false )
	end 
end

function ENT:Use( p, c )
end

function ENT:Think()
	local owner = self:GetNWEntity( "ShieldOwner" )
	if !owner:IsValid() or !owner:IsPlayer() or !owner:Alive() or (owner:GetActiveWeapon() and owner:GetActiveWeapon():GetClass() != "weapon_bs_gravhammer") then
		self:Remove()
		return
	end
end

function ENT:OnTakeDamage( dmg )
	self:SetNWBool( "Flashing", true )
	self:EmitSound( "weapons/physcannon/energy_disintegrate4.wav", 75, math.random( 190, 220 ) )
	if dmg:IsBulletDamage() then
		local pos = dmg:GetDamagePosition()
		local norm = -dmg:GetDamageForce():GetNormal()

		local effectdata = EffectData()
		effectdata:SetOrigin( dmg:GetDamagePosition() )
		effectdata:SetNormal( norm )
		effectdata:SetScale( 1 )
		effectdata:SetMagnitude( 12 )
		util.Effect("StunstickImpact", effectdata)
	end

	timer.Simple( 0.1, function() 
		if self:IsValid() then self:SetNWBool( "Flashing", false ) end
	end)
end

function ENT:StartTouch( e )
end