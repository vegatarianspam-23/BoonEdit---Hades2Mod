---@meta _
---@diagnostic disable: lowercase-global


once('NitroBoost', function()
	if not boon_edit_on('NitroBoost') then return end
	game.TraitData.SprintShieldBoon.Elements = { mod.tuning.NitroBoost.Element }
end)
