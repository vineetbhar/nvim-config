-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

-- Put lazy into runtime path of neovim.
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    -- { import = "plugins" },
   
    -- Set the theme here
    { import = "theme.vscode" },
    -- { import = "theme.tokyonight" },    
    
    -- Add your copilot settings here
    -- { import = "plugins/copilot" },
    { import = "plugins/copilot-vim" },
    -- { import = "plugins/copilotchat" },
    { import = "plugins/copilotchat-v2" },

    -- Import functional settings here
    { import = "plugins/whichkey" }, -- Import whichkey
    { import = "plugins/telescope" }, -- Fuzzy finder
    { import = "plugins/nvim-dap" }, -- Debugging Support
    { "neovim/nvim-lspconfig" }, -- LSP configuration
    { "nvim-tree/nvim-web-devicons", opts = {} }, -- File icons
    { "nvim-tree/nvim-tree.lua" }, -- File explorer
    { "nvim-treesitter/nvim-treesitter", build=":TSUpdate" }, -- Syntax Highlighting
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
