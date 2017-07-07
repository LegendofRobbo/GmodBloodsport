

EFFECT.Mat = Material( "effects/stunstick" )

--[[---------------------------------------------------------
   Init( data table )
-----------------------------------------------------------]]
function EFFECT:Init( data )

	self.Position = data:GetOrigin()
	self.Life = 0;

	local emitter = ParticleEmitter(data:GetOrigin())
	local Pos = data:GetOrigin()

	for i = 1, 6 do
		local particle = emitter:Add("effects/tool_tracer", Pos)

		if (particle) then
			particle:SetVelocity( VectorRand() * 150 )
				
			particle:SetDieTime( 0.3 )
				
			particle:SetColor( 255, 255, 255)			

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
				
			particle:SetStartSize( 5 )
			particle:SetEndSize( math.random( 10, 20 ) )
				
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-3.21, 3.21))
				
			particle:SetAirResistance(math.Rand(70, 150))
				
			particle:SetGravity(Vector(0, 0, -5))

			particle:SetCollide(false)
			particle:SetBounce(0.45)
		end
	end

	emitter:Finish()


end

--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think( )

	self.Life = self.Life + FrameTime() * 3.5
	
	return (self.Life < 1)

end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render( )
		
--	render.SetMaterial( self.Mat )
	render.SetColorMaterial()
	render.DrawSphere( self.Position, self.Life * 100, 12, 12, Color( 205,205,255, ( 1 - self.Life) * 35 ) )
	render.SetMaterial( self.Mat )
	local siz = self.Life * 200 + math.random( 0, 100 )
--	render.DrawQuadEasy( self.Position, -EyeVector():GetNormal(), siz, siz, Color(255,255,255, ( 1 - self.Life) * 155 ), 0 )
	render.DrawQuadEasy( self.Position, -EyeVector():GetNormal(), (siz / 3) / 2, siz / 3, Color(255,255,255, ( 1 - self.Life) * 255 ), 0 )
end