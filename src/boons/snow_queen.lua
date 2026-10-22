---@meta _

once('SnowQueen', function()
	if not boon_edit_on('SnowQueen') then return end

	game.TraitData.ReserveManaHitShieldBoon.OnEncounterStartFunction = { Name = _PLUGIN.guid .. '.SnowQueenRefresh' }
end)

function mod.SnowQueenRefresh(hero, _args)
	if not boon_edit_on('SnowQueen') then return end
	if not hero or (game.CurrentRoom and game.CurrentRoom.BlockTraitSetup) then return end

	local trait = game.GetHeroTrait('ReserveManaHitShieldBoon')
	if not trait then return end

	game.ApplyEffect({
		DestinationId = hero.ObjectId,
		Id = hero.ObjectId,
		EffectName = 'ReserveManaInvulnerability',
		DataProperties = game.EffectData.ReserveManaInvulnerability.EffectData,
	})
	game.SetPlayerInvulnerable('ManaReserveTraitInvulnerability')
	trait.HasTriggered = nil
end
