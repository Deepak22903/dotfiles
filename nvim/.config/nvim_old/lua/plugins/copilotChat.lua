return {
  "CopilotC-Nvim/CopilotChat.nvim",
  branch = "main",
  cmd = "CopilotChat",
  opts = function()
    local user = vim.env.USER or "User"
    user = user:sub(1, 1):upper() .. user:sub(2)
    return {
      auto_insert_mode = true,
      question_header = "  " .. user .. " ",
      answer_header = "  Copilot ",
      window = {
        width = 0.4,
      },
    }
  end,
  keys = {
    { "<c-s>", "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
    { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
    {
      "<leader>aa",
      function()
        return require("CopilotChat").toggle()
      end,
      desc = "Toggle (CopilotChat)",
      mode = { "n", "v" },
    },
    {
      "<leader>ax",
      function()
        return require("CopilotChat").reset()
      end,
      desc = "Clear (CopilotChat)",
      mode = { "n", "v" },
    },
    {
      "<leader>aq",
      function()
        vim.ui.input({
          prompt = "Quick Chat: ",
        }, function(input)
          if input ~= "" then
            require("CopilotChat").ask(input)
          end
        end)
      end,
      desc = "Quick Chat (CopilotChat)",
      mode = { "n", "v" },
    },
    {
      "<leader>ap",
      function()
        require("CopilotChat").select_prompt()
      end,
      desc = "Prompt Actions (CopilotChat)",
      mode = { "n", "v" },
    },

    { "<leader>zc", ":CopilotChat<CR>", mode = "n", "Chat with Copilot" },
    { "<leader>zc", ":CopilotChat<CR>", mode = "v", "Chat with Copilot" },
    { "<leader>ze", ":CopilotChatExplain<CR>", mode = "v", desc = "Explain Code" },
    { "<leader>zr", ":CopilotChatReview<CR>", mode = "v", desc = "Review Code" },
    { "<leader>zf", ":CopilotChatFix<CR>", mode = "v", desc = "Fix Code Issues" },
    { "<leader>zo", ":CopilotChatOptimize<CR>", mode = "v", desc = "Optimize Code" },
    { "<leader>zd", ":CopilotChatDocs<CR>", mode = "v", desc = "Generate Docs" },
    { "<leader>zt", ":CopilotChatTests<CR>", mode = "v", desc = "Generate Tests" },
    { "<leader>zm", ":CopilotChatCommit<CR>", mode = "n", desc = "Generate Commit Message" },
    { "<leader>zs", ":CopilotChatCommit<CR>", mode = "v", desc = "Generate Commit for Selection" },
    { "<leader>zn", ":CopilotChatRename<CR>", mode = "v", desc = "Rename the variable" },
  },
  config = function(_, opts)
    local chat = require("CopilotChat")

    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "copilot-chat",
      callback = function()
        vim.opt_local.relativenumber = false
        vim.opt_local.number = false
      end,
    })

    chat.setup(opts)
  end,
}
