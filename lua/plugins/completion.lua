---@diagnostic disable: missing-fields
---@type LazySpec
return {
  {
    "saghen/blink.cmp",
    -- use a release tag to download pre-built binaries
    version = "v0.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = "default" },
      appearance = {
        nerd_font_variant = "mono",
      },
      -- default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, via `opts_extend`
      sources = {
        completion = {
          enabled_providers = { "lsp", "path" },
        },
      },

      completion = {
        menu = {
          draw = {
            columns = { { "kind_icon" }, { "label", "label_description", "source_name", gap = 1 } },
          },
        },
        ghost_text = { enabled = true },
      },

      -- experimental signature help support
      signature = { enabled = true }
    },
  },
}
