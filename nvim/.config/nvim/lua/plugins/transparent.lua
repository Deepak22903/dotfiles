return {
  {
    "xiyaowong/transparent.nvim",
    enabled = true,
    -- Optional, you don't have to run setup.

    extra_groups = { -- table/string: additional groups that should be cleared
      "BufferLineTabClose",
      "BufferlineBufferSelected",
      "BufferLineFill",
      "BufferLineBackground",
      "BufferLineSeparator",
      "BufferLineIndicatorSelected",

      "IndentBlanklineChar",

      -- make floating windows transparent
      "LspFloatWinNormal",
      "Normal",
      "NormalFloat",
      "FloatBorder",
      "TelescopeNormal",
      "TelescopeBorder",
      "TelescopePromptBorder",
      "SagaBorder",
      "SagaNormal",
    },
  },
}
