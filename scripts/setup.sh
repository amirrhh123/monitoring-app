#!/bin/bash
# ═══════════════════════════════════════════
#  server-monitor.sh — پروژه‌ی نهایی فاز ۱
#  اجرا: ./scripts/server-monitor.sh
# ═══════════════════════════════════════════

# ── بارگذاری تنظیمات (اپیزود ۳: کار با فایل‌ها) ──
CONFIG_FILE="$(dirname "$0")/../config/settings.conf"
server_monitor="$(dirname "$0")/server-monitor.sh"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: config not found: $CONFIG_FILE"; exit 1
fi
source "$CONFIG_FILE"
source "$server_monitor"


LOG_FILE="$(dirname "$0")/../logs/app.log"
ARCHIVE_DIR="$(dirname "$0")/../logs/archive"

# ── توابع اصلی (اپیزود ۷: Shell Scripting) ──
log() {
    local LEVEL="$1" MSG="$2"
    local TS=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$TS] [$LEVEL] $MSG" | tee -a "$LOG_FILE"
}

# بررسی سرویس‌ها (اپیزود ۴: پروسه‌ها)
check_services() {
    for SVC in $SERVICES; do
        if systemctl is-active --quiet "$SVC"; then
            log "INFO " "[SERVICE] $SVC ✓ running"
        else
            log "ERROR" "[SERVICE] $SVC ✗ DOWN"
        fi
    done
}

# بررسی CPU و Memory (اپیزود ۱: /proc)
check_resources() {
    local CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
    local MEM=$(free | awk '/Mem/{printf int($3/$2*100)}')

    [ "$CPU" -gt "$ALERT_CPU" ] \
        && log "WARN " "[CPU] ${CPU}% > threshold ${ALERT_CPU}%" \
        || log "INFO " "[CPU] ${CPU}% OK"

    [ "$MEM" -gt "$ALERT_MEM" ] \
        && log "WARN " "[MEM] ${MEM}% > threshold ${ALERT_MEM}%" \
        || log "INFO " "[MEM] ${MEM}% OK"
}

# HTTP health check (اپیزود ۶: شبکه)
check_endpoints() {
    for URL in $ENDPOINTS; do
        local CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$URL")
        if [ "$CODE" = "200" ]; then
            log "INFO " "[HTTP] $URL → $CODE ✓"
        else
            log "ERROR" "[HTTP] $URL → $CODE ✗"
        fi
    done
}

# آرشیو لاگ‌های قدیمی (اپیزود ۳: cp، mv، find)
rotate_logs() {
    mkdir -p "$ARCHIVE_DIR"
    find "$(dirname "$LOG_FILE")" -name "*.log" -mtime +${LOG_RETENTION_DAYS} \
        -exec mv {} "$ARCHIVE_DIR/" \;
    log "INFO " "[ROTATE] logs older than ${LOG_RETENTION_DAYS}d archived"
}

# ── اجرای اصلی ──
log "INFO " "════ Monitor Start | host: $(hostname) ════"
check_services
check_resources
check_endpoints
rotate_logs
check_disk
log "INFO " "════ Monitor Done ════"