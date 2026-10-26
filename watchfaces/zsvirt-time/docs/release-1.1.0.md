# ZSvirt Time 1.1.0 发布记录

2026-10-26。电量与今日步数已随功能提交[`4aa2a60`](https://github.com/Zixiaobowen/garmin-face-it/commit/4aa2a60)推送GitHub `main`，GitHub分支API已回读确认。Garmin接受1.1.0上传，内部版本2；状态PENDING，尚未公开上架。

## 身份与发布证据

- 既有商店应用`2702e86b-ba01-44ed-9d5a-9b29777945f4`，manifest UUID `cb51f19636e64ae1b979bfd8bf070e31`，签名身份未变。
- 本版本仅支持Enduro 3，无额外权限、免费、非Beta，自动扩展设备支持关闭。
- 包：`artifacts/release-1.1.0/zsvirt-time-1.1.0.iq`，8,842字节，SHA-256 `bc59a45b844dd3d61bcb005b5da5f30ad285655fae9132ed235e086289e8fdca`。1.0.0原包保留。
- `python3 watchfaces/zsvirt-time/scripts/build.py --package 1.1.0`：退出0，1/1官方目标导出成功。官方SDK `VerifyingUtils.verifyIqFile`返回true。
- `--device enduro3 --release --run`：编译和runner均退出0，实际显示Logo、时间、电量及步数。初次后台启动未继承Java环境，已用命令级Java 17环境解决，未改全局环境。
- 仅一次版本上传：`POST .../version`返回204；资料保存`PUT .../apps/<id>`返回204。编辑元数据确认`newAppVersion=1.1.0`、签名true；独立应用回读确认`latestExternalVersion=1.1.0`、`latestInternalVersion=2`、`status=PENDING`。

中英文完整说明和更新说明已逐项回读匹配。新截图、中文及英文hero均从Garmin实际URL取回查看，包含82%电量与8642步。图标保持原品牌图标。隐私说明已随GitHub源码推送。

初次普通页面/应用API仍返回1.0.0与旧图；带唯一查询参数且禁用缓存的独立回读返回新版本与新图片。未重复上传，旧数据成因未确定。实际请求及字段见[商店回执](verification/store-submission-1.1.0.json)。

## 当前边界与后续范围

[商店预览](https://apps-developer.garmin.com/zh-CN/apps/2702e86b-ba01-44ed-9d5a-9b29777945f4)仍为待审核，仅账户本人可见。没有真机安装、腕上显示或续航证据；没有重跑全仓库测试。

用户随后要求像另一款表盘一样兼容其它佳明手表。1.1.0仍为Enduro 3版；后续兼容版需要独立适配、全目标导出及代表设备实际运行，不能将本版本扩大描述为已支持35目标。
