---@meta _


once('HiddenKnives', function()
	if not boon_edit_on('HiddenKnives') then return end

	modutil.mod.Path.Wrap('GetWeaponChargeStages', function(base, weaponData)
		local stages = base(weaponData)
		hidden_knives_ring(weaponData, stages)
		return stages
	end)
end)

function hidden_knives_ring(weaponData, stages)
	if not boon_edit_on('HiddenKnives') then return end
	if weaponData == nil or weaponData.Name ~= 'WeaponDaggerThrow' then return end
	if not game.HeroHasTrait('DaggerSpecialFanTrait') then return end
	if game.HeroHasTrait('DaggerSpecialLineTrait') then return end

	local arc = math.rad(mod.tuning.HiddenKnives.RingDegrees)
	for _, stage in pairs(stages) do
		local count = stage.WeaponProperties and stage.WeaponProperties.NumProjectiles
		if count and count > 1 then
			stage.WeaponProperties.ProjectileAngleOffset = arc / count
		end
	end
end
