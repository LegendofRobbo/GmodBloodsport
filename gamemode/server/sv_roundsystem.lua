util.AddNetworkString( "BS_SendRoundInfo" )

rounds = {}
rounds.Active = { ["Type"] = "", ["Name"] = "", ["TimeLeft"] = 0, ["Mutators"] = "" }

local roundtypes = {
	["FFA"] = {
		["Splatterfest"] = {
			Objective = "Kill people to score points, the person with the highest point count wins",
			Time = 60 * 5, -- 5 minutes
			MutatorBlacklist = {},
			ScoreToWin = 5000,
		},
	},

}

-- does pretty much what you'd expect it to do
function rounds:StartRound( type, name )
	if !roundtypes[type] then error( "you are calling rounds:StartRound() with an invalid round type!" ) end
	if !roundtypes[type][name] then error( "you are calling rounds:StartRound() with a valid type but invalid round name!" ) end
	local roundtab = roundtypes[type][name]
	rounds.Active = { ["Type"] = type, ["Name"] = name, ["TimeLeft"] = CurTime() + roundtab.Time, ["Mutators"] = "" }
	rounds.SendRoundInfo()
end

-- you can call this directly but there's probably no need
function rounds:GetActiveRound()
	return rounds.Active
end

-- error safe function to get the amount of time remaining in the current round, returns 0 if round is over
function rounds:GetRoundTimeRemaining()
	local t = rounds:GetActiveRound().TimeLeft
	if t <= 0 then return 0 end
	local tl = CurTime() - t
	if tl <= 0 then return 0 end
	return CurTime() - t
end

-- returns a table of the active round mutators, add true as an argument to get the raw json string instead
function rounds:GetActiveMutators( raw )
	raw = raw or false
	if raw then return rounds:GetActiveRound().Mutators end
	return util.JSONToTable( rounds:GetActiveRound().Mutators )
end

-- returns a table of strings containing information about the current active round
function rounds:GetActiveRoundInfo()
	local rnd = rounds:GetActiveRound()
	if !roundtypes[rnd.Type] then return { ["Type"] = "None", ["Name"] = "No Active Round", ["Objective"] = "Stare at your navel" } end
	if !roundtypes[rnd.Type][rnd.Name] then return { ["Type"] = "None", ["Name"] = "No Active Round", ["Objective"] = "Stare at your navel" } end -- im gay
	local obj = roundtypes[rnd.Type][rnd.Name].Objective
	return { ["Type"] = rnd.Type, ["Name"] = rnd.Name, ["Objective"] = obj }
end




function rounds.SendRoundInfo()
	net.Start( "BS_SendRoundInfo" )
	net.WriteString( "name" )
	net.WriteString( "objective" )
	net.WriteString( "mutatorsJSON" )
	net.WriteFloat( rounds:GetRoundTimeRemaining() )
	net.WriteFloat( rounds:GetActiveRound().ScoreToWin )
	net.Broadcast()
end

function rounds.SendRoundInfoTargeted( ply )
	if !ply:IsValid() then return end
	net.Start( "BS_SendRoundInfo" )
	net.WriteString( "name" )
	net.WriteString( "objective" )
	net.WriteString( "mutatorsJSON" )
	net.WriteFloat( rounds:GetRoundTimeRemaining() )
	net.WriteFloat( rounds:GetActiveRound().ScoreToWin )
	net.Send( ply )
end