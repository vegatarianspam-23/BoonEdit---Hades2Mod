---@meta _


local SMITHY_RUSH_WEAPONS = { 'WeaponBlink', 'WeaponSprint' }


once('SmithyRush', function()
	if not boon_edit_on('SmithyRush') then return end

	local cast = game.TraitData.HephaestusCastBoon
	local dash = game.TraitData.HephaestusSprintBoon

	local castArgs = cast.OnWeaponFiredFunctions.FunctionArgs
	local halved = {
		BaseValue = castArgs.DamageMultiplier.BaseValue / 2,
		DecimalPlaces = 3,
		AbsoluteStackValues = {},
	}
	for i, value in pairs(castArgs.DamageMultiplier.AbsoluteStackValues) do
		halved.AbsoluteStackValues[i] = value / 2
	end

	dash.RarityLevels = {}
	for rarity, level in pairs(cast.RarityLevels) do
		dash.RarityLevels[rarity] = { Multiplier = level.Multiplier }
	end

	dash.SetupFunction = nil
	dash.BlastReadyVfx = nil
	dash.BlastReadyDarkVfx = nil

	dash.OnWeaponFiredFunctions = {
		ValidWeapons = game.DeepCopyTable(SMITHY_RUSH_WEAPONS),
		ValidWeaponsLookup = game.ToLookup(SMITHY_RUSH_WEAPONS),
		ExcludeLinked = true,
		FunctionName = _PLUGIN.guid .. '.SmithyRushStart',
		FunctionArgs = {
			ProjectileName = castArgs.ProjectileName,
			DamageMultiplier = halved,
			ReportValues = { ReportedMultiplier = 'DamageMultiplier' },
		},
	}
	local vanillaBlast = dash.OnBlinkEndAction.FunctionArgs.DamageMultiplier

	dash.OnSprintEndAction = { FunctionName = _PLUGIN.guid .. '.SmithyRushEnd' }
	dash.OnBlinkEndAction = {
		FunctionName = _PLUGIN.guid .. '.SmithyRushEnd',
		FunctionArgs = {
			CheckSprint = true,
			TraitName = 'HephaestusSprintBoon',
			Name = 'SmithyRushNoCooldown',
			Cooldown = 0,
			DamageMultiplier = vanillaBlast,
		},
	}

	dash.BoonEditUnmodifiedCooldown = 10

	dash.StatLines = { 'BlastDamageStatDisplay1' }
	dash.ExtractValues = with_keyword_extracts({
		{
			Key = 'ReportedMultiplier',
			ExtractAs = 'Damage',
			Format = 'MultiplyByBase',
			BaseType = 'Projectile',
			BaseName = 'HephCastBlast',
			BaseProperty = 'Damage',
		},
		{ Key = 'BoonEditUnmodifiedCooldown', ExtractAs = 'UnmodifiedCooldown', SkipAutoExtract = true },
	}, 'DelayedKnockback')
end)


local SMITHY_RUSH_SCALE = 0.5

local SMITHY_RUSH_WINDUP = 0.35

function smithy_rush_presentation(locationX, locationY)
	local centerId = game.SpawnObstacle({ Name = 'BlankObstacle', LocationX = locationX, LocationY = locationY })
	local playSpeed = 1 / SMITHY_RUSH_WINDUP
	game.SetAnimation({ Name = 'HephMassiveHitHammerCast', DestinationId = centerId, Scale = SMITHY_RUSH_SCALE, PlaySpeed = playSpeed })
	game.waitUnmodified(SMITHY_RUSH_WINDUP)
	game.SetAnimation({ Name = 'HephMassiveHitFixed', DestinationId = centerId, Scale = SMITHY_RUSH_SCALE, PlaySpeed = playSpeed })

	local tuning = mod.tuning.SmithyRush
	rush_impact_ring(tuning.ImpactFx, tuning.ImpactRadius, tuning.ImpactPulses, tuning.ImpactPulseDelay, centerId)
	game.DestroyOnDelay({ centerId }, 1)
end

function smithy_rush_glow(radius)
	local heroId = game.CurrentRun.Hero.ObjectId
	for _, unit in pairs(game.ActiveEnemies or {}) do
		if unit and unit.ObjectId and not unit.IsDead and not is_allied_summon(unit) and not boon_ignores(unit) then
			local distance = game.GetDistance({ Id = unit.ObjectId, DestinationId = heroId })
			if distance and distance <= radius then
				glow_inflict(unit)
			end
		end
	end
end

function smithy_rush_strike()
	local trait = game.GetHeroTrait('HephaestusSprintBoon')
	local traitArgs = trait and trait.OnWeaponFiredFunctions and trait.OnWeaponFiredFunctions.FunctionArgs
	if not traitArgs then return end

	local dataProperties = nil
	local radius = nil
	local castRadius = game.GetBaseDataValue({ Type = 'Projectile', Name = 'ProjectileCast', Property = 'DamageRadius' })
	if type(castRadius) == 'number' and castRadius > 0 then
		radius = castRadius * SMITHY_RUSH_SCALE
		dataProperties = { DamageRadius = radius }
	end

	game.CreateProjectileFromUnit({
		Name = traitArgs.ProjectileName,
		Id = game.CurrentRun.Hero.ObjectId,
		DestinationId = game.CurrentRun.Hero.ObjectId,
		FireFromTarget = true,
		DamageMultiplier = traitArgs.DamageMultiplier,
		DataProperties = dataProperties,
	})

	if radius and not boon_edit_on('AnvilRing') then
		smithy_rush_glow(radius)
	end

	local location = game.GetLocation({ Id = game.CurrentRun.Hero.ObjectId })
	if location then
		game.thread(smithy_rush_presentation, location.X, location.Y)
	end
end

function fire_smithy_rush_strike(args, _triggerArgs)
	if rush_end_suppressed(args) then return end

	smithy_rush_strike()
	game.SessionMapState.BoonEditSmithyRushStarted = nil
end

---@diagnostic disable-next-line: unused-local
function mod.SmithyRushStart(weaponData, _args, _triggerArgs)
	if weaponData and weaponData.Name == 'WeaponSprint' then
		if game.CheckCooldown('BoonEditSmithyRushTrail', stutter_step_interval(mod.tuning.SmithyRush.TrailInterval)) then
			smithy_rush_strike()
		end
		return
	end

	if game.SessionMapState.BoonEditSmithyRushStarted then
		game.thread(function()
			game.wait(mod.tuning.SmithyRush.ChainDelay, game.RoomThreadName)
			smithy_rush_strike()
		end)
	end

	smithy_rush_strike()
	game.SessionMapState.BoonEditSmithyRushStarted = true
end

function mod.SmithyRushEnd(args, triggerArgs)
	if not game.SessionMapState.BoonEditSmithyRushStarted then return end
	fire_smithy_rush_strike(args, triggerArgs)
end
