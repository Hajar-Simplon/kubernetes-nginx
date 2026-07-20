# ==========================================
# Kubernetes Nginx - KIND
# ==========================================

CLUSTER_NAME = nginx-cluster

.PHONY: cluster delete-cluster deploy service destroy status pods deployments services logs shell port-forward

## Create KIND cluster
cluster:
	kind create cluster --name $(CLUSTER_NAME)

## Delete KIND cluster
delete-cluster:
	kind delete cluster --name $(CLUSTER_NAME)

## Deploy all manifests
deploy:
	kubectl apply -f manifests/

## Delete all manifests
destroy:
	kubectl delete -f manifests/

## Show cluster status
status:
	kubectl cluster-info
	kubectl get nodes

## Show Pods
pods:
	kubectl get pods -o wide

## Show Deployments
deployments:
	kubectl get deployments

## Show Services
services:
	kubectl get services

## Follow logs (replace pod name)
logs:
	@echo "Usage:"
	@echo "kubectl logs -f <pod-name>"

## Open shell (replace pod name)
shell:
	@echo "Usage:"
	@echo "kubectl exec -it <pod-name> -- /bin/sh"

## Port forward nginx
port-forward:
	kubectl port-forward service/nginx-service 8080:80