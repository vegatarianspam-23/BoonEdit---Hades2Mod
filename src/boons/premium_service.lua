---@meta _


once('PremiumServiceHammers', function()
	if boon_edit_on('PremiumService') then
		game.TraitData.WeaponUpgradeBoon.AcquireFunctionName = _PLUGIN.guid .. '.PremiumServiceAcquire'

		local anvil = game.ConsumableData.ChaosWeaponUpgrade

		anvil.UseFunctionName = _PLUGIN.guid .. '.AnvilOfFates'
		anvil.UseFunctionArgs = {
			Thread = true,
			NumTraits = mod.tuning.AnvilOfFates.Discoveries,
			ReportValues = { ReportedNumTraits = 'NumTraits' },
		}

		anvil.PurchaseRequirements = nil
	end

	modutil.mod.Path.Wrap("AddTraitToHero", function(base, args)
		local added = base(args)
		premium_service_rank_hammer(added or (args and args.TraitData))
		return added
	end)

	modutil.mod.Path.Wrap("HandleUpgradeChoiceSelection", function(base, screen, button, args)
		if not (screen and screen.Source and screen.Source.BoonEditAnvilSacrifice) then
			return base(screen, button, args)
		end
		return anvil_sacrifice_selected(screen, button)
	end)
end)


local PREMIUM_SERVICE_HAMMER_COUNT = 99

function mod.PremiumServiceAcquire(args, traitData)
	game.UpgradeAspect(args, traitData)

	if not boon_edit_on('PremiumService') then return end

	game.UpgradeHammers({ Count = PREMIUM_SERVICE_HAMMER_COUNT })

	game.thread(game.GiveRandomConsumables, {
		Delay = 0.5,
		NotRequiredPickup = true,
		ForceToValidLocation = true,
		KeepCollision = true,
		LootOptions = {
			{ Name = 'ChaosWeaponUpgrade', Amount = 1 },
		},
	})
end

function premium_service_rank_hammer(trait)
	if mod.PremiumServiceRanking then return end
	if not boon_edit_on('PremiumService') then return end
	if not game.CurrentRun or not game.CurrentRun.Hero then return end

	if not trait or not trait.Name or not trait.IsHammerTrait then return end
	if not trait.RarityLevels or not trait.RarityLevels.Legendary then return end
	if trait.Rarity == 'Legendary' or trait.RemainingUses then return end

	if not game.HeroHasTrait('WeaponUpgradeBoon') then return end

	game.thread(premium_service_rank_hammer_deferred, trait.Name)
end

function premium_service_rank_hammer_deferred(traitName)
	game.waitUnmodified(0.1)

	local trait = game.GetHeroTrait(traitName)
	if not trait or trait.Rarity == 'Legendary' then return end

	mod.PremiumServiceRanking = true
	game.AddRarityToTraits(nil, {
		ForceUpgrade = { trait },
		TargetRarityName = 'Legendary',
		Silent = true,
	})
	mod.PremiumServiceRanking = nil

	game.thread(game.IncreasedHammerRarityPresentation, { [traitName] = true }, 1)
end


function anvil_hammer_traits()
	local held = {}
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return held end

	for _, trait in ipairs(hero.Traits or {}) do
		if game.LootData.WeaponUpgrade.TraitIndex[trait.Name] and not trait.RemainingUses then
			table.insert(held, trait)
		end
	end
	return held
end

function anvil_menu_source()
	local source = game.DeepCopyTable(game.LootData.WeaponUpgrade)
	source.ObjectId = game.SpawnObstacle({
		Name = 'InvisibleTarget',
		Group = 'Standing',
		DestinationId = game.CurrentRun.Hero.ObjectId,
	})
	source.DestroyOnPickup = true
	source.CanDuplicate = false
	source.StackNum = 1
	source.BlockReroll = true
	return source
end

function anvil_open_sacrifice_menu()
	local held = anvil_hammer_traits()
	if game.IsEmpty(held) then return false end

	held = game.FYShuffle(held)
	local options = {}
	for i = 1, math.min(mod.tuning.AnvilOfFates.SacrificeChoices, #held) do
		table.insert(options, { ItemName = held[i].Name, Rarity = held[i].Rarity or 'Common' })
	end

	local source = anvil_menu_source()
	source.UpgradeOptions = options
	source.BoonEditAnvilSacrifice = true

	mod.AnvilSacrificed = nil
	defer_screen_open(game.OpenUpgradeChoiceMenu, source)
	return true
end

function anvil_sacrifice_selected(screen, button)
	local chosen = button and button.Data and button.Data.Name
	if chosen then
		game.RemoveWeaponTrait(chosen)
		mod.AnvilSacrificed = chosen
	end

	local source = screen.Source
	if source and source.ObjectId then
		game.Destroy({ Id = source.ObjectId })
	end

	game.CloseUpgradeChoiceScreen(screen, button)
end

function anvil_open_discover_menu()
	local source = anvil_menu_source()
	source.UpgradeOptions = nil
	defer_screen_open(game.OpenUpgradeChoiceMenu, source)
end

function anvil_unlock_exits()
	local run = game.CurrentRun
	local room = run and run.CurrentRoom
	if not room or room.ExitsUnlocked then return end

	local roomData = game.RoomData[room.Name] or room
	if game.IsEmpty(game.MapState.OfferedExitDoors or {}) and not roomData.UnlockWithoutDoors then return end

	if game.CheckRoomExitsReady(room) then
		game.UnlockRoomExits(run, room)
	end
end

function mod.AnvilOfFates(args)
	if not boon_edit_on('PremiumService') then
		return game.ChaosHammerUpgrade(args)
	end

	if anvil_open_sacrifice_menu() then
		game.waitUnmodified(0.1)
	end

	for _ = 1, mod.tuning.AnvilOfFates.Discoveries do
		anvil_open_discover_menu()
		game.waitUnmodified(0.1)
	end

	anvil_unlock_exits()
	game.InvalidateCheckpoint()
end
