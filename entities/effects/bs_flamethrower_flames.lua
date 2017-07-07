function EFFECT:Init(data)
	local emitter = ParticleEmitter(data:GetOrigin())
	local Pos = data:GetOrigin()
	local Norm = data:GetNormal()
	local owner = data:GetEntity()

	if !owner:IsValid() then return end
		
	for i = 1, 4 do
		local particle = emitter:Add("effects/muzzleflash"..math.random(1,4), Pos )

		if (particle) then
			particle:SetVelocity( Norm * 400 + (VectorRand() * 50) + (owner:GetVelocity() / 2) )
				
			particle:SetDieTime( 0.5 + math.Rand( 0.1, 0.3 ) )
				
			particle:SetColor( 255, 255, 255 )			

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
				
			particle:SetStartSize( 0 )
			particle:SetEndSize( 40 + math.random( 10, 50 ) )
				
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-1.21, 1.21))
				
			particle:SetAirResistance( 5 )
				
			particle:SetGravity(Vector(0, 0, -5))

			particle:SetCollide( true )
			particle:SetBounce(0.45)
		end
	end

	for i = 1, 2 do
		local particle = emitter:Add("particle/smokesprites_000"..math.random( 1, 5 ), Pos )

		if (particle) then
			particle:SetVelocity( Norm * 500 + (VectorRand() * 10) + (owner:GetVelocity() / 2) )
				
			particle:SetDieTime( 1 + math.Rand( 0.1, 0.5 ) )
				
			particle:SetColor( 55, 55, 55 )			

			particle:SetStartAlpha( 55 )
			particle:SetEndAlpha( 0 )
				
			particle:SetStartSize( 5 )
			particle:SetEndSize( 20 + math.random( 10, 30 ) )
				
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-1.21, 1.21))
				
			particle:SetAirResistance( 55 )
				
			particle:SetGravity(Vector(0, 0, -5))

			particle:SetCollide( true )
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