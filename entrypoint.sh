#!/bin/sh

# 获取容器 IP 并设置环境变量
export CONTAINER_IP=$(hostname -i)

# 打印 IP 信息（调试用）
echo "Container IP: $CONTAINER_IP"

# 执行主应用
exec /app/go-app