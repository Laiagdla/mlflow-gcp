### GCLOUD MLFLOW DOCKERFILE ###
FROM python:3.10.6-slim-buster

WORKDIR /mlflow

RUN pip install --upgrade pip
RUN pip install mlflow

CMD mlflow ui --host 0.0.0.0 --port $PORT
