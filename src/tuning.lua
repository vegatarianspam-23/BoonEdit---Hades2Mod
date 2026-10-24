---@meta _


mod.tuning = {}

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
	ReturnDelay = 0.138,

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
	PickupHeartthrobChance = 0,
}

mod.tuning.FestiveFog = {
	Shelter = 0.60,
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

mod.tuning.EcstaticObsession = {
	CharmChance = 0.30,
	CharmDuration = 5,
	InterruptCooldown = 5,

	CharmedDamageMultiplier = 10,
	CharmedFriendlyFireMultiplier = 0,

	GuardianCharmCooldown = 5,
	DamagePerFriendly = 0.10,
	MaxDamageBonus = 0.50,

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
	ManaPerSecond = 12,

	Range = 450,
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

	StrikeRange = 700,
	StrikeInterval = 1,
}

mod.tuning.BeachBall = {
	BlastDamage = 400,

	BlastRadius = 250,

	WaveProjectile = 'PoseidonCastSplashSplinter',
}

mod.tuning.GloriousDisaster = {
	BoltDamage = 50,
}

mod.tuning.SeismicHammer = {
	BlastCooldownReduction = 1,

	MinimumBlastCooldown = 0.1,
}

mod.tuning.SunWorshiper = {
	RepeatChance = 0.30,

	MaxRepeats = 10,

	WardSummons = true,
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

mod.tuning.UnseenIre = {
	Cooldown = 40,
}

mod.tuning.Glow = {
	GlowPerStack = 0.05,
	GlowMax = 1.35,
}

mod.tuning.SmithyRush = {
	TrailInterval = 0.5,

	ChainDelay = 0.15,

	ImpactFx = 'SWuSmithyRushCircle',
	ImpactRadius = 260,
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

	PotencyRarityMultipliers = {
		Common = 1,
		Rare = 2,
		Epic = 3,
		Heroic = 4,
	},
}

mod.tuning.ChainReaction = {
	SkipChance = 0.25,

	ExtraCooldowns = { 'SWuLandMine', 'SWuSolarEclipse', 'SWuWinterSolstice', 'SWuDistressCall', 'BoonEditShockingLossGuardian' },

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

mod.tuning.SecondWind = {
	KeepsakeOfferChance = 0.10,
	ExtraCasts = 1,
	ExtraDashes = 1,
	DashRechargeMultiplier = 0.90,
	DashCooldownMultiplier = 0.40,
}

mod.tuning.BurningMeteor = {
	FireballMultiplier = 1.5,
	SizeMultiplier = 2.0,
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
	},

	GuardianDamage = 9999,
	GuardianInterval = 10,
}

mod.tuning.KillerCurrent = {
	BoltChance = 0.30,
	BoltPower = 30,

	BoltCooldown = 0.5,
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
	},
}

mod.tuning.HarmForTheAfflicted = {
	Interval = 0.3,
}

mod.tuning.ConcaveStone = {
	Rewards = { 'WeaponUpgrade' },
}

mod.tuning.CallingCard = {}

mod.tuning.WhiteAntler = {
	HeirloomOnly = true,
}

mod.tuning.AromaticPhial = {
	Blessings = 1,
	HeroicBlessings = 2,
}

mod.tuning.MetallicDroplet = {
	ResidualFraction = 0.5,
}
