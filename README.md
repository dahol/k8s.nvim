# k8s.nvim

A Neovim plugin for Kubernetes schema autocompletion.

## Features

- YAML schema completion for Kubernetes manifests
- Support for common Kubernetes object fields
- Integration with Neovim's omnifunc system

## Installation

Add to your Neovim configuration:

```lua
-- Using lazy.nvim
{
  'k8s.nvim',
  config = function()
    require('k8s').setup()
  end
}
```

## Usage

The plugin automatically enables completion for `.yaml` files when you're editing Kubernetes manifests.

## Available completions

- apiVersion
- kind
- metadata
- spec
- status
- name
- namespace
- labels
- annotations
- selector
- replicas
- template
- containers
- image
- ports
- env
- volumeMounts
- volumes
- configMaps
- secrets
- serviceAccountName
- resources
- requests
- limits
- hostAliases
- nodeSelector
- tolerations
- affinity

## Requirements

- Neovim 0.8+