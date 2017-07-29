// Variables that are used on both client and server

--SWEP.Base 				= "weapon_melee_base"
SWEP.Instructions   = "Shoot People"
SWEP.ViewModelFlip		= false
SWEP.ViewModel				= "models/weapons/v_sanctum2_tr.mdl"
SWEP.WorldModel			= "models/weapons/w_sanctum2_tr.mdl"
SWEP.ViewModelFOV 		= 60
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
SWEP.Primary.Delay 		= 0.1

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= ""

SWEP.Primary.Sound 		= Sound("npc/vort/attack_shoot.wav")
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

	local gap = 20
	local x = ScrW() / 2
	local y = ScrH() / 2

	surface.SetDrawColor( Color(255,255,255, 50) )
	surface.DrawRect( x - 1, y + gap, 2, 10 )
	surface.DrawRect( x - 1, y - (gap + 11), 2, 10 )
	surface.DrawRect( x + gap, y - 1, 10, 2 )
	surface.DrawRect( x - (gap + 10), y - 1, 10, 2 )

end

function SWEP:BigZaps( mode )
	if CLIENT then return end

	local pos = self.Owner:GetShootPos()
	local rocket = ents.Create( "bs_thudergun_orb" )
	if !rocket:IsValid() then return end
	local wang = self.Owner:GetAimVector():Angle()
	wang:RotateAroundAxis( wang:Right(), 90 )
	rocket:SetAngles( wang )
	rocket:SetPos( pos )
	rocket:SetOwner(self.Owner)
	rocket:Spawn()
	rocket.Mode = mode
	rocket.Owner = self.Owner
	rocket:Activate()
	local eyes = self.Owner:EyeAngles()
	local phys = rocket:GetPhysicsObject()
	if mode then
		phys:SetVelocity(self.Owner:GetAimVector() * 9000)
	else
		phys:SetVelocity(self.Owner:GetAimVector() * 400)
	end

end


function SWEP:PrimaryAttack()

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self.Weapon:EmitSound(self.Primary.Sound, 90, math.random( 180, 200 ), 0.5 )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_SILENCED )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self:BigZaps( true )

end

function SWEP:SecondaryAttack()
--	self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
	self.Weapon:SetNextSecondaryFire( CurTime() + 3 )

	self.Weapon:EmitSound(self.Primary.Sound)
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_SILENCED )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )


	if IsFirstTimePredicted() then self.Owner:ViewPunch( Angle( -4, 0, 0 ) ) end

	self:BigZaps( false )

end


function SWEP:Think()
end