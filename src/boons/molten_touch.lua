---@meta _


local GLOW_EFFECT = 'DelayedKnockbackEffect'

once('MoltenTouchGlow', function()
	if not boon_edit_on('MoltenTouch') then return end

	local moltenTouch = game.TraitData.AntiArmorBoon
	local tuning = mod.tuning.MoltenTouch

	moltenTouch.AddOutgoingDamageModifiersArray = {
		{
			ValidActiveEffects = { GLOW_EFFECT },
			ValidWeapons = game.WeaponSets.HeroPrimarySecondaryWeapons,
			ValidWeaponsLookup = game.ToLookup(game.WeaponSets.HeroPrimarySecondaryWeapons),
			ValidWeaponMultiplier = 1 + tuning.GlowBonus.Common,
			BoonEditMoltenGlow = true,
		},
	}
	moltenTouch.BoonEditMoltenGlowBonus = tuning.GlowBonus.Common

	boon_edit_add_stat('AntiArmorBoon', 'BoonEditMoltenGlowStatDisplay',
		{ Key = 'BoonEditMoltenGlowBonus', ExtractAs = 'TooltipGlowBonus', Format = 'Percent' })
	moltenTouch.ExtractValues = with_keyword_extracts(moltenTouch.ExtractValues, 'DelayedKnockback')

	modutil.mod.Path.Wrap('GetProcessedTraitData', function(base, args)
		local trait = base(args)
		molten_touch_rarity(trait)
		return trait
	end)
end)


function molten_touch_rarity(trait)
	if not trait or trait.Name ~= 'AntiArmorBoon' or not boon_edit_on('MoltenTouch') then return end

	local bonuses = mod.tuning.MoltenTouch.GlowBonus
	local bonus = bonuses[trait.Rarity or 'Common'] or bonuses.Common

	for _, modifier in ipairs(trait.AddOutgoingDamageModifiersArray or {}) do
		if modifier.BoonEditMoltenGlow then
			modifier.ValidWeaponMultiplier = 1 + bonus
		end
	end
	trait.BoonEditMoltenGlowBonus = bonus
end
