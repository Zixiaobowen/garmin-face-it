# 多表盘工作区目录调整交接 · 2026-10-26

## repo、branch、目标

- repo：`/Users/zixiaobowen/myProjects/garmin-face-it`
- branch：`refactor/multi-watchface-layout`，由任务开始时的 `master` 切出，现已跟踪 `origin/refactor/multi-watchface-layout`。
- 目标已完成：同一仓库持续开发多个独立 Garmin 表盘。独立架构评审无阻断；实现提交 `3f68133` 已成功推送至 [GitHub分支](https://github.com/Zixiaobowen/garmin-face-it/tree/refactor/multi-watchface-layout)。用户授权包括本轮提交推送，未操作商店或真机。

## 已完成

旧根目录的 `README.md`、`manifest.xml`、`monkey.jungle`、`source/`、`resources/`、`resources-fonts/`、`profiles/`、`tests/`、`scripts/`、`docs/`、`bin/`、`artifacts/`、`.local/` 已完整移入 `watchfaces/reference-face-configurable/`。共1,467个原文件均保留；176个源码、资源、测试与脚本文件内容未改。构建脚本原本按自身位置确定应用根，所以无需包装脚本、全局应用选择配置或共享框架。

根目录新增工作区 README 与 `docs/garmin-dev-project.md` 技能路由。表盘 README 与专属约束说明应用根语境、仓库根技能位置和历史商店状态。`.gitignore` 的验证截图模式改为 `**/docs/verification/*.png` / `*.webp`，覆盖嵌套目录；原来的 `bin/`、`artifacts/`、`.local/` 规则仍覆盖所有表盘。

本机 `.agents/skills/garmin-dev/SKILL.md` 的入口已改为先读根技能路由、再选表盘。`.omp/skills/garmin-dev` 继续指向同一技能；技能安装仍被 Git 忽略，其上游通用正文未改。`.hermes/`、`skills-lock.json` 保持仓库根。

修复3份历史文档的17处可点击链接，原相对目录关系不变的链接保持原样。历史 JSON、原始日志、发布包及截图未改写；旧回执中的当时路径是历史证据，其中相对应用路径现在从表盘根解释。任务前已有修改的 `watchfaces/reference-face-configurable/docs/codex-handoffs/2026-10-22-time-clipping-1.0.1.md` 与迁移前逐字节一致。

## 已调查或修改的文件

- `README.md`、`docs/garmin-dev-project.md`、`.gitignore`。
- `watchfaces/reference-face-configurable/README.md` 与其 `docs/garmin-dev-project.md`。
- 该表盘 `docs/watchface-review-2026-10-21.html`、`docs/skills-review-2026-10-22.md`、`docs/skills-review-2026-10-22.html`。
- 已读且原样迁移：4个 `scripts/` 入口、`manifest.xml`、`monkey.jungle` 及各应用目录。
- 本机技能入口 `.agents/skills/garmin-dev/SKILL.md`。
- 新回执：`docs/multi-watchface-layout.html`、`docs/verification/multi-watchface-layout.json`、`docs/verification/multi-watchface-enduro3.png`（截图按规则忽略）。

## 实际运行与结果

使用已安装 SDK 9.2.0 与 Homebrew Java 17.0.20.1。构建命令显式设置 `JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home` 并把 Java 17 的 `bin` 放入当前命令 PATH，未修改全局配置。

- 仓库根执行 `python3 watchfaces/reference-face-configurable/scripts/configure.py`：退出0，35目标，重新生成的 manifest / jungle 与迁移前内容一致。
- 仓库根执行 `python3 watchfaces/reference-face-configurable/scripts/build.py --device enduro3`：退出0，真机 PRG。
- 表盘根执行 `python3 scripts/build.py --device fr55`：退出0，小屏真机 PRG。
- `/tmp` 下用绝对路径调用该表盘 `scripts/build.py --device fr965 --simulator`：退出0，AMOLED模拟器 PRG。
- 表盘根执行 `python3 scripts/build.py --device enduro3 --run`：编译和模拟器退出码均0。实际截图显示时间、中文农历和指标；见 `docs/verification/multi-watchface-enduro3.png`。本轮启动的模拟器在截图后停止。
- 本地路径检查：42份 Markdown/HTML、211个本地目标，全部存在（新增最终回执之前的整合检查）。
- 迁移快照：原文件缺失0；`bin/` 之外548个非文档文件哈希全相同，包括历史机器证据、图像和发布包；176个源码/资源/脚本/测试文件内容相同。
- `git check-ignore -v`：新位置的 `bin/`、`artifacts/`、`.local/` 和根/表盘验证截图均命中预期规则。
- 1.0.0原包 SHA-256：`0b3433a5e7675a3fee1646a8a98dc0a6e6762dbf0937c7f15706497cc63505c0`。
- 1.0.1原包 SHA-256：`f071eefec0b1942ab4ae7363bec91e42cd4eb409baa3357d5e188e6cb1a2e392`。
- HTML回执：已绑定当前 `TERN_PANE=2237677961422`，浏览器块为 `2237677961434`。宽屏浅色、窄屏深色和内嵌截图展开均已检查，无页面横向溢出，页面错误与控制台记录为空。最终7个本地链接目标均存在，模拟器截图内嵌为data URI，可随HTML离线查看；不依赖被忽略的原始PNG。验收后保留同一块在右侧分栏。
- 干净暂存导出：`git checkout-index --all` 仅导出198个已跟踪候选文件到新临时目录；不含 `.agents/.omp/.hermes`，从导出目录运行Enduro 3构建退出0，PRG为46,412字节；临时目录已清除。

没有运行全目标构建、Monkey C单元测试或商店export。没有新增真机安装、商店操作、指标真实性、续航或AMOLED烧屏预算验收。

## 独立架构评审

按用户要求调用实际 `reviewer` 角色作架构方向独立评审，评审包含根路由、应用边界、全部构建入口以及最终暂存候选。结论：无阻断问题，`overall_correctness=correct`。评审确认190项原样移动已完整纳入候选，未将本机技能或构建输出提交；新表盘独立UUID及生成器专属约束有明确说明。

评审提出的非阻断项已处理：补充上述干净暂存导出构建，并同步本交接中的用户授权与当前阶段。商店export仍未重跑；本次不改变打包实现或应用内容，历史发布原包保留。

## Git交付

- 实现提交：[`3f68133`](https://github.com/Zixiaobowen/garmin-face-it/commit/3f68133)，`Organize watchfaces as independent Connect IQ projects`；198项文件变更，含190项原样移动。
- `git push -u origin HEAD` 成功，远端回执为新分支 `HEAD -> refactor/multi-watchface-layout`，本地已设置同名上游。推送目标为 `https://github.com/Zixiaobowen/garmin-face-it.git`。
- 架构评审指出的交接阶段描述已更新；本轮回执状态另作文档提交同步。提交自身的SHA不循环写入本文件，以远端分支头和会话最终回执为准。
- 原有未跟踪历史材料未上传。已有time-clipping交接改动完整留在新位置工作区，目录移动提交只包含该文件原HEAD内容；没有全量暂存、重置或清理。


## 已知失败、风险与限制

SDK的 `connectiq` 启动器调用返回0后未发现模拟器进程；直接启动同一SDK的 `ConnectIQ.app/Contents/MacOS/simulator` 后成功运行。AppleScript的 System Events 查询被本机辅助访问权限拒绝；改用 CoreGraphics 查询窗口及 `screencapture -l` 取得实际画面，未改权限。此为本机验收工具限制，不是表盘代码失败。

现有编译器类型推断与弃用警告继续保留。本轮没有运行已知摘要解析异常的 SDK 测试runner，不重述历史PASS为本轮测试结果。

新增表盘必须有独立 UUID。复用现有生成器需要调整 `configure.py` 的应用身份、权限、能力矩阵和资源映射，以及 `build.py` 的产物前缀、默认目标；仅改目录或手改生成的manifest不够。尚未创建第二款表盘，因此没有宣称第二款已构建或发布。

## 用户偏好与禁改区域

默认中文；结构服务信息。用户已有未提交及未跟踪资料保留，未清理历史文件。现有应用 UUID `9d182df86c2d48938ce2c9795678f668`、产物前缀及仓库外签名密钥保持。旧应用 UUID `b9b8804748954f99be17e7c4483b4db3` 及设备数据不在本次操作范围。用户当前仅持有 Enduro 3；不把模拟器证据当作真机验收。

## 下一步

1. 继续现有表盘时，从 `watchfaces/reference-face-configurable/README.md` 与其专属开发约束进入。
2. 新增表盘时，通过官方 Monkey C: New Project 在 `watchfaces/<新目录>/` 建立工程，设置独立身份与实际设备目标。
3. 为新表盘添加自身的构建/验证说明，在根 README 与技能路由登记；只在出现真实共同需求时提取共享实现。
4. 后续提交继续按具体变更暂存，保留已有time-clipping交接改动及未跟踪历史材料；商店发布、部署和真机安装按对应新任务执行。

## 恢复提示

> garmin-face-it 已在 refactor/multi-watchface-layout 改为多表盘工作区，独立架构评审无阻断，实现提交3f68133已推送origin同名分支，本轮目标已完成。现有耐力仪表·可配完整工程在 watchfaces/reference-face-configurable/；根 README 与 docs/garmin-dev-project.md 是新入口。构建/配置/资源脚本未改，按脚本位置定位应用根；新根命令为 python3 watchfaces/reference-face-configurable/scripts/build.py --device enduro3。176个源码/资源/测试/脚本文件原样、两份发布原包哈希不变，用户旧交接改动和未跟踪资料留工作区。Enduro3、FR55、FR965代表构建与干净暂存导出构建通过，Enduro3官方模拟器实际显示、runner退出0；无全量测试/真机/发布。先读本交接与根 README；不恢复旧根兼容链接、不复制密钥、不更改UUID、不清理旧证据。新增表盘建立独立子工程，再登记根导航。
