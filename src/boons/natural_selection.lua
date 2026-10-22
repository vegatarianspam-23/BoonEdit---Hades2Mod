---@meta _


once('NaturalSelectionPoms', function()
	if boon_edit_on('NaturalSelection') then
		local selection = game.TraitData.GoodStuffBoon

		selection.AcquireFunctionName = _PLUGIN.guid .. '.NaturalSelectionAcquire'
		selection.AcquireFunctionArgs = nil

		selection.CurrentRoom = 0
		selection.RoomsPerUpgrade = {
			Amount = { BaseValue = mod.tuning.NaturalSelection.EncountersPerPom },
		}

		selection.BoonEditEncountersPerPom = mod.tuning.NaturalSelection.EncountersPerPom
		selection.BoonEditPomsOnPickup = mod.tuning.NaturalSelection.PomsOnPickup
		selection.BoonEditLevelsPerPom = mod.tuning.NaturalSelection.LevelsPerPom
		selection.StatLines = { 'BoonEditNaturalSelectionStatDisplay' }
		selection.ExtractValues = {
			{ Key = 'BoonEditEncountersPerPom', ExtractAs = 'TooltipEncounters' },
			{ Key = 'BoonEditPomsOnPickup', ExtractAs = 'TooltipPoms', SkipAutoExtract = true },
			{ Key = 'BoonEditLevelsPerPom', ExtractAs = 'TooltipLevelsPerPom', SkipAutoExtract = true },
		}
	end

	modutil.mod.Path.Wrap("CheckChamberTraits", function(base, ...)
		base(...)
		natural_selection_check_pom()
	end)

	modutil.mod.Path.Wrap("CreateBoonLootButtons", function(base, screen, lootData, reroll, args)
		if not reroll then
			natural_selection_reroll(lootData)
		end
		return base(screen, lootData, reroll, args)
	end)
end)


local NATURAL_SELECTION_POM_SPREAD = 190

local NATURAL_SELECTION_POM_DELAY = 0.5

local POM_LOOT_BY_LEVEL = {
	[1] = 'StackUpgrade',
	[2] = 'StackUpgradeBig',
	[3] = 'StackUpgradeTriple',
}

function natural_selection_pom_loot(levels)
	local name = POM_LOOT_BY_LEVEL[levels]
	if name then return name, nil end
	return 'StackUpgrade', levels
end

local NATURAL_SELECTION_ROLL_STRIDE = 64

function natural_selection_mark_pom(pom)
	if not pom then return end

	local run = game.CurrentRun
	if not run then return end

	run.BoonEditNaturalSelectionRoll = (run.BoonEditNaturalSelectionRoll or 0) + 1
	pom.BoonEditNaturalSelection = run.BoonEditNaturalSelectionRoll
end

function natural_selection_drop_poms(count, levels)
	game.wait(NATURAL_SELECTION_POM_DELAY)

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or not game.CurrentRun.CurrentRoom then return end

	local lootName, stackNum = natural_selection_pom_loot(levels)

	local where = game.GetLocation({ Id = hero.ObjectId })
	local anchorId = game.SpawnObstacle({
		Name = 'InvisibleTarget',
		LocationX = where.X,
		LocationY = where.Y,
	})

	for index = 1, count do
		local pom = game.CreateLoot({
			Name = lootName,
			StackNum = stackNum,
			AutoLoadPackages = true,
			DoesNotBlockExit = true,
			SpawnPoint = anchorId,
			OffsetX = game.RandomFloat(-NATURAL_SELECTION_POM_SPREAD, NATURAL_SELECTION_POM_SPREAD),
			OffsetY = game.RandomFloat(-NATURAL_SELECTION_POM_SPREAD, NATURAL_SELECTION_POM_SPREAD),
		})

		natural_selection_mark_pom(pom)

		if pom and pom.ObjectId then
			game.ApplyUpwardForce({ Id = pom.ObjectId, Speed = game.RandomFloat(500, 700) })
			game.ApplyForce({
				Id = pom.ObjectId,
				Speed = game.RandomFloat(75, 150),
				Angle = game.RandomFloat(0, 360),
				SelfApplied = true,
			})
		end
	end
end

---@diagnostic disable-next-line: unused-local
function mod.NaturalSelectionAcquire(args, traitData)
	if not boon_edit_on('NaturalSelection') then return end
	game.thread(natural_selection_drop_poms, mod.tuning.NaturalSelection.PomsOnPickup, mod.tuning.NaturalSelection.LevelsPerPom)
end

function natural_selection_check_pom()
	if not boon_edit_on('NaturalSelection') then return end
	if not game.CurrentRun or not game.CurrentRun.Hero then return end

	local trait = game.GetHeroTrait('GoodStuffBoon')
	if not trait or not trait.RoomsPerUpgrade then return end
	if trait.CurrentRoom ~= 0 then return end

	game.thread(natural_selection_drop_poms, 1, mod.tuning.NaturalSelection.LevelsPerPom)
end


function natural_selection_reroll(source)
	if not boon_edit_on('NaturalSelection') then return end

	local roll = source and source.BoonEditNaturalSelection
	if type(roll) ~= 'number' then return end

	game.RandomSynchronize(roll * NATURAL_SELECTION_ROLL_STRIDE)
	source.UpgradeOptions = nil
end
