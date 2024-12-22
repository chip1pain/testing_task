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

def send_alert_slack(resource, usage, webhook_url):
    """Send alert to Slack."""
    message = f"{resource} usage is high: {usage:.2f}%"
    try:
        response = requests.post(webhook_url, json={"text": message})
        response.raise_for_status()
        logging.info(f"Slack alert sent: {message}")
    except requests.RequestException as e:
        logging.error(f"Failed to send Slack alert: {e}")

def send_alert_prometheus(resource, usage, pushgateway_url):
    """Send metric to Prometheus Pushgateway."""
    metric_name = resource.lower()  # e.g., "CPU" -> "cpu"
    job = "system_monitor"
    data = f"{metric_name}_usage {usage}\n"
    try:
        response = requests.post(f"{pushgateway_url}/metrics/job/{job}", data=data)
        response.raise_for_status()
        logging.info(f"Prometheus metric sent: {metric_name}_usage={usage}")
    except requests.RequestException as e:
        logging.error(f"Failed to send metric to Prometheus: {e}")

def send_alert_local(resource, usage):
    """Log and print alert locally."""
    message = f"ALERT: {resource} usage is high: {usage:.2f}%"
    print(message)  # Output to console
    logging.info(message)  # Write to log file

def monitor_resources(webhook_url, pushgateway_url):
    while True:
        try:
            # Check CPU usage
            cpu_usage = psutil.cpu_percent(interval=1)
            if cpu_usage > THRESHOLD:
                send_alert_local("CPU", cpu_usage)
                if webhook_url:
                    send_alert_slack("CPU", cpu_usage, webhook_url)
                if pushgateway_url:
                    send_alert_prometheus("cpu", cpu_usage, pushgateway_url)

            # Check memory usage
            memory = psutil.virtual_memory()
            if memory.percent > THRESHOLD:
                send_alert_local("Memory", memory.percent)
                if webhook_url:
                    send_alert_slack("Memory", memory.percent, webhook_url)
                if pushgateway_url:
                    send_alert_prometheus("memory", memory.percent, pushgateway_url)

            # Check disk usage
            disk = psutil.disk_usage("/")
            if disk.percent > THRESHOLD:
                send_alert_local("Disk", disk.percent)
                if webhook_url:
                    send_alert_slack("Disk", disk.percent, webhook_url)
                if pushgateway_url:
                    send_alert_prometheus("disk", disk.percent, pushgateway_url)

            time.sleep(60)  # Monitoring interval
        except Exception as e:
            logging.error(f"Error during monitoring: {e}")

def main():
    # Command-line arguments parsing
    parser = argparse.ArgumentParser(description="Monitor system resources and send alerts.")
    parser.add_argument("--webhook-url", help="Slack webhook URL for alert notifications.")
    parser.add_argument("--pushgateway-url", help="Prometheus Pushgateway URL for sending metrics.")
    args = parser.parse_args()

    # Check if at least one URL is provided
    if not args.webhook_url and not args.pushgateway_url:
        print("Error: Either --webhook-url or --pushgateway-url must be provided!")
        sys.exit(1)

    # Start monitoring
    monitor_resources(args.webhook_url, args.pushgateway_url)

if __name__ == "__main__":
    main()


