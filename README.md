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
- i18n (see `sh_lang.moon`)

## Installation ##

### For individuals and server owners ###

[Click here to go to the releases page.](https://github.com/sliceofcode/sandwichzones/releases)

Download the `.zip` file and extract it the contents of it into the `addons` folder.

### For developers ###

Because this mod does not directly use Lua (it is written in MoonScript and compiles down to Lua), you will have to compile the mod before it can work.

Download and install [MoonScript](https://moonscript.org/). If you are on Windows (which you probably are), binary executables are provided on the page, so you do not have to install Lua.

## Configuration ##

There are slim to none configuration to do. Why? Most "configuration" is done in-game
by adding zones and modifying their properties. The only configuration option currently
is to disable server-side logging, because Sandwich Zones logs a lot, just in case you
need it.

## Getting Started ##

Once you have installed the addon, join your server. From there, type
"!szzonemenu" in chat or type in "ulx szzonemenu" in console. This will open the main
interface which controls Sandwich Zones. There are also other ULX commands, but you don't
need to touch those because you can use the user interface instead. The user menu internally calls the ULX commands. Nevertheless, documentation is provided for the other commmands.

## What Things Are ##

A zone is a cubic area that can be defined in your map. Note that zones are saved automatically
and each map gets its own list of zones.

Each zone can have "properties". These properties are essential to using Sandwich Zones. For example,
the "God mode" property means that everyone inside a zone with that property enabled will be
invincible (cannot die). Effects on those who enter a zone are reversed when they leave the zone.

To properties on and off in a zone, select it in the zone menu (!szzonemenu) and click "Zone Settings".
That will bring up a dialog where you can turn properties on and off with checkboxes.

## i18n ##

Almost all strings are stored in "lua/sandwichzones/sh_lang.lua", so translating is a breeze!

Multi-language support has not yet been implemented. Sorry :(

## Hooks ##

If you are a Lua developer, many hooks are called within the script. Read hooks.txt for more information. There
are hooks for both clientside and serverside. You can also read `DEV_NOTES.md`

## Adding your own Zone Properties ##

Sandwich Zones is designed in such a way so that adding your own zone properties is VERY easy.
If you know Lua, custom properties can be added in the file "lua/sandwichzones/sh_zoneproperties.moon"

As you can see, everything is self explanatory.
