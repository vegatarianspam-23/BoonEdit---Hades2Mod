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
