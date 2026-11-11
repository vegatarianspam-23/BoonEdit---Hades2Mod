---@meta _
---@diagnostic disable: lowercase-global


boon_edit_trial({
	Id = _PLUGIN.guid .. '_TrialOfArrows',
	Title = 'Trial of Arrows',
	Description = 'Hunt through Erebus with Artemis and Hermes at your side and no other god to call on, and bring down Hecate.',
	Difficulty = 3,
	BiomeChar = 'F',
	SingleBiome = true,
	IsStandardBounty = true,
	RewardFallback = 'MaxManaDrop',

	ShopItems = {
		'MaxManaDrop',
		'MaxManaDropBig',
		'SpellDrop',
		'TalentDrop',
		'WeaponUpgradeDrop',
		'HealDropRange',
		'HealBigDrop',
		'RoomRewardHealDrop',
	},

	BaseData = {
		InheritFrom = { 'DefaultPackagedBounty', 'BasePackageBountyBiomeF' },

		WeaponKitName = 'WeaponStaffSwing',
		WeaponUpgradeName = 'StaffClearCastAspect',
		KeepsakeName = 'LowHealthCritKeepsake',
		FamiliarName = 'RavenFamiliar',

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
			{ Name = 'OmegaCastVolleyBoon', Rarity = 'Epic' },
			{ Name = 'SupportingFireBoon', Rarity = 'Epic' },
			{ Name = 'MoneyDamageBoon', Rarity = 'Epic' },
			{ Name = 'HermesCastDiscountBoon', Rarity = 'Epic' },
			{ Name = 'HermesSpecialBoon', Rarity = 'Epic' },
			{ Name = 'HighHealthCritBoon', Rarity = 'Epic' },
			{ Name = 'HermesWeaponBoon', Rarity = 'Epic' },
			{ Name = 'CritBonusBoon', Rarity = 'Epic' },
		},

		ForcedRewards = {
			{ Name = 'MaxManaDrop' },
		},

		RewardStoreOverrides = boon_edit_trial_rewards({
			'MaxManaDrop',
			'MaxManaDropSmall',
			'MaxManaDropBig',
			'SpellDrop',
			'TalentDrop',
			'MinorTalentDrop',
			'WeaponUpgrade',
		}, 'MaxManaDrop'),

		UnlockGameStateRequirements = {
			NamedRequirements = { 'PackageBountyBiomeF' },
		},
	},
})
