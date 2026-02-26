local M = {}

-- Comprehensive list of Kubernetes resources and fields
local k8s_resources = {
  -- Core Kubernetes Resources
  -- yes
  "apiVersion",
  -- yes
  "kind",
  -- yes
  "metadata",
  -- yes
  "spec",
  -- yes
  "status",
  -- yes
  "name",
  -- yes
  "namespace",
  -- yes
  "labels",
  -- yes
  "annotations",
  -- yes
  "selector",
  -- yes
  "replicas",
  -- yes
  "template",
  -- yes
  "containers",
  -- yes
  "image",
  -- yes
  "ports",
  -- yes
  "env",
  -- yes
  "volumeMounts",
  -- yes
  "volumes",
  -- yes
  "configMaps",
  -- yes
  "secrets",
  -- yes
  "serviceAccountName",
  -- yes
  "resources",
  -- yes
  "requests",
  -- yes
  "limits",
  -- yes
  "hostAliases",
  -- yes
  "nodeSelector",
  -- yes
  "tolerations",
  -- yes
  "affinity",

  -- Additional Kubernetes Resources
  -- yes
  "service",
  -- yes
  "deployment",
  -- yes
  "statefulset",
  -- yes
  "daemonset",
  -- yes
  "replicaset",
  -- yes
  "job",
  -- yes
  "cronjob",
  -- yes
  "persistentvolume",
  -- yes
  "persistentvolumeclaim",
  -- yes
  "ingress",
  -- yes
  "networkpolicy",
  -- yes
  "poddisruptionbudget",
  -- yes
  "horizontalpodautoscaler",
  -- yes
  "limitrange",
  -- yes
  "resourcequota",

  -- Traefik Resources
  -- yes
  "middleware",
  -- yes
  "ingressroute",
  -- yes
  "ingressroutetcp",
  -- yes
  "ingressrouteudp",
  -- yes
  "tlsoption",
  -- yes
  "traefikservice",
  -- yes
  "serverstransport",

  -- cert-manager Resources
  -- yes
  "certificate",
  -- yes
  "certificaterequest",
  -- yes
  "clusterissuer",
  -- yes
  "issuer",
  -- yes
  "order",
  -- yes
  "challenge",

  -- External Secrets Resources
  -- yes
  "externalsecret",
  -- yes
  "secretstore",
  -- yes
  "clustersecretstore",

  -- Vault Resources (HashiCorp Vault)
  -- yes
  "vaultdynamicsecret",
  -- yes
  "vaultstaticsecret",
  -- yes
  "vaultauth",
  -- yes
  "vaultmount",
  -- yes
  "vaultpolicy",
  -- yes
  "vaulttoken",

  -- Gateway API Resources
  -- yes
  "gateway",
  -- yes
  "httproute",
  -- yes
  "tcproute",
  -- yes
  "udproute",
  -- yes
  "referencegrant",
  -- yes
  "gatewayclass"
}

-- Extended list of Kubernetes field names and values
local k8s_fields = {
  -- Common fields
  -- yes
  "apiVersion",
  -- yes
  "kind",
  -- yes
  "metadata",
  -- yes
  "spec",
  -- yes
  "status",
  -- yes
  "name",
  -- yes
  "namespace",
  -- yes
  "labels",
  -- yes
  "annotations",
  -- yes
  "selector",
  -- yes
  "replicas",
  -- yes
  "template",

  -- Container fields
  -- yes
  "containers",
  -- yes
  "image",
  -- yes
  "ports",
  -- yes
  "env",
  -- yes
  "volumeMounts",
  -- yes
  "volumes",
  -- yes
  "resources",
  -- yes
  "requests",
  -- yes
  "limits",
  -- yes
  "command",
  -- yes
  "args",
  -- yes
  "workingDir",
  -- yes
  "livenessProbe",
  -- yes
  "readinessProbe",
  -- yes
  "startupProbe",
  -- yes
  "healthCheck",

  -- Service fields
  -- yes
  "service",
  -- yes
  "type",
  -- yes
  "clusterIP",
  -- yes
  "externalIPs",
  -- yes
  "sessionAffinity",
  -- yes
  "loadBalancerIP",
  -- yes
  "loadBalancerSourceRanges",

  -- Deployment fields
  -- yes
  "deployment",
  -- yes
  "strategy",
  -- yes
  "rollingUpdate",
  -- yes
  "minReadySeconds",
  -- yes
  "revisionHistoryLimit",

  -- Ingress fields
  -- yes
  "ingress",
  -- yes
  "rules",
  -- yes
  "host",
  -- yes
  "http",
  -- yes
  "paths",
  -- yes
  "pathType",
  -- yes
  "backend",
  -- yes
  "tls",
  -- yes
  "hosts",

  -- Traefik fields
  -- yes
  "middleware",
  -- yes
  "chain",
  -- yes
  "headers",
  -- yes
  "rateLimit",
  -- yes
  "retry",
  -- yes
  "redirectRegex",
  -- yes
  "replacePath",
  -- yes
  "replacePathRegex",
  -- yes
  "forwardAuth",
  -- yes
  "ipWhiteList",
  -- yes
  "inFlightReq",
  -- yes
  "compress",

  -- cert-manager fields
  -- yes
  "certificate",
  -- yes
  "issuerRef",
  -- yes
  "secretName",
  -- yes
  "dnsNames",
  -- yes
  "usages",
  -- yes
  "renewBefore",
  -- yes
  "duration",
  -- yes
  "privateKey",
  -- yes
  "keyAlgorithm",
  -- yes
  "keySize",

  -- External Secrets fields
  -- yes
  "externalsecret",
  -- yes
  "data",
  -- yes
  "dataFrom",
  -- yes
  "refreshInterval",
  -- yes
  "secretStoreRef",
  -- yes
  "target",

  -- Vault fields
  -- yes
  "vaultdynamicsecret",
  -- yes
  "path",
  -- yes
  "mount",
  -- yes
  "role",
  -- yes
  "parameters",
  -- yes
  "token",
  -- yes
  "auth",
  -- yes
  "username",
  -- yes
  "password",
  -- yes
  "tokenSecretRef"
}

-- Merge resources into fields for a single completion source
local all_completions = {}
do
  local seen = {}
  for _, v in ipairs(k8s_fields) do
    if not seen[v] then
      seen[v] = true
      table.insert(all_completions, v)
    end
  end
  for _, v in ipairs(k8s_resources) do
    if not seen[v] then
      seen[v] = true
      table.insert(all_completions, v)
    end
  end
end

-- ─── Ghost-text state ────────────────────────────────────────────────────────

local ns = vim.api.nvim_create_namespace("k8s_ghost_text")

-- State per buffer: { suggestion = string|nil, word_start = int, extmark_id = int|nil }
local state = {}

local function get_state(bufnr)
  if not state[bufnr] then
    state[bufnr] = { suggestion = nil, word_start = nil, extmark_id = nil }
  end
  return state[bufnr]
end

-- Clear the ghost text extmark for a buffer
local function clear_ghost(bufnr)
  local s = get_state(bufnr)
  if s.extmark_id then
    vim.api.nvim_buf_del_extmark(bufnr, ns, s.extmark_id)
    s.extmark_id = nil
  end
  s.suggestion = nil
  s.word_start = nil
end

-- Show ghost text for the remainder of `suggestion` after what the user typed
local function show_ghost(bufnr, row, col, suffix)
  local s = get_state(bufnr)
  -- Remove old extmark first
  if s.extmark_id then
    vim.api.nvim_buf_del_extmark(bufnr, ns, s.extmark_id)
    s.extmark_id = nil
  end
  if suffix == "" then return end
  -- row is 0-indexed for extmarks
  local id = vim.api.nvim_buf_set_extmark(bufnr, ns, row, col, {
    virt_text = { { suffix, "Comment" } },
    virt_text_pos = "inline",
    hl_mode = "combine",
  })
  s.extmark_id = id
end

-- Find the best completion match for the current word prefix
local function find_match(prefix)
  if prefix == "" then return nil end
  for _, field in ipairs(all_completions) do
    if #field > #prefix and field:sub(1, #prefix) == prefix then
      return field
    end
  end
  return nil
end

-- Extract the word immediately before (and including) the cursor
local function get_word_prefix(line, col)
  -- col is 1-indexed byte position (cursor is *after* col-1 chars)
  local before = line:sub(1, col)
  local word = before:match("[%w_%-%.]+$") or ""
  return word, col - #word  -- word, 0-indexed start col
end

-- ─── Core update (called on every CursorMovedI / TextChangedI) ──────────────

local function update_ghost(bufnr)
  -- Guard: only run in insert mode
  if vim.api.nvim_get_mode().mode ~= "i" then
    clear_ghost(bufnr)
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local row0 = cursor[1] - 1  -- 0-indexed
  local col   = cursor[2]     -- byte offset (0-indexed), cursor is after this many bytes

  local line = vim.api.nvim_buf_get_lines(bufnr, row0, row0 + 1, false)[1] or ""
  local prefix, word_start0 = get_word_prefix(line, col)

  local match = find_match(prefix)

  local s = get_state(bufnr)

  if not match then
    clear_ghost(bufnr)
    return
  end

  local suffix = match:sub(#prefix + 1)
  s.suggestion  = match
  s.word_start  = word_start0

  show_ghost(bufnr, row0, col, suffix)
end

-- ─── Accept the current suggestion ──────────────────────────────────────────

local function accept_suggestion(bufnr)
  local s = get_state(bufnr)
  if not s.suggestion then
    -- No suggestion: fall through to a literal Tab
    return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local row0   = cursor[1] - 1
  local col    = cursor[2]

  local line = vim.api.nvim_buf_get_lines(bufnr, row0, row0 + 1, false)[1] or ""
  local prefix, word_start0 = get_word_prefix(line, col)

  -- Replace the prefix with the full suggestion
  local new_line = line:sub(1, word_start0) .. s.suggestion .. line:sub(col + 1)
  vim.api.nvim_buf_set_lines(bufnr, row0, row0 + 1, false, { new_line })

  -- Move cursor to end of inserted word
  local new_col = word_start0 + #s.suggestion
  vim.api.nvim_win_set_cursor(0, { row0 + 1, new_col })

  clear_ghost(bufnr)
end

-- ─── Setup ───────────────────────────────────────────────────────────────────

function M.setup()
  -- Keep omnifunc working as a fallback for <C-x><C-o>
  _G.k8s_complete = function(findstart, base)
    if findstart == 1 then
      local line = vim.api.nvim_get_current_line()
      local col  = vim.api.nvim_win_get_cursor(0)[2]
      local pos  = col
      while pos > 0 and line:sub(pos, pos):match("%w") do
        pos = pos - 1
      end
      return pos
    else
      local matches = {}
      for _, field in ipairs(all_completions) do
        if field:sub(1, #base) == base then
          table.insert(matches, field)
        end
      end
      return matches
    end
  end

  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.yaml",
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.api.nvim_buf_get_option(bufnr, "buftype") ~= "" then return end

      -- Set omnifunc as a fallback
      vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.k8s_complete")

      -- Auto-trigger ghost text on every insert-mode change
      vim.api.nvim_create_autocmd({ "TextChangedI", "CursorMovedI" }, {
        buffer = bufnr,
        callback = function() update_ghost(bufnr) end,
      })

      -- Clear ghost text when leaving insert mode
      vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, {
        buffer = bufnr,
        callback = function() clear_ghost(bufnr) end,
      })

      -- Tab: accept suggestion (or insert literal tab if no suggestion)
      vim.keymap.set("i", "<Tab>", function()
        accept_suggestion(bufnr)
      end, { buffer = bufnr, noremap = true, silent = true,
             desc = "Accept k8s completion suggestion" })

      -- Esc: dismiss ghost text (then fall through to normal Esc behaviour)
      vim.keymap.set("i", "<Esc>", function()
        clear_ghost(bufnr)
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      end, { buffer = bufnr, noremap = true, silent = true,
             desc = "Dismiss k8s completion suggestion" })
    end,
  })
end

return M
