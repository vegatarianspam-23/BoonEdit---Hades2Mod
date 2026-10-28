---@meta _


local SPRINT_PROPERTIES = { 'SelfVelocity', 'SelfVelocityCap' }


local function sprint_follows_moves_sprint(changes)
	for _, change in ipairs(changes) do
		local names = change.WeaponNames or (change.WeaponName and { change.WeaponName })
		if names and change.WeaponProperty == 'SelfVelocityCap' and game.Contains(names, 'WeaponSprint') then
			return true
		end
	end
	return false
end


function sprint_follows_trait(trait)
	local changes = type(trait) == 'table' and trait.PropertyChanges
	if type(changes) ~= 'table' or sprint_follows_moves_sprint(changes) then return end

	local added = {}
	for _, change in ipairs(changes) do
		if change.UnitProperty == 'Speed' and change.ChangeType == 'Multiply' then
			for _, property in ipairs(SPRINT_PROPERTIES) do
				local copy = game.DeepCopyTable(change)
				copy.UnitProperty = nil
				copy.ReportValues = nil
				copy.WeaponNames = { 'WeaponSprint' }
				copy.WeaponProperty = property
				copy.ExcludeLinked = true
				table.insert(added, copy)
			end
		end
	end

	for _, copy in ipairs(added) do
		table.insert(changes, copy)
	end
end


local function sprint_follows_is_sprint(change)
	local names = change.WeaponNames or (change.WeaponName and { change.WeaponName })
	if not names or not game.Contains(names, 'WeaponSprint') then return false end
	return change.WeaponProperty == 'SelfVelocity' or change.WeaponProperty == 'SelfVelocityCap'
end


function sprint_follows_scale(changes)
	if type(changes) ~= 'table' then return changes end

	local factor = nil
	for _, change in ipairs(changes) do
		if change.UnitProperty == 'Speed' and change.ChangeType == 'Multiply' then
			factor = change.ChangeValue
		end
	end
	if type(factor) ~= 'number' then return changes end

	local scaled = {}
	for _, change in ipairs(changes) do
		if change.ChangeType == 'Add' and sprint_follows_is_sprint(change) then
			local copy = game.ShallowCopyTable(change)
			copy.ChangeType = 'Multiply'
			copy.ChangeValue = factor
			table.insert(scaled, copy)
		else
			table.insert(scaled, change)
		end
	end
	return scaled
end


once('SprintFollowsMoveSpeed', function()
	if not boon_edit_on('SprintFollowsMoveSpeed') then return end

	for _, trait in pairs(game.TraitData) do
		sprint_follows_trait(trait)
	end

	modutil.mod.Path.Wrap('UpdateBloodDropSpeed', function(base, ...)
		mod.SprintFollowsPlasma = true
		local ok, err = pcall(base, ...)
		mod.SprintFollowsPlasma = nil
		if not ok then error(err, 0) end
	end)

	modutil.mod.Path.Wrap('ApplyUnitPropertyChanges', function(base, unit, changes, ...)
		if mod.SprintFollowsPlasma and boon_edit_on('SprintFollowsMoveSpeed') then
			changes = sprint_follows_scale(changes)
		end
		return base(unit, changes, ...)
	end)
end)
