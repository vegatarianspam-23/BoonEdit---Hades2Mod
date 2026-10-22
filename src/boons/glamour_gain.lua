---@meta _


once('GlamourGainPulse', function()
	if not boon_edit_on('GlamourGain') then return end

	local glamour = game.TraitData.AphroditeManaBoon

	glamour.SetupFunction.Name = _PLUGIN.guid .. '.GlamourGainPulse'

	glamour.SetupFunction.RequiredContext = nil

	glamour.SetupFunction.Args.Interval = game.EffectData.WeakEffect.EffectData.Duration

	glamour.SetupFunction.Args.ActiveFx = nil
	glamour.SetupFunction.Args.ManaRegenStartFx = nil

	glamour.StatLines = { 'BoonEditGlamourManaStatDisplay' }
end)


local GLAMOUR_PULSE_FX = 'AphroditeDashNova'

local GLAMOUR_UNLIMITED_RANGE = 3000

function glamour_pulse_active()
	if training_grounds() then return true end

	local room = game.CurrentRun and game.CurrentRun.CurrentRoom
	if not room then return false end
	if game.IsCombatEncounterActive(game.CurrentRun) then return true end
	if not room.Encounter then return true end
	if room.Encounter.DelayedStart and room.Encounter.StartTime then return true end
	return not game.IsEmpty(game.MapState.AggroedUnits)
end

function mod.GlamourGainPulse(hero, args)
	local interval = (args and args.Interval) or 1
	local carried = 0

	while game.CurrentRun and game.CurrentRun.CurrentRoom and hero_live()
		and game.HeroHasTrait('AphroditeManaBoon') do

		if glamour_pulse_active() then
			local range = args.Range
			if game.HeroHasTrait(args.ProximityThresholdExclusionBoon) then
				range = GLAMOUR_UNLIMITED_RANGE
			end

			local nearby = game.GetClosestIds({
				Id = game.CurrentRun.Hero.ObjectId,
				DestinationName = 'EnemyTeam',
				IgnoreInvulnerable = true,
				StopsProjectiles = true,
				IgnoreHomingIneligible = true,
				IgnoreSelf = true,
				Distance = range,
				PreciseCollision = true,
			})

			local struck = 0
			for _, id in pairs(nearby) do
				local enemy = game.ActiveEnemies[id]
				if enemy and not enemy.IsDead and not boon_ignores(enemy) then
					game.ApplyEffect({
						Id = game.CurrentRun.Hero.ObjectId,
						DestinationId = enemy.ObjectId,
						EffectName = args.EffectName,
						DataProperties = game.EffectData[args.EffectName].EffectData,
					})
					struck = struck + 1
				end
			end

			if struck > 0 then
				game.CreateAnimation({
					Name = GLAMOUR_PULSE_FX,
					DestinationId = game.CurrentRun.Hero.ObjectId,
					ScaleRadius = args.Range,
				})

				carried = carried + args.ManaRegen * struck
				local whole = math.floor(carried)
				if whole > 0 then
					carried = carried - whole
					game.ManaDelta(whole, { Silent = false, SWuManaDrip = true })
				end
			end
		end

		game.wait(interval, game.RoomThreadName)
	end
end
