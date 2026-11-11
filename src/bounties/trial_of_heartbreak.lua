---@meta _
---@diagnostic disable: lowercase-global


boon_edit_trial({
	Id = _PLUGIN.guid .. '_TrialOfHeartbreak',
	Title = 'Trial of Heartbreak',
	Description = 'Wander the Fields of Mourning with blood on your hands and a broken heart, and put Cerberus to rest.',
	Difficulty = 4,
	BiomeChar = 'H',
	SingleBiome = true,
	IsStandardBounty = true,

	BaseData = {
		InheritFrom = { 'DefaultPackagedBounty', 'BasePackageBountyBiomeH' },

		WeaponKitName = 'WeaponDagger',
		WeaponUpgradeName = 'DaggerBackstabAspect',
		KeepsakeName = 'ForceAphroditeBoonKeepsake',
		FamiliarName = 'PolecatFamiliar',

		MetaUpgradeStateEquipped = {
			'ChanneledCast',
			'CastCount',
			'SorceryRegenUpgrade',
			'CastBuff',
			'BonusDodge',
			'SprintShield',
			'MaxHealthPerRoom',
			'StatusVulnerability',
			'LowHealthBonus',
			'RarityBoost',
			'BonusRarity',
		},

		ShrineUpgradesActive = {
			EnemyDamageShrineUpgrade = 1,
			EnemyHealthShrineUpgrade = 1,
			EnemySpeedShrineUpgrade = 2,
			MinibossCountShrineUpgrade = 1,
			BossDifficultyShrineUpgrade = 4,
		},

		StartingTraits = {
			{ Name = 'AphroditeWeaponBoon', Rarity = 'Epic' },
			{ Name = 'AresSpecialBoon', Rarity = 'Epic' },
			{ Name = 'HephaestusCastBoon', Rarity = 'Epic' },
			{ Name = 'HephaestusSprintBoon', Rarity = 'Epic' },
			{ Name = 'AresManaBoon', Rarity = 'Epic' },
			{ Name = 'LowHealthLifestealBoon', Rarity = 'Epic' },
			{ Name = 'AresExCastBoon', Rarity = 'Epic' },
			{ Name = 'HermesCastDiscountBoon', Rarity = 'Epic' },
			{ Name = 'LuckyBoon', Rarity = 'Epic' },
			{ Name = 'RendBloodDropBoon', Rarity = 'Epic' },
			{ Name = 'ManaBurstBoon', Rarity = 'Epic' },
			{ Name = 'AntiArmorBoon', Rarity = 'Epic' },
			{ Name = 'SlamManaBurstBoon', Rarity = 'Epic' },
			{ Name = 'BloodManaBurstBoon', Rarity = 'Epic' },
			{ Name = 'DaggerSpecialJumpTrait' },
			{ Name = 'DaggerChargeStageSkipTrait' },
			{ Name = boon_edit_trial_stats('BoonEditTrialOfHeartbreakStart', { MaxHealth = 150, MaxMana = 100, Money = 200 }) },
		},

		RunOverrides = {
			MaxGodsPerRun = 3,
			LootTypeHistory = {
				AphroditeUpgrade = 1,
				AresUpgrade = 1,
				HephaestusUpgrade = 1,
			},
		},

		UnlockGameStateRequirements = {
			NamedRequirements = { 'PackageBountyBiomeH' },
		},
	},
})
