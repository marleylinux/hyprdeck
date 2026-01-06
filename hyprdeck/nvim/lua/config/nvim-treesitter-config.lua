-- ~/.config/nvim/lua/config/nvim-treesitter-config.lua
require("nvim-treesitter.configs").setup({
    ensure_installed = "maintained",  -- Automatically install maintained parsers
    highlight = {
        enable = true,  -- Enable Treesitter-based syntax highlighting
        additional_vim_regex_highlighting = false,
    },
})

