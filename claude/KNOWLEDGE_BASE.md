# KNOWLEDGE_BASE — Jing Yang 的代码库 / 应用 / 构建 权威映射

> **用途**：这是 Jing Yang（yxj）给 Claude Code 的"自我介绍 + 团队介绍"知识库。
> **覆盖范围**：他维护的所有仓库、App、Bundle ID、打包/Jenkins、产品谱系与约定。读到时按需定位到对应小节，不要凭目录名猜归属。（"**何时**来读本文件"的触发规则在全局 `~/.claude/CLAUDE.md`「Knowledge Base」段，不在此重复。）
> **权威性**：本文件是代码库/应用映射的唯一权威来源。
> **维护方式**：分级维护，见 [§8](#8-维护机制分级维护)。简言之——产品/分类/坑等"策展知识"手动 + AI 顺手更新；git 事实（remote/分支/worktree）由 `kb-sync.sh` 自动生成到 `kb/repos.generated.md`，勿手改；当前分支等易变信息不入库、用时现查。
> **最后核对（策展层）**：2026-06-24。

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
| `claude-sub` | **jingyang-rico**/claude-sub | Claude 订阅 shim（openclaw/telegram 走订阅调 opus，见 memory: claude-sub-shim / openclaw-runtime-setup；openclaw 服务跑在 Homebrew 全局，~/Work 不再保留其克隆） |
| `claude-ratelimit-bar` | **yxjxx**/claude-ratelimit-bar | 在 statusline 显示 Claude Code 限额（5h 会话 + 7d 周） |

### 3.9 非 git 目录（脚本 / 草稿 / 资料，不可提交）

`AutoTest`（自动化测试用：每个 App 的测试知识库，持续完善中）、`maplocal`（常见接口的 Charles map local JSON）、`notes`、`pb`（protobuf：events.proto 等）、`proj-manage`（WorkspaceLauncher）、`charles_cache`（Charles 抓包缓存）、`jenkins`（空）。

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
- **`/kb-review` skill**：交互跑 → 读缺口/漂移 → 读新仓库 README/podspec/git log 起草说明 → **扫 auto-memory + 本周 git 改动，把涉仓库/产品/流程但 KB 未体现的耐久知识提升进来** → 就部落知识（谱系/坑/流程）问你 → 确认后改本文件并更新「最后核对」日期。
- **每周自动起草**：launchd `com.yxj.kb-review`（周一 10:00）→ `~/.claude/kb-review-cron.sh`：刷新 B 类，**仅当有缺口**才 headless `claude -p "/kb-review --draft"` 把建议写到 `kb/_proposed.md`（不自动改本文件，等你 `/kb-review` 审核应用）；无缺口则跳过、不耗 token。

**知识回写（任务后不靠自觉）**：原始知识由 **auto-memory** 在每个会话自动抽进 `~/.claude/projects/-Users-yxj-Work/memory/`（harness 驱动，防丢已固定）；其中涉及代码库地图的事实，由上面 `/kb-review` 的 memory 提升步**固定地**搬进本 KB 的结构化分节。memory 与 KB 共存：memory 是原始流水账，KB 是策展视图，只提升、不删 memory。

**拆分规则（wiki 分级）**：本文件保持单文件索引。当某仓库/领域的策展内容超过约 **30 行**时，spin out 成 `~/.claude/kb/<领域>.md`，在第 3 节对应处只留一行摘要 + 指针（`详见 kb/<领域>.md`）。索引（本文件）始终小而稳，详情按需读——加再多仓库，单次进上下文的量也不涨。

---

## 9. 密钥目录（仅地图，值不在此）

> 🔑 **密钥值全部在 `~/.config/secrets.env`**（chmod 600、不进 git、由 `~/.zshrc` 与 wrapper 脚本 `source`）。本节只记**变量名 / 用途 / 谁用**，**绝不记值**。
> **取用规则**：脚本内部 `source ~/.config/secrets.env` 后直接用 `$VAR`，**绝不 `echo`/打印**（否则泄漏进对话/transcript，等同写进库）。launchd / 非交互进程**读不到 `.zshrc`**，要在脚本里**显式 `source` secrets.env**。
> **新增密钥**：值用 `read -rs` 写进 secrets.env（别贴进对话），再在此表登记变量名。

| env 变量 | 用途 | 账号 / scope | 谁用 |
|---|---|---|---|
| `JENKINS_USER` + `JENKINS_TOKEN` | ci.n.newsbreak.com basic auth（触发打包 / 查 job） | NewsBreak Jenkins | `/ios-build-trigger`、`/cc**` 打包 skill |
| `ATLASSIAN_EMAIL` + `ATLASSIAN_API_TOKEN` | particlemedia.atlassian.net REST（Confluence 传附件等 MCP 不支持的操作） | 工作账号 | CLAUDE.md「Confluence 上传截图」curl |
| `FIREBASE_TOKEN` | ⏸️ 暂注释停用（用途待确认） | — | — |
| `OPENAI_API_KEY` | ⏸️ 暂注释停用（用途待确认） | — | — |
| `GOOGLE_APPLICATION_CREDENTIALS` | ⏸️ 暂注释停用（值是 GCP service account JSON 的路径，非密钥本身） | — | — |

> ⏸️ 上面 3 个**已在 `secrets.env` 注释停用**（保留行、不导出）。需要时去掉行首 `# ` 即恢复，并补全用途/使用方（可下次 `/kb-review` 处理）。

---

## 10. 开发流程 & 数据/质量工具链

> 本节已与 Jing **逐条确认**（2026-06-24）。

### 10.1 日常开发流程

1. **建单**：Jira（当前 sprint，自动带版本号）→ `/ios-jira-task`。Jira / Confluence 统一走 `plugin:atlassian` MCP（Wiki 子页建在 **iOS Portal** 下）。
2. **拉分支**：命名 `feature/xxx` 或 `fix/xxx`（从默认分支拉，iOS 系多为 `develop`）。
3. **开发**：遵全局 + 仓库级 CLAUDE.md 规约（MVVM + Combine + SnapKit、命名、UIKit 注意点等）。改 **schema/埋点**走 §3.5、改 **NB\* 远程 pod** 走 §3.2 的固定流程。
4. **自查**：改完用 `code-reviewer` agent 审本次会话改动；`/code-review --fix` 可作质量门禁。
5. **提交 / PR**：commit 用祈使句；`/commit-push`、`/pr` 自动化分支/提交/PR。
6. **Review & 合并**：**Codex 自动 review 所有 PR**（CI 里）+ **自己在 Slack 找人 review**；通过后 merge。（早期项目如 `ios-chat` 允许自己 merge 自己的 PR。）
7. **打包**：merge 后可自动触发；手动用 `/cc**` / `/ios-build-trigger`（Jenkins 细节见 §5）。
8. **提审上架**：目前**手动**传 TestFlight / 提审；计划用 **App Store Connect CLI 工具自动化**（参考 `app-store-connect-notifier`）。

**版本号规则**：`YY.WW.B` —— 年份缩写 . 当年第几周(ISO week) . 当周第几版(从 0 起)。例：`26.25.0` = 2026 年第 25 周第一版，`26.25.1` = 同周第二版。**发版节奏不固定（按需）**。

### 10.2 埋点 & 数据（Amplitude）

- **org**：Particle Media（url `particlemedia`，id `7419`，enterprise）。
- **埋点定义**在 `client-log-schema`（proto，**事件命名/口径的真源**），改动走 §3.5 / CLAUDE.md「Schema 仓库改动顺序」：**先查复用**（如 `open app` 通用事件）→ 改 proto → PR（只含 proto）→ Action 生成 → 更新工程 `Podfile` commit id 接入。
- **查数/建图**：`plugin:amplitude` MCP（`get_events` 查事件名、`query_chart` 看图、dashboard）；配套 `analytics-instrumentation` 系列 skill（从代码 diff 推断该埋的事件 → 生成埋点计划）。

**App → Amplitude 项目(appId)**（按 bundle id / 命名匹配，2026-06-23 经 `get_context` 拉取；待校）：

| App | iOS 项目(appId) | Android 项目(appId) | 网站 |
|---|---|---|---|
| NewsBreak | NewsBreak iOS (Beta) `307242` | NewsBreak Android (Beta) `402580` | — |
| CrimeRadar | Crime Radar IOS `699313` / Beta `699314` | Crime Radar Android `699311` / Beta `699312` | — |
| OurBlock(LifeInfo) | LifeInfo iOS `748041` | — | — |
| LocalAll | Local-all-iOS `667040` / Community-iOS-Beta `667042` | Local-all-Android `666550` / Community-Android-Beta `666551` | Zests Website `710972` |
| Bible Vod | bible_ios `758066`（release+beta 同项目） | bible_android `750547` | biblevod-website `755422` |
| Pills Minder | health_iOS `763653`（无 beta） | health_android `816665` | — |
| Scoopz | Bloom (Beta) `463373` | — | — |
| NomiChat | chat_ios `816063` | — | — |

- 备注：**NewsBreak 正式版**项目本人无权限（仅列 Beta）；**`nomi-website` 无需埋点**；**SayFlow** / `InNow iOS Beta`(`666950`) 暂不细究。
- **常看的核心看板**：
  - [ios-nomichat Core Metrics](https://app.amplitude.com/analytics/particlemedia/dashboard/l3uya985)（`l3uya985`）— NomiChat 新用户旅程 / 对话互动 / Push 授权与点击；口径对齐《AI 陪伴埋点文档》。
  - [Crime Radar Core Metrics](https://app.amplitude.com/analytics/particlemedia/dashboard/v5t4ou3y)（`v5t4ou3y`）— CrimeRadar 核心指标（data 团队官方看板）。

### 10.3 归因 / 导流（Adjust）

- **接入范围**：所有 App（NBShellApp 的"归因 attribution"模块即对接此类）。
- **用途**：安装归因 + 渠道投放（买量）效果追踪。
- **核心指标**：安装数。
- **看数**：数据**回传到 Amplitude 看**（不单独盯 Adjust dashboard）；按需用 `mcp__adjust__reporting_tool` 拉报表。
- 凭证（Adjust app token / API token）属密钥，走 `secrets.env`（§9），不入本表。

### 10.4 崩溃监控（Firebase Crashlytics）

- **项目结构**：**每个产品独立 Firebase 项目**；项目内按 **Bundle ID** 对应各 App。
- **看 crash**：Crashlytics 看板 + **人工 oncall**，叠加 **OpenClaw 崩溃报警 / 自动分析**（目标：oncall 只看 AI 报告）。
- `FIREBASE_TOKEN`（§9，现注释停用）用于 Firebase CLI。
- dSYM 上传由其他流程保证（暂不细究）。
