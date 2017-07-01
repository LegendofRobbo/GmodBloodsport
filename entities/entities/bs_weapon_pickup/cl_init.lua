include('shared.lua')

function ENT:Initialize()
end

surface.CreateFont( "BSPickupFont", { font = "Trebuchet MS", size = 34, weight = 100, antialias = true } )
local glowtower = Material( "effects/ar2ground2" )
local mycol = Color( 155, 155, 255, 255 )

function ENT:Draw()

	self:DrawModel()

	if self:GetPos():Distance(LocalPlayer():GetPos()) < 1200 then
		
		local direction = self:GetPos() - LocalPlayer():GetPos()
		x_d = direction.x
		y_d = direction.y
		
		Ang = Angle(0, math.deg(math.atan(y_d/x_d))+90/(x_d/-math.abs(x_d)), 90)
		cam.Start3D2D( self:GetPos() + self:GetUp()*80, Ang, 0.4)
			draw.SimpleTextOutlined( "Magnum Pistol", "BSPickupFont", 0, 0, mycol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 255))
		cam.End3D2D()

		local gcin = math.abs(math.sin(CurTime() * 2) * 60)
		local gcos = math.abs(math.cos(CurTime() * 2) * 60)
		cam.Start3D()
			render.SetMaterial( glowtower )
			render.DrawBeam( self:GetPos() + Vector( 0, 0, 2 ), self:GetPos() + Vector( 0, 0, 80 + gcin ), 32, 1, 0, mycol )
		cam.End3D()

		cam.Start3D2D(self:GetPos() + self:GetUp() * 2, self:GetAngles(), 0.6)
			local TexturedQuadStructure = {
				texture = surface.GetTextureID( 'particle/particle_ring_wave_additive' ),
				color   = mycol,
				x 	= -50,
				y 	= -50,
				w 	= 100,
				h 	= 100
			}
			draw.TexturedQuad( TexturedQuadStructure )
		cam.End3D2D()


	end
end