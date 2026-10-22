---@meta _


once('SwordRing', function()
	if not boon_edit_on('SwordRing') then return end

	local swordRing = game.TraitData.AresCastBoon
	swordRing.OnCastEffectApplyFunction = {
		FunctionName = _PLUGIN.guid .. '.SwordRingCast',
		FunctionArgs = swordRing.OnEffectApplyFunction.FunctionArgs,
	}
end)


function mod.SwordRingCast(victim, functionArgs, projectileId)
	if not boon_edit_on('SwordRing') then return end
	if not victim or not victim.ObjectId or not projectileId then return end

	local contacts = game.SessionMapState.BoonEditSwordRing or {}
	game.SessionMapState.BoonEditSwordRing = contacts
	local touching = contacts[victim.ObjectId] or {}
	contacts[victim.ObjectId] = touching

	local now = game._worldTime or 0
	local window = mod.tuning.SwordRing.ContactWindow
	local fresh = not touching[projectileId] or now - touching[projectileId] > window

	local overlapped = false
	if fresh then
		for otherId, seen in pairs(touching) do
			if otherId ~= projectileId and now - seen <= window then
				overlapped = true
				break
			end
		end
	end

	touching[projectileId] = now

	if overlapped then
		game.CheckAresCurseApply(victim, functionArgs, { EffectName = 'ImpactSlow' })
	end
end
