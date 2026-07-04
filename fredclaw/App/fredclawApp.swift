import SwiftUI

@main
struct fredclawApp: App {
    @StateObject private var registry: FredModuleRegistry = {
        let context = FredModuleContext.default()
        let registry = FredModuleRegistry()
        registry.configure(context)
        // 注册内置模块
        registry.register(ClipboardModule())
        return registry
    }()

    var body: some Scene {
        MenuBarExtra("fredclaw", systemImage: "pawprint") {
            MenuBarContentView()
                .environmentObject(registry)
        }
        .menuBarExtraStyle(.window)
    }
}
