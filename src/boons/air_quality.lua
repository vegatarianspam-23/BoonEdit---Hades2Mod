---@meta _


local function air_quality_floor(attacker, triggerArgs)
	if not boon_edit_on('AirQuality') then return nil end
	if attacker == nil or attacker ~= game.CurrentRun.Hero then return nil end

	local sourceEffectData = triggerArgs and triggerArgs.EffectName and game.EffectData[triggerArgs.EffectName]
	if sourceEffectData and sourceEffectData.BlockDamageFloor then return nil end

	local airQuality = game.GetHeroTrait('ElementalDamageFloorBoon')
	local floor = airQuality and airQuality.BoonEditBaseDamageFloor
	if not floor then return nil end

	if airQuality.ActivationRequirements and not game.IsGameStateEligible(airQuality, airQuality.ActivationRequirements) then
		return nil
	end

	return floor
end


once('AirQualityAdditiveFloor', function()
	if boon_edit_on('AirQuality') then
		local airQuality = game.TraitData.ElementalDamageFloorBoon
		airQuality.BoonEditBaseDamageFloor = airQuality.ActivatedDamageFloor
		airQuality.ActivatedDamageFloor = nil
		airQuality.ExtractValues[1].Key = 'BoonEditBaseDamageFloor'
	end

	modutil.mod.Path.Wrap("CalculateBaseDamage", function(base, attacker, victim, triggerArgs)
		local damage = base(attacker, victim, triggerArgs)

		if triggerArgs and type(damage) == 'number' and damage > 0 and air_quality_floor(attacker, triggerArgs) then
			triggerArgs.BoonEditBaseDamage = damage
		end

		return damage
	end)

	modutil.mod.Path.Wrap("CalculateBaseDamageAdditions", function(base, attacker, victim, triggerArgs)
		local addition = base(attacker, victim, triggerArgs)

		local damage = triggerArgs and triggerArgs.BoonEditBaseDamage
		if type(damage) ~= 'number' or type(addition) ~= 'number' then return addition end

		local floor = air_quality_floor(attacker, triggerArgs)
		if not floor then return addition end

		local total = damage + addition
		if total >= floor then return addition end

		return addition + (floor - total)
	end)
end)
