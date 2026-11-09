---@meta _
---@diagnostic disable: lowercase-global


once('PerfectImageHealthOnly', function()
	if not boon_edit_on('PerfectImage') then return end

	modutil.mod.Path.Wrap('ResetPerfectDamageBonusBoon', function(base, attacker, args, triggerArgs)
		if perfect_image_spared(triggerArgs) then return end
		return base(attacker, args, triggerArgs)
	end)
end)


function perfect_image_spared(triggerArgs)
	if not boon_edit_on('PerfectImage') then return false end
	return triggerArgs ~= nil and triggerArgs.HealthProtected == true
end
