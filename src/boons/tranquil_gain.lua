---@meta _


once('TranquilGainChannel', function()
	if not boon_edit_on('TranquilGain') then return end

	local tranquil = game.TraitData.DemeterManaBoon

	tranquil.SetupFunction.Args.MovePenaltyDuration = mod.tuning.TranquilGain.HoldSeconds
	tranquil.SetupFunction.Name = _PLUGIN.guid .. '.TranquilGainChannel'

	tranquil.SetupFunction.Threaded = true
	tranquil.SetupFunction.RunOnce = nil
end)


local TRANQUIL_POLL_INTERVAL = (game.HeroData and game.HeroData.ManaData and game.HeroData.ManaData.MinManaTickRate) or 0.05

function tranquil_gain_channelling()
	return not game.IsEmpty(game.MapState.ChargedManaWeapons or {})
end


local function tranquil_gain_staged(hero, weaponName)
	if (game.MapState.WeaponCharge or {})[weaponName] ~= nil then return true end

	local data = game.GetWeaponData(hero, weaponName)
	for _, functionName in ipairs((data or {}).OnChargeFunctionNames or {}) do
		if functionName == 'DoWeaponCharge' then return true end
	end
	return false
end


local function tranquil_gain_scale(hero, weaponName)
	local multiplier = game.GetLuaWeaponSpeedMultiplier(weaponName) or 1
	if tranquil_gain_staged(hero, weaponName) then return multiplier end

	local current = game.GetWeaponDataValue({ Id = hero.ObjectId, WeaponName = weaponName, Property = 'ChargeTime' })
	local baseCharge = game.GetBaseDataValue({ Type = 'Weapon', Name = weaponName, Property = 'ChargeTime' })
	if not current or not baseCharge or baseCharge <= 0 then return nil end

	multiplier = multiplier * (current / baseCharge)
	for _, value in pairs((game.SessionMapState or {}).GlobalAttackSpecialSpeed or {}) do
		multiplier = multiplier * value
	end
	return multiplier
end


local function tranquil_gain_hold(base)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or base <= 0 then return base end

	local fastest = nil
	for weaponName in pairs(game.MapState.ChargedManaWeapons or {}) do
		local scale = tranquil_gain_scale(hero, weaponName)
		if scale and (not fastest or scale < fastest) then fastest = scale end
	end

	if not fastest then return base end

	return base * fastest
end


local function tranquil_gain_charged()
	local reached = game.MapState.WeaponCharge or {}
	for weaponName in pairs(game.MapState.ChargedManaWeapons or {}) do
		if (reached[weaponName] or 0) >= 1 then return true end
	end
	return false
end

function tranquil_gain_stop(args)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end
	if args and args.ManaRegenStartFx then
		game.StopAnimation({ Name = args.ManaRegenStartFx, DestinationId = hero.ObjectId })
	end
end

function mod.TranquilGainChannel(hero, args)
	local hold = (args and args.MovePenaltyDuration) or 0
	local channelled = 0
	local carried = 0
	local flowing = false

	while game.CurrentRun and game.CurrentRun.CurrentRoom and hero_live()
		and game.HeroHasTrait('DemeterManaBoon') do

		if tranquil_gain_channelling() then
			channelled = channelled + TRANQUIL_POLL_INTERVAL

			if channelled >= tranquil_gain_hold(hold) or tranquil_gain_charged() then
				if not flowing then
					flowing = true
					if args.ManaRegenStartSound then
						game.PlaySound({ Name = args.ManaRegenStartSound, Id = game.CurrentRun.Hero.ObjectId })
					end
					if args.ManaRegenStartFx then
						game.CreateAnimation({ Name = args.ManaRegenStartFx, DestinationId = game.CurrentRun.Hero.ObjectId, OffsetX = 0 })
					end
				end

				carried = carried + game.CurrentRun.Hero.MaxMana * args.PercentManaRegenPerSecond * TRANQUIL_POLL_INTERVAL
				local whole = math.floor(carried)
				if whole > 0 then
					carried = carried - whole
					game.ManaDelta(whole, { Silent = false, SWuManaDrip = true })
				end
			end
		else
			channelled = 0
			carried = 0
			if flowing then
				flowing = false
				tranquil_gain_stop(args)
			end
		end

		game.wait(TRANQUIL_POLL_INTERVAL, game.RoomThreadName)
	end

	tranquil_gain_stop(args)
end
