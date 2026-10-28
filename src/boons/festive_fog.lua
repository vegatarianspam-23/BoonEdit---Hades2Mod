---@meta _


once('FestiveFogShelterStat', function()
	if not boon_edit_on('FestiveFog') then return end

	local fog = game.TraitData.FogDamageBonusBoon
	if not fog then return end

	fog.StatLines = { 'BoonEditFestiveFogStatDisplay' }
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

	festive_fog_set(on and festive_fog_multiplier() or 1)
end


function festive_fog_multiplier()
	local trait = game.GetHeroTrait('FogDamageBonusBoon')
	local modifier = trait and trait.AddOutgoingDamageModifiers
	local bonus = modifier and modifier.RequiredSelfEffectsMultiplier
	if type(bonus) ~= 'number' then return 1 end

	return math.max(0, 1 - (bonus - 1) * mod.tuning.FestiveFog.ShelterPerBonus)
end


modutil.mod.Path.Set('WineEmpowerApply', function(triggerArgs)
	if triggerArgs and triggerArgs.Victim ~= (game.CurrentRun and game.CurrentRun.Hero) then return end
	festive_fog_shelter(true)
end)

modutil.mod.Path.Set('WineEmpowerClear', function(triggerArgs)
	if triggerArgs and triggerArgs.Victim ~= (game.CurrentRun and game.CurrentRun.Hero) then return end
	festive_fog_shelter(false)
end)
