---@meta _


local VOW_TRAIT = 'AllElementalBoon'
local VOW_HITCH = 'DamageShareEffect'
local VOW_SUMMON_BOON = 'RaiseDeadBoon'


once('NuptialVow', function()
	if not boon_edit_on('NuptialVow') then return end

	local vow = game.TraitData[VOW_TRAIT]

	vow.Elements = nil
	vow.AcquireFunctionName = nil
	vow.AcquireFunctionArgs = nil

	vow.BoonEditDamagePerHitched = mod.tuning.NuptialVow.DamagePerHitched
	vow.BoonEditNuptialMultiplier = 1
	vow.AddOutgoingDamageModifiers = {
		UseTraitValue = 'BoonEditNuptialMultiplier',
		IsMultiplier = true,
	}

	vow.SetupFunction = {
		Threaded = true,
		Name = _PLUGIN.guid .. '.NuptialVow',
		Args = { Interval = mod.tuning.NuptialVow.Interval },
	}
	vow.OnEffectApplyFunction = {
		FunctionName = _PLUGIN.guid .. '.NuptialVowApply',
		FunctionArgs = {},
	}

	vow.StatLines = { 'BoonEditNuptialVowStatDisplay' }
	vow.ExtractValues = with_keyword_extracts({
		{ Key = 'BoonEditDamagePerHitched', ExtractAs = 'TooltipDamagePerHitched', Format = 'Percent' },
	}, 'Link')
end)


local nuptialVowSpreading = false


local function nuptial_vow_wears_hitch(unit)
	return unit ~= nil and not unit.IsDead and unit.ActiveEffects ~= nil and unit.ActiveEffects[VOW_HITCH] ~= nil
end


local function nuptial_vow_foe(unit)
	if not unit or not unit.ObjectId or unit.IsDead then return false end
	if not (game.ActiveEnemies or {})[unit.ObjectId] then return false end
	if unit == (game.CurrentRun and game.CurrentRun.Hero) then return false end
	if boon_ignores(unit) or is_allied_summon(unit) then return false end
	return true
end


function nuptial_vow_hitched()
	local summons = game.HeroHasTrait(VOW_SUMMON_BOON)
	local total = 0
	for _, unit in pairs(game.ActiveEnemies or {}) do
		if nuptial_vow_wears_hitch(unit) then
			if is_allied_summon(unit) then
				if summons then total = total + 1 end
			elseif not boon_ignores(unit) then
				total = total + 1
			end
		end
	end
	return total
end


function nuptial_vow_set_bonus()
	local trait = game.GetHeroTrait(VOW_TRAIT)
	if not trait then return end

	local hitched = boon_edit_on('NuptialVow') and nuptial_vow_hitched() or 0
	trait.BoonEditNuptialMultiplier = 1 + hitched * mod.tuning.NuptialVow.DamagePerHitched
end


function mod.NuptialVow(_hero, args)
	local interval = (args and args.Interval) or mod.tuning.NuptialVow.Interval
	nuptialVowSpreading = false

	while game.CurrentRun and game.CurrentRun.CurrentRoom and hero_live()
		and game.HeroHasTrait(VOW_TRAIT) do

		nuptial_vow_set_bonus()
		game.wait(interval, game.RoomThreadName)
	end

	nuptial_vow_set_bonus()
end


local VOW_CURSES = {
	BurnEffect = function(source, unit, effectName)
		local held = (source.ActiveEffects and source.ActiveEffects[effectName]) or 0
		local carried = (unit.ActiveEffects and unit.ActiveEffects[effectName]) or 0
		if type(held) ~= 'number' or type(carried) ~= 'number' or held <= carried then return end

		game.ApplyBurn(unit, { EffectName = effectName, NumStacks = held - carried })
	end,
	ChillEffect = function(_source, unit, effectName)
		game.ApplyRoot(unit, { EffectName = effectName })
	end,
}


local VOW_ROOT_PRESENTATIONS = {
	RootApplyPresentation = true,
	ChillApplyPresentation = true,
}


local function nuptial_vow_rechills(unit, effectName)
	local effect = game.EffectData[effectName]
	if not effect then return false end

	local group = effect.EffectGroup
	if not VOW_ROOT_PRESENTATIONS[effect.OnApplyPresentationFunctionName]
		and group ~= 'Root' and group ~= 'Chill'
	then
		return false
	end

	return unit.RootActive == true
		or (group ~= nil and game.HasEffectWithEffectGroup(unit, group) == true)
end


local function nuptial_vow_inflict(source, unit, effectName)
	if nuptial_vow_rechills(unit, effectName) then return end

	local handler = VOW_CURSES[effectName]
	if handler then return handler(source, unit, effectName) end

	local effect = game.EffectData[effectName]
	local properties = effect and (effect.EffectData or effect.DataProperties)
	if not properties then return end

	game.ApplyEffect({
		DestinationId = unit.ObjectId,
		Id = game.CurrentRun.Hero.ObjectId,
		EffectName = effectName,
		DataProperties = game.MergeAllTables({ properties }),
	})
end


local function nuptial_vow_curse(effectName, triggerArgs)
	if triggerArgs.IsVulnerabilityEffect then return true end

	local effect = game.EffectData[effectName]
	local properties = effect and (effect.EffectData or effect.DataProperties)
	return properties ~= nil and properties.IsVulnerabilityEffect == true
end


function nuptial_vow_spread(source, effectName)
	game.waitUnmodified(0.01)

	local ok, err = pcall(function()
		if not nuptial_vow_foe(source) then return end

		for _, unit in pairs(game.ShallowCopyTable(game.ActiveEnemies or {})) do
			if unit ~= source and nuptial_vow_foe(unit) and nuptial_vow_wears_hitch(unit) then
				nuptial_vow_inflict(source, unit, effectName)
			end
		end
	end)

	nuptialVowSpreading = false
	if not ok then error(err) end
end


---@diagnostic disable-next-line: unused-local
function mod.NuptialVowApply(victim, _args, triggerArgs)
	if not boon_edit_on('NuptialVow') then return end
	if nuptialVowSpreading then return end

	local effectName = triggerArgs and triggerArgs.EffectName
	if not effectName or effectName == VOW_HITCH then return end
	if not nuptial_vow_curse(effectName, triggerArgs) then return end

	if not game.CurrentRun or not game.CurrentRun.Hero then return end
	if not nuptial_vow_foe(victim) or not nuptial_vow_wears_hitch(victim) then return end

	nuptialVowSpreading = true
	game.thread(nuptial_vow_spread, victim, effectName)
end
