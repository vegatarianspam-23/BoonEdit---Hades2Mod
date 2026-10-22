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
		base(weaponData, traitArgs, triggerArgs)
		cast_storm_follows_caster(triggerArgs)
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


function cast_storm_follows_caster(triggerArgs)
	if not hostile_environment_keeps_cast() then return end

	local storms = game.MapState.CastStorms
	local ids = storms and storms[#storms]
	if not ids or game.IsEmpty(ids) then return end

	local anchorId = game.CurrentRun.Hero.ObjectId
	if triggerArgs and triggerArgs.UnitIdOverride then
		anchorId = game.MapState.FamiliarLocationId
	end
	if not anchorId then return end

	game.AttachProjectiles({ Ids = ids, DestinationId = anchorId })
end
