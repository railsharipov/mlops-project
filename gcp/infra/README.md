# GCP infrastructure for MLOPS project

## Bootstrap `gcloud` CLI tool
+ Install `gcloud` CLI: https://docs.cloud.google.com/sdk/docs/install-sdk
+ Authenticate for the `gcloud` CLI: https://docs.cloud.google.com/sdk/docs/authenticate

## Setup SSH keypair for GCP VM
+ Create your SSH keypair: https://docs.cloud.google.com/compute/docs/connect/create-ssh-keys
+ Public SSH key will be required later to deploy GCP infrastructure
+ Private SSH key will be required later to login to VM instance

## Bootstrap Tailscale

### Install Tailscale client on your machine
+ Go to your tailscale admin console at https://console.tailscale.com/admin/machines
+ Download and install Tailscale client

### Create Tailscale auth key
+ Go to your tailscale admin console at https://console.tailscale.com/admin/settings/keys
+ Create an auth key and save it securely 

### Create Tailscale GCP secret
```sh
echo -n $TAILSCALE_AUTH_KEY | gcloud secrets create tailscale-auth-key \
  --project="$PROJECT_ID" \
  --replication-policy="automatic" \
  --labels="group=mlops" \
  --data-file=-
```

## Create Postgres DB password
```sh
echo -n $POSTGRES_PASSWORD | gcloud secrets create postgres-password \
  --project="$PROJECT_ID" \
  --replication-policy="automatic" \
  --labels="group=mlops" \
  --data-file=-
```

## Create Jupyter token
```sh
echo -n $JUPYTER_TOKEN | gcloud secrets create jupyter-token \
  --project="$PROJECT_ID" \
  --replication-policy="automatic" \
  --labels="group=mlops" \
  --data-file=-
```

### Deploy GCP infrastructure
+ Run Terraform commands:
```sh
terraform init
terraform plan
terraform apply
```
+ Wait for VM instance to finish all the installations (few minutes)
+ Check your Tailscale client UI whether VM instance is now part of the tailnet
+ Copy tailnet IP for VM instance

## VM instance login
```sh
ssh -i "${SSH_PRIVATE_KEY_PATH}" "${SSH_USER}@${TAILNET_IP}"
```

## Pre-installed tools on a VM instance
The deployed GCP VM instance installs following on startup:
+ Anaconda
+ Docker packages
+ `curl`, `jq`
+ Tailscale server

## Setup Anaconda
Login to VM and init conda:
```sh
/opt/anaconda3/bin/conda init
```
Re-login to shell to activate based conda environment:
```sh
exec bash
```
You should now have conda in your PATH:
```sh
conda --version
```
