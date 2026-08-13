# MLOps project

## VM setup
See `gcp/infra/README.md` for details about VM setup.

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
