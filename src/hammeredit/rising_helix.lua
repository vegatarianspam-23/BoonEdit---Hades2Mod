---@meta _


once('RisingHelix', function()
	if not boon_edit_on('RisingHelix') then return end

	game.TraitData.TorchLongevityTrait.AddOutgoingDamageModifiers.LifetimeMultiplier.BaseValue =
		mod.tuning.RisingHelix.MaxDamageBonus
end)
