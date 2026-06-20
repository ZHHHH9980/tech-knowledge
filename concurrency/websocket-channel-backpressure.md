***tags: [concurrency, go, websocket, backpressure]
date: 2026-06-12
project: 7verse-agent
***
WebSocket Channel 队列 + WritePump 背压处理

现象

WebSocket 长连接场景下，如果 LLM 流式输出速度 > 客户端消费速度（弱网、Tab 切后台），
服务端 write buffer 无限增长，最终 OOM 或导致其他连接的推送延迟。

根因

直接在业务 goroutine 中调用 conn.WriteMessage() 存在两个问题：
WriteMessage 有锁，多个 goroutine 并发写会阻塞
没有容量控制，消息堆积无感知

修复

采用 Channel 队列 + 独立 WritePump goroutine 模式：

type Conn struct {
    sendCh chan []byte  // 固定容量 256
    closed chan struct{}
}

// 业务侧：非阻塞写入
func (c *Conn) Send(data []byte) {
    select {
    case c.sendCh <- data:    // 正常入队
    case <-c.closed:          // 连接已关闭
    default:                  // 队列满，丢弃并告警
        log.Errorf("[WS] send channel full, dropping message")
    }
}

// WritePump：独立 goroutine 消费队列
func (c *Conn) writePump() {
    for {
        select {
        case msg := <-c.sendCh:
            c.ws.WriteMessage(websocket.TextMessage, msg)
        case <-c.closed:
            return
        }
    }
}

优雅关闭：主进程 shutdown 时先发 CloseGoingAway 帧，再 sleep 3s 让 WritePump 自然退出。

模式抽象

任何需要从多个生产者推送到单个网络连接的场景，都应该用固定容量 Channel + 独立写泵：
Channel 容量 = 可接受的最大排队消息数（太大浪费内存，太小频繁丢弃）
default 分支做背压处理（丢弃/降级/告警），绝不阻塞业务 goroutine
ReadPump 和 WritePump 各自独立，通过 closed channel 协调生命周期
关闭顺序：close(closed) → ReadPump 退出 → WritePump drain 后退出
