---@meta _


once('GloriousDisasterAxe', function()
	if not boon_edit_on('GloriousDisaster') then return end

	local disaster = game.TraitData.ApolloSecondStageCastBoon

	disaster.OnEarlyCastDetonation = {
		FunctionName = _PLUGIN.guid .. '.GloriousDisasterEarlyDetonation',
	}

	disaster.BoonEditBoltDamage = mod.tuning.GloriousDisaster.BoltDamage
	for _, extract in ipairs(disaster.ExtractValues or {}) do
		if extract.ExtractAs == 'Damage' then
			extract.Key = 'BoonEditBoltDamage'
			extract.External = nil
			extract.BaseType = nil
			extract.BaseName = nil
			extract.BaseProperty = nil
		end
	end
end)


once('GloriousDisasterDamage', function()
	modutil.mod.Path.Wrap("CalculateDamageMultipliers", function(base, attacker, victim, weaponData, triggerArgs)
		return base(attacker, victim, weaponData, triggerArgs) * glorious_disaster_damage_scale(triggerArgs)
	end)
end)


function glorious_disaster_damage_scale(triggerArgs)
	if not boon_edit_on('GloriousDisaster') then return 1 end
	return projectile_damage_scale(triggerArgs, 'ZeusApolloSynergyStrike', mod.tuning.GloriousDisaster.BoltDamage)
end


function glorious_disaster_supercharged()
	return boon_edit_on('GloriousDisaster')
end


once('GloriousDisasterAlwaysSupercharged', function()
	if not glorious_disaster_supercharged() then return end

	modutil.mod.Path.Wrap("CheckArmedApolloCast", function(base, triggerArgs, functionArgs)
		if game.HeroHasTrait('ApolloSecondStageCastBoon') and game.HeroHasTrait('ApolloExCastBoon') then
			game.SessionMapState.SuperchargeCast = true
		end
		return base(triggerArgs, functionArgs)
	end)

	local disaster = game.TraitData.ApolloSecondStageCastBoon

	local arm = disaster.WeaponDataOverride and disaster.WeaponDataOverride.WeaponCastArm
	if arm and arm.ChargeWeaponStages then
		for index = #arm.ChargeWeaponStages, 2, -1 do
			table.remove(arm.ChargeWeaponStages, index)
		end
	end

	disaster.ChargeStageModifiers = nil

	for _, change in ipairs(disaster.PropertyChanges or {}) do
		if change.WeaponProperty == 'ForceMaxChargeRelease' then
			change.ChangeValue = true
		end
	end
end)


---@diagnostic disable-next-line: unused-local
function mod.GloriousDisasterEarlyDetonation(projectileId, _args)
	if not boon_edit_on('GloriousDisaster') then return end

	if not game.HeroHasTrait('ApolloExCastBoon') then return end

	local marked = game.SessionMapState and game.SessionMapState.ValidSuperchargeCastIds
	if marked and projectileId then
		marked[projectileId] = true
	end
end
