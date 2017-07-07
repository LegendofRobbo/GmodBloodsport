include('shared.lua')

function ENT:Initialize()
end

surface.CreateFont( "BSPickupFont", { font = "Trebuchet MS", size = 34, weight = 100, antialias = true } )
local glowtower = Material( "effects/ar2ground2" )

function ENT:Draw()

	self:DrawModel()

	if !BS_PickupData then return end
	local pickuptype = self:GetNWString( "PickupType", "nil" )
	if !BS_PickupData[pickuptype] then return end
	local ref = BS_PickupData[pickuptype]
	local mycol = ref.col

--	if self:GetPos():Distance(LocalPlayer():GetPos()) < 4000 then
		
		local direction = self:GetPos() - LocalPlayer():GetPos()
		x_d = direction.x
		y_d = direction.y
		
		Ang = Angle(0, math.deg( math.atan(y_d/x_d) ) + 90 / ( x_d / -math.abs(x_d) ), 90 )
		cam.Start3D2D( self:GetPos() + self:GetUp() * 80, Ang, 0.4 )
			draw.SimpleTextOutlined( pickuptype, "BSPickupFont", 0, 0, mycol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 255))
		cam.End3D2D()

		local gcin = math.abs(math.sin(CurTime() * 2) * 60)
		local gheight = Vector( 0, 0, 80 + gcin )
		if ref.isitem then gheight = Vector( 0, 0, 30 + (gcin / 2) ) end
		local gcos = math.abs(math.cos(CurTime() * 2) * 60)
		cam.Start3D()
			render.SetMaterial( glowtower )
			render.DrawBeam( self:GetPos() + Vector( 0, 0, 2 ), self:GetPos() + gheight, 32, 1, 0, mycol )
		cam.End3D()

		cam.Start3D2D(self:GetPos() + self:GetUp() * 2, self:GetAngles(), 0.6)
			local size = 100
			if ref.isitem then size = 75 end
			local TexturedQuadStructure = {
				texture = surface.GetTextureID( 'particle/particle_ring_wave_additive' ),
				color   = mycol,
				x 	= -(size / 2),
				y 	= -(size / 2),
				w 	= size,
				h 	= size
			}
			draw.TexturedQuad( TexturedQuadStructure )
		cam.End3D2D()


--	end
end
