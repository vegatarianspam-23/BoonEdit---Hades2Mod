---@meta _
---@diagnostic disable: lowercase-global


HERMES_DUOS_GUID = 'Wistiti-HermesDuos'

BOON_EDIT_HERMES_DUO_REPLACEMENTS = {
	DistressCall = {
		Trait = DISTRESS_CALL_DUO_TRAIT,
		Partner = 'Aphrodite',
		External = 'Wistiti-HermesDuos-OnlyFansBoon',
	},
	FlawlessExecution = {
		Trait = FLAWLESS_EXECUTION_DUO_TRAIT,
		Partner = 'Apollo',
		External = 'Wistiti-HermesDuos-CastWarZoneBoon',
	},
}


function boon_edit_hermes_duos_on()
	return boon_edit_mod_on('HermesDuos', HERMES_DUOS_GUID)
end


function boon_edit_hermes_duo_on(key)
	return boon_edit_hermes_duos_on() and boon_edit_on(key)
end


function boon_edit_cross_list(traitName, lootName, wanted)
	local loot = game.LootData[lootName]
	wanted = wanted and game.TraitData[traitName] ~= nil

	if loot then
		loot.Traits = loot.Traits or {}
		boon_list_set(loot.Traits, traitName, wanted)
		if loot.TraitIndex then loot.TraitIndex[traitName] = wanted or nil end
	end

	local info = game.ScreenData and game.ScreenData.BoonInfo
	if not info then return end
	local dictionary = info.TraitDictionary and info.TraitDictionary[lootName]
	if dictionary then dictionary[traitName] = wanted or nil end
	local order = info.TraitSortOrder and info.TraitSortOrder[lootName]
	if order then boon_list_set(order, traitName, wanted) end
end


function boon_edit_strip_trait(traitName)
	mod.BoonEditStripped = mod.BoonEditStripped or {}
	local stripped = mod.BoonEditStripped[traitName] or {}
	mod.BoonEditStripped[traitName] = stripped

	for lootName, loot in pairs(game.LootData or {}) do
		if type(loot) == 'table' and type(loot.Traits) == 'table' and game.Contains(loot.Traits, traitName) then
			stripped[lootName] = true
			boon_edit_cross_list(traitName, lootName, false)
		end
	end
end


function boon_edit_unstrip_trait(traitName)
	local stripped = mod.BoonEditStripped and mod.BoonEditStripped[traitName]
	if not stripped then return end

	for lootName in pairs(stripped) do
		boon_edit_cross_list(traitName, lootName, true)
	end
	mod.BoonEditStripped[traitName] = nil
end


function boon_edit_mod_sync()
	for key, spec in pairs(BOON_EDIT_HERMES_DUO_REPLACEMENTS) do
		local wanted = boon_edit_hermes_duo_on(key)
		boon_edit_cross_list(spec.Trait, 'HermesUpgrade', wanted)
		boon_edit_cross_list(spec.Trait, spec.Partner .. 'Upgrade', wanted)
		if wanted then
			boon_edit_strip_trait(spec.External)
		else
			boon_edit_unstrip_trait(spec.External)
		end
	end

	high_tension_wrap()
end


function boon_edit_hermes_duos_list()
	for key, spec in pairs(BOON_EDIT_HERMES_DUO_REPLACEMENTS) do
		if boon_edit_hermes_duo_on(key) then
			boon_edit_cross_list(spec.Trait, 'HermesUpgrade', true)
			boon_edit_cross_list(spec.Trait, spec.Partner .. 'Upgrade', true)
		end
	end
end


local HIGH_TENSION_TRAIT = 'Wistiti-HermesDuos-ZappyFieldBoon'
local HIGH_TENSION_ROD_COOLDOWN = 'BoonEditHighTensionRod'


local function high_tension_bolt(zapper, args)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	local properties = {}
	if game.HeroHasTrait('ReboundingSparkBoon') then
		properties.AllowRepeatedOwnerJumpHit = true
		properties.AffectsSelf = true
	end
	local jumps = game.GetBaseDataValue({ Type = 'Projectile', Name = args.ProjectileName, Property = 'NumJumps' })
	properties.NumJumps = (type(jumps) == 'number' and jumps or 0)
		+ game.GetTotalHeroTraitValue('ZeusSparkBonusBounces')

	game.CreateProjectileFromUnit({
		Name = args.ProjectileName,
		Id = hero.ObjectId,
		DestinationId = zapper.ObjectId,
		FireFromTarget = true,
		DamageMultiplier = 3,
		ProjectileCap = 5,
		DataProperties = properties,
	})
end


function mod.HighTensionMelZap(zapper)
	if not boon_edit_hermes_duos_on() then return end
	if not zapper or not zapper.ObjectId or zapper.IsDead then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or not hero.ObjectId then return end

	local trait = game.HeroHasTrait(HIGH_TENSION_TRAIT) and game.GetHeroTrait(HIGH_TENSION_TRAIT)
	local args = trait and trait.SetupFunction and trait.SetupFunction.Args
	if not args or not args.ZappingDistance or not args.Cooldown then return end

	if game.GetDistance({ Id = hero.ObjectId, DestinationId = zapper.ObjectId }) > args.ZappingDistance then return end

	local ids = game.GetClosestIds({
		Id = zapper.ObjectId,
		DestinationName = 'EnemyTeam',
		Distance = args.ZappingDistance,
		IgnoreInvulnerable = true,
		IgnoreHomingIneligible = true,
		IgnoreSelf = true,
	})
	for _, id in ipairs(ids or {}) do
		local enemy = game.ActiveEnemies[id]
		if enemy and not enemy.IsDead and not enemy.SkipModifiers then return end
	end

	if not game.CheckCooldown(HIGH_TENSION_ROD_COOLDOWN, args.Cooldown) then return end
	high_tension_bolt(zapper, args)
end


function high_tension_wrap()
	local wmod = game[HERMES_DUOS_GUID]
	if type(wmod) ~= 'table' then return end

	local original = wmod.ZapNearbyEnemies
	if type(original) ~= 'function' or original == mod.SWuHighTensionZap then return end

	mod.SWuHighTensionZap = function(zapper, ...)
		original(zapper, ...)
		mod.HighTensionMelZap(zapper)
	end
	wmod.ZapNearbyEnemies = mod.SWuHighTensionZap
end
