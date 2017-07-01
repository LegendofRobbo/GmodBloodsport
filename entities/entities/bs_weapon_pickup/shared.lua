ENT.Type 			= "anim"
--ENT.Base 			= "base_gmodentity"
ENT.PrintName			= "Weapon Pickup"
ENT.Author			= "LegendofRobbo"

ENT.Spawnable			= false
ENT.AdminOnly			= true

function ENT:Initialize()

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_NONE )
	self:SetModel("models/props_c17/clock01.mdl")
	self.RotateAngle = 0

	self.Panel = ents.Create("prop_dynamic_override")
	self.Panel:SetModel( "models/weapons/w_pist_deagle.mdl" )
	self.Panel:SetModelScale( 1, 0 )
	self.Panel:SetPos(self.Entity:GetPos() + self.Entity:GetAngles():Up() * 40)
	self.Panel:SetAngles(self:GetAngles())
	self.Panel:SetParent(self.Entity)
	self.Panel:SetSolid(SOLID_NONE)
	self.Panel:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.Panel:SetColor(Color(255,205,255,200))

	self.Active = false
	timer.Simple( 2, function() self.Active = true end )

end

function ENT:Use(activator, caller)
end 

function ENT:Think()
if !SERVER then return end
/*
for k, v in pairs(ents.FindInSphere(self:GetPos(), 80 )) do
	if v:IsPlayer() and v:Alive() and self.Active then
 		v:Give( "weapon_dm_oddball" )
 		v:SelectWeapon( "weapon_dm_oddball" )
 		DM_Broadcast( v:Nick().." has picked up the oddball!" )
 	self:Remove()
 	break
end
end
*/

local myang = self:GetAngles()

self.RotateAngle = self.RotateAngle + 2
if self.RotateAngle >= 360 then
	self.RotateAngle = -360
end
if self.Panel and self.Panel:IsValid() then
self.Panel:SetAngles(Angle( myang.p, self.RotateAngle, myang.r))
end

self:NextThink( CurTime() )
return true
end

function ENT:OnTakeDamage( dmg )
end