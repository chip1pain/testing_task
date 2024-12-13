import psutil
import logging
import time
import requests
import argparse
import sys

# Настройка логирования
LOG_FILE = "/var/log/monitor_system.log"
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)

# Пороговые значения
THRESHOLD = 20

def send_alert(resource, usage, webhook_url):
    message = f"{resource} usage is high: {usage:.2f}%"
    try:
        response = requests.post(webhook_url, json={"text": message})
        response.raise_for_status()
        logging.info(f"Alert sent: {message}")
    except requests.RequestException as e:
        logging.error(f"Failed to send alert: {e}")

def send_alert_local(resource, usage):
    message = f"ALERT: {resource} usage is high: {usage:.2f}%"
    print(message)  # Вывод в консоль
    logging.info(message)  # Запись в лог

def monitor_resources(webhook_url):
    while True:
        try:
            # Проверка CPU
            cpu_usage = psutil.cpu_percent(interval=1)
            print(cpu_usage)
            if cpu_usage > THRESHOLD:
                send_alert_local("CPU", cpu_usage)
                send_alert("CPU", cpu_usage, webhook_url)

            # Проверка памяти
            memory = psutil.virtual_memory()
            print(memory)

            if memory.percent > THRESHOLD:
                send_alert("Memory", memory.percent, webhook_url)
                send_alert_local("Memory", memory.percent)

            # Проверка диска
            disk = psutil.disk_usage("/")
            print(disk)
            if disk.percent > THRESHOLD:
                send_alert("Disk", disk.percent, webhook_url)
                send_alert_local("Disk", disk.percent)

            time.sleep(60)  # Интервал проверки
        except Exception as e:
            logging.error(f"Error during monitoring: {e}")

def main():
    # Парсинг аргументов командной строки
    parser = argparse.ArgumentParser(description="Monitor system resources and send alerts.")
    parser.add_argument("webhook", help="Slack webhook URL for alert notifications.")
    args = parser.parse_args()

    # Проверка, что URL передан
    if not args.webhook:
        print("Error: Webhook URL is required!")
        sys.exit(1)

    # Запуск мониторинга
    monitor_resources(args.webhook)

if __name__ == "__main__":
    main()
