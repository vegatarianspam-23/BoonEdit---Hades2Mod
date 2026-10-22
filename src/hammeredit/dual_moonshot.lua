---@meta _


once('DualMoonshot', function()
	if not boon_edit_on('DualMoonshot') then return end

	local dualMoonshot = game.TraitData.StaffTripleShotTrait
	local changes = dualMoonshot.PropertyChanges

	for index = #changes, 1, -1 do
		local property = changes[index]
		if property.WeaponName == 'WeaponStaffBall'
			and (property.ProjectileProperty == 'Fuse' or property.ProjectileProperty == 'Range') then
			table.remove(changes, index)
		end
	end

	for index = #dualMoonshot.ExtractValues, 1, -1 do
		if dualMoonshot.ExtractValues[index].Key == 'ReportedRangePenalty' then
			table.remove(dualMoonshot.ExtractValues, index)
		end
	end
end)
