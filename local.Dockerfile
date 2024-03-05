FROM python:3.10.6-slim-buster

WORKDIR /mlflow

RUN pip install --upgrade pip
RUN pip install mlflow

EXPOSE 5000

CMD mlflow ui --host 0.0.0.0 --port 5000
