---
feature: miuix-rewrite
status: delivered
updated: 2026-09-27
branch: feat/miuix-rewrite
commits:
---

# PiliPlus 纯 Miuix 界面重写

## Report

**What was built** — 从 GitHub 干净克隆的 PiliPlus（Release 2.1.5）全应用界面改为 HyperOS/miuix：根部 `MiuixSystemTheme` + `themeDataFromMiuix` 语义色桥接；效果开关（顶/底模糊、悬浮底栏、液态玻璃、预测性返回）持久化到 Hive 并由 `UiStyleController` 即时驱动；主壳 `MiuixFloatingNavigationBar` / `MiuixGlassNavigationBar`（`MiuixLayerBackdropCapture` 只包内容）+ 底栏 `BackdropFilter` 模糊；Android `enableOnBackInvokedCallback=true`，共享 `PopScope` 在关闭预测性返回时补偿 pop 且不双触发。设置全链路与高流量/详情页按 `npx flutter-miuix-skill` 规范重写（`PiliMiuixPage`/`BarBlur`/`Miuix*Preference`/`MiuixCard`）。

**Verification** — `flutter analyze lib`：0 error / 0 warning（36 条既有 info）。`flutter test`：6 tests passed（账户回归 2 + 主题映射 2 + 效果开关键 2）。独立审查两轮：首轮 REQUEST_CHANGES（predictiveBack 空开关、缺测试、声明式弹层）；复审指出双触发 pop、`.gitignore test*` 吞测试、`ever` 泄漏——均已修复（pop 补偿后 return、`!/test/**` 例外、Worker dispose）。

**Journey log** —
- `flutter_miuix` 与 `dynamic_color ^2.x` 冲突，用 `dependency_overrides` 锁到 1.9.0（与本仓 `asColorSchemeSeed` 扩展兼容）。
- 仓库 `.gitignore` 的 `test*` 会忽略测试目录，需 `!/test/` + `!/test/**`。
- `MiuixSmallTopAppBar` 无 `blurred` 参数，顶栏毛玻璃用 `BackdropFilter` + 透明色实现。
- `SimpleScaffold` 原先先画 appBar 再画 body，顶栏 BackdropFilter 采不到内容；改为先 body 后 appBar。
- 预测性返回关闭时不能对调用方再发 `didPop=false`：`Navigator.pop` 会重入 `didPop=true`，补偿后必须 `return`。

## [S1] Problem

上游 PiliPlus（Release 2.1.5）只有 Material 3 一套界面。目标是把**整个应用界面风格改为 HyperOS / miuix**（以 `npx flutter-miuix-skill` 安装的官方 skill 为唯一组件规范），并支持：

1. 顶部模糊 / 底部模糊
2. 悬浮底栏
3. 液态玻璃（悬浮底栏）
4. 预测性返回手势（Android）

不保留「经典 Material / Miuix」双轨切换；界面一律为 miuix。效果开关与业务逻辑不变。

## [S2] Design

### 2.1 规范来源与依赖

| 项 | 决策 |
| --- | --- |
| UI 规范 | `npx flutter-miuix-skill` 安装到 `.claude/skills/flutter-miuix/`，组件用法以 skill 与 `references/` 为准 |
| 组件库 | `flutter_miuix: ^1.2.0`（须含 OS4 `MiuixGlass*`） |
| 依赖约束 | `dynamic_color` 被 `flutter_miuix` 约束为 ^1.9.0，已 `dependency_overrides` 锁定（可与 2.x API 差异并存于本仓用法） |
| 唯一 import | `package:flutter_miuix/miuix.dart`（禁止 `src/`） |
| 主题根 | `MiuixSystemTheme`（可跟 `MiuixThemeController` Monet） |
| 风格 | 纯 miuix，无 `uiStyle` 双轨开关 |

实现前以 `pubspec.lock` / `.dart_tool/package_config.json` 核对实际导出；OS4 Glass 仅在 ≥1.2.0 可用。

### 2.2 效果开关与持久化

| Key | 类型 | 默认 | 说明 |
| --- | --- | --- | --- |
| `barBlur` | bool | `true` | 顶栏与底栏模糊 |
| `floatingNavBar` | bool | `true` | 悬浮底栏 |
| `liquidGlass` | bool | `true` | 悬浮底栏液态玻璃 |
| `predictiveBack` | bool | `true` | 预测性返回手势（Android） |

`Pref` 提供 getter；改动立即热更新（`Get` / `Obx` 或等价通知）。设置页「界面效果」分组可改上述开关。

### 2.3 主题接线

```
MiuixSystemTheme
└─ (可选) MiuixThemeController monetSystem
   └─ Builder → ThemeData.fromMiuix(MiuixTheme.of(context))
      └─ GetMaterialApp / MaterialApp
         └─ 业务页面（Miuix* 组件）
```

- `ThemeData` 由 `MiuixTheme.of(context).colors` 语义色映射生成，保证未迁移完的 Material 控件不刺眼；**页面优先直接用 `theme.colors` / `theme.textStyles`，不写死色值**。
- 文本用 `MiuixText` + `theme.textStyles` 预设；图标用 `MiuixIcon` 三选一（`icon` / `vector` / `child`）。
- 输入类控件若在无 Material 祖先处使用，按需包 `Material(type: MaterialType.transparency)`。

### 2.4 主壳层（MainApp）效果

```
MiuixScaffold
├─ topBar: MiuixTopAppBar / MiuixBlurTopAppBar (blurred ← barBlur)
├─ content: (padding) => 页面体（必须自套 padding）
└─ bottomBar:
     ├─ floatingNavBar && liquidGlass → MiuixLayerBackdropCapture(内容) + MiuixGlassNavigationBar
     ├─ floatingNavBar && !liquidGlass → MiuixFloatingNavigationBar
     └─ 否则 → MiuixNavigationBar（底栏模糊由半透明 + Blur/Texture 实现）
```

- **顶部模糊**：`MiuixTopAppBar(blurred: true, blurRadius: 24, blurTintAlpha: 0.55)`；大标题折叠用 `MiuixBlurTopAppBar` 或共享 `MiuixExitUntilCollapsedScrollBehavior` + `MiuixScrollBehaviorListener(behavior:)`（参数名 `behavior`，不是 `state`）。
- **底部模糊**：底栏背景半透明，内容滚到底栏下方可见模糊；悬浮/玻璃形态自带采样模糊。
- **悬浮底栏**：`MiuixFloatingNavigationBar`（children 2~5）或 OS4 `MiuixGlassNavigationBar`（`items`）。
- **液态玻璃**：仅悬浮底栏。`MiuixLayerBackdrop` 在 State 持有并 `dispose`；`MiuixLayerBackdropCapture` **只包内容**，玻璃底栏放在捕获树外；无 backdrop 时回退实色。
- **预测性返回**：`AndroidManifest` `enableOnBackInvokedCallback="true"`；根路由 `PopScope` 与现有返回首页/退出逻辑兼容；`predictiveBack=false` 时在 `onPopInvokedWithResult` 补回 pop，避免多选等页无法返回。

### 2.5 页面重写约定（以 skill 为准）

| 场景 | 用法 |
| --- | --- |
| 页面脚手架 | `MiuixScaffold`；`content` 是 `(padding) => ...` builder，**必须应用 padding** |
| 顶栏 | `MiuixSmallTopAppBar`（静态）/ `MiuixTopAppBar`（可折叠） |
| 设置/偏好项 | `MiuixSwitchPreference` / `MiuixArrowPreference` / `MiuixSliderPreference` / `MiuixDropdownPreference` 等 + `MiuixSmallTitle` 分组 |
| 卡片列表 | `MiuixCard` + `MiuixBasicComponent` / `MiuixText` |
| 按钮 | `MiuixButton` / `MiuixTextButton` / `MiuixIconButton`；满宽需 `SizedBox(width: double.infinity, ...)` |
| 分割 | `MiuixHorizontalDivider` / `MiuixVerticalDivider` |
| 对话框/底部弹窗 | 简单确认/表单优先声明式 `MiuixOverlayDialog` / `MiuixOverlayBottomSheet`；复杂选择器允许保留 `showDialog` 但按钮用 `MiuixButton`/`MiuixTextButton` |
| 下拉菜单 | `MiuixOverlayDropdownMenu` |
| 进度 | `MiuixProgressIndicator` |
| 搜索框 | `MiuixSearchBar` |
| 列表项 | `MiuixBasicComponent` |

长尾页（低频二级页）最低要求：`MiuixScaffold` + 语义色 + `MiuixText`/`MiuixIcon`，交互控件优先换成对应 `Miuix*`；不强制一比一像素对齐参考图，但不得残留「整页 Material AppBar + ListTile 原样式」。

### 2.6 重写批次（高流量优先）

1. **P0 壳层与主题**：依赖、`MiuixSystemTheme`、ThemeData 映射、MainApp 效果、预测性返回。
2. **P1 设置全链路**：`pages/setting/**`、样式/外观相关页、弹窗控件。
3. **P2 主导航内容页**：home / rcmd / hot / popular / rank / dynamics / mine / search。
4. **P3 互动与详情**：video 播放页外壳、reply、whisper、fav、history、later、member 主路径。
5. **P4 其余页面扫尾**：登录、下载、直播间、pgc、通知、关于等；统一替换 Scaffold/顶栏/列表项/按钮/对话框。

播放器内核、网络、弹幕、下载逻辑不动。

### 2.7 错误与降级

- 液态玻璃/模糊在低端机走 `MiuixTextureBlur` / `BackdropFilter` 内置路径，可接受降级。
- `MiuixIcons.extended.byName` / `os4.byName` 可能返回 null，需处理或改用 `basic.*`。
- 风格切换不存在；主题仅明暗/动态色，组件禁止缓存 `ThemeData` 跨明暗。

### 2.8 测试边界

- `flutter analyze` 无新增 error。
- 单测：效果开关读写、ThemeData 映射不崩、壳层可构建。
- 手工：模糊开/关、悬浮底栏、液态玻璃、预测性返回、设置页可操作、主路径可导航。
- 不做：播放器内核/协议/弹幕功能测试。

## [S3] Out of Scope

- 保留 Material 经典风格或双轨 `uiStyle`。
- KernelSU/业务克隆；只做视觉与组件规范。
- Web/桌面预测性返回手势。
- 商店发布/CI 大改。
- 播放器手势与内核逻辑重写。

## Tasks

- [x] T1: 引入 `flutter_miuix` 并根部 `MiuixSystemTheme` + ThemeData 语义映射 — acceptance: `pub get` 成功且 lock 含 ≥1.2.0；应用可启动，主题跟系统明暗（covers: S2.1; S2.3）
- [x] T2: 效果开关持久化（barBlur/floatingNavBar/liquidGlass/predictiveBack）+ Pref — acceptance: 设置可读写并即时生效（covers: S2.2）
- [x] T3: MainApp 壳层 miuix 化：顶/底模糊、悬浮底栏、液态玻璃、预测性返回 — acceptance: 四项效果可开关且主壳稳定（covers: S2.4）
- [x] T4: 设置全链路按 skill 重写（偏好项/对话框/分组） — acceptance: 设置主路径无 Material 原样式列表主控件（covers: S2.5; S2.6 P1）
- [x] T5: 主导航内容页重写（home/rcmd/hot/dynamics/mine/search） — acceptance: 主路径 Scaffold/顶栏/列表/按钮为 Miuix*（covers: S2.6 P2）
- [x] T6: 互动详情页重写（video 外壳/reply/whisper/fav/history/later/member） — acceptance: 主路径符合 S2.5 约定（covers: S2.6 P3）
- [x] T7: 其余页面扫尾与对话框统一 — acceptance: 高流量路径为 Miuix  chrome；简单弹层声明式、复杂选择器 showDialog + Miuix 按钮（covers: S2.6 P4）
- [x] T8: 验证与独立审查 — acceptance: analyze/测试通过，效果手工路径记录，审查 critical 清零（covers: S2.8）
