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
---

---

## High Availability KIND Cluster

This project uses a **multi-node Kubernetes cluster** created with KIND to simulate a production-like environment.

### Cluster Topology

- **3 Control Plane nodes**
  - API Server
  - Scheduler
  - Controller Manager
  - etcd

- **3 Worker nodes**
  - Run application workloads
  - Host Kubernetes Pods

- **1 External Load Balancer**
  - Automatically created by KIND to expose the Kubernetes API in a highly available control plane.

The cluster is created declaratively using:

```bash
kind create cluster --name nginx-cluster --config kind/kind-config.yaml
```

Architecture:

```text
                    KIND Cluster

      ┌──────────────┬──────────────┬──────────────┐
      │ ControlPlane1│ ControlPlane2│ ControlPlane3│
      └──────────────┴──────────────┴──────────────┘
                     High Availability
                             │
                Kubernetes Scheduler
                             │
        ┌────────────────────┼────────────────────┐
        ▼                    ▼                    ▼
    Worker1              Worker2             Worker3
```

The cluster is fully declarative and can be recreated at any time using the `kind-config.yaml` configuration file.

---

## Troubleshooting

### WSL2 - Multi-node KIND Cluster

While creating a **6-node KIND cluster (3 control planes + 3 workers)** on WSL2, cluster creation initially failed during the `kubeadm join` phase.

#### Symptoms

- Cluster creation stopped at:
  - `Joining more control-plane nodes`
  - `Joining worker nodes`
- Error message:

```text
failed to join node with kubeadm
```

#### Root Cause

The default Linux **inotify** limit on WSL2 was too low.

The default value:

```text
fs.inotify.max_user_instances = 128
```

is sufficient for small clusters but not for larger KIND deployments where several Kubernetes nodes are started simultaneously.

#### Temporary Fix

```bash
sudo sysctl -w fs.inotify.max_user_instances=2048
sudo sysctl -w fs.inotify.max_user_watches=1048576
```

#### Permanent Fix

Create a dedicated sysctl configuration:

```bash
echo "fs.inotify.max_user_instances=2048" | sudo tee /etc/sysctl.d/99-kind.conf
echo "fs.inotify.max_user_watches=1048576" | sudo tee -a /etc/sysctl.d/99-kind.conf
sudo sysctl --system
```

#### Verification

```bash
cat /proc/sys/fs/inotify/max_user_instances
cat /proc/sys/fs/inotify/max_user_watches
```

Expected output:

```text
2048
1048576
```

After increasing the inotify limits, the 3-control-plane / 3-worker KIND cluster was successfully created.

## Kubernetes Recommended Labels

This project follows the official Kubernetes recommended application labels.

Implemented labels:

- `app.kubernetes.io/name`
- `app.kubernetes.io/instance`
- `app.kubernetes.io/version`
- `app.kubernetes.io/component`
- `app.kubernetes.io/part-of`
- `app.kubernetes.io/managed-by`

These labels improve resource organization and compatibility with Kubernetes tooling such as Helm, ArgoCD, Prometheus, Grafana, and Lens.

The Kubernetes Service selects Pods using the recommended label:

```yaml
selector:
  app.kubernetes.io/name: nginx
```