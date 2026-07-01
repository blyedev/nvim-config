vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

vim.pack.add({
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/folke/lazydev.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  {
    src = "https://github.com/saghen/blink.cmp",
    version = vim.version.range("1"),
  },
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/j-hui/fidget.nvim",
  "https://github.com/mfussenegger/nvim-lint",
})

vim.cmd.colorscheme("tokyonight-night")
vim.o.signcolumn = "yes"

vim.diagnostic.config({
  virtual_text = {
    source = true,
  },
  float = {
    source = true,
  },
})

require("mason").setup()

local mr = require("mason-registry")
local function ensure_installed()
  local package = mr.get_package("tflint")
  if not package:is_installed() then
    package:install()
  end
end

if mr.refresh then
  mr.refresh(ensure_installed)
else
  ensure_installed()
end

require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "rust_analyzer", "terraformls" },
  automatic_enable = false,
})

require("which-key").setup({})

require("fzf-lua").setup({})
require("fzf-lua").register_ui_select()

local fzf = require("fzf-lua")

vim.keymap.set("n", "<leader>sf", fzf.files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sg", fzf.live_grep, { desc = "[S]earch by [G]rep" })

require("blink.cmp").setup({
  keymap = { preset = "default" },
  appearance = {
    nerd_font_variant = "mono",
  },
  sources = {
    default = { "lazydev", "lsp", "path" },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
    },
  },
  fuzzy = {
    implementation = "lua",
  },
  completion = {
    menu = {
      draw = {
        columns = { { "kind_icon" }, { "label", "label_description", "source_name", gap = 1 } },
      },
    },
    ghost_text = { enabled = true },
  },
  signature = { enabled = true },
})

require("fidget").setup({})

local lint = require("lint")

lint.linters_by_ft = {
  tf = { "tflint" },
  terraform = { "tflint" },
  ["terraform-vars"] = { "tflint" },
}

local function debounce(ms, fn)
  local timer = vim.uv.new_timer()

  return function(...)
    local argv = { ... }

    timer:start(ms, 0, function()
      timer:stop()
      vim.schedule(function()
        fn(unpack(argv))
      end)
    end)
  end
end

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
  callback = debounce(100, function()
    lint.try_lint()
  end),
})

require("gitsigns").setup({
  signs = {
    add = { text = "┃" },
    change = { text = "┃" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "┆" },
  },
})

require("lazydev").setup({
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  },
})

local lsp_capabilities = require("blink.cmp").get_lsp_capabilities()

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("native-lsp-pickers", { clear = true }),
  callback = function(ev)
    local wk = require("which-key")

    vim.keymap.set({ "n", "x" }, "gra", fzf.lsp_code_actions, {
      buffer = ev.buf,
      desc = "Code Action",
    })
    vim.keymap.set("n", "gri", fzf.lsp_implementations, {
      buffer = ev.buf,
      desc = "Go to Implementation",
    })
    vim.keymap.set("n", "grr", fzf.lsp_references, {
      buffer = ev.buf,
      desc = "Go to References",
    })
    vim.keymap.set("n", "grt", fzf.lsp_typedefs, {
      buffer = ev.buf,
      desc = "Go to Type Definition",
    })
    vim.keymap.set("n", "gO", fzf.lsp_document_symbols, {
      buffer = ev.buf,
      desc = "Document Symbols",
    })

    wk.add({
      { "gra", desc = "Code Action", mode = { "n", "x" }, buffer = ev.buf },
      { "gri", desc = "Go to Implementation", buffer = ev.buf },
      { "grn", desc = "Rename", buffer = ev.buf },
      { "grr", desc = "Go to References", buffer = ev.buf },
      { "grt", desc = "Go to Type Definition", buffer = ev.buf },
      { "grx", desc = "Run CodeLens", buffer = ev.buf },
      { "gO", desc = "Document Symbols", buffer = ev.buf },
      { "gx", desc = "Open Link", buffer = ev.buf },
      { "K", desc = "Hover", buffer = ev.buf },
      { "<C-s>", desc = "Signature Help", mode = "i", buffer = ev.buf },
    })
  end,
})

vim.lsp.config("lua_ls", {
  capabilities = lsp_capabilities,
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

vim.lsp.config("rust_analyzer", {
  capabilities = lsp_capabilities,
})

vim.lsp.config("terraformls", {
  capabilities = lsp_capabilities,
  filetypes = { "tf", "terraform", "terraform-vars" },
})

vim.lsp.enable("lua_ls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("terraformls")
