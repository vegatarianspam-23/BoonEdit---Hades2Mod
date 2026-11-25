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
	OfferRequirements = 'Offer requirement changes',
	ScytheSlows = "Chronos' thrown scythes can be slowed",
	SprintFollowsMoveSpeed = 'Sprint speed follows move speed',
	WrathOfOlympus = 'Wrath of Olympus support',
	MoreDashBoons = 'More Dash Boons support',
	AnkhSwapSecondaries = 'Ankh Scepter: Attack draws foes in, Special launches shades',
	PharaohEtchings = 'Pharaoh Etchings: longer field instead of Omega Special shades',
	HermesDuos = 'HermesDuos support',
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
	NuptialVow = 'Hera',
	PaidDues = 'Hermes',
	BurningMeteor = 'Hestia',
	DistressCall = 'Hermes',
	DoubleTime = 'Hermes',
	FlawlessExecution = 'Hermes',
	PremiumService = 'Hephaestus',
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


local function config_node()
	return { Cells = {}, Sections = {} }
end


local function config_read()
	local root = config_node()
	for definition, entry in pairs(chalk.original(config).entries) do
		local value = entry:get()
		if type(value) == 'boolean' then
			local node = root
			for name in definition.section:gmatch('[^.]+') do
				node.Sections[name] = node.Sections[name] or config_node()
				node = node.Sections[name]
			end
			node.Cells[definition.key] = { Entry = entry, Value = value }
		end
	end
	return root.Sections.config or config_node()
end


local function config_sorted(map)
	local labels, keys = {}, {}
	for key in pairs(map) do
		labels[key] = config_label(key)
		table.insert(keys, key)
	end
	table.sort(keys, function(a, b) return labels[a] < labels[b] end)
	return keys
end


local function config_save()
	local file = chalk.original(config)
	if file and file.save then file:save() end
end


local function config_entry(cell, label, id)
	return { Cell = cell, Label = label .. '##' .. id }
end


local function config_checkbox(entry)
	local cell = entry.Cell
	local value, pressed = rom.ImGui.Checkbox(entry.Label, cell.Value)
	if pressed then
		cell.Value = value
		cell.Entry:set(value)
		boon_edit_config_changed()
		config_save()
	end
end


local function config_tree(node, path)
	local tree = { Entries = {}, Children = {} }
	for _, key in ipairs(config_sorted(node.Cells)) do
		table.insert(tree.Entries, config_entry(node.Cells[key], config_label(key), path .. '.' .. key))
	end
	for _, key in ipairs(config_sorted(node.Sections)) do
		local child = config_tree(node.Sections[key], path .. '.' .. key)
		child.Label = config_label(key) .. '##' .. path .. '.' .. key
		table.insert(tree.Children, child)
	end
	return tree
end


local function config_draw_tree(tree)
	for _, entry in ipairs(tree.Entries) do config_checkbox(entry) end
	for _, child in ipairs(tree.Children) do
		if rom.ImGui.TreeNode(child.Label) then
			config_draw_tree(child)
			rom.ImGui.TreePop()
		end
	end
end


local function config_add(byGod, godNames, god, kind, entry)
	if not byGod[god] then
		byGod[god] = { Boons = {}, Legendaries = {}, Duos = {} }
		table.insert(godNames, god)
	end
	table.insert(byGod[god][kind], entry)
end


local function config_boons(boons)
	local byGod, godNames, other = {}, {}, {}

	for god, section in pairs(boons.Sections) do
		if god ~= 'Duos' and god ~= 'Legendaries' then
			for _, key in ipairs(config_sorted(section.Cells)) do
				config_add(byGod, godNames, god, 'Boons', config_entry(section.Cells[key], config_label(key), 'Boons.' .. god .. '.' .. key))
			end
		end
	end

	local legendaries = boons.Sections.Legendaries
	for _, key in ipairs(legendaries and config_sorted(legendaries.Cells) or {}) do
		local cell, label = legendaries.Cells[key], config_label(key) .. ' (Legendary)'
		local god = CONFIG_LEGENDARY_GODS[key]
		if god then
			config_add(byGod, godNames, god, 'Legendaries', config_entry(cell, label, 'Boons.' .. god .. '.' .. key))
		else
			table.insert(other, config_entry(cell, label, 'Boons.Other.' .. key))
		end
	end

	local duos = boons.Sections.Duos
	for _, key in ipairs(duos and config_sorted(duos.Cells) or {}) do
		local cell, label = duos.Cells[key], config_label(key)
		local gods = CONFIG_DUO_GODS[key]
		if gods then
			for i, god in ipairs(gods) do
				config_add(byGod, godNames, god, 'Duos', config_entry(cell, label .. ' (with ' .. gods[3 - i] .. ')', 'Boons.' .. god .. '.' .. key))
			end
		else
			table.insert(other, config_entry(cell, label, 'Boons.Other.' .. key))
		end
	end

	table.sort(godNames)
	local groups = {}
	for _, god in ipairs(godNames) do
		local group = { Label = god .. '##Boons.' .. god, Entries = {} }
		for _, kind in ipairs({ 'Boons', 'Legendaries', 'Duos' }) do
			for _, entry in ipairs(byGod[god][kind]) do table.insert(group.Entries, entry) end
		end
		table.insert(groups, group)
	end
	if #other > 0 then table.insert(groups, { Label = 'Other##Boons.Other', Entries = other }) end
	return groups
end


local configLayout

local function config_layout()
	if configLayout and configLayout.Source == config then return configLayout end

	local root = config_read()
	local layout = { Source = config, Boons = {}, Sections = {} }

	if root.Cells.enabled then layout.Enabled = config_entry(root.Cells.enabled, 'Enable BoonEdits', 'enabled') end
	if root.Sections.Boons then layout.Boons = config_boons(root.Sections.Boons) end

	for _, spec in ipairs(CONFIG_SECTIONS) do
		local node = root.Sections[spec.Key]
		if node then
			local tree = config_tree(node, spec.Key)
			tree.Label = spec.Name .. '##' .. spec.Key
			table.insert(layout.Sections, tree)
		end
	end

	configLayout = layout
	return layout
end


function boon_edits_draw_config()
	if not config then return end
	local layout = config_layout()

	rom.ImGui.TextWrapped('Changes are saved right away. Most boon changes only fully apply after restarting the game.')
	if layout.Enabled then config_checkbox(layout.Enabled) end
	rom.ImGui.Separator()

	if rom.ImGui.CollapsingHeader('Boons##Boons', rom.ImGuiTreeNodeFlags.DefaultOpen) then
		for _, group in ipairs(layout.Boons) do
			if rom.ImGui.TreeNode(group.Label) then
				for _, entry in ipairs(group.Entries) do config_checkbox(entry) end
				rom.ImGui.TreePop()
			end
		end
	end

	for _, tree in ipairs(layout.Sections) do
		if rom.ImGui.CollapsingHeader(tree.Label) then config_draw_tree(tree) end
	end
end
