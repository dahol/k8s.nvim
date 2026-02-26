local M = {}
local picker = require("k8s.picker")

function M.setup(opts)
  opts = opts or {}
  local key = (opts.keymap ~= nil) and opts.keymap or "<leader>k"

  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern  = "*.yaml",
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.api.nvim_buf_get_option(bufnr, "buftype") ~= "" then return end

      vim.keymap.set("n", key, function()
        picker.open(vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win())
      end, {
        buffer  = bufnr,
        noremap = true,
        silent  = true,
        desc    = "Open k8s resource picker",
      })
    end,
  })
end

return M
