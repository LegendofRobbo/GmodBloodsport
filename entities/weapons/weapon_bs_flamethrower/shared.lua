// Variables that are used on both client and server

--SWEP.Base 				= "weapon_melee_base"
SWEP.Instructions   = "Shoot People"
SWEP.ViewModelFlip		= false
SWEP.ViewModel			= "models/weapons/v_flamer.mdl"
SWEP.WorldModel			= "models/weapons/w_flamer.mdl"
SWEP.ViewModelFOV 		= 55
SWEP.BobScale 			= 0
SWEP.HoldType			= "shotgun"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "Bloodsport"
SWEP.UseHands = false
SWEP.DrawCrosshair = false

SWEP.Author				= ""
SWEP.Contact			= ""

SWEP.Purpose			= ""
SWEP.Instructions			= ""

SWEP.Primary.Recoil		= 5
SWEP.Primary.Damage		= 0
SWEP.Primary.NumShots		= 0
SWEP.Primary.Cone			= 0.075
SWEP.Primary.Delay 		= 0.1

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= ""

SWEP.Primary.Sound 		= Sound("Weapon_M3.Single")
SWEP.Primary.Sound2 		= Sound("Weapon_SHOTGUN.Double")

SWEP.Pistol				= true
SWEP.Rifle				= false
SWEP.Shotgun			= false
SWEP.Sniper				= false
SWEP.NxGrenade = 0

/*---------------------------------------------------------
   Name: SWEP:Deploy()
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SetNextPrimaryFire( CurTime() + 0.8 )
	self.Weapon:SetNextSecondaryFire( CurTime() + 0.8 )
	self:SetHoldType( "shotgun" )
	self.Burnies = CreateSound( self.Weapon, "ambient/fire/fire_small_loop1.wav" )

	return true
end

local circle = Material( "particle/particle_ring_wave_additive" )
local circle2 = Material( "particle/particle_ring_sharp" )
local beam = Material("trails/laser")
function SWEP:DrawHUD()
	local me = LocalPlayer()

	local x = ScrW() / 2
	local y = ScrH() / 2

	surface.SetDrawColor( Color(255,255,255, 50) )
	surface.SetMaterial( circle2 )
	surface.DrawTexturedRect( x - 30, y - 30, 60, 60 )

end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.1 )
--	self.Weapon:SetNextSecondaryFire( CurTime() + 0.1 )

	local effectdata = EffectData()
	effectdata:SetOrigin( self.Owner:GetShootPos() + self.Owner:GetAimVector() * 1 + self.Owner:GetUp() * -10 + self.Owner:GetRight() * 5 )
	effectdata:SetNormal( self.Owner:GetAimVector() )
	effectdata:SetEntity( self.Owner )
	util.Effect("bs_flamethrower_flames", effectdata)

	if !self.Burnies then
		self.Burnies = CreateSound( self.Weapon, "ambient/fire/fire_small_loop1.wav" )
		self.Burnies:SetSoundLevel( 85 )
		self.Burnies:Play()
	elseif self.Burnies and !self.Burnies:IsPlaying() then
		self.Burnies:SetSoundLevel( 85 )
		self.Burnies:Play()
	end

	/*
	local trc = util.TraceLine( {start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 160, filter = self.Owner} )
	if trc.Hit then
		local effectdata = EffectData()
		effectdata:SetOrigin( trc.HitPos )
		effectdata:SetNormal( Vector( 0, 0, 0 ) )
		effectdata:SetEntity( game.GetMap() )
		util.Effect("bs_flamethrower_flames", effectdata)
	end
	*/

	if CLIENT then return end

--	local gays = ents.FindInCone( self.Owner:GetShootPos(), self.Owner:GetAimVector(), 200, 50 )
	local gays = ents.FindInSphere( self.Owner:GetShootPos() + self.Owner:GetAimVector() * 160, 100 ) 
	for k, v in pairs( gays ) do
		self:IgniteNapalm( v )

		if v == self.Owner or !v:IsPlayer() then continue end
		if !v:Alive() or !v:Visible( self.Owner ) then continue end
		local d = DamageInfo()
		d:SetDamage( 7 )
		d:SetAttacker( self.Owner )
		d:SetDamageType( DMG_BURN )
		v:TakeDamageInfo( d )
		v:Ignite( 4 )
	end

end

function SWEP:SecondaryAttack()
	if self.NxGrenade > CurTime() then return end

	self.Weapon:EmitSound("weapons/ar2/ar2_altfire.wav")
--	self.Weapon:SetNextPrimaryFire(CurTime() + 0.5 )
	self.Weapon:SetNextSecondaryFire(CurTime() + 1.5 )

	self.NxGrenade = CurTime() + 1

	local ef = EffectData()
	ef:SetOrigin( self.Owner:GetShootPos() + self.Owner:GetAimVector() * 5 )
	ef:SetScale( 1 )
	ef:SetStart( Vector(255, 205, 155) )
	util.Effect( "bs_smoke_puff", ef )

	if (SERVER) then
		local nade = ents.Create("bs_napalm_grenade")
		nade:SetAngles(self.Owner:EyeAngles())

		local pos = self.Owner:GetShootPos()
		pos = pos + self.Owner:GetForward() * 5
		pos = pos + self.Owner:GetRight() * 9
		pos = pos + self.Owner:GetUp() * -5
		nade:SetPos(pos)
		nade:SetOwner(self.Owner)
		nade:SetPhysicsAttacker(self.Owner)
		nade:Spawn()
		nade:Activate()
		nade.Owner = self.Owner

		self.Owner:SetAnimation(PLAYER_ATTACK1)

		local phys = nade:GetPhysicsObject()
		phys:SetVelocity(self.Owner:GetAimVector() * 800)
		phys:AddAngleVelocity(Vector(0, 500, 0))
		self.Owner:ViewPunch( Angle( -5, 0, 0 ) )
	end
end

function SWEP:IgniteNapalm( ent )
	if !ent:IsValid() or ent:GetClass() != "bs_napalm_grenade" then return end
	if !ent:GetNWBool( "ActiveNapalm", false ) then ent:Ignite( 20 ) return end

	ent:NapalmExplode()
end

function SWEP:Think()
--	if CLIENT then return end
	if !self.Owner:KeyDown( IN_ATTACK ) and self.Burnies and self.Burnies:IsPlaying() then self.Burnies:Stop() end
end

function SWEP:OnRemove()
	if self.Burnies and self.Burnies:IsPlaying() then self.Burnies:Stop() end
end

function SWEP:Holster()
	if self.Burnies and self.Burnies:IsPlaying() then self.Burnies:Stop() end
	return true
end