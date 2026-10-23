---@meta _


HEIRLOOM_USE_KEYS = { 'Uses', 'RemainingUses', 'BoonConversionUses' }


function heirloom_requip_fresh(trait)
	local traitName = trait.Name
	local rarity = trait.Rarity or game.GetRarityKey(game.GetKeepsakeLevel(traitName))

	local carried = {}
	local carriedRarify = nil
	if mod.tuning.CherishedHeirloom.CarryUses then
		for _, key in ipairs(HEIRLOOM_USE_KEYS) do
			local held = trait[key]
			if type(held) == 'number' and held > 0 then carried[key] = held end
		end
		local rarify = trait.RarityUpgradeData and trait.RarityUpgradeData.Uses
		if type(rarify) == 'number' and rarify > 0 then carriedRarify = rarify end
	end

	game.UnequipKeepsake(game.CurrentRun.Hero, traitName, { SkipValidateHealth = true, AdvanceKeepsakeMoment = true })
	game.EquipKeepsake(game.CurrentRun.Hero, traitName, { ForceRarity = rarity, FromLoot = true })

	local fresh = game.GetHeroTrait(traitName)
	if not fresh then return fresh end

	local restored = false
	for key, amount in pairs(carried) do
		if type(fresh[key]) == 'number' then
			fresh[key] = fresh[key] + amount
			restored = true
		end
	end
	if carriedRarify and fresh.RarityUpgradeData and type(fresh.RarityUpgradeData.Uses) == 'number' then
		fresh.RarityUpgradeData.Uses = fresh.RarityUpgradeData.Uses + carriedRarify
		restored = true
	end
	if restored then game.UpdateTraitNumber(fresh) end

	return fresh
end


local function heirloom_unexpire(fresh, defaults)
	fresh.CustomName = defaults.CustomName
	fresh.CustomTrayText = defaults.CustomTrayText
	if game.CurrentRun.ExpiredKeepsakes then game.CurrentRun.ExpiredKeepsakes[fresh.Name] = nil end
end

local function heirloom_reset(keys)
	return function(fresh, old, defaults)
		for _, key in ipairs(keys) do
			fresh[key] = defaults[key]
		end
		if fresh.RarityUpgradeData and defaults.RarityUpgradeData then
			fresh.RarityUpgradeData.Uses = defaults.RarityUpgradeData.Uses
		end
		heirloom_unexpire(fresh, defaults)
	end
end

local function heirloom_rescale(value, base, oldStep, newStep)
	if type(value) ~= 'number' or not oldStep or oldStep == 0 or not newStep then return value end
	return base + (value - base) * newStep / oldStep
end


HEIRLOOM_KEEPSAKE_PREPARE = {
	ReincarnationKeepsake = function()
		local hero = game.CurrentRun.Hero
		for _, lastStand in ipairs(hero.LastStands or {}) do
			if lastStand.Name == 'ReincarnationKeepsake' then return end
		end
		table.insert(hero.LastStands, { Name = 'ReincarnationKeepsake' })
	end,

	SpellTalentKeepsake = function()
		return { TalentPoints = game.CurrentRun.NumTalentPoints or 0 }
	end,
}


HEIRLOOM_KEEPSAKE_REFRESH = {
	BonusMoneyKeepsake = function(fresh)
		game.AddResource('Money', game.round(fresh.BonusMoney * game.GetTotalHeroTraitValue('MoneyMultiplier', { IsMultiplier = true })), 'BonusMoneyKeepsake')
	end,

	ManaOverTimeRefundKeepsake = function(fresh)
		game.KeepsakeAddMaxMana(game.ShallowCopyTable(fresh.AcquireFunctionArgs))
	end,

	HadesAndPersephoneKeepsake = function(fresh)
		game.GiveRandomHadesBoonAndBoostBoons(fresh.AcquireFunctionArgs, fresh)
	end,

	ArmorGainKeepsake = function(fresh)
		fresh.CurrentArmor = (fresh.CurrentArmor or 0) + fresh.SetupFunction.Args.BaseAmount
		game.AddHealthBuffer(fresh.CurrentArmor, fresh.Name)
		game.FrameState.RequestUpdateHealthUI = true
	end,

	TempHammerKeepsake = function(fresh)
		game.GiveDurationHammer(fresh.AcquireFunctionArgs, fresh)
	end,

	RandomBlessingKeepsake = function(fresh)
		for _, trait in ipairs(game.CurrentRun.Hero.Traits) do
			trait.FromChaosKeepsake = nil
		end
		game.ChaosBlessingBonus(fresh.AcquireFunctionArgs, fresh)
		fresh.CurrentRoom = 0
	end,

	FountainRarityKeepsake = heirloom_reset({ 'Uses' }),
	BossPreDamageKeepsake = heirloom_reset({ 'Uses' }),
	BossMetaUpgradeKeepsake = heirloom_reset({ 'RemainingUses' }),
	UnpickedBoonKeepsake = heirloom_reset({ 'Uses' }),
	AthenaEncounterKeepsake = heirloom_reset({ 'RemainingUses' }),
	RarifyKeepsake = heirloom_reset({}),
	GoldifyKeepsake = heirloom_reset({ 'BoonConversionUses' }),

	ReincarnationKeepsake = function(fresh, old, defaults)
		heirloom_unexpire(fresh, defaults)
	end,

	SpellTalentKeepsake = function(fresh, old, defaults, before)
		local pending = before and before.TalentPoints or 0
		game.CurrentRun.NumTalentPoints = math.max(pending, fresh.AcquireFunctionArgs.Count)
		heirloom_unexpire(fresh, defaults)
	end,

	SkipEncounterKeepsake = function(fresh, old, defaults)
		local skip = game.GetHeroTrait('PersistentDionysusSkipKeepsake')
		if skip then
			skip.RemainingUses = fresh.AcquireFunctionArgs.RemainingUses
			game.UpdateTraitNumber(skip)
		else
			game.DionysusSkipTrait(fresh.AcquireFunctionArgs, fresh)
		end
		heirloom_unexpire(fresh, defaults)
	end,

	LowHealthCritKeepsake = function(fresh)
		if fresh.Uses and fresh.Uses <= 0 then heirloom_requip_fresh(fresh) end
	end,

	DoorHealReserveKeepsake = function(fresh, old, defaults)
		fresh.DoorHealReserve = defaults.DoorHealReserve
		heirloom_unexpire(fresh, defaults)
	end,

	TimedBuffKeepsake = function(fresh, old, defaults)
		local expired = (fresh.CurrentTime or 0) <= 0
		fresh.CurrentTime = fresh.StartingTime
		heirloom_unexpire(fresh, defaults)
		if expired then
			metallic_droplet_clear_residual()
			game.TimedBuffSetup(game.CurrentRun.Hero, fresh.SetupFunction.Args)
		end
	end,

	EscalatingKeepsake = function(fresh, old)
		fresh.EscalatingKeepsakeValue = heirloom_rescale(fresh.EscalatingKeepsakeValue, 1.0,
			old.EscalatingKeepsakeGrowthPerRoom, fresh.EscalatingKeepsakeGrowthPerRoom)
	end,
}


local function heirloom_pierced_butterfly(fresh, old)
	fresh.AccumulatedDamageBonus = heirloom_rescale(fresh.AccumulatedDamageBonus, 1,
		old.PerfectClearDamageBonus - 1, fresh.PerfectClearDamageBonus - 1)
end

local function heirloom_lambent_plume(fresh, old)
	local bonus = heirloom_rescale(fresh.AccumulatedDodgeBonus, 0, old.FastClearDodgeBonus, fresh.FastClearDodgeBonus) or 0
	fresh.AccumulatedDodgeBonus = bonus

	local heroId = game.CurrentRun.Hero.ObjectId
	game.SetLifeProperty({ Property = 'DodgeChance', Value = bonus, ValueChangeType = 'Add', DestinationId = heroId, DataValue = false })
	game.SetUnitProperty({ Property = 'Speed', Value = 1 + bonus, ValueChangeType = 'Multiply', DestinationId = heroId })
end

local function heirloom_refresh_for(trait)
	if HEIRLOOM_KEEPSAKE_REFRESH[trait.Name] then return HEIRLOOM_KEEPSAKE_REFRESH[trait.Name] end
	if trait.PerfectClearDamageBonus and trait.AccumulatedDamageBonus then return heirloom_pierced_butterfly end
	if trait.FastClearDodgeBonus and trait.AccumulatedDodgeBonus then return heirloom_lambent_plume end
	return nil
end


HEIRLOOM_FORCE_GOD_DATA = {
	ForceZeusBoonKeepsake = { CoreTraits = 'ZeusCoreTraits', Legendary = 'SpawnKillBoon', Wrath = 'ZeusWrathBoon' },
	ForceHeraBoonKeepsake = { CoreTraits = 'HeraCoreTraits', Legendary = 'AllElementalBoon', Wrath = 'HeraWrathBoon' },
	ForceAresBoonKeepsake = { CoreTraits = 'AresCoreTraits', Legendary = 'DoubleBloodDropBoon', Wrath = 'AresWrathBoon' },
	ForcePoseidonBoonKeepsake = { CoreTraits = 'PoseidonCoreTraits', Legendary = 'AmplifyConeBoon', Wrath = 'PoseidonWrathBoon' },
	ForceApolloBoonKeepsake = { CoreTraits = 'ApolloCoreTraits', Legendary = 'DoubleExManaBoon', Wrath = 'ApolloWrathBoon' },
	ForceDemeterBoonKeepsake = { CoreTraits = 'DemeterCoreTraits', Legendary = 'InstantRootKill', Wrath = 'DemeterWrathBoon' },
	ForceAphroditeBoonKeepsake = { CoreTraits = 'AphroditeCoreTraits', Legendary = 'RandomStatusBoon', Wrath = 'AphroWrathBoon' },
	ForceHephaestusBoonKeepsake = { CoreTraits = 'HephaestusCoreTraits', Legendary = 'WeaponUpgradeBoon', Wrath = 'HephWrathBoon' },
	ForceHestiaBoonKeepsake = { CoreTraits = 'HestiaCoreTraits', Legendary = 'BurnSprintBoon', Wrath = 'HestiaWrathBoon' },
}

local heirloom_reset_god = heirloom_reset({ 'Uses' })
for godKeepsakeName, _ in pairs(HEIRLOOM_FORCE_GOD_DATA) do
	HEIRLOOM_KEEPSAKE_REFRESH[godKeepsakeName] = heirloom_reset_god
end


function heirloom_force_god_boon_data(traitName)
	if not traitName then return nil, nil end
	for keepsakeName, data in pairs(HEIRLOOM_FORCE_GOD_DATA) do
		if game.Contains(game.LinkedTraitData[data.CoreTraits] or {}, traitName) then
			return keepsakeName, data
		end
	end
	return nil, nil
end


function heirloom_screen_offers(screen, traitName)
	if not traitName or not screen or not screen.UpgradeButtons then return false end
	for _, otherButton in pairs(screen.UpgradeButtons) do
		if otherButton.Data and otherButton.Data.Name == traitName then
			return true
		end
	end
	return false
end


local HEIRLOOM_TOP_RARITIES = { 'Legendary', 'Duo', 'Heroic', 'Epic', 'Rare', 'Common' }

local function heirloom_top_rarity(traitName)
	local levels = game.TraitData[traitName] and game.TraitData[traitName].RarityLevels or {}
	for _, rarity in ipairs(HEIRLOOM_TOP_RARITIES) do
		if levels[rarity] then return rarity end
	end
	return 'Legendary'
end


local function heirloom_force_god_option(screen, button, data)
	local lootData = screen.Source
	for index, option in pairs(lootData.UpgradeOptions or {}) do
		if option.ItemName == button.Data.Name then
			if not game.HeroHasTrait(data.Legendary) and not heirloom_screen_offers(screen, data.Legendary) then
				return index, { ItemName = data.Legendary, Type = 'Trait', Rarity = heirloom_top_rarity(data.Legendary) }
			end
			if boon_edit_on('WrathOfOlympus') and game.TraitData[data.Wrath] and not game.HeroHasTrait(data.Wrath) and not heirloom_screen_offers(screen, data.Wrath) then
				return index, { ItemName = data.Wrath, Type = 'Trait', Rarity = heirloom_top_rarity(data.Wrath) }
			end

			local rarityLevels = button.Data.RarityLevels
			if button.Data.Rarity == 'Heroic' or not rarityLevels or not rarityLevels.Heroic then return nil end
			option.Rarity = 'Heroic'
			option.StackNum = button.StackNum
			return index, option
		end
	end
	return nil
end


local HEIRLOOM_OPTION_COMPONENTS = {
	'PurchaseButton%d', 'PurchaseButton%dLock', 'PurchaseButton%dHighlight', 'PurchaseButton%dIcon',
	'PurchaseButton%dExchangeIcon', 'PurchaseButton%dExchangeIconFrame', 'PurchaseButton%dQuestIcon',
	'PurchaseButton%dPinIcon', 'PurchaseButton%dElementIcon', 'Backing%d', 'PurchaseButton%dFrame', 'PurchaseButton%dPatch',
}

local function heirloom_replace_option(screen, button, index, option)
	local lootData = screen.Source
	local components = screen.Components

	local toDestroy = {}
	for _, pattern in ipairs(HEIRLOOM_OPTION_COMPONENTS) do
		local key = string.format(pattern, index)
		if components[key] then
			table.insert(toDestroy, components[key].Id)
			components[key] = nil
		end
	end
	game.Destroy({ Ids = toDestroy })
	game.UpgradeBoonRarityPresentation(button)

	lootData.UpgradeOptions[index] = option
	local newButton = game.CreateUpgradeChoiceButton(screen, lootData, index, option)
	if screen.UpgradeButtons then screen.UpgradeButtons[index] = newButton end
	game.NotifyOnInteract({ Ids = { newButton.Id }, Notify = 'ScreenInput' .. (screen.Name or '') })
	return newButton
end


local function heirloom_spend_rarify(trait)
	local upgrade = trait.RarityUpgradeData
	if not game.IsEmpty(upgrade.RarifyVoiceLines) then
		game.thread(game.PlayVoiceLines, upgrade.RarifyVoiceLines, true)
	end
	upgrade.Uses = upgrade.Uses - 1
	game.TraitUIUpdateText(trait)
	if upgrade.Uses <= 0 then
		game.ReduceTraitUses(trait, { Force = true })
		if trait.ZeroBonusTrayText then trait.CustomName = trait.ZeroBonusTrayText end
	end
end


function heirloom_force_god_transform(screen, button, data, trait)
	if not game.CheckCooldown('RarifyInputCooldown', 0.45) then return end

	local index, option = heirloom_force_god_option(screen, button, data)
	if not index then return end

	local newButton = heirloom_replace_option(screen, button, index, option)
	heirloom_spend_rarify(trait)
	screen.UpgradedRarity = true

	game.TeleportCursor({ DestinationId = newButton.Id, ForceUseCheck = true })
	game.killTaggedThreads('RarifyPulse')
end


once('CherishedHeirloomForceGod', function()
	modutil.mod.Path.Wrap('UpgradeMouseOverUpgradeChoice', function(base, screen, button)
		if not boon_edit_on('CherishedHeirloom') or not boon_edit_on('OlympianKeepsakes')
			or not screen or screen.MouseOverButton == nil then
			return base(screen, button)
		end

		local lootData = screen.Source
		if not lootData or (not lootData.GodLoot and not lootData.TreatAsGodLootByShops) then
			return base(screen, button)
		end

		local mouseOverButton = screen.MouseOverButton
		local offered = mouseOverButton.Data
		local keepsakeName, data = heirloom_force_god_boon_data(offered and offered.Name)
		if not keepsakeName or offered.BlockMenuRarify then return base(screen, button) end

		local trait = game.GetHeroTrait(keepsakeName)
		local upgrade = trait and trait.RarityUpgradeData
		if not trait or trait.Rarity ~= 'Heroic' or not upgrade or upgrade.LootName ~= lootData.Name
			or not upgrade.Uses or upgrade.Uses <= 0 or screen.UpgradedRarity then
			return base(screen, button)
		end

		heirloom_force_god_transform(screen, mouseOverButton, data, trait)
	end)
end)


function heirloom_refresh_keepsake(traitName)
	if not traitName or traitName ~= game.GameState.LastAwardTrait then return end

	local old = game.GetHeroTrait(traitName)
	if not old then return end

	local prepare = HEIRLOOM_KEEPSAKE_PREPARE[traitName]
	local before = prepare and prepare(old)

	game.AdvanceKeepsake(true)

	local fresh = game.GetHeroTrait(traitName)
	if not fresh then return end

	local refresh = heirloom_refresh_for(fresh)
	if refresh then
		local defaults = game.GetProcessedTraitData({ Unit = game.CurrentRun.Hero, TraitName = traitName, Rarity = fresh.Rarity })
		refresh(fresh, old, defaults, before)
	end
	game.UpdateTraitNumber(game.GetHeroTrait(traitName) or fresh)
end


once('CherishedHeirloom', function()
	if boon_edit_on('CherishedHeirloom') then
		game.TraitData.KeepsakeLevelBoon.AcquireFunctionName = _PLUGIN.guid .. '.CherishedHeirloomAcquire'

		if boon_edit_on('OlympianKeepsakes') then
			game.TraitData.BaseBoonUpgradeKeepsake.RarityLevels.Heroic = { Multiplier = 3 }
			for keepsakeName in pairs(HEIRLOOM_FORCE_GOD_DATA) do
				local keepsake = game.TraitData[keepsakeName]
				if keepsake and keepsake.RarityLevels then
					keepsake.RarityLevels.Heroic = keepsake.RarityLevels.Heroic or { Multiplier = 3 }
				end
			end
		end
	end

	modutil.mod.Path.Wrap('HandleUpgradeToggle', function(base, screen, button, textOverride)
		local data = button and button.Data
		local picked = data and data.Unlocked and data.Gift
		local traitData = picked and game.TraitData[picked]

		if traitData and traitData.Slot == 'Keepsake' then
			mod.HeirloomPicked = picked
		end

		return base(screen, button, textOverride)
	end)

	modutil.mod.Path.Wrap("KeepsakeScreenClose", function(base, screen, button)
		local extra = cherished_heirloom_extra_pending()
		local picked = mod.HeirloomPicked
		mod.HeirloomPicked = nil

		if extra and picked and picked == mod.HeirloomPriorKeepsake then
			base(screen, button)

			if mod.tuning.CherishedHeirloom.RefreshHeldKeepsake and not mod.HeirloomRefreshUsed then
				mod.HeirloomRefreshUsed = true
				heirloom_refresh_keepsake(picked)
			end

			cherished_heirloom_place_keepsakes()
			game.thread(cherished_heirloom_open_rack)
			return
		end

		if extra and screen and screen.LastTrait == game.GameState.LastAwardTrait then
			mod.HeirloomExtraPending = nil
			mod.HeirloomPriorKeepsake = nil
			return base(screen, button)
		end

		local incoming = nil
		local priorKeepsake = mod.HeirloomPriorKeepsake
		if extra then
			mod.HeirloomSkipUnequip = true
			mod.HeirloomExtraPending = nil

			incoming = game.GameState.LastAwardTrait
			if incoming ~= screen.LastTrait then
				mod.HeirloomIncoming = incoming
			end
		end

		local blocked = extra and game.CurrentRun and game.CurrentRun.BlockedKeepsakes
		local blockedCount = blocked and #blocked or 0

		base(screen, button)

		if extra then
			mod.HeirloomSkipUnequip = nil
			mod.HeirloomIncoming = nil
			mod.HeirloomPriorKeepsake = nil

			if blocked and incoming and #blocked > blockedCount and blocked[#blocked] == screen.LastTrait then
				blocked[#blocked] = incoming
			end

			if game.CurrentRun and screen.LastTrait and game.HeroHasTrait(screen.LastTrait) then
				game.GameState.LastAwardTrait = screen.LastTrait
				heirloom_confirm_special_keepsake(screen.LastTrait)
			end

			if mod.tuning.CherishedHeirloom.RefreshHeldKeepsake and incoming and incoming == priorKeepsake then
				heirloom_refresh_keepsake(incoming)
			end

			cherished_heirloom_place_keepsakes()
		end
	end)

	modutil.mod.Path.Wrap("IsShownInHUD", function(base, trait)
		if heirloom_hides_from_hud(trait) then return false end
		return base(trait)
	end)

	modutil.mod.Path.Wrap("UnequipKeepsake", function(base, heroUnit, traitName, args)
		if mod.HeirloomSkipUnequip then
			mod.HeirloomSkipUnequip = nil
			return
		end
		return base(heroUnit, traitName, args)
	end)
end)


local HEIRLOOM_HOLD_ENCOUNTERS = 9999

local HEIRLOOM_MENU_DELAY = 1.2

function cherished_heirloom_active()
	if not boon_edit_on('CherishedHeirloom') then return false end
	if not game.CurrentRun or not game.CurrentRun.Hero then return false end
	return game.HeroHasTrait('KeepsakeLevelBoon')
end

function cherished_heirloom_extra_pending()
	return mod.HeirloomExtraPending and mod.tuning.CherishedHeirloom.ExtraKeepsake
end

function heirloom_demote_keepsake(trait)
	if not trait or not trait.Name then return end

	game.TraitUIRemove(trait)
	trait.Slot = nil
	trait.ActiveSlotOffsetIndex = nil
	trait.HideInRunHistory = nil
	trait.Ordered = nil
	game.SessionMapState.HUDTraitsShown[trait.Name] = nil

	if mod.tuning.CherishedHeirloom.ExtraKeepsakeInMenuOnly then
		trait.ShowInHUD = nil
		trait.BoonEditHeirloomExtra = true
		return
	end

	trait.BoonEditHeirloomExtra = nil
	game.TraitUIAdd(trait)
end

function heirloom_hides_from_hud(trait)
	if not trait then return false end
	if trait.BoonEditHeirloomExtra then return true end
	return mod.HeirloomIncoming ~= nil and trait.Name == mod.HeirloomIncoming
end

function heirloom_hold_keepsake(trait)
	if trait.UsesAsEncounters and trait.RemainingUses then
		trait.HoldRemainingRooms = HEIRLOOM_HOLD_ENCOUNTERS
	end
end

function heirloom_special_keepsake()
	return game.CurrentRun and game.CurrentRun.BoonEditHeirloomSpecialKeepsake
end

function heirloom_is_special_keepsake(traitName)
	return traitName ~= nil and traitName == heirloom_special_keepsake()
end

function heirloom_confirm_special_keepsake(traitName)
	if not game.CurrentRun then return end
	game.CurrentRun.BoonEditHeirloomSpecialKeepsake = traitName

	local trait = game.GetHeroTrait(traitName)
	if trait then trait.BoonEditHeirloomSpecial = true end
end

function cherished_heirloom_place_keepsakes()
	if not cherished_heirloom_active() then return end

	local equipped = game.GameState.LastAwardTrait
	local special = heirloom_special_keepsake()
	for _, trait in ipairs(game.CurrentRun.Hero.Traits or {}) do
		if game.GetKeepsakeData(trait.Name) then
			if trait.Name == special then
				trait.BoonEditHeirloomSpecial = true
				heirloom_hold_keepsake(trait)
			elseif mod.tuning.CherishedHeirloom.KeepAllKeepsakes then
				heirloom_hold_keepsake(trait)
			end
			if trait.Name ~= equipped and trait.ActiveSlotOffsetIndex ~= nil then
				heirloom_demote_keepsake(trait)
			end
		end
	end
end

function heirloom_equipped_keepsake()
	if not game.CurrentRun or not game.CurrentRun.Hero then return nil end
	for _, trait in ipairs(game.CurrentRun.Hero.Traits or {}) do
		if game.GetKeepsakeData(trait.Name) and trait.ActiveSlotOffsetIndex ~= nil then
			return trait.Name
		end
	end
	return nil
end

function mod.CherishedHeirloomAcquire(args, traitData)
	heirloom_refresh_keepsake(game.GameState.LastAwardTrait)

	cherished_heirloom_place_keepsakes()

	if not mod.tuning.CherishedHeirloom.ExtraKeepsake then return end
	mod.HeirloomExtraPending = true
	mod.HeirloomRefreshUsed = nil
	mod.HeirloomPriorKeepsake = heirloom_equipped_keepsake()
	game.thread(cherished_heirloom_open_rack)
end

function cherished_heirloom_open_rack()
	wait_for_screens(HEIRLOOM_MENU_DELAY)
	if not cherished_heirloom_extra_pending() then return end
	game.OpenKeepsakeRackScreen(nil)
end
