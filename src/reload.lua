---@meta _


mod.SetupDone = mod.SetupDone or {}

function once(key, setup)
	if mod.SetupDone[key] then return end
	mod.SetupDone[key] = true
	setup()
end


BOON_EDIT_GROUPS = {
	{ 'Boons', 'Aphrodite' },
	{ 'Boons', 'Apollo' },
	{ 'Boons', 'Ares' },
	{ 'Boons', 'Athena' },
	{ 'Boons', 'Demeter' },
	{ 'Boons', 'Dionysus' },
	{ 'Boons', 'Hades' },
	{ 'Boons', 'Hephaestus' },
	{ 'Boons', 'Hera' },
	{ 'Boons', 'Hermes' },
	{ 'Boons', 'Hestia' },
	{ 'Boons', 'Medea' },
	{ 'Boons', 'Poseidon' },
	{ 'Boons', 'Selene' },
	{ 'Boons', 'Zeus' },
	{ 'Boons', 'Duos' },
	{ 'Boons', 'Legendaries' },
	{ 'Keepsakes' },
	{ 'Systems' },
	{ 'Experimental', 'Hammers' },
	{ 'Experimental', 'Keepsakes' },
	{ 'Experimental', 'Aspects' },
	{ 'Experimental', 'Mods' },
}

local boonEditGroupOf = {}

local function boon_edit_group(path)
	local node = config
	for _, key in ipairs(path) do
		node = node and node[key]
	end
	return node
end

function boon_edit_on(name)
	if config.enabled == false then return false end

	local path = boonEditGroupOf[name]
	if not path then
		for _, candidate in ipairs(BOON_EDIT_GROUPS) do
			local group = boon_edit_group(candidate)
			if group and group[name] ~= nil then
				path = candidate
				boonEditGroupOf[name] = path
				break
			end
		end
	end

	local group = path and boon_edit_group(path)
	return group ~= nil and group[name] == true
end

import 'tuning.lua'


SCREEN_WAIT_TRIES = 40
SCREEN_WAIT_STEP = 0.1

function prefix_SetupMap()
	reload_config()
	cherished_heirloom_place_keepsakes()
	white_antler_restore()
	aromatic_phial_apply()
	ionic_gain_start()
	boon_edit_sync_groups()
	burning_desire_sync()
end

function reload_config()
	local ok, reloaded = pcall(function()
		local loaded = chalk.auto('config.lua')
		return loaded
	end)
	if ok and reloaded then
		config = reloaded
		public.config = config
	else
		print('[' .. _PLUGIN.guid .. '] config reload failed: ' .. tostring(reloaded))
	end
end


function rolls(chance)
	return game.RandomChance(chance * game.GetTotalHeroTraitValue('LuckMultiplier', { IsMultiplier = true }))
end

function in_run()
	return game.CurrentRun ~= nil and game.CurrentRun.Hero ~= nil
end

function training_grounds()
	local hub = game.CurrentHubRoom
	return hub ~= nil and hub.AllowEnemyAIActive == true
end

function hero_live()
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return false end
	return not hero.IsDead or training_grounds()
end

function is_allied_summon(unit)
	if not unit then return false end
	if unit.AlwaysTraitor or unit.Charmed then return true end
	if unit.ObjectId and game.IsCharmed({ Id = unit.ObjectId }) then return true end
	return game.Contains(game.MapState.SpellSummons or {}, unit)
end

function boon_ignores(unit)
	return unit.SkipModifiers and not unit.TrainingTarget
end

function apply_hitch(unit)
	if not unit or not unit.ObjectId then return end
	if is_allied_summon(unit) then return end

	game.ApplyDamageShare(unit, { EffectName = 'DamageShareEffect' }, {})
end


KEYWORD_EXTRACTS = {
	Rend = {
		{ ExtractAs = 'AresCurseDuration', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'AresStatus', BaseProperty = 'Duration' },
		{ ExtractAs = 'AresCursePowerBonus', SkipAutoExtract = true, External = true,
			BaseType = 'EffectLuaData', BaseName = 'AresStatus', BaseProperty = 'BonusBaseDamageOnInflict' },
	},
	Weak = {
		{ ExtractAs = 'TooltipWeakModifier', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'WeakEffect', BaseProperty = 'Modifier',
			Format = 'NegativePercentDelta' },
		{ ExtractAs = 'TooltipWeakDuration', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'WeakEffect', BaseProperty = 'Duration' },
	},
	Burn = {
		{ ExtractAs = 'BurnRate', SkipAutoExtract = true, External = true,
			BaseType = 'EffectLuaData', BaseName = 'BurnEffect', BaseProperty = 'DamagePerSecond',
			DecimalPlaces = 1 },
	},
	KnockbackAmplify = {
		{ ExtractAs = 'KnockbackAmplifyDuration', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'AmplifyKnockbackEffect', BaseProperty = 'Duration',
			DecimalPlaces = 1 },
		{ ExtractAs = 'FontChance', SkipAutoExtract = true, External = true,
			BaseType = 'EffectLuaData', BaseName = 'AmplifyKnockbackEffect', BaseProperty = 'Chance',
			Format = 'LuckModifiedPercent' },
		{ ExtractAs = 'FontDamage', SkipAutoExtract = true, External = true,
			BaseType = 'ProjectileBase', BaseName = 'PoseidonEffectFont', BaseProperty = 'Damage' },
	},
	HeartBurst = {
		{ ExtractAs = 'Duration', SkipAutoExtract = true, External = true,
			BaseType = 'ProjectileBase', BaseName = 'AphroditeBurst', BaseProperty = 'Fuse' },
	},
	DelayedKnockback = {
		{ ExtractAs = 'DelayedKnockbackModifier', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'DelayedKnockbackEffect', BaseProperty = 'Modifier',
			Format = 'PercentDelta' },
		{ ExtractAs = 'DelayedKnockbackDuration', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'DelayedKnockbackEffect', BaseProperty = 'Duration',
			DecimalPlaces = 1 },
	},
	Blind = {
		{ ExtractAs = 'BlindChance', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'BlindEffect', BaseProperty = 'MissChance',
			Format = 'Percent' },
		{ ExtractAs = 'BlindDuration', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'BlindEffect', BaseProperty = 'Duration' },
	},
}


function with_keyword_extracts(own, ...)
	local combined = {}
	for _, entry in ipairs(own or {}) do table.insert(combined, entry) end

	for _, keyword in ipairs({ ... }) do
		for _, entry in ipairs(KEYWORD_EXTRACTS[keyword] or {}) do
			table.insert(combined, entry)
		end
	end
	return combined
end


function rush_end_suppressed(args)
	if not hero_live() then return true end

	if not (args and args.CheckSprint) then return false end
	if not game.SessionMapState.SprintActive then return false end

	return true
end


function rush_impact_ring(name, radius, pulses, delay, destinationId)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not name then return end

	destinationId = destinationId or (hero and hero.ObjectId)
	if not destinationId then return end

	local function draw()
		game.CreateAnimation({
			Name = name,
			DestinationId = destinationId,
			ScaleRadius = radius,
		})
	end

	draw()
	for _ = 2, (pulses or 1) do
		game.thread(function()
			game.wait(delay or 0.1, game.RoomThreadName)
			draw()
		end)
	end
end


function create_heartthrob(burstArgs)
	if not burstArgs then return end
	game.thread(game.CreateManaBurst, burstArgs, 1 + game.GetTotalHeroTraitValue('BurstCount'))
end


trait_text = {}
help_text = {}
stat_lines = {}
flavor_text = {}
combat_text = {}

function boon_edit_add_stat(traitName, statLine, extract)
	local trait = game.TraitData[traitName]
	if not trait then return end

	trait.ExtractValues = trait.ExtractValues or {}
	table.insert(trait.ExtractValues, extract)

	trait.StatLines = trait.StatLines or {}
	if game.Contains(trait.StatLines, statLine) then return end
	if #trait.StatLines >= 2 then
		trait.StatLines[2] = statLine
	else
		table.insert(trait.StatLines, statLine)
	end
end

function boon_edit_stat_index(traitName, extractAs)
	local index = 0
	for _, extract in ipairs((game.TraitData[traitName] or {}).ExtractValues or {}) do
		if not extract.SkipAutoExtract then
			index = index + 1
			if extract.ExtractAs == extractAs then return index end
		end
	end
	return 1
end

function boon_text(spec)
	for id, entry in pairs(spec.Traits or {}) do trait_text[id] = entry end
	for id, entry in pairs(spec.Keywords or {}) do help_text[id] = entry end
	for id, entry in pairs(spec.StatLines or {}) do stat_lines[id] = entry end
	for id, entry in pairs(spec.Flavor or {}) do flavor_text[id] = entry end
	for id, entry in pairs(spec.CombatText or {}) do combat_text[id] = entry end
end

function sjson_PlayerProjectiles(data)
	local damages = {}

	if glorious_disaster_supercharged() then
		damages.ZeusApolloSynergyStrike = mod.tuning.GloriousDisaster.BoltDamage
	end

	if beach_ball_rebalanced() then
		damages.ProjectileSprintBall = mod.tuning.BeachBall.BlastDamage
	end

	for _, projectile in ipairs(data.Projectiles) do
		local damage = damages[projectile.Name]
		if damage then projectile.Damage = damage end
	end
end

function sjson_EnemyProjectiles(data)
	if not data or not data.Projectiles then return end

	local tuning = mod.tuning.VolcanicCrown
	local order = {
		'Name', 'InheritFrom', 'Damage', 'TotalFuse', 'SpawnOnDetonate',
		'AffectsEnemies', 'AffectsFriends', 'AffectsSelf',
	}

	local existing = {}
	for _, projectile in ipairs(data.Projectiles) do
		existing[projectile.Name] = true
	end

	local copies = {
		{
			Name = tuning.FireProjectile,
			InheritFrom = 'DevotionHestiaFire',
			Damage = tuning.FireDamage,
			TotalFuse = tuning.FireDuration,
		},
		{
			Name = tuning.FireballProjectile,
			InheritFrom = 'DevotionHestia',
			Damage = tuning.FireballDamage.Common,
			SpawnOnDetonate = sjson.null,
		},
	}

	for _, copy in ipairs(copies) do
		if not existing[copy.Name] then
			copy.AffectsEnemies = true
			copy.AffectsFriends = false
			copy.AffectsSelf = false
			table.insert(data.Projectiles, sjson.to_object(copy, order))
		end
	end
end

function sjson_PoseidonVfx(data)
	if not data or not data.Animations then return end

	for _, animation in ipairs(data.Animations) do
		if animation.Name == mod.tuning.PoseidonSplash.RedNova then return end
	end

	table.insert(data.Animations, sjson.to_object({
		Name = mod.tuning.PoseidonSplash.RedNova,
		InheritFrom = 'RadialNovaPentagram_Poseidon',
		ClearCreateAnimations = true,
		StartRed = 1,
		StartGreen = 0.01,
		StartBlue = 0.01,
		EndRed = 0.7,
		EndGreen = 0,
		EndBlue = 0,
	}, {
		'Name', 'InheritFrom', 'ClearCreateAnimations',
		'StartRed', 'StartGreen', 'StartBlue', 'EndRed', 'EndGreen', 'EndBlue',
	}))
end


function sjson_CastVfx(data)
	if not data or not data.Animations then return end

	local existing = {}
	for _, animation in ipairs(data.Animations) do
		existing[animation.Name] = true
	end

	local circles = {
		{ Name = mod.tuning.BreakerRush.ImpactFx, InheritFrom = 'CastCircleOutPoseidon', Bare = true },
		{ Name = mod.tuning.SmithyRush.ImpactFx, InheritFrom = 'CastCircleOutHephaestus', Bare = true },
	}

	for _, circle in ipairs(circles) do
		if circle.Name and not existing[circle.Name] then
			local entry = {
				Name = circle.Name,
				InheritFrom = circle.InheritFrom,
				Sound = 'null',
			}
			local order = { 'Name', 'InheritFrom', 'Sound' }

			if circle.Bare then
				entry.ClearCreateAnimations = true
				table.insert(order, 'ClearCreateAnimations')
			end

			table.insert(data.Animations, sjson.to_object(entry, order))
		end
	end
end


function sjson_HelpText(data)
	for _, entry in ipairs(data.Texts) do
		local rewrite = help_text[entry.Id]
		if rewrite and rewrite.Description then
			entry.Description = rewrite.Description
		end
	end
end

function sjson_TraitText(data)
	local rewritten = {}

	for _, entry in ipairs(data.Texts) do
		local rewrite = trait_text[entry.Id]
		if rewrite then
			rewritten[entry.Id] = true
			if rewrite.DisplayName then
				entry.DisplayName = rewrite.DisplayName
			end
			if rewrite.Description then
				entry.Description = rewrite.Description
			end
		end
	end

	for id, entry in pairs(trait_text) do
		if not rewritten[id] then
			local text = { Id = id }
			local order = { 'Id' }

			if entry.DisplayName then
				text.DisplayName = entry.DisplayName
				table.insert(order, 'DisplayName')
			end
			if entry.Description then
				text.Description = entry.Description
				table.insert(order, 'Description')
			end

			table.insert(data.Texts, sjson.to_object(text, order))
		end
	end

	local statLineOrder = { 'Id', 'InheritFrom', 'DisplayName', 'Description' }

	for id, entry in pairs(stat_lines) do
		local name = type(entry) == 'table' and entry.Name or entry
		local index = (type(entry) == 'table' and entry.Index) or 1
		local suffix = (type(entry) == 'table' and entry.Suffix) or ''
		table.insert(data.Texts, sjson.to_object({
			Id = id,
			InheritFrom = 'BaseStatLine',
			DisplayName = '{!Icons.Bullet}{#PropertyFormat}' .. name,
			Description = '{#UpgradeFormat}{$TooltipData.StatDisplay' .. index .. '}' .. suffix,
		}, statLineOrder))
	end

	local flavorOrder = { 'Id', 'DisplayName' }
	for id, text in pairs(flavor_text) do
		table.insert(data.Texts, sjson.to_object({ Id = id, DisplayName = text }, flavorOrder))
	end

	for id, text in pairs(combat_text) do
		table.insert(data.Texts, sjson.to_object({ Id = id, DisplayName = text }, flavorOrder))
	end
end


import 'boons/fireballs.lua'
import 'boons/glamour_gain.lua'
import 'boons/passion_rush.lua'
import 'boons/carnal_pleasure.lua'
import 'boons/smoldering_forge.lua'
import 'boons/ecstatic_obsession.lua'
import 'boons/hearty_appetite.lua'
import 'boons/secret_crush.lua'

import 'boons/stabbing_rush.lua'
import 'boons/profuse_bleeding.lua'
import 'boons/meat_grinder.lua'
import 'boons/sword_ring.lua'
import 'boons/hostile_environment.lua'
import 'boons/blood_spree.lua'
import 'boons/grape_juice.lua'
import 'boons/festive_fog.lua'

import 'boons/phalanx_shot.lua'

import 'boons/sun_worshiper.lua'
import 'boons/dazzling_display.lua'
import 'boons/extra_dose.lua'

import 'boons/local_climate.lua'
import 'boons/tranquil_gain.lua'
import 'boons/winter_harvest.lua'
import 'boons/natural_selection.lua'
import 'boons/cryo_pounder.lua'
import 'boons/arctic_gale.lua'
import 'boons/weed_killer.lua'
import 'boons/snow_queen.lua'

import 'boons/unseen_ire.lua'
import 'boons/old_grudge.lua'

import 'boons/anvil_ring.lua'
import 'boons/smithy_rush.lua'
import 'boons/heavy_metal.lua'
import 'boons/burning_desire.lua'
import 'boons/controlled_burn.lua'
import 'boons/molten_touch.lua'
import 'boons/premium_service.lua'
import 'boons/chain_reaction.lua'
import 'boons/seismic_hammer.lua'
import 'boons/brave_face.lua'

import 'boons/rousing_reception.lua'
import 'boons/all_together.lua'
import 'boons/cherished_heirloom.lua'

import 'boons/mean_streak.lua'
import 'boons/post_haste.lua'
import 'boons/second_wind.lua'
import 'boons/stutter_step.lua'

import 'boons/burning_meteor.lua'
import 'boons/cardio_gain.lua'
import 'boons/scalding_vapor.lua'
import 'boons/volcanic_crown.lua'

import 'boons/breaker_rush.lua'
import 'boons/easy_shot.lua'
import 'boons/beach_ball.lua'
import 'boons/arterial_spray.lua'
import 'boons/ripple_effect.lua'

import 'boons/shocking_loss.lua'
import 'boons/killer_current.lua'
import 'boons/air_quality.lua'
import 'boons/power_surge.lua'
import 'boons/arc_flash.lua'

import 'boons/thermal_dynamics.lua'

import 'boons/harm_for_the_afflicted.lua'

import 'boons/preparation.lua'

import 'boons/ionic_gain.lua'
import 'boons/glorious_disaster.lua'

import 'keepsakes/aromatic_phial.lua'
import 'keepsakes/concave_stone.lua'
import 'keepsakes/calling_card.lua'
import 'keepsakes/white_antler.lua'
import 'keepsakes/metallic_droplet.lua'

import 'aspects/aspect_of_supay.lua'

import 'hammeredit/dual_moonshot.lua'
import 'hammeredit/reaper_knives.lua'
import 'hammeredit/enduring_coil.lua'
import 'hammeredit/hidden_helix.lua'
import 'hammeredit/hidden_knives.lua'
import 'hammeredit/rising_helix.lua'
import 'hammeredit/whirling_helix.lua'


import 'requirements.lua'
import 'text.lua'

function poseidon_splash_cone(waveFx)
	local scale = 1
	local count = 1
	local graphic = nil

	for _, data in pairs(game.GetHeroTraitValues('ConeModifier')) do
		if data.ScaleIncrease then
			scale = scale * data.ScaleIncrease
		end
		if data.MaxScale and scale > data.MaxScale then
			scale = data.MaxScale
		end
		if data.DoubleWaveChance and game.RandomChance(data.DoubleWaveChance
			* game.GetTotalHeroTraitValue('LuckMultiplier', { IsMultiplier = true })) then
			count = count + 1
			graphic = waveFx or data.DoubleWaveGraphic
		end
	end

	return scale, count, graphic
end


function cast_area_multiplier()
	local multiplier = 1

	for _, data in pairs(game.GetHeroTraitValues('CastProjectileModifiers')) do
		if data.AreaIncrease then
			multiplier = multiplier * data.AreaIncrease
		end
	end

	return multiplier
end


function wait_for_screens(settle)
	settle = settle or 0

	for _ = 1, SCREEN_WAIT_TRIES do
		if not game.IsEmpty(game.ActiveScreenOrder or {}) then
			game.waitUnmodified(SCREEN_WAIT_STEP)
		else
			if settle > 0 then game.waitUnmodified(settle) end
			if game.IsEmpty(game.ActiveScreenOrder or {}) then return end
		end
	end
end

function defer_screen_open(open, ...)
	if game.IsEmpty(game.ActiveScreenOrder or {}) then
		return open(...)
	end

	local args = table.pack(...)
	game.thread(function()
		wait_for_screens(0)
		open(table.unpack(args, 1, args.n))
	end)
end
