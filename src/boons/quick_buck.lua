---@meta _
---@diagnostic disable: lowercase-global


once('QuickBuck', function()
	if not boon_edit_on('QuickBuck') then return end
	game.TraitData.MoneyMultiplierBoon.Elements = { mod.tuning.QuickBuck.Element }
end)
