---@meta _


once('MeanStreak', function()
	if not boon_edit_on('MeanStreak') then return end

	local streak = game.TraitData.TimedKillBuffBoon
	local modifier = streak and streak.AddOutgoingDamageModifiers
	if not modifier then return end

	modifier.ValidWeapons = nil
end)
