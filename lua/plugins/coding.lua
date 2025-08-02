---@type LazySpec
return {
  { -- Provide default configurations to LSP's
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
              },
              diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim" },
              },
              workspace = {
                checkThirdParty = false,
                -- library = {
                --   vim.env.VIMRUNTIME
                --   -- Depending on the usage, you might want to add additional paths here.
                --   -- "${3rd}/luv/library"
                --   -- "${3rd}/busted/library",
                -- },
                -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                library = vim.api.nvim_get_runtime_file("", true),
              },
              format = { enable = false },
              telemetry = { enable = false },
            },
          },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "off", -- Disable type checking in favour of ruff and mypy
              },
            },
          },
        },
        ruff = {},
        taplo = {},
        gopls = {},
        bashls = {},
        rust_analyzer = {},
        vue_ls = {},
        vtsls = {
          settings = {
            vtsls = {
              tsserver = {
                globalPlugins = {
                  {
                    name = "@vue/typescript-plugin",
                    location = vim.fn.stdpath("data")
                      .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
                    languages = { "vue" },
                    configNamespace = "typescript",
                  },
                },
              },
            },
          },
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        },
        angularls = {},
        eslint = {},
        cssls = {},
        ansiblels = {},
        tofu_ls = {
          filetypes = { "terraform", "terraform-vars" },
          get_language_id = function(_, filetype)
            if filetype == "terraform" then
              return "opentofu"
            end
            if filetype == "terraform-vars" then
              return "opentofu-vars"
            end
            return filetype
          end,
        },
        marksman = {},
      },
      on_attach = function(client, bufnr)
        local wk = require("which-key")

        local map = function(keys, func, desc, mode)
          mode = mode or "n"
          wk.add({
            {
              keys,
              func,
              desc = "LSP: " .. desc,
              mode = mode,
              buffer = bufnr,
            },
          })
        end
        local fzf = require("fzf-lua")

        map("gd", fzf.lsp_definitions, "[G]oto [D]efinition")
        map("gr", fzf.lsp_references, "[G]oto [R]eferences")
        map("gI", fzf.lsp_implementations, "[G]oto [I]mplementation")
        map("<leader>D", fzf.lsp_typedefs, "Type [D]efinition")
        map("<leader>ds", fzf.lsp_document_symbols, "[D]ocument [S]ymbols")
        map("<leader>ws", fzf.lsp_live_workspace_symbols, "[W]orkspace [S]ymbols (live)")

        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        -- Highligh keyword
        if client.supports_method("textDocument/documentHighlight") then
          local highlight_group = vim.api.nvim_create_augroup("LSPDocumentHighlight", { clear = true })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = highlight_group,
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            group = highlight_group,
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("LSPDetachCleanup", { clear = true }),
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds({ group = highlight_group, buffer = bufnr })
            end,
          })
        end
      end,
    },
    config = function(_, opts)
      require("mason-lspconfig").setup({
        automatic_installation = true,
      })

      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        on_attach = opts.on_attach,
      })

      for server_name, server_opts in pairs(opts.servers) do
        vim.lsp.config(server_name, server_opts)
      end

      local names = {}
      for name in pairs(opts.servers) do
        table.insert(names, name)
      end
      vim.lsp.enable(names)
    end,
  },

  { -- Tool (lsp, formatter, linter, debugger) installing
    "williamboman/mason.nvim",
    cmd = { "Mason" },
    keys = { { "<leader>mm", "<cmd>Mason<cr>", desc = "Open Mason" } },
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "stylua",
        "mypy",
        "prettier",
        "stylelint",
        "markdownlint",
        "xmlformatter",
        "ansible-lint",
        "hclfmt",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },

  { -- Formatter
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "[F]ormat buffer",
      },
    },

    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      notify_on_error = false,
      notify_no_formatters = true,
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format" },
        go = { "gofmt" },

        -- Web dev
        typescript = { "prettier" },
        javascript = { "prettier" },
        vue = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },

        -- Markup
        markdown = { "markdownlint", "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        xml = { "xmlformat" },
        svg = { "xmlformat" },
        hcl = { "hcl" },
        ["_"] = { "prettier" },
      },
    },
  },

  { -- Pretty notifications for processes
    "j-hui/fidget.nvim",
    event = { "LspAttach" },
    opts = {},
  },
}
