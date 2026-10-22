---@meta _


local OLD_GRUDGE = 'HadesPreDamageBoon'


once('OldGrudgeRepeatable', function()
	if not boon_edit_on('OldGrudge') then return end

	game.TraitData[OLD_GRUDGE].Uses = nil

	modutil.mod.Path.Wrap("StartEncounterEffects", function(base, encounter)
		return old_grudge_encounter_start(base, encounter)
	end)
end)


local function old_grudge_would_fire(encounter, damageData)
	if encounter and encounter.SkipBossTraits then return false end

	local room = game.CurrentRun and game.CurrentRun.CurrentRoom
	if not room then return false end

	if damageData.EnemyType ~= 'Boss' and not game.Contains(damageData.ValidRooms, room.Name) then
		return false
	end

	for _, unit in pairs(game.ActiveEnemies or {}) do
		if unit and unit.IsBoss then return true end
	end
	return false
end


function old_grudge_encounter_start(base, encounter)
	if not boon_edit_on('OldGrudge') then return base(encounter) end

	local run = game.CurrentRun
	local trait = run and game.GetHeroTrait(OLD_GRUDGE)
	local damageData = trait and trait.EncounterPreDamage
	if not damageData then return base(encounter) end

	trait.Uses = nil
	local spent = run.BoonEditOldGrudgeSpent

	if spent then trait.EncounterPreDamage = nil end

	local ok, err = pcall(base, encounter)

	trait.EncounterPreDamage = damageData
	if not ok then error(err) end

	if not spent and old_grudge_would_fire(encounter, damageData) then
		run.BoonEditOldGrudgeSpent = true
	end
end
