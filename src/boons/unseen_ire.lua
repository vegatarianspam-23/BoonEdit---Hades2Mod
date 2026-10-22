---@meta _


once('UnseenIreCooldown', function()
	if not boon_edit_on('UnseenIre') then return end

	game.TraitData.HadesInvisibilityRetaliateBoon.OnSelfDamagedFunction.FunctionArgs.Cooldown =
		mod.tuning.UnseenIre.Cooldown

	modutil.mod.Path.Wrap("StartRoom", function(base, currentRun, currentRoom)
		if currentRoom and currentRoom.BiomeStartRoom and boon_edit_on('UnseenIre')
			and game.HeroHasTrait('HadesInvisibilityRetaliateBoon') then
			game.HadesInvisibilitySetup()
		end
		return base(currentRun, currentRoom)
	end)
end)
