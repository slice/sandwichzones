# Sandwich Zones #

Hello!

This Garry's Mod addon adds multi-purpose, simple to use cubic zones.

It uses ULX to manage permissions and add commands, so your server needs that.
It also needs ULib, which ULX also needs.

It should compatible with every gamemode. It has been tested with DarkRP and Sandbox.

## Features ##

- Derma GUI for managing zones
	- Delete zones
	- Create zones
	- Modify zone properties
	- Edit clientside settings
- Zones
	- Zone properties
	- Zone persistance via `.json` file

## Installation ##

Download this repository as a .ZIP file and extract the contents into your addons/
folder.

## Configuration ##

There are slim to none configuration to do. Why? Most "configuration" is done in-game
by adding zones and modifying their properties. The only configuration option currently
is to disable server-side logging, because Sandwich Zones logs a lot, just in case you
need it.

## Getting Started ##

Once you have installed the addon, join your server. From there, type
"!szzonemenu" in chat or type in "ulx szzonemenu" in console. This will open the main
interface which controls Sandwich Zones. There are also other ULX commands, but you don't
need to touch those because you can use the user interface instead. Nevertheless, documentation
is provided for the other commmands.

## What Things Are ##

A zone is a cubic area that can be defined in your map. Note that zones are saved automatically
and each map gets its own list of zones.

Each zone can have "properties". These properties are essential to using Sandwich Zones. For example,
the "God mode" property means that everyone inside a zone with that property enabled will be
invincible (cannot die).

To properties on and off in a zone, select it in the zone menu (!szzonemenu) and click "Zone Settings".
That will bring up a dialog where you can turn properties on and off with checkboxes.

## i18n ##

Almost all strings are stored in "lua/sandwichzones/sh_lang.lua", so translating is a breeze!

Multi-language support has not yet been implemented. Sorry :(

## Hooks ##

If you are a Lua developer, many hooks are called within the script. Read hooks.txt for more information. There
are hooks for both clientside and serverside.

## Adding your own Zone Properties ##

Sandwich Zones is designed in such a way so that adding your own zone properties is VERY easy.
If you know Lua, custom properties can be added in the file "lua/sandwichzones/sh_zoneproperties.lua"

For example, this is how the God mode property is created:

```lua
	GodMode = {
		NiceName = SZ.Lang.ZonePropNiceGodMode,
		OnEnter = function(ply, zone)
			ply:GodEnable()
		end,
		OnExit = function(ply, zone)
			ply:GodDisable()
		end,
	},
```

As you can see, everything is self explanatory.
