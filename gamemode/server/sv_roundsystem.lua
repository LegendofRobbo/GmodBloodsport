--[[==========================================================
Bloodsport round core system, Created by LegendofRobbo
============================================================]]

util.AddNetworkString( "BS_SendRoundInfo" )
util.AddNetworkString( "BS_SendAnnounce" )

rounds = {}
rounds.Active = { ["Type"] = "None", ["Name"] = "Warm Up", ["TimeLeft"] = 0, ["Mutators"] = "" }
rounds.RollNextRound = 0

local roundtypes = {
	["FFA"] = {
		["Splatterfest"] = {
			Objective = "Kill people to score points, the person with the highest point count wins",
			Time = 60 * 5, -- 5 minutes
			MutatorBlacklist = {},
			ScoreToWin = 2000,
		},
	},

}

local gamemusic = -1


function SendAnnouncement( txt, ply )
	net.Start( "BS_SendAnnounce" )
	net.WriteString( txt )
	if ply and ply:IsValid() and ply:IsPlayer() then net.Send( ply ) else net.Broadcast() end
end

function rounds:RollNewRound()
	local rounds, rtype = table.Random( roundtypes )
	if !rounds then return end
	local newr, newrname = table.Random( rounds )
	self:StartRound( rtype, newrname )
end

-- does pretty much what you'd expect it to do
function rounds:StartRound( type, name )
	if !roundtypes[type] then error( "you are calling rounds:StartRound() with an invalid round type!" ) end
	if !roundtypes[type][name] then error( "you are calling rounds:StartRound() with a valid type but invalid round name!" ) end
	local roundtab = roundtypes[type][name]
	rounds.Active = { ["Type"] = type, ["Name"] = name, ["TimeLeft"] = CurTime() + roundtab.Time, ["Mutators"] = "" }
	StartNewRoundSong()
	SendAnnouncement( "Round Starting: "..name.."!" )
	self:SendRoundInfo()
	for k, v in pairs( player.GetAll() ) do
		v:SetScore( 0 )
		v:Kill()
		GAMEMODE:RollNewDeathmatchTeam( v )
	end
end

-- you can call this directly but there's probably no need
function rounds:GetActiveRound()
	return rounds.Active
end

function rounds:EndCurrentRound()
	if rounds.Active.Type == "None" then return end
	for k, v in pairs( player.GetAll() ) do
		v:SetScore( 0 )
	end
	self.RollNextRound = CurTime() + 15
	rounds.Active = { ["Type"] = "None", ["Name"] = "Warm Up", ["TimeLeft"] = 0, ["Mutators"] = "" }
	self:SendRoundInfo()
	StopRoundSong()
end

function rounds:GetActiveRoundTable()
	if !roundtypes[rounds.Active.Type] then return { ["Type"] = "None", ["Name"] = "Warm Up", ["TimeLeft"] = 0, ["Mutators"] = "" } end
	return roundtypes[rounds.Active.Type][rounds.Active.Name]
end

-- error safe function to get the amount of time remaining in the current round, returns 0 if round is over
function rounds:GetRoundTimeRemaining()
	local t = self:GetActiveRound().TimeLeft
	if t <= 0 then return 0 end
	local tl = t - CurTime()
	if tl <= 0 then return 0 end
	return t - CurTime()
end

-- returns a table of the active round mutators, add true as an argument to get the raw json string instead
function rounds:GetActiveMutators( raw )
	raw = raw or false
	if raw then return self:GetActiveRound().Mutators end
	return util.JSONToTable( self:GetActiveRound().Mutators )
end

-- returns a table of strings containing information about the current active round
function rounds:GetActiveRoundInfo()
	local rnd = rounds:GetActiveRound()
	if !roundtypes[rnd.Type] then return { ["Type"] = "None", ["Name"] = "Warm Up", ["Objective"] = "Get ready and limbered up for the big game night" } end
	if !roundtypes[rnd.Type][rnd.Name] then return { ["Type"] = "None", ["Name"] = "Warm Up", ["Objective"] = "Get ready and limbered up for the big game night" } end
	local obj = roundtypes[rnd.Type][rnd.Name].Objective
	return { ["Type"] = rnd.Type, ["Name"] = rnd.Name, ["Objective"] = obj }
end

function rounds:SendRoundInfo( ply )
	local rndinfo = self:GetActiveRoundInfo()

	net.Start( "BS_SendRoundInfo" )
	net.WriteString( rndinfo.Name )
	net.WriteString( rndinfo.Objective )
	net.WriteString( "" )
	net.WriteFloat( self:GetRoundTimeRemaining() )
	local nscore = self:GetActiveRoundTable().ScoreToWin
	if !nscore then nscore = -1 end
	net.WriteFloat( nscore )
	if ply and ply:IsValid() and ply:IsPlayer() then
		net.Send( ply )
	else
		net.Broadcast()
	end
end

hook.Add( "PlayerInitialSpawn", "gimmeroundinfo", function( ply ) 
	rounds:SendRoundInfo( ply )
	local rtab = rounds:GetActiveRound()
	if rtab.Type != "None" then
		StartNewRoundSong( ply )
	end
end)


function rounds:CheckForRoundWin( ply )
	if !ply:IsValid() or !ply:IsPlayer() then return end
	local rtab = self:GetActiveRoundTable()
	if !rtab then return end
	if rtab.Type == "None" then return end
	if ply:GetNWInt( "BS_Score", 0 ) >= rtab.ScoreToWin then
		self:PlayerWinRound( ply )
	end
end

function rounds:PlayerWinRound( ply )
	if !ply:IsValid() or !ply:IsPlayer() then return end
	/*
	for k, v in pairs( player.GetAll() ) do
		v:PrintMessage( 4, ply:Nick().." has won the match!" )
	end
	print( ply:Nick().." IS A WINRAR!" )
	*/
	SendAnnouncement( ply:Nick().." has won the match!" )
	self:EndCurrentRound()
end

hook.Add( "PlayerDeath", "CheckForWin1", function( ply, inf, atk )
	if ply:IsValid() and ply != atk and atk and atk:IsPlayer() then
		rounds:CheckForRoundWin( atk )
	end
end )

timer.Create( "RoundTimeTicker", 1, 0, function() 
	local rtab = rounds:GetActiveRound()
	if rtab.Type == "None" then
		if player.GetCount() > 1 and rounds.RollNextRound <= CurTime() then rounds:RollNewRound() end
		return 
	end
	if rtab.TimeLeft and rtab.TimeLeft <= CurTime() then
		local weiner = player.GetAll()
		table.sort( weiner, function( a, b ) return a:GetNWInt( "BS_Score", 0 ) > b:GetNWInt( "BS_Score", 0 ) end )
		if weiner[1] and weiner[1]:IsValid() then
			rounds:PlayerWinRound( weiner[1] )
		else
			rounds:EndCurrentRound()
		end
	end

end )


--rounds:RollNewRound()
