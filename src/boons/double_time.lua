---@meta _


DOUBLE_TIME_CASTS = {
	'WeaponCast',
	'WeaponAnywhereCast',
	'WeaponCastLob',
	'WeaponCastProjectile',
	'WeaponCastProjectileHades',
}


DOUBLE_TIME_TRAIT = 'BoonEditSecondWindBoon'


once('DoubleTime', function()
	if not game.TraitData[DOUBLE_TIME_TRAIT] then
		local propertyChanges = {}
		for _, weaponName in ipairs(DOUBLE_TIME_CASTS) do
			table.insert(propertyChanges, {
				WeaponName = weaponName,
				WeaponProperty = 'ActiveProjectileCap',
				ChangeValue = mod.tuning.DoubleTime.ExtraCasts,
				ChangeType = 'Add',
			})
		end

		for weaponName, projectileName in pairs(mod.tuning.DoubleTime.InFlightCasts) do
			table.insert(propertyChanges, {
				WeaponName = weaponName,
				WeaponProperty = 'ExcludeInProjectileCap',
				ChangeValue = projectileName,
				ChangeType = 'Absolute',
			})
		end

		table.insert(propertyChanges, {
			WeaponName = 'WeaponBlink',
			WeaponProperty = 'ClipSize',
			ChangeValue = mod.tuning.DoubleTime.ExtraDashes,
			ChangeType = 'Add',
			ExcludeLinked = true,
		})

		table.insert(propertyChanges, {
			WeaponName = 'WeaponBlink',
			WeaponProperty = 'ClipRegenInterval',
			ChangeValue = mod.tuning.DoubleTime.DashRechargeMultiplier,
			ChangeType = 'Multiply',
			ExcludeLinked = true,
		})

		table.insert(propertyChanges, {
			WeaponName = 'WeaponBlink',
			WeaponProperty = 'Cooldown',
			ChangeValue = mod.tuning.DoubleTime.DashCooldownMultiplier,
			ChangeType = 'Multiply',
			ExcludeLinked = true,
		})

		local doubleTime = boon_edit_new_legendary(DOUBLE_TIME_TRAIT, mod.tuning.DoubleTime.Icon, mod.tuning.DoubleTime.Element)
		doubleTime.PropertyChanges = propertyChanges
		doubleTime.FlavorText = 'BoonEditDoubleTimeFlavorText'
		doubleTime.StatLines = {}
		doubleTime.ExtractValues = {}
		doubleTime.TraitOrderingValueCache = game.GetTraitOrderingValue(doubleTime)
		game.TraitData[DOUBLE_TIME_TRAIT] = doubleTime
	end

	if boon_edit_on('DoubleTime') then
		game.HeroData.HermesData.RarityChances.Legendary = game.HeroData.BoonData.RarityChances.Legendary
	end

	modutil.mod.Path.Wrap("DemeterCastBlast", function(base, weaponData, traitArgs, triggerArgs)
		double_time_extend_nova(traitArgs)
		return base(weaponData, traitArgs, triggerArgs)
	end)
end)


function double_time_extend_nova(traitArgs)
	if not boon_edit_on('DoubleTime') then return end
	if not traitArgs then return end
	if not game.CurrentRun or not game.CurrentRun.Hero then return end
	if not game.HeroHasTrait(DOUBLE_TIME_TRAIT) then return end

	traitArgs.MaxProjectiles = (traitArgs.MaxProjectiles or 1) + mod.tuning.DoubleTime.ExtraCasts
end

