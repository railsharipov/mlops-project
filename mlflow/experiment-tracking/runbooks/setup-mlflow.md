## Setup MLFlow

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

### Run MLFlow web UI:
Listen on localhost and use sqlite for backend store:
```sh
mlflow ui \
    --host 127.0.0.1 \
    --backend-store-uri sqlite:///mlflow.db
```
Listen on Tailscale IP:
```sh
mlflow ui \
    --host $(tailscale ip -4) \
    --backend-store-uri sqlite:///mlflow.db
```
Use PostgreSQL as backend store:
```sh
mlflow ui \
    --host $(tailscale ip -4) \
    --backend-store-uri "postgresql+psycopg2://mlops@<POSTGRES_IP>:5432/mlflow"
```
