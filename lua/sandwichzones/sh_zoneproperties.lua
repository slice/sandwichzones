--
-- .d8888.  .d8b.  d8b   db d8888b. db   d8b   db d888888b  .o88b. db   db      d88888D  .d88b.  d8b   db d88888b .d8888.
-- 88'  YP d8' `8b 888o  88 88  `8D 88   I8I   88   `88'   d8P  Y8 88   88      YP  d8' .8P  Y8. 888o  88 88'     88'  YP
-- `8bo.   88ooo88 88V8o 88 88   88 88   I8I   88    88    8P      88ooo88         d8'  88    88 88V8o 88 88ooooo `8bo.
--   `Y8b. 88~~~88 88 V8o88 88   88 Y8   I8I   88    88    8b      88~~~88        d8'   88    88 88 V8o88 88~~~~~   `Y8b.
-- db   8D 88   88 88  V888 88  .8D `8b d8'8b d8'   .88.   Y8b  d8 88   88       d8' db `8b  d8' 88  V888 88.     db   8D
-- `8888Y' YP   YP VP   V8P Y8888D'  `8b8' `8d8'  Y888888P  `Y88P' YP   YP      d88888P  `Y88P'  VP   V8P Y88888P `8888Y'
--
-- This file is part of Sandwich Zones.
-- (c) 2016 System16

-- In this file, you can add/remove/modify zone properties.
--
-- You should set a zone's properties using !szzonesettings.
-- That command will display a UI where you can set a zone's properties.

SZ.Log("zonep: init zone properties")

-- Player weapons cache, used by
-- strip.
local PlayerWeaponsCache = {}

-- The actual properties.
--
-- A property consists of the following:
--
-- -- The internal identifier is used to identify
-- -- this property, and is saved in zones.
-- InternalIdentifier = {
--   -- The nice name. It can contain spaces
--   -- and is shown to the user.
--   NiceName = "Nice name",
--
--   -- Called when a player enters a zone with
--   -- this property enabled.
--   OnEnter = function(ply, zone) end,
--
--   -- Called when a player exits a zone with
--   -- this property enabled.
--   OnExit = function(ply, zone) end,
--
--   -- Called when this property is enabled on a zone.
--   OnEnable = function(zone) end,
--
--   -- Called when this property is disabled on a zone.
--   OnDisable = function(zone) end,
-- }

SZ.ZoneProperties = {
	-- God mode
	--
	-- Players are godded upon entering this zone.
	GodMode = {
		NiceName = SZ.Lang.ZonePropNiceGodMode,
		OnEnter = function(ply, zone)
			ply:GodEnable()
		end,
		OnExit = function(ply, zone)
			ply:GodDisable()
		end,
	},

	-- Disallow jumping
	--
	-- Doesn't allow jumping.
	DisallowJumping = {
		NiceName = SZ.Lang.ZonePropNiceDisallowJump,
		OnEnter = function(ply)
			ply.JumpPower = ply:GetJumpPower()
			ply:SetJumpPower(0)
		end,
		OnExit = function(ply)
			if ply.JumpPower then ply:SetJumpPower(ply.JumpPower) end
		end,
	},

	-- Slay non admins
	--
	-- Players are slain upon entering if they aren't
	-- considered an admin role.
	SlayNonAdmin = {
		NiceName = SZ.Lang.ZonePropNiceSlayNonAdmin,
		OnEnter = function(ply, zone)
			if not (ply:IsAdmin() or ply:IsSuperAdmin()) then
				ply:Kill()
			end
		end,
	},

	-- Strip weapons
	--
	-- Players get their weapons stripped upon entering,
	-- and are returned after exiting the zone.
	--
	-- Weapons are preserved. They are stored in PlayerWeaponsCache.
	StripWeapons = {
		NiceName = SZ.Lang.ZonePropNiceStripWeapons,
		OnEnter = function(ply, zone)
			local ply_uid = ply:UserID()

			-- Store this player's weapons in the weapon cache.
			-- We don't store the actual weapon entity
			-- because it gets destroyed due to stripping the player.
			PlayerWeaponsCache[ply_uid] = {
				-- Contains weapons metadata.
				-- Doesn't store the actual weapon itself!
				weapons = {},

				-- Contains ammo metadata.
				--
				-- Each entry is as follows:
				-- [AMMO_TYPE] = AMMO_AMOUNT
				ammo = {}
			}

			-- For each weapon this player has create metadata.
			for _, weapon in ipairs(ply:GetWeapons()) do
				-- Append weapon meta.
				local meta = {
					class = weapon:GetClass(),
					clip1 = weapon:Clip1(),
					clip2 = weapon:Clip2(),
					clip1type = weapon:GetPrimaryAmmoType(),
					clip2type = weapon:GetSecondaryAmmoType(),
				}
				table.insert(PlayerWeaponsCache[ply_uid].weapons, meta)

				-- Make sure to include ammo.
				PlayerWeaponsCache[ply_uid].ammo[weapon:GetPrimaryAmmoType()] = ply:GetAmmoCount(weapon:GetPrimaryAmmoType())
				PlayerWeaponsCache[ply_uid].ammo[weapon:GetSecondaryAmmoType()] = ply:GetAmmoCount(weapon:GetSecondaryAmmoType())
			end

			-- Strip the player.
			ply:StripAmmo()
			ply:StripWeapons()
		end,
		OnExit = function(ply, zone)
			local ply_uid = ply:UserID()

				-- Only refund the player's weapons if they actually
				-- have cached weapons.
			if PlayerWeaponsCache[ply_uid] then
				-- For each weapon in th cache, refund.
				for _, weapon in ipairs(PlayerWeaponsCache[ply:UserID()].weapons) do
					SZ.Log("zone strip refund: " .. weapon.class ..
						" clip1: " .. weapon.clip1 .. " clip2: " .. weapon.clip2)

					-- Give back the actual weapon.
					ply:Give(weapon.class)

					-- Strip ammo.
					ply:StripAmmo()

					-- Give back clips.
					ply:GetWeapon(weapon.class):SetClip1(weapon.clip1)
					ply:GetWeapon(weapon.class):SetClip2(weapon.clip2)
				end

				-- Remove ammo, because we will manually refund it.
				ply:StripAmmo()

				-- For each ammo type, refund ammo.
				for ammotype, ammoamount in pairs(PlayerWeaponsCache[ply:UserID()].ammo) do
					SZ.Log("zone strip refund: ammo: refunding " ..
						ammoamount .. " of " .. ammotype)

					-- Give back ammo.
					ply:GiveAmmo(ammoamount, ammotype, false)
				end

				-- Remove from cache.
				PlayerWeaponsCache[ply:UserID()] = nil
			end
		end,
	}
}

local SBNoObjectSpawningPlys = {}
local SandboxProperties = {
	SBDisallowObjectSpawning = {
		NiceName = SZ.Lang.ZonePropNiceSBDisallowObjectSpawn,
		OnEnter = function(ply, zone)
			-- Insert the player into the SBNoObjectSpawningPlys
			-- table.
			SZ.Log("zonep: sandbox: prohibiting " .. ply:Nick() .. " from spawning props")
			table.insert(SBNoObjectSpawningPlys, {
				uid = ply:UserID(),
				uuid = zone.uuid
			})
		end,
		OnExit = function(ply, zone)
			-- Remove the player from the SBNoObjectSpawningPlys
			-- table.
			for k, meta in pairs(SBNoObjectSpawningPlys) do
				if meta.uid == ply:UserID() and meta.uuid == zone.uuid then
					SZ.Log("zonep: sandbox: allowing " .. ply:Nick() .. " to spawning props")
					table.remove(SBNoObjectSpawningPlys, k)
					return
				end
			end
		end,
		OnDisable = function(zone)
			SZ.Log("zonep: sandbox: removing all references to zone " .. zone.uuid .. " from prohibit list")
			-- Remove all references to this zone from SBNoObjectSpawningPlys.
			for i = #SBNoObjectSpawningPlys, 1, -1 do
				if zone.uuid == SBNoObjectSpawningPlys[i].uuid then
					table.remove(SBNoObjectSpawningPlys, i)
				end
			end
		end,
	}
}

hook.Add("Initialize", "sz_add_gamemode_specific_hooks", function()
	if GAMEMODE.Name == "Sandbox" or GAMEMODE.BaseClass.Name == "Sandbox" then
		SZ.Log("zonep: adding sandbox properties")

		-- Add Sandbox properties.
		table.Merge(SZ.ZoneProperties, SandboxProperties)

		hook.Add("PlayerSpawnObject", "sz_sandbox_disallow_object_spawning", function(ply, model, skin)
			-- Check if the player's ID is inside SBNoObjectSpawningPlys.
			-- If so, disallow spawning.
			for _, pmeta in ipairs(SBNoObjectSpawningPlys) do
				if ply:UserID() == pmeta.uid then
					SZ.Log("zonep: sandbox: disallowing spawn of " .. model)
					return false
				end
			end

			return true
		end)
	end
end)

SZ.Log("zonep: initialized properties")
