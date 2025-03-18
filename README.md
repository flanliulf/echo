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

### 本地开发

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

这将把服务部署到 `/root/echo` 目录，并使用PM2和systemd进行管理。

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

在Ubuntu 20.04服务器上，该服务部署在 `/root/echo` 目录下。

## 将本地工程上传到远程服务器

以下是几种将本地工程上传到远程Ubuntu 20.04服务器的方法：

### 方法1：使用SCP（安全复制）

```bash
# 上传整个项目（包含所有子目录）
scp -r /Users/fancyliu/VscodeWorkspace/echo username@server_ip:/root/

# 如果只想上传顶层文件（不包含子目录）
scp /Users/fancyliu/VscodeWorkspace/echo/* username@server_ip:/root/echo/

# 分别上传顶层文件和必要的子目录
scp /Users/fancyliu/VscodeWorkspace/echo/* username@server_ip:/root/echo/
scp -r /Users/fancyliu/VscodeWorkspace/echo/src username@server_ip:/root/echo/
scp -r /Users/fancyliu/VscodeWorkspace/echo/deploy username@server_ip:/root/echo/
```

### 方法2：使用rsync（增量同步）

```bash
# 上传整个项目（包含所有子目录）
rsync -avz --exclude 'node_modules' /Users/fancyliu/VscodeWorkspace/echo/ username@server_ip:/root/echo/

# 如果只想上传顶层文件（不包含子目录）
rsync -av --exclude='*/' /Users/fancyliu/VscodeWorkspace/echo/ username@server_ip:/root/echo/
```

### 方法3：使用tar打包后上传

```bash
# 在本地打包
cd /Users/fancyliu/VscodeWorkspace
tar -czf echo.tar.gz echo

# 上传tar包
scp echo.tar.gz username@server_ip:/root/

# 在远程服务器解压
ssh username@server_ip "cd /root && tar -xzf echo.tar.gz"
```

### 方法4：使用Git仓库

```bash
# 在本地将项目推送到Git仓库
cd /Users/fancyliu/VscodeWorkspace/echo
git init
git add .
git commit -m "Initial commit"
git remote add origin git@github.com:flanliulf/echo.git
git push -u origin main  # 使用main作为默认分支

# 在远程服务器上克隆仓库
ssh username@server_ip "cd /root && git clone git@github.com:flanliulf/echo.git echo"
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
cd /Users/fancyliu/VscodeWorkspace/echo
docker build -t your_dockerhub_username/echo-service .
docker push your_dockerhub_username/echo-service

# 在远程服务器上拉取并运行Docker镜像
ssh username@server_ip "docker pull your_dockerhub_username/echo-service && docker run -d -p 3000:3000 --name echo-service your_dockerhub_username/echo-service"
```

### 上传后的部署步骤

无论使用哪种方法上传，上传完成后都需要在远程服务器上执行以下步骤：

1. 安装依赖：
   ```bash
   cd /root/echo
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
