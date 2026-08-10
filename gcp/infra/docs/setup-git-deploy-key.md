## Setup Github repo deploy key

## Setup SSH keypair
+ Login to VM and run this command to generate SSH keypair:
```sh
ssh-keygen -t ed25519 \
  -C "mlops-vm-github-deploy" \
  -f ~/.ssh/github_deploy
```
+ Setup permissions for the SSH key:
```sh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/github_deploy
chmod 644 ~/.ssh/github_deploy.pub
```

## Create GH deploy deploy key
+ Go to following section in your GH repo:
```
Repository → Settings → Deploy keys → Add deploy key
```
+ Use SSH pubkey for setting up deploy key:
```
~/.ssh/github_deploy.pub
```

## Configure SSH on the VM
+ Create `~/.ssh/config` with following content:
```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_deploy
    IdentitiesOnly yes
```
+ Set permissions for the config file:
```sh
chmod 600 ~/.ssh/config
```
+ Test authentication:
```sh
ssh -T git@github.com
```
