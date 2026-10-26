# ZSvirt Time 1.0.0 发布记录

2026-10-26。源码已提交并推送到GitHub `main`；1.0.0已由Garmin接受提交，当前状态为 `PENDING`（应用程序待处理）。页面仅账户本人可预览，尚未公开上架。保存后的官方元数据确认签名检查通过。

## 发布包与应用身份

- 应用名称：ZSvirt Time；版本：1.0.0；免费。
- Manifest UUID：`cb51f19636e64ae1b979bfd8bf070e31`。
- 支持目标：`enduro3`；280×280 MIP；没有开启自动扩展设备支持。
- 导出命令：`python3 watchfaces/zsvirt-time/scripts/build.py --package 1.0.0`，Connect IQ SDK 9.2.0 / Java 17。
- 包：`artifacts/release-1.0.0/zsvirt-time-1.0.0.iq`，8,498字节。
- SHA-256：`fcc32c3b71745b36085a64d12e52c070aa9c2bb88ac1bb175f13631f778cee48`。
- 官方export输出 `1 OUT OF 1 DEVICES BUILT`、`BUILD SUCCESSFUL`，退出0。
- 调用官方 `VerifyingUtils.verifyIqFile(File, null)`，实际输出 `SDK_IQ_SIGNATURE_VALID=true`，退出0。

签名继续使用仓库外开发者密钥；没有生成或复制新密钥。`.iq`是SDK带签名封装的包，不能直接按普通ZIP读取。

## 实际验收

`python3 watchfaces/zsvirt-time/scripts/build.py --device enduro3 --release --run` 已构建并实际运行，显示完整ZSvirt Logo和13:59时间；截图后正常关闭本次独占模拟器，编译及runner均退出0。原图保存在本地发布目录 `release-simulator.png`。

复用本次开发阶段3项时制边界测试PASS的证据；SDK测试runner退出1的已记录差异保持。没有修改表盘运行代码，不重复运行已通过的时制用例；没有运行全仓库测试或其它设备构建。

5组错误打包参数（空版本、含路径版本、与单设备/模拟器/测试冲突）均以退出码2明确拒绝。

## 商店资料

名称统一为 `ZSvirt Time`，已保存简体中文和英文描述、初版更新说明、[公开隐私说明](privacy.md)、[源码](https://github.com/Zixiaobowen/garmin-face-it/tree/main/watchfaces/zsvirt-time)与[问题反馈](https://github.com/Zixiaobowen/garmin-face-it/issues)。不添加健康、天气、位置等实际不存在的功能，不宣称已经测量续航或通过真机验收。联系地址沿用同一账户既有应用的公开支持邮箱，已回读确认一致；不在本记录复制地址。

商店图标500×500、实际屏幕截图280×280、中英文hero各1440×720，均为sRGB RGB PNG。图标外围为浅色背景，表盘画面来自实际模拟器截图，未修改显示内容。对应文件、SHA与字节数记录在本地发布目录 `asset-report.json`；已按当前表单的300KB图标、150KB截图、2048KB hero限制提交并成功保存。

## GitHub与商店回执

- 功能提交：[`64ee8da`](https://github.com/Zixiaobowen/garmin-face-it/commit/64ee8da)，已快进合入并推送 `main`，GitHub分支API已回读确认。发布状态与验收回执作为后续文档提交同步。
- 商店应用ID：`2702e86b-ba01-44ed-9d5a-9b29777945f4`；与manifest UUID分别记录。
- [中文商店预览](https://apps-developer.garmin.com/zh-CN/apps/2702e86b-ba01-44ed-9d5a-9b29777945f4) · [English preview](https://apps-developer.garmin.com/en-US/apps/2702e86b-ba01-44ed-9d5a-9b29777945f4)。审核通过前仅账户本人可见。
- 2026-10-26 06:13 UTC发起唯一一次创建提交，官方创建接口返回HTTP 200；版本1.0.0，内部版本1。
- 独立回读应用数据与编辑元数据均为HTTP 200：状态 `PENDING`，最终 `signatureCheckSuccessFul=true`；中英文标题、完整说明与更新说明逐项匹配，两张hero与一张截图已保存，封面和截图在实际中英文页面正常显示。
- 兼容范围仅 `Enduro™ 3`（部件号 `006-B4575-00`）；自动扩展设备支持关闭，免费、非Beta、无额外权限。
- 页面提示审核可能最多需要3天；这是平台提示，不是完成时限承诺。公开上架仍需后续确认Garmin审核结果。

上传预校验曾同时显示“已验证”和“签名检查失败”，对应 `iqFiles/validate` 响应中的签名标记为false；本地官方SDK验签为true。正常提交成功后，官方保存元数据中的同一签名标记为true。未改包、未改后台返回值，也未绕过提交校验；初始标记差异的原因未确认。

可复核字段见 [商店提交回执](verification/store-submission-1.0.0.json)。中英文页面截图保留在本地发布目录 `store-preview-zh.webp`、`store-preview-en.webp`；该目录按既有规则不纳入Git。

## 验收边界

构建、验签、模拟器运行、上传、提交审核、公开上架和真机安装分别记录。当前没有真机安装或续航测量。包和原始日志保留在本机 `artifacts/release-1.0.0/`，不纳入Git；公开仓库保留源码、原始Logo、构建脚本、隐私说明和本记录。

## 官方依据

- [Connect IQ提交流程](https://developer.garmin.com/connect-iq/submit-an-app/)
- [审核规则](https://developer.garmin.com/connect-iq/articles/app-review-guidelines/Overview.html)
- [商店图片规范](https://developer.garmin.com/brand-guidelines/connect-iq/)

以上官方页面于2026-10-26核对。当前开发者后台为 `https://apps-developer.garmin.com/`。
