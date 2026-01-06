-- ~/.config/nvim/lua/plugins/coq.lua

return {
  -- Main coq_nvim plugin
  {
    "ms-jpq/coq_nvim",
    branch = "coq",
    run = ":COQdeps",
    config = function()
      -- Enable auto start
      vim.g.coq_settings = { auto_start = "shut-up" }
    end,
  },
  -- Additional sources for coq_nvim (optional but recommended)
  { "ms-jpq/coq.artifacts", branch = "artifacts" },
  { "ms-jpq/coq.thirdparty", branch = "3p" },
}

