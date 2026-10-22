---@meta _


local FROTH = 'AmplifyKnockbackEffect'


once('ScaldingVapor', function()
	if boon_edit_on('ScaldingVapor') then
		local froth = game.EffectData[FROTH]
		local kept = {}
		for _, name in ipairs(froth.ProjectileNameBlacklist or {}) do
			if name ~= 'SteamBlast' then
				table.insert(kept, name)
			end
		end
		froth.ProjectileNameBlacklist = kept
		froth.ProjectileNameBlacklistLookup = game.ToLookup(kept)

		local fireballs = fireball_projectiles()
		local steam = game.TraitData.SteamBoon
		steam.OnEnemyDamagedAction.ValidProjectiles = fireballs
		steam.OnEnemyDamagedAction.ValidProjectilesLookup = game.ToLookup(fireballs)

		steam.OnEnemyDamagedAction.AllEffectsTrigger = nil
		steam.OnEnemyDamagedAction.Args.ValidEffect = nil
	end

	modutil.mod.Path.Wrap("CheckSteam", function(base, victim, functionArgs, triggerArgs)
		if not boon_edit_on('ScaldingVapor') then
			return base(victim, functionArgs, triggerArgs)
		end
		if not scalding_vapor_fireball(triggerArgs) then return end

		scalding_vapor_stack(victim)
	end)
end)


function scalding_vapor_stack(victim)
	if not victim or not victim.ObjectId or not victim.ActiveEffects then return end
	if not victim.ActiveEffects[FROTH] then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	local clouds = {}
	for _, id in ipairs(victim.BoonEditSteamIds or {}) do
		if game.ProjectileExists({ Id = id }) then
			table.insert(clouds, id)
		end
	end

	if #clouds >= mod.tuning.ScaldingVapor.MaxClouds then
		local oldest = table.remove(clouds, 1)
		game.RefreshProjectile({ Id = oldest })
		table.insert(clouds, oldest)
	else
		local id = game.CreateProjectileFromUnit({
			Name = 'SteamBlast',
			Id = hero.ObjectId,
			DestinationId = victim.ObjectId,
		})
		if id then
			game.AttachProjectiles({ Ids = { id }, DestinationId = victim.ObjectId })
			table.insert(clouds, id)
		end
	end

	victim.BoonEditSteamIds = clouds
	victim.ActiveSteamId = clouds[#clouds]
end


function scalding_vapor_fireball(triggerArgs)
	if triggerArgs == nil or triggerArgs.EffectName ~= nil then return false end

	local projectile = triggerArgs.SourceProjectile
	return projectile ~= nil and game.Contains(fireball_projectiles(), projectile)
end
