# ZSvirt Time 表盘交接 · 2026-10-26

## repo、branch、目标

- repo：`/Users/zixiaobowen/myProjects/garmin-face-it`。
- 当前分支：`main`。功能分支 `feat/zsvirt-time-watchface` 已快进合入main并保留；功能提交 `64ee8da` 已推送GitHub。用户明确授权commit/push到main及发布Connect IQ；实际回执见应用 `docs/release-1.0.0.md`。
- 原始目标：新增表盘，显示基本时间和 ZSvirt Logo。已实现为Enduro 3专属的独立ZSvirt Time工程；1.0.0已提交Garmin审核，状态PENDING，尚未公开上架。

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
- 新增文档：应用 `README.md`、`docs/garmin-dev-project.md`、`docs/privacy.md`、`docs/release-1.0.0.md`、`docs/delivery.html`、`docs/verification/verification.json`、`docs/verification/store-submission-1.0.0.json` 和本交接。
- 参考：官方技能缓存、SDK 模板与 Toybox API、Enduro 3 官方设备包、现有表盘构建脚本、既有 SDK runner 字节码诊断。未修改旧表盘。

## 已运行命令与结果

Java 17 使用命令级 `JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home` 与对应 `PATH`；未改全局环境。使用已安装 SDK 9.2.0。

- `python3 watchfaces/zsvirt-time/scripts/generate-resources.py`：退出0，生成160×45 Logo与40×40启动图标。
- `python3 watchfaces/zsvirt-time/scripts/build.py --device enduro3`：退出0，真机 PRG 14,460字节，无编译警告。SHA-256 `7d1c52d0287d8c4d8d5943698862851de91eb92edb1f13f6ddc2a72de7305093`。
- `python3 watchfaces/zsvirt-time/scripts/build.py --device enduro3 --test --run`：测试目标编译退出0；3项测试均 PASS，`passed=3, failed=0, errors=0`；runner原始退出1，脚本保留失败状态。覆盖午夜/正午、24小时边界、下午和分钟补零。
- `python3 watchfaces/zsvirt-time/scripts/build.py --device enduro3 --run`：最终运行编译和runner均退出0。实际窗口显示13:46与完整ZSvirt Logo；截图后用 `NSRunningApplication.terminate()` 正常关闭本次独占模拟器。
- 首次模拟器运行因120秒命令截止中断；随后无截止的交互运行正常完成。不是应用崩溃，未把首次超时记为通过。
- 通过 CoreGraphics 查询命名窗口并 `screencapture -l` 截图；最终原图 `docs/verification/enduro3-window-final.png`，裁图 `enduro3-screen-final.png`。PNG按现有规则忽略；回执内嵌最终图片不依赖这些本地PNG。
- 开发阶段回执曾完成Tern宽屏浅/深色及390px无窗口窄屏检查，图片与展开控件正常，无横向溢出或页面错误；证据见应用 `docs/verification/browser-verification.json`。该记录中的旧浏览器块ID只代表当时验收，发布回执按最终原生分栏回读记录。
- `python3 watchfaces/zsvirt-time/scripts/build.py --package 1.0.0`：退出0，1/1目标构建；官方SDK `VerifyingUtils.verifyIqFile(File, null)` 实际返回true。IQ 8,498字节，SHA-256 `fcc32c3b71745b36085a64d12e52c070aa9c2bb88ac1bb175f13631f778cee48`。
- `python3 watchfaces/zsvirt-time/scripts/build.py --device enduro3 --release --run`：编译和runner均退出0，官方模拟器实际显示完整Logo和13:59。5组无效打包参数均退出2。
- 功能提交64ee8da已推送main，并通过GitHub分支API回读确认；旧表盘未提交文档和未跟踪证据保持原样。
- Connect IQ创建接口HTTP 200；商店ID `2702e86b-ba01-44ed-9d5a-9b29777945f4`，1.0.0 / 内部1，状态PENDING。官方保存元数据HTTP 200，签名检查true，仅Enduro 3、禁止自动迁移、免费非Beta、无额外权限；中英文文案精确匹配，图片保存成功，实际中英文预览已检查。
- 发布回执HTML已在Tern 1386px浅色与无窗口390px深色验证：无横向溢出，嵌入截图完整，展开控件真实点击通过，3个本地链接存在，控制台和页面错误均为0。最终通过原生open/dock绑定当前会话owner `2237677961422`，右侧块 `2237677961528`；原生release后state回读 `shown=true`、`error=null`。窄屏页和商店操作页已关闭。

没有运行全仓库测试、旧表盘测试或多设备构建；没有真机安装或续航测量。已提交审核，但尚无Garmin批准或公开上架证据。

## 已知失败、风险与阻塞

3项时制测试已通过，但不能将整条测试命令声明为通过。SDK runner退出1的现象与仓库记录的9.2.0结果摘要正则解析问题一致；原始证据在 `bin/logs/zsvirt-time-enduro3-tests-simulator.log` 与 `bin/build-enduro3-tests.json`，既有诊断在旧表盘的 `docs/verification/sdk-9.2.0-test-runner.txt`。未修改SDK或吞掉退出码。

初次开发中修正了 `getInitialView` 返回类型必须与基类完整联合类型一致、测试必须导入 `Toybox.Lang` 的编译错误；最终相关构建均通过。

Tern已停靠的浏览器不接受viewport尺寸模拟，`tern pip`也未识别同一浏览器块，因此窄屏改用单独的无窗口浏览器页面验证；没有弹出外部浏览器。Tern中的原生点击未观察到展开，窄屏浏览器的真实点击则成功，未将Tern点击记录为通过。释放已接管的原块1469后该块消失，与工具契约不符；已用原生open/dock恢复为1472，并通过原生release释放、确认仍显示在当前会话右侧。工具限制已上报。

商店上传预校验的签名标记曾为false，与本地SDK验签true不一致；正常提交后，保存元数据的 `appIqFileInfoResult.signatureCheckSuccessFul` 为true。未改包、未改校验结果。初始差异原因未确认；当前无需重复上传。

## 用户偏好、限制与禁改区域

中文沟通，结构服务信息。此次只需基本时间和ZSvirt Logo，不自行加健康数据、日期、设置主题或联网。用户当前仅有Enduro 3。现有旧表盘及其未提交文档、未跟踪历史证据完整保留，不全量暂存或清理。签名密钥始终在仓库外。用户后续已授权本表盘提交、推送到GitHub main及发布Connect IQ；没有授权真机安装或删除分支。

## 后续具体动作

1. 下次查看商店ID `2702e86b-ba01-44ed-9d5a-9b29777945f4` 的审核状态；只有实际批准且公开可见后才记录为上架。
2. 若Garmin要求补充资料，先读取反馈与现有提交回执，再修改相应内容；不要重复创建应用或变更UUID、签名身份。
3. 用户授权真机安装后，仅侧载本表盘PRG，写后回读核对SHA，保留现有表盘；另行验证腕上可读性、时制、休眠与续航。
4. 后续若调整Logo、间距或字号，重做Enduro 3实际模拟器验收；未改渲染时不重复已通过用例。

## 恢复提示

> 继续garmin-face-it的ZSvirt Time。当前main；功能提交64ee8da已推送GitHub，发布回执亦随文档提交同步。独立工程watchfaces/zsvirt-time只适配Enduro3的280×280 MIP；黑底官方白色Logo和大号时分，跟随12/24小时制。UUID cb51f19636e64ae1b979bfd8bf070e31。真机目标、普通及release-stripped模拟器均通过；3个时制用例PASS但SDK runner退出1。1.0.0 IQ导出和SDK验签通过，SHA fcc32c3b71745b36085a64d12e52c070aa9c2bb88ac1bb175f13631f778cee48。Garmin已接受唯一一次创建提交；商店ID 2702e86b-ba01-44ed-9d5a-9b29777945f4，1.0.0 / 内部1，PENDING，仅本人可预览，尚未公开上架。保存元数据签名检查true，中英文资料和图片已回读；细节看本表盘docs/release-1.0.0.md及docs/verification/store-submission-1.0.0.json。没有安装真机。保留旧表盘已有改动、签名身份和功能分支；不自行删分支或重复创建商店应用。
