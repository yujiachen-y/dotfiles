# 私密文件格式

`private/` 下的文件都由本 skill 维护。目录已被 gitignore，会通过 iCloud 同步到用户的其他机器。

本文件各节：文件清单、config.json、ledger.md、状态和转换条件、proposals/P-NNN.md、report.md。

## 文件清单

- `private/config.json`：本 skill 的数据源配置
- `private/state.json`：扫描游标，只由 `digest.py mark` 写
- `private/ledger.md`：loop 台账
- `private/proposals/P-NNN.md`：提议，一条一个文件
- `private/runs/<日期>-<主机>/`：一次批量运行的 digest、`run.json` 和 `report.md`

## config.json

```json
{
  "vault": "~/path/to/obsidian/vault",
  "vault_exclude": ["目录A", "目录B/子目录"],
  "vault_full_history": ["复盘笔记所在目录"],
  "claudeai_backup": "~/path/to/claude-export",
  "first_run_days": 90
}
```

- `vault`：Obsidian vault 根目录。没有就写 `null`。
- `vault_exclude`：自动化任务生成的目录，相对 vault 根目录。这些目录不列入 digest。
- `vault_full_history`：首次扫描时不受时间窗口限制、列出全部历史的目录。通常是月度或年度复盘。
- `claudeai_backup`：claude.ai 导出目录，里面要有 `conversations/split/index.json`。没有就写 `null`。
- `first_run_days`：没有游标时往回扫多少天。

## ledger.md

```markdown
# Loop ledger

更新：YYYY-MM-DD（会话模式 / 批量模式 · 主机）

## L-001 一句话描述 loop

- 状态：observed
- 角色：重试
- 首次 / 最近：YYYY-MM-DD / YYYY-MM-DD
- 证据次数：4（涉及 3 个会话）
- 证据：
  - YYYY-MM-DD · claude · 0ded4830 · 「Try again」
- 已计会话：0ded4830 7a68b8d3 044263e5
- 目标后面的目标：用户真正要的结果，一句话
- 指标：每周人工介入次数；结果信号：一句话
- 指标记录：YYYY-MM-DD 3 · YYYY-MM-DD 1
- 提议：P-002（open）
- 产物：路径或 —

## 已退休

- L-000 一句话描述 · 退休原因 · YYYY-MM-DD
```

规则：

- 「已计会话」列出所有计入过的会话 id 前 8 位，不删。合并新证据前先查这一行：会话已经在里面，就跳过。会话模式下反思的当前会话除外，可以继续追加。
- 每条 loop 只保留最近 5 条证据。更早的证据只计入「证据次数」。
- 每条证据写日期、来源、会话 id 前 8 位，以及不超过 60 字的用户原话。来源是 vault 时，用笔记的相对路径代替会话 id。
- 「指标记录」每次批量运行追加一个数，只保留最近 8 个。

## 状态和转换条件

| 状态 | 进入条件 |
|---|---|
| observed | 第一次见到 |
| candidate | 证据次数 ≥3 且涉及 ≥2 个会话；或单个会话里用户为它花了 ≥10 轮对话 |
| proposed | 已经写好提议，等用户决定 |
| graduated | 用户采纳，产物已经落地 |
| reopened | graduated 之后连续 4 次批量运行，介入次数都没有低于毕业前 4 周的平均值 |
| retired | observed 连续 8 周没有新证据；或 graduated 连续 8 周介入次数为 0 且结果信号正常 |

- 如果用户拒绝了提议，就把 loop 改回 candidate，并在提议文件里记下拒绝原因。
- 被拒绝的出口不要再提。新增 ≥3 条证据后，可以换一个出口重新提议。
- reopened 的 loop 按 candidate 处理，提议里要写明上一个产物为什么没有起效。

## proposals/P-NNN.md

```markdown
---
id: P-007
loop: L-003
status: open
exit: 改现有产物
target: ~/Workspace/github.com/owner/repo/.agent/skills/foo/SKILL.md
created: YYYY-MM-DD
---

# 一句话说清改什么

## 证据

3–5 条，格式同 ledger。

## 目标后面的目标

一句话。

## 改动

target 是 git 跟踪的文件时，写成可以直接应用的 unified diff。
新建文件时写全文。给用户本人的行为建议不需要这一节。

## 指标

- 介入次数怎么数：哪些用户原话、哪些会话算一次
- 结果信号：介入次数下降时，用什么确认用户没有放弃这件事

## 脱敏自查

逐条写「通过」或改了什么，对应 SKILL.md 的脱敏规则。

## 决定

用户决定后填写：采纳 / 拒绝及原因 / 日期。
```

- `status` 只取 `open`、`applied`、`rejected`。
- 编号全局递增。新编号取 `private/proposals/` 里最大编号加 1。

## report.md

```markdown
# Lifting Loops 周报 · YYYY-MM-DD · 主机

## 需要你决定的事

- P-007 一句话 → [proposals/P-007.md](../../proposals/P-007.md)

## 本周数据

会话 N 个（人工发起 a，定时 b），人工介入 M 次：重试 r，裁判 j，审批 g，搬运 c，触发 t，代劳 h。

## 已毕业 loop 的指标

| loop | 产物 | 毕业前每周介入 | 本周 | 结果信号 |
|---|---|---|---|---|

## 新发现和升级

- L-012（新）一句话
- L-004 observed → candidate，原因

## 给你的建议

最多 3 条。只写用户本人才能改的做法。

## 记忆整理

每条记忆一行：保留 / 已被某产物覆盖，可删 / 提议 P-NNN。

## 度量检查

每个指标一句话：数字的变化是不是真的变好了。
```
