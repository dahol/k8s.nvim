local M = {}

-- ─── Resource templates ───────────────────────────────────────────────────────

local templates = {
  -- Core
  deployment = [[
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
  namespace: default
  labels:
    app: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-container
          image: my-image:latest
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
]],

  service = [[
apiVersion: v1
kind: Service
metadata:
  name: my-service
  namespace: default
spec:
  selector:
    app: my-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
]],

  configmap = [[
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
  namespace: default
data:
  key: value
]],

  secret = [[
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
  namespace: default
type: Opaque
data:
  # base64 encoded values
  username: dXNlcm5hbWU=
  password: cGFzc3dvcmQ=
]],

  statefulset = [[
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: my-statefulset
  namespace: default
spec:
  serviceName: my-service
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-container
          image: my-image:latest
          ports:
            - containerPort: 80
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
]],

  daemonset = [[
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: my-daemonset
  namespace: default
spec:
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-container
          image: my-image:latest
]],

  job = [[
apiVersion: batch/v1
kind: Job
metadata:
  name: my-job
  namespace: default
spec:
  template:
    spec:
      containers:
        - name: my-job
          image: my-image:latest
          command: ["sh", "-c", "echo hello"]
      restartPolicy: Never
  backoffLimit: 4
]],

  cronjob = [[
apiVersion: batch/v1
kind: CronJob
metadata:
  name: my-cronjob
  namespace: default
spec:
  schedule: "0 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: my-cronjob
              image: my-image:latest
              command: ["sh", "-c", "echo hello"]
          restartPolicy: OnFailure
]],

  namespace = [[
apiVersion: v1
kind: Namespace
metadata:
  name: my-namespace
]],

  serviceaccount = [[
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-serviceaccount
  namespace: default
]],

  role = [[
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: my-role
  namespace: default
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
]],

  clusterrole = [[
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: my-clusterrole
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
]],

  rolebinding = [[
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: my-rolebinding
  namespace: default
subjects:
  - kind: ServiceAccount
    name: my-serviceaccount
    namespace: default
roleRef:
  kind: Role
  name: my-role
  apiGroup: rbac.authorization.k8s.io
]],

  clusterrolebinding = [[
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: my-clusterrolebinding
subjects:
  - kind: ServiceAccount
    name: my-serviceaccount
    namespace: default
roleRef:
  kind: ClusterRole
  name: my-clusterrole
  apiGroup: rbac.authorization.k8s.io
]],

  ingress = [[
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  namespace: default
spec:
  rules:
    - host: example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 80
  tls:
    - hosts:
        - example.com
      secretName: my-tls-secret
]],

  networkpolicy = [[
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: my-networkpolicy
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: my-app
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: allowed-app
      ports:
        - protocol: TCP
          port: 80
]],

  persistentvolume = [[
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /mnt/data
]],

  persistentvolumeclaim = [[
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard
]],

  horizontalpodautoscaler = [[
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-hpa
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-deployment
  minReplicas: 1
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 80
]],

  poddisruptionbudget = [[
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-pdb
  namespace: default
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: my-app
]],

  resourcequota = [[
apiVersion: v1
kind: ResourceQuota
metadata:
  name: my-resourcequota
  namespace: default
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    requests.memory: 4Gi
    limits.cpu: "8"
    limits.memory: 8Gi
]],

  limitrange = [[
apiVersion: v1
kind: LimitRange
metadata:
  name: my-limitrange
  namespace: default
spec:
  limits:
    - type: Container
      default:
        cpu: "500m"
        memory: "256Mi"
      defaultRequest:
        cpu: "100m"
        memory: "128Mi"
]],

  -- Traefik
  ingressroute = [[
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: my-ingressroute
  namespace: default
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`example.com`)
      kind: Rule
      services:
        - name: my-service
          port: 80
  tls:
    certResolver: letsencrypt
]],

  middleware = [[
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: my-middleware
  namespace: default
spec:
  headers:
    customRequestHeaders:
      X-Custom-Header: "value"
]],

  -- cert-manager
  certificate = [[
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: my-certificate
  namespace: default
spec:
  secretName: my-tls-secret
  issuerRef:
    name: letsencrypt
    kind: ClusterIssuer
  dnsNames:
    - example.com
    - www.example.com
]],

  clusterissuer = [[
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-account-key
    solvers:
      - http01:
          ingress:
            class: traefik
]],

  issuer = [[
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: my-issuer
  namespace: default
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: my-issuer-account-key
    solvers:
      - http01:
          ingress:
            class: traefik
]],

  -- External Secrets
  externalsecret = [[
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: my-externalsecret
  namespace: default
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: my-secretstore
    kind: SecretStore
  target:
    name: my-secret
    creationPolicy: Owner
  data:
    - secretKey: my-key
      remoteRef:
        key: path/to/secret
        property: my-property
]],

  secretstore = [[
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: my-secretstore
  namespace: default
spec:
  provider:
    vault:
      server: https://vault.example.com
      path: secret
      version: v2
      auth:
        kubernetes:
          mountPath: kubernetes
          role: my-role
]],

  clustersecretstore = [[
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: my-clustersecretstore
spec:
  provider:
    vault:
      server: https://vault.example.com
      path: secret
      version: v2
      auth:
        kubernetes:
          mountPath: kubernetes
          role: my-role
]],

  -- Gateway API
  gateway = [[
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: my-gateway
  namespace: default
spec:
  gatewayClassName: my-gatewayclass
  listeners:
    - name: https
      port: 443
      protocol: HTTPS
      tls:
        mode: Terminate
        certificateRefs:
          - name: my-tls-secret
]],

  httproute = [[
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: my-httproute
  namespace: default
spec:
  parentRefs:
    - name: my-gateway
  hostnames:
    - example.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: my-service
          port: 80
]],

  gatewayclass = [[
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: my-gatewayclass
spec:
  controllerName: example.com/gateway-controller
]],

  referencegrant = [[
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata:
  name: my-referencegrant
  namespace: default
spec:
  from:
    - group: gateway.networking.k8s.io
      kind: HTTPRoute
      namespace: other-namespace
  to:
    - group: ""
      kind: Service
]],
}

-- Ordered list of resource names for display
local resource_names = {
  -- Core
  "deployment",
  "service",
  "configmap",
  "secret",
  "namespace",
  "serviceaccount",
  "statefulset",
  "daemonset",
  "job",
  "cronjob",
  "persistentvolume",
  "persistentvolumeclaim",
  "horizontalpodautoscaler",
  "poddisruptionbudget",
  "resourcequota",
  "limitrange",
  -- RBAC
  "role",
  "clusterrole",
  "rolebinding",
  "clusterrolebinding",
  -- Networking
  "ingress",
  "networkpolicy",
  -- Traefik
  "ingressroute",
  "middleware",
  -- cert-manager
  "certificate",
  "clusterissuer",
  "issuer",
  -- External Secrets
  "externalsecret",
  "secretstore",
  "clustersecretstore",
  -- Gateway API
  "gateway",
  "httproute",
  "gatewayclass",
  "referencegrant",
}

-- ─── Picker state ─────────────────────────────────────────────────────────────

local picker_state = {
  buf          = nil,
  win          = nil,
  search_buf   = nil,
  search_win   = nil,
  list_buf     = nil,
  list_win     = nil,
  target_buf   = nil,
  target_win   = nil,
  filtered     = {},
  selected_idx = 1,
}

-- ─── Helpers ──────────────────────────────────────────────────────────────────

local function filter_resources(query)
  local q = query:lower()
  local result = {}
  for _, name in ipairs(resource_names) do
    if q == "" or name:find(q, 1, true) then
      table.insert(result, name)
    end
  end
  return result
end

local function render_list(filtered, selected_idx)
  if not vim.api.nvim_buf_is_valid(picker_state.list_buf) then return end

  local lines = {}
  for i, name in ipairs(filtered) do
    if i == selected_idx then
      table.insert(lines, "> " .. name)
    else
      table.insert(lines, "  " .. name)
    end
  end
  if #lines == 0 then
    lines = { "  (no matches)" }
  end

  vim.api.nvim_buf_set_option(picker_state.list_buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(picker_state.list_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(picker_state.list_buf, "modifiable", false)
end

local function close_picker()
  -- Close in reverse order of creation
  for _, key in ipairs({ "list_win", "search_win" }) do
    local win = picker_state[key]
    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    picker_state[key] = nil
  end
  for _, key in ipairs({ "list_buf", "search_buf" }) do
    local buf = picker_state[key]
    if buf and vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
    picker_state[key] = nil
  end
end

local function confirm_selection()
  local idx    = picker_state.selected_idx
  local list   = picker_state.filtered
  local target = picker_state.target_buf
  local win    = picker_state.target_win

  if #list == 0 then return end
  local name = list[idx]
  local tmpl = templates[name]
  if not tmpl then return end

  close_picker()

  -- Restore focus to the original window
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_set_current_win(win)
  end

  if not (target and vim.api.nvim_buf_is_valid(target)) then return end

  -- Insert template lines at cursor position
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row    = cursor[1] - 1  -- 0-indexed

  -- Split template into lines; strip leading newline if present
  local text = tmpl:gsub("^\n", "")
  local lines = vim.split(text, "\n", { plain = true })
  -- Remove trailing empty line from heredoc
  if lines[#lines] == "" then
    table.remove(lines)
  end

  vim.api.nvim_buf_set_lines(target, row, row, false, lines)
  -- Place cursor at first inserted line
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
end

-- ─── Picker open ──────────────────────────────────────────────────────────────

function M.open(target_buf, target_win)
  -- Don't open twice
  if picker_state.search_win and vim.api.nvim_win_is_valid(picker_state.search_win) then
    return
  end

  picker_state.target_buf  = target_buf
  picker_state.target_win  = target_win
  picker_state.filtered    = filter_resources("")
  picker_state.selected_idx = 1

  local editor_w = vim.o.columns
  local editor_h = vim.o.lines

  local width    = math.min(50, editor_w - 4)
  local height   = math.min(20, editor_h - 6)
  local row      = math.floor((editor_h - height - 3) / 2)
  local col      = math.floor((editor_w - width) / 2)

  -- ── Search bar buffer ────────────────────────────────────────────────────
  local search_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(search_buf, "buftype", "prompt")
  vim.api.nvim_buf_set_option(search_buf, "bufhidden", "wipe")
  vim.fn.prompt_setprompt(search_buf, "  ")

  local search_win = vim.api.nvim_open_win(search_buf, true, {
    relative = "editor",
    width    = width,
    height   = 1,
    row      = row,
    col      = col,
    style    = "minimal",
    border   = "rounded",
    title    = " K8s Resources ",
    title_pos = "center",
  })

  picker_state.search_buf = search_buf
  picker_state.search_win = search_win

  -- ── List buffer ──────────────────────────────────────────────────────────
  local list_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(list_buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(list_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(list_buf, "modifiable", false)

  local list_win = vim.api.nvim_open_win(list_buf, false, {
    relative = "editor",
    width    = width,
    height   = height,
    row      = row + 3,
    col      = col,
    style    = "minimal",
    border   = "rounded",
  })

  vim.api.nvim_win_set_option(list_win, "cursorline", false)

  picker_state.list_buf = list_buf
  picker_state.list_win = list_win

  render_list(picker_state.filtered, picker_state.selected_idx)

  -- ── Keymaps on search buf ────────────────────────────────────────────────

  local function move(delta)
    local n = #picker_state.filtered
    if n == 0 then return end
    picker_state.selected_idx = ((picker_state.selected_idx - 1 + delta) % n) + 1
    render_list(picker_state.filtered, picker_state.selected_idx)
  end

  -- Enter: confirm
  vim.keymap.set("i", "<CR>", function()
    vim.cmd("stopinsert")
    confirm_selection()
  end, { buffer = search_buf, noremap = true, silent = true })

  -- Down / Up arrow and Ctrl-n/p
  vim.keymap.set("i", "<Down>",  function() move(1)  end, { buffer = search_buf, noremap = true, silent = true })
  vim.keymap.set("i", "<Up>",    function() move(-1) end, { buffer = search_buf, noremap = true, silent = true })
  vim.keymap.set("i", "<C-n>",   function() move(1)  end, { buffer = search_buf, noremap = true, silent = true })
  vim.keymap.set("i", "<C-p>",   function() move(-1) end, { buffer = search_buf, noremap = true, silent = true })
  vim.keymap.set("i", "<Tab>",   function() move(1)  end, { buffer = search_buf, noremap = true, silent = true })
  vim.keymap.set("i", "<S-Tab>", function() move(-1) end, { buffer = search_buf, noremap = true, silent = true })

  -- Escape: close without inserting
  vim.keymap.set("i", "<Esc>", function()
    vim.cmd("stopinsert")
    close_picker()
  end, { buffer = search_buf, noremap = true, silent = true })

  vim.keymap.set("n", "<Esc>", function()
    close_picker()
  end, { buffer = search_buf, noremap = true, silent = true })

  vim.keymap.set("n", "q", function()
    close_picker()
  end, { buffer = search_buf, noremap = true, silent = true })

  -- React to text changes in the prompt to filter the list
  vim.api.nvim_create_autocmd("TextChangedI", {
    buffer   = search_buf,
    callback = function()
      local line  = vim.api.nvim_buf_get_lines(search_buf, 0, 1, false)[1] or ""
      -- Strip the prompt prefix "  "
      local query = line:gsub("^%s%s", "")
      picker_state.filtered    = filter_resources(query)
      picker_state.selected_idx = 1
      render_list(picker_state.filtered, picker_state.selected_idx)
    end,
  })

  -- Close both windows if the search buf loses focus
  vim.api.nvim_create_autocmd("BufLeave", {
    buffer   = search_buf,
    once     = true,
    callback = function()
      vim.schedule(function()
        -- Only close if we didn't just confirm (windows already gone)
        if picker_state.search_win and vim.api.nvim_win_is_valid(picker_state.search_win) then
          close_picker()
        end
      end)
    end,
  })

  -- Enter insert mode immediately so the user can type right away
  vim.cmd("startinsert")
end

return M
