--[[==========================================================
Bloodsport round scoring system, Created by LegendofRobbo
============================================================]]


local playa = FindMetaTable( "Player" )

util.AddNetworkString( "BS_Killfeed" )

function playa:AddKillMessage( attacker, modifiers, points )
	if !self:IsValid() then return end
--	if !attacker:IsValid() or !attacker:IsPlayer() then attacker = self end
		
	net.Start( "BS_Killfeed" )
	net.WriteEntity( self ) -- its cheaper to send 2 entities than it is to do net.WriteColor() with their team colours
	net.WriteEntity( attacker )
	net.WriteString( modifiers )
	net.WriteUInt( points, 16 )
	net.Broadcast()
end



local function DoKillScoring( ply, atk, dmg )
	if !ply:IsValid() then return end
	if !atk:IsValid() then return end
	if rounds:GetActiveRoundTable().Type == "None" then return end

	local inf = dmg:GetInflictor()
	if inf and inf:IsValid() and inf:GetClass() == "bs_harpoon" then
		atk = inf.Owner
	end
	if !atk:IsPlayer() then ply:AddKillMessage( game.GetWorld(), "", 0 ) return end
	if ply == atk then ply:AddKillMessage( ply, "", 0 ) return end
	local pts = 100
	local specs = {}

	-- generic --
	if dmg:IsBulletDamage() and ply:LastHitGroup() == HITGROUP_HEAD then
		pts = pts + 25
		table.insert( specs, "Headshot" )
	end

	local siz = 16
	local tr = util.TraceHull( { start = ply:GetPos(), endpos = ply:GetPos() + Vector( 0, 0, -80 ), filter = ply, mask = MASK_SHOT, mins = Vector( -siz, -siz, -siz ), maxs = Vector( siz, siz, siz ) })
	if !tr.HitWorld then
		pts = pts + 50
		table.insert( specs, "Flyswatter" )
	end

	local tr = util.TraceHull( { start = atk:GetPos(), endpos = atk:GetPos() + Vector( 0, 0, -80 ), filter = atk, mask = MASK_SHOT, mins = Vector( -siz, -siz, -siz ), maxs = Vector( siz, siz, siz ) })
	if !tr.HitWorld then
		pts = pts + 25
		table.insert( specs, "Midair" )
	end

	if atk.NextWallJump and atk.NextWallJump > (CurTime() - 0.5) then
		pts = pts + 25
		table.insert( specs, "Walljump Combo" )
	end

	if atk:Alive() and (atk:Health() + atk:Armor()) < 30 then
		pts = pts + 25
		table.insert( specs, "Edge of Death" )
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

	if inf:IsValid() and inf:GetClass() == "bs_knife_thrown" and ply:GetPos():Distance( atk:GetPos() ) > 750 then
		pts = pts + 50
		table.insert( specs, "Knife Longshot" )
	end

	-- harpoons --
	if inf:IsValid() and inf:GetClass() == "bs_harpoon" then
		if ply:GetPos():Distance( atk:GetPos() ) > 1200 then
			pts = pts + 25
			table.insert( specs, "Harpoon Longshot" )
		end
		if inf.Rebounded then
			pts = pts + 100
			table.insert( specs, "Rebound" )
		end

		local tr = util.TraceHull( { start = ply:GetPos(), endpos = ply:GetPos() + Vector( 0, 0, -80 ), filter = ply, mask = MASK_SHOT, mins = Vector( -siz, -siz, -siz ), maxs = Vector( siz, siz, siz ) })
		if !tr.HitWorld then
			pts = pts + 100
			table.insert( specs, "Aerial Skewer" )
		end

		if atk:Alive() and !inf:Visible( atk ) then
			pts = pts + 25
			table.insert( specs, "Blindshot" )
		end
	end

	-- rawkets --
	if atk.RocketJumped and atk.RocketJumped >= CurTime() and !atk:IsOnGround() then
		pts = pts + 25
		table.insert( specs, "Rocketjump Combo" )
	end

	-- multi kills --
	if !atk.KillCombo then atk.KillCombo = 0 atk.KillComboTimeout = CurTime() + 3 end
	if atk.KillComboTimeout > CurTime() then
		atk.KillComboTimeout = CurTime() + 4
		atk.KillCombo = atk.KillCombo + 1
	else
		atk.KillComboTimeout = CurTime() + 4
		atk.KillCombo = 1
	end

	if atk.KillCombo == 2 then
		pts = pts + 25
		table.insert( specs, "Double Kill" )
	elseif atk.KillCombo == 3 then
		pts = pts + 50
		table.insert( specs, "Triple Kill" )
	elseif atk.KillCombo == 4 then
		pts = pts + 75
		table.insert( specs, "Quadra Kill" )
	elseif atk.KillCombo >= 5 then
		pts = pts + 100
		table.insert( specs, "Genocide" )
		atk.KillCombo = 0
	end

	if atk:GetNWBool( "X2Combo", false ) then
		pts = pts * 2
		table.insert( specs, "X2 Boost" )
		atk:SetNWBool( "X2Combo", false )
	end

	local specstring = ""
	if table.Count( specs ) > 0 then specstring = specstring.." Modifiers:" end

	for k, v in pairs( specs ) do
		local seper = " "
		if k >= 2 then seper = " + " end
		specstring = specstring..seper..v
	end

	ply:AddKillMessage( atk, specstring, pts )
	atk:AddScore( pts )

end
hook.Add( "DoPlayerDeath", "BS_ScoreKills", DoKillScoring ) 


local playa = FindMetaTable( "Player" )

function playa:AddScore( pts )
	local score = self:GetNWInt( "BS_Score", 0 )
	self:SetNWInt( "BS_Score", score + pts)
end

function playa:SetScore( pts )
	self:SetNWInt( "BS_Score", pts)
end

function playa:RemoveScoreScore( pts )
	local score = self:GetNWInt( "BS_Score", 0 )
	self:SetNWInt( "BS_Score", math.Clamp( score - pts, 0, 999999 ) )
end