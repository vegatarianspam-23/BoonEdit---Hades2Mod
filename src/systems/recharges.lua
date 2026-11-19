---@meta _
---@diagnostic disable: lowercase-global


BOON_RECHARGE_HOOKS = {
	PoseidonIntermittentClearCast = { Key = 'Interval', Timer = true, Trait = 'PoseidonManaBoon', Active = function(_, _, triggerArgs) return triggerArgs ~= nil and triggerArgs.Cooldown ~= nil end },
	CheckZeusManaSpawn = { Key = 'Interval', Timer = true, Trait = 'ZeusManaBoon' },
	RandomFogSpawn = { Key = 'Interval', Timer = true, Trait = 'FogDamageBonusBoon' },
	CheckDrinkSpawn = { Key = 'Interval', Timer = true, Trait = 'PowerDrinkBoon' },
	PeriodicMark = { Key = 'Interval', Timer = true, Trait = 'TimedCritVulnerabilityBoon' },
	CheckAutoRevenge = { Key = 'Cooldown', Trait = 'AutoRevengeBoon' },
	AthenaRetaliate = { Key = 'Cooldown', Trait = 'RetaliateInvulnerabilityBoon' },
	HadesRetaliate = { Key = 'Cooldown', Trait = 'HadesInvisibilityRetaliateBoon', AddsPostHaste = true },
	CheckAthenaProjectile = { Key = 'Cooldown', Trait = 'AthenaProjectileBoon' },
}


function boon_recharge_multiplier()
	return game.GetTotalHeroTraitValue('OlympianRechargeMultiplier', { IsMultiplier = true })
end


function boon_recharge(seconds, opts)
	if type(seconds) ~= 'number' or seconds <= 0 then return seconds end
	opts = opts or {}

	local multiplier = opts.Multiplier or boon_recharge_multiplier()
	if multiplier <= 0 then return seconds end

	if opts.Timer and chain_reaction_fires_early() then
		return math.min(seconds, mod.tuning.ChainReaction.EarlyFireDelay / multiplier)
	end

	return seismic_hammer_recharge(seconds, multiplier, opts)
end


local function recharge_floor(node, key, depth)
	if type(node) ~= 'table' or depth > 6 then return nil end

	local value = rawget(node, key)
	if type(value) == 'table' and type(value.MinimumSourceValue) == 'number' then return value.MinimumSourceValue end

	for _, child in pairs(node) do
		local floor = recharge_floor(child, key, depth + 1)
		if floor then return floor end
	end
end


local source_floors = {}

function boon_recharge_source_floor(traitName, key)
	local template = traitName and game.TraitData[traitName]
	if not template then return nil end

	local id = traitName .. '.' .. key
	if source_floors[id] == nil then source_floors[id] = recharge_floor(template, key, 0) or false end
	return source_floors[id] or nil
end


local function recharge_value(raw, hook)
	local multiplier = boon_recharge_multiplier()
	if hook.AddsPostHaste and not boon_edit_on('PostHaste') then multiplier = 1 end

	local opts = {
		Multiplier = multiplier,
		Timer = hook.Timer,
		SourceFloor = boon_recharge_source_floor(hook.Trait, hook.Key),
	}
	local seconds = boon_recharge(raw, opts)
	if hook.AddsPostHaste then return seconds * multiplier end
	return seconds
end


local function recharge_args(args, hook)
	if type(args) ~= 'table' or type(args[hook.Key]) ~= 'number' then return args end

	return setmetatable({}, {
		__index = function(_, key)
			if key == hook.Key then return recharge_value(args[key], hook) end
			return args[key]
		end,
		__newindex = args,
		__pairs = function() return next, args, nil end,
	})
end


once('BoonRecharges', function()
	for name in pairs(BOON_RECHARGE_HOOKS) do
		modutil.mod.Path.Wrap(name, function(base, first, args, ...)
			local hook = BOON_RECHARGE_HOOKS[name]
			if not hook then return base(first, args, ...) end
			if hook.Active and not hook.Active(first, args, ...) then return base(first, args, ...) end
			return base(first, recharge_args(args, hook), ...)
		end)
	end
end)


game.BoonEditRecharge = boon_recharge
