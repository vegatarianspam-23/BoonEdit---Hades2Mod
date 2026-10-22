---@meta _


once('CardioGainSprintMana', function()
	if not boon_edit_on('CardioGain') then return end

	local cardioGain = game.TraitData.HestiaManaBoon

	cardioGain.OnSprintAction = {
		FunctionName = _PLUGIN.guid .. '.CardioGainSprintMana',
		RunOnce = true,
		Args = {
			BoonEditManaGain = { BaseValue = mod.tuning.CardioGain.SprintManaGain },
			ReportValues = { BoonEditReportedManaGain = 'BoonEditManaGain' },
		},
	}

	table.insert(cardioGain.StatLines, 'BoonEditCardioGainSprintStatDisplay')
	table.insert(cardioGain.ExtractValues, {
		Key = 'BoonEditReportedManaGain',
		ExtractAs = 'TooltipSprintManaRecovery',
		DecimalPlaces = 1,
	})
end)


local cardio_gain_sprint_carry = 0

---@diagnostic disable-next-line: unused-local
function mod.CardioGainSprintMana(args, triggerArgs)
	if not boon_edit_on('CardioGain') then return end

	cardio_gain_sprint_carry = cardio_gain_sprint_carry + args.BoonEditManaGain
	local whole = math.floor(cardio_gain_sprint_carry)
	if whole > 0 then
		cardio_gain_sprint_carry = cardio_gain_sprint_carry - whole
		game.ManaDelta(whole)
	end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if hero then
		game.CreateAnimation({ Name = 'FireFootstepL', DestinationId = hero.ObjectId, OffsetX = -20 })
		game.CreateAnimation({ Name = 'FireFootstepR', DestinationId = hero.ObjectId, OffsetX = 20 })
	end
end
