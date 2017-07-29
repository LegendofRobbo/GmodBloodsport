// Variables that are used on both client and server

--SWEP.Base 				= "weapon_melee_base"
SWEP.Instructions   = "Use the pointy end on other people"
SWEP.ViewModelFlip		= false
SWEP.UseHands = true
SWEP.ViewModel			= "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel			= "models/weapons/w_knife_ct.mdl"
SWEP.ViewModelFOV 		= 60
SWEP.BobScale 			= 0
SWEP.HoldType			= "knife"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "Bloodsport"
SWEP.DrawCrosshair = false

SWEP.Author				= ""
SWEP.Contact			= ""

SWEP.Purpose			= "A combat knife"
SWEP.Instructions			= "Left click to slice, Right click to stab"

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

SWEP.Sequence			= 0
SWEP.LungeTime = 0
SWEP.ReboundTime = 0
SWEP.LungeHasHit = true
SWEP.NextThrow = 0

function SWEP:Precache()

    	util.PrecacheSound("weapons/knife/knife_slash1.wav")
    	util.PrecacheSound("weapons/knife/knife_hitwall1.wav")
    	util.PrecacheSound("weapons/knife/knife_deploy1.wav")
    	util.PrecacheSound("weapons/knife/knife_hit1.wav")
    	util.PrecacheSound("weapons/knife/knife_hit2.wav")
    	util.PrecacheSound("weapons/knife/knife_hit3.wav")
    	util.PrecacheSound("weapons/knife/knife_hit4.wav")
    	util.PrecacheSound("weapons/iceaxe/iceaxe_swing1.wav")
end


function SWEP:SetupDataTables()
--	self:NetworkVar( "Float", 0, "ThrowCharge" )
end


local circle = Material( "particle/particle_ring_wave_additive" )
local circle2 = Material( "particle/particle_ring_sharp" )
local beam = Material("trails/laser")
function SWEP:DrawHUD()
	local me = LocalPlayer()

	local x = ScrW() / 2
	local y = ScrH() / 2

	surface.SetDrawColor( Color(255,255,255, 50) )
	surface.DrawRect( x + 5, y - 1, 10, 2 )
	surface.DrawRect( x - 15, y - 1, 10, 2 )

end




/*---------------------------------------------------------
   Name: SWEP:Deploy()
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
	self:SetHoldType( "knife" )

	self.Weapon:EmitSound("weapons/knife/knife_deploy1.wav", 50, 100)

	return true
end


function SWEP:PrimaryAttack()

	self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
	local vm = self.Owner:GetViewModel()
	vm:SetSequence( vm:LookupSequence( "stab" ) )

	self.Weapon:SetNextPrimaryFire(CurTime() + 1.5)
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.5)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	local addupward = Vector( 0, 0, 50 )
	if self.Owner:IsOnGround() then 
		self.Owner:SetPos( self.Owner:GetPos() + Vector( 0, 0, 5 ) ) 
		addupward = Vector( 0, 0, 100 ) 
	end
	local myang = self.Owner:EyeAngles()
	myang = Angle( math.Clamp( myang.p, -20, 20 ), myang.y, 0 )
	self.Owner:SetVelocity( myang:Forward() * 400 + addupward )
	self.LungeTime = CurTime() + 0.45
	self.ReboundTime = CurTime() + 0.9
	self.LungeHasHit = false

	if SERVER then
		self.Owner:EmitSound( "weapons/knife/knife_slash1.wav", 90, math.random( 60, 70 ), 0.5 ) 
	end
end


function SWEP:Think()
	if CLIENT then return end
	if self.LungeTime > CurTime() and !self.LungeHasHit then
		local siz = 6
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 60,
			filter = self.Owner,
			mins = Vector( -siz, -siz, -siz ),
			maxs = Vector( siz, siz, siz )
		} )
		if tr.Entity and tr.Entity:IsValid() and tr.Entity:GetClass() == "bs_hammer_shield" then
			local d = DamageInfo()
			d:SetDamage( 1 )
			d:SetAttacker( self.Owner )
			d:SetDamageType( DMG_SLASH )
			tr.Entity:TakeDamageInfo( d )
			self.Owner:SetVelocity( self.Owner:GetVelocity() * -1.5 + Vector( 0, 0, 200 ) )
			self.LungeHasHit = true
			self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
			return
		end

		if tr.Entity and tr.Entity:IsPlayer() then
--			tr.Entity:Kill()
			local d = DamageInfo()
			d:SetDamage( 120 )
			d:SetAttacker( self.Owner )
			d:SetDamageType( DMG_SLASH )
			tr.Entity:TakeDamageInfo( d )

			local effectdata = EffectData()
			effectdata:SetOrigin( tr.HitPos )
			effectdata:SetNormal( tr.HitNormal )
			effectdata:SetMagnitude( 1 )
			effectdata:SetScale( 15 )
			effectdata:SetColor( 0 )
			effectdata:SetFlags( 3 )
			util.Effect( "bloodspray", effectdata, true, true )
			tr.Entity:EmitSound( "weapons/knife/knife_stab.wav", 90, 150 )
			self.LungeHasHit = true
		end
	elseif self.LungeTime < CurTime() and self.ReboundTime > CurTime() and !self.LungeHasHit then
		local siz = 15
		local tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 60,
			filter = self.Owner,
			mins = Vector( -siz, -siz, -siz ),
			maxs = Vector( siz, siz, siz )
		} )
		if tr.Entity and tr.Entity:IsPlayer() then
			self.Owner:SetVelocity( self.Owner:GetVelocity() * -1.5 + Vector( 0, 0, 200 ) )
			self.Owner:EmitSound( "physics/flesh/flesh_impact_hard1.wav" )
			self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
--			tr.Entity:EmitSound( "weapons/knife/knife_stab.wav", 90, 120 ) 
			self.LungeHasHit = true
		end
	else
		self.LungeHasHit = true
	end
end


function SWEP:GetViewModelPosition( pos, ang )
--	if self.NextThrow > CurTime() then return pos + ang:Forward() * -100, ang end
	return pos, ang
end



function SWEP:SecondaryAttack()
	if self.NextThrow > CurTime() then return end

	self.Weapon:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")
	self.Weapon:SetNextPrimaryFire(CurTime() + 1 )
	self.Weapon:SetNextSecondaryFire(CurTime() + 1 )
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)

	self.NextThrow = CurTime() + 3

	if (SERVER) then
		local knife = ents.Create("bs_knife_thrown")
		knife:SetAngles(self.Owner:EyeAngles())

		local pos = self.Owner:GetShootPos()
		pos = pos + self.Owner:GetForward() * 5
		pos = pos + self.Owner:GetRight() * 9
		pos = pos + self.Owner:GetUp() * -5
		knife:SetPos(pos)

		knife:SetOwner(self.Owner)
		knife:SetPhysicsAttacker(self.Owner)
		knife:Spawn()
		knife:Activate()

		self.Owner:SetAnimation(PLAYER_ATTACK1)

		local phys = knife:GetPhysicsObject()
		phys:SetVelocity(self.Owner:GetAimVector() * 1200)
		phys:AddAngleVelocity(Vector(0, 500, 0))
	end
end
