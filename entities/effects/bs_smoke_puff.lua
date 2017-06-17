function EFFECT:Init(data)
	local emitter = ParticleEmitter(data:GetOrigin())
	local col = data:GetStart()
	local col2 = Color( col.x, col.y, col.z )
	local Pos = data:GetOrigin()
	local Zap = data:GetScale()
		
	for i = 1, 6 do
		local particle = emitter:Add("particle/smokesprites_000"..math.random( 1, 5 ), Pos)

		if (particle) then
			particle:SetVelocity(VectorRand() * math.Rand(22, 55) * Zap)
				
			particle:SetDieTime( 0.4 * Zap )
				
			particle:SetColor(col2.r, col2.g, col2.b)			

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
				
			particle:SetStartSize(1)
			particle:SetEndSize(20 * Zap)
				
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-0.21, 0.21))
				
			particle:SetAirResistance(math.Rand(70, 150))
				
			particle:SetGravity(Vector(0, 0, -5))

			particle:SetCollide(false)
			particle:SetBounce(0.45)
		end
	end

	emitter:Finish()
end

function EFFECT:Think()

	return false
end

function EFFECT:Render()
end