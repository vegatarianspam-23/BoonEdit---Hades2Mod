---@meta _


once('UnseenIreCooldown', function()
	if not boon_edit_on('UnseenIre') then return end

	local ire = game.TraitData.HadesInvisibilityRetaliateBoon
	ire.OnSelfDamagedFunction.FunctionArgs.Cooldown = mod.tuning.UnseenIre.Cooldown
	ire.AddOutgoingDamageModifiers.RequiredSelfEffectsMultiplier.BaseValue = mod.tuning.UnseenIre.DamageMultiplier

	modutil.mod.Path.Wrap("StartRoom", function(base, currentRun, currentRoom)
		if currentRoom and currentRoom.BiomeStartRoom and boon_edit_on('UnseenIre')
			and game.HeroHasTrait('HadesInvisibilityRetaliateBoon') then
			game.HadesInvisibilitySetup()
		end
		return base(currentRun, currentRoom)
	end)
end)
