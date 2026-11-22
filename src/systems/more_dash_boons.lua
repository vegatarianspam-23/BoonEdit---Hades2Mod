---@meta _
---@diagnostic disable: lowercase-global


MORE_DASH_GUID = 'zerp-More_Dash_Boons'
MORE_DASH_ON_SPRINT = MORE_DASH_GUID .. 'OnSprintAction'
MORE_DASH_ONE_ONLY = MORE_DASH_GUID .. '.CheckNoExistingBlinkBoons'

MORE_DASH_COPIES = {
	{ Name = 'SWuFlameBlinkBoon', Source = 'HestiaBlinkTrailBoon', God = 'Hestia' },
	{ Name = 'SWuFlutterBlinkBoon', Source = 'AphroditeBlinkTrailBoon', God = 'Aphrodite' },
	{ Name = 'SWuThunderBlinkBoon', Source = 'ZeusBlinkTrailBoon', God = 'Zeus' },
	{ Name = 'SWuCrystalBlinkBoon', Source = 'DemeterBlinkTrailBoon', God = 'Demeter' },
	{ Name = 'SWuSwornBlinkBoon', Source = 'HeraBlinkTrailBoon', God = 'Hera' },
	{ Name = 'SWuBloodyBlinkBoon', Source = 'AresBlinkTrailBoon', God = 'Ares' },
	{ Name = 'SWuWaveBlinkBoon', Source = 'PoseidonBlinkTrailBoon', God = 'Poseidon' },
	{ Name = 'SWuBlindingBlinkBoon', Source = 'ApolloBlinkTrailBoon', God = 'Apollo' },
	{ Name = 'SWuVolcanicBlinkBoon', Source = 'HephaestusBlinkTrailBoon', God = 'Hephaestus' },
}


function more_dash_source(copy)
	return MORE_DASH_GUID .. '-' .. copy.Source
end


function more_dash_on()
	return boon_edit_mod_on('MoreDashBoons', MORE_DASH_GUID)
end


function more_dash_live()
	for _, on in pairs(game.SWuMoreDashBoons or {}) do
		if on then return true end
	end
	return false
end


function more_dash_holds(traitName)
	return more_dash_live() and game.HeroHasTrait(traitName)
end


local function more_dash_rename(value, from, to, seen)
	if type(value) ~= 'table' or seen[value] then return end
	seen[value] = true
	for key, field in pairs(value) do
		if field == from then
			value[key] = to
		else
			more_dash_rename(field, from, to, seen)
		end
	end
end


local function more_dash_flutter_action(tuning)
	return {
		ValidProjectiles = { tuning.FlutterProjectile },
		ValidProjectilesLookup = game.ToLookup({ tuning.FlutterProjectile }),
		FirstHitOnly = true,
		FunctionName = _PLUGIN.guid .. '.SWuFlutterBlink',
		Args = {},
	}
end


local MORE_DASH_OVERRIDES = {
	SWuFlutterBlinkBoon = function(trait, tuning)
		trait.OnEnemyDamagedAction = more_dash_flutter_action(tuning)
	end,

	SWuCrystalBlinkBoon = function(trait, tuning)
		trait.OnEnemyDamagedAction = {
			ValidProjectiles = { tuning.CrystalProjectile },
			ValidProjectilesLookup = game.ToLookup({ tuning.CrystalProjectile }),
			FunctionName = 'ApplyRoot',
			Args = { EffectName = tuning.CrystalEffect },
		}
	end,

	SWuSwornBlinkBoon = function(trait, tuning)
		local action = trait[MORE_DASH_ON_SPRINT]
		if action then action.FunctionName = _PLUGIN.guid .. '.SWuSwornBlink' end
		local damage = action and action.FunctionArgs and action.FunctionArgs.DamageMultiplier
		if type(damage) ~= 'table' then return end
		damage.BaseValue = (damage.BaseValue or 1) * tuning.SwornPower
		for i, value in pairs(damage.AbsoluteStackValues or {}) do
			damage.AbsoluteStackValues[i] = value * tuning.SwornPower
		end
	end,

	SWuWaveBlinkBoon = function(trait)
		local action = trait[MORE_DASH_ON_SPRINT]
		if action then action.FunctionName = _PLUGIN.guid .. '.SWuWaveBlink' end
	end,

	SWuBlindingBlinkBoon = function(trait)
		local action = trait.OnEnemyDamagedAction
		if action then action.FunctionName = _PLUGIN.guid .. '.SWuBlindingBlink' end
	end,

	SWuVolcanicBlinkBoon = function(trait, tuning)
		trait.OnEnemyDamagedAction = {
			ValidProjectiles = { tuning.VolcanicBlast },
			ValidProjectilesLookup = game.ToLookup({ tuning.VolcanicBlast }),
			FunctionName = _PLUGIN.guid .. '.SWuVolcanicMineStun',
			Args = {},
		}
	end,
}


local function more_dash_define(copy)
	local sourceName = more_dash_source(copy)
	local source = game.TraitData[sourceName]
	if not source then return false end

	local trait = game.DeepCopyTable(source)
	more_dash_rename(trait, sourceName, copy.Name, {})
	trait.Name = copy.Name
	trait.Icon = source.Icon
	game.ProcessDataInheritance(trait, game.TraitData)

	if type(trait.GameStateRequirements) == 'table' then
		for _, requirement in ipairs(trait.GameStateRequirements) do
			if type(requirement) == 'table' and requirement.FunctionName == MORE_DASH_ONE_ONLY then
				requirement.FunctionName = _PLUGIN.guid .. '.SWuMoreDashLimit'
			end
		end
	end

	local override = MORE_DASH_OVERRIDES[copy.Name]
	if override then override(trait, mod.tuning.MoreDashBoons) end
	game.TraitData[copy.Name] = trait

	local requirements = game.TraitRequirements and game.TraitRequirements[sourceName]
	if requirements and not game.TraitRequirements[copy.Name] then
		game.TraitRequirements[copy.Name] = game.DeepCopyTable(requirements)
	end
	return true
end


local function more_dash_list(list, traitName, wanted)
	if type(list) ~= 'table' then return end
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


local function more_dash_pool(traitName, lootName, wanted)
	local loot = game.LootData[lootName]
	if loot then
		loot.Traits = loot.Traits or {}
		more_dash_list(loot.Traits, traitName, wanted)
		if loot.TraitIndex then loot.TraitIndex[traitName] = wanted or nil end
	end

	local info = game.ScreenData and game.ScreenData.BoonInfo
	if not info then return end
	local dictionary = info.TraitDictionary and info.TraitDictionary[lootName]
	if dictionary then dictionary[traitName] = wanted or nil end
	local order = info.TraitSortOrder and info.TraitSortOrder[lootName]
	if order then more_dash_list(order, traitName, wanted) end
end


local function more_dash_strip(traitName, wanted)
	mod.MoreDashStripped = mod.MoreDashStripped or {}
	local stripped = mod.MoreDashStripped[traitName] or {}
	mod.MoreDashStripped[traitName] = stripped

	if wanted then
		for lootName, loot in pairs(game.LootData or {}) do
			if type(loot) == 'table' and type(loot.Traits) == 'table' and game.Contains(loot.Traits, traitName) then
				stripped[lootName] = true
				more_dash_pool(traitName, lootName, false)
			end
		end
	else
		for lootName in pairs(stripped) do
			more_dash_pool(traitName, lootName, true)
		end
		mod.MoreDashStripped[traitName] = nil
	end
end


local function more_dash_alias(wanted)
	local added = mod.MoreDashAliases or setmetatable({}, { __mode = 'k' })
	mod.MoreDashAliases = added

	if not wanted then
		for list, ids in pairs(added) do
			for id in pairs(ids) do more_dash_list(list, id, false) end
		end
		mod.MoreDashAliases = nil
		return
	end

	local swaps, own = {}, {}
	for _, copy in ipairs(MORE_DASH_COPIES) do
		swaps[more_dash_source(copy)] = copy.Name
		own[copy.Name] = true
	end

	local seen = {}
	local function walk(value, depth)
		if type(value) ~= 'table' or seen[value] or depth > 4 then return end
		seen[value] = true

		local adds = {}
		for _, name in ipairs(value) do
			if type(name) == 'string' and swaps[name] then table.insert(adds, swaps[name]) end
		end
		for _, name in ipairs(adds) do
			if not game.Contains(value, name) then
				table.insert(value, name)
				added[value] = added[value] or {}
				added[value][name] = true
			end
		end

		for _, field in pairs(value) do
			if type(field) == 'table' then walk(field, depth + 1) end
		end
	end

	for traitName, requirements in pairs(game.TraitRequirements or {}) do
		if not own[traitName] then walk(requirements, 1) end
	end
	walk(game.LinkedTraitData, 0)
end


function more_dash_sync()
	if not boon_edit_mod_present(MORE_DASH_GUID) then return end

	game.SWuMoreDashBoons = game.SWuMoreDashBoons or {}
	game.SWuMoreDashBoons[_PLUGIN.guid] = more_dash_on()
	local wanted = more_dash_live()

	for _, copy in ipairs(MORE_DASH_COPIES) do
		local defined = more_dash_define(copy)
		local lootName = copy.God .. 'Upgrade'
		more_dash_pool(copy.Name, lootName, wanted and defined)
		more_dash_strip(more_dash_source(copy), wanted and defined)
	end
	more_dash_alias(wanted)
	more_dash_flutter_held()
	more_dash_glow_cleanup()
	more_dash_trail_hook()
end


function more_dash_cap(hero)
	local tuning = mod.tuning.MoreDashBoons
	for _, trait in ipairs(hero.Traits or {}) do
		local name = trait.Name
		if type(name) == 'string' and name:find('FamilyTrade', 1, true) and name:sub(-4) == 'Boon' then
			return tuning.FamilyTradeMaxHeld
		end
	end
	return tuning.MaxHeld
end


function mod.SWuMoreDashLimit(source)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return true end
	local held = 0
	for _, trait in ipairs(hero.Traits or {}) do
		if trait[MORE_DASH_ON_SPRINT] and not (source and trait.Name == source.Name) then held = held + 1 end
	end
	return held < more_dash_cap(hero)
end


function more_dash_trail_hook()
	if game.SWuMoreDashTrailHooked then return end
	game.SWuMoreDashTrailHooked = true
	modutil.mod.Path.Wrap('StartBlinkTrailPresentation', function(base, ...)
		return more_dash_trails(base, ...)
	end)
end


function more_dash_trails(base, ...)
	if not more_dash_live() or game.MapState.BabyPolymorph then return base(...) end
	local actions = game.GetHeroTraitValues(MORE_DASH_ON_SPRINT)
	if #actions < 2 then return base(...) end

	for i, data in ipairs(actions) do
		if i == 1 then
			game.thread(game.CallFunctionName, data.FunctionName, data.FunctionArgs)
		else
			local trails = game.MapState.BlinkDropTrail
			game.MapState.BlinkDropTrail = nil
			game.thread(game.CallFunctionName, data.FunctionName, data.FunctionArgs)
			local own = game.MapState.BlinkDropTrail
			game.MapState.BlinkDropTrail = trails or {}
			for id, ids in pairs(own or {}) do game.MapState.BlinkDropTrail[id] = ids end
		end
	end
end


MORE_DASH_GLOWS = { 'BlinkTrailAphroditeProjectileGlow', 'BlinkTrailAphroditeTarget', 'BlinkTrailAphroditeTargetFast' }


function more_dash_glow_cleanup()
	local zerp = game[MORE_DASH_GUID]
	if type(zerp) ~= 'table' then return end
	local base = zerp.CreateAphroditeProjectile
	if type(base) ~= 'function' or base == zerp.SWuGlowCleanup then return end

	zerp.SWuGlowCleanup = function(id, functionArgs, blinkId)
		base(id, functionArgs, blinkId)
		if blinkId then
			game.StopAnimation({ Names = MORE_DASH_GLOWS, DestinationId = blinkId, PreventChain = true })
		end
	end
	zerp.CreateAphroditeProjectile = zerp.SWuGlowCleanup
end


function more_dash_ripple(name)
	local tuning = mod.tuning.MoreDashBoons
	return (name == tuning.WaveProjectile or name == tuning.FlutterProjectile)
		and more_dash_live()
end


local function more_dash_sworn(args, tuning, from, to)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	local origin = game.SpawnObstacle({ Name = 'InvisibleTarget', Group = 'Scripting', LocationX = from.X, LocationY = from.Y })
	local anchor = game.SpawnObstacle({ Name = 'InvisibleTarget', Group = 'Scripting',
		LocationX = (from.X + to.X) / 2, LocationY = (from.Y + to.Y) / 2 })
	local angle = game.GetAngleBetween({ Id = origin, DestinationId = hero.ObjectId })
	game.Destroy({ Id = origin })

	game.CreateProjectileFromUnit({
		Name = tuning.SwornRift,
		Id = hero.ObjectId,
		DestinationId = anchor,
		FireFromTarget = true,
		Angle = angle,
		DamageMultiplier = args.DamageMultiplier,
		DataProperties = { StartDelay = tuning.SwornStartDelay },
	})
	game.thread(game.DestroyOnDelay, { anchor }, tuning.SwornAnchorLife)
end


local function more_dash_base_ratio(from, to, property)
	local a = game.GetBaseDataValue({ Type = 'Projectile', Name = from, Property = property })
	local b = game.GetBaseDataValue({ Type = 'Projectile', Name = to, Property = property })
	if type(a) ~= 'number' or type(b) ~= 'number' or a <= 0 or b <= 0 then return 1 end
	return a / b
end


local function more_dash_mine_blast(args, tuning)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or not args.FireFromId then return nil end
	local id = game.CreateProjectileFromUnit({
		Name = tuning.VolcanicBlast,
		Id = hero.ObjectId,
		DestinationId = args.FireFromId,
		FireFromTarget = true,
		DamageMultiplier = (args.DamageMultiplier or 1) * more_dash_base_ratio(tuning.VolcanicMine, tuning.VolcanicBlast, 'Damage'),
		BlastRadiusModifier = game.GetTotalHeroTraitValue('MassiveAttackSizeModifier', { IsMultiplier = true }),
	})
	if id then
		game.SessionMapState.SWuVolcanicMineBlasts = game.SessionMapState.SWuVolcanicMineBlasts or {}
		game.SessionMapState.SWuVolcanicMineBlasts[id] = true
	end
	return id
end


---@diagnostic disable-next-line: unused-local
function mod.SWuVolcanicMineStun(enemy, _functionArgs, triggerArgs)
	if not more_dash_holds('SWuVolcanicBlinkBoon') then return end
	if not enemy or not enemy.ObjectId or enemy.IsDead or boon_ignores(enemy) then return end
	local blasts = game.SessionMapState.SWuVolcanicMineBlasts
	if not blasts or not triggerArgs or not blasts[triggerArgs.ProjectileId] then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end
	local stun = mod.tuning.MoreDashBoons.VolcanicStun
	game.ApplyEffect({
		DestinationId = enemy.ObjectId,
		Id = hero.ObjectId,
		EffectName = stun.EffectName,
		DataProperties = {
			Duration = stun.Duration,
			DisableMove = true,
			DisableRotate = true,
			DisableAttack = true,
			Active = true,
			CanAffectInvulnerable = false,
			Cancelable = true,
		},
	})
end


once('MoreDashBoonsProjectiles', function()
	modutil.mod.Path.Wrap('CreateProjectileFromUnit', function(base, args)
		local seen = game.SWuMoreDashSeen or setmetatable({}, { __mode = 'k' })
		game.SWuMoreDashSeen = seen
		if type(args) ~= 'table' or seen[args] then return base(args) end
		seen[args] = true

		local tuning = mod.tuning.MoreDashBoons
		if args.Name == tuning.SwornProjectile and more_dash_holds('SWuSwornBlinkBoon') then return nil end

		if args.Name == tuning.VolcanicMine and more_dash_holds('SWuVolcanicBlinkBoon') then
			return more_dash_mine_blast(args, tuning)
		end
		return base(args)
	end)
end)


local function more_dash_wave(args, tuning)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or hero.IsDead then return end
	game.CreateProjectileFromUnit({
		Name = args.ProjectileName or tuning.WaveProjectile,
		Id = hero.ObjectId,
		Angle = game.GetAngle({ Id = hero.ObjectId }) or 0,
		FireFromTarget = true,
		DamageMultiplier = args.DamageMultiplier,
		ProjectileCap = tuning.WaveCap,
	})
end


function mod.SWuWaveBlink(args)
	if not more_dash_live() then
		return game.CallFunctionName(MORE_DASH_GUID .. '.StartPoseidonBlink', args)
	end

	local tuning = mod.tuning.MoreDashBoons
	more_dash_wave(args, tuning)

	local state = game.MapState
	if not state or state.SWuWaveBlinkActive then return end
	state.SWuWaveBlinkActive = true

	local grace = game._worldTime + tuning.WaveGrace
	while game.MapState == state and more_dash_live() do
		game.wait(tuning.WaveInterval, game.RoomThreadName)
		local sprinting = game.SessionMapState and game.SessionMapState.SprintActive
		if not sprinting and game._worldTime > grace then break end
		more_dash_wave(args, tuning)
	end
	state.SWuWaveBlinkActive = nil
end


function mod.SWuSwornBlink(args)
	local zerp = MORE_DASH_GUID .. '.StartHeraBlink'
	if not more_dash_live() then
		return game.CallFunctionName(zerp, args)
	end
	game.thread(game.CallFunctionName, zerp, args)

	local hero = game.CurrentRun and game.CurrentRun.Hero
	local state = game.MapState
	if not hero or not state then return end
	local run = (state.SWuSwornRun or 0) + 1
	state.SWuSwornRun = run

	local tuning = mod.tuning.MoreDashBoons
	local last = game.GetLocation({ Id = hero.ObjectId })
	local delay = tuning.SwornFirstDelay
	local fired = 0

	while game.MapState == state and state.SWuSwornRun == run and fired < tuning.SwornMaxRifts do
		game.wait(delay, 'BlinkTrailPresentation')
		delay = tuning.SwornInterval
		if not (game.SessionMapState and game.SessionMapState.SprintActive) then break end
		if not more_dash_holds('SWuSwornBlinkBoon') then break end

		local here = game.GetLocation({ Id = hero.ObjectId })
		if type(here) == 'table' and here.X and type(last) == 'table' and last.X then
			local dx, dy = here.X - last.X, here.Y - last.Y
			if dx * dx + dy * dy > tuning.SwornMinMove * tuning.SwornMinMove then
				more_dash_sworn(args, tuning, last, here)
				fired = fired + 1
			end
		end
		last = here
	end
end


function mod.SWuBlindingBlink(enemy, functionArgs, triggerArgs)
	local mdb = MORE_DASH_GUID .. '.CheckSuperBlindApply'
	if not more_dash_live() then
		return game.CallFunctionName(mdb, enemy, functionArgs, triggerArgs)
	end
	if not enemy or not enemy.ObjectId or enemy.IsDead then return end

	local cooldown = functionArgs.Cooldown * game.GetTotalHeroTraitValue('OlympianRechargeMultiplier', { IsMultiplier = true })
	if not game.CheckCooldown('ApolloSuperBlind' .. tostring(enemy.ObjectId), cooldown) then return end

	local blind = game[MORE_DASH_GUID] and game[MORE_DASH_GUID].SuperBlind
	if blind then game.thread(blind, enemy, functionArgs, triggerArgs) end

	if enemy.SkipModifiers or enemy.BlockCritMark then return end
	local effectName = mod.tuning.MoreDashBoons.BlindingEffect
	local data = game.ShallowCopyTable(game.EffectData[effectName].EffectData)
	data.Duration = functionArgs.Duration
	game.ApplyEffect({
		DestinationId = enemy.ObjectId,
		Id = game.CurrentRun.Hero.ObjectId,
		EffectName = effectName,
		DataProperties = data,
	})
end


function more_dash_flutter_held()
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or not more_dash_live() then return end
	local names = { SWuFlutterBlinkBoon = true, [MORE_DASH_GUID .. '-AphroditeBlinkTrailBoon'] = true }
	for _, trait in ipairs(hero.Traits or {}) do
		if names[trait.Name] and not trait.OnEnemyDamagedAction then
			trait.OnEnemyDamagedAction = more_dash_flutter_action(mod.tuning.MoreDashBoons)
		end
	end
end


function mod.SWuFlutterBlink(enemy)
	if not more_dash_live() or not enemy or not enemy.ObjectId or enemy.IsDead then return end
	if is_allied_summon(enemy) then return end
	if not rolls(mod.tuning.MoreDashBoons.FlutterCharmChance) then return end
	game.thread(obsession_try_charm, enemy)
end
