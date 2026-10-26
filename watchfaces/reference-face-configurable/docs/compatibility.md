# 设备兼容矩阵

原始矩阵核对日期：2026-10-19；fēnix 6系列于2026-10-26补充核对官方兼容目录、设备参考和本机官方设备包。以下“支持”指官方允许 Watch Face；本项目的编译/模拟器结果另见构建记录，不能由该表推导。

| 官方目标 | 型号 | 屏幕 | API | 表盘内存 KiB |
| --- | --- | --- | --- | --- |
| `enduro` | Enduro™ | 280 x 280 | 3.4 | 112 |
| `enduro3` | Enduro™ 3 | 280 x 280 | 6.0 | 128 |
| `enduro4` | Enduro™ 4 | 280 x 280 | 6.0 | 128 |
| `fenix6` | fēnix® 6 / 6 Solar / 6 Dual Power | 260 x 260 | 3.4 | 112 |
| `fenix6pro` | fēnix® 6 Pro / 6 Sapphire / 6 Pro Solar / 6 Pro Dual Power / quatix® 6 | 260 x 260 | 3.4 | 112 |
| `fenix6s` | fēnix® 6S / 6S Solar / 6S Dual Power | 240 x 240 | 3.4 | 96 |
| `fenix6spro` | fēnix® 6S Pro / 6S Sapphire / 6S Pro Solar / 6S Pro Dual Power | 240 x 240 | 3.4 | 96 |
| `fenix6xpro` | fēnix® 6X Pro / 6X Sapphire / 6X Pro Solar / tactix® Delta / quatix® 6X | 280 x 280 | 3.4 | 128 |
| `fenix7x` | fēnix® 7X / tactix® 7 / quatix® 7X Solar / Enduro™ 2 | 280 x 280 | 5.2 | 128 |
| `fr165` | Forerunner® 165 | 390 x 390 | 5.2 | 128 |
| `fr165m` | Forerunner® 165 Music | 390 x 390 | 5.2 | 128 |
| `fr170` | Forerunner® 170 | 390 x 390 | 6.0 | 128 |
| `fr170m` | Forerunner® 170 Music | 390 x 390 | 6.0 | 128 |
| `fr230` | Forerunner® 230 | 215 x 180 | 1.4 | 64 |
| `fr235` | Forerunner® 235 | 215 x 180 | 1.4 | 64 |
| `fr245` | Forerunner® 245 | 240 x 240 | 3.3 | 96 |
| `fr245m` | Forerunner® 245 Music | 240 x 240 | 3.3 | 96 |
| `fr255` | Forerunner® 255 | 260 x 260 | 5.2 | 128 |
| `fr255m` | Forerunner® 255 Music | 260 x 260 | 5.2 | 128 |
| `fr255s` | Forerunner® 255s | 218 x 218 | 5.2 | 128 |
| `fr255sm` | Forerunner® 255s Music | 218 x 218 | 5.2 | 128 |
| `fr265` | Forerunner® 265 | 416 x 416 | 5.2 | 128 |
| `fr265s` | Forerunner® 265s | 360 x 360 | 5.2 | 128 |
| `fr45` | Forerunner® 45 | 208 x 208 | 1.4 | 48 |
| `fr55` | Forerunner® 55 | 208 x 208 | 3.4 | 96 |
| `fr57042mm` | Forerunner® 570 42mm | 390 x 390 | 6.0 | 128 |
| `fr57047mm` | Forerunner® 570 47mm | 454 x 454 | 6.0 | 128 |
| `fr630` | Forerunner® 630 | 215 x 180 | 1.4 | 64 |
| `fr645` | Forerunner® 645 | 240 x 240 | 3.1 | 96 |
| `fr645m` | Forerunner® 645 Music | 240 x 240 | 3.2 | 96 |
| `fr70` | Forerunner® 70 | 390 x 390 | 6.0 | 128 |
| `fr735xt` | Forerunner® 735xt | 215 x 180 | 2.4 | 64 |
| `fr745` | Forerunner® 745 | 240 x 240 | 3.3 | 96 |
| `fr920xt` | Forerunner® 920XT | 205 x 148 | 1.4 | 64 |
| `fr935` | Forerunner® 935 | 240 x 240 | 3.1 | 96 |
| `fr945` | Forerunner® 945 | 240 x 240 | 3.3 | 96 |
| `fr945lte` | Forerunner® 945 LTE | 240 x 240 | 3.4 | 96 |
| `fr955` | Forerunner® 955 / Solar | 260 x 260 | 5.2 | 128 |
| `fr965` | Forerunner® 965 | 454 x 454 | 5.2 | 128 |
| `fr970` | Forerunner® 970 | 454 x 454 | 6.0 | 128 |

共40个开发目标：Enduro对应4个、Forerunner对应31个、fēnix 6系列对应5个。Enduro 2使用fenix7x，Forerunner 955 Solar使用fr955。fēnix 6系列17个型号名称映射至上述5个target，别名详见JSON；不另设不存在的`fenix6x`或Solar/Sapphire开发目标。

Forerunner 45 Plus使用`fr45`：官方Connect IQ商店的设备类型记录将其硬件编号列为`006-B3847-00`，官方`fr45/compiler.json`包含相同编号。日版ForeAthlete 45S同样通过商店别名和硬件编号`006-B3469-00`核实映射到`fr45`。这两项无需新增SDK target，当前构建入口生成`reference-face-configurable-fr45.prg`，覆盖对应硬件编号。

国际版Forerunner 45S的名称与硬件编号对应仍未确认，不从日版映射外推全部地区。硬件编号证据不替代商店发布、实际下发或真机安装验证。Forerunner 25/30/35等无对应目标，不纳入可安装承诺。

来源：[官方商店设备类型API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/deviceTypes)、[已保存记录与SDK对照](verification/fr45-device-mapping.json)。

详细原始字段、逐设备官方链接与地区part number见 [compatibility.json](compatibility.json)。

API1.4设备仅有基础时间、电量和硬件所提供的心率等能力；Weather自3.2、VO2/恢复/身体电量/活动历史自3.3、系统周跑量和日出Complications自4.2，具体成员仍按运行时检测。官方能力页API版本不保证用户手表已经升级到该固件。

fēnix 6系列本机设备包的地区API为3.4.1–3.4.5，表盘内存按Watch Face分别为96/112/128KiB。复用240/260/280字体与MIP显示路径，机上设置保留；API 4.2的系统周跑量及日出不可用，自动信息位跳过，显式选择显示“不支持”。这不影响支持的本地活动历史图；天气及健康指标仍受固件能力、同步状态与样本有效期约束。

来源：[官方兼容目录](https://developer.garmin.com/connect-iq/compatible-devices/)、[6](https://developer.garmin.com/connect-iq/device-reference/fenix6/)、[6 Pro](https://developer.garmin.com/connect-iq/device-reference/fenix6pro/)、[6S](https://developer.garmin.com/connect-iq/device-reference/fenix6s/)、[6S Pro](https://developer.garmin.com/connect-iq/device-reference/fenix6spro/)、[6X Pro](https://developer.garmin.com/connect-iq/device-reference/fenix6xpro/)，以及各目标官方设备包的`compiler.json`和`simulator.json`。

2026-10-26本轮结果：五个新增目标的真机版/模拟器版构建和最终模拟器运行均退出0；6S Pro、6 Pro、6X Pro各自的三种布局完成视觉验收，6S Pro低功耗隐藏秒通过。6/6S的截图采集受本机截图接口失败影响，仅记录加载与运行结果。本轮未上传商店、未真机安装。见[HTML回执](fenix6-support.html)与[构建/运行报告](verification/fenix6-support.json)。
