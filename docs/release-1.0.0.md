# 1.0.0 发布准备记录

2026-10-22。源码仓库：[Zixiaobowen/garmin-face-it](https://github.com/Zixiaobowen/garmin-face-it)，公开分支 `main`。本次提交增加官方商店导出入口和中英文隐私说明；应用运行源码、字体和现有应用UUID未修改。

当前状态：官方SDK已导出签名`.iq`，商店素材已准备；**未上传、未创建草稿、未提交审核、未上架**。现行[开发者后台](https://apps-developer.garmin.com/)跳转Garmin SSO登录页；上传表单、账户资格及协议状态尚未确认。

## 导出结果

```sh
python3 scripts/build.py --package 1.0.0
```

环境：Python 3.11+、Java 17、Connect IQ SDK 9.2.0、官方设备定义和仓库外现有签名密钥。脚本调用官方`-e -r`导出，版本用于文件名及商店资料，不添加自造manifest字段。生成配置、编译日志与报告均留在`artifacts/release-1.0.0/`，不纳入源码。

- 文件：`artifacts/release-1.0.0/reference-face-configurable-1.0.0.iq`
- 大小：2,062,886字节
- SHA-256：`0b3433a5e7675a3fee1646a8a98dc0a6e6762dbf0937c7f15706497cc63505c0`
- 应用UUID：`9d182df86c2d48938ce2c9795678f668`
- 编译器退出码：0；日志为`56 OUT OF 56 DEVICES BUILT`、`BUILD SUCCESSFUL`
- 35个manifest目标均有对应包内硬件记录，共56个硬件编号；这不等同于56款真机验收。

官方SDK忽略了以下API 1.3.1硬件编号，因为项目最低API为1.4。这些编号不包含在本次包内，不能据研究矩阵宣称可安装：

|目标|未导出的硬件编号|
|---|---|
|fr230|006-B2313-00|
|fr235|006-B2396-00、006-B2653-00、006-B2733-00|
|fr630|006-B2310-00、006-B2311-00|
|fr920xt|006-B2130-00、006-B2131-00、006-B2132-00|

导出仍有容器类型推断、旧属性API弃用和部分启动图标缩放警告；没有隐藏警告或修改SDK。重复导出可能受SDK时间戳影响，不承诺逐字节一致。

## 实际验证与边界

实际运行了上述完整导出命令，独立计算的SHA-256与报告一致。包内UUID、目标映射、清单及签名材料已检查；manifest的RSA-4096/SHA-256签名已验证，但**整包未完成独立验签**。尚未获得Garmin商店二进制校验或审核结果，不根据临时验签方法推断包无效。

空版本、含路径的版本及与模拟器、单目标、全目标选项冲突的5组参数均以退出码2拒绝。未增加永久测试，未重跑全仓测试。此前的模拟器及真机证据见[首次提交审查](review-commit-2026-10-22.md)；本阶段没有新增表盘渲染、手机设置传输、真机显示或续航验收。

## 商店资料与隐私

中英文名称、简介、完整描述、初版说明和隐私文案已保存在本地发布目录的`listing.md`及`listing.json`。应用界面主要为中文；英文商店文案不表示已提供英文UI。公开[隐私说明](privacy.md)和[问题反馈入口](https://github.com/Zixiaobowen/garmin-face-it/issues)可用于提交资料。

素材包括500×500商店图标、三张真实模拟器截图和1440×720 hero。图片保留原始屏幕数值，裁掉桌面和表壳；所有图片为sRGB RGB PNG。三张截图均低于150,000字节，实时表单的截图限制仍待登录后核对。模拟数据不代表实际佩戴记录。字体继续使用原有Noto Sans SC，保留[SIL OFL](../resources-fonts/OFL.txt)。没有增加代码许可证。

## 登录后的接续

在保留的官方“Garmin SSO Portal”标签页登录；页面显示电子邮件地址和密码为必填项。凭据只在官方界面输入，不通过聊天传递。若出现新开发者协议，由账户持有人审阅处理。登录后重新读取实际上传表单，再使用已准备的`.iq`、文案和图片；准确区分文件上传、草稿、提交审核和公开上架，并回读App ID与实际状态。

本阶段没有GitHub Release附件或商店App ID。产物、图片、日志及机器回执留在本机，公开仓库包含可重建源码、必要说明及[本阶段交接](codex-handoffs/2026-10-22-publication.md)。最终Git SHA由远端`main`和本机`.local/publish-receipt.json`记录。

## 官方依据

- [提交流程](https://developer.garmin.com/connect-iq/submit-an-app/)
- [审核规则正文](https://developer.garmin.com/connect-iq/articles/app-review-guidelines/Overview.html)
- [商店图片规范](https://developer.garmin.com/brand-guidelines/connect-iq/)
- [2025-11-20开发者后台迁移公告](https://forums.garmin.com/developer/connect-iq/b/news-announcements/posts/changes-to-the-connect-iq-store)

以上页面于2026-10-22核对；本机SDK的Compiler Options同时确认`-e`导出和`-r`发布编译契约。
