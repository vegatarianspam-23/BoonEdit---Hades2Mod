---@meta _


once('ArterialSprayAlwaysDouble', function()
	if boon_edit_on('ArterialSpray') then
		local arterial = game.TraitData.DoubleSplashBoon
		arterial.ConeModifier.DoubleWaveChance = 1.0

		arterial.BoonEditSecondWavePower = mod.tuning.ArterialSpray.SecondWavePower
		arterial.StatLines = { 'BoonEditSecondSplashStatDisplay' }
		arterial.ExtractValues = {
			{ Key = 'BoonEditSecondWavePower', ExtractAs = 'TooltipSecondWave', Format = 'Percent', HideSigns = true },
		}
	end

	local function withArterialSpray(base, functionArgs, ...)
		arterial_spray_begin(functionArgs)
		local ok, err = pcall(base, ...)
		arterial_spray_end()
		if not ok then error(err) end
	end

	modutil.mod.Path.Wrap("CheckPoseidonSplash", function(base, victim, functionArgs, triggerArgs)
		withArterialSpray(base, functionArgs, victim, functionArgs, triggerArgs)
	end)

	modutil.mod.Path.Wrap("PoseidonAttackPunish", function(base, unit, functionArgs)
		withArterialSpray(base, functionArgs, unit, functionArgs)
	end)

	modutil.mod.Path.Wrap("CreateProjectileFromUnit", function(base, args)
		if arterial_spray_weaken then
			args = arterial_spray_weaken(args)
		end
		return base(args)
	end)
end)


arterial_spray_projectile = nil

function arterial_spray_begin(functionArgs)
	arterial_spray_projectile = nil
	if not boon_edit_on('ArterialSpray') then return end
	if not game.HeroHasTrait('DoubleSplashBoon') then return end
	arterial_spray_projectile = functionArgs and functionArgs.ProjectileName
end

function arterial_spray_end()
	arterial_spray_projectile = nil
end

function arterial_spray_weaken(args)
	if not arterial_spray_projectile then return args end
	if not args or args.Name ~= arterial_spray_projectile then return args end

	local startDelay = args.DataProperties and args.DataProperties.StartDelay
	if not startDelay or startDelay <= 0 then return args end

	args.DamageMultiplier = (args.DamageMultiplier or 1) * mod.tuning.ArterialSpray.SecondWavePower
	return args
end
