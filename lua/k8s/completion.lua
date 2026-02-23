local M = {}

-- Comprehensive list of Kubernetes resources and fields
local k8s_resources = {
  -- Core Kubernetes Resources
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
  "affinity",
  
  -- Additional Kubernetes Resources
  "service",
  "deployment",
  "statefulset",
  "daemonset",
  "replicaset",
  "job",
  "cronjob",
  "persistentvolume",
  "persistentvolumeclaim",
  "ingress",
  "networkpolicy",
  "poddisruptionbudget",
  "horizontalpodautoscaler",
  "limitrange",
  "resourcequota",
  
  -- Traefik Resources
  "middleware",
  "ingressroute",
  "ingressroutetcp",
  "ingressrouteudp",
  "tlsoption",
  "tlsoption",
  "traefikservice",
  "serverstransport",
  
  -- cert-manager Resources
  "certificate",
  "certificaterequest",
  "clusterissuer",
  "issuer",
  "order",
  "challenge",
  
  -- External Secrets Resources
  "externalsecret",
  "secretstore",
  "clustersecretstore",
  
  -- Vault Resources (HashiCorp Vault)
  "vaultdynamicsecret",
  "vaultstaticsecret",
  "vaultauth",
  "vaultmount",
  "vaultpolicy",
  "vaulttoken",
  
  -- Gateway API Resources
  "gateway",
  "httproute",
  "tcproute",
  "udproute",
  "referencegrant",
  "gatewayclass"
}

-- Extended list of Kubernetes field names and values
local k8s_fields = {
  -- Common fields
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
  
  -- Container fields
  "containers",
  "image",
  "ports",
  "env",
  "volumeMounts",
  "volumes",
  "resources",
  "requests",
  "limits",
  "command",
  "args",
  "workingDir",
  "livenessProbe",
  "readinessProbe",
  "startupProbe",
  "healthCheck",
  
  -- Service fields
  "service",
  "type",
  "ports",
  "clusterIP",
  "externalIPs",
  "sessionAffinity",
  "loadBalancerIP",
  "loadBalancerSourceRanges",
  
  -- Deployment fields
  "deployment",
  "replicas",
  "strategy",
  "rollingUpdate",
  "minReadySeconds",
  "revisionHistoryLimit",
  
  -- Ingress fields
  "ingress",
  "rules",
  "host",
  "http",
  "paths",
  "pathType",
  "backend",
  "tls",
  "hosts",
  
  -- Traefik fields
  "middleware",
  "chain",
  "headers",
  "rateLimit",
  "retry",
  "redirectRegex",
  "redirectRegex",
  "replacePath",
  "replacePathRegex",
  "forwardAuth",
  "ipWhiteList",
  "inFlightReq",
  "compress",
  
  -- cert-manager fields
  "certificate",
  "issuerRef",
  "secretName",
  "dnsNames",
  "usages",
  "renewBefore",
  "duration",
  "privateKey",
  "keyAlgorithm",
  "keySize",
  
  -- External Secrets fields
  "externalsecret",
  "data",
  "dataFrom",
  "refreshInterval",
  "secretStoreRef",
  "target",
  
  -- Vault fields
  "vaultdynamicsecret",
  "path",
  "mount",
  "role",
  "data",
  "parameters",
  "token",
  "auth",
  "username",
  "password",
  "tokenSecretRef"
}

-- Get the current line for completion
local function get_current_line()
  local line = vim.api.nvim_get_current_line()
  return line
end

-- Enhanced completion function for Kubernetes objects and fields
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
    -- Return completion items based on the base text
    local matches = {}
    
    for _, field in ipairs(k8s_fields) do
      if string.sub(field, 1, #base) == base then
        table.insert(matches, field)
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