# 1.0.1 时间裁切修复与发布记录

2026-10-22。用户报告上半部分小时、分钟大字被遮挡，并要求修复后更新GitHub和Connect IQ。

## 修复与原因

1.0.0的Enduro 3主时间宽228px，从圆屏顶部34px开始绘制；该高度的圆屏横向空间约183px，左右数字因此被屏幕边缘裁切。原有字体放大时没有同步调整这项几何约束。

1.0.1将Enduro 3日常/极简时间字库从84px改为72px，日常纵坐标从34px改为46px；其余圆屏字体组按同一约束缩小。各时间字形仍为等宽数字。训练密集布局、AMOLED常显和矩形屏专用时间字体保持现有尺寸。实际字高与标称字号不同；Enduro 3主时间行高57px，数字最大字高约56px。

改动集中在`source/ReferenceFaceView.mc`、`scripts/generate-fonts.py`、八组`resources-fonts/*/time.*`与字体元数据。没有修改数据来源、属性含义、应用UUID或签名身份。

## 实际验证

- 对生成后的BMFont像素执行几何检查：11种屏幕规格 × 日常/极简/训练历史三种布局 × 全天1,440个时间组合，共47,520组，未发现主时间像素越过屏幕边界。这是静态像素几何证据，不是47,520次模拟器运行。
- Enduro 3官方模拟器：日常`23:58`、训练`23:58`及极简`23:59`实际显示完整；训练同时显示六个指标、历史图和心率区，没有新增遮挡。
- FR55（208px圆屏）和FR965（454px AMOLED）官方模拟器：日常`23:58`四个数字完整，日期及下方信息位正常显示。
- 三个目标均通过项目入口`python3 scripts/build.py --device DEVICE --run`构建和运行，最终正常停止，未出现运行时错误。
- 本轮没有运行全仓测试，没有新增真机安装、手机设置链路、续航或AMOLED烧屏预算验收。

截图和详细记录位于本地`artifacts/release-1.0.1/`，其中`clock-geometry.json`保存逐规格的组合数和像素边界结果。

## 商店包

命令：`python3 scripts/build.py --package 1.0.1`，环境为Java 17 / Connect IQ SDK 9.2.0。

- 文件：`artifacts/release-1.0.1/reference-face-configurable-1.0.1.iq`
- 大小：2,048,457字节
- SHA-256：`f071eefec0b1942ab4ae7363bec91e42cd4eb409baa3357d5e188e6cb1a2e392`
- 35个manifest目标由官方export统一编译，日志为`56 OUT OF 56 DEVICES BUILT`、`BUILD SUCCESSFUL`，退出0。
- 官方SDK `VerifyingUtils.verifyIqFile(File, null)`实际返回`SDK_IQ_SIGNATURE_VALID=true`，进程退出0。
- 应用UUID继续使用`9d182df86c2d48938ce2c9795678f668`；密钥继续留在仓库外。

编译器原有类型推断、旧属性API弃用和启动图标尺寸警告保留。1.0.0记录中的旧硬件API排除规则继续适用；编译支持不代表相应真机已经验收。

## 发布状态

源码修复已提交为`439fd2f`并推送到[GitHub main](https://github.com/Zixiaobowen/garmin-face-it)。Connect IQ已接受1.0.1程序包：官方校验HTTP 200，版本保存HTTP 204；页面及独立metadata回读均确认签名验证成功。开发者预览显示**1.0.1（内部2）**，应用仍为“待处理”，尚未公开上架。

商店App ID为`aa58871d-46ed-49f2-9c18-72efdaa7eb50`，沿用现有应用。[开发者预览页](https://apps-developer.garmin.com/zh-CN/apps/aa58871d-46ed-49f2-9c18-72efdaa7eb50)当前仅所属账户可见。

2026-10-23再次通过当前已登录的Chrome官方“编辑详细信息”表单提交：中英文1.0.1更新说明、500×500封面及两种语言1440×720 hero均已填写，已有三张新截图正常加载。所有图片均符合表单尺寸和大小要求，必填项无校验错误，联系邮箱及其它既有选项保持原值。保存PUT仍返回**HTTP 403 / Cloudflare**，响应为“Attention Required! / Sorry, you have been blocked”，Ray ID为`a4ed487c68cc0d79`。

独立metadata回读仍为旧中英文1.0.0更新说明；新开官方预览确认封面仍是旧图。与此同时，**三张新版截图已在商店预览中显示**：Enduro 3日常、Enduro 3训练、FR55日常均显示完整的23:58。不能再把整个图文状态概括为“全部旧图”，也不能把截图已显示算作文案、封面及hero保存成功。官方表单`garmin-listing-live`保留未保存内容，待站点解除拦截后继续提交与回读。本轮没有再次上传程序包或截图，没有绕过安全拦截。

本地证据：`artifacts/release-1.0.1/publication-receipt.json`、`publication-receipt.html`、`listing-attempt-2026-10-23.json`、`store-preview-2026-10-23.png`及`assets/`。程序包接受、截图展示、其它图文保存、公开上架、真机验收是不同状态；2026-10-22的构建与模拟器记录未在本轮重跑。
