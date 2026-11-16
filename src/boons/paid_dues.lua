---@meta _
---@diagnostic disable: lowercase-global


once('PaidDues', function()
	if not boon_edit_on('PaidDues') then return end

	game.TraitData.TimeStopLastStandBoon.MoneyShieldData.Multiplier = mod.tuning.PaidDues.GoldPerDamage
	game.TraitData.TimeStopLastStandBoon.Elements = { mod.tuning.PaidDues.Element }
end)
