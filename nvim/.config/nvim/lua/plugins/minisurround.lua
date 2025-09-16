return {
  "echasnovski/mini.surround",
  keys = function(_, keys)
    local opts = LazyVim.opts("mini.surround")
    local mappings = {
      { opts.mappings.add, desc = "Add Surrounding", mode = { "n", "v" } },
      { opts.mappings.delete, desc = "Delete Surrounding", mode = "n" },
      { opts.mappings.find, desc = "Find Right Surrounding", mode = "n" },
      { opts.mappings.find_left, desc = "Find Left Surrounding", mode = "n" },
      { opts.mappings.highlight, desc = "Highlight Surrounding", mode = "n" },
      { opts.mappings.replace, desc = "Replace Surrounding", mode = "n" },
      { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`", mode = "n" },
    }
    mappings = vim.tbl_filter(function(m)
      return m[1] and #m[1] > 0
    end, mappings)
    return vim.list_extend(mappings, keys)
  end,
  opts = {
    mappings = {
      add = "<leader>sa",
      delete = "<leader>sd",
      find = "<leader>sf",
      find_left = "<leader>sF",
      highlight = "<leader>sh",
      replace = "<leader>sr",
      update_n_lines = "<leader>sn",
    },
  },
}
