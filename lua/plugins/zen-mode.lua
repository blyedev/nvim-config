---@type LazySpec
return {
  "folke/zen-mode.nvim",
  dependencies = {
    "folke/twilight.nvim",
  },
  keys = { { "<leader>zm", "<cmd>ZenMode<cr>", desc = "Toggle [Z]en[M]ode" } },
  ---@module 'zen-mode'
  ---@type ZenOptions
  opts = {
    plugins = {
      tmux = { enabled = true },
    },
  },
}
