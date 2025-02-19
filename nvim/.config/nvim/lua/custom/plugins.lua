local plugins = {
  ---@type LazySpec
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        "<leader>-",
        mode = { "n", "v" },
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        -- Open in the current working directory
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        -- NOTE: this requires a version of yazi that includes
        -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
        "<c-up>",
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
      },
    },
  },
  -- Installer for LSP, formatting, and debugging
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = "Mason",
    keys = { { "<leader>pm", "<cmd>Mason<cr>", desc = "Mason" } },
    opts = {
      ui = {
        keymaps = { apply_language_filter = "F" },
        icons = {
          package_installed = "● ",
          package_pending = "󰦗 ",
          package_uninstalled = "○ ",
        },
      },
      -- Not an actual option! Manually install the packages in config.
      ensure_installed = { "clang-format", "codelldb", "prettier", "stylua" },
    },
    config = function(_, opts)
      require("mason").setup(opts)

      local mr = require "mason-registry"
      mr.refresh(function()
        for _, pkg in ipairs(opts.ensure_installed) do
          local p = mr.get_package(pkg)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    lazy = true,
    dependencies = "williamboman/mason.nvim",
    opts = {
      automatic_installation = { exclude = { "rust_analyzer" } },
    },
  },

  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    dependencies = { "williamboman/mason-lspconfig.nvim", "saghen/blink.cmp" },
    init = function()
      local icons = {
        error = "󰯹 ",
        warn = "󰰯 ",
        hint = "󰰂 ",
        info = "󰰅 ",
      }

      -- diagnostics
      local diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = function(diagnostic)
            for d, icon in pairs(icons) do
              if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
                return icon
              end
            end
          end,
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = icons.error,
            [vim.diagnostic.severity.WARN] = icons.warn,
            [vim.diagnostic.severity.HINT] = icons.hint,
            [vim.diagnostic.severity.INFO] = icons.info,
          },
        },
      }
      vim.diagnostic.config(vim.deepcopy(diagnostics))
    end,
    config = function()
      require("lspconfig").lua_ls.setup {
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false,
            },
            codeLens = {
              enable = true,
            },
            completion = {
              callSnippet = "Replace",
            },
            doc = {
              privateName = { "^_" },
            },
            hint = {
              enable = true,
              setType = false,
              paramType = true,
              paramName = "Disable",
              semicolon = "Disable",
              arrayIndex = "Disable",
            },
          },
        },
        capabilities = vim.tbl_deep_extend(
          "force",
          { workspace = { fileOperations = { didRename = true, willRename = true } } },
          vim.lsp.protocol.make_client_capabilities(),
          require("blink.cmp").get_lsp_capabilities()
        ),
        on_attach = function(client, bufnr)
          -- vim.notify(vim.inspect(client))
          -- disable to avoid treesitter/lsp highlighting conflicts
          client.server_capabilities.semanticTokensProvider = nil

                    -- stylua: ignore start
                    local map = vim.keymap.set
                    map("n", "gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, { buffer = bufnr, desc = "Go to definition" })
                    map("n", "gr", "<cmd>Telescope lsp_references<cr>", { buffer = bufnr, nowait = true, desc = "References" })
                    map("n", "gy", function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end, { buffer = bufnr, desc = "Go to type definition" })
                    map("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
                    map("n", "gI", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, { buffer = bufnr, desc = "Go to implementation" })
                    map("n", "gK", function() return vim.lsp.buf.signature_help() end, { buffer = bufnr, desc = "Signature help" })

                    map("n", "K", function() return vim.lsp.buf.hover() end, { buffer = bufnr, desc = "Hover" })

                    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })
                    map("n", "<leader>cl", "<cmd>LspInfo<cr>", { buffer = bufnr, desc = "LSP information" })
                    map("n", "<leader>cr", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename buffer" })

                    map("n", "<leader>cA", function() vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } }) end, { buffer = bufnr, desc = "Source action" })
                    map("n", "<leader>cR", function() Snacks.rename.rename_file() end, { buffer = bufnr, desc = "Rename file" })

                    map("n", "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", { buffer = bufnr, desc = "Symbols" })
                    map("n", "<leader>sS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { buffer = bufnr, desc = "Symbols (workspace)" })
          -- stylua: ignore end

          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          Snacks.toggle.inlay_hints():map "<leader>uh"

          if client.server_capabilities.codeLensProvider then
                        -- stylua: ignore start
                        map("n", "<leader>cC", vim.lsp.codelens.refresh, { buffer = bufnr, desc = "Refresh and display codelens" })
                        map({ "n", "v" }, "<leader>cc", vim.lsp.codelens.run, { buffer = bufnr, desc = "Run codelens" })
            -- stylua: ignore end

            vim.lsp.codelens.refresh()
            vim.api.nvim_create_autocmd(
              { "TextChanged", "InsertLeave", "CursorHold", "LspAttach", "BufEnter" },
              { buffer = bufnr, callback = vim.lsp.codelens.refresh }
            )
          end

          vim.b[bufnr].autoformat = true
                    -- stylua: ignore
                    map("n", "<leader>uf", function() vim.b[bufnr].autoformat = not vim.b[bufnr].autoformat end, { buffer = bufnr, desc = "Toggle autoformat (buffer)" })
        end,
      }

      require("lspconfig").neocmake.setup {
        init_options = {
          format = {
            enable = true,
          },
          lint = {
            enable = true,
          },
          scan_cmake_in_package = true,
          semantic_token = false,
        },
        capabilities = vim.tbl_deep_extend("force", {
          workspace = {
            didChangeWatchedFiles = { dynamicRegistration = true, relative_pattern_support = true },
          },
          textDocument = {
            completion = {
              completionItem = {
                snippetSupport = true,
              },
            },
          },
        }, vim.lsp.protocol.make_client_capabilities(), require("blink.cmp").get_lsp_capabilities()),
        on_attach = function(client, bufnr)
                    -- vim.notify(vim.inspect(client))

                    -- stylua: ignore start
                    local map = vim.keymap.set
                    map("n", "gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, { buffer = bufnr, desc = "Go to definition" })
                    map("n", "gr", "<cmd>Telescope lsp_references<cr>", { buffer = bufnr, nowait = true, desc = "References" })
                    map("n", "gy", function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end, { buffer = bufnr, desc = "Go to type definition" })
                    map("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
                    map("n", "gI", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, { buffer = bufnr, desc = "Go to implementation" })
                    map("n", "gK", function() return vim.lsp.buf.signature_help() end, { buffer = bufnr, desc = "Signature help" })

                    map("n", "K", function() return vim.lsp.buf.hover() end, { buffer = bufnr, desc = "Hover" })

                    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })
                    map("n", "<leader>cl", "<cmd>LspInfo<cr>", { buffer = bufnr, desc = "LSP information" })
                    map("n", "<leader>cr", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename buffer" })

                    map("n", "<leader>cA", function() vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } }) end, { buffer = bufnr, desc = "Source action" })
                    map("n", "<leader>cR", function() Snacks.rename.rename_file() end, { buffer = bufnr, desc = "Rename file" })

                    map("n", "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", { buffer = bufnr, desc = "Symbols" })
                    map("n", "<leader>sS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { buffer = bufnr, desc = "Symbols (workspace)" })
          -- stylua: ignore end

          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          Snacks.toggle.inlay_hints():map "<leader>uh"

          if client.server_capabilities.codeLensProvider then
                        -- stylua: ignore start
                        map("n", "<leader>cC", vim.lsp.codelens.refresh, { buffer = bufnr, desc = "Refresh and display codelens" })
                        map({ "n", "v" }, "<leader>cc", vim.lsp.codelens.run, { buffer = bufnr, desc = "Run codelens" })
            -- stylua: ignore end

            vim.lsp.codelens.refresh()
            vim.api.nvim_create_autocmd(
              { "TextChanged", "InsertLeave", "CursorHold", "LspAttach", "BufEnter" },
              { buffer = bufnr, callback = vim.lsp.codelens.refresh }
            )
          end

          vim.b[bufnr].autoformat = true
                    -- stylua: ignore
                    map("n", "<leader>uf", function() vim.b[bufnr].autoformat = not vim.b[bufnr].autoformat end, { buffer = bufnr, desc = "Toggle autoformat (buffer)" })
        end,
      }

      require("lspconfig").clangd.setup {
        capabilities = vim.tbl_deep_extend(
          "force",
          {},
          vim.lsp.protocol.make_client_capabilities(),
          require("blink.cmp").get_lsp_capabilities()
        ),
        on_attach = function(client, bufnr)
                    -- vim.notify(vim.inspect(client))

                    -- stylua: ignore start
                    local map = vim.keymap.set
                    map("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
                    map("n", "gr", vim.lsp.buf.references, { buffer = bufnr, nowait = true, desc = "References" })
                    map("n", "gy", vim.lsp.buf.type_definition, { buffer = bufnr, desc = "Go to type definition" })
                    map("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
                    map("n", "gI", vim.lsp.buf.implementation, { buffer = bufnr, desc = "Go to implementation" })
                    map("n", "gK", function() return vim.lsp.buf.signature_help() end, { buffer = bufnr, desc = "Signature help" })

                    map("n", "K", function() return vim.lsp.buf.hover() end, { buffer = bufnr, desc = "Hover" })

                    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })
                    -- map("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", { buffer = bufnr, desc = "Switch source/header" })
                    map("n", "<leader>ci", "<cmd>ClangdShowSymbolInfo<cr>", { buffer = bufnr, desc = "Symbol information" })
                    map("n", "<leader>cl", "<cmd>LspInfo<cr>", { buffer = bufnr, desc = "LSP information" })
                    map("n", "<leader>cr", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename buffer" })

                    map("n", "<leader>cA", function() vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } }) end, { buffer = bufnr, desc = "Source action" })

                    map("n", "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", { buffer = bufnr, desc = "Symbols" })
                    map("n", "<leader>sS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { buffer = bufnr, desc = "Symbols (workspace)" })
          -- stylua: ignore end

          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          Snacks.toggle.inlay_hints():map "<leader>uh"

          if client.server_capabilities.codeLensProvider then
                        -- stylua: ignore start
                        map("n", "<leader>cC", vim.lsp.codelens.refresh, { buffer = bufnr, desc = "Refresh and display codelens" })
                        map({ "n", "v" }, "<leader>cc", vim.lsp.codelens.run, { buffer = bufnr, desc = "Run codelens" })
            -- stylua: ignore end

            vim.lsp.codelens.refresh()
            vim.api.nvim_create_autocmd(
              { "TextChanged", "InsertLeave", "CursorHold", "LspAttach", "BufEnter" },
              { buffer = bufnr, callback = vim.lsp.codelens.refresh }
            )
          end

          vim.b[bufnr].autoformat = true
                    -- stylua: ignore
                    map("n", "<leader>uf", function() vim.b[bufnr].autoformat = not vim.b[bufnr].autoformat end, { buffer = bufnr, desc = "Toggle autoformat (buffer)" })
        end,
      }

      require("lspconfig").marksman.setup {
        capabilities = vim.tbl_deep_extend(
          "force",
          { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } },
          vim.lsp.protocol.make_client_capabilities(),
          require("blink.cmp").get_lsp_capabilities()
        ),
        on_attach = function(client, bufnr)
                    -- vim.notify(vim.inspect(client))

                    -- stylua: ignore start
                    local map = vim.keymap.set
                    map("n", "gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, { buffer = bufnr, desc = "Go to definition" })
                    map("n", "gr", "<cmd>Telescope lsp_references<cr>", { buffer = bufnr, nowait = true, desc = "References" })
                    map("n", "gy", function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end, { buffer = bufnr, desc = "Go to type definition" })
                    map("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
                    map("n", "gI", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, { buffer = bufnr, desc = "Go to implementation" })
                    map("n", "gK", function() return vim.lsp.buf.signature_help() end, { buffer = bufnr, desc = "Signature help" })

                    map("n", "K", function() return vim.lsp.buf.hover() end, { buffer = bufnr, desc = "Hover" })

                    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })
                    map("n", "<leader>cl", "<cmd>LspInfo<cr>", { buffer = bufnr, desc = "LSP information" })
                    map("n", "<leader>cr", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename buffer" })

                    map("n", "<leader>cA", function() vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } }) end, { buffer = bufnr, desc = "Source action" })
                    map("n", "<leader>cR", function() Snacks.rename.rename_file() end, { buffer = bufnr, desc = "Rename file" })

                    map("n", "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", { buffer = bufnr, desc = "Symbols" })
                    map("n", "<leader>sS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { buffer = bufnr, desc = "Symbols (workspace)" })

                    map("n", "<leader>mp", "<cmd>Markview splitToggle<cr>", { buffer = bufnr, desc = "Markdown preview" })
                    map("n", "<leader>mt", "<cmd>Markview Toggle<cr>", { buffer = bufnr, desc = "Markdown toggle" })
          -- stylua: ignore end

          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          Snacks.toggle.inlay_hints():map "<leader>uh"

          if client.server_capabilities.codeLensProvider then
                        -- stylua: ignore start
                        map("n", "<leader>cC", vim.lsp.codelens.refresh, { buffer = bufnr, desc = "Refresh and display codelens" })
                        map({ "n", "v" }, "<leader>cc", vim.lsp.codelens.run, { buffer = bufnr, desc = "Run codelens" })
            -- stylua: ignore end

            vim.lsp.codelens.refresh()
            vim.api.nvim_create_autocmd(
              { "TextChanged", "InsertLeave", "CursorHold", "LspAttach", "BufEnter" },
              { buffer = bufnr, callback = vim.lsp.codelens.refresh }
            )
          end

          vim.b[bufnr].autoformat = true
                    -- stylua: ignore
                    map("n", "<leader>uf", function() vim.b[bufnr].autoformat = not vim.b[bufnr].autoformat end, { buffer = bufnr, desc = "Toggle autoformat (buffer)" })
        end,
      }
    end,
  },

  -- Formatting support
  {
    "stevearc/conform.nvim",
    dependencies = "williamboman/mason.nvim", -- dependency updates RTP
    event = "BufWritePre",
    cmd = "ConformInfo",
    init = function()
      vim.o.formatexpr = "v:lua.require('conform').formatexpr()"
    end,
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format { async = true }
        end,
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        lua = { "stylua" },
        markdown = { "prettier" },
        rust = { "rustfmt" },
        toml = { "taplo" },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
      format_on_save = function(bufnr)
        -- set during lsp config
        if vim.b[bufnr].autoformat then
          return { time_ms = 3000, lsp_format = "fallback" }
        end
      end,
    },
  },

  -- Improved LSP for Neovim configuration
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- LSP progress
  {
    "j-hui/fidget.nvim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {
      notification = {
        window = { normal_hl = "", border_hl = "", border = "single", winblend = 0 },
      },
    },
  },

  -- Debugging (DAP)
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = "jay-babu/mason-nvim-dap.nvim",
    config = function()
      local icons = {
        Stopped = { "", "DiagnosticWarn", "DapStoppedLine" },
        Breakpoint = "󰯰",
        BreakpointCondition = "󰯳",
        BreakpointRejected = { "󰰠", "DiagnosticError" },
        LogPoint = "󰰎",
      }
      for name, sign in pairs(icons) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          ---@diagnostic disable-next-line
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end

      -- Setup DAP config by VsCode launch.json file
      local vscode = require "dap.ext.vscode"
      local json = require "plenary.json"
      ---@diagnostic disable-next-line
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end
    end,
  },

  -- Mason integration
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = "williamboman/mason.nvim",
    cmd = { "DapInstall", "DapUninstall" },
    opts = { automatic_installation = true, handlers = {}, ensure_installed = {} },
  },

  -- Virtual text for the debugger UI
  {
    "theHamsta/nvim-dap-virtual-text",
    lazy = true,
    opts = {},
  },

  -- UI for the debugger
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    keys = {
            -- stylua: ignore start
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Breakpoint condition" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
            { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
            { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to cursor" },
            { "<leader>dg", function() require("dap").goto_() end, desc = "Go to line (no execute)" },
            { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
            { "<leader>dj", function() require("dap").down() end, desc = "down" },
            { "<leader>dk", function() require("dap").up() end, desc = "up" },
            { "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
            { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
            { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
            { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
            { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
            { "<leader>ds", function() require("dap").session() end, desc = "Session" },
            { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
            { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
            { "<leader>dX", "<cmd>DapClearBreakpoints<cr>", desc = "Clear breakpoints" },
            { "<leader>du", function() require("dapui").toggle({}) end, desc = "Dap UI" },
            { "<leader>de", function() require("dapui").eval() end, desc = "Eval",  mode = { "n", "v" } },
            {
                "<leader>da",
                function()
                    require("dap").continue({
                        before = function(config)
                            local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
                            local args_str = type(args) == "table" and table.concat(args, " ") or args
                            config = vim.deepcopy(config)
                            config.args = function()
                                local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str))
                                ---@diagnostic disable-next-line
                                return require("dap.utils").splitstr(new_args)
                            end
                            return config
                        end,
                    })
                end,
                desc = "Run with args",
            },
      -- stylua: ignore end
    },
    opts = { controls = { enabled = false } },
    config = function(_, opts)
      local dap = require "dap"
      local dapui = require "dapui"
      dapui.setup(opts)
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open {}
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close {}
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close {}
      end
    end,
  },

  {
    "arnamak/stay-centered.nvim",
  },
  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

                -- stylua: ignore start
                map("n", "]h", function() if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end end, "Next hunk")
                map("n", "[h", function() if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end end, "Prev hunk")
                map("n", "]H", function() gs.nav_hunk("last") end, "Last hunk")
                map("n", "[H", function() gs.nav_hunk("first") end, "First hunk")
                map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
                map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
                map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
                map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
                map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
                map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview hunk inline")
                map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame line")
                map("n", "<leader>ghB", function() gs.blame() end, "Blame buffer")
                map("n", "<leader>ghd", gs.diffthis, "Diff this")
                map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff this ~")
                map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns select hunk")
                map("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", "Commits")
                map("n", "<leader>gs", "<cmd>Telescope git_status<cr>", "Status")
        -- stylua: ignore end
      end,
    },
  },

  -- Icon provider
  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {},
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  -- Session managment
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    init = function()
      vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
    end,
    keys = {
      { "<leader>qs", "<cmd>lua require('persistence').load()<cr>", desc = "Restore session" },
      { "<leader>qS", "<cmd>lua require('persistence').select()<cr>", desc = "Select session" },
      { "<leader>ql", "<cmd>lua require('persistence').load({last=true})<cr>", desc = "Restore last session" },
      { "<leader>qd", "<cmd>lua require('persistence').stop()<cr>", desc = "Don't save current session" },
    },
    opts = {},
  },

  -- Collection of small QoL plugins
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- Create some toggle mappings
          Snacks.toggle.animate():map "<leader>ua"
          Snacks.toggle.line_number():map "<leader>ul"
          Snacks.toggle.option("relativenumber", { name = "relative number" }):map "<leader>uL"
          Snacks.toggle.option("spell", { name = "spelling" }):map "<leader>us"
          Snacks.toggle.scroll():map "<leader>uS"
          Snacks.toggle.option("wrap", { name = "wrap" }):map "<leader>uw"
        end,
      })
    end,
    opts = {
      dashboard = {
        width = 44,
        preset = {
          header = [[




          ▀████▀▄▄              ▄█ 
                █▀    ▀▀▄▄▄▄▄    ▄▄▀▀█ 
        ▄        █          ▀▀▀▀▄  ▄▀  
       ▄▀ ▀▄      ▀▄              ▀▄▀  
      ▄▀    █     █▀   ▄█▀▄      ▄█    
      ▀▄     ▀▄  █     ▀██▀     ██▄█   
       ▀▄    ▄▀ █   ▄██▄   ▄  ▄  ▀▀ █  
        █  ▄▀  █    ▀██▀    ▀▀ ▀▀  ▄▀  
       █   █  █      ▄▄           ▄▀   

          ]],

          -- header = [[
          --
          --           █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ ▀ ▀▀▀█  █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ ▀ ▀▀▀▀█
          --           █ │░███▀█▀▀▀▀▀▓████▓▄ ▀▀▀▀ │░████▓▄   │▓████▓▄  █
          --           █ │▒███████  │▓███████     │▒███████  │▓███████ █
          --           █ │▓███████  │▓███████     │▓███████  │▓███████ █
          --           ▀ │▓███████  │▓███████     │▓███████  │▓███████ █
          --           ▀ │▓███████  │▓███████▄ ▄  │▓███████  │▓███████ █
          --           █ │▓███████                │▓███████   ▓███████ █▄▄▄
          --           █ │▓███████▀▀ ▀    ▀       │▓███████▀▀▀▓█▄█████▄ ▄ █
          --           █▄▄▄▄▄▄▄▄ ▀ █▀▀▀▀▀▀▀▀▀▀▀▀█▄▄▄▄ ▄ ▄▄▄▄▄▄▄▄▄▄▄ ▄ ▄▄▄▄█
          --                   █ ▀ █
          --               ▀▀▀▀▀                                                           ]],
          keys = {
            -- stylua: ignore start
            -- { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            -- { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            -- -- { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            -- { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            -- -- { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            -- { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            -- -- { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            -- -- { icon = "󱌢 ", key = "m", desc = "Mason", action = ":Mason" },
            -- { icon = " ", key = "q", desc = "Quit", action = ":qa" },
            -- stylua: ignore end
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 2 },
          {
            padding = 1,
            title = [[
                        ▀ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ ▀ ▀▀▀▀▀▀▀▀▀▀▀▀▀ ▀                        
                                                              n e o v i m                           ]],
          },
          { section = "startup" },
        },
      },
      styles = {
        notification = { border = "single" },
        notification_history = { border = "single" },
      },
      input = { enabled = true },
      notifier = {
        enabled = true,
        icons = {
          error = "󰯸 ",
          warn = "󰰮 ",
          info = "󰰄 ",
          debug = "󰯵 ",
          trace = "󰰥 ",
        },
      },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
    },
    keys = {
      { "<leader>bd", "<cmd>lua Snacks.bufdelete()<cr>", desc = "Delete buffer" },
      { "<leader>n", "<cmd>lua Snacks.notifier.show_history()<cr>", desc = "Notification history" },
      { "<leader>un", "<cmd>lua Snacks.notifier.hide()<cr>", desc = "Dismiss all notifications" },
    },
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },
  {
    "Civitasv/cmake-tools.nvim",
    lazy = true,
    init = function()
      local loaded = false
      local function check()
        local cwd = vim.uv.cwd()
        if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
          require("lazy").load { plugins = { "cmake-tools.nvim" } }
          loaded = true
        end
      end
      check()
      vim.api.nvim_create_autocmd("DirChanged", {
        callback = function()
          if not loaded then
            check()
          end
        end,
      })
    end,
    opts = {
      cmake_command = "cmake", -- this is used to specify cmake command path
      ctest_command = "ctest", -- this is used to specify ctest command path
      cmake_use_preset = true,
      cmake_regenerate_on_save = true, -- auto generate when save CMakeLists.txt
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" }, -- this will be passed when invoke `CMakeGenerate`
      cmake_build_options = {}, -- this will be passed when invoke `CMakeBuild`
      -- support macro expansion:
      --       ${kit}
      --       ${kitGenerator}
      --       ${variant:xx}
      -- cmake_build_directory = function()
      --   if osys.iswin32 then
      --     return "out\\${variant:buildType}"
      --   end
      --   return "out/${variant:buildType}"
      -- end, -- this is used to specify generate directory for cmake, allows macro expansion, can be a string or a function returning the string, relative to cwd.
      cmake_soft_link_compile_commands = true, -- this will automatically make a soft link from compile commands file to project root dir
      cmake_compile_commands_from_lsp = false, -- this will automatically set compile commands file location using lsp, to use it, please set `cmake_soft_link_compile_commands` to false
      cmake_kits_path = nil, -- this is used to specify global cmake kits path, see CMakeKits for detailed usage
      cmake_variants_message = {
        short = { show = true }, -- whether to show short message
        long = { show = true, max_length = 40 }, -- whether to show long message
      },
      cmake_dap_configuration = { -- debug settings for cmake
        name = "cpp",
        type = "codelldb",
        request = "launch",
        stopOnEntry = false,
        runInTerminal = true,
        console = "integratedTerminal",
      },
      cmake_executor = { -- executor to use
        name = "quickfix", -- name of the executor
        opts = {}, -- the options the executor will get, possible values depend on the executor type. See `default_opts` for possible values.
        default_opts = { -- a list of default and possible values for executors
          quickfix = {
            show = "always", -- "always", "only_on_error"
            position = "belowright", -- "vertical", "horizontal", "leftabove", "aboveleft", "rightbelow", "belowright", "topleft", "botright", use `:h vertical` for example to see help on them
            size = 10,
            encoding = "utf-8", -- if encoding is not "utf-8", it will be converted to "utf-8" using `vim.fn.iconv`
            auto_close_when_success = true, -- typically, you can use it with the "always" option; it will auto-close the quickfix buffer if the execution is successful.
          },
          toggleterm = {
            direction = "float", -- 'vertical' | 'horizontal' | 'tab' | 'float'
            close_on_exit = false, -- whether close the terminal when exit
            auto_scroll = true, -- whether auto scroll to the bottom
            singleton = true, -- single instance, autocloses the opened one, if present
          },
          overseer = {
            new_task_opts = {
              strategy = {
                "toggleterm",
                direction = "horizontal",
                auto_scroll = true,
                quit_on_exit = "success",
              },
            }, -- options to pass into the `overseer.new_task` command
            on_new_task = function(task)
              require("overseer").open { enter = false, direction = "right" }
            end, -- a function that gets overseer.Task when it is created, before calling `task:start`
          },
          terminal = {
            name = "Main Terminal",
            prefix_name = "[CMakeTools]: ", -- This must be included and must be unique, otherwise the terminals will not work. Do not use a simple spacebar " ", or any generic name
            split_direction = "horizontal", -- "horizontal", "vertical"
            split_size = 11,

            -- Window handling
            single_terminal_per_instance = true, -- Single viewport, multiple windows
            single_terminal_per_tab = true, -- Single viewport per tab
            keep_terminal_static_location = true, -- Static location of the viewport if avialable
            auto_resize = true, -- Resize the terminal if it already exists

            -- Running Tasks
            start_insert = false, -- If you want to enter terminal with :startinsert upon using :CMakeRun
            focus = false, -- Focus on terminal when cmake task is launched.
            do_not_add_newline = false, -- Do not hit enter on the command inserted when using :CMakeRun, allowing a chance to review or modify the command before hitting enter.
          }, -- terminal executor uses the values in cmake_terminal
        },
      },
      cmake_runner = { -- runner to use
        name = "terminal", -- name of the runner
        opts = {}, -- the options the runner will get, possible values depend on the runner type. See `default_opts` for possible values.
        default_opts = { -- a list of default and possible values for runners
          quickfix = {
            show = "always", -- "always", "only_on_error"
            position = "belowright", -- "bottom", "top"
            size = 10,
            encoding = "utf-8",
            auto_close_when_success = true, -- typically, you can use it with the "always" option; it will auto-close the quickfix buffer if the execution is successful.
          },
          toggleterm = {
            direction = "float", -- 'vertical' | 'horizontal' | 'tab' | 'float'
            close_on_exit = false, -- whether close the terminal when exit
            auto_scroll = true, -- whether auto scroll to the bottom
            singleton = true, -- single instance, autocloses the opened one, if present
          },
          overseer = {
            new_task_opts = {
              strategy = {
                "toggleterm",
                direction = "horizontal",
                autos_croll = true,
                quit_on_exit = "success",
              },
            }, -- options to pass into the `overseer.new_task` command
            on_new_task = function(task) end, -- a function that gets overseer.Task when it is created, before calling `task:start`
          },
          terminal = {
            name = "Main Terminal",
            prefix_name = "[CMakeTools]: ", -- This must be included and must be unique, otherwise the terminals will not work. Do not use a simple spacebar " ", or any generic name
            split_direction = "horizontal", -- "horizontal", "vertical"
            split_size = 11,

            -- Window handling
            single_terminal_per_instance = true, -- Single viewport, multiple windows
            single_terminal_per_tab = true, -- Single viewport per tab
            keep_terminal_static_location = true, -- Static location of the viewport if avialable
            auto_resize = true, -- Resize the terminal if it already exists

            -- Running Tasks
            start_insert = false, -- If you want to enter terminal with :startinsert upon using :CMakeRun
            focus = false, -- Focus on terminal when cmake task is launched.
            do_not_add_newline = false, -- Do not hit enter on the command inserted when using :CMakeRun, allowing a chance to review or modify the command before hitting enter.
          },
        },
      },
      cmake_notifications = {
        runner = { enabled = true },
        executor = { enabled = true },
        spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }, -- icons used for progress display
        refresh_rate_ms = 100, -- how often to iterate icons
      },
      cmake_virtual_text_support = true, -- Show the target related to current file using virtual text (at right corner)
    },
    config = function(_, opts)
      require("cmake-tools").setup(opts)
    end,
  },
  -- {
  --   "sphamba/smear-cursor.nvim",
  --   lazy = false,
  --
  --   -- opts = {
  --   --   -- Smear cursor when switching buffers or windows.
  --   --   smear_between_buffers = true,
  --   --
  --   --   -- Smear cursor when moving within line or to neighbor lines.
  --   --   -- Use min_horizontal_distance_smear and min_vertical_distance_smear for finer control
  --   --   smear_between_neighbor_lines = true,
  --   --
  --   --   -- Draw the smear in buffer space instead of screen space when scrolling
  --   --   scroll_buffer_space = true,
  --   --
  --   --   -- Set to true if your font supports legacy computing symbols (block unicode symbols).
  --   --   -- Smears will blend better on all backgrounds.
  --   --   legacy_computing_symbols_support = false,
  --   --
  --   --   -- Smear cursor in insert mode.
  --   --   -- See also vertical_bar_cursor_insert_mode and distance_stop_animating_vertical_bar.
  --   --   smear_insert_mode = true,
  --   -- },
  -- },
}

return plugins
