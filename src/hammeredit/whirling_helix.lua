---@meta _


once('WhirlingHelix', function()
	if not boon_edit_on('WhirlingHelix') then return end

	local whirlingHelix = game.TraitData.TorchOrbitPointTrait

	for _, property in ipairs(whirlingHelix.PropertyChanges) do
		if property.ProjectileProperty == 'Speed' then
			property.BaseValue = mod.tuning.WhirlingHelix.SpeedMultiplier
		end
	end
end)
