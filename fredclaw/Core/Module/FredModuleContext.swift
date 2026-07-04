import Foundation

/// 模块初始化时注入的共享服务上下文
/// 每个模块通过 context 访问全局服务，无需自己创建
struct FredModuleContext {
    let hotkeyManager: HotkeyManager
    let dataStore: DataStore
    let settingsStore: SettingsStore
    let eventBus: EventBus
    let permissions: PermissionsManager

    /// 创建默认的上下文（使用标准服务实例）
    static func default() -> FredModuleContext {
        let dataStore = DataStore()
        return FredModuleContext(
            hotkeyManager: HotkeyManager(),
            dataStore: dataStore,
            settingsStore: SettingsStore(),
            eventBus: EventBus(),
            permissions: PermissionsManager()
        )
    }
}
