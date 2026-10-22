---@meta _


once('FestiveFogShelterStat', function()
	if not boon_edit_on('FestiveFog') then return end

	local fog = game.TraitData.FogDamageBonusBoon
	if not fog then return end

	fog.BoonEditShelter = mod.tuning.FestiveFog.Shelter - 1
	boon_edit_add_stat('FogDamageBonusBoon', 'BoonEditFestiveFogShelterStatDisplay',
		{ Key = 'BoonEditShelter', ExtractAs = 'TooltipShelter', Format = 'Percent' })
end)


local FOGWARD = 'BoonEditFestiveFogward'


local function festive_fog_set(multiplier)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end
	hero.IncomingDamageModifiers = hero.IncomingDamageModifiers or {}

	local entry
	for _, modifier in ipairs(hero.IncomingDamageModifiers) do
		if modifier[FOGWARD] then
			entry = modifier
			break
		end
	end

	if not entry then
		entry = { [FOGWARD] = true, NonPlayerMultiplier = 1 }
		game.AddIncomingDamageModifier(hero, entry)
	end

	entry.NonPlayerMultiplier = multiplier
end


function festive_fog_shelter(on)
	if not boon_edit_on('FestiveFog') then
		festive_fog_set(1)
		return
	end

	local shelter = mod.tuning.FestiveFog.Shelter
	if type(shelter) ~= 'number' or shelter <= 0 then return end

	festive_fog_set(on and shelter or 1)
end


modutil.mod.Path.Set('WineEmpowerApply', function(triggerArgs)
	if triggerArgs and triggerArgs.Victim ~= (game.CurrentRun and game.CurrentRun.Hero) then return end
	festive_fog_shelter(true)
end)

modutil.mod.Path.Set('WineEmpowerClear', function(triggerArgs)
	if triggerArgs and triggerArgs.Victim ~= (game.CurrentRun and game.CurrentRun.Hero) then return end
	festive_fog_shelter(false)
end)
