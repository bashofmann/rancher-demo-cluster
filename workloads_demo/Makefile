SHELL := /bin/bash
KUBECONFIG := kubeconfig

add-helm-repos:
	helm repo add rodeo https://rancher.github.io/rodeo/
	helm repo add rancher-charts https://charts.rancher.io
	helm repo add jetstack https://charts.jetstack.io
	helm repo add neuvector https://neuvector.github.io/neuvector-helm/

install:
	helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.7.1 --set installCRDs=true --wait --create-namespace
	kubectl apply -f cert-manager
	helm upgrade --install --namespace cattle-monitoring-system rancher-monitoring-crd rancher-charts/rancher-monitoring-crd --create-namespace --wait
	helm upgrade --install --namespace cattle-monitoring-system rancher-monitoring rancher-charts/rancher-monitoring --create-namespace -f monitoring/values.yaml
	helm upgrade --install --namespace cattle-gatekeeper-system rancher-gatekeeper-crd rancher-charts/rancher-gatekeeper-crd --create-namespace --wait
	helm upgrade --install --namespace cattle-gatekeeper-system rancher-gatekeeper rancher-charts/rancher-gatekeeper --create-namespace
	helm upgrade --install --namespace istio-system rancher-kiali-server-crd rancher-charts/rancher-kiali-server-crd --create-namespace --wait
	helm upgrade --install --namespace istio-system rancher-istio rancher-charts/rancher-istio --create-namespace --set tracing.enabled=true
	kubectl apply -f helm-repos
	kubectl create namespace shop
	kubectl label namespace shop istio-injection=enabled
	helm upgrade --install --namespace shop shop rodeo/online-boutique --create-namespace -f shop/values.yaml
	helm upgrade --install --namespace wordpress wordpress rodeo/wordpress --create-namespace -f wordpress/values.yaml
	helm upgrade --install neuvector --namespace neuvector-system neuvector/core --create-namespace -f neuvector/values.yaml --version 2.2.0-b2
	kubectl -n neuvector-system rollout status deployment neuvector-controller-pod
	kubectl -n neuvector-system rollout status deployment neuvector-manager-pod
	kubectl -n neuvector-system rollout status deployment neuvector-scanner-pod
	kubectl -n neuvector-system rollout status daemonset neuvector-enforcer-pod
	bash neuvector/configure.sh
