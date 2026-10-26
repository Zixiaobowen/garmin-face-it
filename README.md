# Garmin 表盘工作区

本仓库按表盘组织独立的 Connect IQ 工程。先选择表盘，再进入其源码、构建流程和验证记录。

| 表盘 | 应用目录 | 开发约束 |
| --- | --- | --- |
| 耐力仪表·可配 | [watchfaces/reference-face-configurable/](watchfaces/reference-face-configurable/README.md) | [专属开发说明](watchfaces/reference-face-configurable/docs/garmin-dev-project.md) |

ZSvirt Time已迁至独立仓库[ZSvirt/zsvirt-garmin-face-it](https://github.com/ZSvirt/zsvirt-garmin-face-it)。后续开发、构建、兼容矩阵与发布记录在新仓库维护，本仓库不再保留其应用副本。

## 目录职责

- `watchfaces/<表盘目录>/`：每款表盘的应用根，独立维护 `manifest.xml`、UUID、`monkey.jungle`、`source/`、`resources/`、`resources-fonts/`、`profiles/`、`tests/`、`scripts/` 和 `docs/`；`bin/`、`artifacts/` 及本机 `.local/` 也归属各自应用。
- 根 `docs/`：工作区说明与技能路由；具体产品、兼容矩阵、发布记录和验证证据放在对应表盘的 `docs/`。
- 根 `.agents/`、`.omp/`、`.hermes/` 和 `skills-lock.json`：本机开发辅助配置与技能安装，不是应用构建输入。
- 根 `.gitignore`：整个工作区的忽略规则。

各表盘拥有独立应用身份、资源、测试及产物。官方 SDK、Java、设备定义和仓库外开发者签名密钥可以共用；新表盘使用独立 UUID，同一表盘更新维持原 UUID。签名密钥不得复制或链接进仓库。耐力仪表·可配的35个目标只属于该应用，不是工作区通用支持范围。

## 构建、运行与资源生成

以下命令从**仓库根目录**执行；依赖、SDK和密钥配置先看[表盘 README](watchfaces/reference-face-configurable/README.md#工具与构建)。脚本按自身位置确定应用根，产物写入该表盘的目录。

```sh
# Enduro 3 真机 PRG
python3 watchfaces/reference-face-configurable/scripts/build.py --device enduro3

# 官方模拟器已经运行后，构建并运行
python3 watchfaces/reference-face-configurable/scripts/build.py --device enduro3 --run

# 仅编译官方模拟器目标
python3 watchfaces/reference-face-configurable/scripts/build.py --device enduro3 --simulator

# 定向测试，沿用现有 runner 及其已知退出码边界
python3 watchfaces/reference-face-configurable/scripts/build.py --device enduro3 --test --run

# 只编译此表盘 manifest 中的全部目标
python3 watchfaces/reference-face-configurable/scripts/build.py --all

# 导出此表盘的签名商店包
python3 watchfaces/reference-face-configurable/scripts/build.py --package 1.0.1

# 重新生成此表盘配置、农历数据和字体
python3 watchfaces/reference-face-configurable/scripts/configure.py
node watchfaces/reference-face-configurable/scripts/generate-calendar.mjs
python3 watchfaces/reference-face-configurable/scripts/generate-fonts.py --font /path/to/NotoSansSC-wght.ttf
```

这些命令沿用应用脚本的现有参数；没有根包装脚本或 `--face` 参数。也可进入 `watchfaces/reference-face-configurable/` 后使用应用 README 中的相对命令。构建、模拟器运行、商店导出、商店发布和真机安装是不同操作，各自需要独立证据；历史结果见表盘文档，不代表目录调整后重新验收。

## 新增表盘

按 Garmin 的[官方新工程流程](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/)，在 VS Code 使用 **Monkey C: New Project**，选择 Watch Face，在 `watchfaces/` 下创建新的真实工程目录；也可基于已安装 SDK 的 `bin/templates/watchface/simple/` 官方模板建立等价工程。为该表盘选择独立 UUID、最低 API 和目标设备，不预建空应用。

新工程保留独立 `manifest.xml`、UUID、源码、资源、测试、脚本、文档及产物目录，并在本页和[技能路由](docs/garmin-dev-project.md)登记。若复用现有表盘脚本，必须先调整 `scripts/configure.py` 中的应用身份（UUID、入口、名称及资源引用）、权限/API要求和能力矩阵生成逻辑，建立新表盘自己的 `docs/compatibility.json`、配置与资源；同时调整 `scripts/build.py` 的 PRG/IQ 产物前缀及默认目标。只改目录名或手改生成的 manifest 会被配置生成覆盖，不能据此复用现有应用身份或35设备矩阵。

## 目录调整验收

2026-10-26已验证配置重新生成、Enduro 3 / FR55 / FR965代表构建，以及Enduro 3官方模拟器显示；应用源码、资源与脚本保持原样。目录说明、使用入口和本轮证据见[HTML回执](docs/multi-watchface-layout.html)与[交接记录](docs/codex-handoffs/2026-10-26-multi-watchface-layout.md)。
