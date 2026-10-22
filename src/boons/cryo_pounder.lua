---@meta _


local GLOW_EFFECT = 'DelayedKnockbackEffect'

once('CryoPounderGlow', function()
	if not boon_edit_on('CryoPounder') then return end

	local modifiers = game.TraitData.ClearRootBoon.AddOutgoingDamageModifiers

	modifiers.ValidProjectiles = nil
	modifiers.ValidProjectilesLookup = nil

	modifiers.ValidActiveEffects = { GLOW_EFFECT }
	modifiers.ActiveRootMultiplier = mod.tuning.CryoPounder.FrozenGlowMultiplier
end)
