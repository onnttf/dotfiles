local function getTelescopeOpts(state, path)
	return {
		cwd = path,
		search_dirs = { path },
		attach_mappings = function(prompt_bufnr, map)
			local actions = require("telescope.actions")
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local action_state = require("telescope.actions.state")
				local selection = action_state.get_selected_entry()
				local filename = selection.filename
				if filename == nil then
					filename = selection[1]
				end
				-- any way to open the file without triggering auto-close event of neo-tree?
				require("neo-tree.sources.filesystem").navigate(state, state.path, filename)
			end)
			return true
		end,
	}
end

local renderer = require("neo-tree.ui.renderer")

-- Expand a node and load filesystem info if needed.
local function open_dir(state, dir_node)
	local fs = require("neo-tree.sources.filesystem")
	fs.toggle_directory(state, dir_node, nil, true, false)
end

-- Expand a node and all its children, optionally stopping at max_depth.
local function recursive_open(state, node, max_depth)
	local max_depth_reached = 1
	local stack = { node }
	while next(stack) ~= nil do
		node = table.remove(stack)
		if node.type == "directory" and not node:is_expanded() then
			open_dir(state, node)
		end

		local depth = node:get_depth()
		max_depth_reached = math.max(depth, max_depth_reached)

		if not max_depth or depth < max_depth - 1 then
			local children = state.tree:get_nodes(node:get_id())
			for _, v in ipairs(children) do
				table.insert(stack, v)
			end
		end
	end

	return max_depth_reached
end

--- Open the fold under the cursor, recursing if count is given.
local function neotree_zo(state, open_all)
	local node = state.tree:get_node()

	if open_all then
		recursive_open(state, node)
	else
		recursive_open(state, node, node:get_depth() + vim.v.count1)
	end

	renderer.redraw(state)
end

--- Recursively open the current folder and all folders it contains.
local function neotree_zO(state)
	neotree_zo(state, true)
end

-- The nodes inside the root folder are depth 2.
local MIN_DEPTH = 2

--- Close the node and its parents, optionally stopping at max_depth.
local function recursive_close(state, node, max_depth)
	if max_depth == nil or max_depth <= MIN_DEPTH then
		max_depth = MIN_DEPTH
	end

	local last = node
	while node and node:get_depth() >= max_depth do
		if node:has_children() and node:is_expanded() then
			node:collapse()
		end
		last = node
		node = state.tree:get_node(node:get_parent_id())
	end

	return last
end

--- Close a folder, or a number of folders equal to count.
local function neotree_zc(state, close_all)
	local node = state.tree:get_node()
	if not node then
		return
	end

	local max_depth
	if not close_all then
		max_depth = node:get_depth() - vim.v.count1
		if node:has_children() and node:is_expanded() then
			max_depth = max_depth + 1
		end
	end

	local last = recursive_close(state, node, max_depth)
	renderer.redraw(state)
	renderer.focus_node(state, last:get_id())
end

-- Close all containing folders back to the top level.
local function neotree_zC(state)
	neotree_zc(state, true)
end

--- Open a closed folder or close an open one, with an optional count.
local function neotree_za(state, toggle_all)
	local node = state.tree:get_node()
	if not node then
		return
	end

	if node.type == "directory" and not node:is_expanded() then
		neotree_zo(state, toggle_all)
	else
		neotree_zc(state, toggle_all)
	end
end

--- Recursively close an open folder or recursively open a closed folder.
local function neotree_zA(state)
	neotree_za(state, true)
end

--- Set depthlevel, analagous to foldlevel, for the neo-tree file tree.
local function set_depthlevel(state, depthlevel)
	if depthlevel < MIN_DEPTH then
		depthlevel = MIN_DEPTH
	end

	local stack = state.tree:get_nodes()
	while next(stack) ~= nil do
		local node = table.remove(stack)

		if node.type == "directory" then
			local should_be_open = depthlevel == nil or node:get_depth() < depthlevel
			if should_be_open and not node:is_expanded() then
				open_dir(state, node)
			elseif not should_be_open and node:is_expanded() then
				node:collapse()
			end
		end

		local children = state.tree:get_nodes(node:get_id())
		for _, v in ipairs(children) do
			table.insert(stack, v)
		end
	end

	vim.b.neotree_depthlevel = depthlevel
end

--- Refresh the tree UI after a change of depthlevel.
-- @bool stay Keep the current node revealed and selected
local function redraw_after_depthlevel_change(state, stay)
	local node = state.tree:get_node()

	if stay then
		require("neo-tree.ui.renderer").expand_to_node(state.tree, node)
	else
		-- Find the closest parent that is still visible.
		local parent = state.tree:get_node(node:get_parent_id())
		while not parent:is_expanded() and parent:get_depth() > 1 do
			node = parent
			parent = state.tree:get_node(node:get_parent_id())
		end
	end

	renderer.redraw(state)
	renderer.focus_node(state, node:get_id())
end

--- Update all open/closed folders by depthlevel, then reveal current node.
local function neotree_zx(state)
	set_depthlevel(state, vim.b.neotree_depthlevel or MIN_DEPTH)
	redraw_after_depthlevel_change(state, true)
end

--- Update all open/closed folders by depthlevel.
local function neotree_zX(state)
	set_depthlevel(state, vim.b.neotree_depthlevel or MIN_DEPTH)
	redraw_after_depthlevel_change(state, false)
end

-- Collapse more folders: decrease depthlevel by 1 or count.
local function neotree_zm(state)
	local depthlevel = vim.b.neotree_depthlevel or MIN_DEPTH
	set_depthlevel(state, depthlevel - vim.v.count1)
	redraw_after_depthlevel_change(state, false)
end

-- Collapse all folders. Set depthlevel to MIN_DEPTH.
local function neotree_zM(state)
	set_depthlevel(state, MIN_DEPTH)
	redraw_after_depthlevel_change(state, false)
end

-- Expand more folders: increase depthlevel by 1 or count.
local function neotree_zr(state)
	local depthlevel = vim.b.neotree_depthlevel or MIN_DEPTH
	set_depthlevel(state, depthlevel + vim.v.count1)
	redraw_after_depthlevel_change(state, false)
end

-- Expand all folders. Set depthlevel to the deepest node level.
local function neotree_zR(state)
	local top_level_nodes = state.tree:get_nodes()

	local max_depth = 1
	for _, node in ipairs(top_level_nodes) do
		max_depth = math.max(max_depth, recursive_open(state, node))
	end

	vim.b.neotree_depthlevel = max_depth
	redraw_after_depthlevel_change(state, false)
end

require("neo-tree").setup({
	use_default_mappings = false,
	close_if_last_window = true,
	sources = { "filesystem", "buffers", "git_status", "document_symbols" }, -- Define sources for neotree
	source_selector = {
		sources = {
			{
				source = "filesystem", -- Filesystem source
			},
			{
				source = "buffers", -- Buffers source
			},
			{
				source = "git_status", -- Git status source
			},
			{
				source = "document_symbols", -- Document symbols source
			},
		},
	},
	window = {
		position = "float",
		mappings = {
			["<"] = "prev_source", -- Go to previous source
			[">"] = "next_source", -- Go to next source
			["S"] = "open_split", -- Open neotree in split
			["s"] = "open_vsplit", -- Open neotree in vsplit
			["R"] = "refresh", -- Refresh neotree
			["<cr>"] = "open",
		},
	},
	filesystem = {
		filtered_items = {
			show_hidden_count = true, -- when true, the number of hidden items in each folder will be shown as the last entry
			hide_dotfiles = true,
			hide_gitignored = true,
			hide_by_name = {
				"node_modules",
			},
			always_show = { -- remains visible even if other settings would normally hide it
				".gitignored",
			},
		},
		follow_current_file = {
			enabled = true,
		},
		window = {
			mappings = {
				["h"] = function(state)
					local node = state.tree:get_node()
					if node.type == "directory" and node:is_expanded() then
						require("neo-tree.sources.filesystem").toggle_directory(state, node)
					else
						require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
					end
				end,
				["l"] = function(state)
					local node = state.tree:get_node()
					if node.type == "directory" then
						if not node:is_expanded() then
							require("neo-tree.sources.filesystem").toggle_directory(state, node)
						elseif node:has_children() then
							require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
						end
					end
				end,
				["<tab>"] = function(state)
					local node = state.tree:get_node()
					if require("neo-tree.utils").is_expandable(node) then
						state.commands["toggle_node"](state)
					else
						state.commands["open"](state)
						vim.cmd("Neotree reveal")
					end
				end,
				["tf"] = "telescope_find",
				["tg"] = "telescope_grep",
				["a"] = {
					"add",
					config = {
						show_path = "relative",
					},
				},
				["d"] = "delete",
				["r"] = "rename",
				["c"] = {
					"copy",
					config = {
						show_path = "relative",
					},
				},
				["m"] = {
					"move",
					config = {
						show_path = "relative",
					},
				},
				["H"] = "toggle_hidden",
				["/"] = "fuzzy_finder",
				-- ["D"] = "fuzzy_finder_directory",
				["<bs>"] = "navigate_up",
				["."] = "set_root",
				["i"] = "show_file_details",
				["z"] = "none",

				-- zo 	open a directory
				-- 2zo 	recursively open two levels of directories
				-- zO 	recursively open a directory and all its children
				-- zc 	close a directory
				-- zr 	increase depthlevel (like foldlevel), open all folders to the depthlevel, and close all folders beyond it
				-- 2zm 	decrease the depthlevel by 2, then open or close folders appropriately
				-- zR 	open all directories and set the foldlevel to the deepest directory
				["zo"] = neotree_zo,
				["zO"] = neotree_zO,
				["zc"] = neotree_zc,
				["zC"] = neotree_zC,
				["za"] = neotree_za,
				["zA"] = neotree_zA,
				["zx"] = neotree_zx,
				["zX"] = neotree_zX,
				["zm"] = neotree_zm,
				["zM"] = neotree_zM,
				["zr"] = neotree_zr,
				["zR"] = neotree_zR,
			},
			fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
				["<down>"] = "move_cursor_down",
				["<C-n>"] = "move_cursor_down",
				["<up>"] = "move_cursor_up",
				["<C-p>"] = "move_cursor_up",
			},
		},
		commands = {
			telescope_find = function(state)
				local node = state.tree:get_node()
				local path = node:get_id()
				require("telescope.builtin").find_files(getTelescopeOpts(state, path))
			end,
			telescope_grep = function(state)
				local node = state.tree:get_node()
				local path = node:get_id()
				require("telescope.builtin").live_grep(getTelescopeOpts(state, path))
			end,
		},
	},
	buffers = {
		follow_current_file = {
			enabled = true,
		},
		window = {
			mappings = {
				["d"] = "buffer_delete", -- Delete buffer
			},
		},
	},
	git_status = {
		window = {
			mappings = {
				["A"] = "git_add_all",
				["gu"] = "git_unstage_file",
				["ga"] = "git_add_file",
				["gr"] = "git_revert_file",
				["gc"] = "git_commit",
				["gp"] = "git_push",
				["gg"] = "git_commit_and_push",
			},
		},
	},
	document_symbols = {
		follow_cursor = true,
	},
	event_handlers = {
		{
			event = "neo_tree_window_after_open",
			handler = function(args)
				if args.position == "left" or args.position == "right" then
					vim.cmd("wincmd =")
				end
			end,
		},
		{
			event = "neo_tree_window_after_close",
			handler = function(args)
				if args.position == "left" or args.position == "right" then
					vim.cmd("wincmd =")
				end
			end,
		},
	},
})
