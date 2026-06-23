# KNOWLEDGE_BASE — Jing Yang 的代码库 / 应用 / 构建 权威映射

> **用途**：这是 Jing Yang（yxj）给 Claude Code 的"自我介绍 + 团队介绍"知识库。
> **覆盖范围**：他维护的所有仓库、App、Bundle ID、打包/Jenkins、产品谱系与约定。读到时按需定位到对应小节，不要凭目录名猜归属。（"**何时**来读本文件"的触发规则在全局 `~/.claude/CLAUDE.md`「Knowledge Base」段，不在此重复。）
> **权威性**：本文件取代散落的 `~/Desktop/apps_map.md`、`~/Work/map.md`、`~/Work/maintained_apps_table.{md,csv}`（历史遗留，可能过期）。
> **维护方式**：分级维护，见 [§8](#8-维护机制分级维护)。简言之——产品/分类/坑等"策展知识"手动 + AI 顺手更新；git 事实（remote/分支/worktree）由 `kb-sync.sh` 自动生成到 `kb/repos.generated.md`，勿手改；当前分支等易变信息不入库、用时现查。
> **最后核对（策展层）**：2026-06-23。

---

## 1. 关于我（self intro）

- **姓名**：Jing Yang（中文 yxj；git `user.name = Jing Yang`）
- **公司**：ParticleMedia（NewsBreak 母公司）
- **主职**：iOS 开发；同时跨 Android、Go 后端、Python AI 服务、Web、AI 工具链
- **邮箱**：
  - 工作 `jing.yang@newsbreak.com`（所有公司仓库的 git author）
  - 个人 `hustyxjxx@gmail.com`
- **GitHub 身份**：
  - `ParticleMedia/*` — 公司组织仓库（主力）
  - `jingyang-rico/*` — 个人账号下的 fork / 实验（如 claude-sub、config、app-store-connect-notifier）
  - `yxjxx/*` — 纯个人项目，走 SSH host 别名 `github-yxjxx`（如 claude-ratelimit-bar）
- **本地主工作目录**：`/Users/yxj/Work`
- **公司打包机 workspace 路径**：`/Users/jing.yangnewsbreak.com/workspace/...`（与本机路径不同，换机注意）

---

## 2. 产品谱系 / App 映射表

### 谱系（产品怎么来的）

iOS App 大多由「拷贝代码」派生，理解血缘有助于定位相似逻辑、判断一个改动要同步到哪些工程：

- **NewsBreak**（`iOS`）— 公司最早的产品，所有 iOS App 的源头。
- **2025 年从 NewsBreak 各拷贝出一个独立 App：**
  - **CrimeRadar**（`ios-radar`）— 后在其中复制出新 target **OurBlock**（又名 **LifeInfo**）。
  - **LocalAll**（`community-ios`，曾用名 **community / zests**）— 在其中新增两个 target：**BibleVod**、**PillsMinder**。
- **BibleVod 独立**（2026-06）：从 LocalAll 拷贝一份分开维护 → 新仓库 **`ParticleMedia/ios-bible`**。
- **SayFlow**（`sayflow-ios`）— 基于 LocalAll 代码拷贝。
- **Scoopz**（`scoopz-ios`）— 另一个从 NewsBreak 拷贝、已独立维护一段时间的 App。
- **NomiChat**（`ios-chat`）— 全新项目，基于壳工程 **NBShellApp**。

```
NewsBreak (iOS)
├─ CrimeRadar (ios-radar) ── target: OurBlock / LifeInfo
├─ LocalAll (community-ios，旧名 community / zests)
│   ├─ target: PillsMinder
│   ├─ target: BibleVod ──(2026-06 拆出)──▶ ios-bible（独立仓库）
│   └─ 拷贝 ──▶ SayFlow (sayflow-ios)
└─ 拷贝 ──▶ Scoopz (scoopz-ios，已独立)

NomiChat (ios-chat) ── 基于壳工程 NBShellApp（新 App 推荐路径）
```

> **壳工程方向**：以后新 App 都推荐用 **NBShellApp** 起步；开发壳工程派生 App 时，部分通用基础代码需 **port 回 NBShellApp**（反哺壳工程）。
> **组件化进行中**：正把工程组件化，让不同 App 通过 **CocoaPods pod** 共享组件；**一个远程仓库可能含多个 pod**（见 §3.2，如 NBBusinessPods）。

### App 映射表

> Bundle ID / Package Name 用于从 Crashlytics、App Store Connect 等自动反查到正确的仓库。

### iOS

| App | Bundle ID | 仓库 | 本地目录 | Jenkins Release | Jenkins Beta |
|---|---|---|---|---|---|
| **NewsBreak** | `com.particlenews.newsbreak` | ParticleMedia/iOS | `Work/nb-iOS` | [ios-release](https://ci.n.newsbreak.com/job/Sandbox/job/ios-release/) | [ios-beta](https://ci.n.newsbreak.com/job/Sandbox/job/ios-beta/) |
| **CrimeRadar** | `com.newsbreak.radar` | ParticleMedia/ios-radar | `Work/ios-radar` | [ios-radar-release](https://ci.n.newsbreak.com/job/Sandbox/job/ios-radar-release/) | [ios-radar-beta](https://ci.n.newsbreak.com/job/Sandbox/job/ios-radar-beta/) |
| **OurBlock (LifeInfo)** | `com.lifeagents.lifeinfo` | ParticleMedia/ios-radar | `Work/ios-radar` | — | — |
| **LocalAll** | `com.scoopz.zests` | ParticleMedia/community-ios | `Work/community-ios` | [ios-community-release](https://ci.n.newsbreak.com/job/Sandbox/job/ios-community-release/) | [ios-community-beta](https://ci.n.newsbreak.com/job/Sandbox/job/ios-community-beta/) |
| **Bible Vod** | `com.lifeagents.biblevod` | **ParticleMedia/ios-bible**（2026-06 拆出） | `Work/ios-bible` | [ios-biblevod-release](https://ci.n.newsbreak.com/job/Sandbox/job/ios-biblevod-release/) | [ios-biblevod-beta](https://ci.n.newsbreak.com/job/Sandbox/job/ios-biblevod-beta/) |
| **Pills Minder** | `com.lifeagents.health` | ParticleMedia/community-ios | `Work/community-ios` | [ios-health-release](https://ci.n.newsbreak.com/job/Sandbox/job/ios-health-release/) | [ios-health-beta](https://ci.n.newsbreak.com/job/Sandbox/job/ios-health-beta/) |
| **SayFlow** | `com.lifeagents.sayflowinput` | ParticleMedia/sayflow-ios | `Work/sayflow-ios` | [ios-sayflow-release](https://ci.n.newsbreak.com/job/Sandbox/job/ios-sayflow-release/) | [ios-sayflow-beta](https://ci.n.newsbreak.com/job/Sandbox/job/ios-sayflow-beta/) |
| **Scoopz** | `com.localaiapp.bloom` | ParticleMedia/scoopz-ios | `Work/scoopz-ios` | [scoopz-ios-release](https://ci.n.newsbreak.com/job/Elev-Prod/job/scoopz-ios-release/)（在 Elev-Prod 文件夹） | — |
| **NomiChat** | `com.lifeagents.chat` | ParticleMedia/ios-chat | `Work/ios-chat` | [ios-chat-release](https://ci.n.newsbreak.com/job/Sandbox/job/ios-chat-release/) | [ios-chat-beta](https://ci.n.newsbreak.com/job/Sandbox/job/ios-chat-beta/) |

> `community-ios` 现出两个产品（LocalAll / Pills Minder），靠 scheme/flavor 区分；**Bible Vod 已于 2026-06 拆到独立仓库 `ios-bible`**。

### Android

| App | Package Name | 仓库 | 本地目录 | Jenkins Release | Jenkins Beta |
|---|---|---|---|---|---|
| **NewsBreak** | `com.particlenews.newsbreak` | ParticleMedia/Android | （未克隆） | [android_release](https://jenkins.nb-sandbox.com/view/Android/job/newsbreak/job/android_release/) | [android_beta](https://jenkins.nb-sandbox.com/view/Android/job/newsbreak/job/android_beta/) |
| **CrimeRadar** | `com.newsbreak.crimeradar` | ParticleMedia/android-radar | `Work/android-radar` | [crime-radar-release](https://jenkins.nb-sandbox.com/view/Android/job/apps/job/crime-radar-release/) | [crime-radar-beta](https://jenkins.nb-sandbox.com/view/Android/job/apps/job/crime-radar-beta/) |
| **LocalAll** | `com.zests.ai` | ParticleMedia/android-community | `Work/android-community` | [community-release](https://jenkins.nb-sandbox.com/view/Android/job/apps/job/community-release/) | [community-beta](https://jenkins.nb-sandbox.com/view/Android/job/apps/job/community-beta/) |
| **Bible Vod** | `com.bible.vod` | ParticleMedia/android-community（同 LocalAll，不同 flavor） | `Work/android-community` | [bible-release](https://jenkins.nb-sandbox.com/view/Android/job/apps/job/bible-release/) | [bible-beta](https://jenkins.nb-sandbox.com/view/Android/job/apps/job/bible-beta/) |
| **SayFlow** | `com.lifeagents.sayflow` | ParticleMedia/android-sayflow | （未克隆） | 暂无 | [sayflow-beta](https://jenkins.nb-sandbox.com/view/Android/job/apps/job/sayflow-beta/) |

---

## 3. 仓库清单（按用途分类）

> 📟 各仓库的 **remote / 默认分支 / worktree·克隆拓扑 / 最近提交** 是「B 类」可派生事实，
> 由 `kb-sync.sh` 自动生成在 [`~/.claude/kb/repos.generated.md`](kb/repos.generated.md)（含漂移报告），**勿手改**。
> 本节只维护稳定的「分类 + 说明」（A 类）；下表保留 `远程` 列是因为它极少变动、便于一眼定位（以生成文件为准）。
> 「当前分支 / 最新 commit / 开着的 PR」是「C 类」易变信息，**不入库**——请 `git` / `gh` 现查。

### 3.1 iOS App 工程

| 本地目录 | 远程 | 说明 |
|---|---|---|
| `nb-iOS` | ParticleMedia/iOS | NewsBreak iOS 主工程（本地唯一克隆） |
| `community-ios` | ParticleMedia/community-ios | LocalAll / Pills Minder 共用工程（Bible Vod 原为此处 target，2026-06 拆到 ios-bible） |
| `ios-bible` | ParticleMedia/ios-bible | BibleVod 独立工程（2026-06 从 community-ios 拆出） |
| `ios-radar` | ParticleMedia/ios-radar | CrimeRadar / OurBlock(LifeInfo) 工程 |
| `sayflow-ios` | ParticleMedia/sayflow-ios | SayFlow 输入法 App |
| `scoopz-ios` | ParticleMedia/scoopz-ios | Scoopz App |
| `ios-chat` | ParticleMedia/ios-chat | NomiChat（Nomi AI 陪伴聊天 iOS） |
| `NBShellApp` | ParticleMedia/NBShellApp | 壳工程：clone + 填凭证 + 跑脚本即得可运行新 App（登录/埋点/崩溃/推送/归因）。配套 `/new-app-setup` skill |

### 3.2 iOS 模块化 Pod（NB* 基础设施，被上面 App 通过 CocoaPods 引用）

| 本地目录 | 远程 | 说明 |
|---|---|---|
| `NBBaseFoundation` | ParticleMedia/NBBaseFoundation | 基础 Foundation 层 |
| `NBUIFoundation` | ParticleMedia/NBUIFoundation | UI Foundation（NBDesignSystem 等设计系统在这层） |
| `NBLogFoundation` | ParticleMedia/NBLogFoundation | 日志 Foundation |
| `NBNetwork` | ParticleMedia/NBNetwork | 网络层（注意拼写：NBNetwork，**不是** NBNetWork） |
| `NBAppConfig` | ParticleMedia/NBAppConfig | App 级配置 |
| `NBCommonService` | ParticleMedia/NBCommonService | 公共服务层。原个人 fork `jingyang-rico/NBCommonService` 已删除，origin 已改指上游；`feature/jwt-token-resilience` 经 PR #3（2026-06-05）已合并 |
| `NBBusinessPods` | ParticleMedia/NBBusinessPods | 业务 Pod 集合（当前 checkout 内含 LoginComponent.podspec，与 `LoginComponent` 同源但为不同 repo，需用时再核对） |
| `ComponentKit` | ParticleMedia/ComponentKit | ComponentKit UI 组件框架（复杂页面用 BaseListComponent/BaseComponent） |
| `LoginComponent` | ParticleMedia/LoginComponent | 登录组件 Pod |
| `NBSafetyMap` | ParticleMedia/NBSafetyMap | 安全地图 Pod（被 community-ios 等引用） |

> ⚠️ **远程 Pod 改动规则**：App 工程里 `Pods/` 目录被 `.gitignore`，改动**不能**走主仓 PR。要改这些 NB* Pod，须到对应源码仓库单独改 → push → 回主仓改 Podfile 的 commit ID → `bundle exec pod install`。建主仓 PR 时要提醒对应独立仓库也需先合并。

### 3.3 Android

| 本地目录 | 远程 | 说明 |
|---|---|---|
| `android-community` | ParticleMedia/android-community | LocalAll / Bible Android |
| `android-radar` | ParticleMedia/android-radar | CrimeRadar Android |
| `android-map` | ParticleMedia/android-map | 地图模块 |

### 3.4 后端 / 服务

| 本地目录 | 远程 | 说明 |
|---|---|---|
| `server` | ParticleMedia/server | Particle Media 产品的 API 网关（纯 Golang，本地/生产 docker 部署） |
| `server-lite` | ParticleMedia/server-lite | 极简多 App 后端框架：新独立接口用它，提供到 `server` 的反向代理 + 鉴权 |
| `role-ai` | ParticleMedia/role-ai | Nomi LLM Core：Nomi 角色扮演聊天的 FastAPI 在线服务 |
| `streaming_asr` | ParticleMedia/streaming_asr | GPU1 上的 Qwen3-ASR WebSocket 流式语音识别服务 |

> **服务端架构**：NewsBreak 及大多数拷贝派生的 App 主要用 `server`；**全新的独立接口走 `server-lite`**。`server-lite` 对外提供到 `server` 的**反向代理**，并负责**鉴权**。

### 3.5 Schema / 共享数据契约

> 这两个仓库被**所有 App 共享**：`api-schema` = 接口数据格式，`client-log-schema` = 埋点日志。

| 本地目录 | 远程 | 说明 |
|---|---|---|
| `api-schema` | ParticleMedia/api-schema | 客户端↔服务端通信数据格式 schema（iOS + Android 共用） |
| `client-log-schema` | ParticleMedia/client-log-schema | 客户端埋点日志 schema（iOS + Android 共用） |

> **改 proto 定义的流程**（详细顺序 + `gh workflow run` 命令 + 「Podfile commit id 要指向产物提交」等细节见全局 CLAUDE.md「Schema 仓库改动顺序」与 memory `add-nomi-tracking-event`）：
> 1. **先查有没有现成定义**——尤其所有 App 都有的通用事件（如 `open app`），有就**复用**，没有才新建。
> 2. 改 `.proto` → 发 PR → review 无误 → **直接合并到 `main`**。
>    - ⚠️ **PR 里只能有 `.proto` 定义，绝不能包含生成的 Swift 代码**。Swift/产物**只由 GitHub Action 触发生成**，不要本地生成后塞进 PR。
> 3. 合并后**触发 GitHub Action**，等它跑完（它才生成 Swift 并 auto-commit 一条产物提交）。
> 4. 更新引用工程 `Podfile` 的 commit id → 指向**那条产物提交** → `bundle exec pod install`。

### 3.6 Web / 法务站点

| 本地目录 | 远程 | 说明 |
|---|---|---|
| `zests-website` | ParticleMedia/zests-website | LocalAll 官网 / 法务页（含路由总览） |
| `nomi-website` | ParticleMedia/nomi-website | Nomi 法务中心（Terms/Privacy） |

> **前端约定**：每个 App 通常配一个官网（如 LocalAll → `zests-website`、Nomi → `nomi-website`）。

### 3.7 工具链 / Skills / 配置

| 本地目录 | 远程 | 说明 |
|---|---|---|
| `particle-skills` | ParticleMedia/skills | 公司 Agent Skills 仓库（注意远程名是 `skills`，目录是 `particle-skills`） |
| `memory` | ParticleMedia/memory | 团队记忆仓库（含 CLAUDE.md） |
| `config` | **jingyang-rico**/config | 个人仓库指南 / Figma→Swift 规则等配置 |
| `app-store-connect-notifier` | **jingyang-rico**/app-store-connect-notifier（fork） | ASC 通知转发 Slack |

### 3.8 个人 / AI 项目

| 本地目录 | 远程 | 说明 |
|---|---|---|
| `openclaw` | openclaw/openclaw | 多渠道 AI Gateway / 个人 AI 助手（见 memory: openclaw-runtime-setup） |
| `claude-sub` | **jingyang-rico**/claude-sub | Claude 订阅 shim（openclaw/telegram 走订阅调 opus，见 memory: claude-sub-shim） |
| `claude-ratelimit-bar` | **yxjxx**/claude-ratelimit-bar | 在 statusline 显示 Claude Code 限额（5h 会话 + 7d 周） |

### 3.9 非 git 目录（脚本 / 草稿 / 资料，不可提交）

`Demo`（Xcode demo）、`AutoTest`（测试/截图草稿）、`maplocal`（JSON mock/fixtures）、`notes`、`pb`（protobuf：events.proto 等）、`proj-manage`（WorkspaceLauncher）、`scripts`（h2 复现脚本）、`charles_cache`（Charles 抓包缓存）、`jenkins`（空）、`面试`（招聘资料）、`community-ios-gas-map`（草稿）。

---

## 4. 本地 checkout 地图（worktree / 多克隆陷阱 ⚠️）

> ⚠️ 多个目录可能共享同一个 `.git`（git worktree）：**同一分支不能在两个 worktree 同时 checkout**；在某 worktree 改了 commit，其它 worktree 看到的是同一 git 历史。
>
> **独立克隆 ≠ worktree**：独立克隆各有自己的 `.git`，可同时 checkout 同一分支（互不影响）；worktree 则共享 `.git`。当前已无多克隆（NewsBreak 只保留 `nb-iOS` 一份），实时清单以生成文件为准。
>
> 📟 **当前的 worktree 家族 / 多克隆清单是 B 类、自动维护**——见 [`kb/repos.generated.md`](kb/repos.generated.md) 的「worktree 家族」「同一远程的多份独立克隆」两节。本节只保留上面的概念性提醒。

---

## 5. 构建 / 打包

- **Jenkins 根**：`https://ci.n.newsbreak.com/`，所有 iOS job 在 `Sandbox/` 文件夹下（如 `…/job/Sandbox/job/ios-chat-beta/`）；具体见第 2 节表格。认证用「用户名 + 个人 API Token」basic auth（旧实例 `jenkins.nb-sandbox.com` 已迁移至此，2026-06-15 核对）。
- **快捷 build-trigger skills**（Jenkins 打包，分支可选，默认取各 job 自身的 `BRANCH` 默认值——如 community 系为 `develop`、chat 为 `main`）：
  - `/ccbb` Bible Beta · `/ccbr` Bible Release
  - `/cclb` LocalAll Beta · `/cclr` LocalAll Release
  - `/ccrb` Radar Beta
  - `/ios-build-trigger`（通用：传 job 名 / URL / 别名均可，只给名字会自动走 Jenkins 搜索匹配）
- **iOS 本地构建约定**：CocoaPods 用 `bundle exec pod install`（**绝不**裸 `pod install`）；改了 CocoaPods 文件后 `bundle exec pod install` 再 Xcode 构建。
- **UI 自动化测试模拟器**：iPhone 16e，UDID `A494B81E-790F-430A-9FA2-8E4B6E91C302`（开发完不自动测，先问用户）。

---

## 6. Git 身份与约定

- **公司仓库 author**：`Jing Yang <jing.yang@newsbreak.com>`（全局默认）。
- **fork / 个人**：`jingyang-rico/*`（公司相关 fork）、`yxjxx/*`（纯个人，SSH host `github-yxjxx`）。
- **默认分支约定**：iOS 系（iOS/community-ios/ios-radar）默认 `develop`；`server`/`server-lite` 默认 `master`；`android-*`/`NBShellApp`/多数 Pod 默认 `main`。（各仓精确默认分支见 `kb/repos.generated.md`。）
- **Commit message**：祈使句（如 `Add drama carousel logging adapter`）。
- **拼写**：`NBNetwork`（不是 NBNetWork）。

---

## 7. 使用规则

1. 涉及"某 App / 某 Bundle ID / 某仓库 / 打包"时，**先查本表**，不要凭目录名猜远程或产品归属。
2. 一个仓库对应多个产品（community-ios、android-community）时，注意按 scheme/flavor 区分。
3. `本地目录` / worktree 是当前机器（`/Users/yxj/Work`）状态；换机需重新核对（跑一次 `kb-sync.sh` 即可重建 B 类）。
4. 改 NB* Pod 走独立仓库流程（见 3.2 警告），不要试图在 App 主仓提交 `Pods/`。
5. 与历史文件（apps_map.md 等）冲突时，**以本文件为准**，并更新本文件备注来源与日期。

---

## 8. 维护机制（分级维护）

按「**变化速度**」把信息分三层，各用不同维护方式——这样文档既不易旧，又不会越长越臃肿：

| 层 | 内容 | 寿命 | 维护方式 | 位置 |
|---|---|---|---|---|
| **A 稳定** | 身份、产品↔仓库↔Bundle ID↔Jenkins、分类说明、坑、约定 | 月/季 | 人工 + AI 顺手策展（见「自愈规则」） | 本文件 §1/2/3说明/5/6/7 |
| **B 半稳定（可派生）** | remote、默认分支、worktree·克隆拓扑、仓库存在性、最近提交 | 周 | **`kb-sync.sh` 自动生成，勿手改** | `kb/repos.generated.md` |
| **C 易变** | 当前分支、commit hash、开着的 PR、构建状态 | 小时/天 | **不入库**，`git` / `gh` 现查 | — |

**同步命令**：`bash ~/.claude/kb-sync.sh`
- 扫描 `/Users/yxj/Work` 所有 git 仓库，重算 B 类并写入 `kb/repos.generated.md`；
- 输出**漂移报告**（新增 / 消失的仓库、remote 变更），提示需要补/改 A 类策展的地方；
- 与触发方式解耦：可挂 **SessionStart hook（节流，距上次 >24h 才跑）/ launchd / Claude Mac scheduled task / 手动**，哪种能在本机执行就用哪种。
  > 注意：纯云端 routine（`/schedule`）读不到本地 `/Users/yxj/Work`，**不能**用于 B 类同步；它只适合做"读漂移报告 → 起草策展更新"这类 A 类辅助。

**自愈规则（活文档）**：在某仓库干活时，若发现本 KB 的 A 类事实（产品归属 / Bundle ID / 坑 / 约定）有误或缺失，**顺手改对应条目并更新顶部「最后核对」日期**，不要攒到定期大返工。

**A 类更新机制（半自动闭环）**：
- **缺口检测**：`kb-sync.sh` 每次对比 B 类快照 vs 本文件，把"有仓库但没策展说明"的缺口写到 `~/.claude/kb/_gaps.txt`（已排除 worktree）。
- **会话提示**：SessionStart hook 在有缺口或有待审建议（`kb/_proposed.md`）时，打一行 `[KB]` 提示。
- **`/kb-review` skill**：交互跑 → 读缺口/漂移 → 读新仓库 README/podspec/git log 起草说明 + 就部落知识（谱系/坑/流程）问你 → 确认后改本文件并更新「最后核对」日期。
- **每周自动起草**：launchd `com.yxj.kb-review`（周一 10:00）→ `~/.claude/kb-review-cron.sh`：刷新 B 类，**仅当有缺口**才 headless `claude -p "/kb-review --draft"` 把建议写到 `kb/_proposed.md`（不自动改本文件，等你 `/kb-review` 审核应用）；无缺口则跳过、不耗 token。

**拆分规则（wiki 分级）**：本文件保持单文件索引。当某仓库/领域的策展内容超过约 **30 行**时，spin out 成 `~/.claude/kb/<领域>.md`，在第 3 节对应处只留一行摘要 + 指针（`详见 kb/<领域>.md`）。索引（本文件）始终小而稳，详情按需读——加再多仓库，单次进上下文的量也不涨。
