---@meta _


once('WeedKiller', function()
	if not boon_edit_on('WeedKiller') then return end

	local killer = game.TraitData.SlowExAttackBoon
	if not killer then return end

	if killer.AddOutgoingDamageModifiers then
		local weapons = game.AddLinkedWeapons(game.WeaponSets.HeroPrimarySecondaryWeapons)
		killer.AddOutgoingDamageModifiers.ValidWeapons = weapons
		killer.AddOutgoingDamageModifiers.ValidWeaponsLookup = game.ToLookup(weapons)
	end

	if killer.ManaCostModifiers then
		local weapons = game.AddLinkedWeapons(game.WeaponSets.HeroPrimarySecondaryWeapons)
		killer.ManaCostModifiers.WeaponNames = weapons
		killer.ManaCostModifiers.WeaponNamesLookup = game.ToLookup(weapons)
	end

	killer.StatLines = { 'BoonEditWeedKillerStatDisplay' }
end)
