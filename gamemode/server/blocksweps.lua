local badsweps = {}

local blocksweps = false

local meta = FindMetaTable("Player")

local testers = {
	"76561198028288732", -- me / robbo
    "76561198083117557", -- lies
    "76561198035059571", -- erad
    "76561198097352513", -- zultan
    "76561198028646454", -- malus
    "76561198090537451", -- sync
}

function meta:IsTester()
	return table.HasValue(testers, self:SteamID64())
end

function whydoiexist(ply, cmd, args)
	if !ply:IsTester() then
		ply:ChatPrint("fuck off habbibi")
		return false
	end

	blocksweps = !blocksweps
	
	if blocksweps then
		PrintMessage(HUD_PRINTTALK, string.format("Restricting sweps has been administratively disabled by %s", ply:Nick()))
	else 
		PrintMessage(HUD_PRINTTALK, string.format("Restricting sweps has been administratively enabled by %s", ply:Nick()))
	end
end


	
function functionnamesareforgays(ply, wep, swep)
	if badsweps[wep] and blocksweps then
		RunConsoleCommand("ulx", "asay", string.format("%s just tried to use a restricted weapon (%s)", ply:Nick(), wep)) 
		return false
	end

	return true
end

hook.Add("PlayerSpawnSwep", "legitaids", functionnamesareforgays)
concommand.Add("blockswpes", whydoiexist)