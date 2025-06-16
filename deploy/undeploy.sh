#!/bin/bash

# 卸载脚本 - 完全移除Echo服务
# 使用方法: sudo ./undeploy.sh

set -e  # 遇到错误立即退出

# 颜色输出函数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否以root权限运行
if [[ $EUID -ne 0 ]]; then
   log_error "此脚本必须以root权限运行"
   exit 1
fi

log_warn "开始卸载Echo服务..."

# 停止并删除PM2服务
if command -v pm2 &> /dev/null; then
    if pm2 list | grep -q "echo-service"; then
        log_info "停止并删除PM2中的echo-service..."
        pm2 stop echo-service
        pm2 delete echo-service
        pm2 save
    else
        log_info "PM2中未找到echo-service实例"
    fi
else
    log_info "PM2未安装，跳过PM2服务清理"
fi

# 停止并禁用systemd服务
if systemctl is-active --quiet echo.service; then
    log_info "停止systemd服务..."
    systemctl stop echo.service
fi

if systemctl is-enabled --quiet echo.service; then
    log_info "禁用systemd服务..."
    systemctl disable echo.service
fi

# 删除systemd服务文件
if [ -f "/etc/systemd/system/echo.service" ]; then
    log_info "删除systemd服务文件..."
    rm -f /etc/systemd/system/echo.service
    systemctl daemon-reload
fi

# 询问是否删除部署目录
read -p "是否删除部署目录 /root/www/echo？[y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "/root/www/echo" ]; then
        log_info "删除部署目录 /root/www/echo..."
        rm -rf /root/www/echo
    fi
else
    log_info "保留部署目录 /root/www/echo"
fi

# 询问是否删除备份目录
backup_dirs=$(find /root/www -maxdepth 1 -name "echo.backup.*" -type d 2>/dev/null || true)
if [ -n "$backup_dirs" ]; then
    echo "发现以下备份目录:"
    echo "$backup_dirs"
    read -p "是否删除这些备份目录？[y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "删除备份目录..."
        echo "$backup_dirs" | xargs rm -rf
    else
        log_info "保留备份目录"
    fi
fi

log_info "✅ Echo服务卸载完成"
log_info "注意: PM2本身和Node.js未被移除" 