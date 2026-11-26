---@meta _
---@diagnostic disable: lowercase-global


ARACHNE_DRESSES = {
	AgilityCostume = true, CastDamageCostume = true, ManaCostume = true, VitalityCostume = true,
	HighArmorCostume = true, IncomeCostume = true, SpellCostume = true, EscalatingCostume = true,
}


local function arachne_dresses_held(hero)
	local held = {}
	for _, trait in ipairs(hero.Traits or {}) do
		if ARACHNE_DRESSES[trait.Name] then held[trait] = true end
	end
	return held
end


local function arachne_dresses_stored(run)
	run.BoonEditDresses = run.BoonEditDresses or {}
	return run.BoonEditDresses
end


once('ArachneDresses', function()
	modutil.mod.Path.Wrap('OnHealthBufferDamage', function(base, hero, ...)
		if not boon_edit_on('ArachneDresses') or not game.CurrentRun or hero ~= game.CurrentRun.Hero then
			return base(hero, ...)
		end
		local before = arachne_dresses_held(hero)
		local result = base(hero, ...)
		local after = arachne_dresses_held(hero)
		local stored = arachne_dresses_stored(game.CurrentRun)
		for trait in pairs(before) do
			if not after[trait] then table.insert(stored, { Name = trait.Name, Rarity = trait.Rarity }) end
		end
		arachne_dresses_queue()
		return result
	end)

	for _, name in ipairs({ 'AddHealthBuffer', 'RemoveHealthBufferSource', 'SetupHeroObject' }) do
		modutil.mod.Path.Wrap(name, function(base, ...)
			local result = base(...)
			arachne_dresses_queue()
			return result
		end)
	end
end)


function arachne_dresses_queue()
	if not boon_edit_on('ArachneDresses') or mod.ArachneDressesQueued then return end
	mod.ArachneDressesQueued = true
	game.thread(function()
		game.wait(mod.tuning.ArachneDresses.SyncDelay)
		mod.ArachneDressesQueued = nil
		arachne_dresses_sync()
	end)
end


function arachne_dresses_sync()
	if not boon_edit_on('ArachneDresses') then return end
	local run = game.CurrentRun
	local hero = run and run.Hero
	if not hero or not hero.Traits or hero.IsDead then return end

	local stored = arachne_dresses_stored(run)
	local changed = false
	if (hero.HealthBuffer or 0) > 0 then
		for i = #stored, 1, -1 do
			local dress = table.remove(stored, i)
			if game.TraitData[dress.Name] and not game.HeroHasTrait(dress.Name) then
				local trait = game.AddTraitToHero({ TraitName = dress.Name, Rarity = dress.Rarity, SkipSetup = true, SkipNewTraitHighlight = true })
				if trait then
					trait.CurrentArmor = 0
					trait.BoonEditDressReturned = true
					changed = true
				end
			end
		end
	else
		for trait in pairs(arachne_dresses_held(hero)) do
			if trait.BoonEditDressReturned then
				table.insert(stored, { Name = trait.Name, Rarity = trait.Rarity })
				game.RemoveTraitData(hero, trait)
				changed = true
			end
		end
	end
	if changed then game.SetupCostume(game.MapState and game.MapState.HostilePolymorph) end
end
