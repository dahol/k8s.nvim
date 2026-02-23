local M = {}

-- Get the current line for completion
local function get_current_line()
  local line = vim.api.nvim_get_current_line()
  return line
end

-- Simple completion function for Kubernetes objects
local function k8s_complete(findstart, base)
  if findstart then
    -- Find the start of the word to complete
    local line = get_current_line()
    local pos = vim.api.nvim_cursor_get()[2]
    
    -- Look backwards for a word boundary
    while pos > 0 and string.match(line:sub(pos, pos), "%w") do
      pos = pos - 1
    end
    
    return pos + 1
  else
    -- Return completion items
    local k8s_objects = {
      "apiVersion",
      "kind",
      "metadata",
      "spec",
      "status",
      "name",
      "namespace",
      "labels",
      "annotations",
      "selector",
      "replicas",
      "template",
      "containers",
      "image",
      "ports",
      "env",
      "volumeMounts",
      "volumes",
      "configMaps",
      "secrets",
      "serviceAccountName",
      "resources",
      "requests",
      "limits",
      "hostAliases",
      "nodeSelector",
      "tolerations",
      "affinity"
    }
    
    local matches = {}
    for _, obj in ipairs(k8s_objects) do
      if string.sub(obj, 1, #base) == base then
        table.insert(matches, obj)
      end
    end
    
    return matches
  end
end

-- Setup function for the completion module
function M.setup()
  -- Register the completion function globally for use in Neovim
  vim.api.nvim_set_var("k8s_complete", k8s_complete)
  
  -- Set up autocommands for YAML files
  vim.api.nvim_create_autocmd("BufNewFile,BufRead", {
    pattern = "*.yaml",
    callback = function()
      if vim.api.nvim_buf_get_option(0, "buftype") == "" then
        vim.api.nvim_buf_set_option(0, "omnifunc", "v:lua.k8s_complete")
      end
    end,
  })
end

return M