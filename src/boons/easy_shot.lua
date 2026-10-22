---@meta _


once('EasyShotDamage', function()
	if not boon_edit_on('EasyShot') then return end

	local easyShot = game.TraitData.OmegaCastVolleyBoon
	if not easyShot or not easyShot.OnEnemyDamagedAction then return end

	easyShot.BlockStacking = true

	local args = easyShot.OnEnemyDamagedAction.Args
	if not args or type(args.DamageMultiplier) ~= 'table' then return end

	args.DamageMultiplier.BaseValue = mod.tuning.EasyShot.DamageMultiplier
end)


once('EasyShotCrit', function()
	if not boon_edit_on('EasyShot') then return end

	local easyShot = game.TraitData.OmegaCastVolleyBoon
	if not easyShot then return end

	local projectiles = { 'ArtemisCastVolley' }

	easyShot.AddOutgoingCritModifiers = easyShot.AddOutgoingCritModifiers or {
		ValidProjectiles = projectiles,
		ValidProjectilesLookup = game.ToLookup(projectiles),
		Chance = { BaseValue = mod.tuning.EasyShot.CritChance },
	}
end)
