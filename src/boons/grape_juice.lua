---@meta _


once('GrapeJuice', function()
	local drink = game.TraitData.PowerDrinkBoon
	if boon_edit_on('GrapeJuice') and drink then
		drink.BoonEditDrinkHeal = mod.tuning.GrapeJuice.Heal
		boon_edit_add_stat('PowerDrinkBoon', 'BoonEditGrapeJuiceHealStatDisplay',
			{ Key = 'BoonEditDrinkHeal', ExtractAs = 'TooltipDrinkHeal' })
	end

	modutil.mod.Path.Wrap("DrinkPickup", function(base, interactableObject, functionArgs, user)
		grape_juice_heal()
		return base(interactableObject, functionArgs, user)
	end)
end)


function grape_juice_heal()
	if not boon_edit_on('GrapeJuice') then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	local amount = mod.tuning.GrapeJuice.Heal
	if type(amount) ~= 'number' or amount <= 0 then return end

	game.Heal(hero, {
		HealAmount = game.round(amount * game.CalculateHealingMultiplier()),
		SourceName = 'PowerDrinkDrop',
	})
end
