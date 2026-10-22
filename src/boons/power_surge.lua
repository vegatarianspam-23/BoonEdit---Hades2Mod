---@meta _


once('PowerSurge', function()
	modutil.mod.Path.Wrap("ManaDelta", function(base, delta, args)
		local hero = game.CurrentRun and game.CurrentRun.Hero
		local before = hero and hero.Mana

		local result = base(delta, args)
		power_surge_on_restore(before)
		return result
	end)
end)


function power_surge_bolt_args()
	local trait = game.GetHeroTrait('ZeusManaBoltBoon')
	local action = trait and trait.OnManaSpendAction
	return action and action.FunctionArgs
end


function power_surge_on_restore(before)
	if not boon_edit_on('PowerSurge') then return end
	if type(before) ~= 'number' then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or not hero_live() then return end
	if type(hero.Mana) ~= 'number' or hero.Mana <= before then return end

	local args = power_surge_bolt_args()
	if not args then return end

	if not game.CheckCooldown('BoonEditPowerSurgeRestore',
		mod.tuning.PowerSurge.RestoreCooldown, true) then
		return
	end

	game.thread(game.CreateZeusBolt, {
		SourceId = hero.ObjectId,
		Range = args.Range,
		SeekTarget = true,
		ProjectileName = args.ProjectileName,
		DamageMultiplier = args.DamageMultiplier,
		InitialDelay = 0,
		Delay = 0.1,
		Count = 1,
	})
end
