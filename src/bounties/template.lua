---@meta _
---@diagnostic disable: lowercase-global

-- Neutral Chaos Trial template. This file is never imported, so it never loads.
--
-- As written it plays like an ordinary run of one region with your own setup: your current weapon,
-- aspect, keepsake, familiar, Arcana and Fear, no starting boons and vanilla offers.
--
-- To make a trial: copy this file to src/bounties/<name>.lua, change the Id, Title and Description,
-- uncomment the levers you want, then import the copy inside the once('Trials', ...) block in
-- src/reload.lua. Field reference: Hades2ModNotes/BoonEdits/CHAOS_TRIALS.md.
--
-- Every BoonEdits trial switches on all non-experimental BoonEdits changes for the run, whatever the
-- config says.


boon_edit_trial({
	-- Unique name. BountyAPI prefixes it, so keep _PLUGIN.guid in front.
	Id = _PLUGIN.guid .. '_TrialOfSomething',

	-- Text on the Pitch-Black Stone. English only.
	Title = 'Trial of Something',
	Description = 'One line shown on the Pitch-Black Stone.',

	-- Skulls shown on the stone, 1 to 5.
	Difficulty = 3,

	-- Starting region: F G H I (Underworld) or N O P Q (surface).
	-- Keep it in sync with BasePackageBountyBiome<X> and PackageBountyBiome<X> below.
	BiomeChar = 'F',

	-- true: ends at this region's Guardian. false: runs to the end of the route (Chronos or Typhon).
	SingleBiome = true,

	-- true: behaves like a Chaos Trial (no harvest points, no story encounters).
	IsStandardBounty = true,

	-- Optional BountyAPI hooks. `store` is a table saved with the run.
	-- DataOverrides = function(RegisterValues) end,               -- game-table overrides for the trial only
	-- SetupFunctions = function(store, fromSave) end,             -- trial starts or resumes from a save
	-- RoomTransition = function(store, roomName) end,             -- return a room name to force the next room
	-- CanEnd = function(store, roomName) return true end,         -- return false to keep going past the Guardian
	-- EndFunctions = function(store, cleared) end,                -- run ends

	BaseData = {
		InheritFrom = { 'DefaultPackagedBounty', 'BasePackageBountyBiomeF' },

		-- Loadout. Leave a line commented out to keep what the player has equipped.
		-- WeaponKitName needs a WeaponUpgradeName too: without one the trial board crashes when it draws the weapon icon.
		-- WeaponKitName = 'WeaponStaffSwing',
		-- RandomWeaponKitNames = { 'WeaponStaffSwing', 'WeaponDagger' },
		-- WeaponUpgradeName = 'StaffClearCastAspect',
		-- UseRandomWeaponUpgrade = true,
		-- KeepsakeName = 'ForceZeusBoonKeepsake',
		-- RandomKeepsakeNames = { 'ForceZeusBoonKeepsake', 'ForceHeraBoonKeepsake' },
		-- FamiliarName = 'FrogFamiliar',
		-- RandomFamiliarNames = { 'FrogFamiliar', 'CatFamiliar' },
		-- RemoveFamiliar = true,

		-- Arcana. Leave both commented out to keep the player's own set.
		-- MetaUpgradeStateEquipped = { 'ChanneledCast', 'HealthRegen', 'LowHealthBonus' },
		-- RandomMetaUpgradeCostTotal = 10,

		-- Fear. Leave both commented out to keep the player's own vows.
		-- ShrineUpgradesActive = { EnemyHealthShrineUpgrade = 2, BossDifficultyShrineUpgrade = 1 },
		-- RandomShrineUpgradePointTotal = 10,

		-- Boons and other traits held from the start. Offer requirements are skipped; Rarity = 'Duo' works.
		-- StartingTraits = {
		-- 	{ Name = 'AphroditeManaBoon', Rarity = 'Epic' },
		-- 	-- Starting max health, max Magick and gold, as totals. Arcana bonuses still stack on top.
		-- 	{ Name = boon_edit_trial_stats('BoonEditTrialOfSomethingStart', { MaxHealth = 150, MaxMana = 100, Money = 200 }) },
		-- },

		-- The opening reward. ForcedUpgradeOptions fixes the exact boon menu.
		-- ForcedRewards = {
		-- 	{
		-- 		Name = 'Boon',
		-- 		LootName = 'ZeusUpgrade',
		-- 		ForcedUpgradeOptions = {
		-- 			{ Type = 'Trait', ItemName = 'ZeusWeaponBoon', Rarity = 'Epic' },
		-- 		},
		-- 	},
		-- },

		-- Fields copied straight onto CurrentRun. LootTypeHistory seeds which gods have already appeared.
		-- RunOverrides = {
		-- 	MaxGodsPerRun = 2,
		-- 	LootTypeHistory = { ZeusUpgrade = 1, HeraUpgrade = 1 },
		-- },

		-- Fields copied onto the first room.
		-- StartingRoomOverrides = {},

		-- Regional weather: 'Rain' or 'VanillaState'.
		-- ForcedBiomeState = 'Rain',

		-- Room-reward pools: RunProgress, MetaProgress, HubRewards, SubRoomRewards, SubRoomRewardsHard.
		-- RewardStoreOverrides = {
		-- 	RunProgress = {
		-- 		{ Name = 'Boon', LootName = 'ZeusUpgrade', AllowDuplicates = true },
		-- 		{ Name = 'MaxHealthDrop' },
		-- 	},
		-- },

		-- Clear reward. BountyAPI defaults to a Diamond (GemPointsBigDrop) when this is left out.
		-- LootOptions = {
		-- 	{ Name = 'GemPointsBigDrop', Overrides = { CanDuplicate = false } },
		-- },

		-- When the trial appears on the stone. Add more conditions to gate it further.
		UnlockGameStateRequirements = {
			NamedRequirements = { 'PackageBountyBiomeF' },
		},

		-- Extra conditions for counting as cleared. Empty in DefaultPackagedBounty.
		-- CompleteGameStateRequirements = {},
	},
})
