# Server Monitor A bash script that monitors server health — services, CPU, memory, disk usage, and HTTP endpoints.
## Features - Service status check via `systemctl` - CPU and memory threshold alerts - HTTP endpoint health checks - Automatic log rotation
## Usage ```bash # Setup chmod 750 scripts/server-monitor.sh cp config/settings.conf.example config/settings.conf # Run ./scripts/server-monitor.sh 
# Schedule (cron every 5 min) */5 * * * * /home/monitor/monitoring-app/scripts/server-monitor.sh ```
## Configuration Edit `config/settings.conf` to set thresholds and services.
