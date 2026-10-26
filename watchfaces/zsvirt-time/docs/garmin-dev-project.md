# ZSvirt Time 开发约束

本说明仅约束 `watchfaces/zsvirt-time/`。主视觉为本地时间和 ZSvirt 官方 Logo，辅以电量、今日步数；用户持有 Enduro 3。设备集合覆盖Enduro、Forerunner与本机官方设备包中的35个fēnix目标，明确包含fēnix6/6S/6X标准版、Pro、Sapphire与Solar变体。本应用的矩阵、资源、UUID、配置、构建和发布证据完全独立。

## 身份与配置

- UUID `cb51f19636e64ae1b979bfd8bf070e31`，入口 `ZsvirtTimeApp`，名称 `ZSvirt Time`；更新继续沿用原签名，不复制密钥进仓库。
- `docs/compatibility.json` 是本应用69个目标的配置源，含12种分辨率、圆形/半圆/矩形、MIP/AMOLED、设备内存和区域API。最低API1.4.0不覆盖仍标为1.3.1的区域固件；fēnix3等旧机的地区版本需按商店列表核对。
- `scripts/configure.py` 生成 manifest/jungle；构建脚本生成根配置及目标快照，不手改生成文件，不依赖其它表盘。
- `profiles/mip` 与 `profiles/amoled` 提供编译期 `DeviceProfile.AMOLED`。无额外权限。

## 行为与资源

- `FaceTime` 处理12/24小时制及AM/PM，直接使用设备时钟，不转换时区。时间字符串只在时、分或时制变化时生成。
- `onLayout` 加载位图、读取实际字体尺寸并排布内容；字体常量的像素高度因设备和语言而异，不以固定坐标推广其它机型。Logo按12种屏宽生成，Launcher按官方定义的6种尺寸生成。
- 位图使用 `WatchUi.loadResource` 返回值，不把API4.0后的具体位图类型用于API1.x目标。
- 唤醒与MIP休眠读取 `System.getSystemStats().battery` 和 `ActivityMonitor.getInfo().steps`；数值变化时生成字符串。0步显示0，null显示`--`，不沿用旧值。完整重绘避免重新显示时残影。
- AMOLED睡眠仅画灰色时间及AM/PM；根据分钟奇偶在上下不相交区域切换，唤醒恢复完整画面。按官方10%亮像素限制验证实际画面；该设计的跨区域切换是实现选择，官方也建议轻微移动静态元素。模拟器检查不证明真机功耗、烧屏寿命或续航。
- 不显示秒，不引入Timer、动画、联网、后台服务或直接传感器采样。
- 正式Logo源图与来源见 `assets/SOURCES.json`。生成器只裁透明边、等比缩放并转换为设备可用调色板；8色MIP使用纯黑白，不重画品牌图形。

## 调度与验证

从仓库根使用 `python3 watchfaces/zsvirt-time/scripts/build.py`；应用根可用 `python3 scripts/build.py`。默认 `--device enduro3`；`--all` 构建本应用全部目标；`--simulator`、`--run`、`--test` 使用官方对应模拟器目标。

`--run` 要求官方模拟器已启动，并持续连接直到应用结束。切换目标前使用 **File → Kill Device**，确认窗口回到空设备；仅Kill App会保留上一设备。截图时核对实际窗口目标，结束本任务时退出本次独占启动的模拟器。保留原始日志及退出码，不能把超时记为成功。

`--package VERSION` 通过官方 `-e -r` 导出全部目标，保留 `artifacts/release-VERSION/` 的原包、SHA报告和日志。发布前使用 `--device TARGET --release --run` 验证去除调试信息的构建。

渲染修改后验证对应尺寸及MIP/AMOLED实际模拟器画面；多目标变更需全目标发行导出和代表目标实际运行。仅时制逻辑改变时重跑 `tests/TimeTests.mc`。不默认运行另一表盘或全仓库测试。SDK9.2.0既有测试摘要解析问题需按实际用例输出和原始退出码分别报告，不吞异常。

构建、模拟器、商店提交、真机安装、腕上显示、续航分别需要独立证据。商店发布及真机安装需要对应授权，不从历史权限推定新操作。
