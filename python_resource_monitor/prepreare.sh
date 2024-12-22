#!/bin/bash

# Проверка и установка Python и pip3
echo "Checking for Python3 and pip3..."
if ! command -v python3 &>/dev/null; then
  echo "Python3 is not installed. Installing..."
  sudo apt-get update
  sudo apt-get install -y python3
fi

if ! command -v pip3 &>/dev/null; then
  echo "pip3 is not installed. Installing..."
  sudo apt-get install -y python3-pip
fi

# Установка необходимых Python модулей
echo "Checking for required Python modules..."
if ! python3 -c "import psutil" &>/dev/null; then
  echo "psutil module not found. Installing..."
  sudo pip3 install psutil
fi

if ! python3 -c "import requests" &>/dev/null; then
  echo "requests module not found. Installing..."
  sudo pip3 install requests
fi

# Создание файла для systemd сервиса
echo "Creating systemd service..."
cat <<EOF | sudo tee /etc/systemd/system/resource_monitor.service
[Unit]
Description=System Resource Monitoring
After=network.target

[Service]
Environment="WEBHOOK_URL=${1}"
ExecStart=/usr/bin/python3 /usr/local/bin/monitor.py --webhook-url \$WEBHOOK_URL
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Копирование скрипта monitor.py и установка прав
echo "Copying the monitor script..."
sudo cp -r ../python_resource_monitor/monitor.py /usr/local/bin/monitor.py
sudo chmod +x /usr/local/bin/monitor.py

# Перезагрузка systemd и запуск сервиса
echo "Reloading systemd and starting the service..."
sudo systemctl daemon-reload
sudo systemctl enable resource_monitor.service
sudo systemctl start resource_monitor.service

