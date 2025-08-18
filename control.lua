local function get_member_safe(object, field)
	local call_result, value = pcall( function () return object[field] end )
	if call_result then
		return value
	else
		return nil
	end
end
local function call_member_safe(object, field, ...)
	local call_result, value = pcall(function (...) return object[field](...) end, ...)
	if call_result then
		return value
	else
		return nil
	end
end

local function get_current_insert_plan(entity)
	local item_request_proxy = (entity.type == "entity-ghost" and entity) or entity.item_request_proxy
	if item_request_proxy then
		return item_request_proxy.insert_plan or (entity.type ~= "entity-ghost" and item_request_proxy.modules) or {}
	end
	return {}
end


local function get_removal_plan(entity)
	if not entity.valid or not entity.get_output_inventory or entity.get_output_inventory().is_empty() then
		return {}
	end
	local inventory = entity.get_output_inventory()
	local removal_plan = {}
	for index = 1, #inventory do
		local item_slot = inventory[index]
		if item_slot.count > 0 then
			if not removal_plan[item_slot.name] then
				removal_plan[item_slot.name] = {}
			end
			removal_plan[item_slot.name][#removal_plan[item_slot.name] + 1] = {
				inventory = inventory.index,
				stack = index - 1,
				count = item_slot.count
			}
		end
	end
	for key, value in pairs(removal_plan) do
		removal_plan[#removal_plan + 1] = {
			id = {
				name = key
			},
			items = {
				in_inventory = value
			}
		}
		removal_plan[key] = nil
	end
	return removal_plan
end

local function get_item_request_proxy(entity, player, insert_plan, removal_plan)
	return {
		name = "item-request-proxy",
		target = entity,
		position = entity.position,
		force = player.force,
		-- player = player,		-- DO NOT USE THIS, IT can CAUSE A CRASH. Undoing an item-request-proxy will cause a crash. This is what allows an undo. THIS IS ONLY HERE TO SERVE AS A WARNING.
		modules = insert_plan or {},
		insert_plan = insert_plan or {},
		removal_plan = removal_plan or {}
	}
end
local function on_area_selected(event)
	if event.item ~= "clear-container-tool" then
		return
	end
	local player = game.players[event.player_index]
	local set_insert = event.name == defines.events.on_player_selected_area or event.name == defines.events.on_player_reverse_selected_area		--If not alt_select
	local set_remove = event.name == defines.events.on_player_selected_area or event.name == defines.events.on_player_alt_selected_area			--If not reverse_select
	-- player.print(serpent.block(tostring(set_insert).." "..tostring(set_remove)))
	for _, entity in pairs(event.entities) do
		if entity.type ~= "entity-ghost" then																									--If not a ghost. Ghost support is WIP.
			local insert_plan = get_current_insert_plan(entity)																					--Get the current insert plan to merge with the new item-proxy-request.
			local remove_plan = get_removal_plan(entity)																						--Calculate the removal plan for the entity based on the contents.
			local insert_is_set = (set_insert and insert_plan and #insert_plan ~= 0)															--Check if there were items set to insert.
			local remove_is_set = (set_remove and remove_plan and #remove_plan ~= 0)															--Check if there were items to remove.
			-- player.print(serpent.block(tostring(insert_is_set).." "..tostring(remove_is_set)))

			if entity.item_request_proxy then																									--Remove the old item-request-proxy if it exists.
				entity.item_request_proxy.destroy()
			end
			
			if insert_is_set or remove_is_set then																								--If there were items set to insert or items to remove.
				local proxy = get_item_request_proxy(entity, player, insert_is_set and insert_plan, remove_is_set and remove_plan)				--Create a new item-request-proxy.
				-- player.print(serpent.block(proxy))
				event.surface.create_entity(proxy)
			end
		end
	end
end

script.on_event(defines.events.on_player_selected_area, on_area_selected)
script.on_event(defines.events.on_player_alt_selected_area, on_area_selected)
script.on_event(defines.events.on_player_reverse_selected_area, on_area_selected)
script.on_event(defines.events.on_player_alt_reverse_selected_area, on_area_selected)