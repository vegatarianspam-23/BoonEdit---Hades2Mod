---@meta _


once('ThunderRushFireRate', function()
	if not boon_edit_on('ThunderRush') then return end

	local rush = game.TraitData.ZeusSprintBoon
	local fired = rush and rush.OnWeaponFiredFunctions
	local args = fired and fired.FunctionArgs
	if not args or type(args.Cooldown) ~= 'number' then return end

	args.Cooldown = args.Cooldown / mod.tuning.ThunderRush.FireRate
end)
