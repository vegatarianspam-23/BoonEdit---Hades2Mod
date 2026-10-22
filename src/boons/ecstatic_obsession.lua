---@meta _


local OBSESSION_TRAIT = 'RandomStatusBoon'
local WRECK_TRAIT = 'CharmCrowdBoon'
local OBSESSION_MARK = 'BoonEditObsessionMark'

once('EcstaticObsession', function()
	if not boon_edit_on('EcstaticObsession') then return end

	local obsession = game.TraitData[OBSESSION_TRAIT]
	local wreck = game.TraitData[WRECK_TRAIT]
	if not obsession or not wreck then return end

	local wreckCurses = obsession.OnEffectApplyFunction
	local wreckStatLines = obsession.StatLines
	local wreckExtracts = obsession.ExtractValues
	local wreckIcon = obsession.Icon
	local obsessionIcon = wreck.Icon

	wreck.SetupFunction = nil
	wreck.OnEffectApplyFunction = wreckCurses
	wreck.StatLines = wreckStatLines
	wreck.ExtractValues = wreckExtracts
	wreck.Icon = wreckIcon

	obsession.OnEffectApplyFunction = nil
	obsession.Icon = obsessionIcon

	obsession.SetupFunction = {
		Threaded = true,
		Name = _PLUGIN.guid .. '.EcstaticObsession',
		Args = {
			Interval = 0.3,
		},
	}

	obsession.BoonEditCharmChance = mod.tuning.EcstaticObsession.CharmChance
	obsession.BoonEditCharmDuration = mod.tuning.EcstaticObsession.CharmDuration
	obsession.BoonEditDamagePerFriendly = mod.tuning.EcstaticObsession.DamagePerFriendly
	obsession.BoonEditMaxDamageBonus = mod.tuning.EcstaticObsession.MaxDamageBonus

	obsession.StatLines = {
		'BoonEditObsessionChanceStatDisplay',
	}

	obsession.ExtractValues = with_keyword_extracts({
		{
			Key = 'BoonEditCharmChance',
			ExtractAs = 'TooltipChance',
			Format = 'LuckModifiedPercent',
			HideSigns = true,
		},
		{ Key = 'BoonEditDamagePerFriendly', ExtractAs = 'TooltipPerFriendly', Format = 'Percent' },
		{ Key = 'BoonEditCharmDuration', ExtractAs = 'TooltipDuration' },
		{ Key = 'BoonEditMaxDamageBonus', ExtractAs = 'TooltipMaxBonus', Format = 'Percent' },
	}, 'Weak')

	game.EffectData.WeakEffect.OnApplyFunctionName = _PLUGIN.guid .. '.EcstaticObsessionWeak'

	game.EffectData[OBSESSION_MARK] = {
		Name = OBSESSION_MARK,
		Vfx = game.EffectData.Charm and game.EffectData.Charm.Vfx,
		EffectData = { Duration = mod.tuning.EcstaticObsession.CharmDuration },
	}

	modutil.mod.Path.Wrap('CharmClear', function(base, triggerArgs)
		local victim = triggerArgs and triggerArgs.Victim
		if victim then
			game.RemoveOutgoingDamageModifier(victim, CHARM_MODIFIER_NAME)
		end
		return base(triggerArgs)
	end)
end)


local function obsession_interrupt_key(unit)
	return 'BoonEditObsessionInterrupt' .. tostring(unit.ObjectId)
end


local function obsession_charmable(unit)
	if unit.SkipModifiers or unit.BlockCharm then return false end

	if mod.tuning.EcstaticObsession.SpareBosses and (unit.IsBoss or unit.UseBossHealthBar) then
		return false
	end

	return true
end


local function obsession_guardian(unit)
	return unit.IsBoss or unit.UseBossHealthBar
end


local function obsession_charm_ready(unit)
	if unit.ReachedAIStageEnd then return false end
	if unit.ObjectId and game.IsInvulnerable({ Id = unit.ObjectId }) then return false end

	if not obsession_guardian(unit) then return true end

	local tuning = mod.tuning.EcstaticObsession
	return game.CheckCooldownNoTrigger('BoonEditObsessionCharm' .. tostring(unit.ObjectId),
		tuning.CharmDuration + tuning.GuardianCharmCooldown, true)
end


CHARM_MODIFIER_NAME = 'BoonEditObsessionCharmed'


local function obsession_break_pattern(unit)
	local weaponData = unit.WeaponName and game.WeaponData[unit.WeaponName]
	if weaponData and weaponData.BlockInterrupt then return false end

	unit.ForcedWeaponInterrupt = unit.WeaponName or true

	if unit.PreAttackLoopingSoundId then
		game.StopSound({ Id = unit.PreAttackLoopingSoundId, Duration = 0.2 })
		unit.PreAttackLoopingSoundId = nil
	end

	return true
end


local function obsession_charm(unit)
	local tuning = mod.tuning.EcstaticObsession

	game.ApplyEffect({
		Id = game.CurrentRun.Hero.ObjectId,
		DestinationId = unit.ObjectId,
		EffectName = 'Charm',
		DataProperties = {
			Type = 'CHARM',
			Duration = tuning.CharmDuration,
			Active = true,
			TimeModifierFraction = 0,
		},
	})

	local multiplier = tuning.CharmedDamageMultiplier
	local friendly = tuning.CharmedFriendlyFireMultiplier

	if (multiplier and multiplier > 1) or friendly then
		game.RemoveOutgoingDamageModifier(unit, CHARM_MODIFIER_NAME)
		game.AddOutgoingDamageModifier(unit, {
			Name = CHARM_MODIFIER_NAME,
			NonPlayerMultiplier = (multiplier and multiplier > 1) and multiplier or nil,
			FriendMultiplier = friendly,
		})
	end

	obsession_break_pattern(unit)

	if obsession_guardian(unit) then
		game.CheckCooldown('BoonEditObsessionCharm' .. tostring(unit.ObjectId),
			tuning.CharmDuration + tuning.GuardianCharmCooldown, true)
	end
end


local function obsession_interrupt(unit)
	local weaponName = unit.WeaponName
	if not weaponName or not game.WeaponData[weaponName] then return false end

	local cooldown = mod.tuning.EcstaticObsession.InterruptCooldown
	if not game.CheckCooldown(obsession_interrupt_key(unit), cooldown) then return false end

	unit.ForcedWeaponInterrupt = true

	if game.EffectData[OBSESSION_MARK] then
		game.ApplyEffect({
			Id = game.CurrentRun.Hero.ObjectId,
			DestinationId = unit.ObjectId,
			EffectName = OBSESSION_MARK,
			DataProperties = { Duration = mod.tuning.EcstaticObsession.CharmDuration },
		})
	end

	return true
end


local OBSESSION_MODIFIER_NAME = 'BoonEditEcstaticObsession'


local function obsession_set_bonus(friendlyCount)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end
	hero.OutgoingDamageModifiers = hero.OutgoingDamageModifiers or {}

	local entry
	for _, modifier in ipairs(hero.OutgoingDamageModifiers) do
		if modifier.Name == OBSESSION_MODIFIER_NAME then
			entry = modifier
			break
		end
	end
	if not entry then
		entry = { Name = OBSESSION_MODIFIER_NAME, NonPlayerMultiplier = 1 }
		game.AddOutgoingDamageModifier(hero, entry)
	end

	local tuning = mod.tuning.EcstaticObsession
	entry.NonPlayerMultiplier = 1 + math.min(friendlyCount * tuning.DamagePerFriendly, tuning.MaxDamageBonus)
end


function mod.EcstaticObsession(hero, args)
	local interval = (args and args.Interval) or 0.3

	while game.CurrentRun and game.CurrentRun.CurrentRoom and hero_live()
		and game.HeroHasTrait(OBSESSION_TRAIT) do

		local friendly = 0
		if boon_edit_on('EcstaticObsession') then
			local range = mod.tuning.EcstaticObsession.AllyRange
			for _, unit in pairs(game.ActiveEnemies or {}) do
				if unit and unit.ObjectId and not unit.IsDead and is_allied_summon(unit) then
					local distance = game.GetDistance({ Id = hero.ObjectId, DestinationId = unit.ObjectId })
					if distance and distance <= range then
						friendly = friendly + 1
					end
				end
			end
		end

		obsession_set_bonus(friendly)
		game.wait(interval, game.RoomThreadName)
	end

	obsession_set_bonus(0)
end


---@diagnostic disable-next-line: unused-local
function mod.EcstaticObsessionWeak(triggerArgs, _args)
	if not boon_edit_on('EcstaticObsession') then return end
	if not game.HeroHasTrait(OBSESSION_TRAIT) then return end
	if not triggerArgs or triggerArgs.Reapplied then return end

	local victim = triggerArgs.Victim
	if not victim or not victim.ObjectId or victim.IsDead then return end
	if victim == (game.CurrentRun and game.CurrentRun.Hero) then return end

	if is_allied_summon(victim) then return end

	if not rolls(mod.tuning.EcstaticObsession.CharmChance) then return end

	game.thread(obsession_take, victim, triggerArgs.EffectName or 'WeakEffect')
end


function obsession_take(victim, effectName)

	game.waitUnmodified(0.01)

	if not victim.ObjectId or victim.IsDead then return end
	if not (game.ActiveEnemies or {})[victim.ObjectId] then return end

	if obsession_charmable(victim) then
		if not obsession_charm_ready(victim) then return end
		obsession_charm(victim)
	elseif not obsession_interrupt(victim) then
		return
	end

	game.ClearEffect({ Id = victim.ObjectId, Name = effectName })
end
