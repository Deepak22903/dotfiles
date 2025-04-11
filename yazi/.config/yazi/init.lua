local catppuccin_theme = require("yatline-catppuccin"):setup("mocha") -- or "latte" | "frappe" | "macchiato"

require("yatline"):setup({
	theme = catppuccin_theme,
	section_separator = { open = "", close = "" },
	part_separator = { open = "", close = "" },
	inverse_separator = { open = "", close = "" },

	style_a = {
		fg = "black",
		bg_mode = {
			normal = "#a89984",
			select = "#d79921",
			un_set = "#d65d0e",
		},
	},
	style_b = { bg = "#665c54", fg = "#ebdbb2" },
	style_c = { bg = "#3c3836", fg = "#a89984" },

	permissions_t_fg = "green",
	permissions_r_fg = "yellow",
	permissions_w_fg = "red",
	permissions_x_fg = "cyan",
	permissions_s_fg = "darkgray",

	tab_width = 20,
	tab_use_inverse = false,

	selected = { icon = "󰻭", fg = "yellow" },
	copied = { icon = "", fg = "green" },
	cut = { icon = "", fg = "red" },

	total = { icon = "󰮍", fg = "yellow" },
	succ = { icon = "", fg = "green" },
	fail = { icon = "", fg = "red" },
	found = { icon = "󰮕", fg = "blue" },
	processed = { icon = "󰐍", fg = "green" },

	show_background = true,

	display_header_line = true,
	display_status_line = true,

	header_line = {
		left = {
			section_a = {
				{ type = "line", custom = false, name = "tabs", params = { "left" } },
			},
			section_b = {},
			section_c = {},
		},
		right = {
			section_a = {
				{ type = "string", custom = false, name = "date", params = { "%A, %d %B %Y" } },
			},
			section_b = {
				{ type = "string", custom = false, name = "date", params = { "%X" } },
			},
			section_c = {},
		},
	},

	status_line = {
		left = {
			section_a = {
				{ type = "string", custom = false, name = "tab_mode" },
			},
			section_b = {
				{ type = "string", custom = false, name = "hovered_size" },
			},
			section_c = {
				{ type = "string", custom = false, name = "hovered_name" },
				{ type = "coloreds", custom = false, name = "count" },
			},
		},
		right = {
			section_a = {
				{ type = "string", custom = false, name = "cursor_position" },
			},
			section_b = {
				{ type = "string", custom = false, name = "cursor_percentage" },
			},
			section_c = {
				{ type = "string", custom = false, name = "hovered_file_extension", params = { true } },
				{ type = "coloreds", custom = false, name = "permissions" },
			},
		},
	},
})

require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})

require("bookmarks"):setup({
	last_directory = { enable = true, persist = false, mode = "jump" },
	persist = "vim",
	desc_format = "parent",
	file_pick_mode = "hover",
	custom_desc_input = false,
	notify = {
		enable = true,
		timeout = 2,
		message = {
			new = "New bookmark '<key>' -> '<folder>'",
			delete = "Deleted bookmark in '<key>'",
			delete_all = "Deleted all bookmarks",
		},
	},
})

require("archivemount"):setup()

require("restore"):setup({
	-- Set the position for confirm and overwrite dialogs.
	-- don't forget to set height: `h = xx`
	-- https://yazi-rs.github.io/docs/plugins/utils/#ya.input
	position = { "center", w = 70, h = 20 }, -- Optional

	-- Show confirm dialog before restore.
	-- NOTE: even if set this to false, overwrite dialog still pop up
	show_confirm = true, -- Optional

	-- colors for confirm and overwrite dialogs
	theme = { -- Optional
		-- Default using style from your flavor or theme.lua -> [confirm] -> title.
		-- If you edit flavor or theme.lua you can add more style than just color.
		-- Example in theme.lua -> [confirm]: title = { fg = "blue", bg = "green"  }
		title = "blue", -- Optional. This valid has higher priority than flavor/theme.lua

		-- Default using style from your flavor or theme.lua -> [confirm] -> content
		-- Sample logic as title above
		header = "green", -- Optional. This valid has higher priority than flavor/theme.lua

		-- header color for overwrite dialog
		-- Default using color "yellow"
		header_warning = "yellow", -- Optional
		-- Default using style from your flavor or theme.lua -> [confirm] -> list
		-- Sample logic as title and header above
		list_item = { odd = "blue", even = "blue" }, -- Optional. This valid has higher priority than flavor/theme.lua
	},
})

require("simple-mtpfs"):setup({})

require("copy-file-contents"):setup({
	append_char = "\n",
	notification = true,
})

-- require("git"):setup()

require("custom-shell"):setup({
	history_path = "default",
	save_history = true,
})
