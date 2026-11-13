---@meta _
---@diagnostic disable: lowercase-global


boon_edit_trial({
	Id = _PLUGIN.guid .. '_TrialOfDevotion',
	Title = 'Trial of Devotion',
	Description = 'Climb Mount Olympus bound to Hera and Aphrodite alone, and settle things with Prometheus.',
	Difficulty = 4,
	BiomeChar = 'P',
	SingleBiome = true,
	IsStandardBounty = true,

	BaseData = {
		InheritFrom = { 'DefaultPackagedBounty', 'BasePackageBountyBiomeP' },

		WeaponKitName = 'WeaponDagger',
		WeaponUpgradeName = 'DaggerBlockAspect',
		KeepsakeName = 'ForceAphroditeBoonKeepsake',
		FamiliarName = 'HoundFamiliar',

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
			{ Name = 'HeraSpecialBoon', Rarity = 'Epic' },
			{ Name = 'HeraCastBoon', Rarity = 'Epic' },
			{ Name = 'AphroditeManaBoon', Rarity = 'Epic' },
			{ Name = 'AphroditeSprintBoon', Rarity = 'Epic' },
			{ Name = 'FocusRawDamageBoon', Rarity = 'Epic' },
			{ Name = 'WeakPotencyBoon', Rarity = 'Epic' },
			{ Name = 'DamageSharePotencyBoon', Rarity = 'Epic' },
			{ Name = 'SpawnCastDamageBoon', Rarity = 'Epic' },
			{ Name = 'SorcerySpeedBoon', Rarity = 'Epic' },
			{ Name = 'LuckyBoon', Rarity = 'Epic' },
			{ Name = 'CommonGlobalDamageBoon', Rarity = 'Epic' },
			{ Name = 'DaggerRapidAttackTrait' },
			{ Name = boon_edit_trial_stats('BoonEditTrialOfDevotionStart', { MaxHealth = 150, MaxMana = 100, Money = 200 }) },
		},

		RunOverrides = {
			MaxGodsPerRun = 2,
			LootTypeHistory = {
				HeraUpgrade = 1,
				AphroditeUpgrade = 1,
			},
		},

		RewardStoreOverrides = boon_edit_trial_rewards_without({ 'HermesUpgrade', 'TrialUpgrade' }, 'Boon'),

		UnlockGameStateRequirements = {
			NamedRequirements = { 'PackageBountyBiomeP' },
		},
	},
})
