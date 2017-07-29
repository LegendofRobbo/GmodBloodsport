ENT.Type 			= "anim"
--ENT.Base 			= "base_gmodentity"
ENT.PrintName			= "Weapon Pickup"
ENT.Author			= "LegendofRobbo"

ENT.Spawnable			= false
ENT.AdminOnly			= true

local function GenericGiveWeapon( ply, gun )
	if !ply:IsValid() or !ply:Alive() then return false end
	if ply:HasWeapon( gun ) then return false end
	ply:Give( gun, true )
	ply:SelectWeapon( gun )
	return true
end

BS_PickupData = {
	["Combat Knife"] = { col = Color( 200, 200, 200 ), model = "models/weapons/w_knife_t.mdl", pickup = function( ply, ent ) return GenericGiveWeapon( ply, "weapon_bs_knife" ) end },
	["Gravity Hammer"] = { col = Color( 250, 200, 250 ), model = "models/legendofrobbo/bloodsport/hammerbody.mdl", angoffset = Angle( 90, 0, 0 ), pickup = function( ply, ent ) return GenericGiveWeapon( ply, "weapon_bs_gravhammer" ) end },
	["Magnum Pistol"] = { col = Color( 150, 150, 250 ), model = "models/weapons/w_pist_deagle.mdl", scale = 1.2, angoffset = Angle( 0, 0, 0 ), pickup = function( ply, ent ) return GenericGiveWeapon( ply, "weapon_bs_magnum" ) end },
	["Harpoon Bow"] = { col = Color( 150, 250, 150 ), model = "models/weapons/w_crossbow.mdl", pickup = function( ply, ent ) return GenericGiveWeapon( ply, "weapon_bs_harpoonbow" ) end },
	["Shotgun"] = { col = Color( 250, 250, 150 ), model = "models/weapons/w_shot_m3super90.mdl", pickup = function( ply, ent ) return GenericGiveWeapon( ply, "weapon_bs_shotgun" ) end },
	["Rocket Launcher"] = { col = Color( 250, 150, 150 ), model = "models/weapons/w_rl7.mdl", angoffset = Angle( 260, 0, 0 ), z = 20, pickup = function( ply, ent ) return GenericGiveWeapon( ply, "weapon_bs_rocketlauncher" ) end },
	["Flamethrower"] = { col = Color( 250, 200, 150 ), model = "models/weapons/w_flamer.mdl", angoffset = Angle( 0, 0, 0 ), pickup = function( ply, ent ) return GenericGiveWeapon( ply, "weapon_bs_flamethrower" ) end },
	["Grenade Launcher"] = { col = Color( 250, 150, 250 ), model = "models/weapons/w_milkor_mgl1.mdl", angoffset = Angle( 0, 0, 0 ), pickup = function( ply, ent ) return GenericGiveWeapon( ply, "weapon_bs_nadelauncher" ) end },
	["Thunder Gun"] = { col = Color( 150, 250, 250 ), model = "models/weapons/w_sanctum2_tr.mdl", angoffset = Angle( 0, 0, 0 ), pickup = function( ply, ent ) return GenericGiveWeapon( ply, "weapon_bs_thundergun" ) end },
	["Health Kit"] = { col = Color( 50, 150, 50 ), model = "models/Items/HealthKit.mdl", isitem = true, angoffset = Angle( 0, 0, 0 ), z = - 10, pickup = function( ply, ent ) if ply:Health() < 100 then ply:SetHealth( 100 ) return true else return false end end },
	["Armor Charger"] = { col = Color( 100, 100, 150 ), model = "models/Items/battery.mdl", isitem = true, angoffset = Angle( 0, 0, 0 ), scale = 2, z = -10, pickup = function( ply, ent ) if ply:Armor() < 100 then ply:SetArmor( math.Clamp( ply:Armor() + 50, 0, 100 ) ) return true else return false end end },
	["Combo Booster"] = { col = Color( 250, 100, 50 ), model = "models/Gibs/HGIBS.mdl", isitem = true, angoffset = Angle( 0, 0, 0 ), z = -10, pickup = function( ply, ent ) if !ply:GetNWBool( "X2Combo", false ) then ply:SetNWBool( "X2Combo", true ) return true else return false end end },
}




function ENT:Initialize()

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:SetModel("models/props_c17/clock01.mdl")
	self.RotateAngle = 0

	self.HoloDisplay = ents.Create("prop_dynamic_override")
	self.HoloDisplay:SetModel( "models/weapons/w_pist_deagle.mdl" )
	self.HoloDisplay:SetModelScale( 1, 0 )
	self.HoloDisplay:SetPos( self:GetPos() + self:GetAngles():Up() * 40 )
	self.HoloDisplay:SetAngles( self:GetAngles() )
	self.HoloDisplay:SetParent( self )
	self.HoloDisplay:SetSolid( SOLID_NONE)
	self.HoloDisplay:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.HoloDisplay:SetColor( Color(255,205,255,200) )
	self.Active = false
	self.ActiveInit = false
	self:SetMaterial( "effects/vol_lightmask02" )
	timer.Simple( 0, function() if self:IsValid() then self.Active = true end end )

end

function ENT:InitWeaponType()
	if self.ActiveInit then return end
	local pickuptype = self:GetNWString( "PickupType", "nil" )
	local ref = BS_PickupData[pickuptype]
	if !BS_PickupData[pickuptype] then self:Remove() return end

	self.HoloDisplay:SetModel( ref.model )
	self.HoloDisplay:SetPos( self:GetPos() + self:GetAngles():Up() * (40 + (ref.z or 0) ) )
	if ref.scale then self.HoloDisplay:SetModelScale( ref.scale ) end
	self.ActiveInit = true

end


function ENT:Use(activator, caller)
end 

function ENT:Think()
	if !SERVER or !self.Active then return end
	if !self.ActiveInit then self:InitWeaponType() return end
	local pickuptype = self:GetNWString( "PickupType", "nil" )
	if !BS_PickupData[pickuptype] then self:Remove() return end
	local ref = BS_PickupData[pickuptype]

	for k, v in pairs(ents.FindInSphere(self:GetPos(), 30 )) do
		if v:IsPlayer() and v:Alive() then
			if ref.pickup( v, self ) then
				if ref.isitem then
					v:EmitSound( "items/smallmedkit1.wav" )
				else
--					v:EmitSound( "items/gift_drop.wav" )
					v:EmitSound( "items/ammopickup.wav" )
				end
 				self:Remove()
	 			break
	 		end
		end

	end


	local myang = self:GetAngles()

	self.RotateAngle = self.RotateAngle + 2
	if self.RotateAngle >= 360 then
		self.RotateAngle = -360
	end
	if self.HoloDisplay and self.HoloDisplay:IsValid() then
		local newang = Angle( myang.p, self.RotateAngle, myang.r)
		if ref.angoffset then 
			newang:RotateAroundAxis( newang:Right(), ref.angoffset.p )
			newang:RotateAroundAxis( newang:Forward(), ref.angoffset.y )
			newang:RotateAroundAxis( newang:Up(), ref.angoffset.r )
		end
		self.HoloDisplay:SetAngles( newang )
	end

	self:NextThink( CurTime() )
	return true
end

function ENT:OnTakeDamage( dmg )
end