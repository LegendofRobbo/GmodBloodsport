BS_LootDrops = {}

local wepz = {
	[1] = "Gravity Hammer",
	[2] = "Magnum Pistol",
	[3] = "Harpoon Bow",
	[4] = "Shotgun",
	[5] = "Rocket Launcher",
	[6] = "Flamethrower",
}

local function SavePickups()
	if not file.IsDir("bloodsport/spawns", "DATA") then
   		file.CreateDir("bloodsport/spawns")
	end
	local tabstr = util.TableToJSON( BS_LootDrops )
	file.Write( "bloodsport/spawns/" .. string.lower(game.GetMap()) .. ".txt", tabstr )
	print( "loot table saved!" )
end
concommand.Add( "bs_saveloot", SavePickups )

local function LoadPickups()
	if not file.IsDir("bloodsport/spawns", "DATA") then
   		file.CreateDir("bloodsport/spawns")
	end
	if file.Exists( "bloodsport/spawns/" .. string.lower(game.GetMap()) .. ".txt", "DATA" ) then
		local raw = file.Read( "bloodsport/spawns/" .. string.lower(game.GetMap()) .. ".txt", "DATA" )
		BS_LootDrops = util.JSONToTable( raw )
		print( "loot table loaded!" )
	else
		BS_LootDrops = {}
		print( "no loot table for this map" )
	end

end
concommand.Add( "bs_loadloot", LoadPickups )


local function SpawnWeapon( pos )
	local guntab = {}
	for k, v in pairs( BS_PickupData ) do
		if !v.isitem and k != "Combat Knife" then table.insert( guntab, k ) end
	end

	local str = table.Random( guntab )

	local fag = ents.Create( "bs_weapon_pickup" )
	fag:SetNWString( "PickupType", str )
	fag:SetPos( pos )
	fag:SetAngles( Angle( 0, 0, 0 ) )
	fag:Spawn()
	fag:Activate()
	
end

local function SpawnItem( pos )
	local guntab = {}
	for k, v in pairs( BS_PickupData ) do
		if v.isitem then table.insert( guntab, k ) end
	end

	local str = table.Random( guntab )

	local fag = ents.Create( "bs_weapon_pickup" )
	fag:SetNWString( "PickupType", str )
	fag:SetPos( pos )
	fag:SetAngles( Angle( 0, 0, 0 ) )
	fag:Spawn()
	fag:Activate()
	
end


local function SpawnAllPickups()
	if table.Count( BS_LootDrops ) < 1 then
		LoadPickups()
	end

	for k, v in pairs( BS_LootDrops ) do
		if istable( v ) then
			local sphere = ents.FindInSphere( v.p, 60 )
			local alreadyloot = false
			for _, e in pairs( sphere ) do
				if e:GetClass() == "bs_weapon_pickup" then alreadyloot = true break end
			end
			if alreadyloot then continue end
		
			SpawnItem( v.p )
			return
		end

		local sphere = ents.FindInSphere( v, 60 )
		local alreadyloot = false
		for _, e in pairs( sphere ) do
			if e:GetClass() == "bs_weapon_pickup" then alreadyloot = true break end
		end
		if alreadyloot then continue end
		
		SpawnWeapon( v )
	end
end
timer.Create( "BS_PickupLogic", 10, 0, SpawnAllPickups )


concommand.Add( "bs_addweapon", function( ply, cmd, args ) 
	local tr = ply:GetEyeTraceNoCursor()
	local poz = tr.HitPos
	table.insert( BS_LootDrops, poz )
	SavePickups()
	SpawnAllPickups()
end )

concommand.Add( "bs_addloot", function( ply, cmd, args ) 
	local tr = ply:GetEyeTraceNoCursor()
	local poz = tr.HitPos
	table.insert( BS_LootDrops, { p = poz } )
	SavePickups()
	SpawnAllPickups()
end )

concommand.Add( "bs_clearpickups", function( ply, cmd, args ) 
	BS_LootDrops = {}
	SavePickups()
	for k, v in pairs( ents.FindByClass( "bs_weapon_pickup" ) ) do v:Remove() end
end )



--concommand.Add( "testpickups", function( ply, cmd, args )
--	SpawnPickup( ply, tonumber(args[1]) )
--end)