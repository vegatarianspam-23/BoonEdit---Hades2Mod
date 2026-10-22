---@meta _


function boon_edit_when(when)
	if when == nil then return true end
	if type(when) == 'function' then return when() == true end

	for _, name in ipairs(when) do
		local negated = string.sub(name, 1, 1) == '!'
		local on = boon_edit_on(negated and string.sub(name, 2) or name)
		if on == negated then return false end
	end
	return true
end


function boon_list_set(list, traitName, wanted)
	if not list then return end

	local at = nil
	for i, name in ipairs(list) do
		if name == traitName then
			at = i
			break
		end
	end

	if wanted and not at then
		table.insert(list, traitName)
	elseif not wanted and at then
		table.remove(list, at)
	end
end


local function Group(name) return { SWuGroup = name } end
local function If(traitName, when) return { SWuTrait = traitName, When = when } end


BOON_EDIT_ROLES = {
	{
		Name = 'SWuFireballTraits',
		Base = { 'CastProjectileBoon', 'FireballManaSpecialBoon' },
		Add = { If('AloneDamageBoon', { 'VolcanicCrown' }) },
	},
	{
		Name = 'SWuGlowTraits',
		Base = { 'MassiveKnockupBoon' },
		Add = {
			If('HephaestusCastBoon', { 'AnvilRing' }),
			If('HephaestusSprintBoon', { 'SmithyRush' }),
		},
	},
	{
		Name = 'SWuSplashBonusTraits',
		Base = { 'PoseidonWeaponBoon', 'PoseidonSpecialBoon' },
		Add = {
			If('PoseidonSprintBoon', { 'BreakerRush' }),
			If('PoseidonSplashSprintBoon', { 'BeachBall' }),
		},
	},
	{
		Name = 'SWuHammerTraits',
		Base = { 'HephaestusCastBoon' },
		Add = { If('HephaestusSprintBoon', { 'SmithyRush' }) },
	},
	{
		Name = 'AresBloodDropTraits',
		Add = {
			If('AresExCastBoon', { 'MeatGrinder' }),
			If('RendBloodDropBoon', { 'ProfuseBleeding' }),
		},
	},
	{
		Name = 'AresSwordTraits',
		Remove = { If('RendBloodDropBoon', { 'ProfuseBleeding' }) },
	},
	{
		Name = 'PoseidonSplashTraits',
		Add = { If('PoseidonSprintBoon', { 'BreakerRush' }) },
	},
	{
		Name = 'HeraLinkTraits',
		Add = { If('SpawnCastDamageBoon', { 'RousingReception' }) },
	},
	{
		Name = 'HephaestusMassiveTraits',
		Remove = { If('HephaestusSprintBoon', { 'SmithyRush' }) },
	},
}


local DUO_REQUIREMENTS = { 'OfferRequirements' }

BOON_EDIT_REQUIREMENTS = {
	{ Trait = 'SpawnCastDamageBoon', When = { 'RousingReception' }, Set = { OneOf = { 'HeraCastBoon' } } },

	{ Trait = 'PoseidonSplashSprintBoon', When = DUO_REQUIREMENTS, Set = { OneFromEachSet = {
		{ 'ApolloSprintBoon', 'PoseidonSprintBoon' },
		{ 'PoseidonWeaponBoon', 'PoseidonSpecialBoon', If('PoseidonSprintBoon', { 'BreakerRush' }) },
		{ 'ApolloWeaponBoon', 'ApolloSpecialBoon', 'ApolloSprintBoon' },
	} } },
	{ Trait = 'ManaShieldBoon', When = DUO_REQUIREMENTS, Set = { OneFromEachSet = {
		{ 'DamageShareRetaliateBoon', 'BoonDecayBoon', 'CommonGlobalDamageBoon' },
		{ 'ArmorBoon', 'HeavyArmorBoon', 'EncounterStartDefenseBuffBoon', 'ManaToHealthBoon' },
	} } },
	{ Trait = 'ClearRootBoon', When = DUO_REQUIREMENTS, Set = { OneFromEachSet = {
		Group('HephaestusCoreTraits'),
		{ 'DemeterWeaponBoon', 'DemeterSpecialBoon', 'DemeterCastBoon' },
	} } },
	{ Trait = 'FireballRendBoon', When = DUO_REQUIREMENTS, Set = { OneFromEachSet = {
		{ 'AresWeaponBoon', 'AresSpecialBoon' },
		Group('SWuFireballTraits'),
	} } },
	{ Trait = 'SelfCastBoon', When = DUO_REQUIREMENTS, Set = { OneFromEachSet = {
		{ 'AresExCastBoon', 'AresCastBoon' },
		{ 'CastNovaBoon', 'DemeterCastBoon' },
	} } },
	{ Trait = 'AllCloseBoon', When = DUO_REQUIREMENTS, Set = { OneFromEachSet = {
		Group('PoseidonCoreTraits'),
		{ 'AphroditeWeaponBoon', 'AphroditeSpecialBoon', 'AphroditeManaBoon' },
	} } },
	{ Trait = 'LightningVulnerabilityBoon', When = DUO_REQUIREMENTS, Set = { OneFromEachSet = {
		Group('PoseidonKnockbackAmplifyTraits'),
		{ 'ZeusWeaponBoon', 'ZeusSpecialBoon' },
	} } },
	{ Trait = 'RaiseDeadBoon', When = DUO_REQUIREMENTS, Set = { OneFromEachSet = {
		Group('HeraCoreTraits'),
		Group('ApolloCoreTraits'),
	} } },
	{ Trait = 'CoverRegenerationBoon', When = DUO_REQUIREMENTS, Set = { OneFromEachSet = {
		{ 'ApolloCastBoon', 'ApolloSprintBoon', 'ApolloRetaliateBoon', 'BlindChanceBoon' },
		{ 'BurnArmorBoon', 'BurnExplodeBoon', If('AloneDamageBoon', { 'VolcanicCrown' }) },
	} } },
	{ Trait = 'AllElementalBoon', When = DUO_REQUIREMENTS, Set = { OneFromEachSet = {
		{ 'HeraWeaponBoon', 'HeraSpecialBoon', 'HeraCastBoon', 'HeraSprintBoon' },
		{ 'BoonDecayBoon', 'CommonGlobalDamageBoon', 'DamageShareRetaliateBoon' },
		{ 'DamageSharePotencyBoon', 'LinkedDeathDamageBoon', 'SpawnCastDamageBoon' },
	} } },
	{ Trait = 'CharmCrowdBoon', When = DUO_REQUIREMENTS, Set = { OneFromEachSet = {
		Group('HeraCoreTraits'),
		{ 'AphroditeManaBoon', 'AphroditeSprintBoon', 'AphroditeCastBoon' },
	} } },
	{ Trait = 'RandomStatusBoon', When = DUO_REQUIREMENTS, Set = { OneFromEachSet = {
		{ 'AphroditeWeaponBoon', 'AphroditeSpecialBoon' },
		{ 'AphroditeManaBoon', 'AphroditeSprintBoon', 'AphroditeCastBoon' },
		{ 'WeakVulnerabilityBoon', 'WeakPotencyBoon' },
	} } },
	{ Trait = 'DoubleBloodDropBoon', When = DUO_REQUIREMENTS, Set = { OneFromEachSet = {
		{ 'AresWeaponBoon', 'AresSpecialBoon' },
		Group('AresBloodDropTraits'),
		{ 'LowHealthLifestealBoon', 'AresStatusDoubleDamageBoon', 'MissingHealthCritBoon' },
	} } },

	{ Trait = 'BloodManaBurstBoon', When = { 'CarnalPleasure' }, Set = { OneFromEachSet = {
		Group('AresBloodDropTraits'),
		{ 'ManaBurstBoon' },
	} } },
	{ Trait = 'SlamManaBurstBoon', When = { 'SmolderingForge' }, Set = { OneFromEachSet = {
		Group('AphroditeCoreTraits'),
		Group('SWuGlowTraits'),
	} } },
	{ Trait = 'ClearRootBoon', When = { 'CryoPounder' }, Set = { OneFromEachSet = {
		Group('SWuGlowTraits'),
		Group('DemeterRootTraits'),
	} } },
	{ Trait = 'BlindChanceBoon', When = { 'DazzlingDisplay' }, Set = {
		PriorityChance = 0.25,
		OneOf = { 'ApolloWeaponBoon', 'ApolloSpecialBoon' },
	} },
	{ Trait = 'ApolloSecondStageCastBoon', When = { 'GloriousDisaster' }, Set = { OneFromEachSet = {
		{ 'ApolloExCastBoon' },
		{ 'ZeusWeaponBoon', 'ZeusSpecialBoon', 'ZeusCastBoon', 'ZeusSprintBoon', 'ZeusManaBoon' },
	} } },
	{ Trait = 'SteamBoon', When = { 'ScaldingVapor' }, Set = { OneFromEachSet = {
		Group('PoseidonKnockbackAmplifyTraits'),
		Group('SWuFireballTraits'),
	} } },
	{ Trait = 'MassiveCastBoon', When = { 'SeismicHammer' }, Set = { OneFromEachSet = {
		{ 'HephaestusWeaponBoon', 'HephaestusSpecialBoon' },
		{ 'PoseidonExCastBoon' },
	} } },
	{ Trait = 'SlowProjectileBoon', When = { 'PostHaste' }, Set = { OneOf = {
		'TimedCritVulnerabilityBoon', 'RetaliateInvulnerabilityBoon', 'AthenaProjectileBoon', 'PowerDrinkBoon',
		'FogDamageBonusBoon', 'HephaestusWeaponBoon', 'HephaestusSpecialBoon', 'PoseidonManaBoon',
		'ZeusManaBoon', 'AutoRevengeBoon', 'HadesInvisibilityRetaliateBoon',
	} } },
	{ Trait = 'BurnSprintBoon', When = { 'BurningMeteor' }, Set = { OneFromEachSet = {
		{ 'HestiaWeaponBoon', 'HestiaSpecialBoon', 'HestiaCastBoon' },
		Group('SWuFireballTraits'),
		{ 'BurnExplodeBoon', 'BurnArmorBoon', If('AloneDamageBoon', { '!VolcanicCrown' }) },
	} } },

	{ Trait = 'AmplifyConeBoon', When = { 'BreakerRush' }, Set = { OneFromEachSet = {
		{ 'PoseidonWeaponBoon', 'PoseidonSpecialBoon', 'PoseidonSprintBoon' },
		{ 'PoseidonStatusBoon', 'PoseidonCastBoon' },
		{ 'PoseidonExCastBoon', 'FocusDamageShaveBoon', 'OmegaPoseidonProjectileBoon' },
	} } },

	{ Trait = 'RendBloodDropBoon', When = { 'ProfuseBleeding' }, Set = { OneOf = Group('AresRendTraits') } },
	{ Trait = 'RendBloodDropBoon', When = { '!ProfuseBleeding' }, Set = function()
		return { OneOf = game.CombineTables(game.LinkedTraitData.AresRendTraits, game.LinkedTraitData.AresBloodDropTraits) }
	end },

	{ Trait = 'LuckyBoon', Patch = function(requirement) boon_edit_success_rate(requirement.OneOf) end },

	{ Trait = 'TimeStopLastStandBoon', When = { 'SecondWind' }, Patch = function(requirement)
		requirement.PriorityChance = mod.tuning.SecondWind.KeepsakeOfferChance
	end },
}

for _, traitName in ipairs({ 'MassiveDamageBoon', 'MassiveKnockupBoon', 'DoubleMassiveAttackBoon', 'BlindClearBoon', 'ClearRootBoon' }) do
	table.insert(BOON_EDIT_REQUIREMENTS, {
		Trait = traitName,
		When = traitName == 'ClearRootBoon' and { 'SmithyRush', '!CryoPounder' } or { 'SmithyRush' },
		Patch = function(requirement) boon_edit_without(requirement, 'HephaestusSprintBoon') end,
	})
end


local function rolls(name, chance)
	return function()
		local value = chance()
		return boon_edit_on(name) and type(value) == 'number' and value > 0 and value < 1
	end
end

local function uncertain(name, chance)
	return function() return not boon_edit_on(name) or chance() < 1 end
end

BOON_EDIT_SUCCESS_RATE = {
	{ 'DoubleMassiveAttackBoon', rolls('ChainReaction', function() return mod.tuning.ChainReaction.SkipChance end) },
	{ 'AresExCastBoon', rolls('MeatGrinder', function() return mod.tuning.MeatGrinder.PlasmaChance end) },
	{ 'RendBloodDropBoon', rolls('ProfuseBleeding', function() return mod.tuning.ProfuseBleeding.SpillChance end) },
	{ 'LowHealthLifestealBoon', rolls('BloodSpree', function() return mod.tuning.BloodSpree.KillHealChance end) },
	{ 'LightningVulnerabilityBoon', rolls('KillerCurrent', function() return mod.tuning.KillerCurrent.BoltChance end) },
	{ 'RandomStatusBoon', rolls('EcstaticObsession', function() return mod.tuning.EcstaticObsession.CharmChance end) },
	{ 'SlamManaBurstBoon', rolls('SmolderingForge', function() return mod.tuning.SmolderingForge.HeartthrobChance end) },
	{ 'RaiseDeadBoon', rolls('SunWorshiper', function() return mod.tuning.SunWorshiper.RepeatChance end) },
	{ 'DoubleSplashBoon', function() return not boon_edit_on('ArterialSpray') end },
	{ 'BlindChanceBoon', uncertain('DazzlingDisplay', function() return mod.tuning.DazzlingDisplay.Chance end) },
	{ 'BloodManaBurstBoon', function()
		local chance = mod.tuning.CarnalPleasure.PickupHeartthrobChance
		return not boon_edit_on('CarnalPleasure') or (type(chance) == 'number' and chance > 0 and chance < 1)
	end },
}

function boon_edit_success_rate(list)
	for _, entry in ipairs(BOON_EDIT_SUCCESS_RATE) do
		boon_list_set(list, entry[1], entry[2]())
	end
end


BOON_EDIT_BROAD_RULES = {
	{ When = { 'VolcanicCrown' }, Any = { 'CastProjectileBoon', 'FireballManaSpecialBoon' }, Add = 'AloneDamageBoon' },
}


BOON_EDIT_INFECTION = {
	DelayedKnockbackEffect = Group('SWuGlowTraits'),
	DamageShareEffect = { If('SpawnCastDamageBoon', { 'RousingReception' }) },
}


local function group_names()
	local names = {}
	for name, group in pairs(game.LinkedTraitData) do
		if type(group) == 'table' then names[group] = name end
	end
	return names
end


function boon_edit_resolve(value)
	if type(value) ~= 'table' then return value end

	if value.SWuGroup then
		game.LinkedTraitData[value.SWuGroup] = game.LinkedTraitData[value.SWuGroup] or {}
		return game.LinkedTraitData[value.SWuGroup]
	end

	local out = {}
	for _, item in ipairs(value) do
		if type(item) == 'table' and item.SWuTrait then
			if boon_edit_when(item.When) then table.insert(out, item.SWuTrait) end
		else
			table.insert(out, boon_edit_resolve(item))
		end
	end
	for key, item in pairs(value) do
		if type(key) ~= 'number' then out[key] = boon_edit_resolve(item) end
	end
	return out
end


local function capture(value, names)
	if type(value) ~= 'table' then return value end
	if names[value] then return Group(names[value]) end

	local out = {}
	for key, item in pairs(value) do out[key] = capture(item, names) end
	return out
end


local function explicit_lists(requirement, names)
	local lists = {}
	if type(requirement.OneOf) == 'table' and not names[requirement.OneOf] then
		table.insert(lists, requirement.OneOf)
	end
	for _, set in ipairs(requirement.OneFromEachSet or {}) do
		if type(set) == 'table' and not names[set] then table.insert(lists, set) end
	end
	return lists
end


function boon_edit_without(requirement, traitName)
	for _, list in ipairs(explicit_lists(requirement, group_names())) do
		boon_list_set(list, traitName, false)
	end
end


local function same_members(a, b)
	if #a ~= #b then return false end

	local members = game.ToLookup(a)
	for _, name in ipairs(b) do
		if not members[name] then return false end
	end
	return true
end


local function relink(names)
	local function live(set)
		if type(set) ~= 'table' or names[set] then return set end
		for _, role in ipairs(BOON_EDIT_ROLES) do
			local base = mod.BoonEditGroupBase[role.Name]
			local group = game.LinkedTraitData[role.Name]
			if not role.Base and base and group and (same_members(set, base) or same_members(set, group)) then
				return group
			end
		end
		return set
	end

	for traitName, requirement in pairs(game.TraitRequirements) do
		if type(requirement) == 'table' and not string.find(traitName, '-', 1, true) then
			requirement.OneOf = live(requirement.OneOf)
			for i, set in ipairs(requirement.OneFromEachSet or {}) do
				requirement.OneFromEachSet[i] = live(set)
			end
		end
	end
end


local function rebuild_roles()
	mod.BoonEditGroupBase = mod.BoonEditGroupBase or {}

	for _, role in ipairs(BOON_EDIT_ROLES) do
		local base = mod.BoonEditGroupBase[role.Name]
		if not base then
			base = game.ShallowCopyTable(role.Base or game.LinkedTraitData[role.Name] or {})
			mod.BoonEditGroupBase[role.Name] = base
		end

		game.LinkedTraitData[role.Name] = game.LinkedTraitData[role.Name] or {}
		local group = game.LinkedTraitData[role.Name]
		for i = #group, 1, -1 do group[i] = nil end
		for _, name in ipairs(base) do table.insert(group, name) end

		for _, member in ipairs(role.Remove or {}) do
			if boon_edit_when(member.When) then boon_list_set(group, member.SWuTrait, false) end
		end
		for _, member in ipairs(role.Add or {}) do
			if boon_edit_when(member.When) then boon_list_set(group, member.SWuTrait, true) end
		end
	end
end


local function remember(traitName, names)
	mod.BoonEditRequirementBase = mod.BoonEditRequirementBase or {}
	local base = mod.BoonEditRequirementBase
	if base[traitName] == nil then
		local current = game.TraitRequirements[traitName]
		base[traitName] = current and capture(current, names) or false
	end
	mod.BoonEditTouched[traitName] = true
end


local function restore()
	mod.BoonEditTouched = mod.BoonEditTouched or {}
	for traitName in pairs(mod.BoonEditTouched) do
		local base = mod.BoonEditRequirementBase[traitName]
		game.TraitRequirements[traitName] = base and boon_edit_resolve(base) or nil
	end
	mod.BoonEditTouched = {}
end


local function rebuild_infection()
	local infection = game.TraitData.PolymorphCurseTalent
	local args = infection and infection.SetupFunction and infection.SetupFunction.Args
	local curses = args and args.StatusTraitNames
	if not curses then return end

	mod.BoonEditInfectionBase = mod.BoonEditInfectionBase or {}
	for effectName, extra in pairs(BOON_EDIT_INFECTION) do
		local list = curses[effectName]
		if list then
			local base = mod.BoonEditInfectionBase[effectName]
			if not base then
				base = game.ShallowCopyTable(list)
				mod.BoonEditInfectionBase[effectName] = base
			end

			for i = #list, 1, -1 do list[i] = nil end
			for _, name in ipairs(base) do table.insert(list, name) end
			if config.enabled ~= false then
				for _, name in ipairs(boon_edit_resolve(extra)) do boon_list_set(list, name, true) end
			end
		end
	end
end


local function apply_rules(names)
	for _, rule in ipairs(BOON_EDIT_REQUIREMENTS) do
		if boon_edit_when(rule.When) then
			remember(rule.Trait, names)
			if rule.Set then
				local set = type(rule.Set) == 'function' and rule.Set() or rule.Set
				game.TraitRequirements[rule.Trait] = boon_edit_resolve(set)
			end
			local requirement = game.TraitRequirements[rule.Trait]
			if rule.Patch and requirement then rule.Patch(requirement) end
		end
	end
end


local function apply_broad_rules(names)
	for _, rule in ipairs(BOON_EDIT_BROAD_RULES) do
		if boon_edit_when(rule.When) then
			for traitName, requirement in pairs(game.TraitRequirements) do
				if type(requirement) == 'table' and not string.find(traitName, '-', 1, true) then
					for _, list in ipairs(explicit_lists(requirement, names)) do
						local members = game.ToLookup(list)
						local match = rule.All ~= nil
						for _, name in ipairs(rule.Any or {}) do match = match or members[name] == true end
						for _, name in ipairs(rule.All or {}) do match = match and members[name] == true end

						if match and not members[rule.Add] then
							remember(traitName, names)
							table.insert(list, rule.Add)
						end
					end
				end
			end
		end
	end
end


function boon_edit_sync_groups()
	restore()
	rebuild_roles()

	local names = group_names()
	if boon_edit_on('WrathOfOlympus') then relink(names) end
	rebuild_infection()

	if config.enabled == false then return end
	apply_rules(names)
	apply_broad_rules(names)
end
