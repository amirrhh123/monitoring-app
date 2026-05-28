
check_disk() {
    local DISK=$(df / | awk 'NR==2{print int($5)}')
    [ "$DISK" -gt "$ALERT_DISK" ] \
        && log "WARN " "[DISK] ${DISK}% > threshold" \
        || log "INFO " "[DISK] ${DISK}% OK"
}
