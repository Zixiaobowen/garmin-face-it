# 耐力仪表 · Garmin 参考图表盘

“耐力仪表·可配”是一款中文 Connect IQ 表盘，优先适配 Enduro 3。仓库包含应用源码、设置、字体图集、字体许可证、35个官方目标配置及构建脚本。1.0.0已提交Connect IQ审核，后台状态为“待处理”，尚未公开上架；详见[发布记录](docs/release-1.0.0.md)。

## 显示内容

同一款表盘提供日常、训练、极简三种布局，红、蓝、绿、橙、白五种强调色。时间、日期和电量始终保留；秒、农历、本地跑量图和心率区可分别开关。

Enduro 3 的标签字号为15px、次要文字13px、数据24px，日常/极简时间使用84px字库（实际数字最大字高约65px）。训练布局使用较紧凑的同款数字字体。小屏将标签与数值横排，保留全部已启用信息位；表盘与设置菜单分别加载各自需要的字形。

- 信息位可选自动、关闭、心率、身体电量、温度/体感、恢复小时、周跑量、摄氧量/等级、日出、降雨概率、步数。日常最多4位，训练大屏最多6位，极简2位；宽度≤240或高度<200的设备最多4位。关闭后自动收拢，自动选择不重复占用显式指标。
- 支持但暂缺合格数据时显示 `--`；显式选择设备不支持的能力时显示“不支持”。自动模式只选设备支持的能力，不因某次样本缺失而换位。
- “身体电量”对应 Body Battery；数值与VO2等级使用中性色，强调色用于分隔线和历史图。心率区保留独立的区间颜色。
- 训练布局中的“本地近7日”是设备保留的已保存跑步，横轴为6天前至今天，不包括已删除或仅在 Garmin Connect 云端的活动。柱高按当前七日最大值缩放，不能据柱高比较不同周。
- 系统“周跑量”来自 Garmin Complication，周边界由设备定义，与本地图的统计口径不同。目标范围0–1000km，机上支持0.01km精度；0显示“未设目标”，不自动取 Garmin Connect 训练计划目标。
- 恢复时间直接显示小时；日出有明确标签。心率标注最近合格样本的分钟年龄。
- 天气来自 Garmin 系统缓存，温度和体感固定以°C显示；超过3小时隐藏数值并标“天气过期”。心率只接受5分钟内有效样本，身体电量只接受30分钟内样本，不会用模拟值替代缺失值。
- VO2等级按 Garmin 公开标准表及档案中的出生年/性别计算，只有20–79岁且档案完整时显示；出生年推算年龄与实际生日可能相差1岁。
- 农历由ICU中国历生成的本地压缩表计算，公历覆盖2000-01-01至2099-12-31，范围外显示“农历--”。
- MIP睡眠态隐藏秒，按系统每分钟刷新；AMOLED睡眠态只保留稀疏时间与日期并交替显示区域。数据按分钟读取，档案/心率区间缓存15分钟，本地活动缓存5分钟；换日、重新开启历史和时钟回拨及时刷新。关闭历史图时不扫描活动，唤醒不清空慢数据缓存。尚无真机节电比例或续航结论。

## 设置

手机 Connect IQ 的表盘设置与 API 3.2+ 的机上设置使用同一组持久化属性。机上菜单提供布局、强调色、6个信息位及显示开关；信息位5/6只用于大屏训练布局。周目标编辑页分别调节整数和两位小数：上/下键增减，确认键进入小数后保存，返回键回到整数，再返回取消。触屏也可选择数位、点按加减与保存；保存前校验0–1000km范围，字号按最大整数宽度与行高选择。

Enduro 3 可通过表盘的自定义/设置入口修改；官方模拟器使用 **Settings → Trigger App Settings**。API低于3.2的目标使用手机设置。机上入口的保存、即时生效和正常重启保留已在模拟器验收；手机设置传输和新版真机行为尚未验收。表盘与机上设置界面主要为简体中文，英文商店说明不代表英文界面。

## 工具与构建

需要 Python 3.11+、Garmin Connect IQ SDK 9.2.0、Java 17、已通过官方 SDK Manager 下载的目标设备定义和仓库外的RSA4096开发签名密钥。

脚本读取macOS官方SDK配置，也接受 `--sdk` 或 `CIQ_SDK_HOME`。默认签名密钥位置是 `~/.local/share/garmin-face-it/developer_key.der`；可用 `--key` 指定自己的密钥，密钥不随源码或构建产物分发。

构建脚本继承当前进程环境。使用Homebrew Java 17时，可在当前终端设置：

```sh
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"
```

```sh
# 优先目标：生成 bin/reference-face-configurable-enduro3.prg
python3 scripts/build.py --device enduro3

# 全部官方目标逐个编译，结果 bin/build-all.json
python3 scripts/build.py --all

# 官方export：覆盖manifest全部目标的签名商店包
python3 scripts/build.py --package 1.0.0

# 先启动已安装的官方模拟器
"$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.2.0-2026-06-09-92a1605b2/bin/connectiq"
python3 scripts/build.py --device enduro3 --run
python3 scripts/build.py --device enduro3 --test --run

# 只生成模拟器版本，便于单独运行和排查
python3 scripts/build.py --device fr920xt --simulator
```

构建日志保存在 `bin/logs/`，JSON报告记录编译器及模拟器原始退出码，入口以0/1表示总体成功/失败。`--run`、`--test`和`--simulator`使用官方`<device>_sim`编译目标；普通模拟器产物为`reference-face-configurable-<device>-sim.prg`，测试产物为`-tests.prg`。默认生成真机PRG。920XT真机字体含180°设备方向编码，必须区分两种目标。模拟器已经运行后才使用`--run`。

`--package VERSION`使用官方`-e -r`导出，输出到`artifacts/release-VERSION/`，同时保存编译日志、目标列表、字节数和SHA-256。它不能与单目标、模拟器或测试模式混用；版本参数用于文件名及商店提交资料，不向manifest添加不存在的版本字段。此目录不提交Git；重复导出可能因SDK时间戳而产生不同SHA，不能承诺逐字节一致。

已有18项数据／设置／信息位用例记录为PASS，但SDK9.2.0的测试摘要解析异常使runner退出1；不能把整条命令算作成功。历史全目标构建、代表设备显示和本次定向检查分别记在[提交审查](docs/review-commit-2026-10-22.md)，不混写为本轮重跑。原始日志与截图保留在本机，不是应用构建输入。

## 可重现资源

```sh
# 根据已核实矩阵生成 manifest.xml 与 monkey.jungle
python3 scripts/configure.py
# 用 Node.js 完整 ICU 中国历生成紧凑农历数据
node scripts/generate-calendar.mjs
# Python Pillow；源字体从下方官方字体仓库获取
python3 scripts/generate-fonts.py --font /path/to/NotoSansSC-wght.ttf
```

生成的中文、数据与时间位图字体均使用 [Google Fonts / Noto Sans SC](https://github.com/google/fonts/tree/main/ofl/notosanssc)，可用于海外固件，不依赖系统中文字形。表盘标签、次要文字、数据、主时间、密集布局时间、常显时间与设置菜单分别使用对应子集；旧七段式数字和旧字号资源已移除。许可证在 [resources-fonts/OFL.txt](resources-fonts/OFL.txt)，源文件哈希、字号与字重在 [docs/font-assets.json](docs/font-assets.json)。更新资源生成脚本后重新生成对应文件。

## 兼容与安装边界

完整原始矩阵：[docs/compatibility.json](docs/compatibility.json)。目标包括独立的Music/S/LTE/尺寸型号；Enduro 2使用官方`fenix7x`目标，Forerunner 955 Solar使用`fr955`。35个target与35个营销型号并不等价。

Forerunner 45 Plus已由官方商店硬件编号`006-B3847-00`核实共用`fr45`；日版ForeAthlete 45S（`006-B3469-00`）也已核实，国际版45S映射仍未确认。[公开映射证据](docs/verification/fr45-device-mapping.json)保留官方记录与SDK编号对照；这些结论不替代真机安装或商店下发验证。没有开发target的旧型号（如25/30/35）不被宣称可安装，其他地区别名与未来型号不自动视为已验证。

最老目标仅API1.4，fr45表盘内存只有48KiB；现代天气/训练/Complications可能不可用，自动布局只选支持的指标。新版的编译、代表设备截图和内存记录以当前验证报告为准，不沿用旧版内存数值证明新版通过。35个target及历史模拟器范围不代表35款真机验收通过。

Enduro 3的真机候选为`bin/reference-face-configurable-enduro3.prg`；`-sim.prg`和`-tests.prg`仅用于模拟器。UUID为`9d182df86c2d48938ce2c9795678f668`，后续更新维持此身份。旧“耐力仪表”的UUID为`b9b8804748954f99be17e7c4483b4db3`，其应用及数据必须保留。

最近一次有侧载回读证据的是2026-10-21的可配置版；本次字体和温度单位修订尚未安装。真机可读性、真实指标与续航、手机设置传输链路均需独立验收。原始安装回读与旧版备份只保留在本机，不纳入源码基线。

## 项目证据

- [首次提交审查与定向验证](docs/review-commit-2026-10-22.md)
- [设备兼容矩阵](docs/compatibility.md)
- [字体来源、哈希及图集元数据](docs/font-assets.json)
- [1.0.0发布记录与验证边界](docs/release-1.0.0.md)
- [隐私说明 / Privacy notice](docs/privacy.md)

本表盘免费，无广告、付费解锁或订阅。健康数据通过设备本地官方API读取；没有开发者服务器、网络上传或第三方天气密钥。问题反馈请使用[GitHub Issues](https://github.com/Zixiaobowen/garmin-face-it/issues)，提供设备型号、固件版本及复现步骤，请勿附个人健康记录。响应取决于维护者可用时间，不承诺固定时限。
