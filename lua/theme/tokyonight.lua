-- lua/theme/tokyonight.lua
-- { "folke/tokyonight.nvim", config = function() vim.cmd.colorscheme "tokyonight" end },
return {
  "folke/tokyonight.nvim",
  lazy = false, -- Load on startup
  priority = 1000, -- Load before other plugins
  config = function()
    vim.o.background = "dark" -- or "light" if you prefer
    require("tokyonight").setup({
      style = "night", -- "storm", "moon", "night", or "day"
      transparent = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
      },
    })
    vim.cmd.colorscheme("tokyonight")
  end,
}
