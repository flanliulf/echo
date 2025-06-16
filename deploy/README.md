# 部署指南

这个目录包含了将Echo服务部署到远程Ubuntu 20.04服务器的所有必要文件。

## 文件说明

- `deploy.sh` - 主部署脚本，将服务部署到 `/root/www/echo`
- `undeploy.sh` - 卸载脚本，完全移除部署的服务
- `echo.service` - systemd服务配置文件
- `README.md` - 本指南文档

## 快速部署

### 1. 上传项目到服务器

使用以下任一方法将项目上传到服务器：

```bash
# 方法1: 使用rsync（推荐，自动排除不必要文件）
rsync -avz --exclude 'node_modules' --exclude '.git' /Users/fancyliu/echo/ username@server_ip:/root/www/echo/

# 方法2: 使用scp（需要先清理本地项目）
# 先在本地临时删除 node_modules 目录
rm -rf /Users/fancyliu/echo/node_modules
scp -r /Users/fancyliu/echo username@server_ip:/root/www/
# 上传完成后恢复本地依赖
cd /Users/fancyliu/echo && npm install

# 方法3: 使用Git（推荐，最干净的方式）
ssh username@server_ip "cd /root/www && git clone https://github.com/flanliulf/echo.git echo"
```

### 2. 连接到服务器并部署

```bash
# 连接到服务器
ssh username@server_ip

# 进入项目目录
cd /root/www/echo

# 给脚本添加执行权限（如果需要）
chmod +x deploy/deploy.sh deploy/undeploy.sh

# 运行部署脚本
sudo ./deploy/deploy.sh
```

### 3. 验证部署

```bash
# 检查服务状态
pm2 status

# 测试API
curl http://localhost:3000/echo

# 检查systemd服务
systemctl status echo.service
```

## 服务管理命令

```bash
# 查看服务状态
pm2 status

# 查看日志
pm2 logs echo-service

# 重启服务
pm2 restart echo-service

# 停止服务
pm2 stop echo-service

# 完全卸载
sudo ./deploy/undeploy.sh
```

## 注意事项

1. **权限要求**：部署脚本需要root权限
2. **端口占用**：确保3000端口未被其他服务占用
3. **Node.js版本**：服务器需要安装Node.js v20.19.0
4. **备份机制**：部署脚本会自动备份现有部署

## 故障排除

### 如果部署失败

1. 检查错误日志：
   ```bash
   pm2 logs echo-service --lines 50
   ```

2. 验证Node.js版本：
   ```bash
   node --version
   npm --version
   ```

3. 检查端口是否被占用：
   ```bash
   sudo netstat -tlnp | grep :3000
   ```

4. 重新运行部署：
   ```bash
   sudo ./deploy/deploy.sh
   ```

### 如果服务无法启动

1. 检查PM2状态：
   ```bash
   pm2 list
   pm2 describe echo-service
   ```

2. 查看系统日志：
   ```bash
   journalctl -u echo.service -f
   ```

3. 手动启动测试：
   ```bash
   cd /root/www/echo
   node src/index.js
   ``` 