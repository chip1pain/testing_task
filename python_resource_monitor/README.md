# Monitor System Resource Usage

This script monitors system resources such as CPU, memory, and disk usage. If usage exceeds a specified threshold, alerts are sent via Slack and logged locally.

## Features
- Monitors:
  - CPU usage
  - Memory usage
  - Disk usage
- Sends alerts via:
  - Slack webhook
  - Console output
  - Log file

## Prerequisites
- Python 3.x
- Required Python packages:
  - `psutil`
  - `requests`

Install the required packages with:
```bash
pip install psutil requests
```

## Usage

### Running the Script
The script accepts a Slack webhook URL as an argument and only runs when this argument is provided.

```bash
python monitor.py <slack_webhook_url>
```

### Example
```bash
python monitor.py https://hooks.slack.com/services/your/webhook/url
```

If no webhook URL is provided, the script will not start and will display a usage message.

### Default Threshold
By default, the threshold for resource usage alerts is set to **20%**. You can adjust this value directly in the script by modifying the `THRESHOLD` constant.

### Installing the Script as a System Service

To run the script as a service under systemd, follow these steps:

Copy the script to the appropriate directory: Copy monitor.py to /usr/local/bin/:
sudo cp monitor.py /usr/local/bin/monitor.py
### create a systemd service: Create a new systemd service file at /etc/systemd/system/resource_monitor.service:

```bash
cat <<EOF > /etc/systemd/system/resource_monitor.service
[Unit]
Description=System Resource Monitoring
After=network.target

[Service]
Environment="WEBHOOK_URL=https://hooks.slack.com/services/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"
ExecStart=/usr/bin/python3 /usr/local/bin/monitor.py --webhook-url $WEBHOOK_URL
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
```

### Enable and start the service: Enable the service to start on boot and start it immediately:
```bash
sudo systemctl enable resource_monitor.service
sudo systemctl start resource_monitor.service
```
### Check the service status: Verify that the service is running correctly:

```bash
sudo systemctl status resource_monitor.service
```

## Output
- Alerts are logged to the console and a log file named `monitor_system.log`.
- Alerts are sent to the specified Slack webhook.

## Code Breakdown
### Key Functions
- **`send_alert(resource, usage)`**: Sends an alert to Slack.
- **`send_alert_local(resource, usage)`**: Logs and prints alerts locally.
- **`monitor_resources()`**: Monitors system resources in a loop and triggers alerts if thresholds are exceeded.

### Main Workflow
1. Parse the Slack webhook URL from the command line arguments.
2. Start monitoring system resources.
3. Send alerts if usage exceeds the defined threshold.

## Enhancements
- The script includes a usage message and parameter parsing.
- You can dynamically specify the Slack webhook URL at runtime.

## Future Improvements
- Add support for monitoring network bandwidth.
- Implement configurable thresholds via environment variables or a configuration file.

## Log File
All activities and errors are logged in `monitor_system.log` located at /var/log/monitor_system.log.


