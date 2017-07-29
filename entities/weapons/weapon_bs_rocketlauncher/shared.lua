// Variables that are used on both client and server

--SWEP.Base 				= "weapon_melee_base"
SWEP.Instructions   = "Shoot People"
SWEP.ViewModelFlip		= false
SWEP.ViewModel				= "models/weapons/v_RL7.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/weapons/w_rl7.mdl"	-- Weapon world model
SWEP.ViewModelFOV 		= 50
SWEP.BobScale 			= 0
SWEP.HoldType			= "rpg"
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
SWEP.NxLoadBullet = 0

function SWEP:SetupDataTables()
end

/*---------------------------------------------------------
   Name: SWEP:Deploy()
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire( CurTime() + 1 )
	self:SetNextSecondaryFire( CurTime() + 1 )
	self:SetHoldType( "rpg" )

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
	surface.SetMaterial( circle )
	surface.DrawTexturedRect( x - 15, y - 15, 30, 30 )
	surface.SetDrawColor( Color(255,255,255, 20) )
	surface.DrawRect( x - 14, y - 1, 28, 2 )
	surface.DrawRect( x - 30, y - 1, 8, 2 )
	surface.DrawRect( x + 22, y - 1, 8, 2 )

	surface.SetDrawColor( Color(255,255,255, 150) )

end

function SWEP:LaunchRocket( mode )
	if CLIENT then return end

	local pos = self.Owner:GetShootPos()
	local rocket = ents.Create( "bs_rocket" )
	if !rocket:IsValid() then return end
	rocket:SetAngles(self.Owner:GetAimVector():Angle())
	rocket:SetPos( pos )
	rocket:SetOwner(self.Owner)
	rocket:Spawn()
	rocket.Mode = mode
	rocket.Owner = self.Owner
	rocket:Activate()
	local eyes = self.Owner:EyeAngles()
	local phys = rocket:GetPhysicsObject()
	phys:SetVelocity(self.Owner:GetAimVector() * 900)

end

function SWEP:PrimaryAttack()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	self:LaunchRocket( true )

	if SERVER and !self.Owner:IsNPC() then
		local anglo = Angle(-5, 0, 0)		
		self.Owner:ViewPunch(anglo)
	end

	self:SetNextPrimaryFire( CurTime() + 0.9 )
	self:SetNextSecondaryFire( CurTime() + 0.9 )
	self:EmitSound( "weapons/M79/40mmthump.wav", 90, 180, 0.5 )
end

function SWEP:SecondaryAttack()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	self:LaunchRocket( false )

	if SERVER and !self.Owner:IsNPC() then
		local anglo = Angle(-5, 0, 0)		
		self.Owner:ViewPunch(anglo)
	end

	self:SetNextPrimaryFire( CurTime() + 1 )
	self:SetNextSecondaryFire( CurTime() + 1 )
	self:EmitSound( "weapons/M79/40mmthump.wav", 90, 180, 0.5 )
end


function SWEP:Think()
end