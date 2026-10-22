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

local function glow_data()
	local effect = game.EffectData[GLOW_EFFECT]
	return effect and effect.EffectData
end

local function glow_apply(victim)
	local base = glow_data()
	if not base or not victim or not victim.ObjectId then return end

	local stacks = victim.BoonEditGlowStacks or 0
	if stacks <= 0 then
		game.ClearEffect({ Id = victim.ObjectId, Name = GLOW_EFFECT })
		return
	end

	local tuning = mod.tuning.Glow
	local modifier = math.min(base.Modifier + (stacks - 1) * tuning.GlowPerStack, tuning.GlowMax)

	game.ApplyEffect({
		DestinationId = victim.ObjectId,
		Id = game.CurrentRun.Hero.ObjectId,
		EffectName = GLOW_EFFECT,
		DataProperties = game.MergeAllTables({ base, { Modifier = modifier } }),
	})
end

function glow_expire(victim)
	local base = glow_data()
	game.wait((base and base.Duration) or 5, game.RoomThreadName)

	if not victim or victim.IsDead then return end
	victim.BoonEditGlowStacks = math.max((victim.BoonEditGlowStacks or 1) - 1, 0)
	glow_apply(victim)
end

function glow_inflict(victim)
	if not victim or not victim.ObjectId or victim.IsDead then return end

	victim.BoonEditGlowStacks = (victim.BoonEditGlowStacks or 0) + 1
	glow_apply(victim)
	game.thread(glow_expire, victim)
end

---@diagnostic disable-next-line: unused-local
function mod.AnvilGlow(victim, _victimId, triggerArgs)
	if not boon_edit_on('AnvilRing') then return end
	glow_inflict(victim)
end
