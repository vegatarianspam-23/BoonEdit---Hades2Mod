---@meta _


mod.SetupDone = mod.SetupDone or {}
boon_recording = nil
boon_text_recording = nil

function once(key, setup)
	if mod.SetupDone[key] then return end
	mod.SetupDone[key] = true
	boon_record(setup)
end


BOON_EDIT_GROUPS = {
	{ 'Boons', 'Aphrodite' },
	{ 'Boons', 'Apollo' },
	{ 'Boons', 'Ares' },
	{ 'Boons', 'Athena' },
	{ 'Boons', 'Demeter' },
	{ 'Boons', 'Dionysus' },
	{ 'Boons', 'Hades' },
	{ 'Boons', 'Hephaestus' },
	{ 'Boons', 'Hera' },
	{ 'Boons', 'Hermes' },
	{ 'Boons', 'Hestia' },
	{ 'Boons', 'Medea' },
	{ 'Boons', 'Poseidon' },
	{ 'Boons', 'Selene' },
	{ 'Boons', 'Zeus' },
	{ 'Boons', 'Duos' },
	{ 'Boons', 'Legendaries' },
	{ 'Keepsakes' },
	{ 'Systems' },
	{ 'Experimental', 'Hammers' },
	{ 'Experimental', 'Keepsakes' },
	{ 'Experimental', 'Aspects' },
	{ 'Experimental', 'Mods' },
}

local boonEditGroupOf = {}

local function boon_edit_group(path)
	local node = config
	for _, key in ipairs(path) do
		node = node and node[key]
	end
	return node
end

local function boon_edit_path(name)
	local path = boonEditGroupOf[name]
	if not path then
		for _, candidate in ipairs(BOON_EDIT_GROUPS) do
			local group = boon_edit_group(candidate)
			if group and group[name] ~= nil then
				path = candidate
				boonEditGroupOf[name] = path
				break
			end
		end
	end
	return path
end

mod.Trials = mod.Trials or {}

BOON_EDIT_UNFORCEABLE = {}

BOON_EDIT_TRIAL_BLOCKED_PREFIXES = { 'SWu-MoreDuosMod-' }

function boon_edit_trial_running(bounty)
	if bounty == nil then
		local run = game.CurrentRun
		if not run or not run.Hero or run.Hero.IsDead then return false end
		bounty = run.ActiveBounty
	end
	return bounty and mod.Trials[bounty] == true or false
end

function boon_edit_trial_blocks(traitName)
	if type(traitName) ~= 'string' or not boon_edit_trial_running() then return false end
	for _, prefix in ipairs(BOON_EDIT_TRIAL_BLOCKED_PREFIXES) do
		if string.sub(traitName, 1, #prefix) == prefix then return true end
	end
	return false
end

function boon_edit_forced(name, bounty)
	if config.enabled == false or BOON_EDIT_UNFORCEABLE[name] then return false end
	if not boon_edit_trial_running(bounty) then return false end

	local path = boon_edit_path(name)
	if not path or path[1] == 'Experimental' then return false end

	local overrider = BOON_EDIT_OVERRIDDEN_BY[name]
	if overrider and boon_edit_on(overrider, bounty) then return false end
	return true
end

mod.TrialShops = mod.TrialShops or {}
mod.TrialRewardFallbacks = mod.TrialRewardFallbacks or {}

function boon_edit_trial_reward_fallback()
	local run = game.CurrentRun
	return boon_edit_trial_running() and run and mod.TrialRewardFallbacks[run.ActiveBounty] or nil
end

local function boon_edit_set(names)
	local set = {}
	for _, name in ipairs(names or {}) do set[name] = true end
	return set
end

local function boon_edit_keeper(names, blocking)
	local set = boon_edit_set(names)
	return function(name)
		if blocking then return not set[name] end
		return set[name] == true
	end
end

function boon_edit_trial(spec)
	local shopItems, shopBlocked, rewardFallback = spec.ShopItems, spec.ShopBlocked, spec.RewardFallback
	spec.ShopItems, spec.ShopBlocked, spec.RewardFallback = nil, nil, nil

	bountyAPI.RegisterBounty(spec)
	local name = spec.BaseData and spec.BaseData.Name
	if not name then return end

	mod.Trials[name] = true
	mod.TrialRewardFallbacks[name] = rewardFallback
	if shopItems then
		mod.TrialShops[name] = { Keep = boon_edit_keeper(shopItems), Strict = true }
	elseif shopBlocked then
		mod.TrialShops[name] = { Keep = boon_edit_keeper(shopBlocked, true) }
	else
		mod.TrialShops[name] = nil
	end
end

local function boon_edit_filter_rewards(keep, fallback)
	local pools = {}
	for storeName, pool in pairs(game.RewardStoreData) do
		if type(pool) == 'table' and type(pool[1]) == 'table' and pool[1].Name then
			local kept = {}
			for _, reward in ipairs(pool) do
				if keep(reward.Name) then table.insert(kept, game.DeepCopyTable(reward)) end
			end
			if #kept == 0 then kept = { { Name = fallback } } end
			pools[storeName] = kept
		end
	end
	return pools
end

function boon_edit_trial_rewards(names, fallback)
	return boon_edit_filter_rewards(boon_edit_keeper(names), fallback)
end

function boon_edit_trial_rewards_without(names, fallback)
	return boon_edit_filter_rewards(boon_edit_keeper(names, true), fallback)
end

local function boon_edit_kept_names(list, keep)
	if type(list) ~= 'table' then return list end
	local kept = {}
	for _, entry in ipairs(list) do
		local entryName = type(entry) == 'table' and entry.Name or entry
		if keep(entryName) then table.insert(kept, entry) end
	end
	return kept
end

function boon_edit_trial_shop(storeData)
	local run = game.CurrentRun
	local shop = boon_edit_trial_running() and run and mod.TrialShops[run.ActiveBounty]
	if not shop or type(storeData) ~= 'table' then return storeData end
	local keep = shop.Keep

	local filtered = game.ShallowCopyTable(storeData)
	filtered.Traits = boon_edit_kept_names(storeData.Traits, keep)
	filtered.Consumables = boon_edit_kept_names(storeData.Consumables, keep)
	filtered.GuaranteedItems = boon_edit_kept_names(storeData.GuaranteedItems, keep)
	if shop.Strict then filtered.CosmeticOffers = nil end

	if storeData.HealingOffers then
		filtered.HealingOffers = game.ShallowCopyTable(storeData.HealingOffers)
		filtered.HealingOffers.Options = boon_edit_kept_names(storeData.HealingOffers.Options, keep)
	end

	if storeData.GroupsOf then
		filtered.GroupsOf = {}
		for _, group in ipairs(storeData.GroupsOf) do
			if group.OptionsData then
				local copy = game.ShallowCopyTable(group)
				copy.OptionsData = boon_edit_kept_names(group.OptionsData, keep)
				if #copy.OptionsData > 0 then table.insert(filtered.GroupsOf, copy) end
			else
				table.insert(filtered.GroupsOf, group)
			end
		end
	end

	return filtered
end

function boon_edit_trial_stats(name, stats)
	local changes = {}
	if stats.MaxHealth then
		table.insert(changes, { LuaProperty = 'MaxHealth', BaseValue = stats.MaxHealth - game.HeroData.MaxHealth, ChangeType = 'Add' })
	end
	if stats.MaxMana then
		table.insert(changes, { LuaProperty = 'MaxMana', BaseValue = stats.MaxMana - game.HeroData.MaxMana, ChangeType = 'Add' })
	end

	local trait = { Name = name, InheritFrom = { 'BaseTrait' }, Hidden = true, PropertyChanges = changes }
	if stats.Money then trait.BonusMoney = { BaseValue = stats.Money } end

	game.TraitData[name] = trait
	game.ProcessDataInheritance(trait, game.TraitData)
	return name
end

function boon_edit_on(name, bounty)
	local recording = boon_recording
	if recording then
		if not recording.AskedSet[name] then
			recording.AskedSet[name] = true
			table.insert(recording.Asked, name)
		end
		return true
	end
	if boon_text_recording then
		boon_text_owner = name
		return true
	end
	return boon_edit_configured(name) or boon_edit_forced(name, bounty)
end

BOON_EDIT_OVERRIDDEN_BY = {
	AllTogether = 'NuptialVow',
}

function boon_edit_configured(name)
	if config.enabled == false then return false end

	local overrider = BOON_EDIT_OVERRIDDEN_BY[name]
	if overrider and boon_edit_configured(overrider) then return false end

	local path = boon_edit_path(name)
	local group = path and boon_edit_group(path)
	return group ~= nil and group[name] == true
end

import 'tuning.lua'


SCREEN_WAIT_TRIES = 40
SCREEN_WAIT_STEP = 0.1

function prefix_SetupMap()
	reload_config()
	cherished_heirloom_place_keepsakes()
	white_antler_restore()
	aromatic_phial_apply()
	ionic_gain_start()
	boon_edit_sync_groups()
	boon_patches_reconcile()
	burning_desire_sync()
end

function reload_config()
	local ok, reloaded = pcall(function()
		local loaded = chalk.auto('config.lua')
		return loaded
	end)
	if ok and reloaded then
		config = reloaded
		public.config = config
	else
		print('[' .. _PLUGIN.guid .. '] config reload failed: ' .. tostring(reloaded))
	end
end


function rolls(chance)
	return game.RandomChance(chance * game.GetTotalHeroTraitValue('LuckMultiplier', { IsMultiplier = true }))
end

function in_run()
	return game.CurrentRun ~= nil and game.CurrentRun.Hero ~= nil
end

function training_grounds()
	local hub = game.CurrentHubRoom
	return hub ~= nil and hub.AllowEnemyAIActive == true
end

function hero_live()
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return false end
	return not hero.IsDead or training_grounds()
end

function is_allied_summon(unit)
	if not unit then return false end
	if unit.AlwaysTraitor or unit.Charmed then return true end
	if unit.ObjectId and game.IsCharmed({ Id = unit.ObjectId }) then return true end
	return game.Contains(game.MapState.SpellSummons or {}, unit)
end

function boon_ignores(unit)
	return unit.SkipModifiers and not unit.TrainingTarget
end

function apply_hitch(unit)
	if not unit or not unit.ObjectId then return end
	if is_allied_summon(unit) then return end

	game.ApplyDamageShare(unit, { EffectName = 'DamageShareEffect' }, {})
end


KEYWORD_EXTRACTS = {
	Rend = {
		{ ExtractAs = 'AresCurseDuration', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'AresStatus', BaseProperty = 'Duration' },
		{ ExtractAs = 'AresCursePowerBonus', SkipAutoExtract = true, External = true,
			BaseType = 'EffectLuaData', BaseName = 'AresStatus', BaseProperty = 'BonusBaseDamageOnInflict' },
	},
	Weak = {
		{ ExtractAs = 'TooltipWeakModifier', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'WeakEffect', BaseProperty = 'Modifier',
			Format = 'NegativePercentDelta' },
		{ ExtractAs = 'TooltipWeakDuration', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'WeakEffect', BaseProperty = 'Duration' },
	},
	Burn = {
		{ ExtractAs = 'BurnRate', SkipAutoExtract = true, External = true,
			BaseType = 'EffectLuaData', BaseName = 'BurnEffect', BaseProperty = 'DamagePerSecond',
			DecimalPlaces = 1 },
	},
	KnockbackAmplify = {
		{ ExtractAs = 'KnockbackAmplifyDuration', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'AmplifyKnockbackEffect', BaseProperty = 'Duration',
			DecimalPlaces = 1 },
		{ ExtractAs = 'FontChance', SkipAutoExtract = true, External = true,
			BaseType = 'EffectLuaData', BaseName = 'AmplifyKnockbackEffect', BaseProperty = 'Chance',
			Format = 'LuckModifiedPercent' },
		{ ExtractAs = 'FontDamage', SkipAutoExtract = true, External = true,
			BaseType = 'ProjectileBase', BaseName = 'PoseidonEffectFont', BaseProperty = 'Damage' },
	},
	HeartBurst = {
		{ ExtractAs = 'Duration', SkipAutoExtract = true, External = true,
			BaseType = 'ProjectileBase', BaseName = 'AphroditeBurst', BaseProperty = 'Fuse' },
	},
	DelayedKnockback = {
		{ ExtractAs = 'DelayedKnockbackModifier', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'DelayedKnockbackEffect', BaseProperty = 'Modifier',
			Format = 'PercentDelta' },
		{ ExtractAs = 'DelayedKnockbackDuration', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'DelayedKnockbackEffect', BaseProperty = 'Duration',
			DecimalPlaces = 1 },
	},
	Link = {
		{ ExtractAs = 'DamageShareDuration', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'DamageShareEffect', BaseProperty = 'Duration' },
		{ ExtractAs = 'DamageShareAmount', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'DamageShareEffect', BaseProperty = 'Amount',
			Format = 'Percent' },
	},
	Blind = {
		{ ExtractAs = 'BlindChance', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'BlindEffect', BaseProperty = 'MissChance',
			Format = 'Percent' },
		{ ExtractAs = 'BlindDuration', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'BlindEffect', BaseProperty = 'Duration' },
	},
}


function with_keyword_extracts(own, ...)
	local combined = {}
	for _, entry in ipairs(own or {}) do table.insert(combined, entry) end

	for _, keyword in ipairs({ ... }) do
		for _, entry in ipairs(KEYWORD_EXTRACTS[keyword] or {}) do
			table.insert(combined, entry)
		end
	end
	return combined
end


function rush_end_suppressed(args)
	if not hero_live() then return true end

	if not (args and args.CheckSprint) then return false end
	if not game.SessionMapState.SprintActive then return false end

	return true
end


function rush_impact_ring(name, radius, pulses, delay, destinationId)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not name then return end

	destinationId = destinationId or (hero and hero.ObjectId)
	if not destinationId then return end

	local function draw()
		game.CreateAnimation({
			Name = name,
			DestinationId = destinationId,
			ScaleRadius = radius,
		})
	end

	draw()
	for _ = 2, (pulses or 1) do
		game.thread(function()
			game.wait(delay or 0.1, game.RoomThreadName)
			draw()
		end)
	end
end


function projectile_damage_scale(triggerArgs, projectileName, damage)
	if not triggerArgs or triggerArgs.EffectName or triggerArgs.SourceProjectile ~= projectileName then return 1 end

	local base = game.GetBaseDataValue({ Type = 'Projectile', Name = projectileName, Property = 'Damage' })
	if type(base) ~= 'number' or base <= 0 or type(damage) ~= 'number' then return 1 end
	return damage / base
end


function create_heartthrob(burstArgs)
	if not burstArgs then return end
	game.thread(game.CreateManaBurst, burstArgs, 1 + game.GetTotalHeroTraitValue('BurstCount'))
end


trait_text = {}
help_text = {}
stat_lines = {}
flavor_text = {}
combat_text = {}

BOON_EDIT_RECORDED = { 'TraitData', 'EffectData', 'HeroData' }

mod.DataVanilla = mod.DataVanilla or {}
mod.DataPatchKeys = mod.DataPatchKeys or {}
mod.DataPatchSignature = {}
mod.RecordedPatches = mod.RecordedPatches or {}
mod.RemovedKey = mod.RemovedKey or {}
boon_patches = {}

function boon_patch(boon, traitName, apply)
	table.insert(boon_patches, { Table = 'TraitData', Entry = traitName, Owners = { boon }, Apply = apply })
end

local function same(a, b)
	if a == b then return true end
	if type(a) ~= 'table' or type(b) ~= 'table' then return false end
	for key, value in pairs(a) do
		if not same(value, b[key]) then return false end
	end
	for key in pairs(b) do
		if a[key] == nil then return false end
	end
	return true
end

local function assign(target, source)
	for key in pairs(target) do
		if source[key] == nil then target[key] = nil end
	end
	for key, value in pairs(source) do
		if type(value) == 'table' and type(target[key]) == 'table' then
			assign(target[key], value)
		else
			target[key] = game.DeepCopyTable(value)
		end
	end
end

local function data_vanilla(tableName, entryName, real)
	local store = mod.DataVanilla[tableName]
	if not store then
		store = {}
		mod.DataVanilla[tableName] = store
	end

	local vanilla = store[entryName]
	local entry = (real or game[tableName])[entryName]
	if not vanilla and type(entry) == 'table' then
		vanilla = game.DeepCopyTable(entry)
		store[entryName] = vanilla
	end
	return vanilla
end

local function all_patches()
	local patches = {}
	for _, patch in ipairs(mod.RecordedPatches) do table.insert(patches, patch) end
	for _, patch in ipairs(boon_patches) do table.insert(patches, patch) end
	return patches
end

local function patch_apply(patch, entry)
	if patch.Apply then
		patch.Apply(entry)
		return
	end
	for key, value in pairs(patch.Changes) do
		if value == mod.RemovedKey then
			entry[key] = nil
		else
			entry[key] = game.DeepCopyTable(value)
		end
	end
end

local function patch_build(tableName, entryName, patches, live)
	local vanilla = data_vanilla(tableName, entryName)
	if not vanilla then return nil end

	local built = game.DeepCopyTable(vanilla)
	for _, patch in ipairs(patches) do
		if patch.Table == tableName and patch.Entry == entryName and live(patch) then patch_apply(patch, built) end
	end
	return built
end

function boon_patch_preview(traitName)
	return patch_build('TraitData', traitName, all_patches(), function() return true end)
end

function boon_patched(traitName)
	for _, patch in ipairs(all_patches()) do
		if patch.Table == 'TraitData' and patch.Entry == traitName then return true end
	end
	return false
end

function boon_patches_reconcile(bounty)
	local patches = all_patches()
	local boonLive = {}
	local function live(patch)
		for _, boon in ipairs(patch.Owners) do
			if boonLive[boon] == nil then boonLive[boon] = boon_edit_on(boon, bounty) end
			if not boonLive[boon] then return false end
		end
		return true
	end

	local entries = {}
	local signatures = {}
	for index, patch in ipairs(patches) do
		local id = patch.Table .. '.' .. patch.Entry
		if not signatures[id] then
			signatures[id] = {}
			table.insert(entries, { Id = id, Table = patch.Table, Entry = patch.Entry })
		end
		if live(patch) then table.insert(signatures[id], index) end
	end

	for _, item in ipairs(entries) do
		local signature = table.concat(signatures[item.Id], ',')
		local entry = game[item.Table] and game[item.Table][item.Entry]
		if type(entry) == 'table' and mod.DataPatchSignature[item.Id] ~= signature then
			local vanilla = data_vanilla(item.Table, item.Entry)
			local built = patch_build(item.Table, item.Entry, patches, live)

			local keys = {}
			for key, value in pairs(built) do
				if not same(value, vanilla[key]) then keys[key] = true end
			end
			for key in pairs(vanilla) do
				if built[key] == nil then keys[key] = true end
			end

			local touched = {}
			for key in pairs(mod.DataPatchKeys[item.Id] or {}) do touched[key] = true end
			for key in pairs(keys) do touched[key] = true end

			for key in pairs(touched) do
				local want = built[key]
				if want == nil then
					entry[key] = nil
				elseif type(want) == 'table' and type(entry[key]) == 'table' then
					assign(entry[key], want)
				else
					entry[key] = game.DeepCopyTable(want)
				end
			end

			mod.DataPatchKeys[item.Id] = keys
			mod.DataPatchSignature[item.Id] = signature
		end
	end
end

local function record_changes(vanilla, copy)
	local changes = {}
	local any = false
	for key, value in pairs(copy) do
		if not same(value, vanilla[key]) then
			changes[key] = value
			any = true
		end
	end
	for key in pairs(vanilla) do
		if copy[key] == nil then
			changes[key] = mod.RemovedKey
			any = true
		end
	end
	return any and changes or nil
end

local function record_conflicts(patch)
	for _, other in ipairs(mod.RecordedPatches) do
		if other.Table == patch.Table and other.Entry == patch.Entry
			and table.concat(other.Owners, ',') ~= table.concat(patch.Owners, ',') then
			for key in pairs(patch.Changes) do
				if other.Changes[key] ~= nil then
					print('[' .. _PLUGIN.guid .. '] ' .. patch.Table .. '.' .. patch.Entry .. '.' .. tostring(key) ..
						' is edited by both ' .. table.concat(other.Owners, '+') .. ' and ' .. table.concat(patch.Owners, '+'))
				end
			end
		end
	end
end

function boon_edit_all_on(owners)
	for _, boon in ipairs(owners) do
		if not boon_edit_on(boon) then return false end
	end
	return true
end

function boon_record(setup)
	local session = { Asked = {}, AskedSet = {}, Copies = {} }
	local reals = {}

	for _, tableName in ipairs(BOON_EDIT_RECORDED) do
		local real = game[tableName]
		local created = {}
		local copies = {}
		reals[tableName] = real
		session.Copies[tableName] = copies

		game[tableName] = setmetatable({}, {
			__index = function(_, name)
				if created[name] then return real[name] end
				local copy = copies[name]
				if copy then return copy.Data end

				local vanilla = data_vanilla(tableName, name, real)
				if not vanilla then return real[name] end

				local owners = {}
				for _, boon in ipairs(session.Asked) do table.insert(owners, boon) end
				copy = { Data = game.DeepCopyTable(vanilla), Owners = owners }
				copies[name] = copy
				return copy.Data
			end,
			__newindex = function(_, name, value)
				created[name] = true
				real[name] = value
			end,
			__pairs = function()
				return next, real, nil
			end,
		})
	end

	local path = modutil.mod.Path
	local wrap = path.Wrap
	path.Wrap = function(target, handler, ...)
		if #session.Asked == 0 then return wrap(target, handler, ...) end

		local owners = {}
		for _, boon in ipairs(session.Asked) do table.insert(owners, boon) end
		return wrap(target, function(base, ...)
			if boon_edit_all_on(owners) then return handler(base, ...) end
			return base(...)
		end, ...)
	end

	boon_recording = session
	local ok, err = pcall(setup)
	boon_recording = nil
	path.Wrap = wrap
	for tableName, real in pairs(reals) do game[tableName] = real end
	if not ok then error(err, 0) end

	local recorded = false
	for _, tableName in ipairs(BOON_EDIT_RECORDED) do
		for name, copy in pairs(session.Copies[tableName]) do
			local changes = record_changes(mod.DataVanilla[tableName][name], copy.Data)
			if changes then
				local owners = #copy.Owners > 0 and copy.Owners or session.Asked
				local patch = { Table = tableName, Entry = name, Owners = owners, Changes = changes }
				record_conflicts(patch)
				table.insert(mod.RecordedPatches, patch)
				recorded = true
			end
		end
	end
	if recorded then boon_patches_reconcile() end
end

function boon_edit_add_stat(traitName, statLine, extract)
	local trait = type(traitName) == 'table' and traitName or game.TraitData[traitName]
	if not trait then return end

	trait.ExtractValues = trait.ExtractValues or {}
	table.insert(trait.ExtractValues, extract)

	trait.StatLines = trait.StatLines or {}
	if game.Contains(trait.StatLines, statLine) then return end
	if #trait.StatLines >= 2 then
		trait.StatLines[2] = statLine
	else
		table.insert(trait.StatLines, statLine)
	end
end

function boon_edit_stat_index(traitName, extractAs)
	local trait = boon_patched(traitName) and boon_patch_preview(traitName) or game.TraitData[traitName]
	local index = 0
	for _, extract in ipairs((trait or {}).ExtractValues or {}) do
		if not extract.SkipAutoExtract then
			index = index + 1
			if extract.ExtractAs == extractAs then return index end
		end
	end
	return 1
end

trait_text_alt = {}
help_text_owner = {}

function boon_edit_alt_id(boon, id)
	return 'BoonEdit_' .. boon .. '_' .. id
end

function boon_edit_text_id(id)
	for _, alt in ipairs(id and trait_text_alt[id] or {}) do
		if boon_edit_on(alt.Boon) then return boon_edit_alt_id(alt.Boon, id) end
	end
	return id
end

function boon_text(boon, spec, when)
	if type(boon) == 'table' then
		spec, boon = boon, boon_text_recording and boon_text_owner or nil
	elseif when == false then
		return
	end

	if boon then
		for id, entry in pairs(spec.Traits or {}) do
			trait_text_alt[id] = trait_text_alt[id] or {}
			table.insert(trait_text_alt[id], { Boon = boon, Entry = entry })
		end
	else
		for id, entry in pairs(spec.Traits or {}) do trait_text[id] = entry end
	end
	for id, entry in pairs(spec.Keywords or {}) do
		help_text[id] = entry
		help_text_owner[id] = boon
		if entry.DisplayName and not game.Contains(game.KeywordList, id) then
			table.insert(game.KeywordList, id)
		end
	end
	for id, entry in pairs(spec.StatLines or {}) do stat_lines[id] = entry end
	for id, entry in pairs(spec.Flavor or {}) do flavor_text[id] = entry end
	for id, entry in pairs(spec.CombatText or {}) do combat_text[id] = entry end
end

function sjson_EnemyProjectiles(data)
	if not data or not data.Projectiles then return end

	local tuning = mod.tuning.VolcanicCrown
	local order = {
		'Name', 'InheritFrom', 'Damage', 'TotalFuse', 'SpawnOnDetonate',
		'AffectsEnemies', 'AffectsFriends', 'AffectsSelf',
	}

	local existing = {}
	for _, projectile in ipairs(data.Projectiles) do
		existing[projectile.Name] = true
	end

	local copies = {
		{
			Name = tuning.FireProjectile,
			InheritFrom = 'DevotionHestiaFire',
			Damage = tuning.FireDamage,
			TotalFuse = tuning.FireDuration,
		},
		{
			Name = tuning.FireballProjectile,
			InheritFrom = 'DevotionHestia',
			Damage = tuning.FireballDamage.Common,
			SpawnOnDetonate = sjson.null,
		},
	}

	for _, copy in ipairs(copies) do
		if not existing[copy.Name] then
			copy.AffectsEnemies = true
			copy.AffectsFriends = false
			copy.AffectsSelf = false
			table.insert(data.Projectiles, sjson.to_object(copy, order))
		end
	end
end

function sjson_PoseidonVfx(data)
	if not data or not data.Animations then return end

	for _, animation in ipairs(data.Animations) do
		if animation.Name == mod.tuning.PoseidonSplash.RedNova then return end
	end

	table.insert(data.Animations, sjson.to_object({
		Name = mod.tuning.PoseidonSplash.RedNova,
		InheritFrom = 'RadialNovaPentagram_Poseidon',
		ClearCreateAnimations = true,
		StartRed = 1,
		StartGreen = 0.01,
		StartBlue = 0.01,
		EndRed = 0.7,
		EndGreen = 0,
		EndBlue = 0,
	}, {
		'Name', 'InheritFrom', 'ClearCreateAnimations',
		'StartRed', 'StartGreen', 'StartBlue', 'EndRed', 'EndGreen', 'EndBlue',
	}))
end


function sjson_HestiaVfx(data)
	if not data or not data.Animations then return end

	local tuning = mod.tuning.IonicGain
	for _, animation in ipairs(data.Animations) do
		if animation.Name == tuning.RingFx then return end
	end

	table.insert(data.Animations, sjson.to_object({
		Name = tuning.RingFx,
		InheritFrom = 'HestiaCastDefenseCircleA',
		Scale = 1,
		Loop = true,
		Duration = 3600,
		RandomDurationMin = 3600,
		RandomDurationMax = 3600,
		StartAlpha = 1,
		EndAlpha = 1,
		EaseIn = 0,
		EaseOut = 0,
		PingPongColor = false,
		ColorFromOwner = 'Ignore',
		StartRed = 1,
		StartGreen = 1,
		StartBlue = 1,
		EndRed = 1,
		EndGreen = 1,
		EndBlue = 1,
		Hue = tuning.RingHue,
	}, { 'Name', 'InheritFrom' }))
end


function sjson_CastVfx(data)
	if not data or not data.Animations then return end

	local existing = {}
	for _, animation in ipairs(data.Animations) do
		existing[animation.Name] = true
	end

	local circles = {
		{ Name = mod.tuning.BreakerRush.ImpactFx, InheritFrom = 'CastCircleOutPoseidon', Bare = true },
		{ Name = mod.tuning.SmithyRush.ImpactFx, InheritFrom = 'CastCircleOutHephaestus', Bare = true },
	}

	for _, circle in ipairs(circles) do
		if circle.Name and not existing[circle.Name] then
			local entry = {
				Name = circle.Name,
				InheritFrom = circle.InheritFrom,
				Sound = 'null',
			}
			local order = { 'Name', 'InheritFrom', 'Sound' }

			if circle.Bare then
				entry.ClearCreateAnimations = true
				table.insert(order, 'ClearCreateAnimations')
			end

			table.insert(data.Animations, sjson.to_object(entry, order))
		end
	end
end


function sjson_HelpText(data)
	local found = {}
	for _, entry in ipairs(data.Texts) do
		local rewrite = help_text[entry.Id]
		local owner = help_text_owner[entry.Id]
		if rewrite and (owner == nil or boon_edit_configured(owner)) then
			found[entry.Id] = true
			if rewrite.Description then entry.Description = rewrite.Description end
		end
	end

	local order = { 'Id', 'DisplayName', 'Description' }
	for id, keyword in pairs(help_text) do
		if not found[id] and keyword.DisplayName then
			table.insert(data.Texts, sjson.to_object({
				Id = id,
				DisplayName = keyword.DisplayName,
				Description = keyword.Description,
			}, order))
		end
	end
end

function sjson_TraitText(data)
	local rewritten = {}
	local vanilla = {}

	for _, entry in ipairs(data.Texts) do
		vanilla[entry.Id] = true
	end

	for id, alts in pairs(trait_text_alt) do
		local entries = {}
		for _, alt in ipairs(alts) do
			table.insert(entries, {
				Id = boon_edit_alt_id(alt.Boon, id),
				InheritFrom = vanilla[id] and id or nil,
				DisplayName = alt.Entry.DisplayName,
				Description = alt.Entry.Description,
			})
		end

		if not vanilla[id] and alts[1] then
			table.insert(entries, {
				Id = id,
				DisplayName = alts[1].Entry.DisplayName,
				Description = alts[1].Entry.Description,
			})
		end

		for _, text in ipairs(entries) do
			local order = { 'Id' }
			if text.InheritFrom then table.insert(order, 'InheritFrom') end
			if text.DisplayName then table.insert(order, 'DisplayName') end
			if text.Description then table.insert(order, 'Description') end
			table.insert(data.Texts, sjson.to_object(text, order))
		end
	end

	for _, entry in ipairs(data.Texts) do
		local rewrite = trait_text[entry.Id]
		if rewrite then
			rewritten[entry.Id] = true
			if rewrite.DisplayName then
				entry.DisplayName = rewrite.DisplayName
			end
			if rewrite.Description then
				entry.Description = rewrite.Description
			end
		end
	end

	for id, entry in pairs(trait_text) do
		if not rewritten[id] then
			local text = { Id = id }
			local order = { 'Id' }

			if entry.DisplayName then
				text.DisplayName = entry.DisplayName
				table.insert(order, 'DisplayName')
			end
			if entry.Description then
				text.Description = entry.Description
				table.insert(order, 'Description')
			end

			table.insert(data.Texts, sjson.to_object(text, order))
		end
	end

	local statLineOrder = { 'Id', 'InheritFrom', 'DisplayName', 'Description' }

	for id, entry in pairs(stat_lines) do
		local name = type(entry) == 'table' and entry.Name or entry
		local index = (type(entry) == 'table' and entry.Index) or 1
		local suffix = (type(entry) == 'table' and entry.Suffix) or ''
		table.insert(data.Texts, sjson.to_object({
			Id = id,
			InheritFrom = 'BaseStatLine',
			DisplayName = '{!Icons.Bullet}{#PropertyFormat}' .. name,
			Description = '{#UpgradeFormat}{$TooltipData.StatDisplay' .. index .. '}' .. suffix,
		}, statLineOrder))
	end

	local flavorOrder = { 'Id', 'DisplayName' }
	for id, text in pairs(flavor_text) do
		table.insert(data.Texts, sjson.to_object({ Id = id, DisplayName = text }, flavorOrder))
	end

	for id, text in pairs(combat_text) do
		table.insert(data.Texts, sjson.to_object({ Id = id, DisplayName = text }, flavorOrder))
	end
end


import 'boons/fireballs.lua'
import 'boons/glamour_gain.lua'
import 'boons/passion_rush.lua'
import 'boons/carnal_pleasure.lua'
import 'boons/smoldering_forge.lua'
import 'boons/ecstatic_obsession.lua'
import 'boons/hearty_appetite.lua'
import 'boons/secret_crush.lua'

import 'boons/stabbing_rush.lua'
import 'boons/profuse_bleeding.lua'
import 'boons/meat_grinder.lua'
import 'boons/sword_ring.lua'
import 'boons/cutting_edge.lua'
import 'boons/hostile_environment.lua'
import 'boons/blood_spree.lua'
import 'boons/grape_juice.lua'
import 'boons/festive_fog.lua'

import 'boons/phalanx_shot.lua'

import 'boons/sun_worshiper.lua'
import 'boons/dazzling_display.lua'
import 'boons/extra_dose.lua'
import 'boons/perfect_image.lua'

import 'boons/local_climate.lua'
import 'boons/tranquil_gain.lua'
import 'boons/winter_harvest.lua'
import 'boons/natural_selection.lua'
import 'boons/cryo_pounder.lua'
import 'boons/arctic_gale.lua'
import 'boons/weed_killer.lua'
import 'boons/snow_queen.lua'
import 'boons/steady_growth.lua'

import 'boons/unseen_ire.lua'
import 'boons/old_grudge.lua'

import 'boons/anvil_ring.lua'
import 'boons/smithy_rush.lua'
import 'boons/heavy_metal.lua'
import 'boons/burning_desire.lua'
import 'boons/controlled_burn.lua'
import 'boons/molten_touch.lua'
import 'boons/tough_gain.lua'
import 'boons/premium_service.lua'
import 'boons/chain_reaction.lua'
import 'boons/seismic_hammer.lua'
import 'boons/brave_face.lua'

import 'boons/rousing_reception.lua'
import 'boons/all_together.lua'
import 'boons/nuptial_vow.lua'
import 'boons/cherished_heirloom.lua'

import 'boons/mean_streak.lua'
import 'boons/post_haste.lua'
import 'boons/second_wind.lua'
import 'boons/stutter_step.lua'

import 'boons/burning_meteor.lua'
import 'boons/cardio_gain.lua'
import 'boons/scalding_vapor.lua'
import 'boons/volcanic_crown.lua'

import 'boons/breaker_rush.lua'
import 'boons/tidal_ring.lua'
import 'boons/geyser_spout.lua'
import 'boons/easy_shot.lua'
import 'boons/beach_ball.lua'
import 'boons/arterial_spray.lua'
import 'boons/ripple_effect.lua'

import 'boons/shocking_loss.lua'
import 'boons/killer_current.lua'
import 'boons/air_quality.lua'
import 'boons/power_surge.lua'
import 'boons/arc_flash.lua'
import 'boons/thunder_rush.lua'

import 'boons/thermal_dynamics.lua'

import 'boons/harm_for_the_afflicted.lua'
import 'boons/enfeeblement_of_cowards.lua'

import 'boons/preparation.lua'

import 'boons/ionic_gain.lua'
import 'boons/glorious_disaster.lua'

import 'keepsakes/aromatic_phial.lua'
import 'keepsakes/concave_stone.lua'
import 'keepsakes/calling_card.lua'
import 'keepsakes/white_antler.lua'
import 'keepsakes/evil_eye.lua'
import 'keepsakes/metallic_droplet.lua'

import 'aspects/aspect_of_supay.lua'

import 'hammeredit/dual_moonshot.lua'
import 'hammeredit/reaper_knives.lua'
import 'hammeredit/enduring_coil.lua'
import 'hammeredit/hidden_helix.lua'
import 'hammeredit/hidden_knives.lua'
import 'hammeredit/rising_helix.lua'
import 'hammeredit/whirling_helix.lua'


import 'systems/scythe_slows.lua'
import 'systems/combat_text_stack.lua'
import 'systems/sprint_follows_speed.lua'
import 'systems/config_window.lua'

boon_patches_reconcile()

import 'requirements.lua'

boon_text_recording = true
local textOk, textErr = pcall(function()
	import 'text.lua'
end)
boon_text_recording = nil
boon_text_owner = nil
if not textOk then error(textErr, 0) end

once('Trials', function()
	import 'bounties/trial_of_devotion.lua'
	import 'bounties/trial_of_heartbreak.lua'
	import 'bounties/trial_of_embers.lua'
	import 'bounties/trial_of_blades.lua'
	import 'bounties/trial_of_storms.lua'
	import 'bounties/trial_of_arrows.lua'
	import 'bounties/trial_of_revelry.lua'
	import 'bounties/trial_of_charisma.lua'
end)
boon_patches_reconcile()

function poseidon_splash_scale()
	local scale = 1

	for _, data in pairs(game.GetHeroTraitValues('ConeModifier')) do
		if data.ScaleIncrease then
			scale = scale * data.ScaleIncrease
		end
		if data.MaxScale and scale > data.MaxScale then
			scale = data.MaxScale
		end
	end

	return scale
end

function poseidon_splash_cone(waveFx)
	local scale = 1
	local count = 1
	local graphic = nil

	for _, data in pairs(game.GetHeroTraitValues('ConeModifier')) do
		if data.ScaleIncrease then
			scale = scale * data.ScaleIncrease
		end
		if data.MaxScale and scale > data.MaxScale then
			scale = data.MaxScale
		end
		if data.DoubleWaveChance and game.RandomChance(data.DoubleWaveChance
			* game.GetTotalHeroTraitValue('LuckMultiplier', { IsMultiplier = true })) then
			count = count + 1
			graphic = waveFx or data.DoubleWaveGraphic
		end
	end

	return scale, count, graphic
end


function poseidon_circle_splash(args)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or not args.X or not args.Y or not args.Radius then return end

	local _, count, graphic = poseidon_splash_cone(mod.tuning.PoseidonSplash.RedNova)
	local first = args.From or 1
	if count < first then return end

	local projectile = mod.tuning.PoseidonSplash.CircleProjectile
	local multiplier = args.DamageMultiplier
	if args.Damage then
		local base = game.GetBaseDataValue({ Type = 'Projectile', Name = projectile, Property = 'Damage' })
		if type(base) ~= 'number' or base <= 0 then return end
		multiplier = args.Damage / base
	end

	local baseRadius = game.GetBaseDataValue({ Type = 'Projectile', Name = projectile, Property = 'DamageRadius' })
	local visual = (type(baseRadius) == 'number' and baseRadius > 0) and args.Radius / baseRadius or 1

	local anchor = game.SpawnObstacle({ Name = 'BlankObstacle', LocationX = args.X, LocationY = args.Y })
	if not anchor then return end

	local last = 0
	arterial_spray_begin({ ProjectileName = projectile })

	local ok, err = pcall(function()
		for index = first, count do
			last = (index - 1) * mod.tuning.PoseidonSplash.WaveDelay
			game.CreateProjectileFromUnit({
				Name = projectile,
				Id = hero.ObjectId,
				DestinationId = anchor,
				FireFromTarget = true,
				DamageMultiplier = multiplier,
				ScaleMultiplier = visual,
				DataProperties = {
					DamageRadius = args.Radius,
					StartFx = index > 1 and graphic or nil,
					StartDelay = last,
					ImpactVelocity = args.Knockback,
				},
			})
		end
	end)

	arterial_spray_end()

	game.thread(game.DestroyOnDelay, { anchor }, last + mod.tuning.PoseidonSplash.WaveDelay)
	if not ok then error(err) end
end


function cast_area_multiplier()
	local multiplier = 1

	for _, data in pairs(game.GetHeroTraitValues('CastProjectileModifiers')) do
		if data.AreaIncrease then
			multiplier = multiplier * data.AreaIncrease
		end
	end

	return multiplier
end


function wait_for_screens(settle)
	settle = settle or 0

	for _ = 1, SCREEN_WAIT_TRIES do
		if not game.IsEmpty(game.ActiveScreenOrder or {}) then
			game.waitUnmodified(SCREEN_WAIT_STEP)
		else
			if settle > 0 then game.waitUnmodified(settle) end
			if game.IsEmpty(game.ActiveScreenOrder or {}) then return end
		end
	end
end

function defer_screen_open(open, ...)
	if game.IsEmpty(game.ActiveScreenOrder or {}) then
		return open(...)
	end

	local args = table.pack(...)
	game.thread(function()
		wait_for_screens(0)
		open(table.unpack(args, 1, args.n))
	end)
end
