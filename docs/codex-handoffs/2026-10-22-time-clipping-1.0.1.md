# 2026-10-22 主时间裁切修复与1.0.1交接

## repo、branch、目标

- repo：`garmin-face-it`，公开仓库 https://github.com/Zixiaobowen/garmin-face-it 。
- 本地分支`feat/readable-typography`，推送目标`origin/main`；保留当前分支与全部无关本地文件。
- 用户要求修复上半部分小时、分钟大字被遮挡，并更新GitHub及Connect IQ。代码和程序包已更新；商店图文保存被Cloudflare拦截。

## 已完成

- 根因：Enduro 3旧主时间宽228px，在圆屏顶部34px处开始绘制，该高度只有约183px横向空间。修复日常纵坐标为46px，Time字库84px降到72px，并按同一约束调整其余圆屏字体组。训练密集时间和常显字库未改。
- 源码提交`439fd2f`已成功推送至`origin/main`。随后发布记录、README和本交接追加提交；最终文档提交SHA以远端main及本地1.0.1机器回执为准，不在提交自身中循环写自身SHA。
- 11种屏幕规格、三种布局、全天1,440个时间组合，共47,520组BMFont像素几何检查无越界。几何检查不等于模拟器逐分钟运行。
- Enduro 3日常、训练、极简；FR55小屏日常；FR965 AMOLED日常均有官方模拟器实际截图。Enduro 3训练同时显示六指标、历史图和心率区。三个构建与模拟器退出码均为0。
- 1.0.1商店包导出退出0，日志`56 OUT OF 56 DEVICES BUILT`、`BUILD SUCCESSFUL`；SDK内置验签输出true。
- 官方上传表单显示Status Verified、Signature Verified、Version 1.0.1。版本保存POST返回204，独立metadata及新开的开发者预览均确认1.0.1；预览为内部版本2、应用待处理，尚未公开上架。

## 文件与证据

代码：`source/ReferenceFaceView.mc`、`scripts/generate-fonts.py`、八组`resources-fonts/*/time.fnt`和`time.png`、`docs/font-assets.json`。说明：`README.md`、`docs/release-1.0.1.md`。

本地发布目录`artifacts/release-1.0.1/`保留包、package-report.json、package.log、clock-geometry.json、五张原始模拟器截图、screenshot-crops.json、assets/、store-preview.png、listing-update.json、publication-receipt.json及publication-receipt.html。最新状态应看本目录；`.local/publish-receipt.json`是1.0.0历史回执，不替代本轮证据。

- IQ：`reference-face-configurable-1.0.1.iq`，2,048,457字节。
- SHA-256：`f071eefec0b1942ab4ae7363bec91e42cd4eb409baa3357d5e188e6cb1a2e392`。
- manifest UUID：`9d182df86c2d48938ce2c9795678f668`。
- 商店App ID：`aa58871d-46ed-49f2-9c18-72efdaa7eb50`。
- 预览：https://apps-developer.garmin.com/zh-CN/apps/aa58871d-46ed-49f2-9c18-72efdaa7eb50 。

## 实际命令和验证

使用Java 17 / SDK 9.2.0：

- `python3 scripts/generate-fonts.py --font /tmp/garmin-face-it-noto-sc.ttf`：成功重建字体；仅主时间变化。
- `python3 scripts/build.py --device enduro3 --run`、`--device fr55 --run`、`--device fr965 --run`：编译及运行退出0。对应`bin/build-DEVICE-sim.json`可回读。
- `python3 scripts/build.py --package 1.0.1`：成功。
- 使用既有Java jshell验证代码调用`VerifyingUtils.verifyIqFile(File, null)`：退出0，`SDK_IQ_SIGNATURE_VALID=true`。未修改SDK、未重签。
- `git add`仅列举本次修改文件，commit并`git push origin HEAD:main`成功；不全量暂存。
- HTML宽窄屏、主题及本地链接的最终浏览器验收记录在同目录publication-receipt.json。最终HTML按用户要求用`/usr/bin/open`打开；不重复打开同一份回执。

未运行全仓测试；没有新增真机安装、手机设置、续航或AMOLED烧屏预算验证。原有编译器警告继续保留。

## 当前阻塞与边界

首次更新页持续加载，随后官方表单恢复，可以正常上传；不是用户未登录。1.0.1包已接受，不要再上传相同版本。

最终资料保存PUT被Cloudflare返回HTTP403，错误HTML为“Sorry, you have been blocked”。没有绕过安全拦截。三张新截图上传分别201，metadata已有新截图ID：`181f5b88-e8d5-4456-925d-ce571c1058bb`、`e6188598-2ed2-4c86-9db5-99db4b13df99`、`d70df62c-d368-436b-8ae9-5f62c96c6c39`；但预览仍显示旧图、旧封面及1.0.0更新说明。不能把后台素材已上传记成商店图文已更新。

浏览器标签`garmin-authenticated-dashboard`保留官方更新表单，包含新中英文说明、新封面、两种语言hero和截图。原联系邮箱及其它选项保留；没有将邮箱、凭据或完整网络响应写入发布证据。SDK与网页签名验证本轮均通过。

用户当前只有Enduro 3；本任务未授权侧载。旧表盘UUID `b9b8804748954f99be17e7c4483b4db3`及数据继续保留。68个无关本地历史文件不上传、不清理。

## 下一步

1. 回读商店1.0.1（内部2）和审核状态，不重新上传程序包。
2. 待Cloudflare解除拦截，在保留的官方表单继续保存；如重开编辑页，先读取现有metadata，避免重复替换已上传的截图。
3. 使用listing-update.json和assets/完成中英文更新说明、封面、hero及截图关联；若站点仍拦截，由用户在官方界面处理，不绕过安全服务，不代发消息。
4. 独立回读预览：截图应为23:58、更新说明应为1.0.1；确认封面和两种语言hero也更新。
5. 更新发布记录、机器回执、HTML及交接，再提交推送。批准后还需未登录公开商店页面可访问，才能记为正式上架。

## 恢复提示

> 继续garmin-face-it的1.0.1图文收尾。先读docs/codex-handoffs/2026-10-22-time-clipping-1.0.1.md、docs/release-1.0.1.md及artifacts/release-1.0.1/publication-receipt.json。主时间裁切已修复，439fd2f已推送GitHub main；模拟器Enduro3/FR55/FR965及47,520组几何检查通过。1.0.1程序包已被Connect IQ接受，内部版本2、待审核、签名验证通过，不要重新上传。仅商店图文PUT被Cloudflare403拦截；新截图在metadata中，但预览仍是旧图文。保留的garmin-authenticated-dashboard表单、listing-update.json和assets/可用于接续。不得绕过安全拦截、读取凭据或改动旧表盘；按实际保存和预览回执更新状态。
