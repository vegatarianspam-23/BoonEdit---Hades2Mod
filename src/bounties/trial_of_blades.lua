---@meta _
---@diagnostic disable: lowercase-global


boon_edit_trial({
	Id = _PLUGIN.guid .. '_TrialOfBlades',
	Title = 'Trial of Blades',
	Description = 'Cut a path through Thessaly in a rain of steel, and see whether Eris can keep up.',
	Difficulty = 4,
	BiomeChar = 'O',
	SingleBiome = true,
	IsStandardBounty = true,

	BaseData = {
		InheritFrom = { 'DefaultPackagedBounty', 'BasePackageBountyBiomeO' },

		WeaponKitName = 'WeaponTorch',
		WeaponUpgradeName = 'TorchAutofireAspect',
		KeepsakeName = 'ForceAresBoonKeepsake',
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
			EnemySpeedShrineUpgrade = 2,
			MinibossCountShrineUpgrade = 1,
			BossDifficultyShrineUpgrade = 4,
			EnemyCountShrineUpgrade = 2,
			NextBiomeEnemyShrineUpgrade = 2,
		},

		StartingTraits = {
			{ Name = 'HephaestusWeaponBoon', Rarity = 'Epic' },
			{ Name = 'AresSpecialBoon', Rarity = 'Epic' },
			{ Name = 'ApolloCastBoon', Rarity = 'Epic' },
			{ Name = 'AresSprintBoon', Rarity = 'Epic' },
			{ Name = 'HephaestusManaBoon', Rarity = 'Epic' },
			{ Name = 'OmegaDelayedDamageBoon', Rarity = 'Epic' },
			{ Name = 'SprintShieldBoon', Rarity = 'Epic' },
			{ Name = 'HermesSpecialBoon', Rarity = 'Epic' },
			{ Name = 'SorcerySpeedBoon', Rarity = 'Epic' },
			{ Name = 'TorchAutofireSprintTrait' },
			{ Name = boon_edit_trial_stats('BoonEditTrialOfBladesStart', { MaxHealth = 100, MaxMana = 100, Money = 100 }) },
		},

		RunOverrides = {
			MaxGodsPerRun = 3,
			LootTypeHistory = {
				AresUpgrade = 1,
				HephaestusUpgrade = 1,
				ApolloUpgrade = 1,
			},
		},

		UnlockGameStateRequirements = {
			NamedRequirements = { 'PackageBountyBiomeO' },
		},
	},
})
