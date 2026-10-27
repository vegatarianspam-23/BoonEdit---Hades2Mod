---@meta _


once('EnfeeblementOfCowards', function()
	if not boon_edit_on('EnfeeblementOfCowards') then return end

	local curse = game.TraitData.SlowProjectileCurse
	if not curse or not curse.EnemyProjectileSpeedMultiplier then return end

	curse.EnemyProjectileSpeedMultiplier.BaseValue = mod.tuning.EnfeeblementOfCowards.ProjectileSpeed
end)
