# k8s.nvim

A Neovim plugin for Kubernetes schema autocompletion.

## Features

- YAML schema completion for Kubernetes manifests
- Support for common Kubernetes object fields
- Integration with Neovim's omnifunc system
- Comprehensive support for Traefik, cert-manager, External Secrets, and HashiCorp Vault resources
- Gateway API resource support
- Command to list available Kubernetes resources

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

## Available Commands

- `:K8sResources` - Display a list of available Kubernetes resources and fields for completion

## Available completions

### Core Kubernetes Resources:
- apiVersion, kind, metadata, spec, status
- name, namespace, labels, annotations
- selector, replicas, template
- containers, image, ports, env
- volumeMounts, volumes, configMaps, secrets
- serviceAccountName, resources, requests, limits
- hostAliases, nodeSelector, tolerations, affinity

### Additional Kubernetes Resources:
- service, deployment, statefulset, daemonset
- replicaset, job, cronjob, persistentvolume
- persistentvolumeclaim, ingress, networkpolicy
- poddisruptionbudget, horizontalpodautoscaler

### Traefik Resources:
- middleware, ingressroute, ingressroutetcp
- ingressrouteudp, tlsoption, traefikservice

### cert-manager Resources:
- certificate, certificaterequest, clusterissuer
- issuer, order, challenge

### External Secrets Resources:
- externalsecret, secretstore, clustersecretstore

### HashiCorp Vault Resources:
- vaultdynamicsecret, vaultstaticsecret, vaultauth
- vaultmount, vaultpolicy, vaulttoken

### Gateway API Resources:
- gateway, httproute, tcproute, udproute
- referencegrant, gatewayclass

## Requirements

- Neovim 0.8+
