#!/bin/bash

# 部署脚本 - 将服务部署到 /root/echo 并使用PM2管理

# 确保目标目录存在
mkdir -p /root/echo

# 复制项目文件
cp -r ./* /root/echo/

# 安装依赖
cd /root/echo
npm install --production

# 确保PM2已全局安装
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
fi

# 设置PM2开机自启
pm2 startup
pm2 save

# 启动应用
pm2 start ecosystem.config.js --env production

# 设置systemd服务
cp /root/echo/deploy/echo.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable echo.service

echo "Echo服务已部署到 /root/echo 并已通过PM2启动"
