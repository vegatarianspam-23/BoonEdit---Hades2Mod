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


function ionic_gain_regen()
	local tuning = mod.tuning.IonicGain
	local carried = 0

	while ionic_gain_active() do
		local nearest = nil
		if ionic_gain_held() then
			local _, distance = ionic_gain_font(game.CurrentRun.Hero.ObjectId)
			nearest = distance
		end

		if nearest and nearest <= tuning.Range then
			local rate = ionic_gain_rate()
			if rate > 0 then

				carried = carried + rate * tuning.Interval
				local whole = math.floor(carried)
				if whole > 0 then
					carried = carried - whole
					game.ManaDelta(whole, { Silent = false, SWuManaDrip = true })
				end
			end
		else
			carried = 0
		end

		game.wait(tuning.Interval, game.RoomThreadName)
	end
end


local function ionic_gain_target(fontId)
	local range = mod.tuning.IonicGain.StrikeRange
	local candidates = {}

	for _, unit in pairs(game.ActiveEnemies or {}) do
		if unit and unit.ObjectId and not unit.IsDead and not is_allied_summon(unit) then
			local distance = game.GetDistance({ Id = unit.ObjectId, DestinationId = fontId })
			if distance and distance <= range then
				table.insert(candidates, unit)
			end
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


function ionic_gain_strikes()
	local tuning = mod.tuning.IonicGain

	while ionic_gain_active() do
		local fontId = ionic_gain_held() and ionic_gain_font(game.CurrentRun.Hero.ObjectId)

		local victim = fontId and ionic_gain_target(fontId)
		if victim then
			ionic_gain_bolt(victim)
		end

		local recharge = game.GetTotalHeroTraitValue('OlympianRechargeMultiplier', { IsMultiplier = true })
		game.wait(tuning.StrikeInterval * recharge, game.RoomThreadName)
	end
end


function ionic_gain_start()
	if not ionic_gain_on() then return end
	if not in_run() then return end

	logged = nil
	game.thread(ionic_gain_regen)
	game.thread(ionic_gain_strikes)
end
