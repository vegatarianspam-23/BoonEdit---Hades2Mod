---@meta _


local EXTRA_DOSE_TRAIT = 'DoubleStrikeChanceBoon'

local EXTRA_DOSE_PROPERTIES = {
	AdditionalProjectileWaveChance = true,
	ProjectileWaveInterval = true,
}


once('ExtraDoseCoversSpecial', function()
	if not boon_edit_on('ExtraDose') then return end

	local specials = game.AddLinkedWeapons(game.WeaponSets.HeroSecondaryWeapons)

	for _, change in ipairs(game.TraitData[EXTRA_DOSE_TRAIT].PropertyChanges or {}) do
		if change.WeaponNames and EXTRA_DOSE_PROPERTIES[change.WeaponProperty] then
			local named = game.ToLookup(change.WeaponNames)

			for _, weaponName in ipairs(specials) do
				if not named[weaponName] then
					table.insert(change.WeaponNames, weaponName)
				end
			end
		end
	end
end)
