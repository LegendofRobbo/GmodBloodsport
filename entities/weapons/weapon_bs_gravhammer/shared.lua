// Variables that are used on both client and server

--SWEP.Base 				= "weapon_melee_base"
SWEP.Instructions   = "Use the power of gravity itself to crush your foes into red paste"
SWEP.ViewModelFlip		= false
SWEP.UseHands = true
SWEP.ViewModel			= "models/legendofrobbo/bloodsport/c_grav_hammer.mdl"
SWEP.WorldModel			= "models/legendofrobbo/bloodsport/hammerbody.mdl"
SWEP.ViewModelFOV 		= 75
SWEP.BobScale 			= 0
SWEP.HoldType			= "melee2"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "Bloodsport"

SWEP.Author				= ""
SWEP.Contact			= ""

SWEP.Purpose			= "Smash things"
SWEP.Instructions			= "Left click to slam the ground, Right click to project a vortex shield that blocks projectiles"

SWEP.Primary.Recoil		= 5
SWEP.Primary.Damage		= 0
SWEP.Primary.NumShots		= 0
SWEP.Primary.Cone			= 0.075
SWEP.Primary.Delay 		= 0.6

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= ""


SWEP.Pistol				= true
SWEP.Rifle				= false
SWEP.Shotgun			= false
SWEP.Sniper				= false

SWEP.RunArmOffset 		= Vector (0.3671, 0.1571, 5.7856)
SWEP.RunArmAngle	 		= Vector (-37.4833, 2.7476, 0)


function SWEP:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Blocking" )
	self:NetworkVar( "Bool", 1, "EnergyFlash" )
end

/*---------------------------------------------------------
   Name: SWEP:Deploy()
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self:SetHoldType( "melee2" )
	self:SetBlocking( false )
	self:SetEnergyFlash( false )

	return true
end

function SWEP:Holster()
	if self.ShieldSound	then self.ShieldSound:Stop() end
end

function SWEP:Holster()
	if self.ShieldSound	then self.ShieldSound:Stop() end
	return true
end

function SWEP:OnRemove()
	if self.ShieldSound	then self.ShieldSound:Stop() end
end

function SWEP:PrimaryAttack()
self:SetNextPrimaryFire(CurTime() + 1.8)
self:SetNextSecondaryFire(CurTime() + 1.3)
self.Owner:ViewPunch( Angle( -5, 0, 3 ))
self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
timer.Simple( 0.05, function()
	if CLIENT or !self:IsValid() or !self.Owner:IsValid() then return end
	self.Owner:EmitSound( "npc/zombie/claw_miss1.wav", 85, 70 )
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end)

timer.Simple( 0.34, function()
	if !self:IsValid() then return end
	self:Bash()
end)

end

function SWEP:Bash()
	if CLIENT then return end
	self.Owner:ViewPunch( Angle( 5, 0, 0 ))

	local siz = 10
	local tr = util.TraceHull( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 110,
		filter = self.Owner,
		mins = Vector( -siz, -siz, -siz ),
		maxs = Vector( siz, siz, siz )
	} )
	if !tr.Hit then return end

	local blasted = ents.FindInSphere( tr.HitPos, 150 )
	for k, v in pairs( blasted ) do
		if !v:IsPlayer() or v == self.Owner then continue end
		local dist = v:GetPos():Distance( tr.HitPos )
			local d = DamageInfo()
			d:SetDamage( math.Clamp( 100 - (dist * 0.85), 1, 100 )  )
			d:SetAttacker( self.Owner )
			d:SetDamageType( DMG_CRUSH )
			v:TakeDamageInfo( d )
		local mul = 600
		if !v:IsOnGround() then mul = 300 end
		v:SetPos( v:GetPos() + Vector( 0, 0, 3 ) )
		v:SetVelocity( ( (v:GetPos() - tr.HitPos):GetNormal() * mul ) + Vector( 0, 0, mul / 4 ) )
	end

	if tr.Entity:IsPlayer() then
		local d = DamageInfo()
		d:SetDamage( 100 )
		d:SetAttacker( self.Owner )
		d:SetDamageType( DMG_CRUSH )
		d:SetDamageForce( self.Owner:GetAimVector() * 31210 )
		tr.Entity:TakeDamageInfo( d )
	end

	util.ScreenShake( self.Owner:GetPos(), 10, 15, 0.5, 300 )
	self.Weapon:EmitSound("npc/scanner/cbot_energyexplosion1.wav", 90, math.random( 95, 105 ) )
end

/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack()
   Desc: +attack2 has been pressed.
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self:SetBlocking( true )
	if !self.ShieldSound then self.ShieldSound = CreateSound( self, "weapons/physcannon/energy_sing_loop4.wav" ) end
	self.ShieldSound:PlayEx( 0.5, 100 )
	timer.Simple( 2, function() 
		if !self:IsValid() or !self.Owner:IsValid() then return end
		if self.Owner:GetActiveWeapon() and self.Owner:GetActiveWeapon() != self then return end
		self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
		self:SetBlocking( false )
		self.ShieldSound:Stop()
	end )
	self.Weapon:SetNextPrimaryFire(CurTime() + 2.2)
	self.Weapon:SetNextSecondaryFire(CurTime() + 2.6)
end


function SWEP:Think()
	if CLIENT then return end

	if self:GetBlocking() then
		if !self.ShieldEnt or !self.ShieldEnt:IsValid() then
			self.ShieldEnt = ents.Create( "bs_hammer_shield" )
			self.ShieldEnt:SetOwner( self.Owner )
			self.ShieldEnt:SetNWEntity( "ShieldOwner", self.Owner )
			self.ShieldEnt:Spawn()
			self.ShieldEnt:Activate()
		end
		local ang = self.Owner:EyeAngles()
		self.ShieldEnt:SetPos( self.Owner:EyePos() + self.Owner:GetAimVector() * 31 + Vector( 0, 0, -10 ) )
		self.ShieldEnt:SetAngles( self.Owner:EyeAngles() )
	else
		if self.ShieldEnt and self.ShieldEnt:IsValid() then self.ShieldEnt:Remove() end
	end
end


local illum = Material( "effects/ar2_altfire1" )
local flicker = Material( "particle/particle_sphere" )
local flash = Material( "particle/particle_ring_wave_additive" )

function SWEP:DrawWorldModel()
	
	local Pos, Ang = self.Owner:GetBonePosition( self.Owner:LookupBone("ValveBiped.Bip01_R_Hand") )
	
	self:SetRenderOrigin( Pos + Ang:Forward() * 4 + Ang:Up() * -2 + Ang:Right() * 2 )
	Ang:RotateAroundAxis(Ang:Up(),90)
	Ang:RotateAroundAxis(Ang:Right(),-90)

	self:SetRenderAngles(Ang)
	self:DrawModel()

	cam.Start3D()
		render.SetMaterial( illum )
		render.DrawQuadEasy( Pos + Ang:Forward() * 26 + Ang:Up() * -2 + Ang:Right() * 2, -EyeVector():GetNormal(), 15, 15, Color(255,255,255), 0 )
	cam.End3D()
	
end

function SWEP:PostDrawViewModel()
	if !self:IsValid() or !self.Owner:IsValid() or !self.Owner:Alive() then return end

	local vmodel = self.Owner:GetViewModel()

	local Pos, Ang = vmodel:GetBonePosition( vmodel:LookupBone("bigbopper") )

	cam.Start3D()
		render.SetMaterial( illum )
		render.DrawQuadEasy( Pos + Ang:Forward() * 31 + Ang:Right() * -5 + Ang:Up() * -0.5, -EyeVector():GetNormal(), 12, 12, Color(255,255,255), 0 )
		if self:GetBlocking() then
			render.SetMaterial( flash )
			render.DrawQuadEasy( Pos + Ang:Forward() * 10 + Ang:Right() * 14 + Ang:Up() * -10, -EyeVector():GetNormal(), 60, 60, Color(55,255,255, 55), 0 )
			render.SetMaterial( illum )
			render.DrawQuadEasy( Pos + Ang:Forward() * 10 + Ang:Right() * 14 + Ang:Up() * -10, -EyeVector():GetNormal(), 22, 22, Color(255,255,255), 0 )
			if self:GetEnergyFlash() then
				render.SetMaterial( flash )
				local wavef = math.abs( math.sin( CurTime() * 20 ) ) * 60
				local wavef2 = math.abs( math.cos( CurTime() * 20 ) ) * 60
				render.DrawQuadEasy( Pos + Ang:Forward() * 10 + Ang:Right() * 14 + Ang:Up() * -10, -EyeVector():GetNormal(), wavef, wavef2, Color(255,205,205, 255), 0 )
				--render.DrawQuadEasy( Pos + Ang:Forward() * 31 + Ang:Up() * -20, v:GetAimVector(), wavef, wavef2, Color(255,205,205, 255), 90 )
			end
		end

	cam.End3D()
end


hook.Add( "PostDrawOpaqueRenderables", "DrawHammerShieldsTest", function()
	/*
	for k, v in pairs( player.GetAll() ) do
		if !v:Alive() then continue end
		if v == LocalPlayer() then continue end
		local wep = v:GetActiveWeapon()
		if !wep or !wep:IsValid() or wep:GetClass() != "weapon_bs_gravhammer" then continue end
		if !wep:GetBlocking() then continue end
		local Pos, Ang = v:EyePos(), v:EyeAngles()
		cam.Start3D()
			render.SetMaterial( illum )
			render.DrawQuadEasy( Pos + Ang:Forward() * 31 + Ang:Up() * -20, v:GetAimVector(), 60, 60, Color(255,255,255, 55), 0 )
			render.SetMaterial( flash )
			render.DrawQuadEasy( Pos + Ang:Forward() * 31 + Ang:Up() * -20, v:GetAimVector(), 60, 60, Color(55,255,255, 55), 90 )
			if wep:GetEnergyFlash() then
				local wavef = math.abs( math.sin( CurTime() * 20 ) ) * 60
				local wavef2 = math.abs( math.cos( CurTime() * 20 ) ) * 60
				render.DrawQuadEasy( Pos + Ang:Forward() * 31 + Ang:Up() * -20, v:GetAimVector(), wavef, wavef2, Color(255,205,205, 255), 90 )
			end
		cam.End3D()
	end
	*/
end)