-- Set leader key to space before loading lazy.nvim
vim.g.mapleader = " "

-- Bootstrap Lazy.nvim if it's not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("plugins")

-- General settings
vim.opt.number = true  -- Show line numbers

-- Set Space + E to toggle NvimTree
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Keybinding to manually trigger COQ completion
vim.keymap.set("i", "<leader>s", function()
  vim.cmd("COQnow")  -- Start COQ completion mode in insert mode
end, { noremap = true, silent = true, desc = "Trigger COQ completion" })
