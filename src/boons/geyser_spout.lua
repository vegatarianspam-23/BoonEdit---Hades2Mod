---@meta _
---@diagnostic disable: lowercase-global


once('GeyserSpoutSplash', function()
	modutil.mod.Path.Wrap("CheckArmedApolloCast", function(base, triggerArgs, functionArgs)
		if not geyser_spout_handles(functionArgs) then return base(triggerArgs, functionArgs) end
		return geyser_spout_splash(triggerArgs, functionArgs)
	end)
end)


function geyser_spout_handles(functionArgs)
	return boon_edit_on('GeyserSpout') and functionArgs ~= nil
		and functionArgs.ProjectileName == mod.tuning.GeyserSpout.ImpulseProjectile
end


function geyser_spout_splash(triggerArgs, functionArgs)
	local encounter = game.CurrentRun.CurrentRoom and game.CurrentRun.CurrentRoom.Encounter
	if encounter and encounter.BossKillPresentation then return end

	if not triggerArgs or triggerArgs.name ~= functionArgs.ValidProjectileName then return end
	if not triggerArgs.Armed or not triggerArgs.Detonated then return end
	if not triggerArgs.LocationX or not triggerArgs.LocationY then return end

	local repeats = game.SessionMapState.InvalidRepeatCastIds
	if repeats and repeats[triggerArgs.ProjectileId] then return end

	local tuning = mod.tuning.GeyserSpout
	local scale = poseidon_splash_scale()
	local modifier = game.GetProjectileProperty({ ProjectileId = triggerArgs.ProjectileId, Property = 'BlastRadiusModifier' })
	if type(modifier) ~= 'number' or modifier <= 0 then modifier = 1 end

	local derived = game.GetDerivedPropertyChangeValues({
		ProjectileName = tuning.ImpulseProjectile,
		WeaponName = triggerArgs.WeaponName,
		Type = 'Projectile',
		MatchProjectileName = true,
	})

	local dropLocation = game.SpawnObstacle({ Name = 'InvisibleTarget', LocationX = triggerArgs.LocationX, LocationY = triggerArgs.LocationY })
	game.CreateProjectileFromUnit({
		Name = tuning.ImpulseProjectile,
		Id = game.CurrentRun.Hero.ObjectId,
		DestinationId = dropLocation,
		FireFromTarget = true,
		BlastRadiusModifier = modifier * scale,
		DamageMultiplier = functionArgs.DamageMultiplier,
		DataProperties = derived.PropertyChanges,
		ThingProperties = derived.ThingPropertyChanges,
	})
	game.Destroy({ Id = dropLocation })

	local radius = game.GetBaseDataValue({ Type = 'Projectile', Name = tuning.ImpulseProjectile, Property = 'DamageRadius' })
	if type(radius) ~= 'number' or radius <= 0 then return end

	poseidon_circle_splash({
		X = triggerArgs.LocationX,
		Y = triggerArgs.LocationY,
		Radius = radius * modifier * scale,
		Damage = geyser_spout_damage(),
		Knockback = tuning.Knockback,
		From = 2,
	})
end


function geyser_spout_damage()
	local derived = game.GetDerivedPropertyChangeValues({
		ProjectileName = 'ProjectileCast',
		WeaponName = 'WeaponCast',
		Type = 'Projectile',
	})
	local damage = derived and derived.PropertyChanges and derived.PropertyChanges.ArmedExpirationDamage
	if type(damage) == 'number' and damage > 0 then return damage end

	local base = game.GetBaseDataValue({ Type = 'Projectile', Name = 'ProjectileCast', Property = 'ArmedExpirationDamage' })
	return type(base) == 'number' and base or 0
end
