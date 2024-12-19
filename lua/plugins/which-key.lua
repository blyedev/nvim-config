---@type LazySpec
return {
  "folke/which-key.nvim",
  opts = {
    spec = {
      { "<leader>c", group = "[C]ode", mode = { "n", "x" } },
      { "<leader>d", group = "[D]ocument" },
      { "<leader>r", group = "[R]ename" },
      { "<leader>s", group = "[S]earch" },
      { "<leader>w", group = "[W]orkspace" },
      { "<leader>m", group = "[M]eta", { "<leader>ml", "<cmd>Lazy<CR>", desc = "Open [L]azy" } },
      { "<leader>z", group = "[Z]en", { "<leader>zt", "<cmd>Twilight<CR>", desc = "Toggle [T]wilight" } },
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
}
