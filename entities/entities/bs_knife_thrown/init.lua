AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

/*---------------------------------------------------------
   Name: ENT:Initialize()
---------------------------------------------------------*/
function ENT:Initialize()
	
	self.Owner = self.Entity:GetOwner()

	if !IsValid(self.Owner) then
		self:Remove()
		return
	end

	
	self:SetModel("models/weapons/w_knife_t.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()
	self.NextThink = CurTime() + 1
	self.Entity:DrawShadow(false)

	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(10)
	end
	
	util.PrecacheSound("physics/metal/metal_grenade_impact_hard3.wav")
	util.PrecacheSound("physics/metal/metal_grenade_impact_hard2.wav")
	util.PrecacheSound("physics/metal/metal_grenade_impact_hard1.wav")
	util.PrecacheSound("physics/flesh/flesh_impact_bullet1.wav")
	util.PrecacheSound("physics/flesh/flesh_impact_bullet2.wav")
	util.PrecacheSound("physics/flesh/flesh_impact_bullet3.wav")

	self.Hit = { 
	Sound("physics/metal/metal_grenade_impact_hard1.wav"),
	Sound("physics/metal/metal_grenade_impact_hard2.wav"),
	Sound("physics/metal/metal_grenade_impact_hard3.wav")};

	self.FleshHit = { 
	Sound("physics/flesh/flesh_impact_bullet1.wav"),
	Sound("physics/flesh/flesh_impact_bullet2.wav"),
	Sound("physics/flesh/flesh_impact_bullet3.wav")}

	self:GetPhysicsObject():SetMass(2)

	util.SpriteTrail(self.Entity, 0, Color(155, 155, 155, 55), false, 1, 5, 0.8, 5 / ((2 + 10) * 0.5), "trails/smoke.vmt")
end

/*---------------------------------------------------------
   Name: ENT:Think()
---------------------------------------------------------*/
function ENT:Think()
	
	self.lifetime = self.lifetime or CurTime() + 20

	if CurTime() > self.lifetime then
		self:Remove()
	end
end

/*---------------------------------------------------------
   Name: ENT:Disable()
---------------------------------------------------------*/
function ENT:Disable()
	self.PhysicsCollide = function() end
	self.lifetime = CurTime() + 5

	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end


-- fuck this warning spam off from physicscollide
function ENT:KillMe( data, phys )
	if !self:IsValid() then return end
	local Ent = data.HitEntity
	if !(IsValid(Ent) or Ent:IsWorld()) then return end

	if Ent:IsWorld() then
			util.Decal("ManhackCut", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)

			if self.Entity:GetVelocity():Length() > 250 then
				self:EmitSound("npc/roller/blade_out.wav", 60)
				self:SetPos(data.HitPos - data.HitNormal * 10)
				self:SetAngles(data.HitNormal:Angle() + Angle(40, 0, 0))
				self:GetPhysicsObject():EnableMotion(false)
			else
				self:EmitSound(self.Hit[math.random(1, #self.Hit)])
			end

			self:Disable()

	elseif Ent.Health then
		if not(Ent:IsPlayer() or Ent:IsNPC() or Ent:GetClass() == "prop_ragdoll") then 
			util.Decal("ManhackCut", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)
			self:EmitSound(self.Hit[math.random(1, #self.Hit)])
			self:Disable()
		end

		Ent:TakeDamage(100, self:GetOwner(), self )

		if (Ent:IsPlayer() or Ent:IsNPC() or Ent:GetClass() == "prop_ragdoll") then 


			local effectdata = EffectData()
			effectdata:SetOrigin( data.HitPos )
			effectdata:SetNormal( data.HitNormal )
			effectdata:SetMagnitude( 1 )
			effectdata:SetScale( 15 )
			effectdata:SetColor( 0 )
			effectdata:SetFlags( 3 )
			util.Effect( "bloodspray", effectdata, true, true )
			self:EmitSound( "weapons/knife/knife_stab.wav", 90, 150 )

--			local effectdata = EffectData()
--			effectdata:SetStart(data.HitPos)
--			effectdata:SetOrigin(data.HitPos)
--			effectdata:SetScale(1)
--			util.Effect("BloodImpact", effectdata)

--			self:EmitSound(self.FleshHit[math.random(1,#self.Hit)])
			self:Remove()
		end
	end

	self.Entity:SetOwner(NUL)
end


/*---------------------------------------------------------
   Name: ENT:PhysicsCollided()
---------------------------------------------------------*/
function ENT:PhysicsCollide(data, phys)
	timer.Simple( 0, function() self:KillMe(data, phys) end )
end