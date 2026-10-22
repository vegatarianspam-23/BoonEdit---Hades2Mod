---@meta _


local PHIAL = 'FountainRarityKeepsake'

once('AromaticPhial', function()
	if not boon_edit_on('AromaticPhial') then return end

	local phial = game.TraitData[PHIAL]
	if not phial or not phial.RarityLevels or not phial.RarityLevels.Epic then return end

	phial.RarityLevels.Heroic = phial.RarityLevels.Heroic
		or { Multiplier = phial.RarityLevels.Epic.Multiplier }
end)


function aromatic_phial_apply()
	if not boon_edit_on('AromaticPhial') then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	local trait = game.GetHeroTrait(PHIAL)
	if not trait or not trait.FountainRarity then return end

	trait.FountainRarity.NumTraits = trait.Rarity == 'Heroic'
		and mod.tuning.AromaticPhial.HeroicBlessings
		or mod.tuning.AromaticPhial.Blessings

	game.ExtractValues(hero, trait, trait)
end
