AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

/*---------------------------------------------------------
   Name: ENT:Initialize()
---------------------------------------------------------*/
function ENT:Initialize()
	
	self:SetModel("models/props_junk/PopCan01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetMaterial( "effects/binary_noise_b_01" )

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableGravity( false )
	end
	
	self.StartZapping = CurTime() + 0.3

	timer.Simple( 0, function()
		if !self:IsValid() then return end

		self.Glow = ents.Create("env_sprite")
		self.Glow:SetKeyValue("model","particle/particle_glow_05_addnofog.vmt")
		self.Glow:SetKeyValue("rendercolor","150 150 255")
		if self.Mode then self.Glow:SetKeyValue("scale","0.4") else self.Glow:SetKeyValue("scale","2.6") end
		self.Glow:SetPos(self:GetPos())
		self.Glow:SetParent(self.Entity)
		self.Glow:Spawn()
		self.Glow:Activate()

		local len = 0.1
		if !self.Mode then len = 1 self:SetCollisionGroup( COLLISION_GROUP_DEBRIS ) end
		self.Trail = util.SpriteTrail( self, 0, Color(155, 155, 255, 155), false, 2, 5, len, 5 / ((2 + 10) * 0.5), "trails/smoke.vmt" )

	end)

	self.Bounces = 0
end

/*---------------------------------------------------------
   Name: ENT:Think()
---------------------------------------------------------*/
function ENT:Think()

	self.lifetime = self.lifetime or CurTime() + 8

	if CurTime() >= self.lifetime or self.KillMe then
		if self.DiePos then
			local effectdata = EffectData()
			effectdata:SetOrigin( self.DiePos )
			util.Effect("bs_electro", effectdata)
		end

		self:Remove()
	end

	if !self.Mode then
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		util.Effect("bs_electro", effectdata)
		self:NextThink( CurTime() + 0.05 )
		if self.StartZapping <= CurTime() then
			local blasted = ents.FindInSphere( self:GetPos(), 120 )
			for k, v in pairs( blasted ) do
				if !v:IsPlayer() then continue end
				if !v:Alive() then continue end
				local effectdata = EffectData()
				effectdata:SetOrigin( v:GetPos() + Vector( 0, 0, 35 ) + VectorRand() * 5 )
				effectdata:SetScale( 2 )
				effectdata:SetMagnitude( 0.5 )
				util.Effect("Sparks", effectdata)
				local dmg = 3
				if v == self.Owner then dmg = 1 end
				v:EmitSound( "ambient/energy/spark"..math.random( 1, 6 )..".wav", 80, 150, 0.7 )
				v:TakeDamage( dmg, self.Owner, self )
			end
		end
		return true
	end

end

function ENT:Explode( data )
	if data.HitEntity and data.HitEntity:IsValid() and data.HitEntity:IsPlayer() then
		local d = DamageInfo()
		d:SetDamage( 20 )
		d:SetAttacker( self.Owner )
		d:SetDamageType( DMG_GENERIC )
		data.HitEntity:TakeDamageInfo( d )
--		self:Remove()
	end
end



function ENT:PhysicsCollide( data, phys )
	if self.KillMe then return end
	self:Explode( data )
	if self.Mode then
		if self.Glow then self.Glow:Remove() end
		if self.Trail then self.Trail:Remove() end
		self:SetRenderMode( RENDERMODE_NONE )
		self.KillMe = true
		self.DiePos = self:GetPos() 
	end
end