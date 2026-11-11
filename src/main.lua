---@meta _

local mods = rom.mods

---@module 'LuaENVY-ENVY-auto'
mods['LuaENVY-ENVY'].auto()

rom = rom
_PLUGIN = _PLUGIN

---@module 'game'
game = rom.game
---@module 'game-import'
import_as_fallback(game)

---@module 'SGG_Modding-SJSON'
sjson = mods['SGG_Modding-SJSON']
---@module 'SGG_Modding-ModUtil'
modutil = mods['SGG_Modding-ModUtil']

---@module 'SGG_Modding-Chalk'
chalk = mods["SGG_Modding-Chalk"]
---@module 'SGG_Modding-ReLoad'
reload = mods['SGG_Modding-ReLoad']

---@module 'Siuhnexus-BountyAPI'
bountyAPI = mods['Siuhnexus-BountyAPI']

---@module 'config'
config = chalk.auto 'config.lua'
public.config = config

local function on_ready()
	if config.enabled == false then return end
	mod = modutil.mod.Mod.Register(_PLUGIN.guid)

	import 'ready.lua'
end

local function on_reload()
	if config.enabled == false then return end

	import 'reload.lua'
end

rom.gui.add_imgui(function()
	if rom.ImGui.Begin('BoonEdits') and boon_edits_draw_config then
		boon_edits_draw_config()
	end
	rom.ImGui.End()
end)

rom.gui.add_to_menu_bar(function()
	if rom.ImGui.BeginMenu('BoonEdits') then
		if boon_edits_draw_config then boon_edits_draw_config() end
		rom.ImGui.EndMenu()
	end
end)

local loader = reload.auto_multiple()

modutil.once_loaded.game(function()
	loader.load("early", on_ready, on_reload)
end)
