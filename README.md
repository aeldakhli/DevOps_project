# DevOps_project
This is a project to follow GitOps practices.
# lab

## lab-domain
glab.devops-labs.site

## lab-jump
jump.glab.devops-labs.site

### Jump node
- keypair
- ssh
```
#!/bin/bash
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=permissive/g" /etc/selinux/config
sed -i "s/#Port 22/Port 443/g" /etc/ssh/sshd_config
systemctl restart sshd
yum clean all
yum install -y vim bash-completion wget
reboot
```

### create new user

```
sudo useradd user1

sudo su - user1
ssh-keygen -t rsa
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

sudo usermod -aG wheel user1
```

### VScode remote plugin
https://code.visualstudio.com/docs/remote/ssh
https://www.digitalocean.com/community/tutorials/how-to-use-visual-studio-code-for-remote-development-via-the-remote-ssh-plugin

vscode installed
ssh client installed

install **remote-ssh** extenstion

configure ssh info
```
Host group_jump
    HostName 90.84.174.90
    Port 443
    User cloud
    IdentityFile C:\Data\keys\group-lab-jump.pem
```

## Infra Part
Managed K8s Cluster deployed (CCE)
- ingress controller
- certificate-manager with let's encrypt certificates
- ArgoCD 

Client Machine
- kubectl
- helm
- git

### New VPC
10.0.0.0/16
- CIDR
- subnets
    - 10.0.1.0/24
- security group
    - allow all or needed ports only
- Natgw



### CCE Cluster v1.25
- Create cce cluster 
    - control plane  
        - storage csi driver
        - coredns
    - worker nodes


## Client Tools
### kubectl
kubectl version within one minor version difference of your cluster.
cluster version 1.25
kubectl can be 1.24 or 1.25 or 1.26

https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
```
curl -LO https://dl.k8s.io/release/v1.26.0/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

command completion
```
source <(kubectl completion bash) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.
echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanently to your bash shell.
```

cluster configuration

```
mkdir -p $HOME/.kube
vim $HOME/.kube/config

kubectl config use-context internal
kubectl cluster-info
```

### Helm
https://helm.sh/docs/intro/install/

```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm version

source <(helm completion bash)
echo "source <(helm completion bash)" >> ~/.bashrc
```

### Git New Version 2.x

```
sudo yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm
sudo yum install -y git
git --version

git config --global user.name "Your Name"
git config --global user.email "user@exmample.com"
git config --global credential.helper store
```


### ArgoCD
https://blog.fourninecloud.com/installing-argo-cd-using-helm-ed4a0cd0845a
https://artifacthub.io/packages/helm/argo/argo-cd

```
helm repo add argo https://argoproj.github.io/argo-helm

helm repo list
helm repo update

helm search repo argo/argo-cd
NAME        	CHART VERSION	APP VERSION	DESCRIPTION                                       
argo/argo-cd	5.36.7       	v2.7.6     	A Helm chart for Argo CD, a declarative, GitOps...

helm pull --untar argo/argo-cd --version 5.36.7

or

helm upgrade --install argocd argo/argo-cd --version 5.36.7 --namespace argocd --create-namespace --values values.yaml


helm list -n argocd
NAME  	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART         	APP VERSION
argocd	argocd   	1       	2023-06-26 10:49:10.954938074 +0000 UTC	deployed	argo-cd-5.36.7	v2.7.6    

```

## GitOps
- App deployment to k8s

## DevOps CI
- App image build to image registery ex. docket hub
- update gitops repo with new 

## Logging and Monitoring
- Prometheus & Grafana
- Filebeat-Logstash-ELK
