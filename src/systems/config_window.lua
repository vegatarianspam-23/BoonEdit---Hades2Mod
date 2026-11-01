---@meta _
---@diagnostic disable: lowercase-global


local CONFIG_SMALL_WORDS = { Of = 'of', For = 'for', The = 'the', And = 'and', To = 'to' }

local CONFIG_LABELS = {
	FestiveFog = 'Happy Haze',
	PostHaste = 'Post Haste (replaces Hard Target)',
	VolcanicCrown = 'Volcanic Crown (replaces Snuffed Candle)',
	EcstaticObsession = 'Ecstatic Obsession & Nervous Wreck swap',
	SeismicHammer = 'Seismic Hammer (replaces Seismic Servo)',
	SmolderingForge = 'Smoldering Forge (replaces Love Handles)',
	BurningMeteor = 'Burning Meteor (replaces Fire Away)',
	SecondWind = 'Second Wind (replaces Paid Dues)',
	OfferRequirements = 'Offer requirement changes',
	ScytheSlows = "Chronos' scythe throws can be slowed",
	SprintFollowsMoveSpeed = 'Sprint speed follows move speed',
	WrathOfOlympus = 'Wrath of Olympus support',
}

local CONFIG_DUO_GODS = {
	ArterialSpray = { 'Ares', 'Poseidon' },
	BeachBall = { 'Apollo', 'Poseidon' },
	BraveFace = { 'Hephaestus', 'Hera' },
	BurningDesire = { 'Aphrodite', 'Hestia' },
	CarnalPleasure = { 'Aphrodite', 'Ares' },
	ChainReaction = { 'Hephaestus', 'Hestia' },
	CherishedHeirloom = { 'Demeter', 'Hera' },
	CryoPounder = { 'Demeter', 'Hephaestus' },
	CuttingEdge = { 'Apollo', 'Ares' },
	EcstaticObsession = { 'Aphrodite', 'Hera' },
	GloriousDisaster = { 'Apollo', 'Zeus' },
	HeartyAppetite = { 'Aphrodite', 'Demeter' },
	HostileEnvironment = { 'Ares', 'Demeter' },
	KillerCurrent = { 'Poseidon', 'Zeus' },
	NaturalSelection = { 'Demeter', 'Poseidon' },
	RippleEffect = { 'Hera', 'Poseidon' },
	ScaldingVapor = { 'Hestia', 'Poseidon' },
	SeismicHammer = { 'Hephaestus', 'Poseidon' },
	SmolderingForge = { 'Aphrodite', 'Hephaestus' },
	SunWorshiper = { 'Apollo', 'Hera' },
	ThermalDynamics = { 'Hestia', 'Zeus' },
}

local CONFIG_LEGENDARY_GODS = {
	AllTogether = 'Hera',
	BurningMeteor = 'Hestia',
	PremiumService = 'Hephaestus',
	SecondWind = 'Hermes',
	ShockingLoss = 'Zeus',
	WinterHarvest = 'Demeter',
}

local CONFIG_SECTIONS = {
	{ Key = 'Keepsakes', Name = 'Keepsakes' },
	{ Key = 'Systems', Name = 'Systems' },
	{ Key = 'Experimental', Name = 'Experimental' },
}


local function config_label(key)
	if CONFIG_LABELS[key] then return CONFIG_LABELS[key] end

	local words = {}
	for word in key:gmatch('%u[%l%d]*') do
		table.insert(words, (#words > 0 and CONFIG_SMALL_WORDS[word]) or word)
	end
	return table.concat(words, ' ')
end


local function config_keys(section, kind)
	local keys = {}
	for key, value in pairs(section) do
		if type(key) == 'string' and type(value) == kind then table.insert(keys, key) end
	end
	table.sort(keys, function(a, b) return config_label(a) < config_label(b) end)
	return keys
end


local function config_save()
	local file = chalk.original(config)
	if file and file.save then file:save() end
end


local function config_checkbox(label, id, section, key)
	local value, pressed = rom.ImGui.Checkbox(label .. '##' .. id, section[key] == true)
	if pressed then
		section[key] = value
		config_save()
	end
end


local function config_draw_entries(section, path)
	for _, key in ipairs(config_keys(section, 'boolean')) do
		config_checkbox(config_label(key), path .. '.' .. key, section, key)
	end
	for _, key in ipairs(config_keys(section, 'table')) do
		if rom.ImGui.TreeNode(config_label(key) .. '##' .. path .. '.' .. key) then
			config_draw_entries(section[key], path .. '.' .. key)
			rom.ImGui.TreePop()
		end
	end
end


local function config_add(byGod, godNames, god, entry)
	if not byGod[god] then
		byGod[god] = { Boons = {}, Legendaries = {}, Duos = {} }
		table.insert(godNames, god)
	end
	table.insert(byGod[god][entry.Kind], entry)
end


local function config_draw_boons()
	local boons = config.Boons
	if not boons then return end

	local byGod, godNames, other = {}, {}, {}

	for _, god in ipairs(config_keys(boons, 'table')) do
		if god ~= 'Duos' and god ~= 'Legendaries' then
			for _, key in ipairs(config_keys(boons[god], 'boolean')) do
				config_add(byGod, godNames, god, { Kind = 'Boons', Section = boons[god], Key = key, Label = config_label(key) })
			end
		end
	end

	local legendaries = boons.Legendaries
	for _, key in ipairs(legendaries and config_keys(legendaries, 'boolean') or {}) do
		local entry = { Kind = 'Legendaries', Section = legendaries, Key = key, Label = config_label(key) .. ' (Legendary)' }
		local god = CONFIG_LEGENDARY_GODS[key]
		if god then config_add(byGod, godNames, god, entry) else table.insert(other, entry) end
	end

	local duos = boons.Duos
	for _, key in ipairs(duos and config_keys(duos, 'boolean') or {}) do
		local gods = CONFIG_DUO_GODS[key]
		if gods then
			for i, god in ipairs(gods) do
				config_add(byGod, godNames, god, {
					Kind = 'Duos', Section = duos, Key = key,
					Label = config_label(key) .. ' (with ' .. gods[3 - i] .. ')',
				})
			end
		else
			table.insert(other, { Kind = 'Duos', Section = duos, Key = key, Label = config_label(key) })
		end
	end

	table.sort(godNames)
	for _, god in ipairs(godNames) do
		if rom.ImGui.TreeNode(god .. '##Boons.' .. god) then
			for _, kind in ipairs({ 'Boons', 'Legendaries', 'Duos' }) do
				for _, entry in ipairs(byGod[god][kind]) do
					config_checkbox(entry.Label, 'Boons.' .. god .. '.' .. entry.Key, entry.Section, entry.Key)
				end
			end
			rom.ImGui.TreePop()
		end
	end

	if #other > 0 and rom.ImGui.TreeNode('Other##Boons.Other') then
		for _, entry in ipairs(other) do
			config_checkbox(entry.Label, 'Boons.Other.' .. entry.Key, entry.Section, entry.Key)
		end
		rom.ImGui.TreePop()
	end
end


function boon_edits_draw_config()
	if not config then return end

	rom.ImGui.TextWrapped('Changes are saved right away. Most boon changes only fully apply after restarting the game.')
	config_checkbox('Enable BoonEdits', 'enabled', config, 'enabled')
	rom.ImGui.Separator()

	if rom.ImGui.CollapsingHeader('Boons##Boons', rom.ImGuiTreeNodeFlags.DefaultOpen) then config_draw_boons() end

	for _, spec in ipairs(CONFIG_SECTIONS) do
		local section = config[spec.Key]
		if section and rom.ImGui.CollapsingHeader(spec.Name .. '##' .. spec.Key) then
			config_draw_entries(section, spec.Key)
		end
	end
end
