## Troubleshoot startup script on a VM instance

### Check the startup log file
```sh
sudo tail -n 200 /var/log/startup-script.log
```

### Inspect the startup service
```sh
sudo systemctl status google-startup-scripts.service --no-pager
```
```sh
sudo journalctl -u google-startup-scripts.service \
  --no-pager \
  -n 200
```

## Follow live during a reboot
```sh
sudo journalctl -fu google-startup-scripts.service
```

### Inspect Google Guest agent
```sh
sudo journalctl -u google-guest-agent.service \
  --no-pager \
  -n 200
```

## Troubleshoot startup script if not on VM instance

### Use serial-port output from your local machine
```sh
gcloud compute instances get-serial-port-output mlops-vm \
  --zone=us-central1-a \
  --port=1
```

### Test the new/fixed startup script without restarting VM instance
```sh
sudo google_metadata_script_runner startup
```
