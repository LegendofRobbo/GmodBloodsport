include("shared.lua")

local illum = Material( "effects/ar2_altfire1" )
local flicker = Material( "particle/particle_sphere" )
local flash = Material( "particle/particle_ring_wave_additive" )

function ENT:Draw()
	local owner = self:GetNWEntity( "ShieldOwner" )
	if !owner or !owner:IsValid() then return end
	if owner == LocalPlayer() then return end
	local Pos, Ang = self:GetPos(), owner:GetAimVector()

	cam.Start3D()
		render.SetMaterial( illum )
		render.DrawQuadEasy( Pos, Ang, 60, 60, Color(255,255,255, 55), 0 )
		render.SetMaterial( flash )
		render.DrawQuadEasy( Pos, Ang, 60, 60, Color(55,255,255, 55), 90 )

		if self:GetNWBool( "Flashing" ) then
			self.FlashLerp = 255
		elseif (self.FlashLerp or 0) >= 55 then
			render.DrawQuadEasy( Pos, Ang, 62, 62, Color(255,255,255, self.FlashLerp), 0 )
			self.FlashLerp = self.FlashLerp - 10
		end
	cam.End3D()

--    self.Entity:DrawModel()
end