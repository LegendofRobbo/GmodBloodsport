include('shared.lua')

function ENT:Draw()
	
	if !self:GetNWBool( "ActiveNapalm", false ) then self:DrawModel() return end

	if !self.SplatterPos then
		local tr = util.TraceLine( {start = self:GetPos(), endpos = self:GetPos() + Vector( 0, 0, -200), filter = self} )
		self.SplatterPos = tr.HitPos
		self.SplatterAng = tr.HitNormal:Angle()
		self.SplatterAng:RotateAroundAxis( self.SplatterAng:Right(), 270)
		self.SplatterAng:RotateAroundAxis( self.SplatterAng:Up(),  math.random( 0, 360) )
	end
	if !self.SplatterPos then return end

	cam.Start3D2D( self.SplatterPos + Vector( 0, 0, 1 ), self.SplatterAng, 0.6 )
		local bigness = 200
		local TexturedQuadStructure = {
			texture = surface.GetTextureID( 'particle/particle_smoke_dust' ),
			color   = Color(120,90,55, 250),
			x 	= -bigness / 2,
			y 	= -bigness / 2,
			w 	= bigness,
			h 	= bigness
		}
		draw.TexturedQuad( TexturedQuadStructure )
	cam.End3D2D()

end