# ZSvirt Time 1.0.0 发布记录

2026-10-26。用户明确授权提交并推送到GitHub `main`，并在Garmin Connect IQ发布本表盘。当前已完成商店包、SDK验签和发布版模拟器验收；商店提交流程正在进行，本记录将按实际回执更新。

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

名称统一为 `ZSvirt Time`，准备简体中文和英文描述、初版更新说明、[公开隐私说明](privacy.md)、[源码](https://github.com/Zixiaobowen/garmin-face-it/tree/main/watchfaces/zsvirt-time)与[问题反馈](https://github.com/Zixiaobowen/garmin-face-it/issues)。不添加健康、天气、位置等实际不存在的功能，不宣称已经测量续航或通过真机验收。

商店图标500×500、实际屏幕截图280×280、中英文hero各1440×720，均为sRGB RGB PNG。图标外围为浅色背景，表盘画面来自实际模拟器截图，未修改显示内容。对应文件、SHA与字节数记录在本地发布目录 `asset-report.json`；各文件均低于旧后台已知的300KB图标、150KB截图、2048KB hero限制，提交时按当前表单复核。

## 验收边界

构建、验签、模拟器运行、上传、提交审核、公开上架和真机安装分别记录。当前没有真机安装或续航测量。包和原始日志保留在本机 `artifacts/release-1.0.0/`，不纳入Git；公开仓库保留源码、原始Logo、构建脚本、隐私说明和本记录。

## 官方依据

- [Connect IQ提交流程](https://developer.garmin.com/connect-iq/submit-an-app/)
- [审核规则](https://developer.garmin.com/connect-iq/articles/app-review-guidelines/Overview.html)
- [商店图片规范](https://developer.garmin.com/brand-guidelines/connect-iq/)

以上官方页面于2026-10-26核对。当前开发者后台为 `https://apps-developer.garmin.com/`。
