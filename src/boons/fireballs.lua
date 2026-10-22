---@meta _


function fireball_projectiles()
	return mod.tuning.Fireballs.Projectiles
end


function fireball_lookup()
	return game.ToLookup(fireball_projectiles())
end


function fireball_widen_trait(trait)
	if not trait then return end

	for _, field in ipairs({ 'AddOutgoingDamageModifiers', 'OnEnemyDamagedAction' }) do
		local data = trait[field]
		if data and data.ValidProjectiles then
			data.ValidProjectiles = fireball_projectiles()
			data.ValidProjectilesLookup = fireball_lookup()
		end
	end
end


once('Fireballs', function()
	for _, traitName in ipairs(mod.tuning.Fireballs.Traits) do
		fireball_widen_trait(game.TraitData[traitName])
	end
end)
