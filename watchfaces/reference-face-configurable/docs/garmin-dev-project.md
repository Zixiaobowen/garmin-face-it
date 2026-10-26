# 耐力仪表·可配开发约束

2026-10-26更新目录说明；既有验证记录仍以各自日期为准。本文件仅约束 `watchfaces/reference-face-configurable/` 中的耐力仪表·可配，路径均以该**应用根目录**为基准，明确注明仓库根的除外。[返回仓库技能路由](../../../docs/garmin-dev-project.md)。项目使用 `athitupakan/garmin-dev-skills` 的 `garmin-dev` 技能；以下现场证据和项目流程优先于上游通用默认值。本说明独立于技能安装目录保存，技能更新时不会被安装器覆盖。

## 环境与实际入口

- 当前是 macOS arm64，SDK 9.2.0 / Java 17。构建、运行和定向测试沿用 `scripts/build.py`，目标配置沿用 `scripts/configure.py`；不重建工程、不引入第二套构建实现。
- SDK、设备包和仓库外签名密钥的位置见 `README.md`。保留现有签名身份，不重新安装工具链、生成另一把密钥或发起登录；密钥不复制或链接进仓库。
- 可选本机技能实体在仓库根 `.agents/skills/garmin-dev/`（相对应用根为 `../../.agents/skills/garmin-dev/`）；OMP入口为仓库根 `.omp/skills/garmin-dev`（`../../.omp/skills/garmin-dev`），指向同一份内容。仓库根 `.hermes/`、`skills-lock.json` 分别为 `../../.hermes/`、`../../skills-lock.json`。这些安装目录及文件不属于应用基线，构建不依赖它们。当前运行时是OMP，不能直接套用Claude的插件命令、环境变量或后台参数。
- 上游POSIX脚本默认从manifest取第一个目标（本表盘为`enduro`），密钥默认置于调用目录`developer_key`，产物名也采用其通用默认值，并按安装目录日期自动选择SDK。上述默认值不适用于本表盘，因此项目构建以以下命令取代上游的通用build/run/release/push调度。
- 以下命令从应用根 `watchfaces/reference-face-configurable/` 调用。若从仓库根运行，使用 `python3 watchfaces/reference-face-configurable/scripts/build.py` 并沿用相同参数；无需包装脚本或 `--face`。`--run`仅在官方模拟器已运行时使用；不在技能切换时关闭模拟器、清理其他应用或安装到手表。

```sh
# Enduro 3 真机Release构建，生成 bin/reference-face-configurable-enduro3.prg
python3 scripts/build.py --device enduro3

# Enduro 3 官方模拟目标构建
python3 scripts/build.py --device enduro3 --simulator

# 仅在需要验收行为变更且模拟器已经运行时使用
python3 scripts/build.py --device enduro3 --run
python3 scripts/build.py --device enduro3 --test --run

# 覆盖manifest全部目标的官方商店export
python3 scripts/build.py --package 1.0.1
```

商店`.iq`沿用同一入口的`--package VERSION`，使用官方`-e -r`覆盖全部manifest目标，版本参数用于产物及商店资料，输出和SHA报告位于`artifacts/release-VERSION/`。打包、提交审核和公开上架分别记录，不能互相替代；只有任务授权时操作商店。现行开发者后台为`https://apps-developer.garmin.com/`，遇到登录或新协议由用户在官方界面处理，不读取凭据。本机真实设备传输继续使用OpenMTP/Kalam，写入后独立回读；截图按当前macOS窗口取证。

商店状态仅作历史回读：2026-10-22至2026-10-23记录确认1.0.1（内部2）程序包及图文保存成功，当时待审核、尚未公开上架；详见 `docs/release-1.0.1.md`。目录调整未重新查询商店，不能把该历史状态当作当前状态。

API问题先读技能的`references/connect-iq-docs/index.md`及对应章节。缓存只作为检索入口；精确签名、API版本、设备支持与当前SDK的`doc/Toybox`、官方设备包及官方网页核对。缓存中的“不支持”清单和观察性结论不直接当成设备事实。

## 设备与构建

- watchFace内存按官方设备`compiler.json`的`appTypes[type=watchFace].memoryLimit`取值；FR45为49,152字节（48 KiB）、API1.4.5。图形池不能与应用内存混算，不采用统一128 KB的假设。
- 对照 `docs/compatibility.json`；开发 target、营销型号、地区别名和真机验收范围分别记录。国际版 45S 映射仍无最终证据，不从技能初筛结果扩张支持范围。
- 40个官方target仅是本表盘的矩阵，包含新增的5个fēnix 6系列目标；不是仓库内其它表盘的默认能力或支持范围。fēnix 6系列复用240/260/280圆屏资源与MIP路径，API3.4下保留机上设置，系统周跑量和日出仍按已有能力检测处理。各表盘独立维护manifest、UUID、源码、资源、测试、脚本、文档、`bin/`和`artifacts/`；SDK、设备包与仓库外签名密钥可以共用。
- `python3 scripts/build.py --device enduro3` 生成真机 PRG。`--simulator` / `--run` / `--test` 使用官方 `<device>_sim`；920XT 真机字体方向编码不能用于模拟器。
- 构建、定向测试、模拟器画面、文件侧载、真机显示和续航分别验收。技能安装或脚本读取设备包不构成表盘重新编译或真机验证。

## 数据、中文与设置

- 沿用 `FaceData`、`FaceCalendar`、`FaceSettings` 的现有契约。支持但缺数据显示 `--`，不支持明确标识；缺数据时不填假位置、假天气或样本健康值，也不引入后台网络服务。
- 天气有效期3小时、心率5分钟、身体电量30分钟；真实零值与缺值分开，检查未来时间、时钟回拨及本地换日。天气温度、体感沿用SDK摄氏值并明确标°C，不随系统华氏偏好转换。系统周跑量与本地近7日已保存跑步使用不同统计口径，不相互替代。
- 中文位图字形和授权由 `scripts/generate-fonts.py`、`resources-fonts/OFL.txt`、`docs/font-assets.json` 管理；农历使用本地 ICU 生成表，覆盖2000–2099，范围外明确缺值。不要改为只依赖海外固件系统中文字体。
- [官方getSettingsView](https://developer.garmin.com/connect-iq/api-docs/Toybox/Application/AppBase.html#getSettingsView-instance_function)自API3.2.0可用于表盘。当前`ReferenceFaceApp.getSettingsView()`提供菜单，`FaceSettings.save()`写入应用属性并触发刷新；不能把侧载说成只支持编译默认值。
- 保持现有属性含义，不引入旧值迁移或新的默认值分支。机上菜单和手机设置共用属性；周目标0–1000km、精度0.01km，0表示未设目标。
- 保存、取消、越界拒绝、重启保留已有模拟器证据；手机属性编辑器仍有钥匙串认证缺口，新版真机设置尚未直接验收。这三项不得混写。

## 功耗与安装身份

- 已有MIP休眠隐藏秒、AMOLED稀疏显示及换位、分钟/15分钟/5分钟缓存。只有出现相应真机症状并定位原因后才修改生命周期逻辑，不添加推测性恢复逻辑。
- 稀疏亮像素截图不等于官方烧屏预算证明、硬件功耗测量或续航结论；用户目前仅有 Enduro 3，不能要求其用 FR965 做已安排的续航测试。
- 当前可配置版名称“耐力仪表·可配”，UUID `9d182df86c2d48938ce2c9795678f668`，真机文件前缀 `reference-face-configurable-`。后续更新维持该身份。
- 旧“耐力仪表”UUID `b9b8804748954f99be17e7c4483b4db3` 按用户要求保留；不覆盖、删除或迁移其数据。`OUT.BIN` 只回读，不反向写入。
- 文件写入后独立回读核对 SHA-256；并存安装还需比对旧应用登记数据。本机历史证据 `docs/verification/enduro3-coexist-installation.json` 不随应用基线提交；传输成功不能当作拔线后的真机显示已通过。
- SDK 9.2.0 的已知测试摘要解析异常使 `monkeydo` 在用例 PASS 后仍退出1；保留原始日志、用例结果和退出码，不加吞错或强制成功逻辑。本机诊断 `docs/verification/sdk-9.2.0-test-runner.txt` 不随基线提交；可移植的结果摘要见 `docs/review-commit-2026-10-22.md`。

## 上游更新

仓库根 `../../skills-lock.json` 记录上游来源和内容哈希，不包含项目入口补丁，也不属于应用构建依赖。更新时保留技能入口指向仓库根 `../../docs/garmin-dev-project.md` 的路由，再按所选表盘读取专属约束，并重新核验与上游的差异；随后验证OMP发现、文档索引和受影响目标的真实构建。安装技能不授权发布、删除旧表盘、重装手表或改动模型配置。
