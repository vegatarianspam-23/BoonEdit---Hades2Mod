---@meta _


once('HostileEnvironmentCastFollows', function()
	modutil.mod.Path.Wrap("CheckCastDetach", function(base, weaponData, args, triggerArgs)
		if hostile_environment_keeps_cast() then return end
		return base(weaponData, args, triggerArgs)
	end)

	modutil.mod.Path.Wrap("HestiaCastDefense", function(base, weaponData, traitArgs, triggerArgs)
		base(weaponData, traitArgs, triggerArgs)
		cast_defense_follows_caster()
	end)

	modutil.mod.Path.Wrap("CheckFamiliarLink", function(base, weaponData, functionArgs, triggerArgs)
		base(weaponData, functionArgs, triggerArgs)
		familiar_cast_follows_familiar()
	end)

	modutil.mod.Path.Wrap("DemeterCastBlast", function(base, weaponData, traitArgs, triggerArgs)
		local storms = game.MapState.CastStorms
		local before = storms and storms[#storms]
		base(weaponData, traitArgs, triggerArgs)
		cast_storm_follows_caster(triggerArgs, before)
	end)

	modutil.mod.Path.Wrap("FireCastAtLocation", function(base, triggerArgs, ...)
		if hostile_environment_cast_thrown(triggerArgs) then return end
		return base(hostile_environment_cast_on_caster(triggerArgs), ...)
	end)

	modutil.mod.Path.Wrap("AttachCastAtLocation", function(base, triggerArgs, ...)
		if hostile_environment_cast_thrown(triggerArgs) then return end
		return base(triggerArgs, ...)
	end)

	modutil.mod.Path.Wrap("CheckPlayerOnFirePowers", function(base, triggerArgs, ...)
		local result = base(triggerArgs, ...)
		hostile_environment_cast_on_throw(triggerArgs)
		return result
	end)

	modutil.mod.Path.Wrap("FireAnywhereCastAtLocation", function(base, owner, weaponData, functionArgs, triggerArgs)
		if not hostile_environment_keeps_cast() then
			return base(owner, weaponData, functionArgs, triggerArgs)
		end
		return hostile_environment_anywhere_cast(triggerArgs)
	end)

	modutil.mod.Path.Wrap("OnDemeterCastArmed", function(base, triggerArgs, functionArgs)
		base(triggerArgs, functionArgs)
		hostile_environment_cast_armed(triggerArgs)
	end)

	modutil.mod.Path.Wrap("CheckArmedApolloCast", function(base, triggerArgs, functionArgs)
		if hostile_environment_flare_fired(triggerArgs, functionArgs) then return end
		return base(triggerArgs, functionArgs)
	end)
end)


function hostile_environment_keeps_cast()
	return boon_edit_on('HostileEnvironment') and game.HeroHasTrait('SelfCastBoon')
end

function cast_defense_follows_caster()
	if not hostile_environment_keeps_cast() then return end

	local defenses = game.SessionMapState.CastDefense
	local projectileId = defenses and defenses[#defenses]
	if not projectileId then return end

	game.AttachProjectiles({ Ids = { projectileId }, DestinationId = game.CurrentRun.Hero.ObjectId })
end

function familiar_cast_follows_familiar()
	if not hostile_environment_keeps_cast() then return end

	local projectileId = game.SessionMapState.FamiliarCastProjectileId
	local anchorId = game.MapState.FamiliarLocationId
	if not projectileId or not anchorId then return end

	game.AttachProjectiles({ Ids = { projectileId }, DestinationId = anchorId })
end


function cast_storm_follows_caster(triggerArgs, before)
	if not hostile_environment_keeps_cast() then return end

	local storms = game.MapState.CastStorms
	local ids = storms and storms[#storms]
	if not ids or ids == before or game.IsEmpty(ids) then return end

	local anchorId = game.CurrentRun.Hero.ObjectId
	if triggerArgs and triggerArgs.UnitIdOverride then
		anchorId = game.MapState.FamiliarLocationId
	end
	if not anchorId then return end

	game.AttachProjectiles({ Ids = ids, DestinationId = anchorId })
end


function hostile_environment_cast_on_throw(triggerArgs)
	if not hostile_environment_keeps_cast() or not triggerArgs then return end
	if not mod.tuning.HostileEnvironment.InstantCasts[triggerArgs.name] then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or triggerArgs.OwnerTable ~= hero then return end

	local session = game.SessionMapState
	session.BoonEditThrownCasts = (session.BoonEditThrownCasts or 0) + 1
	game.FireWeaponFromUnit({ Weapon = 'WeaponCast', Id = hero.ObjectId, DestinationId = hero.ObjectId, FireFromTarget = true })
end

function hostile_environment_cast_thrown(triggerArgs)
	local copies = mod.RippleCastCopies
	if copies and triggerArgs and triggerArgs.ProjectileId and copies[triggerArgs.ProjectileId] then return false end

	local session = game.SessionMapState
	local thrown = session and session.BoonEditThrownCasts or 0
	if thrown <= 0 then return false end

	session.BoonEditThrownCasts = thrown - 1
	return true
end

function hostile_environment_cast_on_caster(triggerArgs)
	if not hostile_environment_keeps_cast() or not triggerArgs then return triggerArgs end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	local location = hero and game.GetLocation({ Id = hero.ObjectId })
	if not location then return triggerArgs end

	local moved = game.ShallowCopyTable(triggerArgs)
	moved.LocationX = location.X
	moved.LocationY = location.Y
	return moved
end

function hostile_environment_anywhere_cast(triggerArgs)
	if not triggerArgs or not triggerArgs.ProjectileX or not triggerArgs.ProjectileY then return end

	local hero = game.CurrentRun.Hero
	game.FireWeaponFromUnit({ Weapon = 'WeaponCast', Id = hero.ObjectId, DestinationId = hero.ObjectId, FireFromTarget = true })

	local doubleBoltChance = game.GetTotalHeroTraitValue('DoubleBoltChance')
	if not game.RandomChance(doubleBoltChance * game.GetTotalHeroTraitValue('LuckMultiplier', { IsMultiplier = true })) then
		return
	end

	local dropLocation = game.SpawnObstacle({ Name = 'InvisibleTarget', LocationX = triggerArgs.ProjectileX, LocationY = triggerArgs.ProjectileY })
	game.wait(0.3, game.RoomThreadName)
	local derivedValues = game.GetDerivedPropertyChangeValues({
		ProjectileName = 'ZeusCastAnywhereBlast',
		WeaponName = 'WeaponAnywhereCast',
		Type = 'Projectile',
	})
	game.CreateProjectileFromUnit({
		Name = 'ZeusCastAnywhereBlast',
		WeaponName = 'WeaponAnywhereCast',
		DataProperties = derivedValues.PropertyChanges,
		DestinationId = dropLocation,
		Id = hero.ObjectId,
		FireFromTarget = true,
	})
	game.Destroy({ Id = dropLocation })
end


local function hostile_environment_cast_anchor(projectileId)
	if projectileId ~= nil and projectileId == game.SessionMapState.FamiliarCastProjectileId then
		return game.MapState.FamiliarLocationId
	end
	return game.CurrentRun.Hero.ObjectId
end

function hostile_environment_cast_armed(triggerArgs)
	if not hostile_environment_keeps_cast() then return end
	if not triggerArgs or not triggerArgs.ProjectileId then return end
	if not triggerArgs.LocationX or not triggerArgs.LocationY then return end

	local encounter = game.CurrentRun.CurrentRoom and game.CurrentRun.CurrentRoom.Encounter
	if encounter and encounter.BossKillPresentation then return end

	local session = game.SessionMapState
	local repeats = session.InvalidRepeatCastIds
	if repeats and repeats[triggerArgs.ProjectileId] then return end

	session.BoonEditArmedCasts = session.BoonEditArmedCasts or {}
	session.BoonEditArmedCasts[triggerArgs.ProjectileId] = true

	hostile_environment_flare(triggerArgs, hostile_environment_cast_anchor(triggerArgs.ProjectileId))
	volcanic_crown_ring(triggerArgs.LocationX, triggerArgs.LocationY)
end

function hostile_environment_armed_early(projectileId)
	local armed = game.SessionMapState and game.SessionMapState.BoonEditArmedCasts
	return projectileId ~= nil and armed ~= nil and armed[projectileId] == true
end


local function hostile_environment_flare_args()
	local trait = game.GetHeroTrait('ApolloExCastBoon')
	local death = trait and trait.OnProjectileDeathFunction
	return death and death.Args
end

function hostile_environment_flare_fired(triggerArgs, functionArgs)
	local args = hostile_environment_flare_args()
	if not args or not functionArgs or functionArgs.ProjectileName ~= args.ProjectileName then return false end
	return hostile_environment_armed_early(triggerArgs and triggerArgs.ProjectileId)
end

function hostile_environment_flare(triggerArgs, anchorId)
	local args = hostile_environment_flare_args()
	if not args or not anchorId then return end

	local session = game.SessionMapState
	if glorious_disaster_supercharged() and game.HeroHasTrait('ApolloSecondStageCastBoon') then
		session.SuperchargeCast = true
	end

	local castId = triggerArgs.ProjectileId
	local modifier = game.GetProjectileProperty({ ProjectileId = castId, Property = 'BlastRadiusModifier' })
	local derivedValues = game.GetDerivedPropertyChangeValues({
		ProjectileName = args.ProjectileName,
		WeaponName = triggerArgs.WeaponName,
		Type = 'Projectile',
		MatchProjectileName = true,
	})

	local dropLocation = game.SpawnObstacle({ Name = 'InvisibleTarget', LocationX = triggerArgs.LocationX, LocationY = triggerArgs.LocationY })
	local flareId = game.CreateProjectileFromUnit({
		Name = args.ProjectileName,
		Id = game.CurrentRun.Hero.ObjectId,
		DestinationId = dropLocation,
		FireFromTarget = true,
		BlastRadiusModifier = modifier,
		DamageMultiplier = args.DamageMultiplier,
		DataProperties = derivedValues.PropertyChanges,
		ThingProperties = derivedValues.ThingPropertyChanges,
	})
	game.Destroy({ Id = dropLocation })
	if not flareId then return end

	game.AttachProjectiles({ Ids = { flareId }, DestinationId = anchorId })

	local marked = session.MarkedEnemies
	if marked and marked[castId] then
		marked[flareId] = game.DeepCopyTable(marked[castId])
	end

	if game.HeroHasTrait('ApolloSecondStageCastBoon') and (session.SuperchargeCast
		or (game.HeroHasTrait('TransformExCastTalent') and not game.IsEmpty(game.MapState.TransformArgs)))
	then
		session.ValidSuperchargeCastIds[flareId] = true
		session.SuperchargeCast = nil
	end
end
