# ZSvirt Time 1.3.0 发布记录

2026-10-26。已上传Connect IQ，内部版本4、状态PENDING。应用主记录和实际兼容页均回读通过，当前等待Garmin审核，尚未公开上架。

## 本次变化

新增34个fēnix目标，总计69个官方产品目标、12种分辨率。完整集合见[独立设备矩阵](compatibility.json)。新增466×466屏幕Logo与36×36启动图标；沿用原渲染源码、12/24小时制、Logo、电量、完整步数和AMOLED休眠逻辑。UUID与签名身份保持不变，无新增权限。

fēnix6系列5个目标全部纳入：`fenix6`、`fenix6pro`、`fenix6s`、`fenix6spro`、`fenix6xpro`。商店实际列出6／6S／6X的标准版、Pro、Sapphire、Solar和Dual Power变体；对应20个区域part number均回读确认，无遗漏。

商店可见fēnix3、5、6、7、8、Chronos和E系列。官方设备包另含fēnix9目标，发行包和商店主记录已接受对应part number，但本次商店兼容页没有显示9系列名称，不宣称其商店安装可用。旧机API1.3.1区域固件仍因最低API1.4.0而被导出器排除。

## 实际验证

- `python3 watchfaces/zsvirt-time/scripts/generate-resources.py` 与 `scripts/configure.py`：成功生成12种屏宽、6种启动图标尺寸与69目标配置。
- `python3 watchfaces/zsvirt-time/scripts/build.py --package 1.3.0`：退出0，116/116区域变体构建成功。
- `--device TARGET --release --run`：fēnix6系列全部5个目标、fēnix3、fēnix9 Pro51mm、FR255s，共8次编译与官方模拟器运行均退出0。已实际查看画面，未见Logo、时间、电量、步数重叠或裁切；本轮输入为100%电量、0步、12小时制PM。
- 466×466 AMOLED原始帧中2190个亮像素，占圆形屏幕约1.284%，低于10%；唤醒恢复Logo、电量和步数。没有重测未改动的分钟位移逻辑；1.2.0已有连续两分钟互不重叠证据。
- 官方SDK `VerifyingUtils.verifyIqFile` 返回true；`checkIqFileAgainstPrevious` 确认与1.2.0签名身份相同。
- 商店主记录确认版本1.3.0／内部4、116个device type及116个区域part number；与矩阵中符合最低API的116个区域型号完全一致。中英文说明、更新说明均逐字段回读一致。

原包：`artifacts/release-1.3.0/zsvirt-time-1.3.0.iq`，799684字节，SHA-256 `78257f19a97a3e2bfcd3be27eaee8c703e0b214eb6367d2a9c41604a352cf4de`。保留此前版本原包。

证据：[构建与模拟器](verification/fenix-1.3.0.json)、[商店提交](verification/store-submission-1.3.0.json)、[实际兼容列表](verification/store-compatible-1.3.0.txt)。原始模拟器画面保留在本版本artifacts的simulator目录。

本轮没有真机安装、腕上显示、功耗或续航证据。没有重跑未改动的时制测试、123456步边界场景或全仓库测试。旧的Enduro3侧载记录属于此前版本，不能作为1.3.0真机验收。商店图标及画廊图片沿用现有素材。
