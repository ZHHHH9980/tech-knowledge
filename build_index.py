#!/usr/bin/env python3
"""
技术知识库索引生成器

扫描 ~/Public/tech-knowledge/ 下所有 .md 文件，提取 frontmatter 和摘要，
生成全局索引文件供 Claude Code agent 快速检索。

用法:
    python build_index.py

输出:
    ~/Public/tech-knowledge/INDEX.md - 全局索引
    ~/Public/tech-knowledge/INDEX.json - 机器可读索引
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Optional
from dataclasses import dataclass, asdict
from datetime import datetime

@dataclass
class DocMetadata:
    """文档元数据"""
    path: str           # 相对于 tech-knowledge/ 的路径
    title: str          # 标题
    tags: List[str]     # 标签
    date: Optional[str] # 日期
    project: Optional[str]  # 关联项目
    summary: str        # 前 200 字摘要
    category: str       # 所属分类（目录名）


def extract_frontmatter(content: str) -> Dict:
    """提取 YAML frontmatter"""
    match = re.match(r'^---\n(.*?)\n---\n', content, re.DOTALL)
    if not match:
        return {}

    fm_text = match.group(1)
    metadata = {}

    # 简单解析 YAML（不依赖 pyyaml）
    for line in fm_text.split('\n'):
        if ':' not in line:
            continue
        key, value = line.split(':', 1)
        key = key.strip()
        value = value.strip()

        # 处理数组 [tag1, tag2]
        if value.startswith('[') and value.endswith(']'):
            value = [t.strip().strip('"\'') for t in value[1:-1].split(',')]

        metadata[key] = value

    return metadata


def extract_title(content: str) -> str:
    """提取第一个 # 标题"""
    # 跳过 frontmatter
    content = re.sub(r'^---\n.*?\n---\n', '', content, flags=re.DOTALL)

    match = re.search(r'^#\s+(.+)$', content, re.MULTILINE)
    if match:
        return match.group(1).strip()

    return "Untitled"


def extract_summary(content: str, max_length: int = 200) -> str:
    """提取摘要（去掉 frontmatter 和标题后的前 N 字）"""
    # 去掉 frontmatter
    content = re.sub(r'^---\n.*?\n---\n', '', content, flags=re.DOTALL)

    # 去掉第一个标题
    content = re.sub(r'^#\s+.+\n', '', content, flags=re.MULTILINE, count=1)

    # 去掉代码块
    content = re.sub(r'```.*?```', '', content, flags=re.DOTALL)

    # 去掉 markdown 语法
    content = re.sub(r'[#*`\[\]()]', '', content)

    # 去掉多余空白
    content = ' '.join(content.split())

    if len(content) > max_length:
        return content[:max_length] + '...'

    return content


def scan_knowledge_base(base_path: Path) -> List[DocMetadata]:
    """扫描知识库所有文档"""
    docs = []

    for md_file in base_path.rglob("*.md"):
        # 跳过 README 和 INDEX
        if md_file.name in ["README.md", "INDEX.md"]:
            continue

        # 读取内容
        try:
            content = md_file.read_text(encoding='utf-8')
        except Exception as e:
            print(f"⚠️  跳过 {md_file}: {e}")
            continue

        # 提取元数据
        frontmatter = extract_frontmatter(content)
        title = extract_title(content)
        summary = extract_summary(content)

        # 分类（目录名）
        relative_path = md_file.relative_to(base_path)
        category = relative_path.parts[0] if len(relative_path.parts) > 1 else "root"

        # 构建元数据对象
        doc = DocMetadata(
            path=str(relative_path),
            title=title,
            tags=frontmatter.get('tags', []),
            date=frontmatter.get('date'),
            project=frontmatter.get('project'),
            summary=summary,
            category=category
        )

        docs.append(doc)

    return docs


def generate_markdown_index(docs: List[DocMetadata], output_path: Path):
    """生成 Markdown 格式索引"""

    # 按分类分组
    by_category = {}
    for doc in docs:
        if doc.category not in by_category:
            by_category[doc.category] = []
        by_category[doc.category].append(doc)

    # 按标签索引
    by_tag = {}
    for doc in docs:
        for tag in doc.tags:
            if tag not in by_tag:
                by_tag[tag] = []
            by_tag[tag].append(doc)

    # 生成 Markdown
    lines = [
        "# 技术知识库索引",
        "",
        f"最后更新: {datetime.now().strftime('%Y-%m-%d %H:%M')}",
        f"文档总数: {len(docs)}",
        "",
        "## 快速检索",
        "",
        "### 按分类",
        ""
    ]

    for category in sorted(by_category.keys()):
        category_docs = by_category[category]
        lines.append(f"#### {category} ({len(category_docs)} 篇)")
        lines.append("")

        for doc in sorted(category_docs, key=lambda d: d.date or "", reverse=True):
            tags_str = f" `{' '.join(doc.tags)}`" if doc.tags else ""
            date_str = f" *{doc.date}*" if doc.date else ""
            lines.append(f"- [{doc.title}](./{doc.path}){tags_str}{date_str}")
            lines.append(f"  {doc.summary}")
            lines.append("")

    lines.extend([
        "### 按标签",
        ""
    ])

    for tag in sorted(by_tag.keys()):
        tag_docs = by_tag[tag]
        lines.append(f"#### `{tag}` ({len(tag_docs)} 篇)")
        lines.append("")

        for doc in tag_docs:
            lines.append(f"- [{doc.title}](./{doc.path})")

        lines.append("")

    lines.extend([
        "## 全部文档（按时间）",
        ""
    ])

    all_docs_sorted = sorted(docs, key=lambda d: d.date or "1970-01-01", reverse=True)
    for doc in all_docs_sorted:
        tags_str = f" `{' '.join(doc.tags)}`" if doc.tags else ""
        date_str = f" *{doc.date}*" if doc.date else ""
        lines.append(f"### [{doc.title}](./{doc.path}){tags_str}{date_str}")
        lines.append("")
        lines.append(f"**分类**: {doc.category}")
        if doc.project:
            lines.append(f" | **项目**: {doc.project}")
        lines.append("")
        lines.append(doc.summary)
        lines.append("")
        lines.append("---")
        lines.append("")

    # 写入文件
    output_path.write_text('\n'.join(lines), encoding='utf-8')
    print(f"✅ 生成 Markdown 索引: {output_path}")


def generate_json_index(docs: List[DocMetadata], output_path: Path):
    """生成 JSON 格式索引"""

    data = {
        "generated_at": datetime.now().isoformat(),
        "total_docs": len(docs),
        "documents": [asdict(doc) for doc in docs]
    }

    output_path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f"✅ 生成 JSON 索引: {output_path}")


def main():
    base_path = Path.home() / "Public" / "tech-knowledge"

    if not base_path.exists():
        print(f"❌ 知识库目录不存在: {base_path}")
        return

    print(f"🔍 扫描知识库: {base_path}")
    docs = scan_knowledge_base(base_path)
    print(f"📚 找到 {len(docs)} 篇文档")

    # 生成索引
    generate_markdown_index(docs, base_path / "INDEX.md")
    generate_json_index(docs, base_path / "INDEX.json")

    print("\n✅ 索引生成完成")
    print(f"\n💡 Agent 可以通过以下方式使用:")
    print(f"   1. 阅读 ~/Public/tech-knowledge/INDEX.md 浏览全部文档")
    print(f"   2. 用 grep 搜索: grep -i 'redis' ~/Public/tech-knowledge/INDEX.md")
    print(f"   3. 解析 INDEX.json 做精确匹配")


if __name__ == "__main__":
    main()
