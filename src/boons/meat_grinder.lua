---@meta _


local RIFT = 'AresProjectile'


once('MeatGrinderArea', function()
	if not boon_edit_on('MeatGrinder') then return end

	local grinder = game.TraitData.AresExCastBoon
	grinder.OnProjectileArmFunction.FunctionName = _PLUGIN.guid .. '.MeatGrinderCastArmed'
end)


---@diagnostic disable-next-line: unused-local
function mod.MeatGrinderCastArmed(triggerArgs, functionArgs)
	local projectileId = triggerArgs.ProjectileId
	local dataProperties = {}
	if game.HeroHasTrait('SelfCastBoon') and projectileId ~= game.SessionMapState.FamiliarCastProjectileId then
		dataProperties.AttachToOwner = true
		dataProperties.IgnoreCancelAttachedProjectiles = true
	end
	game.CreateProjectileFromUnit({
		Name = functionArgs.ProjectileName,
		Id = game.CurrentRun.Hero.ObjectId,
		ProjectileDestinationId = projectileId,
		FireFromTarget = true,
		DamageMultiplier = functionArgs.DamageMultiplier,
		DataProperties = dataProperties,
		BlastRadiusModifier = cast_area_multiplier(),
	})
end


once('MeatGrinderBloodSpill', function()
	if not boon_edit_on('MeatGrinder') then return end

	local grinder = game.TraitData.AresExCastBoon

	grinder.AcquireFunctionName = 'SetupBloodDropDisplay'
	grinder.OnExpire = { FunctionName = 'CheckBloodDropDisplay' }

	grinder.OnEnemyDamagedAction = {
		ValidProjectiles = { RIFT },
		ValidProjectilesLookup = game.ToLookup({ RIFT }),
		FunctionName = _PLUGIN.guid .. '.MeatGrinderPlasma',
		Args = {
			Chance = { BaseValue = mod.tuning.MeatGrinder.PlasmaChance },
			Cooldown = mod.tuning.MeatGrinder.PlasmaCooldown,
			Name = 'BloodDrop',
		},
	}
end)


---@diagnostic disable-next-line: unused-local
function mod.MeatGrinderPlasma(victim, functionArgs, triggerArgs)
	if not victim or victim.IsDead or not victim.Health then return end
	if triggerArgs and (triggerArgs.DamageAmount or 0) <= 0 then return end

	local chance = functionArgs.Chance or 0
	if chance <= 0 then return end

	local luck = game.GetTotalHeroTraitValue('LuckMultiplier', { IsMultiplier = true })
	if not game.RandomChance(chance * luck) then return end

	local cooldown = functionArgs.Cooldown or mod.tuning.MeatGrinder.PlasmaCooldown
	local cooldownKey = 'BoonEditMeatGrinderPlasma'
	if mod.tuning.MeatGrinder.PlasmaCooldownPerFoe then
		cooldownKey = cooldownKey .. tostring(victim.ObjectId)
	end
	if not game.CheckCooldown(cooldownKey, cooldown) then return end

	game.thread(game.CreateBloodDrop, victim, functionArgs)
end


once('MeatGrinderPlasmaDisplay', function()
	modutil.mod.Path.Wrap('CheckBloodDropDisplay', function(base, ...)
		base(...)
		meat_grinder_plasma_display()
	end)
end)


function meat_grinder_plasma_display()
	if not boon_edit_on('MeatGrinder') then return end
	if not game.HeroHasTrait('AresExCastBoon') then return end

	game.SetupBloodDropDisplay()
end
