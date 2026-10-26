# 2026-10-22 公共仓库与商店发布交接

## repo、branch、当前目标

- repo：`garmin-face-it`，https://github.com/Zixiaobowen/garmin-face-it ，visibility为public。
- 本地branch：`feat/readable-typography`；远端公开branch：`main`。不要为了分支名不同而重置或改写历史。
- 目标：公开完整应用源码并提交佳明商店。公共仓库已建立；1.0.0已成功提交审核，后台显示“应用程序待处理”，尚未公开上架。
- 本交接与发布脚本、隐私说明及发布记录同次提交推送；最终SHA在远端`main`与本机`.local/publish-receipt.json`回读，不在提交自身中循环写入自身SHA。

## 已完成事项

- 审查唯一基线提交`1ba2a2b31db3d1e62f94bae6e8ed35f54d937527`的198个reachable objects、188个跟踪文件，未发现公开阻断的凭据、真实健康记录或私人公司资料；创建public仓库并首次推送成功。
- 在既有`scripts/build.py`新增`--package VERSION`，通过官方SDK的`-e -r`导出；沿用已有UUID、仓库外密钥和目标配置。
- 生成`artifacts/release-1.0.0/reference-face-configurable-1.0.0.iq`，2,062,886字节，SHA-256为`0b3433a5e7675a3fee1646a8a98dc0a6e6762dbf0937c7f15706497cc63505c0`。
- 完成中英文商店文案、支持与隐私说明、500px图标、三张真实模拟器截图、1440×720 hero。源码侧公开隐私文档为`docs/privacy.md`。
- 已接入用户实际登录的Chrome页面，创建公开开发者显示名`Zixiaobowen`，上传1.0.0包及中英文资料。公开联系邮箱由用户在官方表单填写；最终提交成功，商店App ID为`aa58871d-46ed-49f2-9c18-72efdaa7eb50`。

## 已调查或修改的文件

公开修改：`scripts/build.py`、`README.md`、`docs/garmin-dev-project.md`、`docs/privacy.md`、`docs/release-1.0.0.md`、本交接。

本地发布资料：`artifacts/release-1.0.0/listing.json`、`listing.md`、`assets/`、`package-report.json`、`package-validation.json`、`package.log`、`publication-receipt.html`；最终机器回执为`.local/publish-receipt.json`。这些本地产物不强制加入Git。

## 已运行命令和结果

- `JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home python3 scripts/build.py --package 1.0.0`：退出0，官方日志`56 OUT OF 56 DEVICES BUILT`、`BUILD SUCCESSFUL`。
- 包内清单：35个manifest目标均有硬件记录，共56个硬件编号；9个API 1.3.1编号被SDK明确排除，见公开发布记录。
- 独立SHA-256与导出报告一致，manifest签名验证通过。本轮用Java 17调用SDK 9.2.0的`VerifyingUtils.verifyIqFile(File, null)`，退出0并输出`SDK_IQ_SIGNATURE_VALID=true`；未修改SDK、重签或重建包，没有继续逆向签名实现。独立实现的整包验签仍未完成。
- 空/非法版本和三种互斥模式共5组CLI检查均退出2。
- 5个图片文件的实际尺寸、字节数、RGB和ICC配置检查通过；截图裁切与原图已目视检查。
- 已回读提交后的中英文名称、描述和更新说明、免费状态、图标、三张截图、隐私/源码链接及48组兼容设备名称；组内可能含地区别名，不等同于真机验收数量。中英文hero分别上传，自动新增兼容设备关闭。预览截图为`artifacts/release-1.0.0/store-submitted-preview.png`。
- 没有重跑全仓测试或新增真机验收。GitHub的最终提交与推送、远端SHA、公开隐私URL回读及HTML验收以最终本机回执记录为准。

## 已知失败、风险和阻塞

- 当前等待Garmin审核，无需再次登录或重新上传同一版本。页面提示审批可能最多需要3天，不是通过时间承诺。
- 预览URL：`https://apps-developer.garmin.com/zh-CN/apps/aa58871d-46ed-49f2-9c18-72efdaa7eb50`；自动化标签名`garmin-authenticated-dashboard`，处于用户常用Chrome会话，保留供查看。旧relay中的SSO页不是当前发布会话。
- SDK现有类型推断、旧属性API弃用、启动图标尺寸警告保留。既有测试runner摘要异常、手机设置传输、新版真机显示及续航缺口不能混写成通过。
- 商店App ID为`aa58871d-46ed-49f2-9c18-72efdaa7eb50`，版本`1.0.0`、内部版本`1`。当前预览仅开发者本人可见。上传页出现过“已验证”与“签名检查失败”并列提示；SDK内置验签返回true且最终提交成功，但提示成因未确认。

## 用户偏好、限制和禁改区域

中文交付，区分事实和未验证项。当前只收束必要发布工作，不新增功能、不扩大应用代码修改、不继续逆向签名实现。保留68个本地历史文件、现有字体OFL及旧表盘；不全量暂存、清理、重置、强推或重新生成签名身份。当前应用UUID为`9d182df86c2d48938ce2c9795678f668`。

不要读取、输出或复制cookies、token、密码；不要在shell、browser工具或聊天中接收/输入密码和验证码。登录由用户官方界面或安全密码库处理；新协议由用户审阅。已提交的公开联系邮箱无需复制进回执或文档。

## 下一步

1. 在上述开发者预览页回读审核状态；目前无需再提交1.0.0。
2. 若获批准，检查未登录的公开商店页面、名称、图片、隐私链接和兼容设备列表，再记录正式上架。
3. 若被退回，保存原始审核理由，按具体问题修改；保留同一签名身份和manifest UUID。
4. 需要后续手机设置或真机验收时单独开展，不用本次商店提交替代这些证据。
5. 更新发布记录、机器回执和HTML；交付HTML前按用户要求自动打开，不重复既有且仍适用的构建或测试。

## 可粘贴恢复提示

> 继续garmin-face-it发布后的审核跟进。先读docs/codex-handoffs/2026-10-22-publication.md、docs/release-1.0.0.md和.local/publish-receipt.json。公共仓库已推送；1.0.0已成功提交Connect IQ审核，商店App ID为aa58871d-46ed-49f2-9c18-72efdaa7eb50，内部版本1，当前“应用程序待处理”，仅所属账户可见，尚未公开上架。原包SHA为0b3433a5e7675a3fee1646a8a98dc0a6e6762dbf0937c7f15706497cc63505c0，35个manifest目标、56个硬件编号；SDK内置verifyIqFile返回true。上传页的签名失败提示未阻止最终提交，原因未确认。使用garmin-authenticated-dashboard的实际Chrome会话，不再接旧relay的SSO页；不读取凭据。不要重复提交同一版本。保留本机历史和旧表盘，不扩功能、不逆向签名、不重跑适用检查；批准并验证公开页面后才标记已上架。

## 本轮接续事实与连接排查边界

用户此前确认已登录并看到后台，观察始终作为事实保留。最终通过系统默认浏览器定位到常用Chrome中的真实后台页；此前relay连接指向不同会话，连接阻塞已经解决。

包已经上传，正式提交得到预览页和待审核状态。用户选择在官方页面填写公开联系邮箱；字段完成后沿既有发布授权提交一次，未重复创建应用。没有出现单独的新协议确认页。

本次沿用既有包、密钥和素材。网页签名提示与SDK验签结果分别记录；参考的同类论坛回复为https://forums.garmin.com/thread/2071720?ContentTypeID=1 ，仅是用户报告。机器回执、HTML和发布记录同步保存当前状态。

本轮一次全量浏览器目标枚举意外返回了无关页面的敏感URL查询参数；未将其用于请求或写入交付文件。停止该方向，后续只筛选Garmin页面并输出不含查询参数的域名与路径，不再全量输出浏览器页面数据。
