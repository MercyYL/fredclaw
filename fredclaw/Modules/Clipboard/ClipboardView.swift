import SwiftUI

/// 剪贴板模块 UI — 历史记录列表
struct ClipboardView: View {
    @EnvironmentObject var manager: ClipboardManager

    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            HStack {
                Text("剪贴板历史")
                    .font(.headline)
                Spacer()
                Button(action: { manager.clearAll() }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.borderless)
                .help("清空历史")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // 历史列表
            if manager.items.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clipboard")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    Text("暂无剪贴板记录")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    Text("复制任何文本即可自动记录")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(manager.items) { item in
                            ClipboardRowView(
                                item: item,
                                onCopy: { manager.copy(item) },
                                onDelete: { manager.delete(item) }
                            )
                            Divider()
                        }
                    }
                }
            }

            Divider()

            // 底部信息
            HStack {
                Text("共 \(manager.items.count) 条记录")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(nsColor: .windowBackgroundColor))
        }
    }
}

/// 单条剪贴板记录行
struct ClipboardRowView: View {
    let item: ClipboardItem
    let onCopy: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // 内容预览
            VStack(alignment: .leading, spacing: 4) {
                Text(item.preview)
                    .font(.system(size: 13))
                    .lineLimit(2)
                    .foregroundColor(.primary)

                Text(item.timeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 操作按钮（悬停显示）
            if isHovered {
                VStack(spacing: 4) {
                    Button(action: onCopy) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.borderless)
                    .help("复制此条")

                    Button(action: onDelete) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.borderless)
                    .help("删除此条")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isHovered ? Color(nsColor: .controlBackgroundColor) : Color.clear)
        .onHover { hovering in
            isHovered = hovering
        }
        .contentShape(Rectangle())
    }
}
