--[[==========================================================
Bloodsport music system, Created by LegendofRobbo
============================================================]]
-- this code is absolutely horrendous, i would recommend not copying anything i did here

if CLIENT then
	local songs = {}
	local crowd = -1

	local function MakeSounds()
		if !game.GetWorld() or game.GetWorld() == NULL then return false end
		if !isnumber( crowd ) then return false end
		crowd = CreateSound( game.GetWorld(), "bloodsport/crowdbackground.wav" )
		songs = {
			[1] = CreateSound( game.GetWorld(), "bloodsport/BSmusic1.mp3" ),
			[2] = CreateSound( game.GetWorld(), "bloodsport/BSmusic2.mp3" ),
		}
		return true
	end

	timer.Create( "GiveMeAids", 1, 0, function()
		if MakeSounds() then timer.Remove( "GiveMeAids" ) end
	end)

	local crowdlooplen = 8.173
	local crowdplaying = false
	local nxcrowdloop = 0

	net.Receive( "BS_SendSound", function()
		if isnumber( crowd ) then MakeSounds() end
		if crowd and crowd:IsPlaying() then crowd:Stop() end
		local newsong = songs[math.random( 1, 2 )]
		crowdplaying = true
      	newsong:SetSoundLevel( 0 )
    	newsong:Play()
	end )

	net.Receive( "BS_StopSound", function()
		if isnumber( crowd ) then MakeSounds() end
		if crowd and crowd:IsPlaying() then crowd:Stop() end
		crowdplaying = false
		for k, v in pairs( songs ) do
			v:Stop()
		end
	end )

	hook.Add( "Think", "ohgodwhatamidoing", function()
		if isnumber( crowd ) then return end
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
