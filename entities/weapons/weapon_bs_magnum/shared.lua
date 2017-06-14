// Variables that are used on both client and server

--SWEP.Base 				= "weapon_melee_base"
SWEP.Instructions   = "Shoot People"
SWEP.ViewModelFlip		= false
SWEP.ViewModel			= "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_deagle.mdl"
SWEP.ViewModelFOV 		= 50
SWEP.BobScale 			= 1
SWEP.HoldType			= "revolver"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "Bloodsport"
SWEP.UseHands = true

SWEP.Author				= ""
SWEP.Contact			= ""

SWEP.Purpose			= ""
SWEP.Instructions			= ""

SWEP.Primary.Recoil		= 5
SWEP.Primary.Damage		= 0
SWEP.Primary.NumShots		= 0
SWEP.Primary.Cone			= 0.075
SWEP.Primary.Delay 		= 0.3

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= ""

SWEP.Primary.Sound 		= Sound("Weapon_Deagle.Single")

SWEP.Pistol				= true
SWEP.Rifle				= false
SWEP.Shotgun			= false
SWEP.Sniper				= false


function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "Boolets" )
end

/*---------------------------------------------------------
   Name: SWEP:Deploy()
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.8 )
	self:SetHoldType( "revolver" )

	return true
end


function SWEP:PrimaryAttack()

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )

	self.Weapon:EmitSound(self.Primary.Sound)
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if IsFirstTimePredicted() then self.Owner:ViewPunch( Angle( -1, 0, 0 ) ) end

--	self:TakePrimaryAmmo(1)

--	self:ShootBulletInformation()
	self:CSShootBullet( 50, 0, 1, 0.005 )
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

/*
	if CLIENT and IsFirstTimePredicted() then
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		eyeang.yaw = eyeang.yaw - ((math.Rand(-recoil, recoil) ) * self.Primary.RecoilHorizontal)
		self.Owner:SetEyeAngles( eyeang )
	end
*/

end