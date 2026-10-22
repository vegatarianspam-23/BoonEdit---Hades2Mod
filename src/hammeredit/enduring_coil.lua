---@meta _


once('EnduringCoil', function()
	if not boon_edit_on('EnduringCoil') then return end

	local enduringCoil = game.TraitData.TorchSpecialImpactTrait

	for _, property in ipairs(enduringCoil.PropertyChanges) do
		if property.ProjectileProperty == 'Fuse' then
			property.ProjectileName = nil
			property.ChangeType = 'Multiply'
			property.ChangeValue = mod.tuning.EnduringCoil.FuseMultiplier
			property.BaseValue = nil
		end
	end

	for _, extract in ipairs(enduringCoil.ExtractValues) do
		if extract.Key == 'ReportedIncrease' then
			extract.Format = 'PercentDelta'
			extract.IncludeSigns = true
		end
	end
end)
