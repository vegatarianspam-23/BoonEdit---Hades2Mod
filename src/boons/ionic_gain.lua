---@meta _


local function ionic_gain_on()
	return boon_edit_on('IonicGain')
end


local function ionic_gain_active()
	local hero = game.CurrentRun and game.CurrentRun.Hero
	return hero ~= nil and not hero.IsDead
end


local function ionic_gain_held()
	return ionic_gain_on() and game.HeroHasTrait('ZeusManaBoon')
end


local function ionic_gain_rarity()
	local trait = game.GetHeroTrait('ZeusManaBoon')
	return trait and (trait.Rarity or 'Common') or nil
end


local function ionic_gain_rate()
	local rarity = ionic_gain_rarity()
	if not rarity then return 0 end

	local tuning = mod.tuning.IonicGain
	return tuning.ManaPerSecond * (tuning.RarityScale[rarity] or 1)
end


local function ionic_gain_font(heroId)
	local nearestId, nearest = nil, nil
	for _, id in ipairs(game.GetIdsByType({ Name = 'ManaDropZeus' }) or {}) do
		local distance = game.GetDistance({ Id = heroId, DestinationId = id })
		if distance and (not nearest or distance < nearest) then
			nearestId, nearest = id, distance
		end
	end
	return nearestId, nearest
end


local function ionic_gain_ring_fonts(ringed)
	local tuning = mod.tuning.IonicGain
	if not tuning.RingFx then return end

	for _, id in ipairs(game.GetIdsByType({ Name = 'ManaDropZeus' }) or {}) do
		if not ringed[id] then
			ringed[id] = true
			game.CreateAnimation({
				Name = tuning.RingFx,
				DestinationId = id,
				ScaleRadius = tuning.Range,
			})
		end
	end
end


function ionic_gain_regen_tick(state)
	local tuning = mod.tuning.IonicGain
	local nearest = nil
	if ionic_gain_held() then
		ionic_gain_ring_fonts(state.Ringed)
		local _, distance = ionic_gain_font(game.CurrentRun.Hero.ObjectId)
		nearest = distance
	end

	if nearest and nearest <= tuning.Range then
		local rate = ionic_gain_rate()
		if rate > 0 then
			state.Carried = state.Carried + rate * tuning.Interval
			local whole = math.floor(state.Carried)
			if whole > 0 then
				state.Carried = state.Carried - whole
				game.ManaDelta(whole, { Silent = false, SWuManaDrip = true })
			end
		end
	else
		state.Carried = 0
	end

	return tuning.Interval
end


function ionic_gain_regen()
	local state = { Carried = 0, Ringed = {} }

	while ionic_gain_active() do
		game.wait(ionic_gain_regen_tick(state), game.RoomThreadName)
	end
end


local function ionic_gain_foe(unit)
	if not unit or not unit.ObjectId or unit.IsDead then return false end
	if boon_ignores(unit) or is_allied_summon(unit) then return false end
	if unit.IgnoreInvisibility or not unit.TriggersOnHitEffects then return false end

	if not game.GetThingDataValue({ Id = unit.ObjectId, Property = 'StopsProjectiles' }) then return false end
	if game.IsInvulnerable({ Id = unit.ObjectId }) then return false end
	if game.IsUntargetable({ Id = unit.ObjectId }) then return false end
	if unit.InvulnerableFlags and not game.IsEmpty(unit.InvulnerableFlags) then return false end

	return true
end


local function ionic_gain_target(fontId)
	local nearby = game.GetClosestIds({
		Id = fontId,
		DestinationName = 'EnemyTeam',
		IgnoreInvulnerable = true,
		StopsProjectiles = true,
		IgnoreHomingIneligible = true,
		Distance = mod.tuning.IonicGain.Range,
		PreciseCollision = true,
	}) or {}

	local candidates = {}
	for _, id in ipairs(nearby) do
		local unit = game.ActiveEnemies and game.ActiveEnemies[id]
		if ionic_gain_foe(unit) then
			table.insert(candidates, unit)
		end
	end

	if #candidates == 0 then return nil end
	return game.GetRandomValue(candidates)
end


local function ionic_gain_bolt(victim)
	local rarity = ionic_gain_rarity()
	local damage = rarity and mod.tuning.IonicGain.StrikeDamage[rarity]
	if type(damage) ~= 'number' or damage <= 0 then return end

	local baseDamage = game.GetBaseDataValue({ Type = 'Projectile', Name = 'ZeusEchoStrike', Property = 'Damage' })
	if type(baseDamage) ~= 'number' or baseDamage <= 0 then
		baseDamage = 100
	end

	game.CreateProjectileFromUnit({
		Name = 'ZeusEchoStrike',
		Id = game.CurrentRun.Hero.ObjectId,
		DestinationId = victim.ObjectId,
		FireFromTarget = true,
		DamageMultiplier = damage / baseDamage,
	})
end


function ionic_gain_strike_tick()
	local fontId = ionic_gain_held() and ionic_gain_font(game.CurrentRun.Hero.ObjectId)

	local victim = fontId and ionic_gain_target(fontId)
	if victim then
		ionic_gain_bolt(victim)
	end

	local recharge = game.GetTotalHeroTraitValue('OlympianRechargeMultiplier', { IsMultiplier = true })
	return mod.tuning.IonicGain.StrikeInterval * recharge
end


function ionic_gain_strikes()
	while ionic_gain_active() do
		game.wait(ionic_gain_strike_tick(), game.RoomThreadName)
	end
end


function ionic_gain_start()
	if not ionic_gain_on() then return end
	if not in_run() then return end

	logged = nil
	game.thread(ionic_gain_regen)
	game.thread(ionic_gain_strikes)
end
