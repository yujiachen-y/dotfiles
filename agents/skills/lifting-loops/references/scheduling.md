# 设置每周定时任务

在 Claude 桌面端的会话里执行，`scheduled-tasks` 工具只在桌面端提供。会话记录只存在本机，所以每台要扫描的机器各设一次。

1. 确认当前会话的工作目录不是 Obsidian vault。定时任务没有工作目录参数，会沿用创建它的会话的目录；vault 的 AGENTS.md 默认只读问答，会和本任务冲突。如果在 vault 里，请用户换到 dotfiles 仓库或 `~/Workspace` 下的会话再做。
2. 运行 `python3 scripts/digest.py status`（在本 skill 目录下），确认脚本能跑、`config: found`。如果缺配置，先按 SKILL.md「准备」补上。
3. 问用户周日几点运行。如果用户没有偏好，建议排在其他周复盘任务之后，这样那些任务的会话能进入本周的扫描。用 `list_scheduled_tasks` 查已有任务的时间。
4. 调用 `create_scheduled_task`：
   - `taskId`：`lifting-loops-weekly`
   - `title`：`Lifting Loops 周复盘`
   - `description`：`每周日扫描本机会话、vault 和记忆，更新 loop 台账，写周报和提议`
   - `cronExpression`：`<分> <时> * * 0`，按本机时区
   - `notifyOnCompletion`：`true`
   - `prompt`：下面的全文
5. 调用 `run_scheduled_task` 试跑一次，再用 `list_task_runs` 确认运行完成。
6. 打开运行目录里的 `report.md`，确认报告已经生成、`private/state.json` 里本机的游标已经推进。

## prompt

```
使用 lifting-loops skill，按批量模式运行。

- 这是无人值守的定时运行。不要停下来提问，也不要等确认。
- 用户已授权你直接写这个 skill 目录下 private/ 里的文件。其他文件一律只读：git 跟踪的文件只写提议，Obsidian vault 不改。
- 如果某个数据源读不到，跳过它，在报告开头写明原因，继续其余步骤。
- 结束时用三四句话总结：本周最值得处理的 loop、需要用户决定的提议编号、报告路径。
```

## 修改或停用

- 改时间：`update_scheduled_task`，传 `taskId` 和新的 `cronExpression`。
- 停用：`update_scheduled_task`，传 `taskId` 和 `enabled: false`。
- 改 prompt 时，同步更新本文件。
