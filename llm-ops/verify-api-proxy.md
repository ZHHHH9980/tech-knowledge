# LLM API 中转站验证方案

## 问题背景

第三方 LLM API 中转站（代理服务）可能存在的问题：
- 声称是 GPT-4/Claude Opus，实际调用更便宜的小模型
- Token 计数造假，多收费
- 缓存旧响应，不是实时调用
- 记录用户 prompts（隐私风险）

## 验证维度矩阵

| 维度 | 检测目标 | 成本 | 可靠性 |
|------|---------|------|--------|
| 模型自我认知 | 基础可用性 | 低 | ⭐ |
| Token 计数 | 计费准确性 | 低 | ⭐⭐⭐ |
| 长上下文 | 模型能力边界 | 中 | ⭐⭐⭐⭐ |
| Vision/Tools | 高级能力 | 低 | ⭐⭐⭐⭐⭐ |
| 响应质量 | 模型风格指纹 | 中 | ⭐⭐⭐ |
| 延迟统计 | 性能特征 | 中 | ⭐⭐ |
| 响应头 | 官方特征 | 低 | ⭐⭐ |
| Benchmark | 客观能力 | 高 | ⭐⭐⭐⭐⭐ |

## 验证脚本

### 快速验证（Anthropic Claude）

```python
#!/usr/bin/env python3
"""
快速验证 Claude API 中转站真实性
用法: python verify_claude_proxy.py <base_url> <api_key>
"""

import anthropic
import time
import sys
import statistics

def verify_claude_proxy(base_url: str, api_key: str):
    """执行完整验证流程"""
    
    client = anthropic.Anthropic(api_key=api_key, base_url=base_url)
    results = {
        "basic": None,
        "long_context": None,
        "vision": None,
        "token_ratio": None,
        "latency_profile": None,
        "knowledge_cutoff": None,
    }
    
    print("=" * 60)
    print("🔍 Claude API 中转站验证")
    print(f"📍 Base URL: {base_url}")
    print("=" * 60)
    
    # 1. 基础调用 + 自我认知
    print("\n[1/6] 基础调用测试...")
    try:
        start = time.time()
        response = client.messages.create(
            model="claude-opus-4-6",
            max_tokens=200,
            messages=[{
                "role": "user",
                "content": "What model are you? Be specific about version."
            }]
        )
        latency = time.time() - start
        
        results["basic"] = {
            "success": True,
            "latency": latency,
            "model": response.model,
            "response_id": response.id,
            "answer": response.content[0].text[:200]
        }
        print(f"✅ 成功 (延迟: {latency:.2f}s)")
        print(f"   模型: {response.model}")
        print(f"   回答: {response.content[0].text[:150]}...")
    except Exception as e:
        results["basic"] = {"success": False, "error": str(e)}
        print(f"❌ 失败: {e}")
        return results
    
    # 2. 长上下文测试
    print("\n[2/6] 长上下文能力...")
    try:
        long_text = "The quick brown fox jumps over the lazy dog. " * 5000
        start = time.time()
        response = client.messages.create(
            model="claude-opus-4-6",
            max_tokens=100,
            messages=[{
                "role": "user",
                "content": f"{long_text}\n\nSummarize in 5 words."
            }]
        )
        latency = time.time() - start
        
        input_tokens = response.usage.input_tokens
        results["long_context"] = {
            "success": True,
            "input_tokens": input_tokens,
            "latency": latency,
            "answer": response.content[0].text
        }
        
        if input_tokens > 40000:
            print(f"✅ 成功处理 {input_tokens} tokens")
        else:
            print(f"⚠️  Token 数偏低: {input_tokens} (可能截断)")
            
    except Exception as e:
        results["long_context"] = {"success": False, "error": str(e)}
        print(f"❌ 失败: {e}")
    
    # 3. Vision 能力
    print("\n[3/6] Vision 能力...")
    try:
        import base64
        from io import BytesIO
        from PIL import Image
        
        # 创建 10x10 红色图片
        img = Image.new('RGB', (10, 10), color='red')
        buffer = BytesIO()
        img.save(buffer, format='PNG')
        img_data = base64.b64encode(buffer.getvalue()).decode()
        
        response = client.messages.create(
            model="claude-opus-4-6",
            max_tokens=100,
            messages=[{
                "role": "user",
                "content": [
                    {
                        "type": "image",
                        "source": {
                            "type": "base64",
                            "media_type": "image/png",
                            "data": img_data
                        }
                    },
                    {
                        "type": "text",
                        "text": "What color? Just say the color."
                    }
                ]
            }]
        )
        
        answer = response.content[0].text.lower()
        results["vision"] = {
            "success": True,
            "answer": answer,
            "correct": "red" in answer
        }
        
        if "red" in answer:
            print(f"✅ Vision 正常 (答案: {answer})")
        else:
            print(f"⚠️  Vision 可能不工作 (答案: {answer})")
            
    except Exception as e:
        results["vision"] = {"success": False, "error": str(e)}
        print(f"❌ 失败: {e}")
    
    # 4. Token 计数准确性
    print("\n[4/6] Token 计数...")
    try:
        response = client.messages.create(
            model="claude-opus-4-6",
            max_tokens=2000,
            messages=[{
                "role": "user",
                "content": "Write a 1000-word essay about quantum computing."
            }]
        )
        
        output_tokens = response.usage.output_tokens
        word_count = len(response.content[0].text.split())
        ratio = output_tokens / word_count if word_count > 0 else 0
        
        results["token_ratio"] = {
            "output_tokens": output_tokens,
            "word_count": word_count,
            "ratio": ratio
        }
        
        # 英文标准 1.3-1.5 tokens/word
        if 1.2 < ratio < 1.6:
            print(f"✅ Token 计数正常 ({ratio:.2f} tokens/word)")
        else:
            print(f"⚠️  Token 计数异常 ({ratio:.2f} tokens/word)")
            
    except Exception as e:
        results["token_ratio"] = {"success": False, "error": str(e)}
        print(f"❌ 失败: {e}")
    
    # 5. 延迟分析
    print("\n[5/6] 性能基准 (10次)...")
    latencies = []
    try:
        for i in range(10):
            start = time.time()
            client.messages.create(
                model="claude-opus-4-6",
                max_tokens=50,
                messages=[{"role": "user", "content": f"Count to {i+1}"}]
            )
            latencies.append(time.time() - start)
            time.sleep(0.3)
        
        results["latency_profile"] = {
            "mean": statistics.mean(latencies),
            "median": statistics.median(latencies),
            "p95": sorted(latencies)[int(0.95 * len(latencies))],
            "min": min(latencies),
            "max": max(latencies)
        }
        
        avg = statistics.mean(latencies)
        print(f"   平均: {avg:.2f}s | 中位: {statistics.median(latencies):.2f}s")
        print(f"   P95: {results['latency_profile']['p95']:.2f}s")
        
        if avg < 0.5:
            print("⚠️  延迟异常低 (可能缓存/小模型)")
        elif avg > 5:
            print("⚠️  延迟偏高")
        else:
            print("✅ 延迟合理")
            
    except Exception as e:
        results["latency_profile"] = {"success": False, "error": str(e)}
        print(f"❌ 失败: {e}")
    
    # 6. 知识截止日期
    print("\n[6/6] 知识截止验证...")
    try:
        response = client.messages.create(
            model="claude-opus-4-6",
            max_tokens=200,
            messages=[{
                "role": "user",
                "content": "What is your knowledge cutoff date?"
            }]
        )
        
        answer = response.content[0].text
        results["knowledge_cutoff"] = {
            "answer": answer,
            "correct": "2026" in answer or "january" in answer.lower()
        }
        
        print(f"   回答: {answer[:100]}...")
        
    except Exception as e:
        results["knowledge_cutoff"] = {"success": False, "error": str(e)}
        print(f"❌ 失败: {e}")
    
    # 综合评分
    print("\n" + "=" * 60)
    print("📊 综合评估")
    print("=" * 60)
    
    score = 0
    max_score = 6
    
    if results["basic"] and results["basic"].get("success"):
        score += 1
    
    if results["long_context"] and results["long_context"].get("input_tokens", 0) > 40000:
        score += 1
        
    if results["vision"] and results["vision"].get("correct"):
        score += 1
        
    if results["token_ratio"] and 1.2 < results["token_ratio"].get("ratio", 0) < 1.6:
        score += 1
        
    if results["latency_profile"] and 0.5 < results["latency_profile"].get("mean", 999) < 5:
        score += 1
        
    if results["knowledge_cutoff"] and results["knowledge_cutoff"].get("correct"):
        score += 1
    
    print(f"\n🎯 可信度评分: {score}/{max_score} ({score/max_score*100:.0f}%)")
    
    if score >= 5:
        print("✅ 结论: 极有可能是真实 Claude API")
    elif score >= 3:
        print("⚠️  结论: 部分能力正常，需进一步验证")
    else:
        print("❌ 结论: 可疑，不推荐使用")
    
    return results


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("用法: python verify_claude_proxy.py <base_url> <api_key>")
        sys.exit(1)
    
    base_url = sys.argv[1]
    api_key = sys.argv[2]
    
    try:
        verify_claude_proxy(base_url, api_key)
    except KeyboardInterrupt:
        print("\n\n⚠️  验证中断")
    except Exception as e:
        print(f"\n\n❌ 验证失败: {e}")
```

### 使用方法

```bash
# 安装依赖
pip install anthropic pillow

# 运行验证
python verify_claude_proxy.py "https://cc-vibe.com" "sk-xxx..."

# 输出示例见下方
```

## 判断标准

### 高可信度指标（满足 5/6 即可认为真实）

| 指标 | 真实 API 表现 | 掺水特征 |
|------|--------------|---------|
| 长上下文 | >40K tokens | <16K (GPT-3.5 level) |
| Vision | 正确识别颜色 | 拒绝图片 / 答非所问 |
| Token 比例 | 1.3-1.5 | <1.0 或 >2.0 |
| 延迟 | 1-5s | <0.5s (缓存) 或 >10s |
| 知识截止 | 正确 (Jan 2026) | 错误 / 拒答 |

### 次要指标（参考性）

- **响应头**: 官方 API 有 `anthropic-*` headers
- **Response ID**: 格式 `msg_xxx` (官方) vs 自定义格式
- **Stream 行为**: chunk 分布是否自然
- **报价**: 远低于官方价 → 可疑

## 适用场景

### ✅ 推荐使用验证通过的中转站

- 日常开发测试
- 成本敏感场景（如果比官方便宜）
- 非敏感内容处理

### ⚠️ 需权衡风险

- 用户数据处理（prompt 可能被记录）
- 中等重要业务（中转站稳定性未知）

### ❌ 不推荐

- 商业机密、用户隐私数据
- 医疗/金融等强合规场景
- 需要官方 SLA 和技术支持

## 生产环境监控

```python
# 在实际调用中加监控
import time
import logging

def call_with_monitoring(client, **kwargs):
    start = time.time()
    response = client.messages.create(**kwargs)
    latency = time.time() - start
    
    # 记录关键指标
    metrics = {
        "latency": latency,
        "input_tokens": response.usage.input_tokens,
        "output_tokens": response.usage.output_tokens,
        "model": response.model,
        "timestamp": time.time()
    }
    
    # 异常检测
    if latency < 0.5:
        logging.warning(f"异常低延迟: {latency:.2f}s")
    
    if response.usage.output_tokens < 10 and kwargs.get("max_tokens", 0) > 100:
        logging.warning(f"输出异常少: {response.usage.output_tokens} tokens")
    
    # 上报到监控系统
    report_metrics(metrics)
    
    return response
```

## 扩展：验证 OpenAI API

```python
import openai
import time

def verify_openai_proxy(base_url: str, api_key: str):
    """验证 OpenAI API 中转站"""
    
    client = openai.OpenAI(api_key=api_key, base_url=base_url)
    
    # 1. 长上下文测试 (GPT-4 支持 128K)
    long_prompt = "Hello " * 30000
    response = client.chat.completions.create(
        model="gpt-4-turbo",
        messages=[{"role": "user", "content": long_prompt + "\nRepeat: OK"}],
        max_tokens=10
    )
    
    print(f"Input tokens: {response.usage.prompt_tokens}")
    if response.usage.prompt_tokens > 100000:
        print("✅ 长上下文正常")
    else:
        print("⚠️  可能截断输入")
    
    # 2. Vision 测试
    response = client.chat.completions.create(
        model="gpt-4-vision-preview",
        messages=[{
            "role": "user",
            "content": [
                {"type": "text", "text": "What's in this image?"},
                {
                    "type": "image_url",
                    "image_url": {"url": "data:image/png;base64,..."}
                }
            ]
        }],
        max_tokens=100
    )
    
    # 3. Function calling 测试
    response = client.chat.completions.create(
        model="gpt-4-turbo",
        messages=[{"role": "user", "content": "What's the weather in Beijing?"}],
        tools=[{
            "type": "function",
            "function": {
                "name": "get_weather",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "location": {"type": "string"}
                    }
                }
            }
        }]
    )
    
    if response.choices[0].message.tool_calls:
        print("✅ Function calling 正常")
```

## 参考资源

- Anthropic 官方定价: https://www.anthropic.com/pricing
- OpenAI 官方定价: https://openai.com/api/pricing/
- Token 计数工具: `tiktoken` (OpenAI), `anthropic.count_tokens()` (Claude)
- 社区讨论: Reddit r/LocalLLaMA, V2EX AI 节点

## 版本历史

- 2026-06-25: 初版，基于 Claude Opus 4.6 验证案例总结
