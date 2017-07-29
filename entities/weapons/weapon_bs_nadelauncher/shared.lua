// Variables that are used on both client and server

--SWEP.Base 				= "weapon_melee_base"
SWEP.Instructions   = "Shoot People"
SWEP.ViewModelFlip		= true
SWEP.ViewModel				= "models/weapons/v_milkor_mgl1.mdl"
SWEP.WorldModel				= "models/weapons/w_milkor_mgl1.mdl"
SWEP.ViewModelFOV 		= 80
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
SWEP.ActiveGrenades = {}

function SWEP:SetupDataTables()
end

/*---------------------------------------------------------
   Name: SWEP:Deploy()
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire( CurTime() + 1 )
	self:SetNextSecondaryFire( CurTime() + 1 )
	self:SetHoldType( "shotgun" )

	return true
end


local circle = Material( "particle/particle_ring_wave_additive" )
local circle2 = Material( "particle/particle_ring_sharp" )
local beam = Material("trails/laser")
function SWEP:DrawHUD()
	local me = LocalPlayer()

	local x = ScrW() / 2
	local y = ScrH() / 2

	surface.SetDrawColor( Color(255,255,255, 20) )
	surface.DrawRect( x - 13, y - 1, 28, 2 )
	surface.DrawRect( x - 15, y - 1, 2, 15 )
	surface.DrawRect( x + 14, y - 1, 2, 15 )

	surface.DrawRect( x - 10, y + 25, 21, 2 )
	surface.DrawRect( x - 10, y + 35, 21, 2 )
	surface.DrawRect( x - 10, y + 45, 21, 2 )

end

function SWEP:LaunchRocket( mode )
	if CLIENT then return end

	local pos = self.Owner:GetShootPos()
	local rocket = ents.Create( "bs_grenade" )
	if !rocket:IsValid() then return end
	rocket:SetAngles(self.Owner:GetAimVector():Angle())
	rocket:SetPos( pos )
	rocket:SetOwner(self.Owner)
	rocket:Spawn()
	rocket.Mode = mode
	rocket.Owner = self.Owner
	rocket:Activate()
	rocket:EmitSound( "weapons/M79/40mmthump.wav", 90, 250, 0.7 )
	local eyes = self.Owner:EyeAngles()
	local phys = rocket:GetPhysicsObject()
	phys:SetVelocity(self.Owner:GetAimVector() * 1500)
	table.insert( self.Owner.ActiveGrenades, rocket )
	self:VerifyMyGrenades()

end

function SWEP:VerifyMyGrenades()
	if !self.Owner.ActiveGrenades then self.Owner.ActiveGrenades = {} end
	for k, v in pairs( self.Owner.ActiveGrenades ) do
		if !v:IsValid() then table.remove( self.Owner.ActiveGrenades, k ) end
	end
end

function SWEP:PrimaryAttack()
	if !self.Owner.ActiveGrenades then self.Owner.ActiveGrenades = {} end
	if #self.Owner.ActiveGrenades >= 4 then self:VerifyMyGrenades() return end

	if CLIENT then return end

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	timer.Simple( 0.5, function() if self:IsValid() then self:SendWeaponAnim(ACT_VM_IDLE) end end )
	self:LaunchRocket( true )

	if SERVER and !self.Owner:IsNPC() then
		local anglo = Angle(-5, 0, 0)		
		self.Owner:ViewPunch(anglo)
	end

	self:SetNextPrimaryFire( CurTime() + 0.5 )
--	self:SetNextSecondaryFire( CurTime() + 0.1 )
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	for k, v in pairs( self.Owner.ActiveGrenades ) do
		if v:IsValid() then v.lifetime = CurTime() + math.Rand( 0.01, 0.2 ) end
	end
	self:VerifyMyGrenades()
	self.Owner:EmitSound( "buttons/button24.wav", 100, 100, 0.3 )
--	self:SetNextPrimaryFire( CurTime() + 0.1 )
	self:SetNextSecondaryFire( CurTime() + 0.1 )
end


function SWEP:Think()
end