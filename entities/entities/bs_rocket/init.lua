AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

/*---------------------------------------------------------
   Name: ENT:Initialize()
---------------------------------------------------------*/
function ENT:Initialize()
	
	self:SetModel("models/Weapons/W_missile_closed.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(1)
	end
	
	self.InFlight = true

	timer.Simple( 0, function()
		if !self:IsValid() then return end

		local Glow = ents.Create("env_sprite")
		Glow:SetKeyValue("model","orangecore2.vmt")
		if self.Mode then Glow:SetKeyValue("rendercolor","255 150 100") else Glow:SetKeyValue("rendercolor","150 150 255") end
		Glow:SetKeyValue("scale","0.6")
		Glow:SetPos(self.Entity:GetPos())
		Glow:SetParent(self.Entity)
		Glow:Spawn()
		Glow:Activate()

		if self.Mode then
			util.SpriteTrail( self, 0, Color(155, 155, 155, 155), false, 2, 10, 1, 5 / ((2 + 10) * 0.5), "trails/smoke.vmt" )
		else
			util.SpriteTrail( self, 0, Color(155, 155, 255, 155), false, 2, 10, 1, 5 / ((2 + 10) * 0.5), "trails/smoke.vmt" )
		end

	end)
end

/*---------------------------------------------------------
   Name: ENT:Think()
---------------------------------------------------------*/
function ENT:Think()
	
	local phys = self:GetPhysicsObject()
	phys:SetVelocity( self:GetForward() * 2000 + self:GetRight() * math.random( -50, 50 ) + self:GetUp() * math.random( 50, 100 ) )

	self.lifetime = self.lifetime or CurTime() + 20

	if CurTime() > self.lifetime or self.KillMe then
		self:Remove()
	end
end

/*---------------------------------------------------------
   Name: ENT:Disable()
---------------------------------------------------------*/
function ENT:Disable()
	self.PhysicsCollide = function() end
	self.lifetime = CurTime() + 10

	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end



function ENT:PhysicsCollide( data, phys )
	if self.KillMe then return end
	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	util.Effect("HelicopterMegaBomb", effectdata)

	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	util.Effect("bs_shockwave", effectdata)



	if !self.Mode then
		util.BlastDamage( self, self.Owner, self:GetPos(), 250, 30 )
		self:EmitSound( "ambient/explosions/explode_4.wav", 90, math.random( 180, 200 ) )
		local blasted = ents.FindInSphere( self:GetPos(), 180 )
		for k, v in pairs( blasted ) do
			if !v:IsPlayer() then continue end
			local dist = v:GetPos():Distance( self:GetPos() )
			local mul = 600
			if !v:IsOnGround() then mul = 300 end
			v:SetPos( v:GetPos() + Vector( 0, 0, 3 ) )
			v:SetVelocity( ( ( v:GetPos() - self:GetPos() ):GetNormal() * mul ) + Vector( 0, 0, mul / 4 ) )
			v.RocketJumped = CurTime() + 3
		end
	else
		util.BlastDamage( self, self.Owner, self:GetPos(), 200, 110 )
		self:EmitSound( "ambient/explosions/explode_5.wav", 90, math.random( 180, 200 ) )
	end


	if data.HitEntity and data.HitEntity:IsValid() and data.HitEntity:IsPlayer() then
		local d = DamageInfo()
		d:SetDamage( 20 )
		d:SetAttacker( self.Owner )
		d:SetDamageType( DMG_CRUSH )
		data.HitEntity:TakeDamageInfo( d )
	end

	self.KillMe = true
end