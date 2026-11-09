---@meta _


function beach_ball_rebalanced()
	return boon_edit_on('BeachBall')
end


function beach_ball_join(data)
	if not data or not data.ValidProjectiles or game.Contains(data.ValidProjectiles, 'ProjectileSprintBall') then return end

	table.insert(data.ValidProjectiles, 'ProjectileSprintBall')
	if data.ValidProjectilesLookup then
		data.ValidProjectilesLookup.ProjectileSprintBall = true
	end
end


once('BeachBallCone', function()
	if not beach_ball_rebalanced() then return end

	local ball = game.TraitData.PoseidonSplashSprintBoon
	if not ball then return end

	ball.OnProjectileDeathFunction = {
		Name = _PLUGIN.guid .. '.BeachBallWaves',
		ValidProjectiles = { 'ProjectileSprintBall' },
		ValidProjectilesLookup = game.ToLookup({ 'ProjectileSprintBall' }),
		Args = {},
	}

	ball.BoonEditBallDamage = mod.tuning.BeachBall.BlastDamage
	for _, extract in ipairs(ball.ExtractValues or {}) do
		if extract.ExtractAs == 'Damage' then
			extract.Key = 'BoonEditBallDamage'
			extract.Format = nil
			extract.BaseType = nil
			extract.BaseName = nil
			extract.BaseProperty = nil
		end
	end

	local slope = game.TraitData.PoseidonStatusBoon
	beach_ball_join(slope and slope.OnEnemyDamagedAction)

	local tide = game.TraitData.AmplifyConeBoon
	beach_ball_join(tide and tide.AddOutgoingDamageModifiers)
end)


once('BeachBallDamage', function()
	modutil.mod.Path.Wrap("CalculateDamageMultipliers", function(base, attacker, victim, weaponData, triggerArgs)
		return base(attacker, victim, weaponData, triggerArgs) * beach_ball_damage_scale(triggerArgs)
	end)
end)


function beach_ball_damage_scale(triggerArgs)
	if not beach_ball_rebalanced() then return 1 end
	return projectile_damage_scale(triggerArgs, 'ProjectileSprintBall', mod.tuning.BeachBall.BlastDamage)
end


once('BeachBallSize', function()
	modutil.mod.Path.Wrap("PoseidonSprintBlastDetach", function(base, ...)
		beach_ball_size_launch()
		return base(...)
	end)
end)


function beach_ball_size_launch()
	if not beach_ball_rebalanced() then return end

	local ball = game.MapState.AttachedBallProjectileId
	if not ball or ball < 0 then return end

	beach_ball_tide(ball)
end


function beach_ball_tide(projectileId)
	if not beach_ball_rebalanced() or not projectileId then return end

	local scale = poseidon_splash_scale()
	if scale == 1 then return end

	local base = game.GetBaseDataValue({ Type = 'Projectile', Name = 'ProjectileSprintBall', Property = 'DamageRadius' })
	if type(base) ~= 'number' or base <= 0 then return end

	game.SetProjectileProperty({ ProjectileId = projectileId, Property = 'DamageRadius', Value = base * scale })
end


function beach_ball_blast_radius(triggerArgs)
	local radius = triggerArgs.ProjectileId and game.GetProjectileProperty({
		ProjectileId = triggerArgs.ProjectileId,
		Property = 'ModifiedDamageRadius',
	})
	if type(radius) == 'number' and radius > 0 then return radius end

	return mod.tuning.BeachBall.BlastRadius * poseidon_splash_scale()
end


---@diagnostic disable-next-line: unused-local
function mod.BeachBallWaves(triggerArgs, _args)
	if not beach_ball_rebalanced() then return end
	if not triggerArgs or not triggerArgs.LocationX or not triggerArgs.LocationY then return end

	poseidon_circle_splash({
		X = triggerArgs.LocationX,
		Y = triggerArgs.LocationY,
		Radius = beach_ball_blast_radius(triggerArgs),
		Damage = mod.tuning.BeachBall.BlastDamage,
		From = 2,
	})
end


once('BeachBallDash', function()
	modutil.mod.Path.Wrap("DashManeuver", function(base, ...)
		local result = base(...)
		beach_ball_dash_start()
		return result
	end)

	modutil.mod.Path.Wrap("CheckDashManeuverEnd", function(base, ...)
		local token = game.MapState.BoonEditDashBallToken
		local result = base(...)
		beach_ball_dash_end(token)
		return result
	end)
end)


local function beach_ball_dash_ready()
	if not beach_ball_rebalanced() or not mod.tuning.BeachBall.FireOnDash then return false end
	if not game.CurrentRun or not game.CurrentRun.Hero then return false end
	if not game.IsEmpty(game.MapState.TransformArgs) then return false end
	return game.HeroHasTrait('PoseidonSplashSprintBoon')
end

local function beach_ball_launch()
	game.MapState.BoonEditDashBall = nil
	local ball = game.MapState.AttachedBallProjectileId
	if not ball or ball < 0 or game.SessionMapState.SprintActive then return end
	game.thread(game.PoseidonSprintBlastDetach)
end

function beach_ball_dash_start()
	if not beach_ball_dash_ready() then return end

	if game.MapState.BoonEditDashBall then beach_ball_launch() end

	local trait = game.GetHeroTrait('PoseidonSplashSprintBoon')
	local fired = trait and trait.OnWeaponFiredFunctions
	if not fired or not fired.FunctionArgs then return end

	local token = (game.MapState.BoonEditDashBallToken or 0) + 1
	game.MapState.BoonEditDashBallToken = token
	if not game.SessionMapState.SprintActive then
		game.MapState.BoonEditDashBall = token
	end

	game.PoseidonSprintBall(game.GetWeaponData(game.CurrentRun.Hero, 'WeaponSprint'), fired.FunctionArgs, {})
end

function beach_ball_dash_end(token)
	local mark = game.MapState.BoonEditDashBall
	if not mark or mark ~= token or token ~= game.MapState.BoonEditDashBallToken then return end
	if game.SessionMapState.SprintActive then
		game.MapState.BoonEditDashBall = nil
		return
	end
	beach_ball_launch()
end
