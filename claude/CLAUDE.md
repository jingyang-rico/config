# Global Instructions

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

## Code Review
- 完成代码编辑后，使用 code-reviewer agent 审查变更
- 审查范围：本次会话中使用 Edit/Write 工具修改的所有文件
- 发现问题时先报告，等待确认后再修复

## Git
- Write commits in imperative mood (e.g., `Add drama carousel logging adapter`)
- Edits are auto-approved

---

# iOS Development

## Tech Stack
- **Language:** Swift 5.10 / iOS 15+ (no new Objective-C)
- **Dependency Manager:** CocoaPods (`bundle exec pod install`, never bare `pod install`)
- **UI Framework:** UIKit (primary), SwiftUI (widgets)
- **Architecture:** Modular feature-based architecture with 100+ local pods

## Codex Automation
- After code edits, run `bundle exec pod install` (if CocoaPods files changed), then open Xcode and build (Command+R)
- If build errors, capture logs, fix, and rerun until success

## Remote Pods (Pods/ 目录)
- `NewsBreak/Pods/` 下的文件被 `.gitignore` 忽略，**不能**通过主仓库 PR 提交
- 如果需要修改 `Pods/` 目录下的代码，**必须提醒用户**：这是远程仓库的代码，需要到对应源码仓库单独修改、提交、推送
- 修改流程：(1) 在源码仓库（如 `/Users/yxj/Work/NBSafetyMap`）修改并 push → (2) 回到主仓库更新 Podfile 中的 commit ID → (3) `bundle exec pod install`
- 创建主仓库 PR 时，如果涉及远程 pod 改动，**必须提醒用户**对应的独立仓库也需要先合并

## Schema 仓库改动顺序 (client-log-schema / api-schema)
改埋点事件或接口数据格式时，这两个 schema 仓库（`ParticleMedia/client-log-schema`、`ParticleMedia/api-schema`，本地 `~/Work/...`）的**生成产物由 GitHub Action 生成，不要手动生成并塞进 PR**。固定顺序：
1. **只提交 `.proto` 文件变化的 PR** → review → 合并到 `main`。⚠️ **PR 里绝不能包含生成的 Swift 代码**——Swift/产物只由 GitHub Action 触发生成。
2. 合并后**触发 GitHub Action 生成 Swift 文件**（`workflow_dispatch`，如 client-log-schema 的 `Publish Swift Protobuf Files`：`gh workflow run publish_swift.yml --ref main`）；它会用官方工具链重生成全部产物并 auto-commit 一条产物提交。
3. 更新消费方工程 `Podfile` 的 commit id，**指向 Action 产出的那条产物提交**（不是 PR 的 merge commit）→ `bundle exec pod install`。
4. **最后再做消费方 iOS 工程侧**（埋点封装/接口调用等）。
- 这条顺序对**所有**消费这些 schema 的 iOS 工程通用（ios-chat、ios-radar、community-ios… 不只某一个）。
- 即在 schema PR 合并 + Action 跑完之前，不要动消费方工程的接入代码（会因产物未发布而编译不过）。细节坑见 memory `add-nomi-tracking-event`。

## Naming
- **NBNetwork** (correct) — not **NBNetWork**
- Author header: use `git config user.name`

## Architecture (MVVM)

### Simple Page
`Model/` `View/` `ViewModel/` `Repository/` — Template: `~/Library/Developer/Xcode/Templates/File Templates/SimpleMVVMPage.xctemplate`

### Complex Page (with ComponentKit)
Above + `Component/listcomponent/` `Component/othercomponent/` — Template: `~/Library/Developer/Xcode/Templates/File Templates/ComplexMVVMPage.xctemplate`

### Rules
- Combine for data binding, SnapKit for layout
- List components inherit `BaseListComponent`, non-list inherit `BaseComponent`
- ActionHandler pattern: implement `ActionHandling` protocol with `supportedActions()` + `performAction()`

## UIKit Notes
- **Never use `UIButton.contentEdgeInsets`** — use `UIButton.Configuration` or constraints
- Custom colors via `.NB.primarySurface`, design system in NBDesignSystem module

## 通知权限 (Push Notification Permission)
- 处理"开启通知"入口时**必须按 `UNAuthorizationStatus` 分流**，不能把所有未授权情况都跳系统设置：
  - `.notDetermined`（从未弹过系统弹窗）：iOS 系统设置里**根本没有该 App 的通知开关**，跳过去是死路 → 必须在 App 内调 `requestAuthorization` 触发系统弹窗一次。
  - `.denied`（已弹过、被拒）：系统设置里才有开关 → 此时跳 `UIApplication.openSettingsURLString` 才合理。
  - `.authorized/.provisional/.ephemeral`：已授权，给个 toast 即可。
- 授权通过后记得 `UIApplication.shared.registerForRemoteNotifications()` 并刷新 UI 状态。

## SnapKit 布局规则
- **先 `addSubview`，再 `makeConstraints`**：建立跨兄弟视图的约束（如 `a.bottom == b.top`）时，两个 view 必须已经在同一视图层级里，否则运行时抛 `NSGenericException: no common ancestor`。
- 正确做法：先把所有子视图 `addSubview` 到父视图，然后再统一写 `snp.makeConstraints`。不要交替穿插"addSubview + 立即 makeConstraints + addSubview + 立即 makeConstraints"。

## UI Automation Testing
- 开发完成后不要自动开始 UI 自动化测试，先询问用户是否要进行
- 得到肯定回答后，使用 iPhone 16e 模拟器 (UDID: A494B81E-790F-430A-9FA2-8E4B6E91C302) 进行测试
- 使用 AXe CLI 工具进行模拟器交互（tap, swipe, screenshot, describe-ui 等）
- 测试前需要先通过 xcodebuildmcp 编译安装 App 到模拟器
- 如果模拟器网络不通，检查 Charles Proxy 证书是否已安装并信任

---

# External Tools

## Atlassian
- 所有 `https://particlemedia.atlassian.net/` 操作统一使用 `plugin:atlassian` MCP 工具
- Wiki 子页面创建在 **iOS Portal** 下（spaceId: `3942842385`, parentId: `4055203892`）
- `editJiraIssue` 的 `description` 传 **markdown 字符串**（插件自动转 ADF）

### Confluence 上传截图
- 凭证 `ATLASSIAN_EMAIL` / `ATLASSIAN_API_TOKEN` 在 `~/.config/secrets.env`（交互 shell 已自动 source；脚本里需先 `source`）。见 KB §9 密钥目录。
- MCP 插件无附件上传功能，需用 REST API：`curl -u "${ATLASSIAN_EMAIL}:${ATLASSIAN_API_TOKEN}" -X POST -H "X-Atlassian-Token: nocheck" -F "file=@/path/to/image.png" "https://particlemedia.atlassian.net/wiki/rest/api/content/${PAGE_ID}/child/attachment"`
- 上传后需查询附件的 `fileId`：`curl -u "${ATLASSIAN_EMAIL}:${ATLASSIAN_API_TOKEN}" ".../content/${PAGE_ID}/child/attachment"` → `extensions.fileId`
- 页面内嵌图片用 ADF `mediaSingle` + `media` 节点，`id` 必须是附件的 `fileId`（UUID），不能用文件名
- `collection` 固定为 `"contentId-${PAGE_ID}"`
- 示例：`{"type": "media", "attrs": {"type": "file", "collection": "contentId-123", "id": "uuid-from-fileId"}}`

---

# Knowledge Base
- **何时读** `~/.claude/KNOWLEDGE_BASE.md`（代码库/应用权威映射）——命中以下任一就先读：
  - 提到某 **App 名 / Bundle ID / 仓库名 / Jenkins job / "打包·发版·build"**
  - 要判断 **"改动属于哪个仓库 / 去哪改 / 哪些工程要同步"**（跨工程、谱系类）
  - **cwd 落在 `~/Work` 某子目录**里干活，或**崩溃/日志带 bundle id** 要反查仓库
  - 改 **schema / 埋点 / 接口**（api-schema·client-log-schema 流程）或 **NB\* 远程 pod**
  - （纯闲聊 / 与这些项目无关的通用编程 / 一次性脚本：**不必读**）
- **git 事实**（remote/默认分支/worktree·克隆拓扑/最近提交）在 `~/.claude/kb/repos.generated.md`，由 `kb-sync.sh` 自动生成、勿手改；怀疑过期就跑 `bash ~/.claude/kb-sync.sh`。当前分支等易变信息用 `git`/`gh` 现查、不要信缓存。
- **发现 KB 策展事实有误/缺失**：顺手更新对应条目并改其顶部「最后核对」日期。


<claude-mem-context>
# Recent Activity

<!-- This section is auto-generated by claude-mem. Edit content outside the tags. -->