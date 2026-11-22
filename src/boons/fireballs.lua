---@meta _


function more_dash_fireballs(list)
	if not boon_edit_configured('MoreDashBoons') then return list end
	local widened = game.ShallowCopyTable(list)
	for _, name in ipairs(mod.tuning.MoreDashBoons.Fireballs) do
		if not game.Contains(widened, name) then table.insert(widened, name) end
	end
	return widened
end


function fireball_projectiles()
	return more_dash_fireballs(mod.tuning.Fireballs.Projectiles)
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
