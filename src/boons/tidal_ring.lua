---@meta _
---@diagnostic disable: lowercase-global


once('TidalRingSplash', function()
	modutil.mod.Path.Wrap("CheckPoseidonCastSplash", function(base, weaponData, functionArgs, triggerArgs)
		if not boon_edit_on('TidalRing') then return base(weaponData, functionArgs, triggerArgs) end
		return tidal_ring_splash(functionArgs, triggerArgs)
	end)
end)


function tidal_ring_splash(functionArgs, triggerArgs)
	if not functionArgs or not triggerArgs or not triggerArgs.ProjectileX or not triggerArgs.ProjectileY then return end

	local radius = 430
	if triggerArgs.ProjectileId then
		local modified = game.GetProjectileProperty({ ProjectileId = triggerArgs.ProjectileId, Property = 'ModifiedDamageRadius' })
		if type(modified) == 'number' and modified > 0 then radius = modified end
	end

	poseidon_circle_splash({
		X = triggerArgs.ProjectileX,
		Y = triggerArgs.ProjectileY,
		Radius = radius * poseidon_splash_scale(),
		DamageMultiplier = functionArgs.DamageMultiplier,
	})
end
