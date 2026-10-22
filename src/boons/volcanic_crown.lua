---@meta _


local CROWN = 'AloneDamageBoon'

local FIREBALL = mod.tuning.VolcanicCrown.FireballProjectile
local FIRE = mod.tuning.VolcanicCrown.FireProjectile


local PROJECTILE_FIELDS = {
	'AddOutgoingDamageModifiers', 'AddOutgoingDamageModifiersArray', 'AddOutgoingCritModifiers',
	'OnEnemyDamagedAction',
}


local function volcanic_crown_join(data)
	if type(data) ~= 'table' then return end

	local list = data.ValidProjectiles
	if type(list) ~= 'table' then
		for _, entry in ipairs(data) do
			volcanic_crown_join(entry)
		end
		return
	end

	if not game.Contains(list, 'ProjectileFireball') then return end

	if not game.Contains(list, FIREBALL) then
		table.insert(list, FIREBALL)
	end
	if game.Contains(list, 'HestiaSprintPuddle') and not game.Contains(list, FIRE) then
		table.insert(list, FIRE)
	end

	if data.ValidProjectilesLookup then
		data.ValidProjectilesLookup = game.ToLookup(list)
	end
end


once('SnuffedCandleBecomesVolcanicCrown', function()
	game.ProjectileData[FIREBALL] = game.DeepCopyTable(game.ProjectileData.ProjectileFireball)
	game.ProjectileData[FIREBALL].Name = FIREBALL
	game.ProjectileData[FIRE] = game.DeepCopyTable(game.ProjectileData.HestiaSprintPuddle)
	game.ProjectileData[FIRE].Name = FIRE

	volcanic_crown_join({ ValidProjectiles = game.WeaponSets.OlympianProjectileNames })
	for _, trait in pairs(game.TraitData) do
		for _, field in ipairs(PROJECTILE_FIELDS) do
			volcanic_crown_join(type(trait) == 'table' and trait[field])
		end
	end

	if not boon_edit_on('VolcanicCrown') then return end

	local tuning = mod.tuning.VolcanicCrown
	local crown = game.TraitData[CROWN]

	crown.AddOutgoingDamageModifiers = nil

	crown.RarityLevels = {}
	for rarity, damage in pairs(tuning.FireballDamage) do
		crown.RarityLevels[rarity] = { Multiplier = damage / tuning.FireballDamage.Common }
	end

	crown.BoonEditFireballDamage = {
		BaseValue = tuning.FireballDamage.Common,
		AbsoluteStackValues = tuning.PomDamage,
		AsInt = true,
	}
	crown.BoonEditFireballs = tuning.Fireballs
	crown.BoonEditBounces = tuning.Bounces

	crown.OnProjectileDeathFunction = {
		Name = _PLUGIN.guid .. '.VolcanicCrownDeath',
		ValidProjectiles = { 'ProjectileCast', FIREBALL },
		ValidProjectilesLookup = game.ToLookup({ 'ProjectileCast', FIREBALL }),
	}

	crown.StatLines = { 'FireballDamageStatDisplay1' }
	crown.ExtractValues = {
		{ Key = 'BoonEditFireballDamage', ExtractAs = 'Damage' },
		{ Key = 'BoonEditFireballs', ExtractAs = 'TooltipFireballs', SkipAutoExtract = true },
		{ Key = 'BoonEditBounces', ExtractAs = 'TooltipBounces', SkipAutoExtract = true },
	}

	game.ScreenData.RunClear.DamageSourceMap[FIREBALL] = CROWN
	game.ScreenData.RunClear.DamageSourceMap[FIRE] = CROWN
end)


function mod.VolcanicCrownDeath(triggerArgs, args)
	if triggerArgs and triggerArgs.name == FIREBALL then
		return mod.VolcanicCrownBounce(triggerArgs, args)
	end
	return mod.VolcanicCrown(triggerArgs, args)
end


---@diagnostic disable-next-line: unused-local
function mod.VolcanicCrown(triggerArgs, _args)
	if not boon_edit_on('VolcanicCrown') then return end
	if not triggerArgs or not triggerArgs.Armed or not triggerArgs.Detonated then return end
	if not triggerArgs.LocationX or not triggerArgs.LocationY then return end

	local encounter = game.CurrentRun and game.CurrentRun.CurrentRoom and game.CurrentRun.CurrentRoom.Encounter
	if encounter and encounter.BossKillPresentation then return end

	local repeats = game.SessionMapState.InvalidRepeatCastIds
	if repeats and triggerArgs.ProjectileId and repeats[triggerArgs.ProjectileId] then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	local count = mod.tuning.VolcanicCrown.Fireballs
	local facing = game.GetAngle({ Id = hero.ObjectId }) or 0

	for i = 1, count do
		volcanic_crown_throw(triggerArgs.LocationX, triggerArgs.LocationY, facing + (i - 1) * 360 / count, 0)
	end
end


---@diagnostic disable-next-line: unused-local
function mod.VolcanicCrownBounce(triggerArgs, _args)
	if not boon_edit_on('VolcanicCrown') then return end
	if not triggerArgs or not triggerArgs.LocationX or not triggerArgs.LocationY then return end

	local flights = game.SessionMapState.BoonEditVolcanicCrown
	local flight = flights and flights[triggerArgs.ProjectileId]
	if not flight then return end
	flights[triggerArgs.ProjectileId] = nil

	volcanic_crown_fire(triggerArgs.LocationX, triggerArgs.LocationY)

	if flight.Bounces >= mod.tuning.VolcanicCrown.Bounces then return end

	volcanic_crown_throw(triggerArgs.LocationX, triggerArgs.LocationY, flight.Angle, flight.Bounces + 1)
end


function volcanic_crown_throw(x, y, angle, bounces)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or not hero_live() then return end

	local origin = game.GetLocation({ Id = hero.ObjectId })
	if not origin then return end

	local id = game.CreateProjectileFromUnit({
		Name = FIREBALL,
		Id = hero.ObjectId,
		Angle = angle,
		OffsetX = x - origin.X,
		OffsetY = y - origin.Y,
		DamageMultiplier = volcanic_crown_power(),
		BlastRadiusModifier = cast_area_multiplier(),
	})
	if not id then return end

	local session = game.SessionMapState
	session.BoonEditVolcanicCrown = session.BoonEditVolcanicCrown or {}
	session.BoonEditVolcanicCrown[id] = { Angle = angle, Bounces = bounces }
end


function volcanic_crown_fire(x, y)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	local spotId = game.SpawnObstacle({ Name = 'InvisibleTarget', LocationX = x, LocationY = y })
	game.CreateProjectileFromUnit({
		Name = FIRE,
		Id = hero.ObjectId,
		DestinationId = spotId,
		FireFromTarget = true,
		BlastRadiusModifier = cast_area_multiplier(),
	})
	game.thread(game.DestroyOnDelay, { spotId }, 1)
end


function volcanic_crown_power()
	local trait = game.GetHeroTrait(CROWN)
	local damage = trait and trait.BoonEditFireballDamage
	local base = game.GetBaseDataValue({ Type = 'Projectile', Name = FIREBALL, Property = 'Damage' })
	if type(damage) ~= 'number' or type(base) ~= 'number' or base <= 0 then return 1 end

	return damage / base
end
