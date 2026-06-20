***tags: [architecture, go, llm, tool-calling, error-recovery]
date: 2026-06-12
project: 7verse-agent
***
LLM Tool 参数容错 + FC Loop 自动恢复

现象

LLM Function Calling 在生产中有两类典型故障：

参数格式不稳定：同一个 Tool 的 string_array 参数，LLM 有时返回 ["a","b"]，有时返回 "a, b" 字符串
幻觉跳过 Tool：LLM 声称"已完成"但实际从未调用必要的 Tool（如 generate_visual）

这两类问题导致用户看到残缺的生成结果。

根因

LLM 的结构化输出质量不是 100% 可靠的，即使有 JSON Schema 约束
LLM 的"任务完成"判断基于文本推理，可能产生幻觉（认为已调用但实际没有）

修复

参数容错：ArgReader 优雅降级

type argReader struct {
    fields map[string]json.RawMessage
}

func (r *argReader) StringSlice(keys ...string) []string {
    raw := r.Raw(keys...)
    // 1. 先尝试标准 JSON Array
    var arr []string
    if json.Unmarshal(raw, &arr) == nil { return arr }
    // 2. 降级：把单个 string 当作逗号分隔的 array
    var s string
    if json.Unmarshal(raw, &s) == nil {
        return strings.Split(s, ",")
    }
    // 3. 兜底：返回空
    return nil
}

keys ...string 支持多 key 回退：LLM 可能用 visual_prompt 也可能用 prompt。

FC Loop 安全网：Turn 结束前自动检查

func (e *Engine) ensureCoreAssets(ts *turnState, pool AssetPool) {
    for assetType, toolName := range coreGenerateTools {
        if pool.HasCandidate(assetType) { continue }
        
        // Tool 被调用过但没产出 → 重试一次
        if ts.ToolWasCalled(toolName) {
            e.retryTool(ts, toolName)
            continue
        }
        // Tool 从未被调用（LLM 幻觉） → 只对 persona 补救
        if assetType == AssetPersona {
            e.retryTool(ts, toolName)
        }
    }
}

Guide Card 验证 + 指导性错误

func invalidGuideCardToolResult(reason string) *ToolResult {
    return &ToolResult{
        Success: false,
        Message: fmt.Sprintf(
            "push_guide_card output rejected: %s. "+
            "Do not send any user-visible correction text. "+
            "Retry push_guide_card immediately with corrected parameters.",
            reason),
    }
}

错误信息本身就是给 LLM 的修复指令，让 FC Loop 在下一轮自动纠正。

模式抽象

与 LLM Tool Calling 集成时的防御性设计三原则：

参数层：假设格式不可靠。ArgReader 做多级降级（标准解析→宽松解析→默认值），不因格式异常中断流程
结果层：Trust but Verify。FC Loop 结束前检查"必要产出是否真的存在"，区分"Tool 失败"和"LLM 没调用"两种模式分别处理
反馈层：错误即指令。返回给 LLM 的错误信息不是给人读的日志，而是精确的修复指令（告诉它"不要道歉，直接重试，参数改成 XXX"）
