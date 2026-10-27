---@meta _


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


local function scythe_slows_apply(projectileId, scythe, zoneFactor)
	local speed = scythe.BaseSpeed * scythe.ShotMultiplier * zoneFactor
	if scythe.Applied == speed then return end

	scythe.Applied = speed
	game.SetProjectileProperty({ ProjectileId = projectileId, Property = 'Speed', Value = speed })
end


function scythe_slows_spawned(projectileId, args)
	if not boon_edit_on('ScytheSlows') then return end
	if not projectileId or not args or not args.Name then return end

	local state = scythe_slows_state()

	if game.Contains(mod.tuning.ScytheSlows.Projectiles, args.Name) then
		local baseSpeed = args.DataProperties and args.DataProperties.Speed
			or game.GetBaseDataValue({ Type = 'Projectile', Name = args.Name, Property = 'Speed' })
		if type(baseSpeed) ~= 'number' then return end

		local scythe = { BaseSpeed = baseSpeed, ShotMultiplier = args.SpeedMultiplier or 1 }
		state.Scythes[projectileId] = scythe
		scythe_slows_apply(projectileId, scythe, 1)

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
		else
			alive = true
			scythe_slows_apply(projectileId, scythe, inside[projectileId] or 1)
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
