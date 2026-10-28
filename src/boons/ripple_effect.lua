---@meta _


once('RippleEffectOmegaBoons', function()
	if boon_edit_on('RippleEffect') then
		local ripple = game.TraitData.MoneyDamageBoon

		ripple.DoubleOlympianProjectileChance = 0

		ripple.BoonEditRepeatChance = mod.tuning.RippleEffect.RepeatChance
		ripple.StatLines = { 'BoonEditRippleRepeatStatDisplay' }
		ripple.BoonEditMaxRepeats = mod.tuning.RippleEffect.MaxRepeats
		ripple.ExtractValues = {
			{
				Key = 'BoonEditRepeatChance',
				ExtractAs = 'Chance',
				Format = 'LuckModifiedPercent',
				HideSigns = true,
			},
			{ Key = 'BoonEditMaxRepeats', ExtractAs = 'TooltipMaxRepeats', SkipAutoExtract = true },
		}
	end

	modutil.mod.Path.Wrap("CreateProjectileFromUnit", function(base, args)
		local result = base(args)
		if ripple_effect_repeat then
			ripple_effect_repeat(args)
		end
		return result
	end)

	modutil.mod.Path.Wrap("PoseidonSprintBall", function(base, weaponData, traitArgs, triggerArgs)
		local charging = game.MapState.AttachedBallProjectileId and game.MapState.AttachedBallProjectileId >= 0
		local result = base(weaponData, traitArgs, triggerArgs)
		if not charging then
			game.MapState.BoonEditRippleBallStart = game._worldTimeUnmodified
		end
		return result
	end)

	modutil.mod.Path.Wrap("PoseidonSprintBlastDetach", function(base, ...)
		local ball = ripple_effect_ball_snapshot()
		local result = base(...)
		if ball then ripple_effect_ball_repeat(ball) end
		return result
	end)
end)


local RIPPLE_PROJECTILES = {
	PoseidonOmegaWave = true,
	ProjectileHeraOmega = true,
	ArtemisCastVolley = true,
	ProjectileFireball = true,
	AthenaDeflectingProjectile = true,
	ArtemisSupportingFire = true,
}


function ripple_effect_covers(name)
	return RIPPLE_PROJECTILES[name] == true
end

function ripple_effect_rolls()
	local tuning = mod.tuning.RippleEffect
	local chance = game.GetTotalHeroTraitValue('BoonEditRepeatChance')
	local repeats = 0

	while repeats < tuning.MaxRepeats and rolls(chance) do
		repeats = repeats + 1
		chance = chance * tuning.Falloff
	end

	return repeats
end


function ripple_effect_repeat(args)
	if mod.RippleFiring then return end
	if not boon_edit_on('RippleEffect') then return end
	if not args or not args.Name or not ripple_effect_covers(args.Name) then return end
	if not game.HeroHasTrait('MoneyDamageBoon') then return end


	local repeats = ripple_effect_rolls()
	if repeats <= 0 then return end

	local repeated = game.ShallowCopyTable(args)

	if repeated.ProjectileCap then
		repeated.ProjectileCap = repeated.ProjectileCap + repeats
	end

	game.thread(ripple_effect_refire, repeated, repeats)
end

function ripple_effect_ball_snapshot()
	if not boon_edit_on('RippleEffect') then return nil end
	if not game.HeroHasTrait('MoneyDamageBoon') then return nil end

	local trait = game.GetHeroTrait('PoseidonSplashSprintBoon')
	local args = trait and trait.OnWeaponFiredFunctions and trait.OnWeaponFiredFunctions.FunctionArgs
	local ballId = game.MapState.AttachedBallProjectileId
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not args or not hero or not ballId or ballId < 0 then return nil end

	local where = game.GetLocation({ Id = ballId, IsProjectile = true })
	if not where then return nil end

	local charge = 1
	local started = game.MapState.BoonEditRippleBallStart
	if started and args.ChargeRadiusTime and args.ChargeRadiusTime > 0 then
		charge = math.max(0, math.min(1, (game._worldTimeUnmodified - started) / args.ChargeRadiusTime))
	end

	return {
		Args = args,
		X = where.X,
		Y = where.Y,
		Angle = game.GetAngle({ Id = hero.ObjectId }),
		Charge = charge,
	}
end

function ripple_effect_ball_repeat(ball)
	local repeats = ripple_effect_rolls()
	if repeats <= 0 then return end

	game.thread(ripple_effect_ball_refire, ball, repeats)
end

function ripple_effect_ball_refire(ball, repeats)
	local args = ball.Args
	local interval = game.GetTotalHeroTraitValue('DoubleOlympianProjectileInterval')

	local startDamage = args.StartingDamageMultiplier or 0.25
	local damage = startDamage + ball.Charge * ((args.DamageMultiplier or 1) - startDamage)
	local scale = args.StartScale + ball.Charge * (args.EndScale - args.StartScale)
	local radius = 1 + ball.Charge * ((args.ChargeRadiusMultiplier or 1) - 1)

	for _ = 1, repeats do
		game.waitUnmodified(interval)

		local hero = game.CurrentRun and game.CurrentRun.Hero
		if not hero or hero.IsDead then return end

		local anchor = game.SpawnObstacle({ Name = 'InvisibleTarget', LocationX = ball.X, LocationY = ball.Y })
		if not anchor then return end

		mod.RippleFiring = true
		local ok, projectileId = pcall(game.CreateProjectileFromUnit, {
			Name = args.ProjectileName,
			Id = hero.ObjectId,
			DestinationId = anchor,
			FireFromTarget = true,
			Angle = ball.Angle,
			DamageMultiplier = damage,
			ScaleMultiplier = scale,
			DataProperties = { CheckUnitImpact = true, CheckObstacleImpact = true, Range = 1000 },
		})
		mod.RippleFiring = nil
		game.thread(game.DestroyOnDelay, { anchor }, 0.1)

		if not ok then
			print('[' .. _PLUGIN.guid .. '] ripple ball repeat failed: ' .. tostring(projectileId))
			return
		end
		if projectileId and radius ~= 1 then
			game.SetDamageRadiusMultiplier({ Id = projectileId, Fraction = radius, Duration = 0 })
		end
	end
end

function ripple_effect_refire(args, repeats)
	local interval = game.GetTotalHeroTraitValue('DoubleOlympianProjectileInterval')

	for _ = 1, repeats do
		game.waitUnmodified(interval)

		mod.RippleFiring = true
		local ok, err = pcall(game.CreateProjectileFromUnit, args)
		mod.RippleFiring = nil
		if not ok then
			print('[' .. _PLUGIN.guid .. '] ripple repeat failed: ' .. tostring(err))
			return
		end
	end
end
