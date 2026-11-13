---@meta _
---@diagnostic disable: lowercase-global


boon_edit_trial({
	Id = _PLUGIN.guid .. '_TrialOfEmbers',
	Title = 'Trial of Embers',
	Description = 'Carry Hestia\'s flame through the Fields of Mourning, keep it out of the rain, set Cerberus alight, and carry it down to Chronos.',
	Difficulty = 4,
	BiomeChar = 'H',
	SingleBiome = false,
	IsStandardBounty = true,

	BaseData = {
		InheritFrom = { 'DefaultPackagedBounty', 'BasePackageBountyBiomeH' },
		Encounters = { 'BossChronos01', 'BossChronos02' },

		WeaponKitName = 'WeaponTorch',
		WeaponUpgradeName = 'TorchSpecialDurationAspect',
		KeepsakeName = 'ForceHestiaBoonKeepsake',
		FamiliarName = 'CatFamiliar',

		MetaUpgradeStateEquipped = {
			'ChanneledCast',
			'CastCount',
			'SorceryRegenUpgrade',
			'CastBuff',
			'BonusDodge',
			'SprintShield',
			'MaxHealthPerRoom',
			'StatusVulnerability',
			'LastStand',
			'RarityBoost',
			'BonusRarity',
		},

		ShrineUpgradesActive = {
			EnemyDamageShrineUpgrade = 1,
			EnemyHealthShrineUpgrade = 1,
			EnemySpeedShrineUpgrade = 2,
			MinibossCountShrineUpgrade = 1,
			BossDifficultyShrineUpgrade = 4,
			EnemyShieldShrineUpgrade = 2,
			EnemyCountShrineUpgrade = 3,
			NextBiomeEnemyShrineUpgrade = 2,
			EnemyRespawnShrineUpgrade = 2,
			EnemyEliteShrineUpgrade = 2,
		},

		StartingTraits = {
			{ Name = 'HeraWeaponBoon', Rarity = 'Epic' },
			{ Name = 'HestiaSpecialBoon', Rarity = 'Epic' },
			{ Name = 'PoseidonCastBoon', Rarity = 'Epic' },
			{ Name = 'HestiaSprintBoon', Rarity = 'Epic' },
			{ Name = 'DemeterManaBoon', Rarity = 'Epic' },
			{ Name = 'FireballManaSpecialBoon', Rarity = 'Epic' },
			{ Name = 'BurnStackBoon', Rarity = 'Epic' },
			{ Name = 'BurnExplodeBoon', Rarity = 'Epic' },
			{ Name = 'AloneDamageBoon', Rarity = 'Epic' },
			{ Name = 'OmegaPoseidonProjectileBoon', Rarity = 'Epic' },
			{ Name = 'HermesSpecialBoon', Rarity = 'Epic' },
			{ Name = 'BurnSprintBoon' },
			{ Name = 'TorchDiscountExAttackTrait' },
			{ Name = boon_edit_trial_stats('BoonEditTrialOfEmbersStart', { MaxHealth = 150, MaxMana = 100, Money = 200 }) },
		},

		RunOverrides = {
			MaxGodsPerRun = 4,
			LootTypeHistory = {
				HestiaUpgrade = 1,
				PoseidonUpgrade = 1,
				HeraUpgrade = 1,
				DemeterUpgrade = 1,
			},
		},

		UnlockGameStateRequirements = {
			NamedRequirements = { 'PackageBountyBiomeH' },
		},
	},
})
