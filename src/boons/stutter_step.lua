---@meta _


once('StutterStepRushTrails', function()
	if not boon_edit_on('StutterStep') then return end

	local stutter = game.TraitData.SorcerySpeedBoon
	if not stutter or not stutter.PropertyChanges then return end

	table.insert(stutter.PropertyChanges, {
		WeaponName = 'WeaponSprint',
		WeaponProperty = 'ProjectileInterval',
		BaseValue = mod.tuning.StutterStep.RushInterval,
		SourceIsMultiplier = true,
		DecimalPlaces = 3,
		ChangeType = 'Multiply',
		ReportValues = { BoonEditRushInterval = 'ChangeValue' },
	})
end)


function stutter_step_interval(seconds)
	if not boon_edit_on('StutterStep') then return seconds end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return seconds end

	local scale = 1
	for _, trait in ipairs(hero.Traits or {}) do
		if trait.Name == 'SorcerySpeedBoon' and type(trait.BoonEditRushInterval) == 'number' then
			scale = scale * trait.BoonEditRushInterval
		end
	end

	return seconds * scale
end
