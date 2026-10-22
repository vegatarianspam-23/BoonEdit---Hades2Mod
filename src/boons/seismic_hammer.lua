---@meta _


once('SeismicHammer', function()
	if not boon_edit_on('SeismicHammer') then return end

	local hammer = game.TraitData.MassiveCastBoon

	hammer.OlympianRechargeMultiplier = nil

	hammer.BoonEditBlastCooldown = mod.tuning.SeismicHammer.BlastCooldownReduction
	hammer.StatLines = { 'BoonEditSeismicHammerStatDisplay' }
	hammer.ExtractValues = {
		{ Key = 'BoonEditBlastCooldown', ExtractAs = 'TooltipCooldown' },
	}

	modutil.mod.Path.Wrap("CheckMassiveAttack", function(base, victim, functionArgs, triggerArgs)
		if not seismic_hammer_shortens(functionArgs) then
			return base(victim, functionArgs, triggerArgs)
		end

		local tuning = mod.tuning.SeismicHammer
		local full = functionArgs.Cooldown
		functionArgs.Cooldown = math.max(tuning.MinimumBlastCooldown, full - tuning.BlastCooldownReduction)

		local ok, err = pcall(base, victim, functionArgs, triggerArgs)
		functionArgs.Cooldown = full
		if not ok then error(err) end
	end)

	hammer.OnProjectileCreationFunction = {
		ValidProjectiles = { 'MassiveSlamBlast' },
		Name = 'CheckAxeCastArm',
		Args = {
			BlastMultiplier = { BaseValue = 1.15, SourceIsMultiplier = true },
		},
	}
	hammer.OnProjectileCreationFunction.ValidProjectilesLookup =
		game.ToLookup(hammer.OnProjectileCreationFunction.ValidProjectiles)

	modutil.mod.Path.Wrap("SetTraitTextData", function(base, traitData, args)
		seismic_hammer_report(traitData)
		return base(traitData, args)
	end)
end)


SEISMIC_BLAST_BOONS = {
	HephaestusWeaponBoon = true,
	HephaestusSpecialBoon = true,
}


function seismic_hammer_report(traitData)
	if not boon_edit_on('SeismicHammer') then return end
	if not traitData or not SEISMIC_BLAST_BOONS[traitData.Name] then return end
	if not in_run() or not game.HeroHasTrait('MassiveCastBoon') then return end

	local action = traitData.OnEnemyDamagedAction
	local full = action and action.Args and action.Args.Cooldown
	if type(full) ~= 'number' then return end

	local tuning = mod.tuning.SeismicHammer
	traitData.ReportedCooldown =
		math.max(tuning.MinimumBlastCooldown, full - tuning.BlastCooldownReduction)
end


function seismic_hammer_shortens(functionArgs)
	if not boon_edit_on('SeismicHammer') then return false end
	if not game.HeroHasTrait('MassiveCastBoon') then return false end
	return type(functionArgs and functionArgs.Cooldown) == 'number' and functionArgs.Cooldown > 0
end
