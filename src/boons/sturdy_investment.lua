---@meta _
---@diagnostic disable: lowercase-global


STURDY_INVESTMENT_TRAIT = 'BoonEditSturdyInvestmentDuoBoon'
STURDY_INVESTMENT_SOURCE = 'Wistiti-HermesDuos-MoneyToShieldBoon'


function sturdy_investment_define()
	if game.TraitData[STURDY_INVESTMENT_TRAIT] then return true end
	local source = game.TraitData[STURDY_INVESTMENT_SOURCE]
	if not source then return false end

	local trait = game.DeepCopyTable(source)
	trait.Name = STURDY_INVESTMENT_TRAIT
	game.TraitData[STURDY_INVESTMENT_TRAIT] = trait
	game.ProcessDataInheritance(trait, game.TraitData)

	local requirements = game.TraitRequirements
	if requirements and requirements[STURDY_INVESTMENT_SOURCE] and not requirements[STURDY_INVESTMENT_TRAIT] then
		requirements[STURDY_INVESTMENT_TRAIT] = game.DeepCopyTable(requirements[STURDY_INVESTMENT_SOURCE])
	end
	return true
end


function sturdy_investment_gain(name, amount)
	if name ~= 'Money' or type(amount) ~= 'number' or amount <= 0 then return end
	if not boon_edit_hermes_duo_on('SturdyInvestment') then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or hero.IsDead or not game.HeroHasTrait(STURDY_INVESTMENT_TRAIT) then return end

	local data = game.GetHeroTrait(STURDY_INVESTMENT_TRAIT).GoldtoArmorData
	local cost = data and math.ceil(data.GoldCost or 0) or 0
	if cost <= 0 then return end

	local armor = game.round(amount / cost)
	if armor > 0 then
		game.AddArmor(armor, { Thread = true })
	end
end


once('SturdyInvestment', function()
	modutil.mod.Path.Wrap('AddResource', function(base, name, amount, source, args)
		local result = base(name, amount, source, args)
		sturdy_investment_gain(name, amount)
		return result
	end)
end)
