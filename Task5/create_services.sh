#!/bin/bash
echo "[INFO] Создаётся сервис front-end-app"
kubectl run front-end-app --image=nginx --labels role=front-end --expose --port 80
echo "[INFO] Создаётся сервис back-end-api-app"
kubectl run back-end-api-app --image=nginx --labels role=back-end-api --expose --port 80
echo "[INFO] Создаётся сервис admin-front-end-app"
kubectl run admin-front-end-app --image=nginx --labels role=admin-front-end --expose --port 80
echo "[INFO] Создаётся сервис admin-back-end-api-app"
kubectl run admin-back-end-api-app --image=nginx --labels role=admin-back-end-api --expose --port 80