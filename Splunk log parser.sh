#!/bin/bash

# Log file locations (adjust paths based on your system)
AUTH_LOG="/var/log/auth.log"
APACHE_LOG="/var/log/apache2/access.log"
OUTPUT_LOG="/var/log/filtered_security_events.log"

# Splunk HTTP Event Collector (HEC) details
SPLUNK_HEC_URL="http://your-splunk-server:8088/services/collector"
SPLUNK_HEC_TOKEN="your-splunk-hec-token"

# Function to filter security-related events
filter_logs() {
  echo "[INFO] Filtering logs for security events..."
  # Example filters: failed SSH logins, Apache 403 errors
  grep -E "Failed password|authentication failure|403" "$AUTH_LOG" "$APACHE_LOG" > "$OUTPUT_LOG"
}

# Function to send filtered logs to Splunk
send_to_splunk() {
  echo "[INFO] Sending logs to Splunk..."
  while IFS= read -r line; do
    curl -k $SPLUNK_HEC_URL \
      -H "Authorization: Splunk $SPLUNK_HEC_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"event\": \"$line\", \"sourcetype\": \"manual_security_logs\"}"
  done < "$OUTPUT_LOG"
}

# Main function
main() {
  echo "[INFO] Starting log monitoring and forwarding..."
  filter_logs
  send_to_splunk
  echo "[INFO] Process completed."
}

main
