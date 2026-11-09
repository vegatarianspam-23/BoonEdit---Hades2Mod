---@meta _
---@diagnostic disable: lowercase-global


local zoneFactors = {}


once('ScytheSlows', function()
	modutil.mod.Path.Wrap('CreateProjectileFromUnit', function(base, args)
		local projectileId = base(args)
		scythe_slows_spawned(projectileId, args)
		return projectileId
	end)
end)


local function scythe_slows_state()
	local state = game.SessionMapState.BoonEditScytheSlows
	if not state then
		state = { Scythes = {}, Zones = {}, Running = false }
		game.SessionMapState.BoonEditScytheSlows = state
	end
	return state
end


local function scythe_slows_zone_factor(name)
	local cached = zoneFactors[name]
	if cached == nil then
		local ok, value = pcall(game.GetBaseDataValue, {
			Type = 'Projectile',
			Name = name,
			Property = 'SpeedMultiplierOfEnemyProjectilesInside',
		})
		cached = ok and type(value) == 'number' and value < 1 and value or false
		zoneFactors[name] = cached
	end
	return cached or nil
end


local function scythe_slows_debug(message)
	if mod.tuning.ScytheSlows.Debug then
		print('[' .. _PLUGIN.guid .. '] ScytheSlows: ' .. message)
	end
end


local function scythe_slows_set_clock(projectileId, value)
	game.SetThingProperty({
		Property = 'ElapsedTimeMultiplier',
		Value = value,
		ValueChangeType = 'Absolute',
		DataValue = false,
		DestinationId = projectileId,
	})
end


local function scythe_slows_apply(projectileId, scythe, zoneFactor)
	local world = game.GetGameplayElapsedTimeMultiplier()

	if zoneFactor then
		scythe_slows_set_clock(projectileId, world * zoneFactor)
		if scythe.Factor ~= zoneFactor then
			scythe_slows_debug(scythe.Name .. ' ' .. projectileId .. ' slowed to ' .. zoneFactor .. 'x (world ' .. world .. 'x)')
		end
		scythe.Factor = zoneFactor
	elseif scythe.Factor then
		scythe_slows_set_clock(projectileId, world)
		scythe_slows_debug(scythe.Name .. ' ' .. projectileId .. ' back to normal (world ' .. world .. 'x)')
		scythe.Factor = nil
	end
end


function scythe_slows_spawned(projectileId, args)
	if not boon_edit_on('ScytheSlows') then return end
	if not projectileId or not args or not args.Name then return end

	local state = scythe_slows_state()

	if game.Contains(mod.tuning.ScytheSlows.Projectiles, args.Name) then
		state.Scythes[projectileId] = { Name = args.Name }
		scythe_slows_debug(args.Name .. ' ' .. projectileId .. ' thrown')

		if not state.Running then
			state.Running = true
			game.thread(scythe_slows_loop, state)
		end
		return
	end

	local factor = scythe_slows_zone_factor(args.Name)
	if factor then state.Zones[projectileId] = factor end
end


function scythe_slows_tick(state)
	local inside = {}

	for zoneId, factor in pairs(state.Zones) do
		if not game.ProjectileExists({ Id = zoneId }) then
			state.Zones[zoneId] = nil
		else
			local found = game.GetInProjectilesBlast({
				ProjectileId = zoneId,
				DestinationNames = mod.tuning.ScytheSlows.Projectiles,
				UseDamageRadius = true,
			})
			for _, projectileId in pairs(found or {}) do
				if not inside[projectileId] or factor < inside[projectileId] then
					inside[projectileId] = factor
				end
			end
		end
	end

	local alive = false
	for projectileId, scythe in pairs(state.Scythes) do
		if not game.ProjectileExists({ Id = projectileId }) then
			state.Scythes[projectileId] = nil
			scythe_slows_debug(scythe.Name .. ' ' .. projectileId .. ' gone')
		else
			alive = true
			scythe_slows_apply(projectileId, scythe, inside[projectileId])
		end
	end

	return alive
end


function scythe_slows_loop(state)
	while boon_edit_on('ScytheSlows') and scythe_slows_tick(state) do
		game.wait(mod.tuning.ScytheSlows.Interval, game.RoomThreadName)
	end
	state.Running = false
end
