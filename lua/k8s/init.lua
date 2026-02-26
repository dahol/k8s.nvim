local M = {}

-- Function to list available Kubernetes resources
local function list_k8s_resources()
	local resources = {
		"Core Kubernetes Resources:",
		"  apiVersion, kind, metadata, spec, status",
		"  name, namespace, labels, annotations",
		"  selector, replicas, template",
		"  containers, image, ports, env",
		"  volumeMounts, volumes, configMaps, secrets",
		"  serviceAccountName, resources, requests, limits",
		"  hostAliases, nodeSelector, tolerations, affinity",

		"",
		"Additional Kubernetes Resources:",
		"  service, deployment, statefulset, daemonset",
		"  replicaset, job, cronjob, persistentvolume",
		"  persistentvolumeclaim, ingress, networkpolicy",
		"  poddisruptionbudget, horizontalpodautoscaler",

		"",
		"Traefik Resources:",
		"  middleware, ingressroute, ingressroutetcp",
		"  ingressrouteudp, tlsoption, traefikservice",

		"",
		"cert-manager Resources:",
		"  certificate, certificaterequest, clusterissuer",
		"  issuer, order, challenge",

		"",
		"External Secrets Resources:",
		"  externalsecret, secretstore, clustersecretstore",

		"",
		"HashiCorp Vault Resources:",
		"  vaultdynamicsecret, vaultstaticsecret, vaultauth",
		"  vaultmount, vaultpolicy, vaulttoken",

		"",
		"Gateway API Resources:",
		"  gateway, httproute, tcproute, udproute",
		"  referencegrant, gatewayclass",
	}

	-- Create a new buffer to display the resources
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, resources)
	vim.api.nvim_buf_set_option(buf, "buftype", "nowrite")
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "swapfile", false)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	-- Open the buffer in a split
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = 60,
		height = 30,
		row = 5,
		col = 10,
		style = "minimal",
		border = "single",
	})

	-- Set the window highlight after creation
	vim.api.nvim_win_set_option(win, "winhighlight", "Normal:Normal,FloatBorder:NormalFloat")

	-- Set buffer name and make it readonly
	vim.api.nvim_buf_set_name(buf, "K8s Resources")
	vim.api.nvim_win_set_option(win, "number", false)
	vim.api.nvim_win_set_option(win, "relativenumber", false)

	-- Set up a keybinding to close the window
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
end

-- Setup function for the k8s.nvim plugin
function M.setup()
	-- Create the command to list resources
	vim.api.nvim_create_user_command("K8sResources", list_k8s_resources, {})

	-- Set up autocommands for YAML files to enable completion
	vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
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
