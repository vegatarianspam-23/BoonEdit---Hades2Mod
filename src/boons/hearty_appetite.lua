---@meta _


local HEARTY_APPETITE = 'MaxHealthDamageBoon'


once('HeartyAppetite', function()
	if not boon_edit_on('HeartyAppetite') then return end

	local trait = game.TraitData[HEARTY_APPETITE]
	if not trait then return end

	trait.TraitHealingBonus = mod.tuning.HeartyAppetite.HealingBonus
	trait.AcquireFunctionName = _PLUGIN.guid .. '.HeartyAppetiteAcquire'
	trait.AcquireFunctionArgs = nil

	trait.CurrentRoom = 0
	trait.RoomsPerUpgrade = {
		Amount = { BaseValue = mod.tuning.HeartyAppetite.EncountersPerFood },
	}

	trait.BoonEditEncountersPerFood = mod.tuning.HeartyAppetite.EncountersPerFood

	trait.StatLines = trait.StatLines or {}
	table.insert(trait.StatLines, 'BoonEditHeartyAppetiteHealingStatDisplay')

	trait.ExtractValues = trait.ExtractValues or {}
	table.insert(trait.ExtractValues, {
		Key = 'TraitHealingBonus',
		ExtractAs = 'TooltipHealingBonus',
		Format = 'PercentDelta',
	})

	table.insert(trait.ExtractValues, {
		Key = 'BoonEditEncountersPerFood',
		ExtractAs = 'TooltipEncountersPerFood',
		SkipAutoExtract = true,
	})

	trait.CustomStatLinesWithShrineUpgrade = {
		ShrineUpgradeName = 'HealingReductionShrineUpgrade',
		StatLines = {
			'HealthDamageStatDisplay',
			'BoonEditHeartyAppetiteHealingStatDisplay',
			'HealingReductionNotice',
		},
	}

	modutil.mod.Path.Wrap("CheckChamberTraits", function(base, ...)
		base(...)
		hearty_appetite_check_food()
	end)
end)


function hearty_appetite_drop_food(count)
	local tuning = mod.tuning.HeartyAppetite
	game.wait(tuning.Delay)

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or not game.CurrentRun.CurrentRoom then return end

	local where = game.GetLocation({ Id = hero.ObjectId })

	for _ = 1, count do
		local foodId = game.SpawnObstacle({
			Name = tuning.Food,
			Group = 'Standing',
			LocationX = where.X + game.RandomFloat(-tuning.Spread, tuning.Spread),
			LocationY = where.Y + game.RandomFloat(-tuning.Spread, tuning.Spread),
		})
		if not foodId then return end

		local food = game.CreateConsumableItem(foodId, tuning.Food, 0)

		if food and food.ObjectId then
			game.ApplyUpwardForce({ Id = food.ObjectId, Speed = game.RandomFloat(500, 700) })
			game.ApplyForce({
				Id = food.ObjectId,
				Speed = game.RandomFloat(75, 150),
				Angle = game.RandomFloat(0, 360),
				SelfApplied = true,
			})
		end
	end
end


---@diagnostic disable-next-line: unused-local
function mod.HeartyAppetiteAcquire(args, traitData, addArgs)
	if not boon_edit_on('HeartyAppetite') then return end
	game.thread(hearty_appetite_drop_food, mod.tuning.HeartyAppetite.FoodOnPickup)
end


function hearty_appetite_check_food()
	if not boon_edit_on('HeartyAppetite') then return end
	if not game.CurrentRun or not game.CurrentRun.Hero then return end

	local trait = game.GetHeroTrait(HEARTY_APPETITE)
	if not trait or not trait.RoomsPerUpgrade then return end
	if trait.CurrentRoom ~= 0 then return end

	game.thread(hearty_appetite_drop_food, 1)
end
