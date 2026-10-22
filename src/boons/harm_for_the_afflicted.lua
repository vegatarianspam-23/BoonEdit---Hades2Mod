---@meta _


once('HarmForTheAfflictedEveryStatus', function()
	if not boon_edit_on('HarmForTheAfflicted') then return end

	local harm = game.TraitData.NewStatusDamage
	harm.OnEffectApplyFunction.FunctionName = _PLUGIN.guid .. '.HarmForTheAfflicted'
	harm.OnEffectApplyFunction.FunctionArgs.Cooldown = mod.tuning.HarmForTheAfflicted.Interval
end)


local function harm_curse_category(effectName)
	local effect = game.EffectData[effectName]
	if not effect or not effect.DisplaySuffix then return nil end
	return effect.SharedVulnerabilityCategory or effect.DisplaySuffix
end

---@diagnostic disable-next-line: unused-local
function mod.HarmForTheAfflicted(_, functionArgs, triggerArgs)
	if not boon_edit_on('HarmForTheAfflicted') then return end
	if not triggerArgs or not triggerArgs.IsVulnerabilityEffect or triggerArgs.Reapplied then return end

	local victim = triggerArgs.Victim
	if not victim or not victim.ObjectId then return end

	local category = harm_curse_category(triggerArgs.EffectName)
	if not category then return end

	if not game.CheckCooldown('BoonEditHarmAfflicted' .. victim.ObjectId .. category, functionArgs.Cooldown) then
		return
	end

	game.CreateProjectileFromUnit({
		Name = functionArgs.ProjectileName,
		Id = game.CurrentRun.Hero.ObjectId,
		DestinationId = victim.ObjectId,
		DamageMultiplier = functionArgs.DamageMultiplier,
	})

	local trait = game.GetHeroTrait('NewStatusDamage')
	if trait then
		game.TraitUIActivateTrait(trait, { FlashOnActive = true, Duration = functionArgs.Cooldown })
	end

	if not victim.IsDead then
		game.CreateAnimation({ Name = 'MedeaPoisonDamage', DestinationId = victim.ObjectId })
		victim.CreatedAnimations = victim.CreatedAnimations or {}
		table.insert(victim.CreatedAnimations, 'MedeaPoisonDamage')
	end
end
