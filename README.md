
# Summary:

In this project, I implemented a GitOps pipeline using Argo CD and Argo Rollouts for automated deployment and canary release of a web application on Kubernetes. Here's a detailed summary of the steps I took, challenges encountered, and how I resolved them.



## Steps

### 1) Setting up the Git Repository:

```bash
git clone <repository-url>
cd <repository-name>
# Add application code
git add .
git commit -m "Initial commit"
git push origin main

```
### 2) Installing Kubernetes using minikube with argocd & argo rollouts:
- To install the latest minikube stable release on x86-64 Windows using .exe download:
https://minikube.sigs.k8s.io/docs/start/

or
Download and run the installer for the latest release.
Or if using PowerShell, use this command:
    
    
    New-Item -Path 'c:\' -Name 'minikube' -ItemType Directory -Force
    Invoke-WebRequest -OutFile 'c:\minikube\minikube.exe' -Uri 'https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe' -UseBasicParsing
    
    
    
- Start your cluster

```bash
minikube start
```
- Verify
![Screenshot 2024-05-17 025514](https://github.com/suhaspete/sample-app/assets/99081809/f7975256-7f2c-4e16-9066-295e8f7b42d4)


- Installing Argo CD on Kubernetes Cluster:

``` bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.7/manifests/install.yaml
kubectl get svc -n argocd
kubectl port-forward svc/argocd-server 8080:443 -n argocd
```


- Login Using The CLI
```bash
argocd admin initial-password -n argocd
```
- Grab the password to login to the dashboard
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```
- Create a new Application in Argo CD
![Screenshot 2024-05-17 032356](https://github.com/suhaspete/sample-app/assets/99081809/a325e40c-6fec-4882-9409-ab45f3a4e74c)

- Put the github repository link and continue

#### [Argo CD Documentation](https://linktodocumentation)

- Installing Argo Rollouts:

```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

- Watching rollouts

1) Via CLI:
```bash
kubectl argo rollouts get rollout rollouts-demo --watch
```
![Screenshot 2024-05-17 033932](https://github.com/suhaspete/sample-app/assets/99081809/e45136dc-e885-4bcb-840c-eb15dde423f1)


2) Dashboard:
```bash
kubectl argo rollouts dashboard
```
![Screenshot 2024-05-17 034109](https://github.com/suhaspete/sample-app/assets/99081809/fe1a9879-5300-4b87-b0b8-e0cc15baca47)


#### [Argo Rollouts Documentation](https://argo-rollouts.readthedocs.io/en/stable/installation/)


### 3) Dockerizing the Application:

-    Dockerized the web application by creating a Dockerfile.
-   Built a Docker image for the application.
-   Pushed the Docker image to a public container registry.

``` bash
docker build -t sample-app .
docker push suhaspete/sample-app

```

### 4) Deploying the Application Using Argo CD:

- Modified Kubernetes manifests in the repository to use the Docker image.
- Configured Argo CD to monitor the repository and automatically deploy changes to the Kubernetes cluster.

![Screenshot 2024-05-17 044431](https://github.com/suhaspete/sample-app/assets/99081809/41a961b2-245f-4eee-934b-85486e9388b4)

- If you make any changes just refresh it by pressing refresh button
- If any new version is created for example: sample-app:2, then automatically it will sync, if all code are running correctly

### 5) Implementing a Canary Release with Argo Rollouts:
- Creating a file named rollout.yaml
- Put the below code
``` bash
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: my-frontend-rollout
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-frontend-app
  template:
    metadata:
      labels:
        app: my-frontend-app
    spec:
      containers:
        - name: my-frontend-app
          image: sample-app
          ports:
            - containerPort: 80
  strategy:
    canary:
      steps:
        - setWeight: 10
        - pause:
            duration: 60s
        - setWeight: 25
        - pause:
            duration: 60s
        - setWeight: 50
        - pause:
            duration: 60s
        - setWeight: 100
  # Add additional fields as needed
  #

```
-  Verify
![Screenshot 2024-05-17 034512](https://github.com/suhaspete/sample-app/assets/99081809/9dcaa86c-e98a-4f84-b4e2-7a4988c84d7c)

and 
![Screenshot 2024-05-17 035536](https://github.com/suhaspete/sample-app/assets/99081809/cea73400-28d6-4089-b2d2-a0061b88e763)

![Screenshot 2024-05-17 041037](https://github.com/suhaspete/sample-app/assets/99081809/0de0e062-f124-495d-888c-fa1dae7a80ff)




### Challenges Encountered and Solutions:

#### During the course of this project, I encountered several challenges, yet I remained resolute in my commitment to finding solutions. Each obstacle presented an opportunity for growth and problem-solving, and I approached them with determination ensuring that they were effectively resolved.


### 1) Minikube was stopped by Windows Defender


![75090643-decc4c00-558a-11ea-8898-1a2c886f93cd](https://github.com/suhaspete/sample-app/assets/99081809/546dad6e-3242-4aba-9060-8709fc2f43f4)

### Solutions: 
- Press Run Anyway or
- Upload in Whitelist of Windows Defender

### 2) When i run, it is not updating 
```bash
kubectl apply -f .\application.yaml
```

### Solution 
- Sync Status: Check the sync status of your Argo CD application to see if there are any errors or warnings. You can do this by viewing the application details in the Argo CD UI or by using the Argo CD CLI:
```bash
argocd app get <application-name>
```
- Look for any errors or warnings in the output that might indicate why the sync is failing.

### 3) Minikube is not running properly

![photo_2024-05-15_02-38-17](https://github.com/suhaspete/sample-app/assets/99081809/286c9f2a-763f-47ff-b725-9053b9c73146)

- Press the Windows logo key + I simultaneously to open the Settings menu
- Click on Apps and then click Optional features.
- Scroll down Apps >More Windows features
- Select Hyper-V and then click OK


### 4)  Unable to connect server : dail tcp 127.0.0.1 error
![photo_2024-05-16_20-25-38](https://github.com/suhaspete/sample-app/assets/99081809/0fe9b64c-1574-40a2-84dd-bff4cae23372)

- By running
```bash
minikube stop
minikube start
```

#### 5) Lost connection to pod
![Screenshot 2024-05-17 050446](https://github.com/suhaspete/sample-app/assets/99081809/993a5cc0-e393-46c4-b163-8f7a84f8ac89)

- Step 1: Check the Pod Status
```bash
kubectl get pods

```
- Step 2: Verify the Application is Listening on Port 8080
```bash
kubectl exec -it <pod-name> -- /bin/sh
# Once inside the pod
netstat -tuln

```

- Step 3: Inspect Network Policies
If your Kubernetes cluster is using Network Policies, ensure that there is no policy blocking the traffic. You can list the network policies using:
```bash
kubectl get networkpolicies

```

- Step 5: Check the Service Configuration
```bash
kubectl get svc
kubectl describe svc <service-name>

```

- Step 6: Recreate the Pod
```bash
kubectl delete pod <pod-name>

```
- Step 7: Look at Port Forwarding
```bash
kubectl port-forward <pod-name> 8090:8080

```
## Clean Up

- To cleanly remove all resources created during this assignment from the Kubernetes cluster, follow these steps:

#### 1) Delete Argo CD Resources:
```bash
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

```

#### 2) Delete Argo Rollouts Resources:

```bash
kubectl delete -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

```

#### 3) Delete Application Resources:
- Delete the Kubernetes resources 
```bash
kubectl delete -f <path/to/file>
```

#### 4) Delete Docker Image 

![Screenshot 2024-05-17 024956](https://github.com/suhaspete/sample-app/assets/99081809/c23460ce-41cb-4c5b-a8df-1a9e784f4ef0)
