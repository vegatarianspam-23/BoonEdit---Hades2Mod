---@meta _


local GLOW_EFFECT = 'DelayedKnockbackEffect'

once('SmolderingForge', function()
	if not boon_edit_on('SmolderingForge') then return end

	local forge = game.TraitData.SlamManaBurstBoon
	local tuning = mod.tuning.SmolderingForge

	forge.BoonEditBurstArgs = forge.OnProjectileCreationFunction and forge.OnProjectileCreationFunction.Args
	forge.OnProjectileCreationFunction = nil

	forge.BoonEditHeartthrobChance = tuning.HeartthrobChance

	local weapons = game.AddLinkedWeapons(game.WeaponSets.HeroPrimarySecondaryWeapons)
	forge.OnEnemyDamagedAction = {
		FunctionName = _PLUGIN.guid .. '.SmolderingForgeHeartthrob',
		ValidWeapons = weapons,
		ValidWeaponsLookup = game.ToLookup(weapons),
	}

	forge.FlavorText = 'BoonEditSmolderingForgeFlavorText'
	forge.StatLines = { 'BoonEditSmolderingForgeStatDisplay' }
	forge.ExtractValues = with_keyword_extracts({
		{
			Key = 'BoonEditHeartthrobChance',
			ExtractAs = 'Chance',
			Format = 'LuckModifiedPercent',
			HideSigns = true,
		},
	}, 'HeartBurst', 'DelayedKnockback')
end)


---@diagnostic disable-next-line: unused-local
function mod.SmolderingForgeHeartthrob(victim, functionArgs, triggerArgs)
	if not boon_edit_on('SmolderingForge') then return end

	if not victim or not victim.ActiveEffects or not victim.ActiveEffects[GLOW_EFFECT] then return end
	if not rolls(mod.tuning.SmolderingForge.HeartthrobChance) then return end

	local forge = game.GetHeroTrait('SlamManaBurstBoon')
	create_heartthrob(forge and forge.BoonEditBurstArgs)
end
