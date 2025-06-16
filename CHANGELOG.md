# 更新日志

本文档记录了 Echo 服务项目的所有重要变更。

## [1.1.0] - 2025-06-16

### 🚀 新增功能

- **新增卸载脚本**: 添加了 `deploy/undeploy.sh` 脚本，支持完全移除部署的服务
- **增强部署脚本**: 大幅改进 `deploy/deploy.sh`，增加了错误检查、备份机制和状态验证
- **部署指南文档**: 新增 `deploy/README.md`，提供详细的快速部署指南
- **服务管理章节**: 在主 README.md 中新增完整的服务管理和故障排除章节

### 🔧 重要变更

- **部署路径调整**: 将服务部署路径从 `/root/echo` 更改为 `/root/www/echo`
- **文档路径更新**: 更新了所有文档中的本地工作目录路径，从 `/Users/fancyliu/VscodeWorkspace/echo` 改为 `/Users/fancyliu/echo`

### ✨ 增强功能

#### 部署脚本增强 (`deploy/deploy.sh`)
- 添加了彩色日志输出（INFO/WARN/ERROR）
- 增加了 root 权限检查
- 实现了自动备份现有部署的功能
- 添加了 Node.js 版本检查
- 增强了 PM2 服务管理（停止现有实例）
- 添加了服务状态验证和 API 端点测试
- 提供了详细的部署后管理命令说明

#### 卸载脚本功能 (`deploy/undeploy.sh`)
- 完全停止和删除 PM2 服务
- 禁用和删除 systemd 服务
- 交互式选择删除部署目录
- 智能管理备份目录
- 彩色日志输出

#### 文档完善
- **README.md**: 
  - 更新所有部署路径引用
  - 新增服务管理章节
  - 添加故障排除指南
  - 完善 PM2 和 systemd 服务管理说明
- **deploy/README.md**: 
  - 提供快速部署指南
  - 详细的故障排除步骤
  - 服务管理命令参考

### 🛠️ 技术改进

- **错误处理**: 部署脚本增加了 `set -e` 确保遇到错误时立即退出
- **状态验证**: 自动验证服务启动状态和 API 可用性
- **备份机制**: 部署时自动备份现有版本，支持快速回滚
- **权限管理**: 确保脚本具有正确的执行权限

### 📁 文件变更

#### 新增文件
- `deploy/undeploy.sh` - 服务卸载脚本
- `deploy/README.md` - 部署指南文档
- `CHANGELOG.md` - 更新日志（本文件）

#### 修改文件
- `README.md` - 更新部署路径和增加服务管理章节
- `deploy/deploy.sh` - 大幅增强功能和错误处理
- `deploy/echo.service` - 更新工作目录路径

### 🎯 部署路径变更详情

| 组件 | 旧路径 | 新路径 |
|------|--------|--------|
| 服务部署目录 | `/root/echo` | `/root/www/echo` |
| systemd 工作目录 | `/root/echo` | `/root/www/echo` |
| 备份目录模式 | 无 | `/root/www/echo.backup.YYYYMMDD_HHMMSS` |

### 🔍 上传方式更新

所有文档中的上传命令已更新：

#### SCP 命令
```bash
# 旧: scp -r /Users/fancyliu/VscodeWorkspace/echo username@server_ip:/root/
# 新: scp -r /Users/fancyliu/echo username@server_ip:/root/www/
```

#### rsync 命令
```bash
# 旧: rsync -avz --exclude 'node_modules' /Users/fancyliu/VscodeWorkspace/echo/ username@server_ip:/root/echo/
# 新: rsync -avz --exclude 'node_modules' /Users/fancyliu/echo/ username@server_ip:/root/www/echo/
```

#### Git 克隆
```bash
# 旧: ssh username@server_ip "cd /root && git clone git@github.com:flanliulf/echo.git echo"
# 新: ssh username@server_ip "cd /root/www && git clone git@github.com:flanliulf/echo.git echo"
```

### 📋 迁移指南

如果您有现有的部署需要迁移到新路径：

1. **备份现有部署**:
   ```bash
   sudo cp -r /root/echo /root/echo.backup.manual
   ```

2. **创建新目录结构**:
   ```bash
   sudo mkdir -p /root/www
   ```

3. **移动现有部署**:
   ```bash
   sudo mv /root/echo /root/www/echo
   ```

4. **更新 systemd 服务**:
   ```bash
   sudo cp /root/www/echo/deploy/echo.service /etc/systemd/system/
   sudo systemctl daemon-reload
   ```

5. **重启服务**:
   ```bash
   sudo systemctl restart echo.service
   ```

### ⚡ 快速开始

使用新的部署流程：

1. **上传项目**:
   ```bash
   scp -r /Users/fancyliu/echo username@server_ip:/root/www/
   ```

2. **部署服务**:
   ```bash
   ssh username@server_ip
   cd /root/www/echo
   sudo ./deploy/deploy.sh
   ```

3. **验证部署**:
   ```bash
   curl http://localhost:3000/echo
   ```

### 🔧 维护命令

- **查看服务状态**: `pm2 status`
- **查看日志**: `pm2 logs echo-service`
- **重启服务**: `pm2 restart echo-service`
- **更新部署**: `sudo ./deploy/deploy.sh`
- **完全卸载**: `sudo ./deploy/undeploy.sh`

---

## [1.0.0] - 2025-03-16 (初始版本)

### 🎉 初始发布

- 基本的 Node.js Express 服务
- `/echo` API 端点
- PM2 进程管理
- systemd 服务集成
- Docker 支持
- 基础部署脚本

---

*更新日志格式遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/) 规范。* 