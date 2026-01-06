-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",  -- Automatically update treesitter parsers
  config = function()
    require("nvim-treesitter.configs").setup({
      highlight = {
        enable = true,  -- Enable syntax highlighting
        additional_vim_regex_highlighting = false,
      },
      ensure_installed = { "lua", "python", "javascript", "html", "css" },  -- Add languages as needed
    })
  end,
}

