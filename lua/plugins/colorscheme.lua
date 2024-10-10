---@type LazySpec
return {
  -- {
  --   "folke/tokyonight.nvim",
  --   enabled = false,
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.cmd([[colorscheme tokyonight-night]])
  --   end,
  -- },

  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme rose-pine-dawn]])
    end,
  },
}
