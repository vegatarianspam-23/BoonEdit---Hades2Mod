---@meta _


local COMBAT_TEXT_SPACING = 60
local COMBAT_TEXT_DEFAULT_OFFSET = -140


once('CombatTextStack', function()
	modutil.mod.Path.Wrap('InCombatTextArgs', function(base, args)
		return base(combat_text_stack(args))
	end)
end)


function combat_text_stack(args)
	if type(args) ~= 'table' or args.SWuTextStacked then return args end
	if args.UseProgressiveStack or args.ScreenSpace or args.SkipRise then return args end

	local targetId = args.TargetId
	if args.TargetHero and game.CurrentRun and game.CurrentRun.Hero then
		targetId = game.CurrentRun.Hero.ObjectId
	end
	if not targetId or targetId <= 0 then return args end

	local stacks = game.SWuCombatTextStacks or {}
	game.SWuCombatTextStacks = stacks
	local slots = stacks[targetId] or {}
	stacks[targetId] = slots

	local start = (game._worldTime or 0) + (args.PreDelay or 0)
	local finish = start + (args.Duration or 0.4) + (args.FadeDuration or 0.3)

	local slot = 0
	while slots[slot] and slots[slot] > start do
		slot = slot + 1
	end
	slots[slot] = finish

	local stacked = game.ShallowCopyTable(args)
	stacked.SWuTextStacked = true
	if slot > 0 then
		stacked.OffsetY = (args.OffsetY or COMBAT_TEXT_DEFAULT_OFFSET) - slot * COMBAT_TEXT_SPACING
	end
	return stacked
end
