# fēnix 6 适配提交与 1.1.0 商店上传交接

## repo、branch、目标

- repo：`/Users/zixiaobowen/myProjects/garmin-face-it`；当前工作分支 `feat/multifunction-fenix6`，发布目标为 `origin/main`。
- 用户要求另一款多功能表盘支持 fēnix 6 系列，随后明确授权“提交推送到github 并上传商店”。本次更新“耐力仪表·可配”，不是独立仓库中的 ZSvirt Time。
- 应用 UUID：`9d182df86c2d48938ce2c9795678f668`；商店 app ID：`aa58871d-46ed-49f2-9c18-72efdaa7eb50`。沿用原签名，密钥保持在仓库外。

## 已完成

- 适配提交 `c89fd97`；与远端 ZSvirt Time 拆分提交 `6825268` 合并，冲突仅为根README的目标数描述，合并提交 `3b1767f` 已成功推送 `origin/main`。保留拆分结果，未强推。
- 新增五个 fēnix 6 官方目标，manifest 共40目标；沿用现有源码、字体、布局和能力检测。前一阶段的构建、运行和截图见 `docs/verification/fenix6-support.json`。
- 1.1.0官方商店包导出及SDK验签通过。现有 `scripts/build.py` 增加 `--release`，用于去除调试信息的模拟器验收；真机与商店导出逻辑保持原有行为。
- 原商店应用成功接收1.1.0（内部3），文件验证200、版本POST 204、资料PUT 204。中英文说明与新功能回读一致；隐私URL修正为 `watchfaces/reference-face-configurable/docs/privacy.md`。
- 开发者兼容清单包含所有新增20个硬件编号；后台总76个。公开端仍为1.0.1（内部2）、56个编号，新增20个均未出现。两个位置的差异已保留，不能说新版本公开可安装。
- 发布记录、JSON和HTML回执：应用目录 `docs/release-1.1.0.md`、`docs/verification/release-1.1.0.json`、`docs/release-1.1.0.html`。发布包、后台/公开截图及SDK验签回执在本机 `artifacts/release-1.1.0/`，不随Git提交。

## 已调查或修改的文件

- 原适配：`docs/compatibility.json`、`docs/compatibility.md`、`manifest.xml`、`monkey.jungle`、根与应用README/开发说明、`docs/fenix6-support.html`、原始验证JSON及适配handoff。
- 发布：`scripts/build.py`、根 `README.md`、应用 `README.md`、`docs/garmin-dev-project.md`、`docs/privacy.md`、`docs/release-1.1.0.*`、`docs/verification/release-1.1.0.json`、本交接及适配交接中的最新状态入口。
- 浏览器读取现有官方上传表单、开发者metadata、开发者应用清单、公开应用清单及仪表板；未读取或保存认证凭据。

## 实际运行命令与结果

构建命令从仓库根使用 `python3 watchfaces/reference-face-configurable/scripts/build.py ...`，显式设置已安装Java17的 `JAVA_HOME` 与 `PATH`。

- `--package 1.1.0`：退出0，40目标；IQ为2,776,681字节，SHA-256 `e93c22b1f15830af45c7d7368aeba8717d16060d45334869d4d6f3a0a9f1317e`。
- SDK `VerifyingUtils.verifyIqFile`：输出`SDK_IQ_SIGNATURE_VALID=true`，退出0。商店metadata亦回读验签true及正确manifestAppId。
- `--device fenix6spro --release --run`：编译0、模拟器0，PRG 54,124字节；实际画面核对成功，通过File → Kill App正常退出。本次独占模拟器PID18099已停止。
- `--release --test`：预期拒绝冲突参数，退出2，未触发编译。
- 没有跑全仓库/Monkey C单元测试，也没有真机安装、手机商店下发、真实数据或续航验收。
- 上传操作及后续版本、双语资料、全部新增硬件编号逐项回读成功；公开侧`cache: no-store`仍读到旧版，响应本身为`no-cache, no-store, max-age=0, must-revalidate`。
- HTML原生浏览器验收：1512px浅色与460px深色实际截图均已查看，无横向溢出，图片加载、5个本地链接及证据展开/收起通过，控制台/页面错误为空。实际窄屏宽度为460，不将请求的390当作已实现宽度。证据见 `docs/verification/release-1.1.0-browser.json`。
- 最终HTML位于当前owner `2237677961599`的右侧块`2237677961623`，接管已释放，分栏保留；本轮商店浏览器页已关闭。Tern隐藏页面的可信点击未触发展开，改用原生HTML summary的DOM click验证；停靠页不能强制viewport，窄屏验收临时浮回当前owner，结束后重新停靠。

## 已知差异、工具问题与边界

- 后台仪表板“已批准”和接口`APPROVED`是应用状态，`hasVersionPendingScan`为false；公开页面/接口仍是旧版。未发现额外发布操作，公开端更新原因与时间未确认；不擅自重传相同版本或再次提交。
- Tern原生`uploadFile`不能操作隐藏的input；第一次选按钮未选入文件。临时显示真实file input后上传成功，核对文件名及2,776,681字节后恢复样式。
- 模拟器设备窗口恢复自Window菜单后可见，矩形截图成功。IQ不是ZIP格式，曾用zipfile检查而得到BadZipFile；没有改动原包，验签以SDK和商店结果为准。
- 旧发布目录原包、用户历史未跟踪记录以及 `2026-10-22-time-clipping-1.0.1.md` 的既有修改保留；不做全量暂存、清理、reset或删除。

## 用户偏好与禁改区域

中文沟通，事实与推断分开。不得把开发者预览当公开可下载，不把模拟器结果当真机续航。不要改签名、旧表盘数据或ZSvirt独立仓库。HTML采用effective-html文档形式，最终回执绑定当前Tern会话右侧展示；不打开外部Chrome。浏览器验收结束释放接管、保留回执分栏；只关闭本轮自己开的商店页。

## 后续动作

1. 仅在Garmin状态发生变化或用户需要时，回读公开商店版本与20个fēnix 6硬件编号；当前上传已被接受，不重复上传。
2. 公开端出现1.1.0后，更新发布回执的公开状态及观察时间，保留此前后台/公开不同步的原始证据。
3. 获得实际fēnix 6设备和独立安装授权后，再验收商店下发、设置、真实指标及续航；用户目前没有fēnix 6 Pro，不将其当作现有测试设备。

## 恢复提示

> 继续 `/Users/zixiaobowen/myProjects/garmin-face-it` 的 `feat/multifunction-fenix6`。用户已授权适配另一款多功能表盘并提交推送、上传商店。适配c89fd97，合并远端ZSvirt拆分的3b1767f已推送main。耐力仪表·可配的1.1.0（内部3）上传与双语资料保存均成功，SDK及商店验签通过，40目标包与6S Pro stripped模拟器编译/运行均通过。开发者后台有新增20个fēnix硬件编号；公开商店仍为1.0.1、缺少这20个编号，不能说已公开可安装，不能无依据重传。详见应用docs/release-1.1.0.md、verification/release-1.1.0.json和本handoff。保留原签名、旧发布包、历史未提交记录；没有真机安装或部署授权。发布记录及release入口的提交见Git历史。
