AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

/*---------------------------------------------------------
   Name: ENT:Initialize()
---------------------------------------------------------*/
function ENT:Initialize()
	
	self:SetModel("models/props_junk/harpoon002a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()
	--self.NextThink = CurTime() +  1

	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(10)
	end
	
	self.InFlight = true

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
	Sound("weapons/crossbow/bolt_skewer1.wav")}

--	self:GetPhysicsObject():SetMass(2)	

--	self.Entity:SetUseType(SIMPLE_USE)
	util.SpriteTrail(self.Entity, 0, Color(155, 155, 155, 155), false, 2, 10, 1, 5 / ((2 + 10) * 0.5), "trails/smoke.vmt")
end

/*---------------------------------------------------------
   Name: ENT:Think()
---------------------------------------------------------*/
function ENT:Think()
	
	self.lifetime = self.lifetime or CurTime() + 20

--	self:SetAngles( self:GetVelocity():GetNormal():Angle() )

	if CurTime() > self.lifetime then
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



function ENT:PhysicsCollide(data, phys)
	
	local Ent = data.HitEntity

	if Ent:IsValid() and Ent:GetClass() == "bs_harpoon" then
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetScale(1)
		effectdata:SetMagnitude(3)
		util.Effect("Sparks", effectdata)
		self:EmitSound( "npc/manhack/grind5.wav" )
		self.Rebounded = true
		self:SetOwner()
		return
	end

	if Ent:IsValid() and Ent:GetClass() == "bs_hammer_shield" then
		local eowner = Ent:GetNWEntity( "ShieldOwner" )
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetScale(1)
		effectdata:SetMagnitude(3)
		util.Effect("Sparks", effectdata)
--		self:EmitSound( "npc/manhack/grind5.wav" )
		Ent:TakeDamage( 120, self.Owner, self.Entity)
		self.Rebounded = true
		self.Owner = eowner
		self:SetOwner()
		return
	end

	if !(Ent:IsValid() or Ent:IsWorld()) then return end

	if Ent:IsWorld() and self.InFlight then
	
			if data.Speed > 400 then
				self:EmitSound(Sound("weapons/crossbow/bolt_skewer1.wav"))
				self:SetPos(data.HitPos - data.HitNormal * 10)
				self:SetAngles(self.Entity:GetAngles())
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

		Ent:TakeDamage( 120, self.Owner, self.Entity)

		if (Ent:IsPlayer() or Ent:IsNPC() or Ent:GetClass() == "prop_ragdoll") then

			local effectdata = EffectData()
			effectdata:SetStart(data.HitPos)
			effectdata:SetOrigin(data.HitPos)
			effectdata:SetNormal(data.HitNormal)
			effectdata:SetMagnitude( 1 )
			effectdata:SetScale( 15 )
			effectdata:SetColor( 0 )
			effectdata:SetFlags( 3 )
			util.Effect("bloodspray", effectdata)

			self:EmitSound("weapons/crossbow/bolt_skewer1.wav", 100, 90)
			self:Remove()
		end
	end

	self.Entity:SetOwner(NUL)
end