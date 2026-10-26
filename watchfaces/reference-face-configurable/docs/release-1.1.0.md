# 耐力仪表·可配 1.1.0 · fēnix 6 系列发布记录

2026-10-26。用户授权“提交推送到 GitHub 并上传商店”。应用 UUID 保持 `9d182df86c2d48938ce2c9795678f668`，更新原 [Connect IQ 应用](https://apps.garmin.com/zh-CN/apps/aa58871d-46ed-49f2-9c18-72efdaa7eb50)。

## Git 与本次变化

适配提交 `c89fd97`；合并远端 ZSvirt Time 独立仓库调整的提交为 `3b1767f`，已推送至 `origin/main`。保留原签名和无关未提交记录，未强推。

新增 `fenix6`、`fenix6pro`、`fenix6s`、`fenix6spro`、`fenix6xpro` 五个官方目标，manifest 从35增至40。覆盖对应 Solar、Sapphire、Dual Power 型号；五个目标的20个硬件编号均已进入开发者后台的兼容清单。沿用240/260/280px布局、字体和数据读取；系统周跑量与日出仍按设备能力处理，自动模式跳过，显式选择显示“不支持”。

发布阶段在现有 `scripts/build.py` 增加 `--release`，让官方模拟器目标也能使用 `-r`，输出独立的 `-sim-release.prg`；与 `--test`互斥。真机版及商店包仍按原方式去除调试信息。更新中英文商店说明，并将隐私链接修正为多表盘目录下的现行文件。

## 实际验证

- 适配阶段：五个新增目标的真机版、模拟器版均编译成功；五款实际模拟器运行最终退出0。三种屏幕尺寸的Pro代表机型完成日常、训练、极简及机上切换检查；详见 [适配回执](fenix6-support.html) 与 [原始结果](verification/fenix6-support.json)。
- 本次发布：`python3 scripts/build.py --package 1.1.0`，40目标官方导出退出0。
- 官方 SDK `VerifyingUtils.verifyIqFile` 返回 `true`，退出0；商店也回读 `signatureCheckSuccessFul: true`，应用身份一致。
- `python3 scripts/build.py --device fenix6spro --release --run`：编译与模拟器均退出0。实际核对大字时间、日期、心率、身体电量、温度和步数显示；通过 File → Kill App 正常退出。构建为54,124字节，截图保留在本机发布目录。
- `python3 scripts/build.py --release --test`：按预期拒绝冲突选项，退出2；未触发编译。
- 未运行全仓库或Monkey C单元测试。没有进行fēnix 6真机安装、手机下发或续航验收。
- HTML回执已在Tern原生页面核对1512px浅色与实际460px深色画面，均无横向溢出；图片加载、证据展开/收起和5个本地链接通过，控制台及页面错误为空。已固定到当前会话右侧并释放接管，见 [浏览器回执](verification/release-1.1.0-browser.json)。

## 上传与公开状态

| 观察位置 | 版本 | 兼容硬件编号 | 新增fēnix 6编号 |
| --- | --- | --- | --- |
| 开发者后台回读 | 1.1.0，内部3 | 76 | 20/20 |
| 公开商店回读 | 1.0.1，内部2 | 56 | 0/20 |

文件验证HTTP 200，版本POST 204，资料PUT 204；重新读取metadata与应用数据均为200。中英文新功能和兼容说明已逐项回读一致，公开页面也已出现新说明。

后台仪表板显示应用“已批准”，接口为`APPROVED`、`hasVersionPendingScan: false`；**这不能替代新版本公开上架证据**。公开接口在`no-store`请求下仍返回1.0.1，兼容清单尚未包含新增机型。本次上传流程已完成，界面未发现额外发布操作；公开端更新时间及差异原因尚未确认，不将其表述为已完成fēnix 6商店下发。

## 产物与证据

- 本机包：`artifacts/release-1.1.0/reference-face-configurable-1.1.0.iq`，2,776,681字节。
- SHA-256：`e93c22b1f15830af45c7d7368aeba8717d16060d45334869d4d6f3a0a9f1317e`。
- [发布JSON回执](verification/release-1.1.0.json)；[HTML回执](release-1.1.0.html)；[交接记录](codex-handoffs/2026-10-26-fenix6-release.md)。
- 本机`artifacts/release-1.1.0/`保存导出日志、报告、SDK验签回执、发布模拟器截图、后台版本截图、兼容清单截图及公开页面截图。发布原包和旧版本原包不纳入Git，也未覆盖或删除。
