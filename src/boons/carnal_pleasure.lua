---@meta _


local HEART_BREAKER = 'ManaBurstBoon'
local HEARTTHROB = 'AphroditeBurst'


function carnal_pleasure_held()
	return boon_edit_on('CarnalPleasure') and game.HeroHasTrait('BloodManaBurstBoon')
end


once('CarnalPleasureHeartBreaker', function()
	if boon_edit_on('CarnalPleasure') then
		local carnal = game.TraitData.BloodManaBurstBoon
		local tuning = mod.tuning.CarnalPleasure

		carnal.DropManaBurstChance = tuning.PickupHeartthrobChance
		carnal.BoonEditManaPerPlasma = tuning.ManaPerPlasma
		carnal.BoonEditDamagePerPlasma = tuning.DamagePerPlasma

		carnal.StatLines = { 'BoonEditCarnalManaStatDisplay', 'BoonEditCarnalDamageStatDisplay' }

		local extracts = {
			{ Key = 'BoonEditManaPerPlasma', ExtractAs = 'TooltipManaPerPlasma' },
			{ Key = 'BoonEditDamagePerPlasma', ExtractAs = 'TooltipDamagePerPlasma', IncludeSigns = true },
		}
		for _, extract in ipairs(carnal.ExtractValues or {}) do
			if extract.SkipAutoExtract then table.insert(extracts, extract) end
		end
		carnal.ExtractValues = extracts
	end

	modutil.mod.Path.Wrap("BloodDropUse", function(base, args, consumable)
		local result = base(args, consumable)
		carnal_pleasure_feed_heart_breaker()
		return result
	end)

	modutil.mod.Path.Wrap("CalculateBaseDamageAdditions", function(base, attacker, victim, triggerArgs)
		return base(attacker, victim, triggerArgs) + carnal_pleasure_heartthrob_power(attacker, triggerArgs)
	end)
end)


function carnal_pleasure_feed_heart_breaker()
	if not carnal_pleasure_held() then return end

	local breaker = game.GetHeroTrait(HEART_BREAKER)
	local action = breaker and breaker.OnManaSpendAction
	if not action or not action.FunctionArgs then return end

	local plasma = 1 * game.GetTotalHeroTraitValue('BloodDropMultiplier', { IsMultiplier = true })
	local mana = plasma * mod.tuning.CarnalPleasure.ManaPerPlasma
	if mana <= 0 then return end

	game.CheckManaBurst(action.FunctionArgs, mana)
end


function carnal_pleasure_heartthrob_power(attacker, triggerArgs)
	if not triggerArgs or triggerArgs.EffectName or triggerArgs.SourceProjectile ~= HEARTTHROB then return 0 end
	if attacker ~= (game.CurrentRun and game.CurrentRun.Hero) then return 0 end
	if not carnal_pleasure_held() then return 0 end

	local room = game.CurrentRun.CurrentRoom
	local plasma = (room and room.BloodDropCount) or 0
	return plasma * mod.tuning.CarnalPleasure.DamagePerPlasma
end
