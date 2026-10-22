---@meta _

once('Preparation', function()
	if not boon_edit_on('Preparation') then return end

	game.TraitData.PreChargeTalent.OnEncounterStartFunction = { Name = _PLUGIN.guid .. '.PreparationPrecharge' }
end)

function mod.PreparationPrecharge(hero, _args)
	if not boon_edit_on('Preparation') then return end
	if not hero or (game.CurrentRoom and game.CurrentRoom.BlockTraitSetup) then return end
	local run = game.CurrentRun
	if not run or (game.GetTotalHeroTraitValue('SpellPreCharge') or 0) <= 0 then return end

	local spellTrait
	for _, trait in ipairs(hero.Traits or {}) do
		if trait.Slot == 'Spell' then spellTrait = trait end
	end
	if not spellTrait or not spellTrait.PreEquipWeapons then return end

	local held = run.SpellCharge or 0
	game.SpellPrecharge(spellTrait, spellTrait.PreEquipWeapons[1])
	if (run.SpellCharge or 0) < held then run.SpellCharge = held end

	if spellTrait.CheckChargeFunctionName then
		game.CallFunctionName(spellTrait.CheckChargeFunctionName, hero, nil, {})
	end
end
