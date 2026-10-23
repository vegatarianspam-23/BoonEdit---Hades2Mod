---@meta _


if boon_edit_on('GlamourGain') then
	boon_text({
		Traits = {
			AphroditeManaBoon = {
				Description = 'Every {#BoldFormatGraft}1 Sec.{#Prev}, automatically inflict {$Keywords.Weak} on nearby foes and restore {!Icons.Mana} for {#ItalicFormat}each{#Prev}.',
			},
		},
		StatLines = {
			BoonEditGlamourManaStatDisplay = { Name = 'Magick Restored per Foe:', Index = 1 },
		},
	})
end

if boon_edit_on('FestiveFog') then
	boon_text({
		Traits = {
			FogDamageBonusBoon = {
				Description = 'Every {#BoldFormatGraft}{$TooltipData.ExtractData.Interval} Sec. {#Prev}in each ' ..
					'{$Keywords.EncounterAlt}, {$Keywords.Cloud} appears. While you are in it, you deal more ' ..
					'damage and take less damage.',
			},
		},
		StatLines = {
			BoonEditFestiveFogShelterStatDisplay = {
				Name = 'Damage Taken in {$Keywords.Cloud}:',
				Index = boon_edit_stat_index('FogDamageBonusBoon', 'TooltipShelter'),
			},
		},
	})
end

if boon_edit_on('GrapeJuice') then
	boon_text({
		StatLines = {
			BoonEditGrapeJuiceHealStatDisplay = {
				Name = 'Life Restored per Drink:',
				Index = boon_edit_stat_index('PowerDrinkBoon', 'TooltipDrinkHeal'),
			},
		},
		Keywords = {
			DrinkDrop = {
				Description = 'Restores {!Icons.Health} and gives your very next move ' ..
					'{#UpgradeFormat}+{$TooltipData.ExtractData.Damage} {#Prev}{$Keywords.BaseDamage}, ' ..
					'then later reappears in a random spot.',
			},
		},
	})
end

if boon_edit_on('HeartyAppetite') then
	boon_text({
		Traits = {
			MaxHealthDamageBoon = {
				Description = 'You deal more damage with your {$Keywords.WeaponSet} the more {!Icons.HealthUpTotal} ' ..
					'you have, and restore more {!Icons.Health} this night. Gain a healing reward now, and ' ..
					'another every {#BoldFormatGraft}{$TooltipData.ExtractData.TooltipEncountersPerFood} ' ..
					'{$Keywords.EncounterPlural}{#Prev}.',
			},
		},
		StatLines = {
			BoonEditHeartyAppetiteHealingStatDisplay = { Name = 'Bonus Healing:', Index = 2 },
		},
	})
end

if boon_edit_on('SecretCrush') then
	boon_text({
		Traits = {
			FocusRawDamageBoon = {
				Description = 'Your {$Keywords.WeaponSet} strikes gain ' ..
					'{$Keywords.BaseDamage}, but you {$Keywords.ReserveMana} ' ..
					'{#ManaFormat}{$TooltipData.ExtractData.TooltipCost}{#Prev}{!Icons.Mana}.',
			},
		},
	})
end

if boon_edit_on('DazzlingDisplay') then
	boon_text({
		Traits = {
			BlindChanceBoon = {
				Description = 'Your {#BoldFormatGraft}Nova Strike {#Prev}and {#BoldFormatGraft}Nova Flourish ' ..
					'{#Prev}inflict {$Keywords.Blind}.',
			},
		},
		StatLines = {
			BoonEditDazzlingPotencyStatDisplay = {
				Name = '{$Keywords.Blind} Potency:',
				Index = 1,
			},
		},
	})
end

if boon_edit_on('ExtraDose') then
	boon_text({
		Traits = {
			DoubleStrikeChanceBoon = {
				Description = 'Your {$Keywords.Attack} and {$Keywords.Special} have a chance to hit ' ..
					'{$TraitData.DoubleStrikeChanceBoon.StringTextNumeral} times.',
			},
		},
	})
end

if boon_edit_on('CarnalPleasure') then
	boon_text({
		Traits = {
			BloodManaBurstBoon = {
				Description = 'Each {!Icons.BloodDropIcon} you collect counts toward ' ..
					'{$TraitData.ManaBurstBoon.Name} as {!Icons.Mana} used. Your {$Keywords.HeartBurstPlural} ' ..
					'deal more damage for each {!Icons.BloodDropIcon} you have.',
			},
		},
		StatLines = {
			BoonEditCarnalManaStatDisplay = { Name = 'Magick per Plasma:', Index = 1 },
			BoonEditCarnalDamageStatDisplay = { Name = '{$Keywords.HeartBurst} Power per Plasma:', Index = 2 },
		},
	})
end

if boon_edit_on('SmolderingForge') then
	boon_text({
		Traits = {
			SlamManaBurstBoon = {
				DisplayName = 'Smoldering Forge',
				Description = 'Your {$Keywords.Attack} and {$Keywords.Special} may create a ' ..
					'{$Keywords.HeartBurst} when they strike foes with {$Keywords.DelayedKnockback}.',
			},
		},
		StatLines = {
			BoonEditSmolderingForgeStatDisplay = { Name = '{$Keywords.HeartBurst} Chance:', Index = 1 },
		},
		Flavor = {
			BoonEditSmolderingForgeFlavorText = 'Struck while the iron is hot.',
		},
	})
end

if boon_edit_on('EcstaticObsession') then
	boon_text({
		Traits = {
			RandomStatusBoon = {
				DisplayName = 'Ecstatic Obsession',
				Description = 'Whenever you inflict {$Keywords.Weak}, you may inflict {$Keywords.Charm} ' ..
					'instead. You deal more damage for each nearby character fighting for you.',
			},
			CharmCrowdBoon = {
				DisplayName = 'Nervous Wreck',
				Description = 'Whenever you inflict {$Keywords.Weak}, also randomly inflict ' ..
					'{$Keywords.StatusPlural} from other Olympians.',
			},
		},
		StatLines = {
			BoonEditObsessionChanceStatDisplay = { Name = '{$Keywords.Charm} Chance:', Index = 1 },
		},
	})
end

if boon_edit_on('MeatGrinder') then
	boon_text({
		Traits = {
			AresExCastBoon = {
				Description = 'Your {$Keywords.CastEX} also creates a {$Keywords.BladeRift} in the ' ..
					'binding circle, which may cause foes to spill {!Icons.BloodDropIcon}.',
			},
		}
	})
end

if boon_edit_on('ControlledBurn') then
	boon_text({
		Traits = {
			FireballManaSpecialBoon = {
				Description = 'Your {$Keywords.AttackEX} and {$Keywords.SpecialEX} also launch a ' ..
					'fireball, but use {#ManaFormat}+{$TooltipData.ExtractData.TooltipManaCost}' ..
					'{#Prev}{!Icons.Mana}.',
			},
		}
	})
end

if boon_edit_on('ProfuseBleeding') then
	boon_text({
		Traits = {
			RendBloodDropBoon = {
				Description = '{$Keywords.Rend}-afflicted foes may spill {!Icons.BloodDropIcon} whenever they take damage.',
			},
			RendBloodDropBoon_Tray = {
				Description = '{$Keywords.Rend}-afflicted foes may spill {!Icons.BloodDropWithCountIcon} whenever they take damage.',
			},
		},
		StatLines = {
			BoonEditBloodSpillChanceStatDisplay = { Name = '{$Keywords.BloodDrop_NoTooltip} Chance:', Index = 1 },
		},
	})
end

if boon_edit_on('BloodSpree') then
	boon_text({
		Traits = {
			LowHealthLifestealBoon = {
				Description = 'While you have less than ' ..
					'{$TooltipData.ExtractData.ReportedRequirement}{!Icons.Health}, your ' ..
					'{$Keywords.AttackSet} and {$Keywords.SpecialSet} restore {!Icons.Health}. ' ..
					'Whenever you slay a foe, restore that much {!Icons.Health} {#BoldFormatGraft}' ..
					'{$TooltipData.ExtractData.TooltipKillHealChance}% {#Prev}of the time.',
			},
		},
	})
end

if boon_edit_on('HostileEnvironment') then
	boon_text({
		Traits = {
			SelfCastBoon = {
				Description = 'Your {$Keywords.CastEX} is stronger, and all your {$Keywords.CastSet} follow you.',
			},
		},
	})
end

if boon_edit_on('SunWorshiper') then
	boon_text({
		Traits = {
			RaiseDeadBoon = {
				Description = 'In each {$Keywords.EncounterAlt}, the first foe you slay returns to fight for you, '
					.. 'and others may as well.',
			},
		},
		StatLines = {
			BoonEditRepeatRaiseStatDisplay = { Name = 'Repeat Revival Chance:', Index = 2 },
		},
	})
end

if boon_edit_on('LocalClimate') then
	boon_text({
		Traits = {
			CastAttachBoon = {
				Description = 'Your {$Keywords.CastSet} deal more damage. If you are in the binding circle, the bonus is doubled.',
			},
		},
	})
end

if boon_edit_on('SnowQueen') then
	boon_text({
		Traits = {
			ReserveManaHitShieldBoon = {
				Description = 'Gain a barrier that stops {#BoldFormatGraft}1 {#Prev}instance of damage in each {$Keywords.EncounterAlt}, but you {$Keywords.ReserveMana} {!Icons.Mana}.',
			},
		},
	})
end

if boon_edit_on('TranquilGain') then
	boon_text({
		Traits = {
			DemeterManaBoon = {
				Description = 'After you {$Keywords.HoldNoTooltip} your {$Keywords.Omega} for {#BoldFormat}{$TooltipData.ExtractData.TooltipMovePenaltyDuration} Sec.{#Prev}, rapidly restore {!Icons.Mana} until you release them.',
			},
		},
	})
end

if boon_edit_on('NaturalSelection') then
	boon_text({
		Traits = {
			GoodStuffBoon = {
				Description = 'Gain {#BoldFormatGraft}{$TooltipData.ExtractData.TooltipPoms}' ..
					'{#Prev}{!Icons.Pom} worth {#BoldFormatGraft}+' ..
					'{$TooltipData.ExtractData.TooltipLevelsPerPom} {#Prev}{$Keywords.PomLevel} each, ' ..
					'then {#BoldFormatGraft}1 {#Prev}more every {#BoldFormatGraft}' ..
					'{$TooltipData.ExtractData.TooltipEncounters} {$Keywords.EncounterPlural}{#Prev}.',
			},
		},
		StatLines = {
			BoonEditNaturalSelectionStatDisplay = { Name = '{$Keywords.EncounterPlural} per Pom:', Index = 1 },
		},
	})
end

if boon_edit_on('CryoPounder') then
	boon_text({
		Traits = {
			ClearRootBoon = {
				Description = '{$Keywords.Root}-afflicted foes with {$Keywords.DelayedKnockback} take more ' ..
					'damage from any source.',
			},
		},
	})
end

if boon_edit_on('WeedKiller') then
	boon_text({
		Traits = {
			SlowExAttackBoon = {
				Description = 'Your {$Keywords.AttackEX} and {$Keywords.SpecialEX} deal more damage, ' ..
					'but use {#ManaFormat}+{$TooltipData.ExtractData.ManaCostAddition}{#Prev}{!Icons.Mana}.',
			},
		},
		StatLines = {
			BoonEditWeedKillerStatDisplay = { Name = 'Omega Move Damage:', Index = 1 },
		},
	})
end

if boon_edit_on('AnvilRing') then
	boon_text({
		Traits = {
			HephaestusCastBoon = {
				Description = 'Your {$Keywords.CastSet} deal damage {$TooltipData.ExtractData.Detonations} times in succession to foes in the binding circle, inflicting {$Keywords.DelayedKnockback}.',
			},
		},
	})
end

if boon_edit_on('SmithyRush') then
	boon_text({
		Traits = {
			HephaestusSprintBoon = {
				Description = '{$Keywords.DashSet} damages surrounding foes and inflicts {$Keywords.DelayedKnockback}, and again once you stop.',
			},
		},
	})
end

if boon_edit_on('HeavyMetal') then
	boon_text({
		Traits = {
			HeavyArmorBoon = {
				Description = 'Your {$Keywords.WeaponSet} deals more damage based on ' ..
					'{$TooltipData.ExtractData.TooltipBonus:F} of your {!Icons.ArmorTotal}, and you gain ' ..
					'some now. Foes\' blows cannot knock you back.',
			},
		},
	})
end

if boon_edit_on('MoltenTouch') then
	boon_text({
		Traits = {
			AntiArmorBoon = {
				Description = 'Your {$Keywords.AttackSet} and {$Keywords.SpecialSet} deal more damage to ' ..
					'{$Keywords.Armor} and foes with {$Keywords.DelayedKnockback}.',
			},
		},
		StatLines = {
			BoonEditMoltenGlowStatDisplay = {
				Name = 'Bonus Damage vs. {$Keywords.DelayedKnockback}:',
				Index = boon_edit_stat_index('AntiArmorBoon', 'TooltipGlowBonus'),
			},
		},
	})
end

if boon_edit_on('PremiumService') then
	boon_text({
		Traits = {
			WeaponUpgradeBoon = {
				Description = 'Your {$Keywords.Aspect} of the {#BoldFormatGraft}Nocturnal Arms {#Prev}is even stronger, '
					.. 'and your {!Icons.RandomHammer} upgrades gain rank {#ItalicFormat}(if possible){#Prev}. '
					.. 'Gain an {#BoldFormatGraft}Anvil of Fates {#Prev}now.',
			},
		},
	})
end

if boon_edit_on('ChainReaction') then
	boon_text({
		Traits = {
			DoubleMassiveAttackBoon = {
				Description = 'Any {$Keywords.GodBoon} effects that recharge over time have a chance to skip the recharge entirely.',
			},
		},
		StatLines = {
			BoonEditCooldownSkipStatDisplay = { Name = 'Recharge Skip Chance:', Index = 1 },
		},
		CombatText = {
			BoonEditChainReactionCombatText = '{#CombatTextHighlightFormat}Chain Reaction',
		},
	})
end

if boon_edit_on('SeismicHammer') then
	boon_text({
		Traits = {
			MassiveCastBoon = {
				DisplayName = 'Seismic Hammer',
				Description = 'Your blast effects from {#BoldFormatGraft}Hephaestus {#Prev}make your ' ..
					'{$Keywords.Cast} erupt like your {$Keywords.CastEX}.',
			},
		},
		StatLines = {
			BoonEditSeismicHammerStatDisplay = { Name = 'Blast Recharge Reduction:', Index = 1, Suffix = ' Sec.' },
		},
	})
end

if boon_edit_on('RousingReception') and mod.tuning.RousingReception.HitchOnly then
	boon_text({
		Traits = {
			SpawnCastDamageBoon = {
				Description = 'Your {$Keywords.CastSet} damage any foes as they join the ' ..
					'{$Keywords.EncounterAlt}, wherever they appear, and inflict {$Keywords.Link}.',
			},
		},
	})
end

if boon_edit_on('AllTogether') then
	boon_text({
		Traits = {
			AllElementalBoon = {
				Description = 'Gain {#BoldFormatGraft}2 {#Prev}of each {$Keywords.AllElements}, and {#BoldFormatGraft}1 {#Prev}{$Keywords.Synergy} {$Keywords.GodBoonNoTooltip} for each.',
			},
			AllElementStatDisplay = {
				Description = '{#UpgradeFormat}+2',
			},
		},
	})
end

if boon_edit_on('CherishedHeirloom') then
	boon_text({
		Traits = {
			KeepsakeLevelBoon = {
				Description = 'Your {$Keywords.Keepsakes} are upgraded this night. ' ..
					'Choose another now to keep for the rest of this night.',
			},
		},
	})

	if boon_edit_on('OlympianKeepsakes') then
		local olympianKeepsakes = {}
		for keepsakeName, god in pairs({
			ForceZeusBoonKeepsake = { 'Zeus', 'his' }, ForceHeraBoonKeepsake = { 'Hera', 'her' },
			ForceAresBoonKeepsake = { 'Ares', 'his' }, ForcePoseidonBoonKeepsake = { 'Poseidon', 'his' },
			ForceApolloBoonKeepsake = { 'Apollo', 'his' }, ForceDemeterBoonKeepsake = { 'Demeter', 'her' },
			ForceAphroditeBoonKeepsake = { 'Aphrodite', 'her' }, ForceHephaestusBoonKeepsake = { 'Hephaestus', 'his' },
			ForceHestiaBoonKeepsake = { 'Hestia', 'her' },
		}) do
			local name, pronoun = god[1], god[2]
			olympianKeepsakes[keepsakeName] = {
				Description = 'A {$Keywords.GodBoon} of {#BoldFormat}' .. name .. ' {#Prev}is likely. You can {$Keywords.RarityUpgrade} ' ..
					pronoun .. ' {#AltUpgradeFormat}{$TooltipData.ExtractData.RarityLevel} {#Prev}blessings once this night. ' ..
					'At {#BoldFormat}Heroic{#Prev}, turn any of ' .. pronoun .. ' blessings into ' .. pronoun .. ' Legendary instead.',
			}
		end
		boon_text({ Traits = olympianKeepsakes })
	end
end

if boon_edit_on('ConcaveStone') then
	boon_text({
		Traits = {
			UnpickedBoonKeepsake = {
				Description = 'After you collect your next {$Keywords.GodBoon} or Hammer, {#AltUpgradeFormat}{$TooltipData.ExtractData.Chance}% {#Prev}of the time it appears again.',
			},
		},
	})
end

if boon_edit_on('WhiteAntler') then
	boon_text({
		Traits = {
			LowHealthCritKeepsake = {
				Description = 'Gain {#AltUpgradeFormat}+{$TooltipData.ExtractData.Chance}% {#Prev}{$Keywords.Crit} damage chance while you wear this {$Keywords.KeepsakeAlt}, but you are limited to {#AltPenaltyFormat}{$TooltipData.ExtractData.Health}{!Icons.HealthDown}{#Prev}.',
			},
		},
	})
end

if boon_edit_on('MetallicDroplet') then
	boon_text({
		Traits = {
			TimedBuffKeepsake = {
				Description = 'You move, strike, and {$Keywords.HoldAlt} {#BoldFormatGraft}{$TooltipData.ExtractData.Speed}% {#Prev}faster for the next {#UpgradeFormat}{$TooltipData.ExtractData.Duration} Sec.{#Prev}, then keep {#AltUpgradeFormat}' ..
					math.floor(mod.tuning.MetallicDroplet.ResidualFraction * 100 + 0.5) ..
					'% {#Prev}of that boost while you hold this {$Keywords.KeepsakeAlt}.',
			},
		},
	})
end

if boon_edit_on('StutterStep') then
	boon_text({
		Traits = {
			SorcerySpeedBoon = {
				Description = 'You can {$Keywords.Dash} more frequently, and your {$Keywords.SprintBoonAlt} effects strike more often while you {$Keywords.Sprint}.',
			},
		},
	})
end

if boon_edit_on('MeanStreak') then
	boon_text({
		Traits = {
			TimedKillBuffBoon = {
				Description = 'Whenever you slay a foe, deal more damage for the next {#BoldFormatGraft}{$TooltipData.ExtractData.Duration} Sec.',
			},
		},
	})
end

if boon_edit_on('PostHaste') then
	boon_text({
		Traits = {
			SlowProjectileBoon = {
				DisplayName = 'Post Haste',
				Description = 'Any {$Keywords.GodBoon} effects that recharge over time recharge faster.',
			},
		},
	})
end

if boon_edit_on('SecondWind') then
	boon_text({
		Traits = {
			TimeStopLastStandBoon = {
				DisplayName = 'Second Wind',
				Description = 'Gain an extra {$Keywords.Cast} and {$Keywords.Dash}.',
			},
		},
		Flavor = {
			BoonEditSecondWindFlavorText = 'Why not a third? Or fourth?',
		},
	})
end

if boon_edit_on('BurningMeteor') then
	boon_text({
		Traits = {
			BurnSprintBoon = {
				DisplayName = 'Burning Meteor',
				Description = 'Your fireball effects from {#BoldFormatGraft}Hestia {#Prev}are larger, deal more damage, and inflict {$Keywords.Burn} equal to the damage they deal.',
			},
		},
		StatLines = {
			BoonEditMeteorDamageStatDisplay = { Name = 'Fireball Damage:', Index = 1 },
		},
	})
end

if boon_edit_on('CardioGain') then
	boon_text({
		Traits = {
			HestiaManaBoon = {
				Description = 'Whenever your {$Keywords.Attack} or {$Keywords.Special} deals damage, or you {$Keywords.Sprint}, restore {!Icons.Mana}.',
			},
		},
		StatLines = {
			BoonEditCardioGainSprintStatDisplay = { Name = 'Magick Restored on Sprint:', Index = 2 },
		},
	})
end

if boon_edit_on('VolcanicCrown') then
	boon_text({
		Traits = {
			AloneDamageBoon = {
				DisplayName = 'Volcanic Crown',
				Description = 'After your {$Keywords.CastEX} expires, it releases a ring of ' ..
					'{#BoldFormatGraft}{$TooltipData.ExtractData.TooltipFireballs} {#Prev}fireballs from its ' ..
					'center. Each bounces {#BoldFormatGraft}{$TooltipData.ExtractData.TooltipBounces} {#Prev}' ..
					'times, leaving burning ground wherever it lands.',
			},
		},
	})
end

if boon_edit_on('BreakerRush') then
	boon_text({
		Traits = {
			PoseidonSprintBoon = {
				Description = '{$Keywords.DashSet} launches a splash at each surrounding foe, and again once you stop.',
			},
		},
	})
end

if boon_edit_on('ArterialSpray') then
	boon_text({
		Traits = {
			DoubleSplashBoon = {
				Description = 'Your splash effects from {#BoldFormatGraft}Poseidon {#Prev}hit a second time with reduced power {#ItalicLightFormat}(and take the color of the River Styx){#Prev}.',
			},
		},
		StatLines = {
			BoonEditSecondSplashStatDisplay = { Name = 'Second Splash Damage:', Index = 1 },
		},
	})
end

if boon_edit_on('RippleEffect') then
	boon_text({
		Traits = {
			MoneyDamageBoon = {
				Description = 'The bonus effects your {$Keywords.Omega} trigger, {#BoldFormatGraft}Phalanx Shot {#Prev}and ' ..
					'{#BoldFormatGraft}Support Fire {#Prev}may occur again, up to ' ..
					'{#BoldFormatGraft}{$TooltipData.ExtractData.TooltipMaxRepeats} {#Prev}more times.',
			},
		},
		StatLines = {
			BoonEditRippleRepeatStatDisplay = { Name = 'Repeat Chance:', Index = 1 },
		},
	})
end

if boon_edit_on('ArcFlash') then
	boon_text({
		Traits = {
			EchoExpirationBoon = {
				Description = 'Your {$Keywords.Echo} effects are stronger, and damage from {$Keywords.Omega} ' ..
					'immediately activates them.',
			},
		},
		StatLines = {
			BoonEditArcFlashStatDisplay = { Name = 'Bonus {$Keywords.Echo} Damage:', Index = 1 },
		},
	})
end

if boon_edit_on('ShockingLoss') then
	boon_text({
		Traits = {
			SpawnKillBoon = {
				Description = 'Your lightning bolts may destroy susceptible foes outright, most likely the ' ..
					'first time each is struck. {$Keywords.BossPlural} instead take {#BoldFormatGraft}' ..
					'{$TooltipData.ExtractData.TooltipGuardianDamage} {#Prev}damage, at most once every ' ..
					'{#BoldFormatGraft}{$TooltipData.ExtractData.TooltipGuardianInterval} Sec.{#Prev}',
			},
		},
		StatLines = {
			BoonEditShockingLossStatDisplay = { Name = 'First-Hit Destruction Chance:', Index = 1 },
		},
	})
end

if boon_edit_on('KillerCurrent') then
	boon_text({
		Traits = {
			LightningVulnerabilityBoon = {
				Description = 'Damaging a {$Keywords.KnockbackAmplify}-afflicted foe may strike it with lightning.',
			},
		},
		StatLines = {
			BoonEditKillerCurrentStatDisplay = { Name = 'Strike Chance:', Index = 1 },
		},
	})
end

if boon_edit_on('PowerSurge') then
	boon_text({
		Traits = {
			ZeusManaBoltBoon = {
				Description = 'Whenever you use or restore {!Icons.Mana}, a random surrounding foe is struck by lightning.',
			},
		},
	})
end

if boon_edit_on('ThermalDynamics') then
	boon_text({
		Traits = {
			EchoBurnBoon = {
				Description = 'Your lightning effects from Zeus (except chain lightning) also inflict {$Keywords.Burn} ' ..
					'for a share of the damage they deal.',
			},
		},
		StatLines = {
			BoonEditThermalScorchStatDisplay = { Name = '{$Keywords.Burn} per Damage Dealt:', Index = 1 },
		},
	})
end

if boon_edit_on('GloriousDisaster') then
	boon_text({
		Traits = {
			ApolloSecondStageCastBoon = {
				Description = 'Your {$Keywords.CastEX} repeatedly strikes foes with lightning bolts.',
			},
		},
	})
end

if boon_edit_on('IonicGain') then
	boon_text({
		Traits = {
			ZeusManaBoon = {
				Description = 'In each {$Keywords.EncounterAlt}, an {$Keywords.ManaDropZeus} appears in the ' ..
					'area. Standing near it restores {!Icons.Mana}, and using it restores {#ItalicFormat}all ' ..
					'{#Prev}{!Icons.Mana}.',
			},
		},
	})
end

if boon_edit_on('HarmForTheAfflicted') then
	boon_text({
		Traits = {
			NewStatusDamage = {
				Description = 'Inflicting a {$Keywords.Status} deals {#BoldFormatGraft}{$TooltipData.ExtractData.Damage} {#Prev}damage.',
			},
		},
	})
end


if boon_edit_on('Preparation') then
	boon_text({
		Traits = {
			PreChargeTalent = {
				Description = 'Whenever you enter an {$Keywords.EncounterAlt}, your {$Keywords.Spell} starts {#UpgradeFormat}{$TooltipData.StatDisplay1} {#Prev}charged.',
			},
		},
	})
end


if boon_edit_on('ScaldingVapor') then
	boon_text({
		Traits = {
			SteamBoon = {
				Description = 'If foes with {$Keywords.KnockbackAmplify} are struck by your fireball effects ' ..
					'from {#BoldFormatGraft}Hestia{#Prev}, they are engulfed in {$Keywords.Steam}.',
			},
		},
		Keywords = {
			Steam = {
				Description = 'A burning cloud that rapidly deals damage. Lasts {#BoldFormatGraft}{$TooltipData.ExtractData.Duration} Sec.{#Prev}',
			},
		},
	})
end


if boon_edit_on('DualMoonshot') then
	boon_text({
		Traits = {
			StaffTripleShotTrait = {
				Description = 'Your {$Keywords.SpecialSet} fire {#UpgradeFormat}{$TooltipData.ExtractData.Projectiles} {#Prev}projectiles.',
			},
		},
	})
end

if boon_edit_on('ReaperKnives') then
	boon_text({
		Traits = {
			DaggerSpecialReturnTrait = {
				DisplayName = 'Hook Knives',
				Description = 'Your {$Keywords.SpecialSet} return to you and deal {#UpgradeFormat}' ..
					'{$TooltipData.ExtractData.DamageIncrease:P} {#Prev}damage striking foes from behind.',
			},
		},
	})
end

if boon_edit_on('EnduringCoil') then
	boon_text({
		Traits = {
			TorchSpecialImpactTrait = {
				Description = 'Your {$Keywords.SpecialSet} last {#UpgradeFormat}{$TooltipData.ExtractData.Duration}% {#Prev}longer.',
			},
		},
	})
end

if boon_edit_on('HiddenKnives') then
	boon_text({
		Traits = {
			DaggerSpecialFanTrait = {
				Description = 'Your {$Keywords.SpecialSet} deal {#UpgradeFormat}{$TooltipData.ExtractData.DamageIncrease:P} ' ..
					'{#Prev}damage and your {$Keywords.SpecialEX} fires {#UpgradeFormat}+{$TooltipData.ExtractData.Amount} ' ..
					'{#Prev}shots in a ring around you.',
			},
		},
	})
end
