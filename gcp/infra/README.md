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

## Serving endpoints on GCP VM

### Direct access
Tailscale provides network connectivity between tailnet devices, so the client connects directly to the service just as it would to any other reachable IP and port. For example:
```sh
curl http://${TAILNET_IP}/8080
```
The service must listen on the Tailscale interface or all interfaces. For example, to run Jupyter Lab server listening on tailnet IP:
```sh
jupyter lab \
  --no-browser \
  --ip="$(tailscale ip -4)" \
  --port=8888 \
  --ServerApp.allow_remote_access=True
```
If service listens only on localhost other tailnet devices cannot reach it directly.

### Access with Tailscale Serve
If the application listens only on localhost, configure Tailscale Serve on the VM:
```sh
sudo tailscale serve --https=443 http://127.0.0.1:8080
```
Then access it from another tailnet device using the generated MagicDNS hostname:
```sh
curl https://mlops-vm.<your-tailnet>.ts.net
```

### Tailscale TCP proxy
You can also use Tailscale Serve as a raw TCP forwarder:
```sh
sudo tailscale serve --tcp=9000 tcp://127.0.0.1:9000
```
Tailscale documents this for raw TCP services such as SSH, RDP, and other TCP-based protocols.

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
