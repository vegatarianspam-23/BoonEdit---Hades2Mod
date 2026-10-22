---@meta _


local THROWN = 'ProjectileDaggerThrow'
local OMEGA = 'ProjectileDaggerThrowCharged'

local HOOK_PROPERTIES = {
	NumPenetrations = 9999,
	UnlimitedUnitPenetration = true,
	UseVulnerability = true,
	RepeatHitOnReturn = true,
}

once('ReaperKnives', function()
	if not boon_edit_on('ReaperKnives') then return end

	local reaperKnives = game.TraitData.DaggerSpecialReturnTrait

	reaperKnives.AddOutgoingDamageModifiers = {
		ValidWeapons = { 'WeaponDaggerThrow' },
		ValidWeaponsLookup = game.ToLookup({ 'WeaponDaggerThrow' }),
		ExcludeLinked = true,
		HitVulnerabilityMultiplier = { BaseValue = mod.tuning.ReaperKnives.HitVulnerabilityMultiplier },
		ReportValues = { ReportedWeaponMultiplier = 'HitVulnerabilityMultiplier' },
	}

	local changes = {}
	local function change(projectile, property, value, reportValues)
		table.insert(changes, {
			WeaponName = 'WeaponDaggerThrow',
			ProjectileName = projectile,
			ProjectileProperty = property,
			ChangeValue = value,
			ChangeType = 'Absolute',
			ReportValues = reportValues,
		})
	end

	for _, projectile in ipairs({ THROWN, OMEGA }) do
		for property, value in pairs(HOOK_PROPERTIES) do
			change(projectile, property, value)
		end
		change(projectile, 'ReturnToOwnerAfterInactiveSeconds', mod.tuning.ReaperKnives.ReturnDelay,
			{ ReportedReturnTime = 'ChangeValue' })
	end
	change(THROWN, 'Fuse', mod.tuning.ReaperKnives.Fuse)

	reaperKnives.PropertyChanges = changes

	reaperKnives.ExtractValues = {
		{ Key = 'ReportedWeaponMultiplier', ExtractAs = 'DamageIncrease', Format = 'PercentDelta' },
		{ Key = 'ReportedReturnTime', ExtractAs = 'ReturnTime', DecimalPlaces = 2 },
	}
end)
