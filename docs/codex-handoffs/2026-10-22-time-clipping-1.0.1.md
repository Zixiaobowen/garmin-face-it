# 1.0.1主时间裁切修复与商店更新交接（2026-10-23更新）

## repo、branch、目标

- repo：`garmin-face-it`，公开仓库 https://github.com/Zixiaobowen/garmin-face-it 。
- 本地分支`feat/readable-typography`，推送目标`origin/main`；保留当前分支与全部无关本地文件。
- 当前用户要求完成商店图文更新。1.0.1代码和程序包已更新，三张新截图现已在商店预览显示；中英文更新说明、新封面和两种语言hero保存仍被Cloudflare拦截。

## 已完成

- 根因：Enduro 3旧主时间宽228px，在圆屏顶部34px处开始绘制，该高度只有约183px横向空间。修复日常纵坐标为46px，Time字库84px降到72px，并按同一约束调整其余圆屏字体组。训练密集时间和常显字库未改。
- 源码提交`439fd2f`已成功推送至`origin/main`。随后发布记录、README和本交接追加提交；最终文档提交SHA以远端main及本地1.0.1机器回执为准，不在提交自身中循环写自身SHA。
- 11种屏幕规格、三种布局、全天1,440个时间组合，共47,520组BMFont像素几何检查无越界。几何检查不等于模拟器逐分钟运行。
- Enduro 3日常、训练、极简；FR55小屏日常；FR965 AMOLED日常均有官方模拟器实际截图。Enduro 3训练同时显示六指标、历史图和心率区。三个构建与模拟器退出码均为0。
- 1.0.1商店包导出退出0，日志`56 OUT OF 56 DEVICES BUILT`、`BUILD SUCCESSFUL`；SDK内置验签输出true。
- 官方上传表单显示Status Verified、Signature Verified、Version 1.0.1。版本保存POST返回204，独立metadata及新开的开发者预览均确认1.0.1；预览为内部版本2、应用待处理，尚未公开上架。

## 文件与证据

代码：`source/ReferenceFaceView.mc`、`scripts/generate-fonts.py`、八组`resources-fonts/*/time.fnt`和`time.png`、`docs/font-assets.json`。说明：`README.md`、`docs/release-1.0.1.md`。

本地发布目录`artifacts/release-1.0.1/`保留包、package-report.json、package.log、clock-geometry.json、五张原始模拟器截图、screenshot-crops.json、assets/、listing-update.json及publication-receipt.json/html。2026-10-23最新现场证据为`listing-attempt-2026-10-23.json`和`store-preview-2026-10-23.png`；旧`store-preview.png`及`.local/publish-receipt.json`不能替代本轮状态。

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

2026-10-23已通过OMP relay接管用户当前登录的Chrome后台；旧自动化浏览器的页面已关闭，不能再假定旧`garmin-authenticated-dashboard`可用。新官方“编辑详细信息”页已填好中英文1.0.1更新说明、新封面和两种语言hero，表单无必填项错误；封面119,663字节（上限300KB），hero 256,236字节（上限2048KB），三张截图均小于150KB。保留联系邮箱及其它既有选项，没有读取凭据。

本轮唯一一次资料保存PUT再次返回Cloudflare HTTP403，标题“Attention Required! | Cloudflare”、正文“Sorry, you have been blocked”，Ray ID `a4ed487c68cc0d79`。正常GET metadata返回200，版本1.0.1、签名通过；中英文appWhatsNew仍为旧1.0.0文案。不要绕过安全拦截或重新上传相同版本。

三张新截图在metadata中的ID继续为`181f5b88-e8d5-4456-925d-ce571c1058bb`、`e6188598-2ed2-4c86-9db5-99db4b13df99`、`d70df62c-d368-436b-8ae9-5f62c96c6c39`。**本轮独立新开商店预览确认三张均已显示23:58**；公开图片服务生成的派生ID与metadata不同。预览仍使用旧01:44封面、旧1.0.0文案，hero未成功保存。程序仍为1.0.1（内部2）、待审核，未公开上架。

保留的官方编辑页由浏览器标签`garmin-listing-live`管理，URL为`https://apps-developer.garmin.com/zh-CN/developer/b141695f-8c03-4df3-a656-5277d34e025e/apps/aa58871d-46ed-49f2-9c18-72efdaa7eb50/edit`。它是用户真实Chrome标签；不要关闭、重载或导航，以免丢失未保存的两种语言文案与图片。独立验收页已释放。

用户当前只有Enduro 3；本任务未授权侧载。旧表盘UUID `b9b8804748954f99be17e7c4483b4db3`及数据继续保留。68个无关本地历史文件不上传、不清理。

## 下一步

1. 先读取最新机器回执和本交接，核对当前开发者页面及1.0.1（内部2）的审核状态；不重复上传程序包和三张截图。
2. 若现有管理句柄失效，使用`browser.targets(app={relay:true})`定位当前Garmin页，再接管已观察到的目标；不要依赖旧CDP端口，不输出无关页面或凭据。
3. 待站点解除拦截，在保留的官方编辑表单保存中英文更新说明、新封面和两种语言hero；若表单已关闭，先回读现有metadata，再用listing-update.json和assets/恢复。需要登录或安全验证时由用户在官方界面处理，不绕过安全服务，不代发消息。
4. 独立回读中英文文案均为1.0.1、封面和两种语言hero已更新，且三张23:58截图保持正常；程序包、素材、图文保存、公开上架分别记录。
5. 更新发布记录、机器回执、HTML及本交接；HTML最终交付前自动打开。批准后还需未登录公开商店页面可访问，才能记为正式上架。

## 恢复提示

> 继续garmin-face-it的1.0.1商店图文收尾。读本交接、docs/release-1.0.1.md和artifacts/release-1.0.1/listing-attempt-2026-10-23.json。代码439fd2f已推送，程序1.0.1（内部2）签名通过、待审核。三张新版23:58截图已在独立商店预览确认；不要重传程序包或截图。用户真实Chrome官方编辑页garmin-listing-live保留中英文1.0.1说明、新封面和两种语言hero；2026-10-23唯一一次提交仍被Cloudflare403拦截，Ray ID a4ed487c68cc0d79。metadata文案仍为1.0.0，封面仍为旧01:44。只在正常官方流程可用后完成剩余保存与回读；不得绕过拦截、读取凭据或操作旧表盘。
