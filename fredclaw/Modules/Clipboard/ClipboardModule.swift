import SwiftUI

/// 剪贴板模块 — 实现 FredModule 协议
class ClipboardModule: FredModule {
    let id = "clipboard"
    let name = "剪贴板"
    let icon = "clipboard"
    var isEnabled = true

    private var manager: ClipboardManager?

    func initialize(context: FredModuleContext) {
        let mgr = ClipboardManager(
            dataStore: context.dataStore,
            eventBus: context.eventBus,
            maxItems: context.settingsStore.get(
                Int.self,
                module: id,
                key: "maxItems",
                default: 50
            )
        )
        self.manager = mgr
        FredLog.clipboard.info("Clipboard module initialized")
    }

    func shutdown() {
        manager = nil
        FredLog.clipboard.info("Clipboard module shut down")
    }

    func makeContentView() -> AnyView {
        guard let manager = manager else {
            return AnyView(Text("Module not initialized").foregroundColor(.secondary))
        }
        return AnyView(
            ClipboardView()
                .environmentObject(manager)
        )
    }

    func makeSettingsView() -> AnyView? {
        // TODO: 后续添加设置 UI（最大记录数、排除应用等）
        nil
    }
}
