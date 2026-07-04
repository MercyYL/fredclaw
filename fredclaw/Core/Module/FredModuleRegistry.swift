import SwiftUI

/// 模块注册中心 — 统一管理所有模块的生命周期
class FredModuleRegistry: ObservableObject {
    @Published private(set) var modules: [any FredModule] = []
    @Published var activeModuleId: String?

    private var context: FredModuleContext?

    /// 注入共享服务上下文（在 App 启动时调用）
    func configure(_ context: FredModuleContext) {
        self.context = context
    }

    /// 注册并初始化模块
    func register(_ module: any FredModule) {
        guard context != nil else {
            FredLog.module.error("Cannot register module: context not configured")
            return
        }
        guard module(for: module.id) == nil else {
            FredLog.module.warning("Module \(module.id) already registered, skipping")
            return
        }

        module.initialize(context: context!)
        modules.append(module)

        // 默认激活第一个模块
        if activeModuleId == nil {
            activeModuleId = module.id
        }

        FredLog.module.info("Registered module: \(module.id)")
    }

    /// 卸载模块
    func unregister(_ id: String) {
        guard let module = module(for: id) else { return }
        module.shutdown()
        modules.removeAll { $0.id == id }

        if activeModuleId == id {
            activeModuleId = modules.first?.id
        }

        FredLog.module.info("Unregistered module: \(id)")
    }

    /// 按 ID 查找模块
    func module(for id: String) -> (any FredModule)? {
        modules.first { $0.id == id }
    }

    /// 当前激活的模块
    var activeModule: (any FredModule)? {
        guard let id = activeModuleId else { return nil }
        return module(for: id)
    }

    /// 已启用的模块列表
    var enabledModules: [any FredModule] {
        modules.filter { $0.isEnabled }
    }
}
