---@meta _
---@diagnostic disable: lowercase-global


HERMES_LEGENDARY_OWNERS = {
	TimeStopLastStandBoon = 'PaidDues',
	[DOUBLE_TIME_TRAIT] = 'DoubleTime',
	[FLAWLESS_EXECUTION_TRAIT] = 'FlawlessExecution',
	[DISTRESS_CALL_TRAIT] = 'DistressCall',
}

HERMES_LEGENDARY_EXTRA_ELEMENTS = {
	TimeStopLastStandBoon = { 'Water' },
	[DOUBLE_TIME_TRAIT] = { 'Air' },
}


local function hermes_listed(traitName)
	local hermes = game.LootData.HermesUpgrade
	return hermes ~= nil and hermes.Traits ~= nil and game.Contains(hermes.Traits, traitName)
end


function hermes_legendary_element(traitName)
	if config.enabled == false then return nil end

	local traitData = game.TraitData[traitName]
	if not traitData or not traitData.RarityLevels or not traitData.RarityLevels.Legendary then return nil end
	if not hermes_listed(traitName) then return nil end

	local owner = HERMES_LEGENDARY_OWNERS[traitName]
	if owner and not boon_edit_on(owner) then return nil end

	return traitData.Elements and traitData.Elements[1]
end


function hermes_legendary_names()
	local names = {}
	local hermes = game.LootData.HermesUpgrade
	for _, traitName in ipairs(hermes and hermes.Traits or {}) do
		if hermes_legendary_element(traitName) then table.insert(names, traitName) end
	end
	return names
end


function hermes_legendary_elements(traitName)
	if not hermes_legendary_element(traitName) then return nil end
	local elements = {}
	for _, element in ipairs(game.TraitData[traitName].Elements or {}) do
		table.insert(elements, element)
	end
	local extra = boon_edit_hermes_duos_on() and HERMES_LEGENDARY_EXTRA_ELEMENTS[traitName] or {}
	for _, element in ipairs(extra) do
		if not game.Contains(elements, element) then table.insert(elements, element) end
	end
	return elements
end


function hermes_legendary_requirement(traitName)
	local elements = hermes_legendary_elements(traitName) or {}
	local oneOf = {}
	for _, other in ipairs(game.LootData.HermesUpgrade.Traits) do
		local data = game.TraitData[other]
		local legendary = data and data.RarityLevels and data.RarityLevels.Legendary
		if data and not legendary and data.Elements then
			for _, element in ipairs(elements) do
				if game.Contains(data.Elements, element) then
					table.insert(oneOf, other)
					break
				end
			end
		end
	end
	return { OneOf = oneOf, PriorityChance = mod.tuning.HermesLegendaries.KeepsakeOfferChance }
end


local function hermes_legendary_keepsake()
	return game.CurrentRun ~= nil and game.HeroHasTrait(mod.tuning.HermesLegendaries.Keepsake)
end


local function hermes_legendary_element_met(traitName)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	local elements = hermes_legendary_elements(traitName)
	if not hero or not hero.Elements or not elements then return false end
	for _, element in ipairs(elements) do
		if (hero.Elements[element] or 0) >= mod.tuning.HermesLegendaries.GuaranteeElementCount then return true end
	end
	return false
end


local function hermes_legendary_due(traitName)
	local given = game.CurrentRun.BoonEditHermesLegendaryGuaranteed
	if given and given[traitName] then return false end
	return hermes_legendary_element_met(traitName)
end


function hermes_legendary_unlocked(traitName)
	if not hermes_legendary_element(traitName) then return false end
	return hermes_legendary_keepsake() or hermes_legendary_element_met(traitName)
end


function hermes_legendary_priority(linked)
	if not linked or not game.CurrentRun then return linked end

	local keepsake = hermes_legendary_keepsake()
	local guaranteed = {}
	for index = #linked, 1, -1 do
		local traitName = linked[index].TraitName
		if hermes_legendary_element(traitName) then
			if hermes_legendary_due(traitName) then
				table.remove(linked, index)
				table.insert(guaranteed, traitName)
			elseif not keepsake then
				table.remove(linked, index)
			end
		end
	end

	local run = game.CurrentRun
	for _, traitName in ipairs(guaranteed) do
		table.insert(linked, 1, { TraitName = traitName, PriorityChance = 1 })
		run.BoonEditHermesLegendaryGuaranteed = run.BoonEditHermesLegendaryGuaranteed or {}
		run.BoonEditHermesLegendaryGuaranteed[traitName] = true
	end
	return linked
end


function hermes_legendary_rarities(lootData)
	for _, option in ipairs(lootData and lootData.UpgradeOptions or {}) do
		local levels = option.Type == 'Trait' and hermes_legendary_element(option.ItemName)
			and game.TraitData[option.ItemName].RarityLevels
		if levels and not levels[option.Rarity] then
			option.Rarity = 'Legendary'
		end
	end
end


once('HermesLegendaries', function()
	modutil.mod.Path.Wrap('SetTraitsOnLoot', function(base, lootData, ...)
		local result = base(lootData, ...)
		hermes_legendary_rarities(lootData)
		return result
	end)

	modutil.mod.Path.Wrap('HasTraitRequirements', function(base, traitName, ...)
		if hermes_legendary_unlocked(traitName) then return true end
		return base(traitName, ...)
	end)

	modutil.mod.Path.Wrap('GetPriorityDependentTraits', function(base, lootData)
		return hermes_legendary_priority(base(lootData))
	end)
end)
