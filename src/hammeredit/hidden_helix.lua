---@meta _


local SPECIAL = 'WeaponTorchSpecial'


once('HiddenHelix', function()
	if not boon_edit_on('HiddenHelix') then return end

	local hiddenHelix = game.TraitData.TorchExSpecialCountTrait
	local extra = mod.tuning.HiddenHelix.ExtraProjectiles

	hiddenHelix.ChargeStageModifiers.IncreaseNumProjectiles.NumProjectiles = extra
	hiddenHelix.ChargeStageModifiers.AddWeaponProperties.ProjectileAngleOffset = math.rad(360 / 4)

	for _, property in ipairs(hiddenHelix.PropertyChanges) do
		if property.WeaponProperty == 'NumProjectiles' then
			property.ChangeValue = extra
		elseif property.WeaponProperty == 'ProjectileAngleOffset' then
			property.ChangeValue = math.rad(-360 / 3)
		end
	end

	modutil.mod.Path.Wrap('GetWeaponChargeStages', function(base, weaponData)
		local stages = base(weaponData)
		hidden_helix_seed(weaponData, stages)
		return stages
	end)
end)


function hidden_helix_seed(weaponData, stages)
	if not boon_edit_on('HiddenHelix') then return end
	if weaponData == nil or weaponData.Name ~= SPECIAL then return end
	if not game.HeroHasTrait('TorchExSpecialCountTrait') then return end

	local base = game.GetBaseDataValue({ Type = 'Weapon', Name = SPECIAL, Property = 'NumProjectiles' })
	if type(base) ~= 'number' or base <= 0 then base = 1 end

	for _, stage in pairs(stages) do
		stage.WeaponProperties = stage.WeaponProperties or {}
		if not stage.WeaponProperties.NumProjectiles then
			stage.WeaponProperties.NumProjectiles = base + mod.tuning.HiddenHelix.ExtraProjectiles
		end
	end
end
