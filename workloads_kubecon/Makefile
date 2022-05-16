SHELL := /bin/bash

add-helm-repos:
	helm repo add rodeo https://rancher.github.io/rodeo/
	helm repo add rancher-charts https://charts.rancher.io
	helm repo add jetstack https://charts.jetstack.io
	helm repo add epinio https://epinio.github.io/helm-charts
	helm repo add neuvector https://neuvector.github.io/neuvector-helm/

install:
	helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.7.1 --set installCRDs=true --wait --create-namespace
	kubectl apply -f cert-manager
	kubectl create namespace longhorn-system || true
	kubectl delete secret -n longhorn-system backup-credentials || true
	kubectl create secret generic -n longhorn-system backup-credentials --from-env-file=<(tail $(HOME)/.aws/credentials -n 2 | awk '{printf "%s=%s\n",toupper($$1), $$3}')
	helm upgrade --install --namespace longhorn-system longhorn-crd rancher-charts/longhorn-crd --create-namespace --wait
	helm upgrade --install --namespace longhorn-system longhorn rancher-charts/longhorn --create-namespace --set "defaultSettings.backupTarget=s3://bhofmann-longhorn-backup@eu-central-1/" --set "defaultSettings.backupTargetCredentialSecret=backup-credentials"
	helm upgrade --install --namespace cattle-monitoring-system rancher-monitoring-crd rancher-charts/rancher-monitoring-crd --create-namespace --wait
	helm upgrade --install --namespace cattle-monitoring-system rancher-monitoring rancher-charts/rancher-monitoring --create-namespace -f monitoring/values.yaml
	helm upgrade --install --namespace cattle-gatekeeper-system rancher-gatekeeper-crd rancher-charts/rancher-gatekeeper-crd --create-namespace --wait
	helm upgrade --install --namespace cattle-gatekeeper-system rancher-gatekeeper rancher-charts/rancher-gatekeeper --create-namespace
	helm upgrade --install --namespace cattle-logging-system rancher-logging-crd rancher-charts/rancher-logging-crd --create-namespace --wait
	helm upgrade --install --namespace cattle-logging-system rancher-logging rancher-charts/rancher-logging --create-namespace
	helm upgrade --install --namespace istio-system rancher-kiali-server-crd rancher-charts/rancher-kiali-server-crd --create-namespace --wait
	helm upgrade --install --namespace istio-system rancher-istio rancher-charts/rancher-istio --create-namespace --set tracing.enabled=true
	kubectl apply -f helm-repos
	kubectl create namespace shop || true
	kubectl label namespace shop istio-injection=enabled || true
	kubectl create namespace bookinfo || true
	kubectl label namespace bookinfo istio-injection=enabled || true
	helm upgrade --install --namespace shop shop rodeo/online-boutique --create-namespace -f shop/values.yaml
	helm upgrade --install --namespace rancher-demo rancher-demo rodeo/rancher-demo --create-namespace -f rancher-demo/values.yaml
	helm upgrade --install --namespace loki loki rodeo/loki --create-namespace
	helm upgrade --install --namespace tetris tetris rodeo/tetris --create-namespace -f tetris/values.yaml
	helm upgrade --install --namespace bookinfo bookinfo rodeo/bookinfo --create-namespace
	helm upgrade --install --namespace wordpress wordpress rodeo/wordpress --create-namespace -f wordpress/values.yaml
	kubectl apply -f longhorn_monitoring/
	helm upgrade --install neuvector-crd --namespace cattle-neuvector-system rancher-charts/neuvector-crd --create-namespace --version 100.0.0+up2.2.0
	helm upgrade --install neuvector --namespace cattle-neuvector-system rancher-charts/neuvector --create-namespace -f neuvector/values.yaml --version 100.0.0+up2.2.0	kubectl -n cattle-neuvector-system rollout status deployment neuvector-controller-pod
	kubectl -n cattle-neuvector-system rollout status deployment neuvector-manager-pod
	kubectl -n cattle-neuvector-system rollout status deployment neuvector-scanner-pod
	kubectl -n cattle-neuvector-system rollout status daemonset neuvector-enforcer-pod
	bash neuvector/configure.sh
	helm upgrade --install epinio -n epinio --create-namespace epinio/epinio --values epinio/values.yaml
