# ZSvirt Time 迁出交接 · 2026-10-26

## 仓库、分支与目标

- 原仓库：`/Users/zixiaobowen/myProjects/garmin-face-it`；远端`Zixiaobowen/garmin-face-it`。
- 迁出工作区：`.local/worktrees/zsvirt-split-20261026`；分支`chore/split-zsvirt-repository`，基于`2371cbe2655bf3f2afa1a0ee92d4f2d49adeb1a2`。
- 新仓库：`/Users/zixiaobowen/ZStack/zsvirt-garmin-face-it`；https://github.com/ZSvirt/zsvirt-garmin-face-it 。
- 目标：ZSvirt Time独立维护，原仓库继续按多表盘结构开发其它表盘；GitHub推送成功后通知用户指定的钉钉群。

## 已完成

- `git subtree split --prefix=watchfaces/zsvirt-time`提取7个相关提交，新历史末端为`f167f8dd87f84441d88c50d36d7d0dc6271e17fa`。
- 新仓库根即Connect IQ应用根。源码、资源、脚本、矩阵、文档及发布材料完整迁入；52个构建输入逐文件一致，四个原始版本IQ包哈希一致，保持UUID和原签名。
- 本迁出提交移除`watchfaces/zsvirt-time/`的受控应用文件，更新根README与`docs/garmin-dev-project.md`，指向新仓库；旧历史交接继续保留。
- 新仓库已创建为公开仓库，`main`已推送至`df86753d20754e50a94efffb9afead545a1731d2`；已通过GitHub API回读确认默认分支、公开属性及提交SHA。原仓库迁出由本交接所在提交记录；群通知及最终HTML回执见新仓库交接。

## 实际验证

在新仓库根运行`python3 scripts/build.py --device enduro3`、`--device fenix6pro`、`--device fr265 --simulator --release`，三个构建均成功，退出0。证据在新仓库`docs/verification/repository-split-20261026.json`。

本轮是仓库路径和文档迁移，没有修改渲染或业务逻辑；未重新运行模拟器、单元测试或全仓库测试，未重新上传商店或安装手表。原始发布包只复制和校验，未重建覆盖。

## 并行工作与限制

主工作区使用`feat/multifunction-fenix6`，其中耐力仪表的兼容矩阵、manifest、jungle及既有未提交记录属于其它任务，未纳入迁出提交。迁出操作只修改独立worktree，不切换主工作区分支，不暂存、重置或清理其文件。主工作区旧分支仍保留ZSvirt原目录的历史视图，合入最新main后才会反映迁出；ZSvirt后续开发直接进入新仓库。

密钥仍在仓库外。保留各版本原包、真机回读和历史发布证据；发布、安装、群消息均遵从当前任务授权。用户要求中文交付与必要的定向验证。

## 后续接续步骤

1. 继续原仓库的并行表盘任务时，保留当前改动，通过正常合并纳入迁出提交；不要在进行中的工作区强行重置到main。
2. ZSvirt Time相关需求从新仓库启动，并读取其README、开发约束和交接。
3. 后续新增表盘仍在本仓库`watchfaces/<slug>/`下建立独立工程；不要恢复ZSvirt副本或增加跨仓库同步入口。

## 恢复提示

```text
本仓库的ZSvirt Time已提取至 /Users/zixiaobowen/ZStack/zsvirt-garmin-face-it，远端ZSvirt/zsvirt-garmin-face-it。迁出工作在chore/split-zsvirt-repository及独立worktree完成，主工作区的feat/multifunction-fenix6和未提交改动须继续保留。先核对远端main及本地分支，再正常整合迁出提交；ZSvirt开发不要再使用watchfaces/zsvirt-time。新仓库保留7个相关历史提交和四版原始IQ包，52个输入一致，三个代表构建通过。
```
