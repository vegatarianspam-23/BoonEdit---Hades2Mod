---@meta _


once('HardTargetBecomesPostHaste', function()
	if boon_edit_on('PostHaste') then
		local haste = game.TraitData.SlowProjectileBoon

		haste.EnemyProjectileSpeedMultiplier = nil

		local function speedup(factor)
			return (1 - 1 / factor) / (1 - 1 / 1.20)
		end

		haste.OlympianRechargeMultiplier = { BaseValue = 1 / 1.20, SourceIsMultiplier = true }
		haste.RarityLevels = {
			Common = { Multiplier = speedup(1.20) },
			Rare   = { Multiplier = speedup(1.25) },
			Epic   = { Multiplier = speedup(1.30) },
			Heroic = { Multiplier = speedup(1.35) },
		}

		haste.StatLines = { 'RechargeSpeedStatDisplay' }
		haste.ExtractValues = {
			{
				Key = 'OlympianRechargeMultiplier',
				ExtractAs = 'RechargeMultiplier',
				Format = 'PercentReciprocalDelta',
			},
		}
	end

	modutil.mod.Path.Wrap("HadesRetaliate", function(base, unit, args, triggerArgs)
		return base(unit, post_haste_recharge(args), triggerArgs)
	end)
end)


function post_haste_recharge(args)
	if not boon_edit_on('PostHaste') then return args end
	if not args or not args.Cooldown then return args end

	local multiplier = game.GetTotalHeroTraitValue('OlympianRechargeMultiplier', { IsMultiplier = true })
	if multiplier == 1 then return args end

	local scaled = game.ShallowCopyTable(args)
	scaled.Cooldown = args.Cooldown * multiplier
	return scaled
end
