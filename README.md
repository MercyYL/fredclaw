# fredclaw

> 快捷键工具合集 — 收录市面上所有收费快捷键工具的核心功能，合而为一。

fredclaw 是一个 macOS 菜单栏应用，采用模块化插件架构。每个功能模块独立开发，通过统一协议注册到主应用。目标是覆盖 BetterTouchTool、Alfred、Raycast、Keyboard Maestro、Paste、TextExpander、Rectangle/Moom、Bartender、LaunchBar、Hammerspoon 等工具的核心功能。

## 当前状态

**v0.1** — 架构骨架 + Clipboard 模块

已完成：
- 模块化插件架构（FredModule 协议 + 注册中心）
- 全局热键引擎（Carbon RegisterEventHotKey 封装）
- 通用 JSON 存储服务
- 模块间事件总线
- 辅助功能权限管理
- 剪贴板历史模块（自动监控、去重、持久化、复制/删除/清空）

## 14 个模块规划

| 优先级 | 模块 | 对标工具 | 状态 |
|--------|------|----------|------|
| 一期 | Clipboard | Paste / Raycast / Alfred | ✅ 已完成 |
| 二期 | Hotkeys | BetterTouchTool / KM | 📋 规划中 |
| 二期 | WindowMgmt | Rectangle Pro / Moom | 📋 规划中 |
| 二期 | Snippets | TextExpander / Alfred | 📋 规划中 |
| 三期 | Launcher | Raycast / Alfred / LaunchBar | 📋 规划中 |
| 三期 | SystemControls | BTT / Hammerspoon | 📋 规划中 |
| 三期 | MenuBarMgr | Bartender | 📋 规划中 |
| 四期 | Macros | Keyboard Maestro / Hammerspoon | 📋 规划中 |
| 四期 | Gestures | BetterTouchTool | 📋 规划中 |
| 四期 | Extensions | Alfred Workflows / Raycast | 📋 规划中 |
| 五期 | AI | Raycast AI | 📋 规划中 |
| 五期 | Theming | Alfred / Raycast / Bartender | 📋 规划中 |
| 五期 | Sync | Alfred / Raycast / Paste | 📋 规划中 |
| 五期 | Remote | BTT Remote / Paste iOS | 📋 规划中 |

## 系统要求

- macOS 13.0+（MenuBarExtra 需要）
- Xcode 15+
- Swift 5.9+

## 如何打开项目

1. 确保已安装 Xcode
2. 双击 `fredclaw.xcodeproj`，或终端执行：
   ```
   open fredclaw.xcodeproj
   ```
3. 等待 Xcode 完成索引

## 编译运行

1. 顶部选择 **fredclaw** target 和 **My Mac** 运行目标
2. 按 `Cmd + R` 编译运行
3. 菜单栏会出现一个爪印图标
4. 点击图标即可访问已加载的模块

## 项目结构

```
fredclaw/
├── fredclaw.xcodeproj/
└── fredclaw/
    ├── App/
    │   └── fredclawApp.swift              # @main 入口
    ├── Core/
    │   ├── Module/
    │   │   ├── FredModule.swift           # 模块协议
    │   │   ├── FredModuleContext.swift    # 共享上下文
    │   │   └── FredModuleRegistry.swift   # 注册中心
    │   ├── Hotkey/
    │   │   ├── HotkeyBinding.swift        # 热键模型
    │   │   └── HotkeyManager.swift        # Carbon 全局热键
    │   ├── Storage/
    │   │   ├── DataStore.swift            # JSON 存储
    │   │   └── SettingsStore.swift        # 设置持久化
    │   ├── Events/
    │   │   └── EventBus.swift             # 事件总线
    │   ├── Permissions/
    │   │   └── PermissionsManager.swift   # 权限管理
    │   └── UI/
    │       ├── MenuBarContentView.swift   # 主面板
    │       ├── ModuleTabBar.swift         # 模块切换栏
    │       └── AboutView.swift            # 关于页
    ├── Modules/
    │   └── Clipboard/
    │       ├── ClipboardModule.swift      # 模块入口
    │       ├── ClipboardManager.swift     # 监控逻辑
    │       ├── ClipboardItem.swift        # 数据模型
    │       ├── ClipboardView.swift        # 模块 UI
    │       └── HistoryStore.swift         # 持久化
    ├── Resources/
    │   ├── Info.plist
    │   ├── fredclaw.entitlements
    │   └── Assets.xcassets/
    └── Supporting/
        └── FredLog.swift                  # 统一日志
```

## 添加新模块

1. 在 `Modules/` 下创建新目录
2. 实现 `FredModule` 协议：
   ```swift
   class MyModule: FredModule {
       let id = "mymodule"
       let name = "我的模块"
       let icon = "star"
       var isEnabled = true

       func initialize(context: FredModuleContext) { ... }
       func shutdown() { ... }
       func makeContentView() -> AnyView { ... }
       func makeSettingsView() -> AnyView? { ... }
   }
   ```
3. 在 `fredclawApp.swift` 中注册：
   ```swift
   registry.register(MyModule())
   ```
4. 在 `project.pbxproj` 中添加文件引用

## 架构设计

```
┌─────────────────────────────────────────────────┐
│                  MenuBarExtra (UI)               │
├─────────────────────────────────────────────────┤
│                Module Registry                   │
├──────────┬──────────┬──────────┬────────────────┤
│ Clipboard │ Launcher │ Snippets │ WindowMgmt ...│
├──────────┴──────────┴──────────┴────────────────┤
│                 Core Services                     │
│  HotkeyMgr │ DataStore │ EventBus │ Permissions  │
├──────────────────────────────────────────────────┤
│                    macOS                         │
│  NSPasteboard │ AXUIElement │ Carbon HotKey ...  │
└──────────────────────────────────────────────────┘
```

核心原则：**模块即插件**。每个模块遵守统一协议，注册到 ModuleRegistry，可独立启用/停用。模块间通过 EventBus 松耦合通信，共享底层服务。

## License

MIT
