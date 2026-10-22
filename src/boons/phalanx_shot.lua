---@meta _


once('PhalanxShot', function()
	if not boon_edit_on('PhalanxShot') then return end

	local phalanx = game.TraitData.AthenaProjectileBoon
	local args = phalanx and phalanx.OnWeaponFiredFunctions and phalanx.OnWeaponFiredFunctions.FunctionArgs
	if not args then return end

	args.Cooldown = mod.tuning.PhalanxShot.Cooldown
end)
