--[[==========================================================
Bloodsport music system, Created by LegendofRobbo
============================================================]]
-- this code is absolutely horrendous, i would recommend not copying anything i did here

if CLIENT then
	local songs = {
		[1] = CreateSound( game.GetWorld(), "bloodsport/BSmusic1.mp3" ),
		[2] = CreateSound( game.GetWorld(), "bloodsport/BSmusic2.mp3" ),
		[3] = CreateSound( game.GetWorld(), "bloodsport/BSmusic3.mp3" ),
	}
	local crowdlooplen = 8.173
	local crowdplaying = false
	local nxcrowdloop = 0

	net.Receive( "BS_SendSound", function() 
		if !crowd then crowd = CreateSound( game.GetWorld(), "bloodsport/crowdbackground.wav" ) end
		if crowd and crowd:IsPlaying() then crowd:Stop() end
		local newsong = songs[math.random( 1, 3 )]
		crowdplaying = true
      	newsong:SetSoundLevel( 0 )
    	newsong:Play()
	end )

	net.Receive( "BS_StopSound", function() 
		if crowd and crowd:IsPlaying() then crowd:Stop() end
		crowdplaying = false
		for k, v in pairs( songs ) do
			v:Stop()
		end
	end )

	hook.Add( "Think", "ohgodwhatamidoing", function()
		if !crowd then return end
		if crowdplaying then
			if nxcrowdloop <= CurTime() then
				if crowd:IsPlaying() then crowd:Stop() end
    			crowd:SetSoundLevel( 0 )
    			crowd:Play()
    			nxcrowdloop = CurTime() + crowdlooplen
    		end
    	elseif !crowdplaying and crowd:IsPlaying() then
    		crowd:Stop()
    	end
	end )

end

if SERVER then 
	util.AddNetworkString( "BS_SendSound" )
	util.AddNetworkString( "BS_StopSound" )

	function StartNewRoundSong( ply )
		net.Start( "BS_SendSound" )
		if ply and ply:IsValid() and ply:IsPlayer() then net.Send( ply ) else net.Broadcast() end
	end

	function StopRoundSong( ply )
		net.Start( "BS_StopSound" )
		if ply and ply:IsValid() and ply:IsPlayer() then net.Send( ply ) else net.Broadcast() end
	end

end