-- Property: Strips weapons from players.

class PlayerWeaponCache
	new: =>
		@Cache = {}

	CreateMetaBase: (player) =>
		@Cache[player\UserID!] = {
			weapons: {}
			ammo: {}
		}

	CreateMeta: (player) =>
		@CreateMetaBase player

		ply_uid = player\UserID!
		ply_weps = player\GetWeapons!

		-- For each weapon this player has, create metadata.
		for k, weapon in ipairs(ply_weps) do
			-- Create weapon metadata.
			meta = {
				class: weapon\GetClass!
				clip1: weapon\Clip1!
				clip2: weapon\Clip2!
				clip1type: weapon\GetPrimaryAmmoType!
				clip2type: weapon\GetSecondaryAmmoType!
			}

			table.insert @Cache[ply_uid].weapons, meta

			-- Make sure to include ammo.
			@Cache[ply_uid].ammo[weapon\GetPrimaryAmmoType!] = player\GetAmmoCount(weapon\GetPrimaryAmmoType!)
			@Cache[ply_uid].ammo[weapon\GetSecondaryAmmoType!] = player\GetAmmoCount(weapon\GetSecondaryAmmoType!)

	Restore: (player) =>
		ply_uid = player\UserID!

		-- Only restore weapons if the player
		-- had their weapons stripped.
		return unless @Cache[ply_uid]

		-- Enumerate through all weapons.
		for _, weapon in ipairs @Cache[player\UserID!].weapons do
			SZ.Log "zonep: strip restore: #{weapon.class} clip1: #{weapon.clip1} clip2: #{weapon.clip2}"

			-- Give back the actual weapon.
			player\Give weapon.class

			-- Strip ammo.
			player\StripAmmo!

			-- Give back clips.
			player\GetWeapon(weapon.class)\SetClip1 weapon.clip1
			player\GetWeapon(weapon.class)\SetClip2 weapon.clip2

			-- Remove ammo, because we will manually restore it.
			player\StripAmmo!

		-- For each ammo type, restore ammo.
		for ammotype, ammoamount in pairs @Cache[player\UserID!].ammo do
			SZ.Log "zonep: strip refund: ammo: refunding #{ammoamount} of #{ammotype}"

			-- Give back ammo.
			player\GiveAmmo ammoamount, ammotype, false

		-- Remove from cache.
		@Cache[player\UserID!] = nil

PWC = PlayerWeaponCache!

-- Create property information.
PropertyInfo = {
	StripWeapons:
		NiceName: SZ.Lang.ZonePropNiceStripWeapons
		OnEnter: (ply, zone) ->
			-- Store weapon metadata into the
			-- PWC.
			PWC\CreateMeta ply

			-- Actually strip the player.
			ply\StripAmmo!
			ply\StripWeapons!
		OnExit: (ply, zone) ->
			PWC\Restore ply
}

-- Merge.
table.Merge SZ.ZoneProperties, PropertyInfo

SZ.Log("zonep: strip property loaded")
