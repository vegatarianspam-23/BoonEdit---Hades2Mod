---@meta _


local BLOOD_SPREE = 'LowHealthLifestealBoon'


once('BloodSpreeKillCrit', function()

	modutil.mod.Path.Wrap("KillEnemy", function(base, victim, triggerArgs)
		base(victim, triggerArgs)
		blood_spree_orphan_kill(victim, triggerArgs)
	end)

	if not boon_edit_on('BloodSpree') then return end

	local trait = game.TraitData[BLOOD_SPREE]
	if not trait then return end

	trait.OnEnemyDeathFunction = { Name = _PLUGIN.guid .. '.BloodSpreeKill' }

	trait.BoonEditKillHealChance = mod.tuning.BloodSpree.KillHealChance
	table.insert(trait.ExtractValues, {
		Key = 'BoonEditKillHealChance',
		ExtractAs = 'TooltipKillHealChance',
		Format = 'LuckModifiedPercent',
		SkipAutoExtract = true,
	})
end)


local ORPHANED_KILL_EFFECTS = {
	DamageShareDeath = true,
}

function blood_spree_orphan_kill(victim, triggerArgs)
	if not boon_edit_on('BloodSpree') then return end

	if not game.HeroHasTrait(BLOOD_SPREE) then return end
	if not victim or victim.SkipModifiers then return end
	if not triggerArgs or triggerArgs.AttackerTable ~= nil then return end
	if not ORPHANED_KILL_EFFECTS[triggerArgs.EffectName] then return end

	mod.BloodSpreeKill(victim, nil, triggerArgs)
end


---@diagnostic disable-next-line: unused-local
function mod.BloodSpreeKill(victim, _args, _triggerArgs)
	if not boon_edit_on('BloodSpree') then return end
	if is_allied_summon(victim) then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	if not rolls(mod.tuning.BloodSpree.KillHealChance) then return end

	local amount = blood_spree_heal_amount()
	if amount <= 0 then return end

	game.Heal(hero, {
		HealAmount = game.round(amount * game.CalculateHealingMultiplier()),
		SourceName = BLOOD_SPREE,
	})
end


function blood_spree_heal_amount()
	local trait = game.GetHeroTrait(BLOOD_SPREE)
	local modifiers = trait and trait.AddOutgoingLifestealModifiers
	local amount = modifiers and modifiers.MaxLifesteal

	if type(amount) ~= 'number' then return 0 end
	return amount
end
