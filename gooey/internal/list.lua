local HASHES = require "libs.hashes"
local core = require "gooey.internal.core"

local M = {}

local dynamic_lists = {}


-- update the positions of the list items and set their data indices
local function update_dynamic_listitem_positions(list)
	local top_i, top_y, top_x
	if list.horizontal then
		top_i = list.scroll_pos.x / list.item_size.x
		top_x = list.scroll_pos.x % list.item_size.x
	else
		top_i = list.scroll_pos.y / list.item_size.y
		top_y = list.scroll_pos.y % list.item_size.y
	end
	local first_index = 1 + math.floor(top_i)
	for i = 1, #list.items do
		local item = list.items[i]
		local item_pos = gui.get_position(item.root)
		local index = first_index + i - 1
		if (#list.data ~= 0) then
			item.index = ((index - 1) % #list.data) + 1
		end
		if list.horizontal then
			item_pos.x = list.first_item_pos.x - (list.item_size.x * (i - 1)) + top_x
		else
			item_pos.y = list.first_item_pos.y - (list.item_size.y * (i - 1)) + top_y
		end
		gui.set_position(item.root, item_pos)
	end
end

-- assign new data to the list items
local function update_dynamic_listitem_data(list)
	for i = 1, #list.items do
		local item = list.items[i]
		if i <= #list.data then
			item.data = list.data[item.index] or nil
		else
			item.data = nil
		end
	end
end



-- instance functions
local LIST = {}
function LIST.refresh(list)
	if list.refresh_fn then list.refresh_fn(list) end
end
function LIST.set_visible(list, visible)
	gui.set_enabled(list.node, visible)
end
function LIST.scroll_to(list, x, y)
	list.consumed = true
	list.scrolling = true

	if list.horizontal then
		-- don't scroll if all items are visible
		if list.max_x <= 0 then
			list.scroll_pos.x = 0
			list.scroll.x = 0
		else
			list.scroll_pos.x = list.min_x + (list.max_x - list.min_x) * x
			list.scroll.x = x
		end
	else
		-- don't scroll if all items are visible
		if list.max_y <= 0 then
			list.scroll_pos.y = 0
			list.scroll.y = 0
		else
			list.scroll_pos.y = list.min_y + (list.max_y - list.min_y) * y
			list.scroll.y = y
		end
	end
	if list.static then
		error("static not supported")
	elseif list.dynamic then
		update_dynamic_listitem_positions(list)
		update_dynamic_listitem_data(list)
	end
end
function LIST.set_long_pressed_time(list, time)
	list.long_pressed_time = time
end
function LIST.set_carousel(list)
	list.carousel = true
end

local function handle_input(list, action_id, action, click_fn)
	local over_stencil = gui.pick_node(list.stencil, action.x, action.y)
	list.over = over_stencil

	local touch = action_id == HASHES.INPUT.TOUCH
	local scroll_up = action_id == HASHES.INPUT.SCROLL_UP
	local scroll_down = action_id == HASHES.INPUT.SCROLL_DOWN
	local pressed = touch and action.pressed and over_stencil
	local released = touch and action.released
	local action_pos = vmath.vector3(action.x, action.y, 0)
	if pressed then
		list.pressed_pos = action_pos
		list.action_pos = action_pos
		list.pressed = true
		list.have_scrolled = false
	elseif released then
		list.pressed = false
	end
	list.consumed = false

	-- handle mouse-wheel scrolling
	if over_stencil and (scroll_up or scroll_down) then
		list.consumed = true
		list.scrolling = true
		-- reset scroll speed if the time between two scroll events is too large
		local time = os.time()
		list.scroll_time = list.scroll_time or time
		if (time - list.scroll_time) > 1 then
			list.scroll_speed = 0
		end
		list.scroll_speed = list.scroll_speed or 0
		list.scroll_speed = math.min(list.scroll_speed + 0.25, 30)
		list.scroll_time = time
		if list.horizontal then
			list.scroll_pos.x = list.scroll_pos.x + ((scroll_up and 1 or -1) * list.scroll_speed)
		else
			list.scroll_pos.y = list.scroll_pos.y + ((scroll_up and 1 or -1) * list.scroll_speed)
		end
		list.have_scrolled = true
		if action.released then
			list.scrolling = false
		end
		-- handle touch and drag scrolling
	elseif list.pressed and vmath.length(list.pressed_pos - action_pos) > 10 then
		list.have_scrolled = true
		list.consumed = true
		list.scrolling = true
		if list.horizontal then
			list.scroll_pos.x = list.scroll_pos.x + (action_pos.x - list.action_pos.x)
		else
			list.scroll_pos.y = list.scroll_pos.y + (action_pos.y - list.action_pos.y)
		end
		list.action_pos = action_pos
	else
		list.scrolling = false
	end
	-- limit to scroll bounds unlss this is a carousel list
	if list.scrolling and not list.carousel then
		if list.horizontal then
			list.scroll_pos.x = math.min(list.scroll_pos.x, list.max_x)
			list.scroll_pos.x = math.max(list.scroll_pos.x, list.min_x)
			list.scroll.x = (list.scroll_pos.x / list.max_x)
		else
			list.scroll_pos.y = math.min(list.scroll_pos.y, list.max_y)
			list.scroll_pos.y = math.max(list.scroll_pos.y, list.min_y)
			list.scroll.y = (list.scroll_pos.y / list.max_y)
		end
	end

	-- find which item (if any) that the touch event is over
	local over_item
	for i = 1, #list.items do
		local item = list.items[i]
		if gui.pick_node(item.root, action.x, action.y) then
			list.consumed = true
			over_item = item
			break
		end
	end

	-- handle list item over state
	list.out_item_now = (list.over_item ~= over_item) and list.over_item or nil
	list.over_item_now = (list.over_item_now ~= list.over_item) and over_item or nil
	list.over_item = over_item

	-- handle list item clicks
	list.released_item_now = nil
	list.pressed_item_now = nil
	if released then
		list.released_item_now = list.pressed_item
		list.pressed_item = nil
	end
	if pressed and list.pressed_item_now ~= over_item then
		list.pressed_item_now = over_item
		list.pressed_item = over_item
	else
		list.pressed_item_now = nil
	end
	if list.released_item_now then
		if not list.have_scrolled and list.released_item_now == over_item then
			list.selected_item = list.released_item_now
			click_fn(list)
		end
	end
end

function LIST:on_input(action_id, action)
	self.enabled = gui.is_enabled(self.node, true)
	-- detect a change in size of the stencil
	-- if it has changed we delete the nodes and then recreate
	local stencil_size = gui.get_size(self.stencil)
	if stencil_size.x ~= self.stencil_size.x
			or stencil_size.y ~= self.stencil_size.y then
		self.stencil_size = stencil_size
		if self.items then
			for i = 1, #self.items do
				local item = self.items[i]
				gui.delete_node(item.root)
			end
			self.items = nil
		end
	end

	-- create list items
	if not self.items then
		local item_node = gui.get_node(self.item_id)
		local item_pos = gui.get_position(item_node)
		local item_size = gui.get_size(item_node)
		self.list.items = {}
		self.item_size = item_size
		self.scroll_pos = vmath.vector3(0)
		self.first_item_pos = vmath.vector3(item_pos)
		self.data_size = nil

		local item_count
		if self.horizontal then
			item_count = (math.ceil(self.stencil_size.x / item_size.x) + 1)
		else
			item_count = (math.ceil(self.stencil_size.y / item_size.y) + 1)
		end
		gui.set_enabled(item_node, true)
		for i = 1, item_count do
			local nodes = gui.clone_tree(item_node)
			self.items[i] = {
				root = nodes[self.item_id],
				nodes = nodes,
				index = i,
				size = gui.get_size(nodes[self.item_id]),
				data = self.data[i] or ""
			}
			local pos
			if self.horizontal then
				pos = (item_pos - vmath.vector3(item_size.x * (i - 1), 0, 0))
			else
				pos = (item_pos - vmath.vector3(0, item_size.y * (i - 1), 0))
			end
			gui.set_position(self.items[i].root, pos)
		end
		gui.set_enabled(item_node, false)
	end

	-- recalculate size of list if the amount of data has changed
	-- deselect and realign items
	local data_size_changed = self.data_size ~= #self.data
	if not self.data_size or data_size_changed then
		self.data_size = #self.data
		self.min_y = 0
		self.min_x = 0
		self.max_y = (#self.data * self.item_size.y) - self.stencil_size.y
		self.max_x = (#self.data * self.item_size.x) - self.stencil_size.x
		self.selected_item = nil
		-- fewer items in the list than visible
		-- assign indices and disable list items
		if #self.data < #self.items then
			for i = 1, #self.items do
				local item = self.items[i]
				item.index = i
				gui.set_enabled(item.root, (i <= #self.data))
			end
			self.scroll_pos.y = 0
			self.scroll_pos.x = 0
			update_dynamic_listitem_positions(self)
			-- more items in list than visible
			-- assign indices and enable list items
		else
			local first_index = self.items[1].index
			if (first_index + #self.items) > #self.data then
				first_index = #self.data - #self.items + 1
			end
			for i = 1, #self.items do
				local item = self.items[i]
				item.index = first_index + i - 1
				gui.set_enabled(item.root, true)
			end
		end
	end

	-- bail early if the list is empty
	if self.data_size == 0 then
		if self.refresh_fn then self.refresh_fn(self) end
		return self
	end

	if self.enabled and (action_id or action) then
		handle_input(self, action_id, action, self.fn)
		-- re-position the list items if we're scrolling
		-- re-assign list item indices and data
		if self.scrolling then
			update_dynamic_listitem_positions(self)
		end
	end

	update_dynamic_listitem_data(self)

	if self.refresh_fn then self.refresh_fn(self.list) end

	return self
end

function M.new_list(list_id, stencil_id, item_id, data, config, fn, refresh_fn)
	local list = core.instance(LIST)
	list.id = core.to_hash(list_id)
	list.stencil_id = core.to_hash(stencil_id)

	list.scroll = vmath.vector3()
	list.stencil = gui.get_node(list.stencil_id)
	list.stencil_size = gui.get_size(list.stencil)
	list.refresh_fn = refresh_fn
	list.fn = fn
	list.enabled = gui.is_enabled(list.stencil, true)
	list.dynamic = true
	list.horizontal = config and config.horizontal
	list.carousel = config and config.carousel
	list.data = data
	list.item_id = item_id

	list:on_input(nil, nil)

	return list
end

return M
