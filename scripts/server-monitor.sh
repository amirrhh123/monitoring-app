
check_disk() {
    local DISK=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

    [ "$DISK" -gt "$ALERT_DISK" ] \
        && log "WARN " "[DISK] ${DISK}% > threshold" \
        || log "INFO " "[DISK] ${DISK}% OK"
}
