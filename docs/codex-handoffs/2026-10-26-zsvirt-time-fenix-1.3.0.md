# ZSvirt Time fēnix 兼容版交接

- Repo：`/Users/zixiaobowen/myProjects/garmin-face-it`
- 当前分支：`main`。实现分支`feat/zsvirt-time-fenix-family`保留。
- 当前目标：用户要求将ZSvirt表盘上传商店，并追加fēnix全系列、明确包含fēnix6系列。功能和商店提交已完成；当前等待Garmin审核。

## 已完成

1.2.0的35目标兼容版已实际上传并确认内部3；随后新增34个fēnix目标，1.3.0共69个官方目标、116个可导出区域变体。fēnix6／6S／6X标准版、Pro、Sapphire、Solar等由5个官方目标覆盖，20个区域part number全部出现在商店主记录。实际兼容页已看到对应机型。

1.3.0商店AppID为`2702e86b-ba01-44ed-9d5a-9b29777945f4`，内部版本4，PENDING，尚未公开上架。UUID仍为`cb51f19636e64ae1b979bfd8bf070e31`，签名未变。功能提交`b33055d`已推送GitHub main；此前`44630b9`保存1.2.0最终回执。未安装本次1.3.0到真机。

## 已调查或修改的文件

- `watchfaces/zsvirt-time/docs/compatibility.json`：独立69目标矩阵，来自官方compiler/simulator元数据。
- `manifest.xml`、`monkey.jungle`：生成的69目标配置。
- `resources-logos/466/`、`resources-launchers/36x36/`：新增资源；既有渲染源码与资源生成脚本未改。
- 根README、应用README、应用`docs/garmin-dev-project.md`：当前范围与命令。
- `docs/release-1.2.0.md`、`docs/release-1.3.0.md`及`docs/verification/store-*1.2.0*`、`*1.3.0*`、`fenix-1.3.0.json`：实际发布和验收证据。
- `watchfaces/zsvirt-time/docs/delivery.html`：最终自包含HTML回执，嵌入fēnix6Pro模拟器实际画面。
- 官方设备目录：`~/Library/Application Support/Garmin/ConnectIQ/Devices/fenix*/{compiler,simulator}.json`。

## 已运行命令与结果

- `python3 watchfaces/zsvirt-time/scripts/generate-resources.py`及`configure.py`：成功，12种屏宽、6种启动图标尺寸。
- `python3 watchfaces/zsvirt-time/scripts/build.py --package 1.3.0`：退出0，116/116构建成功。
- `--device TARGET --release --run`：fenix6、fenix6pro、fenix6s、fenix6spro、fenix6xpro、fenix3、fenix9pro51mm、fr255s，8次构建与模拟器runner均退出0，已查看画面。无重叠或裁切，输入100%电量／0步／PM。
- 官方SDK验签true；与1.2.0同签名true。
- 新466×466 AMOLED原始截图2190亮像素，占圆形显示区域1.284%；唤醒恢复完整布局。
- 商店1.3.0／内部4，116个区域part number与矩阵符合最低API的完整集合一致；中英文说明和更新说明回读一致。
- Git已提交、fast-forward合入main并推送；远端回执`6ffea8a..b33055d main -> main`。
- 最终HTML已通过Tern实际1386px宽页及375CSS-px内嵌窄页检查（原生取整回读374px），无横向溢出、图片已加载、证据折叠正常、控制台无错误。已绑定当前会话并固定到右侧块2237677961593，最终目标回读shown=true；已释放接管并保留分栏。详见应用`docs/verification/delivery-1.3.0-browser.json`。

## 风险、边界与已知失败

无当前功能阻塞。Garmin审核尚未完成；PENDING不能称为公开上架。没有1.3.0真机安装、腕上显示、功耗或续航证据。未重复运行未改动的时制测试、123456步场景或全仓库测试。

设备包含fēnix9目标，商店主记录接受对应part number，但可见兼容页未显示9系列名称，不宣称该系列商店安装可用。API1.3.1地区固件因最低API1.4被导出器排除。

1.2.0曾有“编辑后台已识别新包、应用主记录仍为旧版”的短暂不一致，之后已确认主记录与实际兼容页更新。确切服务端延迟原因未确定；不能单凭上传204宣称生效。

本轮原生模拟器自动化曾遇到就绪标签大小写不符及目录输入未完整写入；均完成定位并取得最终8次退出0及原始帧证据。活动监测对话框只查看，未成功修改步数，不宣称长步数边界在1.3.0重测。任务独占模拟器已退出。

## 用户偏好与禁改区域

中文、简洁，优先完成上传，不要反复确认已授权动作。用户要求fēnix6系列必须包含。保留所有无关未提交文件，尤其耐力仪表目录中的交接／回执，以及并行的Enduro3安装记录。不要删除旧原包、分支、技能或其它会话页面。签名密钥保持仓库外，未授权真机安装或商店删除。

最终HTML使用`html`技能；绑定当前实际`TERN_PANE`，在Tern右侧展示，验收后释放接管并保留分栏，禁止改用外部浏览器。Eval进程的环境中可能没有TERN_PANE，必须通过当前session的bash `printenv TERN_PANE`获取；本轮值为2237677961422，未来不要沿用旧值。

## 下一步

1. 用户需要时重新读取商店审核状态；只在出现实际批准回执后报告公开上架。
2. 如用户授权真机安装，使用本次1.3.0原包对应PRG并重新做设备回读与腕上验证，不沿用旧Enduro3安装结果。
3. 若新增其他系列，先核对当前官方设备元数据、实际商店型号与API要求；不要从相同分辨率推导真机验收。
4. 保留本次原包与证据；不重复提交1.3.0来解决页面缓存，先核对主记录与兼容页。

## 恢复提示

继续`garmin-face-it`的ZSvirt Time。先读本交接、应用README与`docs/release-1.3.0.md`。1.3.0已上传Connect IQ，内部4、PENDING；69目标／116区域变体，fēnix6系列20区域型号全部回读确认。功能`b33055d`已推送main。不要再重复上传或默认重跑全部验证；先确认用户的新目标及最新商店状态，保留无关未提交改动。HTML回执为`watchfaces/zsvirt-time/docs/delivery.html`。
