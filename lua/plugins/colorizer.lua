---@type LazySpec
return {
  "norcalli/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    css = { rgb_fn = true, hsl_fn = true },
    vue = { rgb_fn = true, hsl_fn = true },
  },
}
