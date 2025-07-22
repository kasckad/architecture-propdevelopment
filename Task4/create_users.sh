#!/bin/bash

set -e

mkdir -p users && cd users

# === Пользователи и соответствующие группы ===
USERS=(
  "admin-user:system-admins"
  "dev-user:developers"
  "analyst1:analysts"
  "qa1:testers"
  "monitor:monitoring"
  "sec1:security-team"
)

CA_CERT="$HOME/.minikube/ca.crt"
CA_KEY="$HOME/.minikube/ca.key"
CLUSTER_NAME="minikube"

for user_data in "${USERS[@]}"; do
  user=$(echo "$user_data" | cut -d':' -f1)
  group=$(echo "$user_data" | cut -d':' -f2)

  echo "[INFO] Создаётся пользователь '$user' с группой '$group'..."

  # Генерация ключа
  openssl genrsa -out "$user.key" 2048

  # Создание CSR
  openssl req -new -key "$user.key" -out "$user.csr" -subj "/CN=$user/O=$group"

  # Подпись сертификата
  openssl x509 -req -in "$user.csr" -CA "$CA_CERT" -CAkey "$CA_KEY" -CAcreateserial \
    -out "$user.crt" -days 365 -sha256

  # Добавление пользователя в kubeconfig
  kubectl config set-credentials "$user" \
    --client-certificate="$user.crt" \
    --client-key="$user.key" \
    --embed-certs=true

  # Добавление контекста
  kubectl config set-context "$user-context" \
    --cluster="$CLUSTER_NAME" \
    --user="$user"

  echo "[OK] Пользователь '$user' создан."
done

echo
echo "Все пользователи созданы. Используйте:"
for user_data in "${USERS[@]}"; do
  user=$(echo "$user_data" | cut -d':' -f1)
  echo "kubectl config use-context $user-context"
done
