---@meta _


once('LocalClimateCoversCastBoons', function()
	if not boon_edit_on('LocalClimate') then return end

	local modifiers = game.TraitData.CastAttachBoon.AddOutgoingDamageModifiers

	local projectiles, seen = {}, {}
	for _, list in ipairs({ modifiers.ValidProjectiles or {}, game.WeaponSets.CastProjectileNames }) do
		for _, name in ipairs(list) do
			if not seen[name] then
				seen[name] = true
				table.insert(projectiles, name)
			end
		end
	end
	modifiers.ValidProjectiles = projectiles
	modifiers.ValidProjectilesLookup = game.ToLookup(projectiles)

	modifiers.ValidWeapons = game.WeaponSets.HeroRangedWeapons
	modifiers.ValidWeaponsLookup = game.ToLookup(game.WeaponSets.HeroRangedWeapons)
	modifiers.WeaponOrProjectileRequirement = true
end)
