---@meta _


function beach_ball_rebalanced()
	return boon_edit_on('BeachBall')
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

	local slope = game.TraitData.PoseidonStatusBoon
	local froth = slope and slope.OnEnemyDamagedAction
	if froth and froth.ValidProjectiles and not game.Contains(froth.ValidProjectiles, 'ProjectileSprintBall') then
		table.insert(froth.ValidProjectiles, 'ProjectileSprintBall')
		if froth.ValidProjectilesLookup then
			froth.ValidProjectilesLookup.ProjectileSprintBall = true
		end
	end
end)


---@diagnostic disable-next-line: unused-local
function mod.BeachBallWaves(triggerArgs, _args)
	if not beach_ball_rebalanced() then return end
	if not triggerArgs or not triggerArgs.LocationX or not triggerArgs.LocationY then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	local scale, count, graphic = poseidon_splash_cone(mod.tuning.PoseidonSplash.RedNova)
	if count < 2 then return end

	local tuning = mod.tuning.BeachBall

	local anchor = game.SpawnObstacle({
		Name = 'BlankObstacle',
		LocationX = triggerArgs.LocationX,
		LocationY = triggerArgs.LocationY,
	})
	if not anchor then return end

	local base = game.GetBaseDataValue({
		Type = 'Projectile',
		Name = tuning.WaveProjectile,
		Property = 'Damage',
	})
	if type(base) ~= 'number' or base <= 0 then base = 60 end

	local last = 0

	arterial_spray_begin({ ProjectileName = tuning.WaveProjectile })

	local ok, err = pcall(function()
		for index = 2, count do
			last = (index - 1) * mod.tuning.PoseidonSplash.WaveDelay

			game.CreateProjectileFromUnit({
				Name = tuning.WaveProjectile,
				Id = hero.ObjectId,
				DestinationId = anchor,
				FireFromTarget = true,
				DamageMultiplier = tuning.BlastDamage / base,
				ScaleMultiplier = scale,
				DataProperties = {
					DamageRadius = tuning.BlastRadius * scale,
					StartFx = graphic,
					StartDelay = last,
				},
			})
		end
	end)

	arterial_spray_end()

	game.thread(game.DestroyOnDelay, { anchor }, last + mod.tuning.PoseidonSplash.WaveDelay)
	if not ok then error(err) end
end
