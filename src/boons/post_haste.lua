---@meta _


once('HardTargetBecomesPostHaste', function()
	if boon_edit_on('PostHaste') then
		local haste = game.TraitData.SlowProjectileBoon

		haste.EnemyProjectileSpeedMultiplier = nil
		haste.Elements = { mod.tuning.PostHaste.Element }

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
end)

