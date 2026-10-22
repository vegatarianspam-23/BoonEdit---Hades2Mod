---@meta _


local HEAVY_METAL_TRAIT = 'HeavyArmorBoon'

local HEAVY_METAL_FLAG = 'BoonEditHeavyMetal'


once('HeavyMetalKnockback', function()
	modutil.mod.Path.Wrap("HeavyArmorInitialPresentation", function(base, ...)
		local result = base(...)
		heavy_metal_sync()
		return result
	end)

	modutil.mod.Path.Wrap("SetupHeroObject", function(base, ...)
		local result = base(...)
		heavy_metal_sync()
		return result
	end)
end)


function heavy_metal_sync()
	if not boon_edit_on('HeavyMetal') then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or not hero.ObjectId or not hero.ImmuneToForceFlags then return end

	if game.HeroHasTrait(HEAVY_METAL_TRAIT) then
		game.AddPlayerImmuneToForce(HEAVY_METAL_FLAG)
	elseif hero.ImmuneToForceFlags[HEAVY_METAL_FLAG] then
		game.RemovePlayerImmuneToForce(HEAVY_METAL_FLAG)
	end
end
