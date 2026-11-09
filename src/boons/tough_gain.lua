---@meta _


once('ToughGain', function()
	if not boon_edit_on('ToughGain') then return end

	local tough = game.TraitData.HephaestusManaBoon
	local tuning = mod.tuning.ToughGain

	tough.BlockStacking = nil
	tough.DamageShave.AbsoluteStackValues = { tuning.PomDamageReduction }
	tough.DamageShave.MaximumValue = tuning.MaxDamageReduction
end)
