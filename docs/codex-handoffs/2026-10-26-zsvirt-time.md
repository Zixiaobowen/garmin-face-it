# ZSvirt Time 表盘交接 · 2026-10-26

## repo、branch、目标

- repo：`/Users/zixiaobowen/myProjects/garmin-face-it`。
- 工作分支：`feat/zsvirt-time-watchface`，从 `main` 新建；后续用户明确要求提交并推送到GitHub `main`、发布Connect IQ。Git及商店状态见应用 `docs/release-1.0.0.md`，按实际回执更新。
- 原始目标：新增表盘，显示基本时间和 ZSvirt Logo。已实现为 Enduro 3 专属的独立 `ZSvirt Time` 工程；当前进入1.0.0发布流程。

## 已完成

`watchfaces/zsvirt-time/` 包含真实 Connect IQ 工程、独立 UUID `cb51f19636e64ae1b979bfd8bf070e31`、单目标 manifest、源码、官方 Logo 原件与生成器、构建入口、边界测试及文档。采用 SDK 9.2.0 自带 Simple Watch Face 模板结构；没有复制耐力仪表的生成器、35 设备矩阵或签名密钥。

黑底白字；上方为官方白色横版 Logo，下方为大号时分。时制跟随手表系统；12 小时制显示 AM/PM，午夜和正午均为 12 点。系统本地时间来自 `System.getClockTime()`；无秒、动画、Timer、后台服务或额外权限。字符串在时、分或时制变化时更新，每次系统 `onUpdate` 完整重绘。只有 Enduro 3 的 280×280 MIP 已适配。

Logo 从 `https://zsvirt.io/download` 链接下载，两张原件保存在 `assets/`；来源与哈希见 `assets/SOURCES.json`。生成器只裁透明边、等比缩放、合成黑底并量化到 0/85/170/255 灰阶。表盘 Logo 160×45，启动图标 40×40。

根 README 和技能路由已登记新表盘，并明确可以基于 SDK 官方模板创建工程。HTML 回执嵌入实际模拟器截图，可离线查看。

## 已调查或修改的文件

- 修改：根 `README.md`、`docs/garmin-dev-project.md`。
- 新增：`watchfaces/zsvirt-time/manifest.xml`、`monkey.jungle`。
- 新增源码：`source/ZsvirtTimeApp.mc`、`source/ZsvirtTimeView.mc`、`source/FaceTime.mc`。
- 新增资源：`assets/`、`resources/strings/strings.xml`、`resources/drawables/`。
- 新增脚本和测试：`scripts/build.py`、`scripts/generate-resources.py`、`tests/TimeTests.mc`。
- 新增文档：应用 `README.md`、`docs/garmin-dev-project.md`、`docs/delivery.html`、`docs/verification/verification.json` 和本交接。
- 参考：官方技能缓存、SDK 模板与 Toybox API、Enduro 3 官方设备包、现有表盘构建脚本、既有 SDK runner 字节码诊断。未修改旧表盘。

## 已运行命令与结果

Java 17 使用命令级 `JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home` 与对应 `PATH`；未改全局环境。使用已安装 SDK 9.2.0。

- `python3 watchfaces/zsvirt-time/scripts/generate-resources.py`：退出0，生成160×45 Logo与40×40启动图标。
- `python3 watchfaces/zsvirt-time/scripts/build.py --device enduro3`：退出0，真机 PRG 14,460字节，无编译警告。SHA-256 `7d1c52d0287d8c4d8d5943698862851de91eb92edb1f13f6ddc2a72de7305093`。
- `python3 watchfaces/zsvirt-time/scripts/build.py --device enduro3 --test --run`：测试目标编译退出0；3项测试均 PASS，`passed=3, failed=0, errors=0`；runner原始退出1，脚本保留失败状态。覆盖午夜/正午、24小时边界、下午和分钟补零。
- `python3 watchfaces/zsvirt-time/scripts/build.py --device enduro3 --run`：最终运行编译和runner均退出0。实际窗口显示13:46与完整ZSvirt Logo；截图后用 `NSRunningApplication.terminate()` 正常关闭本次独占模拟器。
- 首次模拟器运行因120秒命令截止中断；随后无截止的交互运行正常完成。不是应用崩溃，未把首次超时记为通过。
- 通过 CoreGraphics 查询命名窗口并 `screencapture -l` 截图；最终原图 `docs/verification/enduro3-window-final.png`，裁图 `enduro3-screen-final.png`。PNG按现有规则忽略；回执内嵌最终图片不依赖这些本地PNG。
- 回执3个本地链接目标均存在；Tern宽屏浅/深色无横向溢出，图片完整加载，页面错误和控制台为空。390px窄屏深色通过无窗口浏览器检查，展开控件点击成功，无溢出或页面错误；该测试页已关闭。浏览器证据见应用 `docs/verification/browser-verification.json`。最终回执绑定当前 `TERN_PANE=2237677961422`，保留右侧浏览器块 `2237677961472`，原生释放后读回 `shown=true`、`error=null`。

没有运行全仓库测试、旧表盘测试、多设备构建、商店export、真机安装、商店上传、续航测量或Git提交推送。

## 已知失败、风险与阻塞

3项时制测试已通过，但不能将整条测试命令声明为通过。SDK runner退出1的现象与仓库记录的9.2.0结果摘要正则解析问题一致；原始证据在 `bin/logs/zsvirt-time-enduro3-tests-simulator.log` 与 `bin/build-enduro3-tests.json`，既有诊断在旧表盘的 `docs/verification/sdk-9.2.0-test-runner.txt`。未修改SDK或吞掉退出码。

初次开发中修正了 `getInitialView` 返回类型必须与基类完整联合类型一致、测试必须导入 `Toybox.Lang` 的编译错误；最终相关构建均通过。

Tern已停靠的浏览器不接受viewport尺寸模拟，`tern pip`也未识别同一浏览器块，因此窄屏改用单独的无窗口浏览器页面验证；没有弹出外部浏览器。Tern中的原生点击未观察到展开，窄屏浏览器的真实点击则成功，未将Tern点击记录为通过。释放已接管的原块1469后该块消失，与工具契约不符；已用原生open/dock恢复为1472，并通过原生release释放、确认仍显示在当前会话右侧。工具限制已上报。

## 用户偏好、限制与禁改区域

中文沟通，结构服务信息。此次只需基本时间和ZSvirt Logo，不自行加健康数据、日期、设置主题或联网。用户当前仅有Enduro 3。现有旧表盘及其未提交文档、未跟踪历史证据完整保留，不全量暂存或清理。签名密钥始终在仓库外。用户后续已授权本表盘提交、推送到GitHub main及发布Connect IQ；没有授权真机安装或删除分支。

## 后续具体动作

1. 按用户对右侧截图的反馈调整Logo尺寸、间距或时间字号；渲染改变后重做Enduro 3实际模拟器验收。
2. 用户授权真机安装后，仅将 `bin/zsvirt-time-enduro3.prg` 作为独立应用侧载，写后回读核对SHA，保留现有表盘。
3. 获得真机反馈后分别记录腕上可读性、12/24小时制和休眠显示；不把模拟器截图当作续航证明。
4. 用户要求提交时，仅暂存本次新工程、根导航和交接，保留旧表盘已有未提交资料；推送和商店发布按对应授权执行。

## 恢复提示

> 继续 garmin-face-it 的 ZSvirt Time 表盘及1.0.0发布。工作分支 feat/zsvirt-time-watchface，用户已明确要求commit/push到GitHub main并发布Connect IQ。独立工程watchfaces/zsvirt-time只适配Enduro3的280×280 MIP；黑底官方白色Logo和大号时分，跟随12/24小时制。UUID cb51f19636e64ae1b979bfd8bf070e31。真机构建、模拟器和release-stripped模拟器均通过；3个时制测试PASS但SDK runner退出1。1.0.0 IQ导出和SDK验签通过，SHA fcc32c3b71745b36085a64d12e52c070aa9c2bb88ac1bb175f13631f778cee48；最新Git/商店回执看本表盘docs/release-1.0.0.md。Garmin已通过Tern登录，当前官方开发者后台可用。保留旧表盘已有改动、签名身份，不自行安装真机或删分支。
