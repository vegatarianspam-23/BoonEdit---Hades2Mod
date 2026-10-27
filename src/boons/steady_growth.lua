---@meta _


once('SteadyGrowth', function()
	if not boon_edit_on('SteadyGrowth') then return end

	local growth = game.TraitData.BoonGrowthBoon
	if not growth then return end

	growth.AcquireFunctionName = _PLUGIN.guid .. '.SteadyGrowthAcquire'
end)


---@diagnostic disable-next-line: unused-local
function mod.SteadyGrowthAcquire(args, traitData)
	game.UpdateUpgradableTraitCount(args, traitData)

	if not boon_edit_on('SteadyGrowth') then return end

	game.thread(steady_growth_pickup_rarity)
end


function steady_growth_pickup_rarity()
	game.wait(mod.tuning.SteadyGrowth.PickupDelay)

	local trait = game.GetHeroTrait('BoonGrowthBoon')
	if not trait then return end

	game.AddRarityToTraits(trait, {
		NumTraits = mod.tuning.SteadyGrowth.RarityOnPickup,
		LowPriorityTraitName = 'BoonGrowthBoon',
	})
	game.UpdateUpgradableTraitCount(nil, trait)
end
