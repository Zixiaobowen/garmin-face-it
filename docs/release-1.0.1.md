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

新版图文尚未完成保存：三张新截图的上传分别返回HTTP 201，metadata已列出新素材ID；但最终资料保存PUT返回**HTTP 403 / Cloudflare**，正文为“Sorry, you have been blocked”。独立打开的预览仍显示旧截图、旧封面和1.0.0更新说明，不能把素材上传成功算作图文已更新。没有绕过该拦截，也没有重复上传1.0.1。

中英文更新说明、新封面、中英文hero及三张截图已在本地准备完成，原更新表单保留。待网站解除拦截后，只需保存现有版本的图文并回读预览，不应再增加一个相同程序版本。联系邮箱及其它既有设置保持原值；不把该地址复制到回执。

本地证据：`artifacts/release-1.0.1/publication-receipt.json`、`publication-receipt.html`、`store-preview.png`、`assets/`。程序包接受、商店图文保存、公开上架、真机验收是不同状态。
