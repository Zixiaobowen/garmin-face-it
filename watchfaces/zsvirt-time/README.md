# ZSvirt Time

[返回工作区](../../README.md) · [开发约束](docs/garmin-dev-project.md)

以本地时间与ZSvirt官方Logo为主视觉、底部显示手表电量和今日步数的Connect IQ表盘，目标为Garmin Enduro 3的280×280 MIP圆屏。

- 黑底白字，160×45 像素官方横版 Logo 位于时间上方。
- 时、分跟随手表系统的 12/24 小时制；12 小时制显示 AM / PM，午夜与正午均为 12 点。
- 底部左侧为电池图标和整数百分比，右侧为脚步图标与今日完整步数；两项使用同一行小号白字。有效0步显示 `0`，系统未提供步数时显示 `--`。
- 不显示秒，不使用计时器、动画、后台服务或传感器权限。休眠由系统按分钟刷新；唤醒与休眠使用相同布局。尚未测量真机续航。
- 应用名 `ZSvirt Time`，UUID `cb51f19636e64ae1b979bfd8bf070e31`，与耐力仪表独立安装。

1.0.0已于2026-10-26提交Connect IQ，当前为“应用程序待处理”，尚未公开上架。[商店预览](https://apps-developer.garmin.com/zh-CN/apps/2702e86b-ba01-44ed-9d5a-9b29777945f4)在审核通过前仅账户本人可见；[发布记录](docs/release-1.0.0.md)保留实际提交和签名回读结果。

1.1.0增加电量和步数。电量读取 `System.getSystemStats().battery`，步数读取 `ActivityMonitor.getInfo().steps`（设备本地当天从午夜起的累计值），无需新增权限。随系统表盘刷新读取，只有数值变化时重建字符串；不另设定时器。

## 构建与运行

依赖沿用工作区已安装的 Connect IQ SDK、Java 17、官方 Enduro 3 设备包与仓库外开发者签名密钥。构建使用 Python 3.11+；仅重新生成图片时需要 Pillow。工程按 SDK `bin/templates/watchface/simple/` 官方模板结构建立，删除了无行为的生命周期回调。

从仓库根执行：

```sh
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"

# 真机候选包
python3 watchfaces/zsvirt-time/scripts/build.py --device enduro3

# 官方模拟器已经运行时，编译并运行
python3 watchfaces/zsvirt-time/scripts/build.py --device enduro3 --run

# 发布前验证移除调试信息后的模拟器构建
python3 watchfaces/zsvirt-time/scripts/build.py --device enduro3 --release --run

# 导出包含 manifest 全部目标的签名商店包
python3 watchfaces/zsvirt-time/scripts/build.py --package 1.1.0

# 午夜、正午及格式边界测试
python3 watchfaces/zsvirt-time/scripts/build.py --device enduro3 --test --run

# 从保留的官方原图重新生成 MIP 位图
python3 watchfaces/zsvirt-time/scripts/generate-resources.py
```

也可在本表盘目录运行 `python3 scripts/build.py`。脚本按自身路径定位工程，不调用其它表盘的配置生成器；支持 `--sdk`、`CIQ_SDK_HOME` 与 `--key`。SDK 默认读取 macOS 官方配置；没有唯一 SDK 时明确报错。

真机产物为 `bin/zsvirt-time-enduro3.prg`；`-sim.prg` 与 `-tests.prg` 仅供官方模拟器。日志及原始退出码保留在 `bin/`。`--run` 会持续等待模拟器中的应用结束，不是只推送后立即返回；结束本轮验收后关闭该模拟器。

`--package VERSION` 使用官方 `-e -r` 导出，输出到 `artifacts/release-VERSION/`，保留原始编译日志、退出码和 SHA-256。它不能与 `--device`、`--simulator`、`--run` 或 `--test` 混用；版本格式为 `MAJOR.MINOR.PATCH`。`--release --run` 生成单独的 `-sim-release.prg`，用于发布前验证，不覆盖普通模拟器产物。

## 资源与品牌

Logo 来自 [ZSvirt 官方下载页](https://zsvirt.io/download)。`assets/` 保留官方白色横版和独立图形原图，[SOURCES.json](assets/SOURCES.json) 记录下载 URL 与 SHA-256。生成器仅裁透明边、等比缩放并转换为 Enduro 3 可显示的黑、白与两级灰；不重画 Logo、不用普通字体代替品牌字标。启动图标使用独立资源。

时间使用设备内置字体，不携带另一套字体。Logo 属于 ZSvirt 品牌资产；官网下载页未附单独 Logo 许可，不将其视为商标权转让。

## 验收边界

构建、模拟器显示、真机安装与续航分别验收。当前仅适配 Enduro 3，没有真机安装或续航测量。实际截图见 [HTML 回执](docs/delivery.html)；商店包与提交状态见 [1.0.0 发布记录](docs/release-1.0.0.md)。[隐私说明](docs/privacy.md)与[问题反馈](https://github.com/Zixiaobowen/garmin-face-it/issues)可供商店用户查阅。

电量与步数开发版已通过 Enduro 3 真机目标构建和官方模拟器显示检查：0%/0步、100%/123456步、82%/8642步，以及12/24小时切换、数值归零和重新增长。截图未见重叠或裁切；详见[本轮验证记录](docs/verification/battery-steps.json)。本轮未重跑未改动的时制测试，也未运行全仓库测试；尚未在真机验证或上传这次功能。
