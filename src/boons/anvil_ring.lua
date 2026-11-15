---@meta _


once('AnvilRing', function()
	if not boon_edit_on('AnvilRing') then return end

	local blast = game.ProjectileData.HephCastBlast
	blast.OnHitFunctionNames = blast.OnHitFunctionNames or {}
	table.insert(blast.OnHitFunctionNames, _PLUGIN.guid .. '.AnvilGlow')

	local cast = game.TraitData.HephaestusCastBoon

	local baseDamage = game.GetBaseDataValue({ Type = 'Projectile', Name = 'HephCastBlast', Property = 'Damage' })
	if type(baseDamage) ~= 'number' or baseDamage <= 0 then
		baseDamage = 60
	end
	local cut = 10 / baseDamage

	for _, level in pairs(cast.RarityLevels) do
		level.Multiplier = level.Multiplier - cut
	end

	cast.ExtractValues = with_keyword_extracts(cast.ExtractValues, 'DelayedKnockback')
end)


local GLOW_EFFECT = 'DelayedKnockbackEffect'

function glow_inflict(victim)
	if not victim or not victim.ObjectId or victim.IsDead then return end

	local effect = game.EffectData[GLOW_EFFECT]
	if not effect or not effect.EffectData then return end

	game.ApplyEffect({
		DestinationId = victim.ObjectId,
		Id = game.CurrentRun.Hero.ObjectId,
		EffectName = GLOW_EFFECT,
		DataProperties = effect.EffectData,
	})
end

---@diagnostic disable-next-line: unused-local
function mod.AnvilGlow(victim, _victimId, triggerArgs)
	if not boon_edit_on('AnvilRing') then return end
	glow_inflict(victim)
end
