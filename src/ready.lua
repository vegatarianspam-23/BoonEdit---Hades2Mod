---@meta _


local traitText = rom.path.combine(rom.paths.Content, 'Game/Text/en/TraitText.en.sjson')
sjson.hook(traitText, function(data)
	return sjson_TraitText(data)
end)

local helpText = rom.path.combine(rom.paths.Content, 'Game/Text/en/HelpText.en.sjson')
sjson.hook(helpText, function(data)
	return sjson_HelpText(data)
end)

local enemyProjectiles = rom.path.combine(rom.paths.Content, 'Game/Projectiles/Enemy_General_Projectiles.sjson')
sjson.hook(enemyProjectiles, function(data)
	return sjson_EnemyProjectiles(data)
end)

local castVfx = rom.path.combine(rom.paths.Content, 'Game/Animations/Melinoe_Cast_VFX.sjson')
sjson.hook(castVfx, function(data)
	return sjson_CastVfx(data)
end)

local poseidonVfx = rom.path.combine(rom.paths.Content, 'Game/Animations/Melinoe_Poseidon_VFX.sjson')
sjson.hook(poseidonVfx, function(data)
	return sjson_PoseidonVfx(data)
end)

local hestiaVfx = rom.path.combine(rom.paths.Content, 'Game/Animations/Melinoe_Hestia_VFX.sjson')
sjson.hook(hestiaVfx, function(data)
	return sjson_HestiaVfx(data)
end)


modutil.mod.Path.Wrap("SetupMap", function(base, ...)
	prefix_SetupMap()
	return base(...)
end)

modutil.mod.Path.Wrap("StartNewRun", function(base, currentRun, args)
	boon_patches_reconcile(args and args.ActiveBounty or false)
	return base(currentRun, args)
end)

modutil.mod.Path.Wrap("FillInShopOptions", function(base, args)
	if args and args.StoreData then
		args.StoreData = boon_edit_trial_shop(args.StoreData)
	end
	return base(args)
end)

modutil.mod.Path.Wrap("ChooseRoomReward", function(base, run, room, rewardStoreName, previouslyChosenRewards, args)
	local chosen = base(run, room, rewardStoreName, previouslyChosenRewards, args)
	local fallback = chosen == "RoomRewardHealDrop" and boon_edit_trial_reward_fallback()
	if fallback and room and room.Reward and room.Reward.Name == "RoomRewardHealDrop" then
		room.Reward = { Name = fallback }
		return fallback
	end
	return chosen
end)

modutil.mod.Path.Wrap("RandomFogSpawn", function(base, unit, args)
	while game.CurrentRun and not game.CurrentRun.CurrentRoom do
		game.wait(0.1)
	end
	return base(unit, args)
end)

modutil.mod.Path.Wrap("IsTraitEligible", function(base, traitData, args)
	if traitData and boon_edit_trial_blocks(traitData.Name) then return false end
	return base(traitData, args)
end)

modutil.mod.Path.Wrap("GetTraitTooltip", function(base, trait, args)
	return boon_edit_text_id(base(trait, args))
end)

modutil.mod.Path.Wrap("GetTraitTooltipTitle", function(base, trait)
	return boon_edit_text_id(base(trait))
end)

modutil.mod.Path.Wrap("CreateTextBox", function(base, args)
	if args and type(args.LuaValue) == 'table' and args.LuaValue.ForBoonInfo then
		args.Text = boon_edit_text_id(args.Text)
	end
	return base(args)
end)
