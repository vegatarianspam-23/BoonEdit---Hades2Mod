---@meta _
---@diagnostic disable: lowercase-global


local CHARISMA_SPELL = 'Summon'

local CHARISMA_NO_SPELL_DROP = {
	{ PathTrue = { 'CurrentRun', 'BoonEditTrialOfCharismaSpellDrop' } },
}

local CHARISMA_TALENT_LEGAL = {
	{ Path = { 'GameState', 'UseRecord', 'SpellDrop' }, Comparison = '>=', Value = 4 },
	{ FunctionName = 'RequiredNotInStore', FunctionArgs = { Name = 'TalentDrop' } },
	{ PathFalse = { 'CurrentRun', 'AllSpellInvestedCache' } },
}


local charisma_bounty = nil

local function charisma_active()
	local run = game.CurrentRun
	return run ~= nil and charisma_bounty ~= nil and run.ActiveBounty == charisma_bounty
end


local function charisma_debug(label)
	if not charisma_active() then return end
	local run = game.CurrentRun
	local hero = run.Hero
	local priorities = table.concat(run.RewardPriorities or {}, ',')
	print(string.format('[SWu-BoonEdits] TrialOfCharisma: %s | UseRecord.SpellDrop=%s SlottedSpell=%s priorities=[%s] talentPoints=%s',
		label,
		tostring(run.UseRecord and run.UseRecord.SpellDrop),
		tostring(hero and hero.SlottedSpell and hero.SlottedSpell.Name),
		priorities,
		tostring(run.NumTalentPoints)))
end


modutil.mod.Path.Wrap('OpenSpellScreen', function(base, ...)
	charisma_debug('OpenSpellScreen')
	if debug and debug.traceback and charisma_active() then
		print(debug.traceback('[SWu-BoonEdits] TrialOfCharisma: OpenSpellScreen caller', 2))
	end
	return base(...)
end)


local function charisma_full_moonglow()
	local bonuses = game.SpellTalentData and game.SpellTalentData.InitialBonuses or {}
	local best = 0
	for _, bonus in pairs(bonuses) do
		best = math.max(best, bonus.BonusPoints or 0)
	end
	return best
end


local function charisma_grant_hex(store, fromSave)
	charisma_debug(fromSave and 'setup from save' or 'setup before grant')
	if fromSave then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	local spellData = game.SpellData[CHARISMA_SPELL]
	if not hero or not spellData then return end

	local spellTrait = game.AddTraitToHero({ TraitName = spellData.TraitName, SkipNewTraitHighlight = true })
	if spellTrait and spellTrait.CheckChargeFunctionName then
		game.thread(game.CallFunctionName, spellTrait.CheckChargeFunctionName, hero)
	end

	hero.SlottedSpell = game.DeepCopyTable(spellData)
	hero.SlottedSpell.HasDuoTalent = true
	hero.SlottedSpell.Talents = game.DeepCopyTable(game.CreateTalentTree(spellData))

	game.CurrentRun.NumTalentPoints = (game.CurrentRun.NumTalentPoints or 0) + charisma_full_moonglow()

	game.CurrentRun.UseRecord = game.CurrentRun.UseRecord or {}
	game.CurrentRun.UseRecord.SpellDrop = math.max(game.CurrentRun.UseRecord.SpellDrop or 0, 1)
	for index, name in ipairs(game.CurrentRun.RewardPriorities or {}) do
		if name == 'SpellDrop' then
			game.CurrentRun.RewardPriorities[index] = 'TalentDrop'
		end
	end

	game.UpdateTalentPointInvestedCache()
	game.UpdateSpellActiveStatus()
	game.UpdateHeroTraitDictionary()
	charisma_debug('setup after grant')
end


local charisma_spec = {
	Id = _PLUGIN.guid .. '_TrialOfCharisma',
	Title = 'Trial of Charisma',
	Description = 'Brave the depths of Oceanus with Hera, Aphrodite and Apollo, an army of admirers at your back, and settle things with Scylla and her Sirens.',
	Difficulty = 4,
	BiomeChar = 'G',
	SingleBiome = true,
	IsStandardBounty = true,

	DataOverrides = {
		{
			Table = game.NamedRequirementsData,
			Keys = { 'SpellDropRequirements', 'TalentLegal' },
			Values = { CHARISMA_NO_SPELL_DROP, CHARISMA_TALENT_LEGAL },
		},
	},

	SetupFunctions = charisma_grant_hex,

	BaseData = {
		InheritFrom = { 'DefaultPackagedBounty', 'BasePackageBountyBiomeG' },

		WeaponKitName = 'WeaponAxe',
		WeaponUpgradeName = 'AxeRecoveryAspect',
		KeepsakeName = 'SpellTalentKeepsake',
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
			EnemyShieldShrineUpgrade = 2,
			EnemyCountShrineUpgrade = 3,
			NextBiomeEnemyShrineUpgrade = 2,
			EnemyRespawnShrineUpgrade = 2,
			EnemyEliteShrineUpgrade = 2,
		},

		StartingTraits = {
			{ Name = 'LuckyBoon', Rarity = 'Epic' },
			{ Name = 'AphroditeWeaponBoon', Rarity = 'Epic' },
			{ Name = 'HeraManaBoon', Rarity = 'Epic' },
			{ Name = 'HeraSpecialBoon', Rarity = 'Epic' },
			{ Name = 'AphroditeSprintBoon', Rarity = 'Epic' },
			{ Name = 'ApolloCastBoon', Rarity = 'Epic' },
			{ Name = 'RaiseDeadBoon', Rarity = 'Duo' },
			{ Name = 'RandomStatusBoon', Rarity = 'Duo' },
			{ Name = 'OlympianSpellCountBoon', Rarity = 'Epic' },
			{ Name = 'SorceryCritBoon', Rarity = 'Epic' },
			{ Name = 'HighHealthOffenseBoon', Rarity = 'Epic' },
			{ Name = 'CirceSorceryDamageBoon' },
			{ Name = boon_edit_trial_stats('BoonEditTrialOfCharismaStart', { MaxHealth = 100, MaxMana = 100, Money = 100 }) },
		},

		RunOverrides = {
			MaxGodsPerRun = 3,
			LootTypeHistory = {
				HeraUpgrade = 1,
				AphroditeUpgrade = 1,
				ApolloUpgrade = 1,
			},
		},

		UnlockGameStateRequirements = {
			NamedRequirements = { 'PackageBountyBiomeG' },
		},
	},
}

boon_edit_trial(charisma_spec)
charisma_bounty = charisma_spec.BaseData.Name
