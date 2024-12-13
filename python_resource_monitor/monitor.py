import psutil
import logging
import time
import requests
import argparse
import sys

# Logging configuration
LOG_FILE = "/var/log/monitor_system.log"
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)

# Threshold values
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
    print(message)  # Output to console
    logging.info(message)  # Write to log file

def monitor_resources(webhook_url):
    while True:
        try:
            # Check CPU usage
            cpu_usage = psutil.cpu_percent(interval=1)
            print(cpu_usage)
            if cpu_usage > THRESHOLD:
                send_alert_local("CPU", cpu_usage)
                send_alert("CPU", cpu_usage, webhook_url)

            # Check memory usage
            memory = psutil.virtual_memory()
            print(memory)
            if memory.percent > THRESHOLD:
                send_alert("Memory", memory.percent, webhook_url)
                send_alert_local("Memory", memory.percent)

            # Check disk usage
            disk = psutil.disk_usage("/")
            print(disk)
            if disk.percent > THRESHOLD:
                send_alert("Disk", disk.percent, webhook_url)
                send_alert_local("Disk", disk.percent)

            time.sleep(60)  # Monitoring interval
        except Exception as e:
            logging.error(f"Error during monitoring: {e}")

def main():
    # Command-line arguments parsing
    parser = argparse.ArgumentParser(description="Monitor system resources and send alerts.")
    parser.add_argument("--webhook-url", required=True, help="Slack webhook URL for alert notifications.")
    args = parser.parse_args()

    # Check if the URL is provided
    if not args.webhook_url:
        print("Error: Webhook URL is required!")
        sys.exit(1)

    # Start monitoring
    monitor_resources(args.webhook_url)

if __name__ == "__main__":
    main()
