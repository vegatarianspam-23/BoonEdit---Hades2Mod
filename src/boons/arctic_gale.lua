---@meta _


once('ArcticGaleArea', function()
	if not boon_edit_on('ArcticGale') then return end

	modutil.mod.Path.Wrap('DemeterCastBlast', function(base, weaponData, traitArgs, triggerArgs)
		traitArgs.BlastRadiusMultiplier = cast_area_multiplier()
		return base(weaponData, traitArgs, triggerArgs)
	end)
end)
