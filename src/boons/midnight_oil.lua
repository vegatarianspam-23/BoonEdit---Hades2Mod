---@meta _
---@diagnostic disable: lowercase-global


MIDNIGHT_OIL_TRAIT = 'BoonEditMidnightOilBoon'


once('MidnightOil', function()
	if not game.TraitData[MIDNIGHT_OIL_TRAIT] then
		local tuning = mod.tuning.MidnightOil
		local rarities = {}
		for rarity, multiplier in pairs(tuning.Rarities) do
			rarities[rarity] = { Multiplier = multiplier }
		end

		local trait = {
			Name = MIDNIGHT_OIL_TRAIT,
			Icon = tuning.Icon,
			Cost = game.TraitData.BaseTrait.Cost,
			Elements = { tuning.Element },
			RarityLevels = rarities,
			BoonEditMidnightOil = { BaseValue = tuning.Saving },
			StatLines = { 'BoonEditMidnightOilStatDisplay' },
			ExtractValues = {
				{ Key = 'BoonEditMidnightOil', ExtractAs = 'TooltipMidnightOil', Format = 'Percent' },
			},
		}
		trait.TraitOrderingValueCache = game.GetTraitOrderingValue(trait)

		game.TraitData[MIDNIGHT_OIL_TRAIT] = trait
	end

	modutil.mod.Path.Wrap('GetManaSpendCost', function(base, weaponData)
		return midnight_oil_cost(base(weaponData), weaponData)
	end)
end)


local function midnight_oil_hex_weapon()
	local hero = game.CurrentRun and game.CurrentRun.Hero
	for _, trait in pairs(hero and hero.Traits or {}) do
		if trait.Slot == 'Spell' and trait.PreEquipWeapons then return trait.PreEquipWeapons[1] end
	end
	return nil
end


function midnight_oil_saving()
	local saving = game.GetTotalHeroTraitValue('BoonEditMidnightOil') or 0
	if saving <= 0 then return 0 end
	return math.min(saving, mod.tuning.MidnightOil.MaxSaving)
end


function midnight_oil_cost(cost, weaponData)
	if type(cost) ~= 'number' or cost <= 0 or not weaponData then return cost end
	if not boon_edit_on('MidnightOil') or not game.CurrentRun or not game.HeroHasTrait(MIDNIGHT_OIL_TRAIT) then return cost end
	if weaponData.Name ~= midnight_oil_hex_weapon() then return cost end
	return cost * (1 - midnight_oil_saving())
end
