# 首次应用基线审查与本地提交交接

2026-10-22

- Repo：`/Users/zixiaobowen/myProjects/garmin-face-it`
- Branch：`feat/readable-typography`
- 目标：审查完整未跟踪应用，保留必要修复，形成可独立构建的首次应用提交。仅授权本地 commit，不推送、发布、部署、写手表或删除本地文件。
- 当前结果：完整应用审查未确认阻止本地提交的缺陷；三处温度单位改为明确的°C。应用验证已结束，审查记录随本次提交保存。实际提交 SHA、路径清单与剩余状态见最终 Git 回读及本机 `.local/review-commit-receipt.json`，恢复时用 `git log -1` 核对。

## 已完成及涉及文件

静态审查覆盖 `source/` 的数据、农历、设置、菜单、应用和绘制，`profiles/`、`resources/`、`resources-fonts/`、`tests/`、构建／生成脚本及官方 SDK 约束。数据和 UI 分片独立只读复核，没有扩大应用改动。

本轮修改 `source/ReferenceFaceView.mc` 的主标签、短标签和体感后缀；更新 `.gitignore`、`README.md`、`docs/garmin-dev-project.md`、`docs/compatibility.md` 和公开 `fr45-device-mapping.json` 的路径说明。新增 `docs/review-commit-2026-10-22.md`、同名 HTML 及本交接。暂存检查发现 `resources-fonts/OFL.txt` 一处行尾空格，已仅移除此空格，许可证正文不变。当前初始基线还包含此前完整应用、字体改进、配置、脚本与测试。

本机技能／会话目录、锁文件、历史报告、截图、原始日志、缓存、编译产物与签名材料不纳入提交；没有删除本地材料。字体 OFL 许可证随图集纳入。

## 实际命令与验证

构建使用 Homebrew Java 17：`JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home`。

- 仓库内执行 `python3 scripts/build.py --device enduro3 --run` 与 `--device fr55 --run`，编译成功并实际观察常规／小屏°C标签；两次运行器均正常退出0。
- 185 个暂存应用及必要说明文件通过 `git checkout-index --all --prefix <新临时目录>/` 独立导出。在导出目录执行 `python3 scripts/build.py --device enduro3`，Release 编译成功；再执行 `--run` 并通过机上设置切换训练三列，实际观察温度−12、体感13°C，无标签重叠。正常结束应用后，运行器退出0。
- 独立 Release：46,588 字节；SHA-256 `73c666f7c966dedc1ec51434c30718b1329264c02332361cb7f590fa904c8ece`。目录与产物路径保存在本机回执；仓库旧 `bin/` 产物没有被用来替代该证据。
- 9 组实际 BMFont 相关字形覆盖与 `xadvance` 宽度检查通过；负体感等文本的几何检查不代表输入场景实际运行。
- 候选文件的常见私钥／token 标记扫描未命中，没有纳入符号链接或本机排除目录。审查／交接补入暂存后执行 `git diff --cached --check` 及最终范围确认，再创建本地提交；最终结果见回执。

未新增永久测试，未重跑全仓测试或全目标构建。历史 35 目标 Release、72 图集及代表设备记录仍保留本机；既有18项用例PASS但SDK runner退出1，不能改写为整条命令通过。类型推断及旧属性API警告仍存在。

## 边界、偏好与禁改区域

- 已停止模拟器 GUI、特殊天气输入和新增截图。零温、负体感、无天气数据等未实际验收；按用户收尾要求不再做 HTML 浏览器检查，只自动打开最终 HTML 回执。
- 12小时制没有AM/PM仍是已记录边界，不在本次扩展。
- 新字体／单位修订未写入手表。真机显示、真实数据、续航、手机设置和AMOLED烧屏预算没有新增验收。
- 旧“耐力仪表”UUID `b9b8804748954f99be17e7c4483b4db3` 及数据必须保留；新版UUID `9d182df86c2d48938ce2c9795678f668` 维持不变。密钥留在仓库外，`OUT.BIN` 只读。
- 中文简洁交付；结构服务信息，不再扩展审查、调试或文档装饰。没有必须阻断本地提交的已确认缺陷。

## 恢复后的具体动作

1. 阅读本交接、审查记录及 `git log -1`，核对本机回执中的实际 SHA、路径清单和未跟踪材料；不要把历史文档里的“未提交”当成当前状态。
2. 如下一任务需要新安装包，从当前提交按 README 重新构建，核对新产物；不要直接把仓库旧 `bin/` 候选当作本轮修订产物。真机写入需对应授权，并保留旧应用。
3. 后续若明确要求继续验收，再分别处理 Enduro 3 真机可读性／指标／续航与手机设置链路；特殊天气输入及 AM/PM 按新任务范围处理，不自动续跑本次验证循环。

恢复提示：

> 继续 garmin-face-it，先读 docs/codex-handoffs/2026-10-22-review-commit.md、docs/review-commit-2026-10-22.md 并核对 git log -1 与 .local/review-commit-receipt.json。首次应用基线已完成整体审查、三处°C修正、Enduro3/FR55实际显示、9组字体宽度及暂存导出Release验证。本轮已停止GUI与特殊输入调试；仅本地提交，无推送、发布或真机写入授权。保留本机未跟踪材料与旧表盘，按新的明确需求继续。
