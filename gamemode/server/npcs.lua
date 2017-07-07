--[==[ Functions / Declarations / Tables ]==]--

local meta = FindMetaTable("Player")

local ent = FindMetaTable("Entity")

local allowed_npcs = {}

local blocknpcs = CreateConVar("block_all_npcs", 0, true, false)

local blocksomenpcs = CreateConVar("restrict_npcs", 0, true, false)

local testers = {
	"76561198028288732", -- me
    "76561198083117557", -- lies
    "76561198035059571", -- erad
    "76561198097352513", -- zultan
    "76561198028646454", -- malus
    "76561198090537451", -- sync
}

function meta:IsTester()
	return table.HasValue(testers, self:SteamID64())
end

function meta:SendErrorNotification(str, time)
	self:SendLua(string.format([[notification.AddLegacy(%s, NOTIFY_ERROR, %i)]], str, time))
end

function ent:AllowedNPC()
	if type(self) == "NPC" and allowed_npcs[self:GetClass()] then
		return true
	end

	return false
end

function RemoveNPCS(ply, cmd, args)
	if !ply:IsTester() then
		return false
	end

	for k, v in pairs(ents.GetAll()) do 
		if v:IsNPC() then
			v:Remove()
		end
	end
end

function NPCSAREFUCKINGGAY(ply, npc_type, weapon)
	if blocknpcs:GetBool() and !ply:IsTester() then
		ply:SendErrorNotification(string.format("You tried to spawn {%s} which is not allowed!. Contact a server admin for more information!", npc_type))
		return false
	end

	if !blocknpcs:GetBool() and blocksomenpcs:GetBool() and !ply:IsTester() then
		if allowed_npcs[npc_type] then
			return true
		end

		return false
	end

	if !blocknpcs:GetBool() and !blocksomenpcs:GetBool() then
		return true
	end

	return true
end


--[==[ concommands / hooks ]==]--

concommand.Add("Remove_NPCS", RemoveNPCS)

hook.Add("PlayerSpawnNPC", "npcsarefuckinggay", NPCSAREFUCKINGGAY)