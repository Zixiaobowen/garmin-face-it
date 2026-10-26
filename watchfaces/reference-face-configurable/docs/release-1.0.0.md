# 1.0.0 发布记录

2026-10-22。源码仓库：[Zixiaobowen/garmin-face-it](https://github.com/Zixiaobowen/garmin-face-it)，公开分支`main`。发布准备已加入官方商店导出入口和中英文隐私说明；本轮同步商店提交回执，应用运行源码、字体和现有应用UUID未修改。

当前状态：**1.0.0已成功提交Connect IQ审核，后台显示“应用程序待处理”，尚未公开上架**。预览页明确说明批准前仅开发者本人可见，并提示审批可能最多需要3天；这是平台提示，不是通过时间承诺。

## 商店提交回执

- 商店App ID：`aa58871d-46ed-49f2-9c18-72efdaa7eb50`。这是商店分配的ID，与下方manifest UUID不同。
- [开发者预览页](https://apps-developer.garmin.com/zh-CN/apps/aa58871d-46ed-49f2-9c18-72efdaa7eb50)：当前仅已登录的所属账户可见。
- 版本：`1.0.0`，内部版本`1`；开发者显示名`Zixiaobowen`；免费。
- 已回读简体中文名称“耐力仪表·可配”和英文名称“Endurance Dial Configurable”、对应描述及更新说明、500px图标、三张截图、隐私政策和源码链接。
- 已读取实际兼容设备列表；商店显示48组设备名称，部分条目合并地区别名。这不等同于48款真机验收。没有启用自动新增兼容设备。
- 公开联系邮箱由用户在官方表单填写；本记录不复制该地址。

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

实际运行了上述完整导出命令，独立计算的SHA-256与报告一致。包内UUID、目标映射、清单及签名材料已检查，manifest的RSA-4096/SHA-256签名验证通过。本轮通过Java 17调用SDK 9.2.0自带的`com.garmin.connectiq.common.signing.VerifyingUtils.verifyIqFile(File, null)`，进程退出0，实际输出`SDK_IQ_SIGNATURE_VALID=true`。这属于SDK内置验签，独立实现的整包验签仍未完成。

上传页曾同时显示“状态：已验证”和“签名检查失败”。保留该观察，没有重签或改包；最终提交成功并进入待审核。该网页提示的成因尚未确认。[2026-10-15论坛回复](https://forums.garmin.com/thread/2071720?ContentTypeID=1)报告过类似现象，但这只是其他用户的报告，不是Garmin对本包或根因的确认。

空版本、含路径的版本及与模拟器、单目标、全目标选项冲突的5组参数均以退出码2拒绝。未增加永久测试，未重跑全仓测试。此前的模拟器及真机证据见[首次提交审查](review-commit-2026-10-22.md)；本阶段没有新增表盘渲染、手机设置传输、真机显示或续航验收。

## 商店资料与隐私

中英文名称、简介、完整描述、初版说明和隐私文案已保存在本地发布目录的`listing.md`及`listing.json`。应用界面主要为中文；英文商店文案不表示已提供英文UI。公开[隐私说明](privacy.md)和[问题反馈入口](https://github.com/Zixiaobowen/garmin-face-it/issues)可用于提交资料。

素材包括500×500商店图标、三张真实模拟器截图和1440×720 hero。图片保留原始屏幕数值，裁掉桌面和表壳；所有图片为sRGB RGB PNG。实时表单确认封面图像不超过300KB、截图不超过150KB、hero不超过2048KB；本次素材符合这些限制。中英文hero分别上传，图标和三张截图已在提交后的预览页显示。标题上限50字符，描述和更新说明各4000字符。模拟数据不代表实际佩戴记录。字体继续使用原有Noto Sans SC，保留[SIL OFL](../resources-fonts/OFL.txt)。没有增加代码许可证。

## 审核后的接续

后续在开发者后台回读审核状态。只有批准且未登录的公开商店页面可访问后，才记录为公开上架；若退回，保留原始审核理由，再按具体问题处理。SDK导出、上传、提交审核、公开上架和真机验收分别记录。后续版本继续使用现有签名身份和manifest UUID。

本阶段没有上传GitHub Release附件。商店预览截图`artifacts/release-1.0.0/store-submitted-preview.png`、产物、日志和机器回执保留在本机；公开仓库包含可重建源码、必要说明及[交接记录](codex-handoffs/2026-10-22-publication.md)。最终Git SHA由远端`main`和本机`.local/publish-receipt.json`记录。

## 官方依据

- [提交流程](https://developer.garmin.com/connect-iq/submit-an-app/)
- [审核规则正文](https://developer.garmin.com/connect-iq/articles/app-review-guidelines/Overview.html)
- [商店图片规范](https://developer.garmin.com/brand-guidelines/connect-iq/)
- [2025-11-20开发者后台迁移公告](https://forums.garmin.com/developer/connect-iq/b/news-announcements/posts/changes-to-the-connect-iq-store)

以上页面于2026-10-22核对；本机SDK的Compiler Options同时确认`-e`导出和`-r`发布编译契约。
