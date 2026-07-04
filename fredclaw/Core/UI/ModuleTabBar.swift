import SwiftUI

/// 左侧模块图标栏 — 点击切换模块
struct ModuleTabBar: View {
    @EnvironmentObject var registry: FredModuleRegistry

    var body: some View {
        VStack(spacing: 4) {
            // 顶部 Logo
            Image(systemName: "pawprint.fill")
                .font(.system(size: 18))
                .foregroundColor(.accentColor)
                .padding(.top, 12)
                .padding(.bottom, 8)

            Divider()
                .frame(width: 32)

            // 模块图标列表
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(registry.modules, id: \.id) { module in
                        ModuleTabItem(
                            icon: module.icon,
                            name: module.name,
                            isActive: registry.activeModuleId == module.id,
                            isEnabled: module.isEnabled
                        ) {
                            registry.activeModuleId = module.id
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Spacer()

            // 底部关于按钮
            Divider().frame(width: 32)

            Button(action: {
                NSApplication.shared.orderFrontStandardAboutPanel(nil)
            }) {
                Image(systemName: "info.circle")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.borderless)
            .padding(.bottom, 8)
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

/// 单个模块图标项
struct ModuleTabItem: View {
    let icon: String
    let name: String
    let isActive: Bool
    let isEnabled: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(isActive ? .accentColor : .secondary)
                .opacity(isEnabled ? 1.0 : 0.4)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isActive ? Color.accentColor.opacity(0.15) : (isHovered ? Color(nsColor: .controlBackgroundColor) : Color.clear))
                )
        }
        .buttonStyle(.borderless)
        .onHover { hovering in isHovered = hovering }
        .help(name)
    }
}
