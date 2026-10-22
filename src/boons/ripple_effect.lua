---@meta _


once('RippleEffectOmegaBoons', function()
	if boon_edit_on('RippleEffect') then
		local ripple = game.TraitData.MoneyDamageBoon

		ripple.DoubleOlympianProjectileChance = 0

		ripple.BoonEditRepeatChance = mod.tuning.RippleEffect.RepeatChance
		ripple.StatLines = { 'BoonEditRippleRepeatStatDisplay' }
		ripple.BoonEditMaxRepeats = mod.tuning.RippleEffect.MaxRepeats
		ripple.ExtractValues = {
			{
				Key = 'BoonEditRepeatChance',
				ExtractAs = 'Chance',
				Format = 'LuckModifiedPercent',
				HideSigns = true,
			},
			{ Key = 'BoonEditMaxRepeats', ExtractAs = 'TooltipMaxRepeats', SkipAutoExtract = true },
		}
	end

	modutil.mod.Path.Wrap("CreateProjectileFromUnit", function(base, args)
		local result = base(args)
		if ripple_effect_repeat then
			ripple_effect_repeat(args)
		end
		return result
	end)
end)


local RIPPLE_PROJECTILES = {
	PoseidonOmegaWave = true,
	ProjectileHeraOmega = true,
	ArtemisCastVolley = true,
	ProjectileFireball = true,
}


function ripple_effect_covers(name)
	return RIPPLE_PROJECTILES[name] == true
end

function ripple_effect_rolls()
	local tuning = mod.tuning.RippleEffect
	local chance = game.GetTotalHeroTraitValue('BoonEditRepeatChance')
	local repeats = 0

	while repeats < tuning.MaxRepeats and rolls(chance) do
		repeats = repeats + 1
		chance = chance * tuning.Falloff
	end

	return repeats
end


function ripple_effect_repeat(args)
	if mod.RippleFiring then return end
	if not boon_edit_on('RippleEffect') then return end
	if not args or not args.Name or not ripple_effect_covers(args.Name) then return end
	if not game.HeroHasTrait('MoneyDamageBoon') then return end


	local repeats = ripple_effect_rolls()
	if repeats <= 0 then return end

	local repeated = game.ShallowCopyTable(args)

	if repeated.ProjectileCap then
		repeated.ProjectileCap = repeated.ProjectileCap + repeats
	end

	game.thread(ripple_effect_refire, repeated, repeats)
end

function ripple_effect_refire(args, repeats)
	local interval = game.GetTotalHeroTraitValue('DoubleOlympianProjectileInterval')

	for _ = 1, repeats do
		game.waitUnmodified(interval)

		mod.RippleFiring = true
		local ok, err = pcall(game.CreateProjectileFromUnit, args)
		mod.RippleFiring = nil
		if not ok then
			print('[' .. _PLUGIN.guid .. '] ripple repeat failed: ' .. tostring(err))
			return
		end
	end
end
