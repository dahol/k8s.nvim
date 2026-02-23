local M = {}

-- Setup function for the k8s.nvim plugin
function M.setup()
  -- Set up autocommands for YAML files to enable completion
  -- Using separate events for better compatibility with older Neovim versions
  vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    pattern = "*.yaml",
    callback = function()
      if vim.api.nvim_buf_get_option(0, "buftype") == "" then
        -- Enable omnifunc for Kubernetes YAML completions
        vim.api.nvim_buf_set_option(0, "omnifunc", "v:lua.k8s_complete")
      end
    end,
  })
end

return M