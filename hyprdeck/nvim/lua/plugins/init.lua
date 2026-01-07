-- ~/.config/nvim/lua/plugins/init.lua

require("lazy").setup({
  { import = "plugins.nvim-tree" },    -- Load nvim-tree
  { import = "plugins.catppuccin" },   -- Load catppuccin theme
  { import = "plugins.treesitter" },   -- Load nvim-treesitter
  { import = "plugins.coq" },          -- Load coq_nvim
})

