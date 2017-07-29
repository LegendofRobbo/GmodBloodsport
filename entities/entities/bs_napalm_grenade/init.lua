AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

/*---------------------------------------------------------
   Name: ENT:Initialize()
---------------------------------------------------------*/
function ENT:Initialize()
	
	self.Owner = self:GetOwner()

	if !IsValid(self.Owner) then
		self:Remove()
		return
	end

	
	self:SetModel("models/props_junk/metal_paintcan001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	self.NextThink = CurTime() + 1
	self:DrawShadow(false)

	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(10)
	end

	util.SpriteTrail(self, 0, Color(255, 205, 155, 55), false, 1, 5, 0.8, 5 / ((2 + 10) * 0.5), "trails/smoke.vmt")
end


function ENT:Think()
	
	self.lifetime = self.lifetime or CurTime() + 20

	if CurTime() > self.lifetime then
		self:Remove()
	end

	if self.KillMe and !self.Killed then
		self:Disable()
	end

	if self.Flaming then
		local gays = ents.FindInSphere( self:GetPos(), 100 ) 
		for k, v in pairs( gays ) do
			if v:GetClass() == "bs_napalm_grenade" and !v.Flaming then
				v.Owner = self.Owner
				v:NapalmExplode()
			end
			if !v:IsPlayer() then continue end
			if !v:Alive() then continue end
			local d = DamageInfo()
			d:SetDamage( 1 )
			d:SetAttacker( self.Owner )
			d:SetDamageType( DMG_BURN )
			v:TakeDamageInfo( d )
			v:Ignite( 5 )
		end
	end

	self:NextThink( CurTime() + 0.05 )
	return true

end

local function makeburnie( pos )
	local fire = ents.Create("env_fire")
	fire:SetPos( pos )
	fire:SetKeyValue("health", 4 )
	fire:SetKeyValue("firesize", "128")
	fire:SetKeyValue("fireattack", "10")
	fire:SetKeyValue("damagescale", "0")
	fire:SetKeyValue("StartDisabled", "0")
	fire:SetKeyValue("firetype", "0")
	fire:SetKeyValue("spawnflags", "128")
	fire:Spawn()
	fire:Fire("StartFire", "", 0)
end

function ENT:NapalmExplode()
	if !self.Killed or self.Flaming then return end
	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	util.Effect("bs_shockwave", effectdata)

	local square = 30

	makeburnie( self:GetPos() + Vector( square, square, 0 ) )
	makeburnie( self:GetPos() + Vector( square, -square, 0 ) )
	makeburnie( self:GetPos() + Vector( -square, square, 0 ) )
	makeburnie( self:GetPos() + Vector( -square, -square, 0 ) )

	self.lifetime = CurTime() + 5
	self.Flaming = true

	self:EmitSound( "ambient/fire/mtov_flame2.wav", 80, math.random( 70, 90 ) )
end


function ENT:Disable()
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self.lifetime = CurTime() + 20
	self.Killed = true
	local phys = self:GetPhysicsObject()
	phys:EnableMotion( false )

	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	effectdata:SetNormal( Vector( 0, 0, 1 ) )
	effectdata:SetScale( 0.5 )
	util.Effect( "StriderBlood", effectdata, true, true )

	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	effectdata:SetScale( 2 )
	effectdata:SetFlags( 1 )
	util.Effect( "WaterSplash", effectdata, true, true )

	self:SetNWBool( "ActiveNapalm", true )

	if self:IsOnFire() then self:NapalmExplode() end

end


function ENT:PhysicsCollide(data, phys)
	if data.HitNormal.z > -0.8 or !data.HitEntity or !data.HitEntity:IsWorld() then return end
	self.KillMe = true
end

function ENT:OnTakeDamage( dmg )
	if dmg:IsExplosionDamage() then
		self:NapalmExplode()
	end
end