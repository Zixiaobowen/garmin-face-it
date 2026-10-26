# ZSvirt Time 开发约束

本说明仅约束 `watchfaces/zsvirt-time/`。当前目标以时间与ZSvirt官方Logo为主视觉，并显示手表电量和今日步数；用户设备为Enduro 3。不要套用耐力仪表的UUID、35目标矩阵、数据模块、配置生成器或发布历史。

## 身份与工程

- 应用 UUID：`cb51f19636e64ae1b979bfd8bf070e31`；入口 `ZsvirtTimeApp`；名称 `ZSvirt Time`。
- 官方目标仅 `enduro3`，280×280 MIP；最低 API 4.0.0；没有额外权限。不要以此宣称 AMOLED 或其它尺寸已适配。
- 使用 SDK 9.2.0 的 `bin/templates/watchface/simple/` 模板结构创建；静态 `manifest.xml` 和 `monkey.jungle` 是真实构建输入，没有配置生成器。
- 应用、资源、测试、脚本和输出均归属本目录。官方 SDK、Java 17 与仓库外开发者密钥可共用，不复制或链接密钥。

## 行为与资源

- `FaceTime` 负责 12/24 小时制与 AM/PM；`ZsvirtTimeView` 直接读取设备本地时钟和系统时制，不模拟时间、不进行时区换算。
- 时间字符串仅在时、分或时制变化时重建；电量、步数字符串仅在对应值变化时重建。每次 `onUpdate` 读取当前系统电量和当天步数，并重绘完整画面，避免返回表盘时出现残影或空白。
- 不显示秒，不添加Timer、动画、后台联网或直接传感器采样。电量来自 `System.getSystemStats().battery`，显示整数百分比；步数来自 `ActivityMonitor.getInfo().steps`，有效0必须显示0，null显示 `--`，不沿用上一有效值。这两个系统API无需新增权限。
- MIP休眠由官方WatchFace生命周期控制，保持Logo、时间、电量及步数完整可见；不宣称已测得节电比例。固定布局仅为Enduro 3设计：Logo顶部60px，时间中心158px，AM/PM中心197px，底部数据中心225px。
- Logo 原件和来源见 `assets/SOURCES.json`；图形只裁透明边、等比缩放、转为四级灰。通过 `scripts/generate-resources.py` 重现，不能重画品牌图形或替换字标。

## 调度与验证

从仓库根使用 `python3 watchfaces/zsvirt-time/scripts/build.py --device enduro3`；从应用根使用 `python3 scripts/build.py --device enduro3`。参数 `--simulator` / `--run` / `--test` 使用官方 `enduro3_sim`；普通构建生成真机 PRG。先启动官方模拟器再使用 `--run`。

商店导出使用 `--package VERSION`，通过官方 `-e -r` 覆盖 manifest 全部目标，产物和SHA报告保留在本应用 `artifacts/release-VERSION/`。发布前通过 `--device enduro3 --release --run` 验证去除调试信息后的模拟器构建；该产物独立命名为 `-sim-release.prg`。

`--run` 持续连接正在运行的应用，必须保留运行日志并在截图后结束本次独占模拟器；超时不能记作 runner 成功。SDK 9.2.0 存在测试摘要解析异常的项目历史，当前运行仍按实际用例输出和原始退出码分别报告，不吞异常或强制改为成功。

修改渲染后须构建并查看官方模拟器实际画面。时制边界定向运行 `tests/TimeTests.mc`；不默认运行另一款表盘测试或全仓库构建。真机安装、商店发布、真机显示与续航各需相应授权和独立证据。
