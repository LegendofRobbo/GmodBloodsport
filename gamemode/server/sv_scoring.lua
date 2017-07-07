local playa = FindMetaTable( "Player" )

local function DoKillScoring( ply, atk, dmg )
	if !ply:IsValid() or !ply:IsPlayer() then return end
	if !atk:IsValid() or !atk:IsPlayer() then return end
	if ply == atk then return end
	local pts = 100
	local inf = dmg:GetInflictor()
	local specs = {}

	-- generic --
	if dmg:IsBulletDamage() and ply:LastHitGroup() == HITGROUP_HEAD then
		pts = pts + 25
		table.insert( specs, "Headshot" )
	end

	local siz = 16
	local tr = util.TraceHull( { start = atk:GetPos(), endpos = atk:GetPos() + Vector( 0, 0, -80 ), filter = atk, mask = MASK_SHOT, mins = Vector( -siz, -siz, -siz ), maxs = Vector( siz, siz, siz ) })
	if !tr.HitWorld then
		pts = pts + 25
		table.insert( specs, "Midair" )
	end

	if atk.NextWallJump and atk.NextWallJump > (CurTime() - 0.3) then
		pts = pts + 25
		table.insert( specs, "Walljump Combo" )
	end

	if !atk:Alive() then
		pts = pts + 25
		table.insert( specs, "Beyond the Grave" )
	end

	-- knives --
	if ply:GetActiveWeapon() and ply:GetActiveWeapon():GetClass() == "weapon_bs_knife" and ply:GetActiveWeapon().ReboundTime and ply:GetActiveWeapon().ReboundTime > CurTime() then
		pts = pts + 50
		table.insert( specs, "You call that a knife?" )
	end

	if inf:IsValid() and inf:GetClass() == "bs_knife_thrown" and ply:GetPos():Distance( atk:GetPos() ) > 800 then
		pts = pts + 50
		table.insert( specs, "Knife Longshot" )
	end

	-- harpoons --
	if inf:IsValid() and inf:GetClass() == "bs_harpoon" then
		if ply:GetPos():Distance( atk:GetPos() ) > 1500 then
		pts = pts + 25
		table.insert( specs, "Harpoon Longshot" )
		end
		if inf.Rebounded then
			pts = pts + 100
			table.insert( specs, "Rebound" )
		end

		if atk:Alive() and !inf:Visible( atk ) then
			pts = pts + 25
			table.insert( specs, "Blindshot" )
		end
	end

	-- rawkets --
	if atk.RocketJumped and atk.RocketJumped >= CurTime() then
		pts = pts + 25
		table.insert( specs, "Rocketjump Combo" )
	end

	-- multi kills --
	if !atk.KillCombo then atk.KillCombo = 0 atk.KillComboTimeout = CurTime() + 3 end
	if atk.KillComboTimeout > CurTime() then
		atk.KillComboTimeout = CurTime() + 3
		atk.KillCombo = atk.KillCombo + 1
	else
		atk.KillComboTimeout = CurTime() + 3
		atk.KillCombo = 1
	end

	if atk.KillCombo == 2 then
		pts = pts + 25
		table.insert( specs, "Double Kill" )
	elseif atk.KillCombo == 3 then
		pts = pts + 25
		table.insert( specs, "Triple Kill" )
	elseif atk.KillCombo == 4 then
		pts = pts + 50
		table.insert( specs, "Quadra Kill" )
	elseif atk.KillCombo >= 5 then
		pts = pts + 75
		table.insert( specs, "Genocide" )
		atk.KillCombo = 0
	end


	local specstring = ""
	if table.Count( specs ) > 0 then specstring = specstring.." Special Modifiers:" end

	for k, v in pairs( specs ) do
		specstring = specstring.." "..v
	end

	atk:ChatPrint( "You killed "..ply:Nick().." for "..pts.." points!"..specstring )

end
hook.Add( "DoPlayerDeath", "BS_ScoreKills", DoKillScoring ) 


local wepz = {
	[1] = "Combat Knife",
	[2] = "Gravity Hammer",
	[3] = "Magnum Pistol",
	[4] = "Harpoon Bow",
	[5] = "Shotgun",
	[6] = "Rocket Launcher",
	[7] = "Flamethrower",
}

local function SpawnPickup( ply, num )
	if !ply:IsValid() or !ply:Alive() then return end
	local tr = ply:GetEyeTraceNoCursor()
	local str = wepz[num]
	if !str then return end

	local fag = ents.Create( "bs_weapon_pickup" )
	fag:SetNWString( "PickupType", str )
	fag:SetPos( tr.HitPos )
	fag:SetAngles( Angle( 0, 0, 0 ) )
	fag:Spawn()
	fag:Activate()
end


concommand.Add( "testpickups", function( ply, cmd, args )
	SpawnPickup( ply, tonumber(args[1]) )
end)