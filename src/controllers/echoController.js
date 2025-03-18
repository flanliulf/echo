/**
 * Echo控制器
 * 提供echo接口的处理逻辑
 */

// 处理echo请求，返回hello
const getEcho = (req, res) => {
  try {
    res.status(200).json({ message: 'hello' });
  } catch (error) {
    console.error('Echo处理错误:', error);
    res.status(500).json({ message: '服务器内部错误' });
  }
};

module.exports = {
  getEcho
};
