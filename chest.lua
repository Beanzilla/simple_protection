local sp = simple_protection
local S = sp.translator

-- A shared chest for simple_protection but works with other protection mods too

local function get_item_count(pos, player, count)
	local name = player and player:get_player_name()
	if not name or minetest.is_protected(pos, name) then
		return 0
	end
	return count
end

-- Just in case we are under MineClone
local groups = nil
local sounds = nil
local textures = nil
if sp.game_mode() == "MTG" then
	groups = {choppy = 2, oddly_breakable_by_hand = 2}
	sounds = default.node_sound_wood_defaults()
	textures = {
		top = "default_chest_top.png",
		right = "default_chest_side.png",
		front = "default_chest_lock.png"
	}
	textures.bot = textures.top
	textures.left = textures.right
	textures.back = textures.right
elseif sp.game_mode() == "MCL" then
	groups = {handy=1,axey=1, deco_block=1}
	sounds = mcl_sounds.node_sound_wood_defaults()
	textures = {
		top = "mcl_chests_chest_trapped_top.png",
		back = "mcl_chests_chest_trapped_back.png",
		bot = "mcl_chests_chest_trapped_bottom.png",
		right = "mcl_chests_chest_trapped_right.png",
		left = "mcl_chests_chest_trapped_left.png",
		front = "mcl_chests_chest_trapped_front.png",
	}
end

local tex_mod = "^[colorize:#FF2:50"
minetest.register_node("simple_protection:chest", {
	description = S("Shared Chest") .. " " .. S("(by protection)"),
	tiles = {
		textures.top  .. tex_mod,
		textures.bot  .. tex_mod,
		textures.right .. tex_mod,
		textures.left .. tex_mod,
		textures.back .. tex_mod,
		textures.front .. tex_mod
	},
	paramtype2 = "facedir",
	sounds = sounds,
	groups = groups,
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Shared Chest"))
		if sp.game_mode() == "MTG" then
			meta:set_string("formspec",
				"size[8,9]" ..
				default.gui_bg ..
				default.gui_bg_img ..
				"list[context;main;0,0.3;8,4;]" ..
				"list[current_player;main;0,5;8,4;]" ..
				"listring[context;main]" ..
				"listring[current_player;main]"
			)
			local inv = meta:get_inventory()
			inv:set_size("main", 8*4)
		elseif sp.game_mode() == "MCL" then
			-- In MineClone they have a separate overlay of images for the inventory,
			-- This branch should setup the proper dimentions (9x3) instead of Minetest's fairly nice dimentions (8x4)
			meta:set_string("formspec",
				"size[9,8.75]"..
				"label[0,0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Shared Chest"))).."]"..
				"list[context;main;0,0.5;9,3;]"..
				mcl_formspec.get_itemslot_bg(0,0.5,9,3)..
				"label[0,4.0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
				"list[current_player;main;0,4.5;9,3;9]"..
				mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
				"list[current_player;main;0,7.74;9,1;]"..
				mcl_formspec.get_itemslot_bg(0,7.74,9,1)..
				"listring[context;main]"..
				"listring[current_player;main]"
			)
			local inv = meta:get_inventory()
			inv:set_size("main", 9*3)
		end
	end,
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_inventory():is_empty("main")
	end,
	on_blast = function() end,

	allow_metadata_inventory_put = function(pos, fl, fi, stack, player)
		return get_item_count(pos, player, stack:get_count())
	end,
	allow_metadata_inventory_take = function(pos, fl, fi, stack, player)
		return get_item_count(pos, player, stack:get_count())
	end,
	allow_metadata_inventory_move = function(pos, fl, fi, tl, ti, count, player)
		return get_item_count(pos, player, count)
	end,
	on_metadata_inventory_put = function(pos, fl, fi, stack, player)
		minetest.log("action", player:get_player_name()
			.. " moves " .. stack:get_name() .. " to shared chest at "
			.. minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, fl, fi, stack, player)
		minetest.log("action", player:get_player_name()
			.. " takes " .. stack:get_name() .. " from shared chest at "
			.. minetest.pos_to_string(pos))
	end,
	-- on_metadata_inventory_move logging is redundant: Same chest contents
})

minetest.register_craft({
	type = "shapeless",
	output = "simple_protection:chest",
	recipe = { "simple_protection:claim", sp.resource.chest.regular}
})

minetest.register_craft({
	type = "shapeless",
	output = "simple_protection:chest",
	recipe = { "simple_protection:claim", sp.resource.chest.locked}
})
