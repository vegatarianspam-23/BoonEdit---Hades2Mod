---@meta _


once('BraveFace', function()
	if not boon_edit_on('BraveFace') then return end

	local braveFace = game.TraitData.ManaShieldBoon
	braveFace.ManaShieldData.DamageBlocked = mod.tuning.BraveFace.DamageBlocked
	braveFace.ManaShieldData.ManaPerDamageBlocked = mod.tuning.BraveFace.ManaPerDamage
end)
