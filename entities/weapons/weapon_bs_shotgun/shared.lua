// Variables that are used on both client and server

--SWEP.Base 				= "weapon_melee_base"
SWEP.Instructions   = "Shoot People"
SWEP.ViewModelFlip		= false
SWEP.ViewModel			= "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel			= "models/weapons/w_shot_m3super90.mdl"
SWEP.ViewModelFOV 		= 50
SWEP.BobScale 			= 0
SWEP.HoldType			= "shotgun"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "Bloodsport"
SWEP.UseHands = true
SWEP.DrawCrosshair = false

SWEP.Author				= ""
SWEP.Contact			= ""

SWEP.Purpose			= ""
SWEP.Instructions			= ""

SWEP.Primary.Recoil		= 5
SWEP.Primary.Damage		= 0
SWEP.Primary.NumShots		= 0
SWEP.Primary.Cone			= 0.075
SWEP.Primary.Delay 		= 1

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= ""

SWEP.Primary.Sound 		= Sound("Weapon_M3.Single")
SWEP.Primary.Sound2 		= Sound("Weapon_SHOTGUN.Double")

SWEP.Pistol				= true
SWEP.Rifle				= false
SWEP.Shotgun			= false
SWEP.Sniper				= false

/*---------------------------------------------------------
   Name: SWEP:Deploy()
---------------------------------------------------------*/
function SWEP:Deploy()

--	self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.8 )
	self:SetHoldType( "shotgun" )

	return true
end

local circle = Material( "particle/particle_ring_wave_additive" )
local circle2 = Material( "particle/particle_ring_sharp" )
local beam = Material("trails/laser")
function SWEP:DrawHUD()
	local me = LocalPlayer()

	local gap = 40
	local x = ScrW() / 2
	local y = ScrH() / 2

	surface.SetDrawColor( Color(255,255,255, 50) )
	surface.DrawRect( x - 1, y + gap, 2, 10 )
	surface.DrawRect( x - 1, y - (gap + 11), 2, 10 )
	surface.DrawRect( x + gap, y - 1, 10, 2 )
	surface.DrawRect( x - (gap + 10), y - 1, 10, 2 )

end

function SWEP:PrimaryAttack()

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )

	self.Weapon:EmitSound(self.Primary.Sound)
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )


	if IsFirstTimePredicted() then self.Owner:ViewPunch( Angle( -2, 0, 0 ) ) end

	self:CSShootBullet( 12, 0, 10, 0.075 )

end

function SWEP:SecondaryAttack()

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay * 2 )

	self.Weapon:EmitSound( "weapons/flaregun/fire.wav", 90, 50)
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )


	if IsFirstTimePredicted() then self.Owner:ViewPunch( Angle( -8, 1, 0 ) ) end

	local ef = EffectData()
	ef:SetOrigin( self.Owner:GetShootPos() + self.Owner:GetAimVector() * 2 )
	ef:SetScale( 1 )
	ef:SetStart( Vector(25, 25, 25) )
	util.Effect( "bs_smoke_puff", ef )

	local ef = EffectData()
	ef:SetOrigin( self.Owner:GetShootPos() + self.Owner:GetAimVector() * 20 )
	ef:SetScale( 2 )
	ef:SetStart( Vector(25, 25, 25) )
	util.Effect( "bs_smoke_puff", ef )

	self:CSShootBullet( 14, 0, 10, 0.575 )

	if SERVER then
		self.Owner:SetVelocity( self.Owner:EyeAngles():Forward() * -400 + Vector( 0, 0, 100 ) )
	end

--	self:CSShootBullet( 10, 0, 8, 0.1 )

end

function SWEP:CSShootBullet( dmg, recoil, numbul, cone )

	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01
	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= Vector( cone, cone, 0 )			// Aim Cone
	bullet.Tracer	= self.TracerNum
	bullet.TracerName = self.TracerName
	bullet.Force	= 5
	bullet.Damage	= dmg
	bullet.Callback	= function(attacker, tr, dmginfo) 

		if tr.Entity:IsPlayer() or tr.Entity:IsNPC() then

			if tr.HitGroup == HITGROUP_HEAD then
				tr.Entity:EmitSound("player/headshot"..math.random(1, 2)..".wav", 80, math.random(95,105))
				local effectdata = EffectData()
				effectdata:SetOrigin( tr.HitPos )
				effectdata:SetNormal( tr.HitNormal )
				effectdata:SetMagnitude( 1 )
				effectdata:SetScale( 8 )
				effectdata:SetColor( 0 )
				effectdata:SetFlags( 3 )
				util.Effect( "bloodspray", effectdata, true, true )
			end

		end
	end
	self.Owner:FireBullets( bullet )

end


function SWEP:Think()
end