---@type LazySpec
return {
  "goolord/alpha-nvim",
  dependencies = {
    "echasnovski/mini.icons",
  },
  opts = function()
    local button = require("alpha.themes.dashboard").button
    return {
      layout = {
        { type = "padding", val = 4 },
        {
          type = "text",
          val = require("plugins.ascii.creation_of_adam").hands_no_bg,
          opts = {
            position = "center",
            hl = "Type",
            -- wrap = "overflow";
          },
        },
        { type = "padding", val = 4 },
        {
          type = "group",
          val = {
            button("N", "  New file", "<cmd>ene <BAR> startinsert<cr>"),
            button(".", "  Recent files", "<cmd>Telescope oldfiles<cr>"),
            button("f", "  Find file", "<cmd>Telescope find_files<cr>"),
            button("g", "  Find text", "<cmd>Telescope live_grep<cr>"),
            button("n", "  Neovim config", "<cmd>Telescope find_files cwd=" .. vim.fn.stdpath("config") .. "<cr>"),
            button("l", "󰒲  Lazy", "<cmd>Lazy<cr>"),
            button("q", "  Quit", "<cmd>qa<cr>"),
          },
          opts = {
            spacing = 1,
          },
        },
        { type = "padding", val = 2 },
        {
          type = "text",
          val = {
            "“ A man paints with his brains and not with",
            "his hands. ”                               ",
            "                             - Michelangelo",
          },
          opts = {
            position = "center",
            hl = "Number",
          },
        },
      },
      opts = { margin = 5, noautocmd = true },
    }
  end,
}
