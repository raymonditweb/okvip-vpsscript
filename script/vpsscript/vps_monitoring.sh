#!/bin/bash

# Kiểm tra quyền root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Vui lòng chạy script này với quyền root."
  exit 1
fi

# Đặt tên file log
logfile="/var/log/script_log.txt"

# Ghi log - Hàm
log_message() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $logfile
}

# Kiểm tra tham số đầu vào, xác định loại thu thập dữ liệu
if [[ "$1" == "today" ]]; then
  num_samples=5 # Số sample cho "today"
  log_message "Collecting data for today..."
elif [[ "$1" == "yesterday" ]]; then
  num_samples=5 # Số sample cho "yesterday"
  log_message "Collecting data for yesterday..."
elif [[ "$1" == "7day" ]]; then
  num_samples=7 # Số sample cho "7day"
  log_message "Collecting data for the last 7 days..."
elif [[ "$1" == "30day" ]]; then
  num_samples=7 # Số sample cho "30day"
  log_message "Collecting 7 samples for the last 30 days..."
elif [[ "$1" == "range" && -n "$2" && -n "$3" ]]; then
  start_date="$2" # Ngày bắt đầu
  end_date="$3"   # Ngày kết thúc
  num_samples=5   # Số sample cho "range"
  log_message "Collecting data from $start_date to $end_date..."
else
  log_message "Error: Sử dụng: $0 {today|yesterday|7day|30day|range start_date end_date}"
  exit 1
fi

# Hàm chuyển đổi ngày thành số ngày kể từ hiện tại
date_to_days() {
  date -d "$1" +%s
}

# Hàm tính toán số giây giữa hai ngày
seconds_between() {
  start_date_epoch=$(date_to_days "$1")       # Chuyển đổi ngày bắt đầu thành epoch time
  end_date_epoch=$(date_to_days "$2")         # Chuyển đổi ngày kết thúc thành epoch time
  echo $((end_date_epoch - start_date_epoch)) # Tính số giây
}

# Lưu trữ tổng số liệu để tính trung bình
total_cpu=0
total_memory=0
total_disk=0
total_rx=0
total_tx=0
total_load=0

# Kiểm tra lỗi cho lệnh sau
check_error() {
  if [ $? -ne 0 ]; then
    log_message "Error: $1  - Vui lòng kiểm tra lại."
    return 1
  fi
}

# Hàm thu thập các thông số hệ thống
collect_system_stats() {
  # CPU Usage
  cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
  check_error "Error: Không thể lấy dữ liệu CPU."
  total_cpu=$(echo "$total_cpu + $cpu_usage" | bc)

  # Memory Usage
  memory_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
  check_error "Error: Không thể lấy dữ liệu Memory usage"
  total_memory=$(echo "$total_memory + $memory_usage" | bc)

  # Disk Usage
  disk_usage=$(df -h / | grep / | awk '{ print $5 }' | sed 's/%//g')
  check_error "Error: Không thể lấy dữ liệu Disk usage"
  total_disk=$(echo "$total_disk + $disk_usage" | bc)

  # Network RX/TX
  network_rx=$(cat /sys/class/net/eth0/statistics/rx_bytes)
  network_tx=$(cat /sys/class/net/eth0/statistics/tx_bytes)
  check_error "Error: Không thể lấy dữ liệu Network traffic"

  sleep 1

  network_rx_new=$(cat /sys/class/net/eth0/statistics/rx_bytes)
  network_tx_new=$(cat /sys/class/net/eth0/statistics/tx_bytes)
  check_error "Error: Không thể lấy dữ liệu new Network traffic"

  rx_diff=$((network_rx_new - network_rx))
  tx_diff=$((network_tx_new - network_tx))

  total_rx=$((total_rx + rx_diff))
  total_tx=$((total_tx + tx_diff))

  # Load Average
  load_average=$(uptime | awk -F'load average: ' '{ print $2 }' | cut -d',' -f1)
  check_error "Error: Không thể lấy dữ liệu Load average"
  total_load=$(echo "$total_load + $load_average" | bc)

  # Process Count
  process_count=$(ps aux --no-heading | wc -l)
  check_error "Error: Không thể lấy dữ liệu Process details"
}

# Xử lý tham số range (tăng dần từ cũ đến mới)
if [[ "$1" == "range" ]]; then
  total_seconds=$(seconds_between "$start_date" "$end_date") # Tính số giây giữa hai ngày
  interval_seconds=$((total_seconds / (num_samples - 1)))    # Chia đều thời gian

  for ((i = 0; i < num_samples; i++)); do
    sample_epoch=$(($(date -d "$start_date" +%s) + (i * interval_seconds))) # Tính thời gian cho sample i
    sample_date=$(date -d "@$sample_epoch" "+%Y-%m-%d %H:%M:%S")            # Định dạng lại thời gian cho sample

    collect_system_stats

    log_message "Sample #$((i + 1)) - Date: $sample_date => CPU Usage: $cpu_usage% / Memory Usage: $memory_usage% / Disk Usage: $disk_usage% / Network RX/TX: $rx_diff bytes / $tx_diff bytes / Load Average: $load_average / Process Count: $process_count"
  done
else
  # Thu thập dữ liệu cho các tham số khác (today, yesterday, 7day, 30day)
  for ((i = 1; i <= num_samples; i++)); do
    if [[ "$1" == "today" || "$1" == "yesterday" ]]; then
      time_of_day=("01:00" "06:00" "12:00" "18:00" "23:00")
      sample_time="${time_of_day[$((i - 1))]}"

      if [[ "$1" == "today" ]]; then
        sample_date=$(date "+%Y-%m-%d $sample_time")
      elif [[ "$1" == "yesterday" ]]; then
        sample_date=$(date -d "yesterday $sample_time" "+%Y-%m-%d $sample_time")
      fi
    elif [[ "$1" == "7day" ]]; then
      sample_date=$(date -d "$((num_samples - i)) days ago" "+%Y-%m-%d") # Tăng dần từ ngày cũ đến mới
    elif [[ "$1" == "30day" ]]; then
      sample_date=$(date -d "$(((num_samples - i) * 4)) days ago" "+%Y-%m-%d") # Tăng dần từ ngày cũ đến mới
    else
      sample_date="Sample #$i"
    fi

    collect_system_stats

    log_message "Sample #$i - Date: $sample_date => CPU Usage: $cpu_usage% / Memory Usage: $memory_usage% / Disk Usage: $disk_usage% / Network RX/TX: $rx_diff bytes / $tx_diff bytes / Load Average: $load_average / Process Count: $process_count"
  done
fi

# Tính trung bình của các thông số
avg_cpu=$(echo "$total_cpu / $num_samples" | bc -l)
avg_memory=$(echo "$total_memory / $num_samples" | bc -l)
avg_disk=$(echo "$total_disk / $num_samples" | bc -l)
avg_rx=$(echo "$total_rx / $num_samples" | bc)
avg_tx=$(echo "$total_tx / $num_samples" | bc)
avg_load=$(echo "$total_load / $num_samples" | bc -l)

# Hiển thị kết quả trung bình
log_message "Total Average"
log_message "Average CPU Usage: $avg_cpu%"
log_message "Average Memory Usage: $avg_memory%"
log_message "Average Disk Usage: $avg_disk%"
log_message "Average Network RX: $avg_rx bytes"
log_message "Average Network TX: $avg_tx bytes"
log_message "Average Load Average: $avg_load"
log_message "Hoàn Tất"
