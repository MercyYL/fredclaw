import SwiftUI

/// 所有功能模块必须遵守的协议
/// 每个模块是独立的插件，通过 FredModuleContext 访问共享服务
protocol FredModule: AnyObject {
    /// 模块唯一标识（如 "clipboard", "launcher"）
    var id: String { get }
    /// 显示名称
    var name: String { get }
    /// SF Symbol 图标名
    var icon: String { get }
    /// 模块是否启用（用户可在设置中开关）
    var isEnabled: Bool { get set }

    /// 模块初始化（注册热键、加载数据等）
    /// - Parameter context: 共享服务上下文
    func initialize(context: FredModuleContext)

    /// 模块卸载（清理资源、注销热键等）
    func shutdown()

    /// 模块的主 UI 视图
    func makeContentView() -> AnyView

    /// 模块的设置视图（可选，返回 nil 表示无设置页）
    func makeSettingsView() -> AnyView?
}
