# Echo服务

一个简单的Node.js后端服务，提供返回"hello"的echo接口。

## 技术栈

- Node.js v20.19.0
- Express.js
- PM2 (进程管理)

## 项目结构

```
echo/
├── package.json        # 项目配置文件
├── .nvmrc              # 指定Node.js版本
├── ecosystem.config.js # PM2配置文件
├── src/                # 源代码目录
│   ├── index.js        # 主入口文件
│   ├── routes/         # 路由目录
│   │   └── echo.js     # echo接口路由
│   └── controllers/    # 控制器目录
│       └── echoController.js  # echo接口控制器
├── deploy/             # 部署相关文件
│   ├── echo.service    # systemd服务文件
│   └── deploy.sh       # 部署脚本
├── Dockerfile          # Docker容器配置文件
└── .dockerignore       # Docker忽略文件
```

## 安装与运行

### 本地运行

确保您的系统上安装了Node.js v20.19.0：

```bash
# 使用nvm安装指定版本的Node.js
nvm install 20.19.0
nvm use 20.19.0
```
安装依赖并启动开发服务器：

```bash
npm install
npm run dev
```

服务将在 http://localhost:3000 上运行。

### 生产环境部署

#### 方法1：使用部署脚本（Ubuntu 20.04）

确保您有root权限，然后执行：

```bash
# 确保脚本有执行权限
chmod +x deploy/deploy.sh

# 执行部署脚本
sudo ./deploy/deploy.sh
```

这将把服务部署到 `/root/www/echo` 目录，并使用PM2和systemd进行管理。

#### 方法2：使用Docker

构建Docker镜像：

```bash
docker build -t echo-service .
```

运行容器：

```bash
docker run -d -p 3000:3000 --name echo-service echo-service
```

## API文档

### GET /echo

返回一个包含"hello"消息的JSON响应。

**请求示例：**

```
GET http://localhost:3000/echo
```

**响应示例：**

```json
{
  "message": "hello"
}
```

## PM2常用命令

```bash
# 查看应用状态
pm2 status

# 查看日志
pm2 logs echo-service

# 重启应用
pm2 restart echo-service

# 停止应用
pm2 stop echo-service

# 删除应用
pm2 delete echo-service
```

## 部署路径

在Ubuntu 20.04服务器上，该服务部署在 `/root/www/echo` 目录下。

## 将本地工程上传到远程服务器

以下是几种将本地工程上传到远程Ubuntu 20.04服务器的方法：

### 方法1：使用rsync（推荐，智能同步）

```bash
# 上传整个项目，自动排除不必要文件
rsync -avz --exclude 'node_modules' --exclude '.git' --exclude '.DS_Store' /Users/fancyliu/echo/ username@server_ip:/root/www/echo/

# 如果需要显示详细进度
rsync -avz --progress --exclude 'node_modules' --exclude '.git' /Users/fancyliu/echo/ username@server_ip:/root/www/echo/
```

### 方法2：使用SCP（需要预处理）

```bash
# 先临时删除不必要的目录（推荐先备份）
rm -rf /Users/fancyliu/echo/node_modules

# 上传项目
scp -r /Users/fancyliu/echo username@server_ip:/root/www/

# 恢复本地依赖
cd /Users/fancyliu/echo && npm install
```

### 方法3：使用tar打包后上传

```bash
# 在本地打包（排除不必要文件）
cd /Users/fancyliu
tar -czf echo.tar.gz --exclude='echo/node_modules' --exclude='echo/.git' --exclude='echo/.DS_Store' echo

# 上传tar包
scp echo.tar.gz username@server_ip:/root/www/

# 在远程服务器解压
ssh username@server_ip "cd /root/www && tar -xzf echo.tar.gz && rm echo.tar.gz"
```

### 方法4：使用Git仓库（推荐，最干净）

```bash
# 在本地将项目推送到Git仓库
cd /Users/fancyliu/echo
git init
git add .
git commit -m "Initial commit"
git remote add origin git@github.com:flanliulf/echo.git
git push -u origin main  # 使用main作为默认分支

# 在远程服务器上克隆仓库
ssh username@server_ip "cd /root/www && git clone git@github.com:flanliulf/echo.git echo"
```

项目GitHub仓库地址：[https://github.com/flanliulf/echo](https://github.com/flanliulf/echo)

#### 克隆仓库

如果您想克隆此仓库，可以使用以下命令：

```bash
# 克隆仓库
git clone git@github.com:flanliulf/echo.git

# 进入项目目录
cd echo

# 确保您在main分支上
git checkout main
```

### 方法5：使用Docker镜像

```bash
# 在本地构建Docker镜像并推送到Docker Hub
cd /Users/fancyliu/echo
docker build -t your_dockerhub_username/echo-service .
docker push your_dockerhub_username/echo-service

# 在远程服务器上拉取并运行Docker镜像
ssh username@server_ip "docker pull your_dockerhub_username/echo-service && docker run -d -p 3000:3000 --name echo-service your_dockerhub_username/echo-service"
```

### 上传后的部署步骤

无论使用哪种方法上传，上传完成后都需要在远程服务器上执行以下步骤：

1. 安装依赖：
   ```bash
   cd /root/www/echo
   npm install --production
   ```

2. 安装PM2（如果尚未安装）：
   ```bash
   npm install -g pm2
   ```

3. 启动服务：
   ```bash
   # 使用PM2启动
   pm2 start ecosystem.config.js --env production
   
   # 或使用部署脚本
   chmod +x deploy/deploy.sh
   ./deploy/deploy.sh
   ```

4. 设置PM2开机自启：
   ```bash
   pm2 startup
   pm2 save
   ```

5. 验证服务是否正常运行：
   ```bash
   curl http://localhost:3000/echo
   ```

**注意**：上述命令中的`username@server_ip`需要替换为实际的服务器用户名和IP地址。

## 服务管理

### 部署脚本使用

项目包含了增强的部署脚本，提供了更好的错误检查和状态验证：

```bash
# 部署服务
sudo ./deploy/deploy.sh

# 卸载服务
sudo ./deploy/undeploy.sh
```

### 服务状态检查

```bash
# 检查PM2状态
pm2 status

# 查看服务日志
pm2 logs echo-service

# 检查systemd服务状态
systemctl status echo.service

# 测试API端点
curl http://localhost:3000/echo
```

### 服务更新

当需要更新服务时，可以重新运行部署脚本：

```bash
# 上传新版本的代码后
sudo ./deploy/deploy.sh
```

部署脚本会自动：
- 备份现有部署
- 停止旧服务
- 安装新依赖
- 启动新服务
- 验证服务状态

### 完全卸载

如果需要完全移除Echo服务：

```bash
sudo ./deploy/undeploy.sh
```

卸载脚本将：
- 停止并删除PM2中的服务
- 禁用并删除systemd服务
- 可选择删除部署目录和备份

## 故障排除

### 常见问题

1. **端口冲突**：如果3000端口被占用，请检查是否有其他服务在使用该端口
   ```bash
   sudo netstat -tlnp | grep :3000
   ```

2. **权限问题**：确保以root权限运行部署脚本
   ```bash
   sudo ./deploy/deploy.sh
   ```

3. **Node.js版本不匹配**：确保服务器上安装了正确的Node.js版本
   ```bash
   node --version  # 应该是 v20.19.0
   ```

4. **PM2服务无法启动**：检查PM2日志
   ```bash
   pm2 logs echo-service
   ```

### 日志位置

- PM2日志：`~/.pm2/logs/`
- systemd日志：`journalctl -u echo.service`

## 贡献指南

如果您想为这个项目做出贡献，请按照以下步骤操作：

1. Fork这个仓库
2. 创建您的特性分支：`git checkout -b feature/amazing-feature`
3. 提交您的更改：`git commit -m '添加一些很棒的功能'`
4. 推送到分支：`git push origin feature/amazing-feature`
5. 提交Pull Request

### 开发规范

- 遵循JavaScript Standard Style代码风格
- 确保所有测试通过
- 为新功能添加适当的测试
- 更新文档以反映任何更改

### 问题反馈

如果您发现任何问题或有改进建议，请在GitHub仓库中创建一个Issue。
