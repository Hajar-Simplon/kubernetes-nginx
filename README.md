# Kubernetes Nginx Deployment with KIND

## Overview

This project demonstrates the fundamentals of Kubernetes by deploying an Nginx application on a local Kubernetes cluster created with KIND (Kubernetes IN Docker).

The project covers:

- Creating a Kubernetes cluster with KIND
- Deploying an application using a Deployment
- Managing Pods with ReplicaSets
- Exposing the application with a Service
- Kubernetes self-healing
- Viewing application logs
- Executing commands inside containers

---

## Project Structure

```
kubernetes-nginx/
├── manifests/
│   ├── deployment.yaml
│   └── service.yaml
├── README.md
├── Makefile
└── .gitignore
```

---

## Requirements

- Docker
- kubectl
- KIND

Verify installation:

```bash
docker --version
kubectl version --client
kind version
```

---

## Create the Cluster

```bash
kind create cluster --name nginx-cluster
```

Verify:

```bash
kubectl cluster-info
kubectl get nodes
```

---

## Deploy Nginx

```bash
kubectl apply -f manifests/deployment.yaml
```

Verify:

```bash
kubectl get deployments
kubectl get replicasets
kubectl get pods
```

---

## Expose the Application

```bash
kubectl apply -f manifests/service.yaml
```

Verify:

```bash
kubectl get services
```

Port-forward:

```bash
kubectl port-forward service/nginx-service 8080:80
```

Open:

```
http://localhost:8080
```

---

## Demonstrate Self-Healing

Delete a Pod:

```bash
kubectl delete pod <pod-name>
```

Watch Pods:

```bash
kubectl get pods -w
```

Kubernetes automatically recreates the missing Pod.

---

## View Logs

```bash
kubectl logs <pod-name>
```

Follow logs:

```bash
kubectl logs -f <pod-name>
```

---

## Execute Commands Inside a Pod

```bash
kubectl exec -it <pod-name> -- /bin/sh
```

---

## Cleanup

Delete resources:

```bash
kubectl delete -f manifests/
```

Delete the KIND cluster:

```bash
kind delete cluster --name nginx-cluster
```

---

## Kubernetes Concepts Learned

- Cluster
- Node
- Namespace
- Deployment
- ReplicaSet
- Pod
- Service
- Labels
- Selectors
- Self-Healing
- Port Forwarding
- Logs
- kubectl exec

---

## Architecture

```
Browser
    │
localhost:8080
    │
kubectl port-forward
    │
Service (NodePort)
    │
Deployment
    │
ReplicaSet
    │
Pods (x3)
    │
Nginx Containers
```