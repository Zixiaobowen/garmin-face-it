# 2026-10-22 公共仓库与商店发布交接

## repo、branch、当前目标

- repo：`garmin-face-it`，https://github.com/Zixiaobowen/garmin-face-it ，visibility为public。
- 本地branch：`feat/readable-typography`；远端公开branch：`main`。不要为了分支名不同而重置或改写历史。
- 目标：公开完整应用源码并提交佳明商店。本阶段完成公开仓库及必要发布准备；官方SSO登录是外部阻塞，商店未上传、未创建草稿、未提交审核、未上架。
- 本交接与发布脚本、隐私说明及发布记录同次提交推送；最终SHA在远端`main`与本机`.local/publish-receipt.json`回读，不在提交自身中循环写入自身SHA。

## 已完成事项

- 审查唯一基线提交`1ba2a2b31db3d1e62f94bae6e8ed35f54d937527`的198个reachable objects、188个跟踪文件，未发现公开阻断的凭据、真实健康记录或私人公司资料；创建public仓库并首次推送成功。
- 在既有`scripts/build.py`新增`--package VERSION`，通过官方SDK的`-e -r`导出；沿用已有UUID、仓库外密钥和目标配置。
- 生成`artifacts/release-1.0.0/reference-face-configurable-1.0.0.iq`，2,062,886字节，SHA-256为`0b3433a5e7675a3fee1646a8a98dc0a6e6762dbf0937c7f15706497cc63505c0`。
- 完成中英文商店文案、支持与隐私说明、500px图标、三张真实模拟器截图、1440×720 hero。源码侧公开隐私文档为`docs/privacy.md`。
- 用同一个浏览器页先检查旧上传入口，再普通导航到现行https://apps-developer.garmin.com/。最终为Garmin SSO Portal登录表单，显示“电子邮件地址*”“密码*”；页面已保留，未读取凭据、处理验证码或操作登录。

## 已调查或修改的文件

公开修改：`scripts/build.py`、`README.md`、`docs/garmin-dev-project.md`、`docs/privacy.md`、`docs/release-1.0.0.md`、本交接。

本地发布资料：`artifacts/release-1.0.0/listing.json`、`listing.md`、`assets/`、`package-report.json`、`package-validation.json`、`package.log`、`publication-receipt.html`；最终机器回执为`.local/publish-receipt.json`。这些本地产物不强制加入Git。

## 已运行命令和结果

- `JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home python3 scripts/build.py --package 1.0.0`：退出0，官方日志`56 OUT OF 56 DEVICES BUILT`、`BUILD SUCCESSFUL`。
- 包内清单：35个manifest目标均有硬件记录，共56个硬件编号；9个API 1.3.1编号被SDK明确排除，见公开发布记录。
- 独立SHA-256与导出报告一致；manifest签名验证通过，但整包未完成独立验签。按用户收束要求停止签名实现调查，不将临时验签方法失败视为包无效。
- 空/非法版本和三种互斥模式共5组CLI检查均退出2。
- 5个图片文件的实际尺寸、字节数、RGB和ICC配置检查通过；截图裁切与原图已目视检查。
- 没有重跑全仓测试或新增真机验收。GitHub的最终提交与推送、远端SHA、公开隐私URL回读及HTML验收以最终本机回执记录为准。

## 已知失败、风险和阻塞

- 官方SSO尚未登录，Hermes安全凭据库也没有Garmin登录。账户资格、新开发者协议、上传表单字段、商店包校验及审核状态未知。
- 最新观察URL为`https://sso.garmin.com/portal/sso/zh-CN/sign-in?clientId=APPS_LIBRARY&service=https://apps-developer.garmin.com/api/auth/login?returnTo=/zh-CN/developer/dashboard`；标题`Garmin SSO Portal`，自动化标签名`garmin-publish`。
- SDK现有类型推断、旧属性API弃用、启动图标尺寸警告保留。既有测试runner摘要异常、手机设置传输、新版真机显示及续航缺口不能混写成通过。
- 真实商店App ID为空；没有草稿或上传回执。SDK导出、上传、审核、公开上架是不同状态。

## 用户偏好、限制和禁改区域

中文交付，区分事实和未验证项。当前只收束必要发布工作，不新增功能、不扩大应用代码修改、不继续逆向签名实现。保留68个本地历史文件、现有字体OFL及旧表盘；不全量暂存、清理、重置、强推或重新生成签名身份。当前应用UUID为`9d182df86c2d48938ce2c9795678f668`。

不要读取、输出或复制cookies、token、密码；不要在shell、browser工具或聊天中接收/输入密码和验证码。登录由用户官方界面或安全密码库处理；新协议由用户审阅。保留`garmin-publish`供用户接管。

## 下一步

1. 用户在Chrome切换到标题“Garmin SSO Portal”的保留标签页，或直接打开现行开发者后台，自己完成登录。只需告知“已登录”，不要发送凭据。
2. 已登录后重新观察现有页面和实际表单；若出现新开发者协议，停在协议页交用户处理。
3. 按用户既有上传授权，用本地`.iq`、`listing.json`及`assets/`填写实际字段；核对免费选项、隐私URL、截图限制和包校验结果。
4. 回读准确App ID、草稿/审核状态和链接。仅以实际成功回执更新商店状态；审核通过并公开可见前不能称已上架。
5. 更新发布回执与本交接；新增问题只按实际失败定位，不继续扩展本阶段的签名分析或应用功能。

## 可粘贴恢复提示

> 继续garmin-face-it的商店发布。先读docs/codex-handoffs/2026-10-22-publication.md、docs/release-1.0.0.md和.local/publish-receipt.json；公共仓库已建立，最终SHA以回执/远端为准。官方SDK已导出1.0.0包，35目标、56硬件编号，SHA为0b3433a5e7675a3fee1646a8a98dc0a6e6762dbf0937c7f15706497cc63505c0。商店尚未上传，阻塞是现行apps-developer.garmin.com的官方SSO登录。保留的garmin-publish页供用户接管，不读取凭据或处理验证码。用户登录后沿既有上传授权读取真实表单；遇新协议交用户。使用artifacts/release-1.0.0/中的包、listing和assets，严格区分上传、草稿、审核、上架。保留本机历史和旧表盘，不扩功能、不逆向签名、不重跑已经适用的检查。
