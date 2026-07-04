import SwiftUI

/// 关于页面
struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)

            Text("fredclaw")
                .font(.largeTitle.bold())

            Text("快捷键工具合集")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("收录市面上所有收费快捷键工具的核心功能，合而为一")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            Spacer()

            VStack(spacing: 4) {
                Text("Version 0.1.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("macOS 13.0+")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
