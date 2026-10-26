# Garmin 多表盘技能路由

本文件是仓库级 `garmin-dev` 入口。**先选择表盘，再读取该表盘专属开发约束**；不把任一表盘的设备矩阵、UUID、数据语义或历史验收结果推广到其它表盘。

| 表盘 | 应用根（相对仓库根） | 必读说明 |
| --- | --- | --- |
| 耐力仪表·可配 | `watchfaces/reference-face-configurable/` | [产品与命令](../watchfaces/reference-face-configurable/README.md)、[开发约束](../watchfaces/reference-face-configurable/docs/garmin-dev-project.md) |

ZSvirt Time已迁出本工作区，入口为[独立仓库](https://github.com/ZSvirt/zsvirt-garmin-face-it)及其[开发约束](https://github.com/ZSvirt/zsvirt-garmin-face-it/blob/main/docs/garmin-dev-project.md)。该仓库根即应用根，使用`python3 scripts/build.py`；不再使用原`watchfaces/zsvirt-time/`命令。

## 路径与调度

仓库根不再是 Connect IQ 应用根；每款表盘的 `manifest.xml`、`monkey.jungle`、源码、资源、测试、脚本、文档、`bin/` 和 `artifacts/` 均归属自己的应用目录。表盘说明中的相对路径以其应用根为准，除非明确注明仓库根。

现有表盘从仓库根构建：

```sh
python3 watchfaces/reference-face-configurable/scripts/build.py --device enduro3
```

也可进入选定应用根，使用 `python3 scripts/build.py --device enduro3`。运行、定向测试、模拟器编译和商店打包分别沿用 `--run`、`--test`、`--simulator`、`--package VERSION`；资源生成沿用该表盘脚本及原参数。以专属说明为准，不引入根包装脚本或 `--face`，不使用技能通用脚本的默认应用名、首个设备或仓库内密钥路径代替项目入口。

## 共用工具与应用边界

技能实体仍在**仓库根** `.agents/skills/garmin-dev/`，`.omp/skills/garmin-dev` 指向同一份内容；`.hermes/` 与 `skills-lock.json` 也保留在仓库根。这些本机辅助目录不是应用构建依赖。技能更新需保留到本路由的入口，再按选定表盘读取其约束。

SDK、Java、官方设备包和仓库外开发者签名密钥可以共用。每款表盘的 UUID、能力矩阵、资源及产物独立维护；同一表盘更新维持原签名和 UUID。耐力仪表·可配的35目标、SDK故障记录、商店历史回读和真机验收边界只约束该应用。

新增表盘按[根 README](../README.md#新增表盘)使用官方 **Monkey C: New Project** 或 SDK 自带的官方模板在新子目录创建真实工程，再登记路由和专属说明。复用脚本前必须调整 `configure.py` 的身份与能力矩阵，以及 `build.py` 的产物前缀；不能把已有表盘的生成配置直接当作新工程。

API问题仍先查技能缓存索引，再核对当前SDK、官方设备包及官方文档。操作技能不构成构建、模拟器或真机验收，也不授权商店发布、手表安装、覆盖旧应用或改动用户数据。
