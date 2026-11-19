---@meta _


once('ToughGain', function()
	if not boon_edit_on('ToughGain') then return end

	local tough = game.TraitData.HephaestusManaBoon
	local tuning = mod.tuning.ToughGain

	tough.BlockStacking = nil
	tough.DamageShave.AbsoluteStackValues = { tuning.PomDamageReduction }
	tough.DamageShave.MaximumValue = tuning.MaxDamageReduction

	modutil.mod.Path.Wrap('CheckAutoRevenge', function(base, victim, functionArgs, triggerArgs)
		local key = victim and victim.ObjectId and victim.ObjectId .. 'AutoRevengeCooldown'
		local cooldowns = game.SessionState.GlobalCooldowns or {}
		local before = key and cooldowns[key]
		local result = base(victim, functionArgs, triggerArgs)
		if key and cooldowns[key] ~= before then tough_gain_affront() end
		return result
	end)
end)


function tough_gain_affront()
	if not boon_edit_on('ToughGain') or not mod.tuning.ToughGain.HeinousAffront then return end

	local trait = game.GetHeroTrait('HephaestusManaBoon')
	local mana = trait and trait.OnDamagedManaConversionFlat
	if type(mana) ~= 'number' or mana <= 0 then return end

	game.ManaDelta(mana)
end
