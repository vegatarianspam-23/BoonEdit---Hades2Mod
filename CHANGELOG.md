# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.8] - 2026-10-28

### Changed

- Happy Haze: damage taken in the fog is reduced by the same amount as its damage bonus (was a flat 40%), shown together on one stat line
- Thunder Rush: strikes 50% more often (every 0.23 seconds, was 0.35), and Stutter Step makes it strike more often still
- Ripple Effect: Beach Ball can now repeat too.

### Fixed

- Sprint speed now also rises with move-speed bonuses that only raised run speed (Ignited Ichor, Word of Smaller Stature, Toula), and Plasma now raises Sprint speed by the same proportion as run speed, so running can't outpace Sprinting
- Pop-up text over Melinoe and foes (like Perfect Image or Untouchable Glow being lost) now stacks upward instead of overlapping when several show at once

## [1.0.7] - 2026-10-27

### Changed

- Ecstatic Obsession: Charm chance lowered to 25% (was 30%), and duration on bosses is halved to 2.5 seconds. Charming Typhon no longer interrupts his current attack, and cap of 5 charmed foes at a time.
- Mean Streak: the timer now pauses while a menu or the pause screen is open, following Vow of Time's logic
- Steady Growth: also upgrades a random boon's rarity on pickup
- Enfeeblement of Cowards: foes' ranged shots are slowed by 60% (was 40%)
- Evil Eye (experimental): the damage bonus now applies to the last foe that struck you
- White Antler (experimental): max health limit set to 30

### Fixed

- Cutting Edge: the extra blade from Cut Above now deals its damage, instead of usually landing inside the first blade's hit immunity
- Chronos' spinning scythe throws are now slowed by ranged-shot slows, which the game skipped for them: Enfeeblement of Cowards, Demeter's Sprint and Cast gusts, and More Duos' Air Control rings

## [1.0.6] - 2026-10-26

### Changed

- Ionic Gain: the Aether Font's area is 50% larger (marked by a yellow ring), and its lightning now strikes only foes inside that same area

## [1.0.5] - 2026-10-24

### Fixed

- Scalding Vapor: now triggers on anything your Steam boon counts as a fireball, so More Duos' Hot Iron weapon strikes can apply it

## [1.0.4] - 2026-10-23

### Changed

- Thermal Dynamics: inflicts Scorch equal to 30% of damage from all lightning from Zeus except chain lightning (was 100% of Blitz only); any core Zeus boon satisfies its requirement

## [1.0.3] - 2026-10-23

### Changed

- Chain Reaction: recharge skip chance lowered to 25% (was 30%)
- Ripple Effect: Phalanx Shot and Support Fire projectiles can now repeat

## [1.0.2]

- text changes

## [1.0.1] - 2026-10-23

### Changed

- Sun Worshiper: extra summons now capped at 10 per location instead of per encounter
- Olympian keepsakes: new Heroic rarity moved to Experimental, off by default (`Experimental.Keepsakes.OlympianKeepsakes` in config)

## [1.0.0] - 2026-10-22

### Added

- Initial release.

[1.0.8]: https://github.com/vegatarianspam-23/BoonEdit---Hades2Mod/compare/1.0.7...1.0.8
[1.0.7]: https://github.com/vegatarianspam-23/BoonEdit---Hades2Mod/compare/1.0.6...1.0.7
[1.0.6]: https://github.com/vegatarianspam-23/BoonEdit---Hades2Mod/compare/1.0.5...1.0.6
[1.0.5]: https://github.com/vegatarianspam-23/BoonEdit---Hades2Mod/compare/1.0.4...1.0.5
[1.0.4]: https://github.com/vegatarianspam-23/BoonEdit---Hades2Mod/compare/1.0.3...1.0.4
[1.0.3]: https://github.com/vegatarianspam-23/BoonEdit---Hades2Mod/compare/1.0.1...1.0.3
[1.0.1]: https://github.com/vegatarianspam-23/BoonEdit---Hades2Mod/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/vegatarianspam-23/BoonEdit---Hades2Mod/compare/63a0cb096ca3526e4447959dde16a870a14e4507...1.0.0