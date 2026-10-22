---@meta _


once('AllTogetherDoubleElements', function()
	if not boon_edit_on('AllTogether') then return end

	local allTogether = game.TraitData.AllElementalBoon
	local doubled = {}
	for _, element in ipairs(allTogether.Elements) do
		table.insert(doubled, element)
		table.insert(doubled, element)
	end
	allTogether.Elements = doubled
end)
