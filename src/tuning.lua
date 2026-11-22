---@meta _


mod.tuning = {}

mod.tuning.AspectOfAnubis = {
	EtchingsFieldDuration = 0.5,
}

mod.tuning.AspectOfSupay = {
	SprintDamageBonus = 0.15,

	RarityMultipliers = {
		Common = 1,
		Rare = 2,
		Epic = 3,
		Heroic = 4,
		Legendary = 5,
		Perfect = 6.5,
	},
}

mod.tuning.ReaperKnives = {
	HitVulnerabilityMultiplier = 1.5,
	ReturnDelay = {
		ProjectileDaggerThrow = 0.276,
		ProjectileDaggerThrowCharged = 0.138,
	},

	Fuse = 1,
}

mod.tuning.EnduringCoil = {
	FuseMultiplier = 2,
}

mod.tuning.HiddenHelix = {
	ExtraProjectiles = 2,
}

mod.tuning.HiddenKnives = {
	RingDegrees = 360,
}

mod.tuning.RisingHelix = {
	MaxDamageBonus = 0.50,
}

mod.tuning.WhirlingHelix = {
	SpeedMultiplier = 2.0,
}

mod.tuning.CarnalPleasure = {
	ManaPerPlasma = 20,
	DamagePerPlasma = 1,
	SizePerPlasma = 0.01,
	PickupHeartthrobChance = 0,
}

mod.tuning.FestiveFog = {
	ShelterPerBonus = 1,
}

mod.tuning.GrapeJuice = {
	Heal = 20,
}

mod.tuning.PowerSurge = {
	RestoreCooldown = 0.35,
}

mod.tuning.HeartyAppetite = {
	HealingBonus = 1.5,

	Food = 'HealBigDrop',
	FoodOnPickup = 1,
	EncountersPerFood = 5,

	Spread = 190,
	Delay = 0.5,
}

mod.tuning.SmolderingForge = {
	HeartthrobChance = 0.25,
}

mod.tuning.CuttingEdge = {
	BladeSpacing = 0.3,
}

mod.tuning.EcstaticObsession = {
	CharmChance = 0.25,
	CharmDuration = 5,
	InterruptCooldown = 5,

	CharmedDamageMultiplier = 5,
	CharmedFriendlyFireMultiplier = 0,

	GuardianCharmDuration = 2.5,
	GuardianCharmCooldown = 5,
	FullCharmGuardians = { 'SirenDrummer', 'SirenKeytarist', 'CharybdisTentacle2' },
	MaxCharmed = 5,
	InterruptBossAttacks = false,
	SoftCharmUnits = { 'TyphonHead' },

	BossCharmFlashColor = 'AphroditeDamage',
	BossCharmFlashSpeed = 0.8,
	BossCharmFlashStrength = 0.6,

	DamagePerFriendly = 0.10,
	MaxDamageBonus = 0.50,

	Debug = false,

	AllyRange = 430,

	SpareBosses = false,
}

mod.tuning.MeatGrinder = {
	PlasmaChance = 0.30,
	PlasmaCooldown = 0.1,
	PlasmaCooldownPerFoe = true,
}

mod.tuning.ProfuseBleeding = {
	SpillChance = 0.10,
	FreshRendMultiplier = 1,
}

mod.tuning.BloodSpree = {
	KillHealChance = 0.20,
}

mod.tuning.SwordRing = {
	ContactWindow = 0.3,
}

mod.tuning.IonicGain = {
	ManaPerSecond = 6,

	Range = 675,
	Interval = 0.25,

	RarityScale = {
		Common = 1.00,
		Rare = 1.34,
		Epic = 1.67,
		Heroic = 2.00,
	},

	StrikeDamage = {
		Common = 15,
		Rare = 20,
		Epic = 25,
		Heroic = 30,
	},

	StrikeInterval = 1,

	RangeScaleY = 0.5,

	RingFx = 'SWuIonicGainRing',
	RingArtRadius = 391,
	RingHue = 0.1,
}

mod.tuning.BeachBall = {
	BlastDamage = 400,

	BlastRadius = 250,

	FireOnDash = true,
}

mod.tuning.GloriousDisaster = {
	BoltDamage = 20,
}

mod.tuning.HostileEnvironment = {
	CompatibleCasts = { 'CastProjectileBoon', 'CastAnywhereBoon', 'CastLobBoon' },
	InstantCasts = { WeaponCastProjectile = true, WeaponCastLob = true, WeaponCastProjectileHades = true },
}

mod.tuning.SeismicHammer = {
	RechargeReduction = 2,
	OmegaCastReducesCooldowns = true,

	ReducedCooldowns = {
		'MassiveAttack', 'MassiveSpecial', 'HephSprint', 'AthenaProjectile', 'AthenaInvulnerability', 'HadesRetaliate',
		'AutoRevengeCooldown', 'BoonEditDistressCall', 'BoonEditShockingLossGuardian', 'SWuLandMine', 'SWuSolarEclipse',
	},
}

mod.tuning.SunWorshiper = {
	RepeatChance = 0.30,

	MaxRepeats = 10,

	WardSummons = true,

	HitchSummons = true,
	SummonHitchDuration = 9999,

	AllyKillsCount = true,

	BossReach = true,
	BossTargetReach = 9999,
	BossProjectile = {
		ImpactLineOfSight = false,
		CheckObstacleImpact = false,
		MaxVictimZ = 9999,
	},

	Debug = false,
}

mod.tuning.TranquilGain = {
	HoldSeconds = 0.5,
}

mod.tuning.WinterHarvest = {
	ExecuteThreshold = 0.15,
}

mod.tuning.PhalanxShot = {
	Cooldown = 1,
}

mod.tuning.NaturalSelection = {
	PomsOnPickup = 3,

	LevelsPerPom = 3,
	EncountersPerPom = 8,
}

mod.tuning.NuptialVow = {
	DamagePerHitched = 0.10,

	Interval = 0.3,
}

mod.tuning.SteadyGrowth = {
	RarityOnPickup = 1,
	PickupDelay = 0.5,
}

mod.tuning.UnseenIre = {
	Cooldown = 40,
	DamageMultiplier = 2.0,
}

mod.tuning.SmithyRush = {
	TrailInterval = 0.5,

	ChainDelay = 0.15,

	ImpactFx = 'SWuSmithyRushCircle',
	ImpactRadius = 260,
}

mod.tuning.ToughGain = {
	PomDamageReduction = 1,

	MaxDamageReduction = 10,

	HeinousAffront = true,
}

mod.tuning.CryoPounder = {
	FrozenGlowMultiplier = 1.5,
}

mod.tuning.MoltenTouch = {
	GlowBonus = { Common = 0.15, Rare = 0.20, Epic = 0.25, Heroic = 0.30 },
}

mod.tuning.AnvilOfFates = {
	SacrificeChoices = 3,
	Discoveries = 2,
}

mod.tuning.DazzlingDisplay = {
	Chance = 1.0,

	PotencyBonus = 0.03,
	PomPotencyBonus = { 0.03, 0.02, 0.01 },

	PotencyRarityMultipliers = {
		Common = 1,
		Rare = 2,
		Epic = 3,
		Heroic = 4,
	},
}

mod.tuning.ChainReaction = {
	SkipChance = 0.25,

	ExtraCooldowns = {
		'SWuLandMine', 'SWuSolarEclipse', 'BoonEditDistressCall', 'AthenaProjectile', 'AthenaInvulnerability',
	},

	HephaestusOnly = true,
	HephaestusCooldowns = { 'MassiveAttack', 'MassiveSpecial', 'HephSprint', 'SWuLandMine' },

	RepeatingTimers = false,
	EarlyFireDelay = 0.25,

	TextDuration = 1.45,
	TextCooldown = 0.5,
}

mod.tuning.BraveFace = {
	DamageBlocked = 0.50,
	ManaPerDamage = 5,
}

mod.tuning.RousingReception = {
	HitchOnly = true,
	UseCastStrikes = true,
	DamageScaledCurseMultiplier = 1.0,
}

mod.tuning.CherishedHeirloom = {
	ExtraKeepsake = true,
	ExtraKeepsakeInMenuOnly = true,
	KeepAllKeepsakes = false,
	RefreshHeldKeepsake = false,
	CarryUses = true,
}

mod.tuning.DistressCall = {
	Icon = 'Boon_Hermes_27',
	Element = 'Water',

	Duration = 8,
	Cooldown = 40,

	OnEncounterStart = true,
	EncounterStartDelay = 0.5,
	EncounterFoeWait = 15,
	SwingLimit = 2.5,

	NominalHealth = 1,

	AllowInBoss = true,
	FocusBoss = true,

	TargetReach = 9999,

	BossProjectile = {
		ImpactLineOfSight = false,
		CheckObstacleImpact = false,
		MaxVictimZ = 9999,
	},

	Allies = {
		{
			Key = 'Heracles',
			Unit = 'NPC_Heracles_01',
			BlockedBy = 'Heracles',
			WakeDelay = 0,
			Haste = 1.25,
			Packages = { 'Heracles' },
			Voice = { Bank = 'Heracles' },
			Greet = true,
			Entrance = {
				Animation = 'Heracles_Combat_Taunt',
				Height = 2500,
				Delay = 0.3,
				Force = 3500,
				Land = 0.5,
				Sound = '/SFX/Enemy Sounds/Heracles/EmotePowerCharging',
				LandFx = 'HydraTouchdownFx',
				LandSounds = {
					'/SFX/Enemy Sounds/Heracles/EmotePowerAttacking',
					'/SFX/Enemy Sounds/Polyphemus/PolyphemusGroundSlam',
				},
				LandShake = true,
			},
			Exit = {
				Animation = 'Heracles_Combat_LeapExit',
				Voice = true,
				Wind = 0.62,
				Rise = 2000,
				RiseTime = 0.2,
				Fade = 0.1,
				Shake = true,
			},
		},
		{
			Key = 'Nemesis',
			Unit = 'NPC_Nemesis_01',
			Variant = 'NemesisCombat',
			WakeDelay = 0,
			Packages = { 'Nemesis' },
			Voice = { Bank = 'Nemesis' },
			Greet = true,
			Entrance = {
				Animation = 'Nemesis_Combat_Entrance',
				Height = 1500,
				Delay = 0.3,
				Force = 2000,
				Land = 0.6,
				Sound = '/SFX/Player Sounds/MelWhooshDropIn',
				Shake = true,
			},
			Exit = {
				Animation = 'Nemesis_Hub_Exit',
				Voice = true,
				Wind = 0.92,
				Rise = 1000,
				RiseTime = 0.2,
				Fade = 0.1,
			},
		},
		{
			Key = 'Icarus',
			Unit = 'NPC_Icarus_01',
			Variant = 'IcarusCombat',
			Packages = { 'Icarus', 'NPC_Icarus_01' },
			Voice = { Bank = 'Icarus' },
			Greet = true,
			Invisible = true,
			WakeDelay = 0,
			SpawnAt = { 'CameraClamp' },

			Weapons = {
				IcarusBombardmentLine = {
					TargetSpawnPoints = false,
					TargetRequiredKillEnemy = true,
					TargetClosestToPlayer = true,

					PostAttackCooldownMin = 1.5,
					PostAttackCooldownMax = 1.5,
					Requirements = { MinAttacksBetweenUse = 0 },
				},
				IcarusBombardmentSingle = {
					TargetClosestToPlayer = true,

					PostAttackCooldownMin = 0.8,
					PostAttackCooldownMax = 1.2,
				},
			},

			Exit = {
				Cycles = 3,
				Grace = 1.0,
				Settle = 0.5,
				Animation = 'Icarus_FlyExit_TakeOff',
				Voice = true,
				Wind = 0.36,
				Rise = 800,
				RiseTime = 0.22,
				Fade = 0.11,
			},
		},
		{
			Key = 'Hades',
			Unit = 'NPC_Hades_Field_01',
			Packages = { 'NPC_Hades_Field_01', 'Hades' },
			Voice = { Bank = 'Hades' },
			BossOnly = true,
			Weight = 0.5,

			Grudge = {
				Fraction = 0.20,
				Delay = 1.0,

				Effect = 'HadesInvisible',
				Multiplier = 1.5,

				DamageSourceName = 'HadesPreDamageBoon',
				Presentation = 'HadesPreDamagePresentation',
				Text = 'PreDamageHit_Hades',
				VoiceLines = 'HadesCurseVoiceLines',
			},
		},
		{
			Key = 'Dionysus',
			Unit = 'NPC_Dionysus_01',
			Packages = { 'NPC_Dionysus_01', 'Dionysus' },
			Voice = { Bank = 'Dionysus' },

			Revel = {
				Ball = '3DDiscoBall_SkipEncounter',
				Chain = 'OlympusCeilingChain01',
				Reflections = 'DiscoBallReflections_SkipEncounter',
				ChainScale = 0.51,
				ChainOffset = -97,
				Height = 1200,
				Drop = -650,
				DropAlt = -525,

				Sound = '/SFX/DionysusBoonWineLaugh',
				Music = '/Music/MusicPlayer/Iris/DionysusMusicMusicPlayer',
				EndSound = '/SFX/Menu Sounds/RecordScratch',

				Fog = 'DionysusField',
				Clouds = 18,
				MinGap = 750,
				Spread = 2800,
				SpreadY = 0.6,
				Refresh = 4.0,
				Drift = 137.5,

				Hangover = 'DamageOverTime',
				Damage = 50,
				Radius = 400,
				Sweep = 0.5,

				Drink = 'PowerDrinkDrop',
				Drinks = 2,
				DrinkMin = 700,
				DrinkVfx = 'BoonDropFrontFlare',
				DrinkSound = '/SFX/Menu Sounds/KeepsakeEurydiceAcorn',
			},
		},
		{
			Key = 'Athena',
			Unit = 'NPC_Athena_01',
			Packages = { 'NPC_Athena_01', 'Athena' },
			Voice = { Bank = 'Athena' },
			NoBoss = true,
			Weight = 0.5,

			Smite = {
				Nova = 'AthenaLandingNova',
				Sound = '/SFX/AthenaWrathHolyShield',
				Damage = 9999,

				Descend = 1.2,
				Interval = 0.01,
				Linger = 0.7,

				Entrance = 'Athena_Leap_Entrance',
				Departure = 'Athena_Leap_Exit',
				Height = 2000,
			},
		},
		{
			Key = 'Artemis',
			Unit = 'NPC_Artemis_Field_01',
			Packages = { 'Artemis', 'NPC_Artemis_Field_01' },
			Voice = { Bank = 'Artemis', From = 'NPC_Artemis_01' },
			Greet = true,
			Invisible = 'Artemis_Invisible',
			WakeDelay = 0,
			SpawnAt = { 'ArtemisSpawnPoints', 'HeroStart', 'CameraClamp' },
			SpawnAtEntrance = 'ArtemisUseHeroStart',

			Weapons = {
				ArtemisSniper = {
					PreAttackDuration = 0.6,
					FireDuration = 0.15,
					PostAttackDurationMin = 0.7,
					PostAttackDurationMax = 0.85,
				},
				ArtemisHuntersMark = {
					PreAttackDuration = 0.3,
					PostAttackDurationMin = 0.7,
					PostAttackDurationMax = 0.9,
				},
			},

			Exit = {
				Cycles = 4,
				Grace = 1.0,
				Settle = 0.5,
				Voice = true,
				Wind = 0.4,
				Fade = 0.1,
			},
		},
		{
			Key = 'Thanatos',
			Unit = 'NPC_Thanatos_Field_01',
			Requires = 'NikkelM-Zagreus_Journey',
			Packages = { 'Thanatos', 'ModsNikkelMHadesBiomesFxOriginal', 'NikkelM-HadesBiomesFxModded' },
			Voice = { Bank = { 'Thanatos', 'ThanatosField' } },
			NoBoss = true,
			WakeDelay = 0,
			Greet = true,
			GreetLines = 'EntranceVoiceLines',
			TargetReach = 1000,
			Weapons = {
				ThanatosDeathCurseAoE = {
					ForceFirst = true,
					MinAttacksBetweenUse = 0,
					Requirements = { MinAttacksBetweenUse = 0 },
				},
			},
			Entrance = {
				Fx = 'ThanatosTeleport',
				Delay = 0.2,
				FadeIn = 0.3,
				Sound = '/SFX/ThanatosEntranceSound',
				Land = 0.5,
			},
			Exit = {
				Animation = 'NPCThanatosExit',
				Fx = 'ThanatosTeleport',
				Wind = 0.1,
				Fade = 0.35,
			},
		},
		{
			Key = 'Megaera',
			Unit = 'Harpy',
			Requires = 'NikkelM-Zagreus_Journey',
			Traitor = true,
			DamageMultiplier = 30,
			Packages = { 'TartarusModsNikkelMHadesBiomes', 'ModsNikkelMHadesBiomesFxOriginal', 'NikkelM-HadesBiomesFxModded' },
			Voice = { Bank = 'MegaeraField' },
			BlockedIn = { 'BossHarpy1' },
			WakeDelay = 0,
			Greet = true,
			Clear = {
				'IsBoss', 'UseBossHealthBar', 'AIStages', 'AdditionalEnemySetupFunctionName',
				'OnDeathFunctionName', 'OnDeathFunctionArgs', 'KillEnemyEvents', 'FightStartGlobalVoiceLines',
				'BossPresentationUltraSuperPriorityIntroTextLineSets', 'BossPresentationIntroTextLineSets',
				'BossPresentationTextLineSets', 'ShrineMetaUpgradeName', 'ShrineDataOverwrites', 'DreamBiomeData',
				'SpawnOptions', 'SupportAIWeaponSetOptions', 'SupportUnitName',
			},
			Data = {
				AIOptions = { 'AttackerAI' },
				WeaponOptions = { 'HarpyLunge', 'HarpyWhipWhirl', 'HarpyLightning' },
				HideHealthBar = true,
				EncounterStartVoiceLines = {
					RandomRemaining = true,
					PreLineWait = 0.6,
					{ Cue = '/VO/MegaeraField_0401' },
					{ Cue = '/VO/MegaeraField_0085' },
					{ Cue = '/VO/MegaeraField_0086' },
					{ Cue = '/VO/MegaeraField_0114' },
					{ Cue = '/VO/MegaeraField_0116' },
				},
				ExitVoiceLines = {
					RandomRemaining = true,
					{ Cue = '/VO/MegaeraField_0662' },
					{ Cue = '/VO/MegaeraField_0133' },
					{ Cue = '/VO/MegaeraField_0296' },
				},
			},
			Entrance = {
				Animation = 'MegaeraMultiFurySkyDive',
				Height = 1500,
				Delay = 0.3,
				Force = 2500,
				Land = 0.5,
				LandShake = true,
			},
			Exit = {
				Animation = 'MegaeraMultiFuryTakeOff',
				Voice = true,
				Wind = 0.4,
				Rise = 1500,
				RiseTime = 0.2,
				Fade = 0.1,
			},
		},
		{
			Key = 'Bouldy',
			Unit = 'NPC_Bouldy_01',
			Requires = 'NikkelM-Zagreus_Journey',
			Packages = { 'Bouldy', 'BiomeI' },
			Voice = { Bank = 'Sisyphus' },
			Weight = 0.5,

			Callout = {
				Speaker = 'NPC_Sisyphus_01',
				SubtitleColor = { 109, 185, 116, 255 },
				Sets = {
					{
						Rooms = { 'A_Boss01', 'A_Boss02', 'A_Boss03' },
						Cues = { 'Sisyphus_0290', 'Sisyphus_0291', 'Sisyphus_0292', 'Sisyphus_0293', 'Sisyphus_0294', 'Sisyphus_0295' },
					},
					{
						Units = { 'Hecate', 'Eris' },
						Cues = { 'Sisyphus_0290', 'Sisyphus_0291', 'Sisyphus_0293', 'Sisyphus_0294', 'Sisyphus_0295' },
					},
					{
						Units = { 'NPC_Thanatos_Field_01' },
						Cues = { 'Sisyphus_0296', 'Sisyphus_0297', 'Sisyphus_0298', 'Sisyphus_0299', 'Sisyphus_0300' },
					},
					{
						Rooms = { 'D_Boss01' },
						Cues = { 'Sisyphus_0302', 'Sisyphus_0303', 'Sisyphus_0304', 'Sisyphus_0305', 'Sisyphus_0306', 'Sisyphus_0307' },
					},
					{
						Rooms = { 'CharonFight01' },
						Cues = { 'Sisyphus_0447', 'Sisyphus_0448', 'Sisyphus_0449', 'Sisyphus_0450', 'Sisyphus_0451', 'Sisyphus_0452' },
					},
					{
						Cues = {
							'Sisyphus_0268', 'Sisyphus_0269', 'Sisyphus_0272', 'Sisyphus_0273', 'Sisyphus_0274',
							'Sisyphus_0275', 'Sisyphus_0276', 'Sisyphus_0277', 'Sisyphus_0279', 'Sisyphus_0280',
							'Sisyphus_0282', 'Sisyphus_0283', 'Sisyphus_0284', 'Sisyphus_0285', 'Sisyphus_0310',
							'Sisyphus_0313', 'Sisyphus_0314', 'Sisyphus_0315',
						},
					},
				},
			},

			Drop = {
				Damage = 4000,
				Radius = 700,
				Reach = 900,

				Scale = 0.5,
				Height = 1000,
				Fall = 0.45,
				FallSound = '/Leftovers/SFX/MeteorStrikeQuiet',
				LandFx = 'UnitUnfrozen',
				LandSound = '/SFX/Explosion1',

				Delay = 2.5,

				LootDelay = 0,
				LootRange = 150,
				LootForceMin = 200,
				LootForceMax = 350,
				LootScale = 0.6,
				Loot = {
					{ Name = 'RoomMoneyTinyDrop', Count = 5, Overrides = { DropMoney = 10 } },
					{ Name = 'MetaCurrencyDrop', Count = 5, Overrides = { AddResources = { MetaCurrency = 20 } } },
					{ Name = 'HealDropMinor', Count = 5, Overrides = { HealFixed = 10 } },
				},

				Linger = 0,
				Fade = 0.15,
			},
		},
	},
}

mod.tuning.FlawlessExecution = {
	Icon = 'Boon_Hermes_29',
	Element = 'Air',
	StepInterval = 0.6,
	PercentPerStep = 0.01,
	MaxPercent = 1.00,
	DefensePerStep = 0.01,
	MaxDefense = 1.00,
	IncludeTraps = true,
	ExpireSound = '/SFX/WrathOver',
	ResetGrace = 5,
}

mod.tuning.HermesLegendaries = {
	Keepsake = 'TimedBuffKeepsake',
	KeepsakeOfferChance = 0.10,
	GuaranteeElementCount = 8,
}

mod.tuning.PaidDues = {
	Element = 'Fire',
	GoldPerDamage = 1,
}

mod.tuning.PostHaste = {
	Element = 'Water',
}

mod.tuning.DoubleTime = {
	Icon = 'Boon_Hermes_30',
	Element = 'Earth',
	ExtraCasts = 1,
	ExtraDashes = 1,
	DashRechargeMultiplier = 0.90,
	DashCooldownMultiplier = 0.40,

	InFlightCasts = {
		WeaponCastLob = 'ProjectileCastLob',
		WeaponCastProjectile = 'ProjectileCastFireball',
		WeaponCastProjectileHades = 'ProjectileCastHades',
	},
}

mod.tuning.BurningMeteor = {
	FireballMultiplier = 1.5,
	SizeMultiplier = 1.5,
}

mod.tuning.CardioGain = {
	SprintManaGain = 1.0,
}

mod.tuning.VolcanicCrown = {
	FireballDamage = { Common = 100, Rare = 125, Epic = 150, Heroic = 175 },
	PomDamage = { 25, 20, 15 },

	Fireballs = 5,
	Bounces = 2,

	FireDamage = 6,
	FireDuration = 5,

	FireballProjectile = 'SWuVolcanicCrownFireball',
	FireProjectile = 'SWuVolcanicCrownFire',
}

mod.tuning.Fireballs = {
	Projectiles = {
		'ProjectileCastFireball', 'ProjectileFireball', 'SWuHestiaFireball',
		mod.tuning.VolcanicCrown.FireballProjectile, 'SWuVolcanicFireball',
		'ProjectileSprintFireball',
	},

	Traits = { 'FireballRendBoon', 'SteamBoon' },
}

mod.tuning.EasyShot = {
	DamageMultiplier = 2.0,
	CritChance = 0.20,
}

mod.tuning.PoseidonSplash = {
	RedNova = 'SWuPoseidonRedNova',

	WaveDelay = 0.1,

	CircleProjectile = 'PoseidonCastSplashSplinter',
}

mod.tuning.GeyserSpout = {
	ImpulseProjectile = 'PoseidonCastImpulse',
	Knockback = 1100,
}

mod.tuning.BreakerRush = {
	WaveDamage = { Common = 20, Rare = 25, Epic = 30, Heroic = 35 },

	PomDamage = { First = 20, Rest = 10 },

	TrailInterval = 0.5,

	Knockback = 900,

	WaveProjectile = 'PoseidonSplashSplinter',

	ChainDelay = 0.15,

	ImpactFx = 'SWuBreakerRushCircle',
	ImpactRadius = 260,
	RingScale = 1.0,
	ImpactPulses = 2,
	ImpactPulseDelay = 0.12,
}

mod.tuning.BurningDesire = {
	ScorchCap = 9999,
}

mod.tuning.ScaldingVapor = {
	MaxClouds = 5,
}

mod.tuning.MeanStreak = {
	PauseInMenus = true,
	Tick = 0.1,
}

mod.tuning.MidnightOil = {
	Icon = 'Boon_Hermes_38',
	Element = 'Water',
	Saving = 0.20,
	MaxSaving = 0.9,
	Rarities = { Common = 1, Rare = 1.5, Epic = 2, Heroic = 2.5 },
	Hexes = {
		'SpellTimeSlowTrait', 'SpellPolymorphTrait', 'SpellLaserTrait', 'SpellLeapTrait', 'SpellPotionTrait',
		'SpellSummonTrait', 'SpellMeteorTrait', 'SpellTransformTrait', 'SpellMoonBeamTrait',
	},
}

mod.tuning.NitroBoost = {
	Element = 'Air',
}

mod.tuning.QuickBuck = {
	Element = 'Fire',
}

mod.tuning.StutterStep = {
	RushInterval = 0.8,
}

mod.tuning.PassionRush = {
	TrailInterval = 0.2,

	ChainDelay = 0.15,
}

mod.tuning.ArterialSpray = {
	SecondWavePower = 0.30,
}

mod.tuning.StabbingRush = {
	ProjectileCap = 30,
}

mod.tuning.RippleEffect = {
	RepeatChance = 0.50,

	Falloff = 0.5,
	MaxRepeats = 4,
}

mod.tuning.ShockingLoss = {
	HitChance = 0.025,
	FirstHitMultiplier = 10,

	RollInterval = 0.01,

	Lightning = {
		'ZeusEchoStrike',
		'ZeusCastStrike',
		'ZeusRootStrike',
		'ZeusSprintStrike',
		'ZeusZeroManaStrike',
		'ZeusRetaliateStrike',
		'ZeusCastAnywhereBlast',
		'ZeusApolloSynergyStrike',
		'ZeusPolymorphStrike',
		'ZeusManaBolt',
		'ProjectileZeusSpark',
		'ZeusWrathBolt',
		'SWuAirControlBolt',
		'SWuBlindingSmiteBolt',
		'SWuTippedScalesBolt',
	},

	GuardianDamage = 9999,
	GuardianInterval = 40,
}

mod.tuning.KillerCurrent = {
	BoltChance = 0.30,
	BoltPower = 30,

	BoltCooldown = 0.5,
}

mod.tuning.ThunderRush = {
	FireRate = 1.5,
}

mod.tuning.ThermalDynamics = {
	ScorchFraction = 0.30,

	Lightning = {
		'ZeusEchoStrike',
		'ZeusCastStrike',
		'ZeusRootStrike',
		'ZeusSprintStrike',
		'ZeusZeroManaStrike',
		'ZeusRetaliateStrike',
		'ZeusCastAnywhereBlast',
		'ZeusApolloSynergyStrike',
		'ZeusPolymorphStrike',
		'ZeusManaBolt',
		'ProjectileZeusSpark',
		'ZeusWrathBolt',
		'SWuAirControlBolt',
		'SWuBlindingSmiteBolt',
		'SWuTippedScalesBolt',
	},
}

mod.tuning.EnfeeblementOfCowards = {
	ProjectileSpeed = 0.40,
}

mod.tuning.HarmForTheAfflicted = {
	Interval = 0.3,
}

mod.tuning.ConcaveStone = {
	Rewards = { 'WeaponUpgrade' },
}

mod.tuning.CallingCard = {}

mod.tuning.EvilEye = {
	MatchWholeType = false,
}

mod.tuning.ScytheSlows = {
	Projectiles = {
		'ChronosScytheThrow',
		'ChronosScytheThrowReverse',
		'ChronosScytheThrowLarge',
		'ChronosScytheThrowClose',
		'ChronosScytheThrowMid',
		'ChronosScytheThrowFar',
	},

	Interval = 0.03,
	Debug = true,
}

mod.tuning.WhiteAntler = {
	HeirloomOnly = true,
	MaxHealth = 30,
}

mod.tuning.AromaticPhial = {
	Blessings = 1,
	HeroicBlessings = 2,
}

mod.tuning.MetallicDroplet = {
	ResidualFraction = 0.5,
}

mod.tuning.MoreDashBoons = {
	MaxHeld = 1,
	FamilyTradeMaxHeld = 2,

	Fireballs = { 'BlinkTrailProjectileHestia', 'BlinkTrailProjectileFireHestia' },

	FlutterProjectile = 'BlinkTrailProjectileAphrodite',
	FlutterCharmChance = 0.15,

	CrystalProjectile = 'BlinkTrailDemeterProjectileTracking',
	CrystalEffect = 'ChillEffect',

	SwornProjectile = 'BlinkTrailProjectileHeraOmega',
	SwornRift = 'ProjectileHeraOmega',
	SwornPower = 0.5,
	SwornStartDelay = 0.5,
	SwornFirstDelay = 0.75,
	SwornInterval = 0.5,
	SwornMinMove = 45,
	SwornMaxRifts = 5,
	SwornAnchorLife = 3,

	WaveProjectile = 'PoseidonBlinkWave',
	WaveInterval = 0.25,
	WaveGrace = 0.3,
	WaveCap = 2,

	BlindingEffect = 'ArtemisBoonHuntersMark',

	VolcanicMine = 'HephMineBlast',
	VolcanicBlast = 'HephSprintBlast',
	VolcanicStun = { EffectName = 'OnHitStun', Duration = 0.2 },
}
