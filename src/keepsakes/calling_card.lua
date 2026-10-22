---@meta _


once('CallingCard', function()
	modutil.mod.Path.Wrap('UpgradeMouseOverUpgradeChoice', function(base, screen, button)
		if not boon_edit_on('CallingCard') or not screen or screen.MouseOverButton == nil then
			return base(screen, button)
		end

		local lootData = screen.Source
		if not lootData or (not lootData.GodLoot and not lootData.TreatAsGodLootByShops) then
			return base(screen, button)
		end

		local mouseOverButton = screen.MouseOverButton
		local upgradeTraitData = nil
		for _, traitData in ipairs(game.CurrentRun.Hero.Traits) do
			if traitData.RarityUpgradeData then
				if not traitData.RarityUpgradeData.LootName
					and mouseOverButton.LootData
					and (mouseOverButton.LootData.GodLoot or mouseOverButton.LootData.TreatAsGodLootByShops)
					and (not traitData.RarityUpgradeData.RequireNotExcludeFromLastRunBoon or not mouseOverButton.LootData.ExcludeFromLastRunBoon) then
					if not traitData.RarityUpgradeData.RequireFated or game.IsFateValid() then
						upgradeTraitData = traitData
					end
				end
				if lootData.Name == traitData.RarityUpgradeData.LootName then
					if not traitData.RarityUpgradeData.RequireFated or game.IsFateValid() then
						upgradeTraitData = traitData
					end
					break
				end
			end
		end

		mod.CallingCardHeroicActive = (upgradeTraitData and upgradeTraitData.Name == 'RarifyKeepsake') or nil
		base(screen, button)
		mod.CallingCardHeroicActive = nil
	end)

	modutil.mod.Path.Wrap('GetUpgradedRarity', function(base, baseRarity, rarityUpgradeOrder)
		if mod.CallingCardHeroicActive and baseRarity ~= 'Heroic' then
			return 'Heroic'
		end
		return base(baseRarity, rarityUpgradeOrder)
	end)
end)
