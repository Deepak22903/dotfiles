-- plugins/telescope.lua:
return {
  "nvim-telescope/telescope.nvim",
  lazy = true,
  tag = "0.1.8",
  -- or                              , branch = '0.1.x',
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>tt", "<cmd>Telescope<cr>", desc = "Launch Telescope", mode = "n" },
  },
}
