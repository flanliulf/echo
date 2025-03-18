const express = require('express');
const echoRoutes = require('./routes/echo');

// 创建Express应用
const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 路由
app.use('/', echoRoutes);

// 404处理
app.use((req, res) => {
  res.status(404).json({ message: '未找到请求的资源' });
});

// 错误处理
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: '服务器内部错误' });
});

// 启动服务器
app.listen(PORT, () => {
  console.log(`Echo服务已启动，监听端口: ${PORT}`);
  console.log(`访问 http://localhost:${PORT}/echo 获取hello响应`);
});

module.exports = app; // 导出app用于测试
