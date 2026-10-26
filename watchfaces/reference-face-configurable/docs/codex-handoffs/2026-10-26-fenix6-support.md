# 耐力仪表·可配 fēnix 6 系列支持 · 2026-10-26

## repo、branch、目标

- repo：`/Users/zixiaobowen/myProjects/garmin-face-it`。
- branch：`feat/multifunction-fenix6`，由本轮从 `main` 创建。
- 用户目标：让另一款多功能表盘“耐力仪表·可配”支持 fēnix 6 系列。适配完成后，用户追加授权提交推送GitHub并上传商店，后续实际结果见 [1.1.0发布交接](2026-10-26-fenix6-release.md)。没有真机安装授权。
- UUID 保持 `9d182df86c2d48938ce2c9795678f668`；ZSvirt Time 和旧“耐力仪表”身份均未改动。

## 已完成与修改

`docs/compatibility.json` 新增 `fenix6`、`fenix6pro`、`fenix6s`、`fenix6spro`、`fenix6xpro`，覆盖官方对应的 17 个 fēnix 6 系列型号名称及 20 个地区硬件编号。总矩阵 40 targets、55 个命名型号行、85 个硬件编号；旧 35 个目标对象和原有型号行与修改前内存快照逐项比较，保持不变。

通过现有 `scripts/configure.py` 重新生成 `manifest.xml`、`monkey.jungle`。240/260/280px、MIP、机上设置和 API 成员检测均已有实现，适配阶段没有修改 Monkey C 源码、字体、资源、构建脚本或测试。后续发布阶段为构建入口增加 `--release`，详见发布交接。

同步更新应用 `README.md`、`docs/compatibility.md`、`docs/garmin-dev-project.md`，以及仓库根 `README.md`、`docs/garmin-dev-project.md` 的当前范围。历史发布记录和历史 35-target 验收数字保持原义。

新增回执 `docs/fenix6-support.html`，采用 effective-html（`skill://html`）文档形式，内嵌三张实际模拟器截图。完整结果 `docs/verification/fenix6-support.json`；首次失败单独保存为 `docs/verification/fenix6-initial-build-failures.json`。

## 依据与已调查文件

- 官方兼容目录：<https://developer.garmin.com/connect-iq/compatible-devices/>。
- 技能缓存 `references/connect-iq-docs/portal/device-reference/fenix6*.md`。
- 官方本机设备包 `~/Library/Application Support/Garmin/ConnectIQ/Devices/fenix6*/compiler.json` 与 `simulator.json`：屏幕、颜色、Watch Face 内存、地区 API、别名、按键与位置。
- `source/FaceData.mc`：运行时能力检测，API 3.4 无系统周跑量和日出 Complications；自动信息位跳过，显式选择显示“不支持”。
- `source/ReferenceFaceView.mc`：240px 紧凑布局、260/280px 大屏布局、三种布局与 MIP 休眠路径。
- `source/ReferenceFaceApp.mc`、`source/FaceSettings.mc`、`source/FaceSettingsMenu.mc`：API 3.2+ 机上设置、持久化、布局切换。
- `scripts/configure.py`、`scripts/build.py`：沿用矩阵生成与官方编译/运行入口。

## 实际运行的检查

环境：SDK 9.2.0、Java 17。监督进程需显式指定：

```sh
env JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home PATH=/opt/homebrew/opt/openjdk@17/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin python3 watchfaces/reference-face-configurable/scripts/build.py --device fenix6spro --run
```

- `python3 watchfaces/reference-face-configurable/scripts/configure.py`：退出 0，生成 40 个官方目标。
- 对五个新增目标分别运行 `scripts/build.py --device <id>` 与 `--simulator`：最终均编译退出 0；真机包分别为 55,196 / 55,196 / 54,124 / 54,124 / 56,732 字节（顺序与上方目标列表一致）。SHA-256 见 JSON。
- 对五个目标分别运行 `--run`：最终编译退出 0、模拟器退出 0；通过 File → Kill App 正常结束实际运行。
- 6S Pro、6 Pro、6X Pro：分别实际切换日常、训练、极简，核对屏幕未见裁切或重叠；截图为 `docs/verification/<id>-<daily|training|minimal>-window.png`。
- 6S Pro：机上设置菜单与布局选择可用；Settings → Display Mode → Always-Active 后等待下一分钟，确认秒被隐藏，随后恢复 High Power。证据 `fenix6spro-sleep-window.png`。
- 矩阵 smoke：40 个目标唯一、manifest 顺序等于矩阵、UUID 保持、分辨率及内存汇总一致。
- 没有运行全仓库测试或 Monkey C 单元测试 runner；没有改变可执行源码和资源。
- HTML在当前Tern owner `2237677961599`右侧块`2237677961615`展示。390px深色页面已实际截图核对，图片加载、无横向溢出、证据展开/收起通过；1080px浅色无窗口浏览器的几何、图片、控制台检查通过，但截图两次超时，未声称完成宽屏视觉截图验收。两页均无控制台/页面错误，8个本地链接均存在。详见 `docs/verification/fenix6-browser.json`；已释放原生接管、保留分栏并关闭本次无窗口验收页。

## 工具异常、风险和验收边界

1. 首次并发构建的 6S Pro 模拟器目标报 SDK critical error；同源码单独构建成功。没有修改应用来绕过异常，根因未确定，不能宣称已修复 SDK。
2. 首次监督运行缺少 Java 环境，失败发生在应用运行之前。后续进程显式使用已安装的 Java 17。
3. 模拟器切换时旧机型窗口曾短暂保留；早期误标为 6X 的过渡截图已弃用并覆盖为正确机型画面。一个 6X 启动进程在检查隐藏窗口时被停止（143）；重启后最终运行退出 0。恢复 Window 菜单中的设备窗口可继续操作；没有证据表明这是表盘崩溃。
4. 后段 macOS `screencapture` 对窗口与矩形返回 `could not create image`。6、6S 已加载正确机型且最终运行退出 0，但没有完成这两款非 Pro 的截图验收；视觉结论仅覆盖三款 Pro 代表机型。
5. Python Eval 超时后临时状态丢失，已从构建入口保存的报告重新整理结果，没有用失效内存猜测运行结果。
6. 地区设备包包含 API 3.4.1–3.4.5，运行验证使用 SDK 3.4.5 模拟器；没有各地区固件、真实 fēnix 6、手机设置传输、腕上可读性或续航验收。
7. 本次独占启动的模拟器 PID 55789 已在中途恢复时停止，最终 PID 61918 也已停止；没有停止其它会话的浏览器或服务。

## 用户偏好与禁改区域

中文沟通，证据范围不得超过实际验证。不扩展成表盘重构或重新设计，不增加旧接口兼容层。保留现有签名，密钥始终在仓库外。用户已有大量未跟踪历史记录及一处历史 handoff 修改，均保留；不全量暂存、清理或重置。HTML 按本次阅读目的选用 effective-html，优先在当前 Tern 会话右侧展示，禁止改开外部浏览器。

## 后续动作

本轮适配完成，后续发布操作已获授权并执行；当前状态以 [1.1.0发布交接](2026-10-26-fenix6-release.md) 为准：

1. 适配及远端ZSvirt拆分整合已推送 `origin/main`，保留用户无关未提交记录。
2. 1.1.0官方包导出、验签、发布模拟器运行及商店上传均完成；开发者后台为1.1.0，公开侧仍为1.0.1，不将后台预览当公开可安装。
3. 如获得实际fēnix 6设备及安装授权，再做侧载回读、真实数据、机上设置和续航验收；用户已不持有Fenix 6 Pro。

## 恢复提示

> 继续 garmin-face-it 的 feat/multifunction-fenix6。用户已要求另一款多功能表盘支持fēnix 6系列，并追加授权提交推送与商店上传。适配阶段新增五个官方目标，矩阵35→40，经原configure.py生成manifest/jungle，无Monkey C或资源修改；五款构建和运行最终通过，三款Pro代表机型的三种布局、机上切换及6S Pro休眠有截图。后续发布已完成1.1.0导出、验签、stripped模拟器运行及上传，源码已推送main；公开商店仍为1.0.1。恢复前先读同目录2026-10-26-fenix6-release.md及docs/release-1.1.0.md，不再使用本阶段原来的“未提交、未授权上传”状态。保留用户历史未提交内容与原签名；没有真机安装授权。
