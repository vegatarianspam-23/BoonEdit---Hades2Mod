---@meta _


once('SecondWind', function()
	if boon_edit_on('SecondWind') then
		local secondWind = game.TraitData.TimeStopLastStandBoon

		secondWind.MoneyShieldData = nil

		secondWind.PropertyChanges = {}
		for _, weaponName in ipairs({
			'WeaponCast',
			'WeaponAnywhereCast',
			'WeaponCastLob',
			'WeaponCastProjectile',
			'WeaponCastProjectileHades',
		}) do
			table.insert(secondWind.PropertyChanges, {
				WeaponName = weaponName,
				WeaponProperty = 'ActiveProjectileCap',
				ChangeValue = mod.tuning.SecondWind.ExtraCasts,
				ChangeType = 'Add',
			})
		end

		table.insert(secondWind.PropertyChanges, {
			WeaponName = 'WeaponBlink',
			WeaponProperty = 'ClipSize',
			ChangeValue = mod.tuning.SecondWind.ExtraDashes,
			ChangeType = 'Add',
			ExcludeLinked = true,
		})

		table.insert(secondWind.PropertyChanges, {
			WeaponName = 'WeaponBlink',
			WeaponProperty = 'ClipRegenInterval',
			ChangeValue = mod.tuning.SecondWind.DashRechargeMultiplier,
			ChangeType = 'Multiply',
			ExcludeLinked = true,
		})

		table.insert(secondWind.PropertyChanges, {
			WeaponName = 'WeaponBlink',
			WeaponProperty = 'Cooldown',
			ChangeValue = mod.tuning.SecondWind.DashCooldownMultiplier,
			ChangeType = 'Multiply',
			ExcludeLinked = true,
		})

		secondWind.FlavorText = 'BoonEditSecondWindFlavorText'
		secondWind.StatLines = {}
		secondWind.ExtractValues = {}

		game.HeroData.HermesData.RarityChances.Legendary = game.HeroData.BoonData.RarityChances.Legendary
	end

	modutil.mod.Path.Wrap("DemeterCastBlast", function(base, weaponData, traitArgs, triggerArgs)
		second_wind_extend_nova(traitArgs)
		return base(weaponData, traitArgs, triggerArgs)
	end)
end)


function second_wind_extend_nova(traitArgs)
	if not boon_edit_on('SecondWind') then return end
	if not traitArgs then return end
	if not game.CurrentRun or not game.CurrentRun.Hero then return end
	if not game.HeroHasTrait('TimeStopLastStandBoon') then return end

	traitArgs.MaxProjectiles = (traitArgs.MaxProjectiles or 1) + mod.tuning.SecondWind.ExtraCasts
end


function second_wind_keepsake()
	return boon_edit_on('SecondWind') and game.HeroHasTrait('TimedBuffKeepsake')
end


once('SecondWindKeepsake', function()
	modutil.mod.Path.Wrap("HasTraitRequirements", function(base, traitName)
		if traitName == 'TimeStopLastStandBoon' and second_wind_keepsake() then return true end
		return base(traitName)
	end)

	modutil.mod.Path.Wrap("GetPriorityDependentTraits", function(base, lootData)
		local linked = base(lootData)
		if not boon_edit_on('SecondWind') or second_wind_keepsake() then return linked end

		for index = #(linked or {}), 1, -1 do
			if linked[index].TraitName == 'TimeStopLastStandBoon' then
				table.remove(linked, index)
			end
		end
		return linked
	end)
end)
