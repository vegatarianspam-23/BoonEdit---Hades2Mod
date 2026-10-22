---@meta _


once('AspectOfSupay', function()
	if not boon_edit_on('AspectOfSupay') then return end

	local supay = game.TraitData.TorchAutofireAspect
	if not supay or not supay.RarityLevels then return end

	local modifiers = supay.AddOutgoingDamageModifiers
	local scaled = modifiers and modifiers.ValidWeaponMultiplier
	if not scaled then return end

	local tuning = mod.tuning.AspectOfSupay
	scaled.BaseValue = 1 + tuning.SprintDamageBonus

	for rarity, multiplier in pairs(tuning.RarityMultipliers) do
		if supay.RarityLevels[rarity] then
			supay.RarityLevels[rarity].Multiplier = multiplier
		end
	end
end)
