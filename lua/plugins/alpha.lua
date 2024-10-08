---@type LazySpec
return {
  "goolord/alpha-nvim",
  dependencies = {
    "echasnovski/mini.icons",
  },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")
    dashboard.section.header.val = require("plugins.ascii.matrix").wake_up_multiline

    dashboard.section.buttons.val = {
      dashboard.button("f", "  Find file", "<cmd>Telescope find_files<cr>"),
      dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<cr>"),
      dashboard.button("g", "  Find text", "<cmd>Telescope live_grep<cr>"),
      dashboard.button("c", "  Config", "<cmd>Telescope find_files cwd=" .. vim.fn.stdpath("config") .. "<cr>"),
      dashboard.button("l", "󰒲  Lazy", "<cmd>Lazy<cr>"),
      dashboard.button("q", "  Quit", "<cmd>qa<cr>"),
    }

    dashboard.opts.layout[1].val = 8

    local handle = io.popen("fortune")
    local fortune = handle:read("*a")
    handle:close()
    dashboard.section.footer.val = fortune

    dashboard.config.opts.noautocmd = true

    vim.cmd([[autocmd User AlphaReady echo 'ready']])

    alpha.setup(dashboard.config)
  end,
}