---@meta _


SEISMIC_BLAST_COOLDOWNS = {
	MassiveAttack = 'HephaestusWeaponBoon',
	MassiveSpecial = 'HephaestusSpecialBoon',
	HephSprint = 'HephaestusSprintBoon',
}


SEISMIC_BLAST_BOONS = {
	HephaestusWeaponBoon = 'OnEnemyDamagedAction',
	HephaestusSpecialBoon = 'OnEnemyDamagedAction',
	HephaestusSprintBoon = 'OnBlinkEndAction',
}


once('SeismicHammer', function()
	if not boon_edit_on('SeismicHammer') then return end

	local hammer = game.TraitData.MassiveCastBoon

	hammer.OlympianRechargeMultiplier = nil

	hammer.BoonEditRechargeReduction = mod.tuning.SeismicHammer.RechargeReduction
	hammer.StatLines = { 'BoonEditSeismicHammerStatDisplay' }
	hammer.ExtractValues = {
		{ Key = 'BoonEditRechargeReduction', ExtractAs = 'TooltipCooldown' },
	}

	modutil.mod.Path.Wrap("CheckMassiveAttack", function(base, victim, functionArgs, triggerArgs)
		if not seismic_hammer_shortens(functionArgs) then
			return base(victim, functionArgs, triggerArgs)
		end

		local full = functionArgs.Cooldown
		functionArgs.Cooldown = seismic_hammer_recharge(full, boon_recharge_multiplier(), {
			SourceFloor = boon_recharge_source_floor(functionArgs.TraitName, 'Cooldown'),
		})

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

	hammer.OnProjectileDeathFunction = {
		ValidProjectiles = { 'ProjectileCast' },
		Name = _PLUGIN.guid .. '.SeismicHammerDetonation',
	}
	hammer.OnProjectileDeathFunction.ValidProjectilesLookup =
		game.ToLookup(hammer.OnProjectileDeathFunction.ValidProjectiles)

	modutil.mod.Path.Wrap("SetTraitTextData", function(base, traitData, args)
		seismic_hammer_report(traitData)
		return base(traitData, args)
	end)

	modutil.mod.Path.Wrap("CheckCooldown", function(base, name, time, unmodified)
		local ready = base(name, time, unmodified)
		if ready then seismic_hammer_cooldown_started(name, time) end
		return ready
	end)
end)


function seismic_hammer_blasts_reduce()
	return mod.tuning.SeismicHammer.OmegaCastReducesCooldowns and seismic_hammer_active()
end


function seismic_hammer_reduces(name)
	mod.SeismicHammerReduces = mod.SeismicHammerReduces or {}
	local known = mod.SeismicHammerReduces[name]
	if known ~= nil then return known end

	known = false
	for _, pattern in ipairs(mod.tuning.SeismicHammer.ReducedCooldowns) do
		if name == pattern or (#name > #pattern and (name:sub(1, #pattern) == pattern or name:sub(-#pattern) == pattern)) then
			known = true
			break
		end
	end

	mod.SeismicHammerReduces[name] = known
	return known
end


function seismic_hammer_cooldown_started(name, time)
	if type(name) ~= 'string' or type(time) ~= 'number' or time <= 0 then return end
	if not seismic_hammer_blasts_reduce() or not seismic_hammer_reduces(name) then return end

	mod.SeismicHammerCooldowns = mod.SeismicHammerCooldowns or {}
	mod.SeismicHammerCooldowns[name] = { Time = time, Shift = 0 }

end


function mod.SeismicHammerDetonation(triggerArgs)
	if not triggerArgs or not triggerArgs.Armed or not triggerArgs.Detonated then return end
	if seismic_hammer_blasts_reduce() then seismic_hammer_blast() end
end


function seismic_hammer_cooldown_floor(name)
	local floor = boon_recharge_source_floor(SEISMIC_BLAST_COOLDOWNS[name], 'Cooldown')
	if floor then return floor * boon_recharge_multiplier() end
	return 0
end


function seismic_hammer_blast()
	local cooldowns = game.SessionState.GlobalCooldowns
	if not cooldowns then return end

	local reduction = mod.tuning.SeismicHammer.RechargeReduction
	for name, entry in pairs(mod.SeismicHammerCooldowns or {}) do
		local started = cooldowns[name]
		if type(started) == 'number' then
			local shift = math.min(reduction, entry.Time - seismic_hammer_cooldown_floor(name) - entry.Shift)
			if shift > 0 then
				cooldowns[name] = started - shift
				entry.Shift = entry.Shift + shift
			end
		end
	end
end


function seismic_hammer_recharge(seconds, multiplier, opts)
	if not seismic_hammer_active() or mod.tuning.SeismicHammer.OmegaCastReducesCooldowns then return seconds end

	local tuning = mod.tuning.SeismicHammer
	opts = opts or {}
	local floor = math.max(
		type(opts.Floor) == 'number' and opts.Floor or 0,
		type(opts.SourceFloor) == 'number' and opts.SourceFloor * multiplier or 0
	)
	local full = seconds * multiplier
	local reduced = math.max(math.min(full, floor), full - tuning.RechargeReduction)

	return reduced / multiplier
end


function seismic_hammer_active()
	if not boon_edit_on('SeismicHammer') then return false end
	if not game.CurrentRun or not game.CurrentRun.Hero then return false end
	return game.HeroHasTrait('MassiveCastBoon')
end


function seismic_hammer_report(traitData)
	if not boon_edit_on('SeismicHammer') then return end
	local field = traitData and SEISMIC_BLAST_BOONS[traitData.Name]
	if not field then return end
	if not in_run() or not game.HeroHasTrait('MassiveCastBoon') then return end

	local action = traitData[field]
	local args = action and (action.Args or action.FunctionArgs)
	local full = args and args.Cooldown
	if type(full) ~= 'number' or full <= 0 then return end

	traitData.ReportedCooldown = seismic_hammer_recharge(full, 1, {
		SourceFloor = boon_recharge_source_floor(traitData.Name, 'Cooldown'),
	})
end


function seismic_hammer_shortens(functionArgs)
	if not seismic_hammer_active() or mod.tuning.SeismicHammer.OmegaCastReducesCooldowns then return false end
	return type(functionArgs and functionArgs.Cooldown) == 'number' and functionArgs.Cooldown > 0
end
