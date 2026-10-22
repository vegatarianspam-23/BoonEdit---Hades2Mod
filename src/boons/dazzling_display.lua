---@meta _


local DAZZLING_TRAIT = 'BlindChanceBoon'
local NOVA_STRIKE = 'ApolloWeaponBoon'
local NOVA_FLOURISH = 'ApolloSpecialBoon'
local BLIND_EFFECT = 'BlindEffect'


once('DazzlingDisplayNovaOnly', function()
	if not boon_edit_on('DazzlingDisplay') then return end

	local trait = game.TraitData[DAZZLING_TRAIT]
	local tuning = mod.tuning.DazzlingDisplay

	for rarity, multiplier in pairs(tuning.PotencyRarityMultipliers) do
		if trait.RarityLevels[rarity] then
			trait.RarityLevels[rarity].Multiplier = multiplier
		end
	end

	trait.OnEnemyDamagedAction = {
		ValidWeapons = {},
		FunctionName = _PLUGIN.guid .. '.DazzlingDisplayBlind',
		Args = {
			Chance = tuning.Chance,
			MissChanceBonus = { BaseValue = tuning.PotencyBonus },
			ReportValues = { ReportedMissBonus = 'MissChanceBonus' },
		},
	}

	trait.StatLines = { 'BoonEditDazzlingPotencyStatDisplay' }

	trait.ExtractValues = with_keyword_extracts({
		{ Key = 'ReportedMissBonus', ExtractAs = 'MissBonus', Format = 'Percent', IncludeSigns = true },
	}, 'Blind')

	modutil.mod.Path.Wrap('AddTraitToHero', function(base, args)
		local added = base(args)
		dazzling_display_widen()
		return added
	end)
end)


function dazzling_display_widen()
	if not boon_edit_on('DazzlingDisplay') then return end

	local trait = game.GetHeroTrait(DAZZLING_TRAIT)
	local action = trait and trait.OnEnemyDamagedAction
	if not action then return end

	local weapons = {}
	if game.HeroHasTrait(NOVA_STRIKE) then
		weapons = game.ConcatTableValues(weapons, game.WeaponSets.HeroPrimaryWeapons)
	end
	if game.HeroHasTrait(NOVA_FLOURISH) then
		weapons = game.ConcatTableValues(weapons, game.WeaponSets.HeroSecondaryWeapons)
	end

	weapons = game.AddLinkedWeapons(weapons)
	action.ValidWeapons = weapons
	action.ValidWeaponsLookup = game.ToLookup(weapons)
end


---@diagnostic disable-next-line: unused-local
function mod.DazzlingDisplayBlind(victim, args, triggerArgs)
	if not boon_edit_on('DazzlingDisplay') then return end
	if not victim or not rolls(args.Chance) then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	local vanilla = game.EffectData[BLIND_EFFECT].EffectData
	game.ApplyEffect({
		DestinationId = victim.ObjectId,
		Id = hero.ObjectId,
		EffectName = BLIND_EFFECT,
		DataProperties = game.MergeAllTables({
			vanilla,
			{ MissChance = vanilla.MissChance + (args.MissChanceBonus or 0) },
		}),
	})
end
