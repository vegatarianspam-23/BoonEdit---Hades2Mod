---@meta _
---@diagnostic disable: lowercase-global


local noBoons = { 'Boon', 'HermesUpgrade', 'Devotion', 'TrialUpgrade' }

boon_edit_trial({
	Id = _PLUGIN.guid .. '_TrialOfRevelry',
	Title = 'Trial of Revelry',
	Description = 'Stagger through Ephyra on what you started with and no god willing to top you up, and drink Polyphemus under the table.',
	Difficulty = 4,
	BiomeChar = 'N',
	SingleBiome = true,
	IsStandardBounty = true,
	RewardFallback = 'MaxHealthDrop',

	ShopBlocked = { 'RandomLoot', 'BlindBoxLoot', 'ShopHermesUpgrade' },

	BaseData = {
		InheritFrom = { 'DefaultPackagedBounty', 'BasePackageBountyBiomeN' },

		WeaponKitName = 'WeaponLob',
		WeaponUpgradeName = 'LobAmmoBoostAspect',
		KeepsakeName = 'SkipEncounterKeepsake',
		FamiliarName = 'FrogFamiliar',

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
			{ Name = 'CastLobBoon', Rarity = 'Epic' },
			{ Name = 'HermesWeaponBoon', Rarity = 'Epic' },
			{ Name = 'HermesCastDiscountBoon', Rarity = 'Heroic' },
			{ Name = 'LuckyBoon', Rarity = 'Heroic' },
			{ Name = 'MoneyDamageBoon', Rarity = 'Epic' },
			{ Name = 'TimeStopLastStandBoon', Rarity = 'Legendary' },
			{ Name = 'FogDamageBonusBoon', Rarity = 'Epic' },
			{ Name = 'HiddenMaxHealthBoon', Rarity = 'Epic' },
		},

		ForcedRewards = {
			{ Name = 'MaxHealthDrop' },
		},

		RewardStoreOverrides = boon_edit_trial_rewards_without(noBoons, 'MaxHealthDrop'),

		UnlockGameStateRequirements = {
			NamedRequirements = { 'PackageBountyBiomeN' },
		},
	},
})
