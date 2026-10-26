# 1.0.1主时间裁切修复与商店更新交接（2026-10-23更新）

## repo、branch、目标

- repo：`garmin-face-it`，公开仓库 https://github.com/Zixiaobowen/garmin-face-it 。
- 本地分支`feat/readable-typography`，推送目标`origin/main`；保留当前分支与全部无关本地文件。
- 用户要求的商店图文更新已完成：中英文1.0.1说明、封面、两种语言hero与三张23:58截图均已保存并回读。程序继续为1.0.1（内部2）、待审核；本轮目标不包含等待审核通过或真机安装。

## 已完成

- 根因：Enduro 3旧主时间宽228px，在圆屏顶部34px处开始绘制，该高度只有约183px横向空间。修复日常纵坐标为46px，Time字库84px降到72px，并按同一约束调整其余圆屏字体组。训练密集时间和常显字库未改。
- 源码提交`439fd2f`已成功推送至`origin/main`。随后发布记录、README和本交接追加提交；最终文档提交SHA以远端main及本地1.0.1机器回执为准，不在提交自身中循环写自身SHA。
- 11种屏幕规格、三种布局、全天1,440个时间组合，共47,520组BMFont像素几何检查无越界。几何检查不等于模拟器逐分钟运行。
- Enduro 3日常、训练、极简；FR55小屏日常；FR965 AMOLED日常均有官方模拟器实际截图。Enduro 3训练同时显示六指标、历史图和心率区。三个构建与模拟器退出码均为0。
- 1.0.1商店包导出退出0，日志`56 OUT OF 56 DEVICES BUILT`、`BUILD SUCCESSFUL`；SDK内置验签输出true。
- 官方上传表单显示Status Verified、Signature Verified、Version 1.0.1。版本保存POST返回204，独立metadata及新开的开发者预览均确认1.0.1；预览为内部版本2、应用待处理，尚未公开上架。

## 文件与证据

代码：`source/ReferenceFaceView.mc`、`scripts/generate-fonts.py`、八组`resources-fonts/*/time.fnt`和`time.png`、`docs/font-assets.json`。说明：`README.md`、`docs/release-1.0.1.md`。

本地发布目录`artifacts/release-1.0.1/`保留包、package-report.json、package.log、clock-geometry.json、五张原始模拟器截图、screenshot-crops.json、assets/、listing-update.json及publication-receipt.json/html。**最新成功证据**为`listing-success-2026-10-23.json`、`store-listing-updated-zh-2026-10-23.png`及`store-listing-updated-en-2026-10-23.png`。`listing-attempt-2026-10-23.json`、旧store-preview图片及`.local/publish-receipt.json`均为历史记录，不代表当前仍受阻。

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

## 当前完成状态与边界

2026-10-23通过OMP relay使用用户已登录的Chrome官方编辑页，分别保存：中英文1.0.1更新说明、500×500封面、英文1440×720 hero、中文1440×720 hero。**四次updateAppDetail PUT均返回204**。文案和图片仍使用listing-update.json中的原定内容，未更换账号、网络或写入端点；没有读取凭据或重传程序包。

独立GET metadata返回200，中英文appWhatsNew与目标文案完全一致，版本1.0.1、签名通过。新封面ID为`860fd5d1-d801-4122-b4c5-efa849e5b3aa`；中英文官方预览均确认新说明、封面及三张23:58截图。两种语言的hero均从官方图片URL直接回读确认新版三联图。应用仍为1.0.1（内部2）、待审核、未公开上架。

三张截图在metadata中的ID继续为`181f5b88-e8d5-4456-925d-ce571c1058bb`、`e6188598-2ed2-4c86-9db5-99db4b13df99`、`d70df62c-d368-436b-8ae9-5f62c96c6c39`；公开预览的派生ID与metadata不同。截图无需重传。此前合并提交曾返回Cloudflare403，具体服务端拦截规则未查明；本次分次官方保存已完成，不再将旧403作为当前阻塞。

用户原`garmin-listing-live`编辑页可能仍保留保存前草稿，不再需要提交；不要误把旧草稿当作待办。`garmin-listing-final-verify`为成功预览验收页。核对新状态时重新定位实际Garmin标签，避免依赖旧自动化CDP端口。代码、手表文件和旧表盘均未改动；本轮没有重跑构建、测试或模拟器。

用户当前只有Enduro 3；本任务未授权侧载。旧表盘UUID `b9b8804748954f99be17e7c4483b4db3`及数据继续保留。68个无关本地历史文件不上传、不清理。

## 后续接续

本轮图文目标已完成。以下为后续发布验收事项，不是本轮遗留图文任务：

1. 用户后续要求查看审核进度时，读取当前后台状态并记录实际结果，不沿用本次“待审核”快照。
2. 获得批准后，通过未登录公开商店页面确认可访问及图文完整，再记为正式上架。
3. 用户安排真机安装或设置验证后，继续沿用现有UUID并保留旧表盘；商店保存不能替代真机验收。

## 恢复提示

> garmin-face-it的1.0.1商店图文已完成，不要再重试旧草稿。先读本交接、docs/release-1.0.1.md及artifacts/release-1.0.1/listing-success-2026-10-23.json。中英文更新说明、封面及两种语言hero通过官方编辑页分四次保存，全部204；metadata、双语预览和两张hero图片回读通过。三张截图均为23:58，新封面ID 860fd5d1-d801-4122-b4c5-efa849e5b3aa。程序仍1.0.1（内部2）、待审核，代码修复439fd2f已推送。旧403仅为历史证据，具体拦截规则未查明；不重传程序包或截图，不操作旧表盘。下一阶段仅在用户要求时检查审核或安排真机验收。
