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

## 功能与使用方式

### 面向用户的功能

#### 剪贴板历史管理

fredclaw 的第一个功能模块，对标 Paste / Raycast / Alfred 的剪贴板功能。

**自动记录**：应用启动后会在后台每 0.5 秒检查一次系统剪贴板，任何复制操作（Cmd+C、右键复制、应用内复制）都会被自动捕获并记录到历史列表中，无需手动操作。

**智能去重**：同一段文本反复复制不会产生重复条目，旧记录会被移到列表顶部，保持最新。

**持久化存储**：所有历史记录保存到 `~/Library/Application Support/fredclaw/clipboard/history.json`，应用重启后历史不丢失。默认保留最近 50 条，超出后自动截断。

**复制回剪贴板**：点击历史列表中任意条目右侧的复制按钮（鼠标悬停时显示），即可将该内容重新写入剪贴板。

**删除与清空**：每条记录可单独删除（悬停后点 × 按钮），也可点击顶部垃圾桶图标一键清空全部历史。

**时间显示**：每条记录下方显示相对时间（如"3分钟前"），使用中文格式。

**内容预览**：每条记录显示前 80 字符的预览，超长内容以省略号截断，换行符替换为空格。

#### 菜单栏应用界面

**常驻菜单栏**：应用运行后在 macOS 菜单栏显示一个爪印图标，不占用 Dock 位置（LSUIElement=true）。点击图标弹出主面板。

**模块切换栏**：面板左侧是 48px 宽的图标栏，每个已注册模块对应一个 SF Symbol 图标按钮，点击切换右侧内容区。顶部有 fredclaw 爪印 Logo，底部有关于按钮。

**内容区域**：右侧显示当前激活模块的主界面。无模块时显示空状态提示。

**状态栏**：面板底部显示版本号、已加载模块数量，以及退出按钮。

### 核心架构能力（开发者向）

以下能力已封装为核心服务，所有模块通过 `FredModuleContext` 共享使用，无需重复造轮子。

#### 模块化插件系统

对标 BetterTouchTool / Raycast 的模块化设计。每个功能模块是独立插件，遵守 `FredModule` 协议即可接入主应用。

**FredModule 协议**定义了模块的统一接口：唯一 ID、显示名称、图标、启用状态、初始化、卸载、主 UI 视图、设置视图（可选）。模块通过 `FredModuleRegistry` 统一管理生命周期——注册时自动初始化并激活，卸载时自动清理资源。`FredModuleContext` 作为依赖注入容器，在模块初始化时传入，提供对所有共享服务的访问。

使用方式：在 `fredclawApp.swift` 的 `@StateObject` 闭包中调用 `registry.register(MyModule())`，新模块即刻接入，无需改动核心代码。

#### 全局热键引擎

对标 BetterTouchTool / Keyboard Maestro 的全局快捷键功能。封装 Carbon `RegisterEventHotKey` API，支持在任何应用中触发快捷键。

支持注册任意 Carbon 虚拟键码 + 修饰键组合（⌘⇧⌥⌃），返回 `HotkeyBinding` 对象用于注销。可按模块批量注销热键（模块卸载时自动调用）。热键事件通过 C 回调桥接，在主线程执行处理闭包。`HotkeyBinding` 是 `Codable`，可持久化到磁盘。

```swift
context.hotkeyManager.register(
    keyCode: 9,           // V 键
    modifiers: UInt32(cmdKey) | UInt32(shiftKey),  // ⌘⇧
    label: "打开剪贴板历史",
    module: "clipboard",
    handler: { /* 触发时执行 */ }
)
```

#### 数据存储服务

通用的 JSON 文件存储，按模块隔离。路径格式：`~/Library/Application Support/fredclaw/<module>/<key>.json`。支持任意 `Codable` 类型，自动处理 ISO8601 日期编码，写入使用原子操作保证数据完整性。提供加载、保存、删除、清空模块四个核心方法。

```swift
// 保存数据
context.dataStore.save(myData, module: "mymodule", key: "items")
// 加载数据
let loaded = context.dataStore.load([MyItem].self, module: "mymodule", key: "items")
```

#### 设置持久化

基于 `UserDefaults` 的轻量设置存储，键按模块命名空间（格式：`fredclaw.<module>.<key>`），避免冲突。支持读取时带默认值、写入、删除、检查存在。

```swift
let maxItems = context.settingsStore.get(Int.self, module: "clipboard", key: "maxItems", default: 50)
context.settingsStore.set(100, module: "clipboard", key: "maxItems")
```

#### 事件总线

发布/订阅模式的事件系统，模块间松耦合通信。线程安全（`DispatchQueue` concurrent + barrier）。支持泛型订阅特定事件类型，预定义了 `ClipboardChangedEvent`（剪贴板变化）和 `ModuleStateChangedEvent`（模块启停）。模块可自定义 `FredEvent` 子类扩展事件类型。

```swift
// 订阅事件
let subId = context.eventBus.subscribe(ClipboardChangedEvent.self) { event in
    print("剪贴板有新内容")
}
// 发布事件
context.eventBus.publish(MyCustomEvent())
// 取消订阅
context.eventBus.unsubscribe(subId)
```

#### 权限管理

封装 macOS 系统权限检查与请求。辅助功能权限（Accessibility）用于窗口管理、全局热键模拟等；屏幕录制权限用于窗口截取。提供 `checkAccessibility()`、`requestAccessibility()`（弹出系统授权弹窗）、`openAccessibilitySettings()`（直接跳转系统设置）三个方法。

#### 统一日志

`FredLog` 封装 `os.Logger`，子系统 `com.fredclaw.app`，按类别分类：app、module、hotkey、clipboard、storage、permissions。所有模块统一使用，方便 Console.app 过滤排查。

```swift
FredLog.clipboard.info("Clipboard module initialized")
FredLog.hotkey.error("Failed to register hotkey")
```

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
