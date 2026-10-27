---@meta _


local VANILLA_SPACING = 0.1

local cutAboveSpawning = false


once('CuttingEdge', function()
	modutil.mod.Path.Wrap('CheckAresExCurseApply', function(base, victim, functionArgs, triggerArgs)
		if not boon_edit_on('CuttingEdge') then return base(victim, functionArgs, triggerArgs) end

		cutAboveSpawning = true
		local ok, err = pcall(base, victim, functionArgs, triggerArgs)
		cutAboveSpawning = false
		if not ok then error(err, 0) end
	end)

	modutil.mod.Path.Wrap('CreateProjectileFromUnit', function(base, args)
		if cutAboveSpawning then cutting_edge_space_blade(args) end
		return base(args)
	end)
end)


function cutting_edge_space_blade(args)
	local properties = args and args.DataProperties
	if not properties or not properties.StartDelay then return end

	properties.StartDelay = properties.StartDelay / VANILLA_SPACING * mod.tuning.CuttingEdge.BladeSpacing
end
