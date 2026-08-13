## Setup Jupyter Lab Server

### Prerequisites
+ Install Python3
+ Setup Python environment and activate it

### Install requirements
+ Create `requirements.txt` file with following content:
```
mlflow
jupyter
scikit-learn
pandas
seaborn
hyperopt
xgboost
```
+ Install requiremnts using `pip`:
```sh
pip install -r requirements.txt
```

### Run Jupyter Lab Server
+ Listen on localhost:
```sh
jupyter lab --no-browser --ip="127.0.0.1" --port=8888 --ServerApp.allow_remote_access=True
```
+ Serve in tailnet:
```sh
sudo tailscale serve --https=8888 http://127.0.0.1:8888
```
