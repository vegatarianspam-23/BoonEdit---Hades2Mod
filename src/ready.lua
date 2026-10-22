---@meta _


local traitText = rom.path.combine(rom.paths.Content, 'Game/Text/en/TraitText.en.sjson')
sjson.hook(traitText, function(data)
	return sjson_TraitText(data)
end)

local helpText = rom.path.combine(rom.paths.Content, 'Game/Text/en/HelpText.en.sjson')
sjson.hook(helpText, function(data)
	return sjson_HelpText(data)
end)

local playerProjectiles = rom.path.combine(rom.paths.Content, 'Game/Projectiles/PlayerProjectiles.sjson')
sjson.hook(playerProjectiles, function(data)
	return sjson_PlayerProjectiles(data)
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


modutil.mod.Path.Wrap("SetupMap", function(base, ...)
	prefix_SetupMap()
	return base(...)
end)
