---@type LazySpec[]
return {
  {
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
        ruff_lsp = {},
        angularls = {},
        eslint = {},
        cssls = {},
      },
      setup = {},
      on_attach = function(client, bufnr)
        local map = function(keys, func, desc, mode)
          mode = mode or "n"
          vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end

        map("gd", require("telescope.builtin").lsp_definitions, "[G]o to [D]efinition")
        map("gr", require("telescope.builtin").lsp_references, "[G]o to [R]eferences")
        map("gI", require("telescope.builtin").lsp_implementations, "[G]o to [I]mplementation")
        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
        map("gD", vim.lsp.buf.declaration, "[G]o to [D]eclaration")

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
        local server_options = vim.tbl_deep_extend("force", {
          capabilities = capabilities,
          on_attach = opts.on_attach,
        }, server_opts)

        if opts.setup[server_name] then
          if opts.setup[server_name](server_name, server_options) then
            goto continue
          end
        elseif opts.setup["*"] then
          if opts.setup["*"](server_name, server_options) then
            goto continue
          end
        end

        lspconfig[server_name].setup(server_options)
        ::continue::
      end
    end,
  },

  {
    "williamboman/mason.nvim",
    cmd = { "Mason" },
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "stylua",
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

  {
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
      },
    },
  },

  {
    "j-hui/fidget.nvim",
    event = { "LspAttach" },
    opts = {},
  },
}
