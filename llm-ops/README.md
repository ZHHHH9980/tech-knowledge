# LLM Ops 知识库

LLM API 运维相关的技术文档。

## 文档列表

- [verify-api-proxy.md](./verify-api-proxy.md) - LLM API 中转站验证方案
  - 多维度验证方法（长上下文、Vision、Token 计数、延迟分析）
  - Claude 和 OpenAI 验证脚本
  - 判断标准和使用建议
  - 生产环境监控方案

## 使用场景

- 评估第三方 LLM API 中转站真实性
- 验证中转站是否掺水（用小模型冒充大模型）
- 排查 API 调用异常（延迟、token 计数、能力缺失）
- 生产环境 LLM API 质量监控
