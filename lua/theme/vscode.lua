-- lua/theme/vscode.lua

return {
  "Mofiqul/vscode.nvim",
  lazy = false, -- Load during startup
  priority = 1000, -- Ensure it loads before other plugins

  config = function()
    -- Set background before applying the theme
    vim.o.background = 'dark' -- or 'light'

    -- Setup the theme
    require("vscode").setup({
      -- Alternatively set style in setup
      -- style = 'light',
  
      -- Enable transparent background
      transparent = true,

      -- Enable italic comment
      italic_comments = true,

      -- Underline `@markup.link.*` variants
      underline_links = true,

      -- Disable nvim-tree background color
      disable_nvimtree_bg = true,

      -- Apply theme colors to terminal
      terminal_colors = true,

      -- Override colors (see ./lua/vscode/colors.lua)
      color_overrides = {
        vscLineNumber = '#FFFFFF',
      },
    })

    -- Now that the theme is initialized, get the colors
    local c = require('vscode.colors').get_colors()

    -- Override highlight groups (see ./lua/vscode/theme.lua)
    -- this supports the same val table as vim.api.nvim_set_hl
    -- use colors from this colorscheme by requiring vscode.colors!
    vim.api.nvim_set_hl(0, "Cursor", { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true })

    -- Apply the colorscheme
    vim.cmd("colorscheme vscode")
  end,
}

