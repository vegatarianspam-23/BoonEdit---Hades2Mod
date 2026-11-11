---@meta _
---@diagnostic disable: lowercase-global


boon_edit_trial({
	Id = _PLUGIN.guid .. '_TrialOfStorms',
	Title = 'Trial of Storms',
	Description = 'Ride frost and lightning from Mount Olympus to the Summit, and bring the storm down on Typhon.',
	Difficulty = 5,
	BiomeChar = 'P',
	SingleBiome = false,
	IsStandardBounty = true,

	BaseData = {
		InheritFrom = { 'DefaultPackagedBounty', 'BasePackageBountyBiomeP' },
		Encounters = { 'BossTyphonHead01', 'BossTyphonHead02' },

		WeaponKitName = 'WeaponStaffSwing',
		WeaponUpgradeName = 'StaffClearCastAspect',
		KeepsakeName = 'ForceZeusBoonKeepsake',
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
			{ Name = 'ZeusWeaponBoon', Rarity = 'Epic' },
			{ Name = 'AresSpecialBoon', Rarity = 'Epic' },
			{ Name = 'DemeterCastBoon', Rarity = 'Epic' },
			{ Name = 'ApolloSprintBoon', Rarity = 'Epic' },
			{ Name = 'ZeusManaBoon', Rarity = 'Epic' },
			{ Name = 'ApolloExCastBoon', Rarity = 'Epic' },
			{ Name = 'AresExCastBoon', Rarity = 'Epic' },
			{ Name = 'CastNovaBoon', Rarity = 'Epic' },
			{ Name = 'RootDurationBoon', Rarity = 'Epic' },
			{ Name = 'StormSpawnBoon', Rarity = 'Epic' },
			{ Name = 'ApolloSecondStageCastBoon', Rarity = 'Epic' },
			{ Name = 'HermesCastDiscountBoon', Rarity = 'Epic' },
			{ Name = 'HermesSpecialBoon', Rarity = 'Epic' },
			{ Name = 'SelfCastBoon' },
			{ Name = 'StaffFastSpecialTrait' },
			{ Name = 'StaffJumpSpecialTrait' },
			{ Name = boon_edit_trial_stats('BoonEditTrialOfStormsStart', { MaxHealth = 150, MaxMana = 100, Money = 200 }) },
		},

		RunOverrides = {
			MaxGodsPerRun = 4,
			LootTypeHistory = {
				ZeusUpgrade = 1,
				DemeterUpgrade = 1,
				ApolloUpgrade = 1,
				AresUpgrade = 1,
			},
		},

		UnlockGameStateRequirements = {
			NamedRequirements = { 'PackageBountyBiomeP' },
		},
	},
})
