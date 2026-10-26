# ZSvirt Time 1.2.0 发布记录

2026-10-26。功能提交[`6ffea8a`](https://github.com/Zixiaobowen/garmin-face-it/commit/6ffea8a)已推送GitHub main。Garmin已接受1.2.0，内部版本3，状态PENDING；应用主记录与实际“兼容设备”页均确认多设备范围，尚未公开上架。

## 变化

支持范围从 Enduro 3 扩展为35个官方产品目标，覆盖11种分辨率、圆形/半圆/矩形、MIP和AMOLED。独立设备矩阵见 `compatibility.json`。时间、Logo、电量、步数按实际尺寸和字体排布；8色屏采用纯黑白品牌资源。AMOLED休眠只保留灰色时间及AM/PM，分钟交替上下区域，唤醒恢复完整画面。

最低API1.4.0。打包器成功构建56个区域变体，并明确跳过9个API1.3.1区域固件；产品目标数量不等于全部区域固件均受支持。保持UUID `cb51f19636e64ae1b979bfd8bf070e31`，不增加权限。

## 实际验证

- `python3 watchfaces/zsvirt-time/scripts/build.py --package 1.2.0`：退出0，56/56区域构建成功，覆盖35个target。
- FR920XT、FR230、FR45、FR255S、FR245、FR955、Enduro 3、FR265S、FR165、FR265、FR965的 `--release --run` 编译和runner均退出0。实际查看11种分辨率；100%电量、123456步和PM同屏未见重叠或裁切。
- 四种AMOLED尺寸的官方原始截图亮像素占比1.25%–1.59%，低于10%。FR265S的17:14与17:15两帧亮像素交集为0；唤醒恢复Logo、时间、电量和步数。
- 官方SDK `VerifyingUtils.verifyIqFile` 返回true，`checkIqFileAgainstPrevious`确认与1.1.0签名身份相同。

原包：`artifacts/release-1.2.0/zsvirt-time-1.2.0.iq`，391119字节，SHA-256 `6cbfab13a67784d81c99fe39aadd4a81285f879bd6219a103ef449b9ff69b8ae`。保留1.0.0与1.1.0原包。

原始检查见[验证记录](verification/multi-device-1.2.0.json)，发行日志和验签输出保留在本版本artifacts目录。

商店主记录确认56个device type ID及56个区域part number；编辑元数据确认版本1.2.0和签名true，中英文说明与更新说明逐项回读一致。实际页面显示Enduro 1–4、多款Forerunner及对应fēnix7X/tactix7变体。详见[商店回执](verification/store-submission-1.2.0.json)和[实际兼容列表](verification/store-compatible-1.2.0.txt)。

上传成功后曾出现编辑后台已识别1.2.0、应用主记录仍为1.1.0且仅Enduro3的短暂不一致；之后主记录和页面均更新为1.2.0多设备版本。确切服务端延迟原因未确定，不能把上传204回执单独当作兼容范围已生效。只发生一次成功的1.2.0版本POST，未重复提交二进制。

用户随后追加要求覆盖整个fēnix系列，明确包含fēnix6系列。该范围不属于1.2.0的35目标成果，继续由后续版本实现和验证。

没有真机安装、腕上显示、功耗或续航证据；像素检查不能代替真机烧屏验证。本次没有重跑未改动的时制测试，也没有运行全仓库测试。
