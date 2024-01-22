#!/bin/bash

# haproxy 的 IP 地址
haproxy_ip="192.168.100.101"

# redis 访问密码
redis_password="P@ssw0rd"

# 访问次数
access_count=100

# 访问时间范围（秒）
start_time=0
end_time=3600

# 访问高峰时间范围（秒）
peak_start_time=43200
peak_end_time=46800

# 访问后创建数据记录访问时间
function create_data() {
    local timestamp=$(date +%s)
    redis-cli -h $haproxy_ip -a $redis_password set "access:$timestamp" "$timestamp"
}

# 随机等待一段时间
function random_wait() {
    local wait_time=$((RANDOM % (end_time - start_time) + start_time))
    sleep $wait_time
}

# 访问高峰期间的并发连接数
function peak_connections() {
    local connections=$((RANDOM % 300 + 300))
    echo $connections
}

# 访问 redis
function access_redis() {
    for ((i=1; i<=$access_count; i++)); do
        random_wait
        local current_time=$(date +%s)
        if [[ $current_time -gt $peak_start_time && $current_time -lt $peak_end_time ]]; then
            local connections=$(peak_connections)
            redis-cli -h $haproxy_ip -a $redis_password -p 6379 -c -n 0 -r $connections ping >/dev/null
        else
            redis-cli -h $haproxy_ip -a $redis_password -p 6379 ping >/dev/null
        fi
        create_data
    done
}

# 访问 redis
access_redis