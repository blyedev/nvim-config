---@type LazySpec
return {
  { -- Provide default configurations to LSP's
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    opts = {
      capabilities = {},
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
        pyright = {},
        ruff = {},
        ts_ls = {
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        },
        volar = {},
        -- angularls = {},
        eslint = {},
        cssls = {},
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

        -- Keymaps
        map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
        map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
        map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
        map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
        map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
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
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities(),
        opts.capabilities or {}
      )

      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(opts.servers),
      })

      local lspconfig = require("lspconfig")
      for server_name, server_opts in pairs(opts.servers) do
        local additional_opts = {}
        if server_name == "ts_ls" then
          additional_opts.init_options = {
            plugins = {
              {
                name = "@vue/typescript-plugin",
                location = require("mason-registry").get_package("vue-language-server"):get_install_path()
                  .. "/node_modules/@vue/language-server",
                languages = { "vue" },
              },
            },
          }
        end

        local server_options = vim.tbl_deep_extend("force", {
          capabilities = capabilities,
          on_attach = opts.on_attach,
        }, server_opts, additional_opts)

        lspconfig[server_name].setup(server_options)
      end
    end,
  },

  { -- Tool (lsp, formatter, linter, debugger) installing
    "williamboman/mason.nvim",
    cmd = { "Mason" },
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "stylua",
        "markdownlint",
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
    opts = {
      notify_on_error = false,
      formatters_by_ft = {
        lua = { "stylua" },
        markdown = { "markdownlint" },
      },
    },
  },

  { -- Pretty notifications for processes
    "j-hui/fidget.nvim",
    event = { "LspAttach" },
    opts = {},
  },
}
