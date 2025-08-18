local icon_set = {
	{
		icon = data.raw["deconstruction-item"]["deconstruction-planner"].icon
	},
	{
		icon = data.raw["item"]["steel-chest"].icon,
		scale = 0.3125,
		shift = {-4, -4}
	},
	{
		icon = data.raw["virtual-signal"]["signal-stack-size"].icon,
		scale = 0.3125,
		shift = {6, 6}
	},
	{
		icon = data.raw["virtual-signal"]["signal-deny"].icon,
		scale = 0.3125,
		shift = {6, 6}
	}
}
local shortcut = {
	type = "shortcut",
	name = "clear-container-shortcut",
	order = "b[blueprints]-s[clear-container-tool]",
	action = "spawn-item",
	item_to_spawn = "clear-container-tool",
	style = "default",
	icons = icon_set,
	small_icons = icon_set
}
local container_list = {"container", "infinity-container", "logistic-container", "temporary-container"}
local common_mode = {
	mode = {"any-entity"},
	cursor_box_type = "pair",
	entity_type_filters = container_list,
	ended_sound = data.raw["deconstruction-item"]["deconstruction-planner"].select.ended_sound
}
---@diagnostic disable-next-line: undefined-field
local select_mode = table.deepcopy(common_mode)
     select_mode["border_color"] = {r = 1        , g = 170 / 255, b = 0}
---@diagnostic disable-next-line: undefined-field
local select_mode_alt = table.deepcopy(common_mode)
 select_mode_alt["border_color"] = {r = 1        , g =  64 / 255, b = 0}
---@diagnostic disable-next-line: undefined-field
local reverse_mode = table.deepcopy(common_mode)
    reverse_mode["border_color"] = {r = 149 / 255, g = 1        , b = 0}
---@diagnostic disable-next-line: undefined-field
local reverse_mode_alt = table.deepcopy(common_mode)
reverse_mode_alt["border_color"] = {r = 1        , g = 1        , b = 0}
local selector = {
	type = "selection-tool",
	select = select_mode,
	alt_select = select_mode_alt,
	reverse_select = reverse_mode,
	alt_reverse_select = reverse_mode_alt,
	name = "clear-container-tool",
	icons = icon_set,
	flags = {"only-in-cursor", "spawnable"},
	subgroup = "tool",
	order = "c[automated-construction]-b[clear-container-tool]",
	stack_size = 1,
	stackable = false
}
local key_sequence = {
	name = "give-clear-container-tool",
	type = "custom-input",
	key_sequence = "ALT + X",
	action = "spawn-item",
	item_to_spawn = "clear-container-tool",
	consuming = "none",
	order = "b"
}

data.extend({shortcut, selector, key_sequence})
