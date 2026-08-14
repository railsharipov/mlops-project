## Setup MLFlow

## Manual installation

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
+ Listen on localhost and use sqlite for backend store:
```sh
mlflow ui \
    --host 127.0.0.1 \
    --backend-store-uri sqlite:///mlflow.db
```
+ OR use PostgreSQL as backend store and GCP bucket as artifact store:
```sh
mlflow ui \
    --host 127.0.0.1 \
    --backend-store-uri "postgresql+psycopg2://mlops@postgres.internal.mlops.net:5432/mlops" \
    --default-artifact-root "gs://<GCP_BUCKET>"
```
