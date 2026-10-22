---@meta _


local STONE = 'UnpickedBoonKeepsake'
local CERTAIN = 1000

local concaveStoneForcing = false
local concaveStoneCopied = false


function concave_stone_active()
	return boon_edit_on('ConcaveStone') and game.HeroHasTrait(STONE)
end


local function concave_stone_major(source)
	if source.GodLoot or source.TreatAsGodLootByShops then return true end
	return game.Contains(mod.tuning.ConcaveStone.Rewards, source.Name)
end


local function concave_stone_eligible(source)
	if not source or source.CanDuplicate == false or not concave_stone_active() then return false end
	if not concave_stone_major(source) then return false end

	local trait = game.GetHeroTrait(STONE)
	return trait.BoonEditRewardChance ~= nil and trait.Uses ~= nil and trait.Uses > 0
end


local function concave_stone_copy(source, base, ...)
	if not concave_stone_eligible(source) then return base(...) end

	local trait = game.GetHeroTrait(STONE)
	local luck = game.GetTotalHeroTraitValue('LuckMultiplier', { IsMultiplier = true })
	if not game.RandomChance(trait.BoonEditRewardChance * luck) then
		game.ReduceTraitUses(trait)
		return base(...)
	end

	local couldDuplicate = source.CanDuplicate
	source.CanDuplicate = true
	concaveStoneForcing = true

	local result = base(...)

	if concaveStoneForcing then
		concaveStoneForcing = false
		source.CanDuplicate = couldDuplicate
	else
		game.ReduceTraitUses(game.GetHeroTrait(STONE))
	end
	return result
end


local function concave_stone_presentation(args)
	local objectId = args.ObjectId
	game.ApplyUpwardForce({ Id = objectId, Speed = game.RandomFloat(500, 700) })
	game.ApplyForce({ Id = objectId, Speed = game.RandomFloat(75, 260), Angle = game.RandomFloat(0, 360) })
	game.wait(0.75)
	game.thread(game.PlayVoiceLines, game.GlobalVoiceLines.EchoKeepsakeLines, true)

	game.PlaySound({ Name = '/SFX/Menu Sounds/PortraitEmoteSparklySFX' })
	local toastAnchor = game.SpawnObstacle({ Name = 'BlankObstacle', DestinationId = game.CurrentRun.Hero.ObjectId, Group = 'Combat_Menu_Additive' })
	game.DrawScreenRelative({ Id = toastAnchor })
	game.CreateAnimation({ Name = 'BiomeStateGoldFx', DestinationId = toastAnchor, Group = 'Combat_Menu_Additive' })
	game.thread(game.InCombatText, objectId, 'DoubleBoonSuccess', 0.75)
end


once('ConcaveStone', function()
	if boon_edit_on('ConcaveStone') then
		local stone = game.TraitData[STONE]
		stone.BoonEditRewardChance = stone.DoubleBoonChance
		stone.DoubleBoonChance = nil
		for _, extract in ipairs(stone.ExtractValues or {}) do
			if extract.Key == 'DoubleBoonChance' then extract.Key = 'BoonEditRewardChance' end
		end
	end

	modutil.mod.Path.Wrap('GetTotalHeroTraitValue', function(base, propertyName, args)
		if concaveStoneForcing and propertyName == 'DoubleRewardChance' then
			concaveStoneForcing = false
			concaveStoneCopied = true
			return CERTAIN
		end
		return base(propertyName, args)
	end)

	modutil.mod.Path.Wrap('HandleUpgradeChoiceSelection', function(base, screen, button, args)
		if args and args.DoubleBoonChance then return base(screen, button, args) end
		return concave_stone_copy(screen and screen.Source, base, screen, button, args)
	end)

	modutil.mod.Path.Wrap('DoubleRewardPresentation', function(base, args)
		if not concaveStoneCopied then return base(args) end
		concaveStoneCopied = false
		return concave_stone_presentation(args)
	end)
end)
