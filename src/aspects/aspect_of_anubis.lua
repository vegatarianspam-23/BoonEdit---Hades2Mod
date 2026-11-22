---@meta _


ANUBIS_ASPECT = 'StaffRaiseDeadAspect'
ANUBIS_ETCHINGS = 'StaffLoneShadeRallyTrait'

local ANUBIS_ATTACKS = {
	WeaponStaffSwing = true,
	WeaponStaffSwing2 = true,
	WeaponStaffSwing3 = true,
	WeaponStaffSwing5 = true,
}

local ANUBIS_SPECIALS = {
	WeaponStaffBall = true,
}


once('AspectOfAnubis', function()
	if not boon_edit_on('AspectOfAnubis') then return end

	local anubis = game.TraitData[ANUBIS_ASPECT]
	if not anubis then return end

	if anubis.WeaponDataOverride then
		anubis.WeaponDataOverride.WeaponStaffSwing = nil
	end

	local kept = {}
	for _, change in ipairs(anubis.PropertyChanges or {}) do
		if change.WeaponName ~= 'WeaponStaffSwing' then
			table.insert(kept, change)
		end
	end
	anubis.PropertyChanges = kept
	anubis.SWuAnubisRework = 2

	local action = anubis.OnEnemyDamagedAction
	if action then
		action.ValidWeapons = nil
		action.ValidWeaponsLookup = nil
		action.FirstHitOnly = true
		action.FunctionName = _PLUGIN.guid .. '.AnubisSecondary'
	end
end)


once('PharaohEtchings', function()
	if not boon_edit_on('PharaohEtchings') then return end

	local etchings = game.TraitData[ANUBIS_ETCHINGS]
	if etchings then
		etchings.OnEnemyDamagedAction = nil
		etchings.PropertyChanges = etchings.PropertyChanges or {}
		table.insert(etchings.PropertyChanges, {
			WeaponName = 'WeaponStaffDash',
			ProjectileName = 'ProjectileStaffSingle',
			ProjectileProperty = 'BlastDuration',
			ChangeValue = 1 + mod.tuning.AspectOfAnubis.EtchingsFieldDuration,
			ChangeType = 'Multiply',
			ExcludeLinked = true,
		})
	end
end)


once('AspectOfAnubisField', function()
	if not boon_edit_on('AspectOfAnubis') then return end

	modutil.mod.Path.Wrap('ExpireProjectiles', function(base, args)
		if args and args.WeaponName == 'WeaponStaffDash' and game.HeroHasTrait(ANUBIS_ASPECT) then return end
		return base(args)
	end)
end)


once('AspectOfAnubisHeld', function()
	modutil.mod.Path.Wrap('EquipWeaponUpgrade', function(base, hero, args)
		anubis_refresh_held(hero)
		return base(hero, args)
	end)
end)


function anubis_refresh_held(hero)
	if not hero or hero ~= (game.CurrentRun and game.CurrentRun.Hero) then return end
	local data = game.TraitData[ANUBIS_ASPECT]
	if not data then return end
	for _, trait in ipairs(hero.Traits or {}) do
		if trait.Name == ANUBIS_ASPECT then
			if trait.SWuAnubisRework ~= data.SWuAnubisRework then
				game.RemoveTraitData(hero, trait, { SkipUIUpdate = true })
			end
			return
		end
	end
end


function mod.AnubisSecondary(victim, args, triggerArgs)
	if not boon_edit_on('AspectOfAnubis') or not victim or not triggerArgs or triggerArgs.EffectName then return end

	local weapon = triggerArgs.SourceWeapon
	local launch, pull = ANUBIS_ATTACKS[weapon], ANUBIS_SPECIALS[weapon]
	if not launch and not pull then return end
	if boon_edit_on('AnkhSwapSecondaries') then launch, pull = pull, launch end

	if launch then
		game.RallyAnubisShades(victim, args, triggerArgs)
	else
		game.CheckStaffProjectilePull(victim, args, triggerArgs)
	end
end
