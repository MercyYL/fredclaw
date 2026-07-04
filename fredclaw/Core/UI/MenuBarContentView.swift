import SwiftUI

/// 主面板 — 左侧模块栏 + 右侧内容区
struct MenuBarContentView: View {
    @EnvironmentObject var registry: FredModuleRegistry

    var body: some View {
        VStack(spacing: 0) {
            // 左侧模块栏 + 右侧内容区
            HStack(spacing: 0) {
                // 左侧模块图标栏
                ModuleTabBar()
                    .environmentObject(registry)
                    .frame(width: 48)

                Divider()
                    .frame(width: 1)

                // 右侧内容区
                if let module = registry.activeModule {
                    module.makeContentView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.accentColor)
                        Text("fredclaw")
                            .font(.headline)
                        Text("暂无可用模块")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            Divider()

            // 底部状态栏
            HStack(spacing: 8) {
                Text("fredclaw v0.1")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("•")
                    .foregroundColor(.secondary)

                Text("\(registry.enabledModules.count) 个模块")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: { NSApplication.shared.terminate(nil) }) {
                    Text("退出")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(width: 420, height: 480)
    }
}
