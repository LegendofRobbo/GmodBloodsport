// Variables that are used on both client and server

--SWEP.Base 				= "weapon_melee_base"
SWEP.Instructions   = "Shoot People"
SWEP.ViewModelFlip		= false
SWEP.ViewModel			= "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_deagle.mdl"
SWEP.ViewModelFOV 		= 50
SWEP.BobScale 			= 0
SWEP.HoldType			= "revolver"
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
	self:NetworkVar( "Bool", 0, "Zoomed" )
	self:NetworkVar( "Float", 0, "Boolets" )
end

/*---------------------------------------------------------
   Name: SWEP:Deploy()
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.8 )
	self:SetHoldType( "revolver" )
	self:SetZoomed( false )

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
	surface.DrawRect( x - 1, y + 5, 2, 10 )
	surface.DrawRect( x - 1, y - 16, 2, 10 )
	surface.DrawRect( x + 5, y - 1, 10, 2 )
	surface.DrawRect( x - 15, y - 1, 10, 2 )

	surface.SetDrawColor( Color(255,255,255, 150) )
	surface.DrawRect( x - 1, y + 5, 2, 2 )
	surface.DrawRect( x - 1, y - 6, 2, 2 )
	surface.DrawRect( x + 5, y - 1, 2, 2 )
	surface.DrawRect( x - 6, y - 1, 2, 2 )

	if !self:GetZoomed() then return end
	local scrw, scrh = ScrW(), ScrH()

	local scx, scy = scrw / 2, scrh / 2	
	surface.SetDrawColor( Color(225,225,255, 200) )
	surface.SetMaterial( circle2 )
	surface.DrawTexturedRect(scx - 20, scy - 20, 40, 40)
	surface.SetDrawColor( Color(225,225,255, 255) )
	surface.DrawTexturedRect(scx - 10, scy - 10, 20, 20)
	surface.SetDrawColor( Color(225,225,255, 10) )
	surface.SetMaterial( circle )
	surface.DrawTexturedRect(scx - 100, scy - 100, 200, 200)

	surface.SetDrawColor( Color(225,225,255, 5) )
	surface.DrawTexturedRect(scx - 200, scy - 200, 400, 400)

	surface.SetDrawColor( Color(225,225,255, 100) )
	surface.SetMaterial( beam )
--	surface.SetDrawColor( memecol1solid )
	surface.DrawTexturedRectRotated(scx - 50, scy, 5, 80, 90 )
	surface.DrawTexturedRectRotated(scx + 50, scy, 5, 80, 90 )

	local it = x - 28
	for i = 1, 4 do
		surface.SetDrawColor( Color(255,255,255, 30) )
		surface.DrawRect( it, y + 25, 10, 6 )
		it = it + 15
	end

	it = x - 28
	for i = 1, self:GetBoolets() do
		surface.SetDrawColor( Color(255,255,255, 250) )
		surface.DrawRect( it, y + 25, 10, 6 )
		it = it + 15
	end


end

function SWEP:PrimaryAttack()

	if self:GetZoomed() then return end

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )

	self.Weapon:EmitSound(self.Primary.Sound)
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if IsFirstTimePredicted() then self.Owner:ViewPunch( Angle( -1, 0, 0 ) ) end

	self:CSShootBullet( 50, 0, 1, 0.008 )
end

function SWEP:SecondaryAttack()
	if !self.Owner:IsOnGround() or self.Owner:GetVelocity():Length() > 400 then return end

	self.Weapon:SetNextPrimaryFire( CurTime() + 0.1 )
	self.Weapon:SetNextSecondaryFire( CurTime() + 0.1 )

	self:SetZoomed( !self:GetZoomed() )
	self:FireChargedShot()
	if SERVER then
		if self:GetZoomed() then self.Owner:SetFOV(60, 0.2) else self.Owner:SetFOV(0, 0.2) end
	end
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
--	if CLIENT then return end
	if self:GetZoomed() and (!self.Owner:IsOnGround() or self.Owner:GetVelocity():Length() > 400 ) then 
		self:SetZoomed( false )
		self.Owner:SetFOV(0, 0.2)
		self:FireChargedShot()
--		self:SetBoolets( 0 )
	end

	if self:GetZoomed() then
		if self.Owner:KeyDown( IN_ATTACK ) then
			if self:GetBoolets() < 4 and self.NxLoadBullet <= CurTime() then
				if SERVER then 
					self:SetBoolets( self:GetBoolets() + 1 )
					self.NxLoadBullet = CurTime() + 0.6
					self.Owner:EmitSound( "weapons/shotgun/shotgun_reload2.wav", 70, 70 )
				end
			end
		else
			self:FireChargedShot()
		end
	end	


end

function SWEP:FireChargedShot()
	if self:GetBoolets() < 1 then return end
	self.Weapon:SetNextPrimaryFire( CurTime() + (self.Primary.Delay * 2) + (self:GetBoolets() * 0.1) )
	self.Weapon:SetNextSecondaryFire( CurTime() + (self.Primary.Delay * 2) + (self:GetBoolets() * 0.1) )
	for i = 1, self:GetBoolets() do 
		timer.Simple( (i-1) * 0.05, function() if self:IsValid() then self:EmitSound(self.Primary.Sound) end end )
	end
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	if IsFirstTimePredicted() then self.Owner:ViewPunch( Angle( -self:GetBoolets(), 0, 0 ) ) end
	self:CSShootBullet( 50, 0, self:GetBoolets(), 0.01 )
	self:SetBoolets( 0 )
	self.NxLoadBullet = CurTime() + 1
end