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

local playerProjectiles = rom.path.combine(rom.paths.Content, 'Game/Projectiles/PlayerProjectiles.sjson')
sjson.hook(playerProjectiles, function(data)
	return sjson_PlayerProjectiles(data)
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
	return base(boon_edit_text_args(args))
end)

modutil.mod.Path.Wrap("ModifyTextBox", function(base, args)
	return base(boon_edit_text_args(args))
end)


local TRAY_TRAITS = {
	BoonEditFlawlessExecutionBoon = true,
	BoonEditFlawlessExecutionDuoBoon = true,
}

local function tray_lists(trait)
	return TRAY_TRAITS[trait.Name] == true
end

local trayListing = nil

local function tray_proxy(trait)
	local proxy = game.ShallowCopyTable(trait)
	proxy.SWuTrayProxy = true
	proxy.AnchorId = nil
	proxy.TraitInfoCardId = nil
	proxy.TraitInfoChargeId = nil
	proxy.CustomLabel = nil
	return proxy
end

modutil.mod.Path.Wrap("TraitTrayShowTraits", function(base, ...)
	trayListing = 'tray'
	local result = base(...)
	trayListing = nil
	return result
end)

modutil.mod.Path.Wrap("ShowTraitUI", function(base, ...)
	local result = base(...)
	if trayListing ~= 'tray' then return result end
	trayListing = nil
	local shallowCopy = game.ShallowCopyTable
	game.ShallowCopyTable = function(orig, ...)
		game.ShallowCopyTable = shallowCopy
		local copy = shallowCopy(orig, ...)
		if type(copy) ~= 'table' or not game.CurrentRun or not game.CurrentRun.Hero or orig ~= game.CurrentRun.Hero.Traits then
			return copy
		end
		for i, trait in pairs(copy) do
			if type(trait) == 'table' and not trait.SWuTrayProxy and trait.ShowInHUD and tray_lists(trait) then
				copy[i] = tray_proxy(trait)
			end
		end
		return copy
	end
	return result
end)

modutil.mod.Path.Wrap("IsShownInHUD", function(base, trait, ...)
	if trait and trait.SWuTrayProxy then return false end
	return base(trait, ...)
end)
