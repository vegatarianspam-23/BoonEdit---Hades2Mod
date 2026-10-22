---@meta _


local DROPLET = 'TimedBuffKeepsake'


local function metallic_droplet_residual(traitData)
	if not boon_edit_on('MetallicDroplet') or mod.tuning.MetallicDroplet.ResidualFraction <= 0 then return nil end
	if not traitData or not traitData.SetupFunction or not traitData.SetupFunction.Args then return nil end

	local multiplier = traitData.SetupFunction.Args.Multiplier or 1
	if multiplier == 1 then return nil end
	return 1 + (multiplier - 1) * mod.tuning.MetallicDroplet.ResidualFraction
end


once('MetallicDroplet', function()
	modutil.mod.Path.Wrap('TimedBuffSetup', function(base, hero, args)
		local traitData = game.GetHeroTrait(DROPLET)
		local expired = traitData and traitData.CurrentTime and traitData.CurrentTime <= 0
		local residual = expired and not hero.IsDead and metallic_droplet_residual(traitData)
		if not residual then return base(hero, args) end
		if game.MapState.BoonEditDropletResidual then return end

		game.MapState.KeepsakeSpeedPropertyChanges = nil
		local savedTime = traitData.CurrentTime
		traitData.CurrentTime = 1
		base(hero, { Multiplier = residual })
		traitData.CurrentTime = savedTime
		game.MapState.BoonEditDropletResidual = residual
	end)

	modutil.mod.Path.Wrap('EndTimedBuff', function(base, traitData)
		base(traitData)
		if not metallic_droplet_residual(traitData) then return end

		game.MapState.KeepsakeSpeedPropertyChanges = nil
		game.TimedBuffSetup(game.CurrentRun.Hero, traitData.SetupFunction.Args)
	end)

	modutil.mod.Path.Wrap('UnequipKeepsake', function(base, heroUnit, traitName, args)
		if traitName == DROPLET and not mod.HeirloomSkipUnequip and not (args and args.AdvanceKeepsakeMoment) then
			metallic_droplet_clear_residual()
		end
		return base(heroUnit, traitName, args)
	end)
end)


function metallic_droplet_clear_residual()
	local residual = game.MapState.BoonEditDropletResidual
	if not residual then return end
	game.MapState.BoonEditDropletResidual = nil

	if not game.IsEmpty(game.MapState.KeepsakeSpeedPropertyChanges) then
		game.SessionMapState.MapSpeedMultiplier = game.SessionMapState.MapSpeedMultiplier / residual
		game.ApplyUnitPropertyChanges(game.CurrentRun.Hero, game.MapState.KeepsakeSpeedPropertyChanges, true, true)
	end
	game.MapState.KeepsakeSpeedPropertyChanges = nil
end
