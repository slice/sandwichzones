-- In this file, you can add/remove/modify zone properties.
--
-- You should set a zone's properties using !szzonesettings.
-- That command will display a UI where you can set a zone's properties.

SZ.Log "zonep: init zone properties"

-- Player weapons cache, used by
-- strip.
PlayerWeaponsCache = {}

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
	GodMode:
		NiceName: SZ.Lang.ZonePropNiceGodMode
		OnEnter: (ply, zone) ->
			ply\GodEnable!
		OnExit: (ply, zone) ->
			ply\GodDisable!

	-- Disallow jumping
	--
	-- Doesn't allow jumping.
	DisallowJumping:
		NiceName: SZ.Lang.ZonePropNiceDisallowJump
		OnEnter: (ply) ->
			ply.JumpPower = ply\GetJumpPower!
			ply\SetJumpPower 0
		OnExit: (ply) ->
			ply\SetJumpPower ply.JumpPower if ply.JumpPower

	-- Slay non admins
	--
	-- Players are slain upon entering if they aren't
	-- considered an admin role.
	SlayNonAdmin:
		NiceName: SZ.Lang.ZonePropNiceSlayNonAdmin
		OnEnter: (ply, zone) ->
			ply\Kill! unless (ply\IsAdmin! or ply\IsSuperAdmin!)

	-- Disallow sprint
	--
	-- Does what it says on the tin -- it disallows
	-- sprinting.
	DisallowSprint:
		NiceName: SZ.Lang.ZonePropNiceDisallowSprint
		OnEnter: (ply, zone) ->
			ply.SprintingSpeed = ply\GetRunSpeed!
			ply\SetRunSpeed ply\GetWalkSpeed!
		OnExit: (ply, zone) ->
			ply\SetRunSpeed ply.SprintingSpeed if ply.SprintingSpeed
}

-- Include additional properties
-- that need their own files.
SZ.Log "zonep: init zone property modules"
include "properties/pr_weaponstrip.lua"

SBNoObjectSpawningPlys = {}
SandboxProperties = {
	SBDisallowObjectSpawning:
		NiceName: SZ.Lang.ZonePropNiceSBDisallowObjectSpawn
		OnEnter: (ply, zone) ->
			-- Insert the player into the SBNoObjectSpawningPlys
			-- table.
			SZ.Log "zonep: sandbox: prohibiting #{ply\Nick!} from spawning props"

			table.insert SBNoObjectSpawningPlys, {
				uid: ply\UserID!
				uuid: zone.uuid
			}

		OnExit: (ply, zone) ->
			-- Remove the player from the SBNoObjectSpawningPlys
			-- table.
			for k, meta in pairs SBNoObjectSpawningPlys do
				if meta.uid == ply\UserID! and meta.uuid == zone.uuid then
					SZ.Log "zonep: sandbox: allowing #{ply\Nick!} to spawn props"
					table.remove SBNoObjectSpawningPlys, k
					return

		OnDisable: (zone) ->
			SZ.Log("zonep: sandbox: removing all references to zone #{zone.uuid} from prohibit list")
			-- Remove all references to this zone from SBNoObjectSpawningPlys.
			for i = #SBNoObjectSpawningPlys, 1, -1 do
				if zone.uuid == SBNoObjectSpawningPlys[i].uuid then
					table.remove SBNoObjectSpawningPlys, i
}

hook.Add "Initialize", "sz_add_gamemode_specific_hooks", ->
	if GAMEMODE.Name == "Sandbox" or GAMEMODE.BaseClass.Name == "Sandbox" then
		SZ.Log "zonep: adding sandbox properties"

		-- Add Sandbox properties.
		table.Merge SZ.ZoneProperties, SandboxProperties

		hook.Add "PlayerSpawnObject", "sz_sandbox_disallow_object_spawning", (ply, model, skin) ->
			-- Check if the player's ID is inside SBNoObjectSpawningPlys.
			-- If so, disallow spawning.
			for _, pmeta in ipairs SBNoObjectSpawningPlys do
				if ply\UserID! == pmeta.uid then
					SZ.Log "zonep: sandbox: disallowing spawn of #{model}"
					return false

			return true

SZ.Log "zonep: initialized properties"
