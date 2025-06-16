#!/bin/bash

# 部署脚本 - 将服务部署到 /root/www/echo 并使用PM2管理
# 使用方法: sudo ./deploy.sh

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

log_info "开始部署Echo服务..."

# 确保目标目录存在
log_info "创建目标目录 /root/www/echo"
mkdir -p /root/www/echo

# 备份现有部署（如果存在）
if [ -d "/root/www/echo/node_modules" ]; then
    log_warn "检测到现有部署，创建备份..."
    backup_dir="/root/www/echo.backup.$(date +%Y%m%d_%H%M%S)"
    cp -r /root/www/echo $backup_dir
    log_info "备份已创建: $backup_dir"
fi

# 获取当前工作目录
current_dir=$(pwd)
target_dir="/root/www/echo"

# 检查是否已在目标目录中
if [ "$current_dir" = "$target_dir" ]; then
    log_info "已在目标目录中，跳过文件复制步骤"
else
    # 复制项目文件
    log_info "复制项目文件从 $current_dir 到 $target_dir"
    cp -r ./* /root/www/echo/
    
    # 切换到目标目录
    cd /root/www/echo
fi

# 安装依赖
log_info "安装生产环境依赖..."
npm install --production

# 检查Node.js版本
node_version=$(node --version)
log_info "当前Node.js版本: $node_version"

# 确保PM2已全局安装
if ! command -v pm2 &> /dev/null; then
    log_info "安装PM2进程管理器..."
    npm install -g pm2
else
    log_info "PM2已安装: $(pm2 --version)"
fi

# 停止现有的服务（如果正在运行）
if pm2 list | grep -q "echo-service"; then
    log_info "停止现有的echo-service实例..."
    pm2 stop echo-service
    pm2 delete echo-service
fi

# 启动应用
log_info "启动Echo服务..."
pm2 start ecosystem.config.js --env production

# 设置PM2开机自启
log_info "配置PM2开机自启..."
pm2 startup systemd -u root --hp /root
pm2 save

# 设置systemd服务
log_info "配置systemd服务..."
cp /root/www/echo/deploy/echo.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable echo.service

# 验证服务状态
log_info "验证服务状态..."
sleep 3
if pm2 list | grep -q "online.*echo-service"; then
    log_info "✅ Echo服务已成功启动"
    pm2 status
else
    log_error "❌ Echo服务启动失败"
    pm2 logs echo-service --lines 20
    exit 1
fi

# 测试API端点
log_info "测试API端点..."
if curl -s http://localhost:3000/echo | grep -q "hello"; then
    log_info "✅ API端点测试成功"
else
    log_warn "⚠️ API端点测试失败，请检查服务状态"
fi

log_info "🎉 Echo服务已成功部署到 /root/www/echo 并已通过PM2启动"
log_info "您可以使用以下命令管理服务:"
echo "  pm2 status          # 查看服务状态"
echo "  pm2 logs echo-service    # 查看日志"
echo "  pm2 restart echo-service # 重启服务"
echo "  systemctl status echo.service # 查看systemd服务状态"
