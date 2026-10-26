# ZSvirt Time

[返回工作区](../../README.md) · [开发约束](docs/garmin-dev-project.md)

以本地时间与 ZSvirt 官方 Logo 为主视觉，显示电量和今日步数的 Connect IQ 表盘。1.2.0 将支持范围扩展为 35 个官方设备目标，涵盖 Enduro、Forerunner 及 Enduro 2 对应的 `fenix7x` 目标；完整列表以[独立设备矩阵](docs/compatibility.json)为准。

- 黑底白字，正式横版 Logo 等比缩放；时间、Logo 和数据根据屏幕与实际字体尺寸排布。
- 遵循手表 12/24 小时制；12 小时制显示 AM/PM，午夜和正午均为 12 点。
- 电池图标和整数百分比、脚步图标和完整步数。有效 0 显示 `0`，系统未提供步数时显示 `--`。
- MIP 休眠保持完整画面；AMOLED 休眠只显示灰色时间与 AM/PM，每分钟交替上下位置，唤醒恢复完整画面。
- 不显示秒，不添加计时器、动画、后台服务、联网或传感器权限。电量来自 `System.getSystemStats().battery`，今日步数来自 `ActivityMonitor.getInfo().steps`。
- 应用名 `ZSvirt Time`，UUID `cb51f19636e64ae1b979bfd8bf070e31`，沿用原签名，与耐力仪表独立安装。

最低 API 为 1.4.0。部分旧机的区域设备定义仍标为 API 1.3.1，该固件范围不符合最低要求；35 个产品目标不代表所有地区、固件版本均可安装。

1.1.0 已提交 Connect IQ，内部版本 2、状态 PENDING；1.2.0 正在完成兼容性发布验收。[商店预览](https://apps-developer.garmin.com/zh-CN/apps/2702e86b-ba01-44ed-9d5a-9b29777945f4)在审核通过前仅账户本人可见。历史原包和[1.1.0 发布记录](docs/release-1.1.0.md)保留。

## 构建与运行

使用 Connect IQ SDK、Java 17、矩阵中的官方设备包及仓库外原签名密钥。构建需要 Python 3.11+；重新生成图片需要 Pillow。以下命令从仓库根执行：

```sh
# 构建 Enduro 3 真机 PRG（默认目标）
python3 watchfaces/zsvirt-time/scripts/build.py --device enduro3

# 构建本表盘全部 35 个目标
python3 watchfaces/zsvirt-time/scripts/build.py --all

# 官方模拟器已启动时，运行去除调试信息后的目标
python3 watchfaces/zsvirt-time/scripts/build.py --device fr265 --release --run

# 全目标签名商店包
python3 watchfaces/zsvirt-time/scripts/build.py --package 1.2.0

# 需要修改时制逻辑时运行边界测试
python3 watchfaces/zsvirt-time/scripts/build.py --device enduro3 --test --run

# 从正式源图重建尺寸、调色板及 launcher 资源
python3 watchfaces/zsvirt-time/scripts/generate-resources.py
```

构建前自动从 `docs/compatibility.json` 生成 `manifest.xml` 和 `monkey.jungle`，并生成本次目标的构建快照；不要手改生成配置。独立使用 `python3 watchfaces/zsvirt-time/scripts/configure.py` 可重新生成配置。工程不依赖另一款表盘的文件。

也可在应用根运行 `python3 scripts/build.py`。支持 `--sdk`、`CIQ_SDK_HOME` 与 `--key`；SDK 不明确或签名密钥缺失时直接报错。真机产物为 `bin/zsvirt-time-<device>.prg`；带 `-sim`、`-sim-release`、`-tests` 的文件仅供官方模拟器。日志、哈希和退出码保留在 `bin/`。

`--run` 持续连接应用直到结束。切换机型前在模拟器使用 **File → Kill Device**，防止沿用上一款设备；只执行 Kill App 不足以切换目标。结束本轮验收后退出本次独占启动的模拟器。

`--package VERSION` 使用官方 `-e -r` 导出，产物及报告保留于 `artifacts/release-VERSION/`。版本格式为 `MAJOR.MINOR.PATCH`；不能与单设备、模拟器或测试选项混用。

## 资源与品牌

Logo 来自 [ZSvirt 官方下载页](https://zsvirt.io/download)。`assets/` 保留正式源图，[SOURCES.json](assets/SOURCES.json)记录来源和 SHA-256。生成器只裁透明边、等比缩放、合成黑底，并按设备调色板生成黑白或四级灰图像；不重画 Logo，不用普通字体替代字标。Launcher 按官方设备定义的独立尺寸生成。时间使用设备内置字体。

Logo 属于 ZSvirt 品牌资产；官网下载页未附单独 Logo 许可，不将其视为商标权转让。

## 验收边界

构建、模拟器显示、商店提交、真机安装与续航分别验收。实际画面和本轮结果见 [HTML 回执](docs/delivery.html)。2026-10-26已将此前Enduro 3专用的时间＋Logo＋电量＋步数版侧载并回读校验，14,844字节安装包与设备回读逐字节一致，详见[安装记录](docs/verification/enduro3-installation-20261026.json)；安装期间并行产生的后续改动不属于这次已安装版本。尚未验收腕上显示或测量续航；AMOLED 亮像素检查不能替代真机烧屏与功耗验证。没有运行全仓库测试。

[隐私说明](docs/privacy.md) · [问题反馈](https://github.com/Zixiaobowen/garmin-face-it/issues)
