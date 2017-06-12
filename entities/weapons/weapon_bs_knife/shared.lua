// Variables that are used on both client and server

--SWEP.Base 				= "weapon_melee_base"
SWEP.Instructions   = "Use the pointy end on other people"
SWEP.ViewModelFlip		= false
SWEP.ViewModel			= "models/weapons/v_knife_t.mdl"
SWEP.WorldModel			= "models/weapons/w_knife_ct.mdl"
SWEP.ViewModelFOV 		= 70
SWEP.BobScale 			= 1
SWEP.HoldType			= "knife"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "Bloodsport"

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

/*---------------------------------------------------------
   Name: SWEP:Precache()
---------------------------------------------------------*/
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

/*---------------------------------------------------------
   Name: SWEP:Deploy()
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self:SetHoldType( "knife" )

	self.Weapon:EmitSound("weapons/knife/knife_deploy1.wav", 50, 100)

	return true
end


function SWEP:PrimaryAttack()

	self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
	local vm = self.Owner:GetViewModel()
	vm:SetSequence( vm:LookupSequence( "stab" ) )

	self.Weapon:SetNextPrimaryFire(CurTime() + 1.5)
	self.Weapon:SetNextSecondaryFire(CurTime() + 1.5)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	local addupward = Vector( 0, 0, 0 )
	if self.Owner:IsOnGround() then self.Owner:SetPos( self.Owner:GetPos() + Vector( 0, 0, 5 ) ) addupward = Vector( 0, 0, 100 ) end
	self.Owner:SetVelocity( self.Owner:EyeAngles():Forward() * 400 + addupward )
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
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 60,
			filter = self.Owner,
			mins = Vector( -siz, -siz, -siz ),
			maxs = Vector( siz, siz, siz )
		} )
		if tr.Entity and tr.Entity:IsPlayer() then
			self.Owner:SetVelocity( self.Owner:GetVelocity() * -1.5 + Vector( 0, 0, 200 ) )
			self.Owner:EmitSound( "physics/flesh/flesh_impact_hard1.wav" )
--			tr.Entity:EmitSound( "weapons/knife/knife_stab.wav", 90, 120 ) 
			self.LungeHasHit = true
		end
	else
		self.LungeHasHit = true
	end
end





function SWEP:SecondaryAttack()
	/*
	if self.Weapon:GetNetworkedBool("Holsted") or self.Owner:KeyDown(IN_SPEED) then return end

	// Holst/Deploy your fucking weapon
	if (not self.Owner:IsNPC() and self.Owner:KeyDown(IN_USE)) then
		bHolsted = !self.Weapon:GetDTBool(0)
		self:SetHolsted(bHolsted)

		self.Weapon:SetNextPrimaryFire(CurTime() + 0.3)
		self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)

		self:SetIronsights(false)

		return
	end

	self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
	local Animation = self.Owner:GetViewModel()
	Animation:SetSequence(Animation:LookupSequence("stab"))


	self:SetHoldType("knife")
--	timer.Simple(1, function() if self:IsValid() then self:SetHoldType("normal") end end)

	timer.Simple( 0.1, function()
	if ( !IsValid( self ) || !IsValid( self.Owner ) || !self.Owner:GetActiveWeapon() || self.Owner:GetActiveWeapon() != self || CLIENT ) then return end
	self:DealDamage( anim )
	self.Owner:EmitSound( "weapons/slam/throw.wav" )
	end )

	timer.Simple( 0.02, function()
	if ( !IsValid( self ) || !IsValid( self.Owner ) || !self.Owner:GetActiveWeapon() || self.Owner:GetActiveWeapon() != self ) then return end
	self.Owner:ViewPunch( Angle(-0.3, -0.3, 0.5) )
	end )

	timer.Simple( 0.2, function()
	if ( !IsValid( self ) || !IsValid( self.Owner ) || !self.Owner:GetActiveWeapon() || self.Owner:GetActiveWeapon() != self ) then return end
	self.Owner:ViewPunch( Angle( math.Rand(0.5,1.5), 0.5, -0.5 ) )
	end )

	if self.Weapon:GetNetworkedBool("Holsted") then return end

	self.Weapon:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	self.Owner:SetAnimation(PLAYER_ATTACK1)



	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end

	self:IdleAnimation(1)
end

function SWEP:DealDamage( anim )
	local anim = self:GetSequenceName(self.Owner:GetViewModel():GetSequence())

	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
		filter = self.Owner
	} )

	if ( !IsValid( tr.Entity ) ) then 
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
			filter = self.Owner,
			mins = Vector( -10, -10, -8 ),
			maxs = Vector( 10, 10, 8 )
		} )
	end

	if ( tr.Hit ) then
	if (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity.Type == "nextbot") then 

		local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetStart(tr.HitPos)
		util.Effect("BloodImpact", effectdata)

		if ( anim == "stab" ) then
		self.Weapon:EmitSound("weapons/knife/knife_stab.wav", 80, 120)
		else
		self.Weapon:EmitSound("weapons/knife/knife_hit"..math.random(1,4)..".wav", 80, 100)
		end
	else
	self.Weapon:EmitSound( "weapons/knife/knife_hitwall1.wav", 70, math.Rand(85, 95) )
	end
--	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)

	end


	if ( IsValid( tr.Entity ) && ( tr.Entity:IsNPC() || tr.Entity:IsPlayer() || tr.Entity.Type == "nextbot" ||tr.Entity:GetClass() == "prop_physics" || tr.Entity:GetClass() == "func_breakable" || tr.Entity:Health() > 0 ) ) then
		local dmginfo = DamageInfo()
		if ( anim == "stab" ) then
		dmginfo:SetDamage( math.random( 28, 32 ) )
		else
		dmginfo:SetDamage( math.random( 18, 22 ) )
		end
		dmginfo:SetDamageForce( self.Owner:GetRight() * 300 + self.Owner:GetForward() * 200 ) -- Yes we need those specific numbers
		dmginfo:SetInflictor( self )
		local attacker = self.Owner
		if ( !IsValid( attacker ) ) then attacker = self end
		dmginfo:SetAttacker( attacker )

		tr.Entity:TakeDamageInfo( dmginfo )
	end
	*/
end