import Foundation

/// 剪贴板条目数据模型
struct ClipboardItem: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    let timestamp: Date

    /// 用于显示的内容预览（截取前 80 字符，替换换行）
    var preview: String {
        let line = content.replacingOccurrences(of: "\n", with: " ")
        if line.count > 80 {
            return String(line.prefix(80)) + "..."
        }
        return line
    }

    /// 格式化后的相对时间
    var timeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }

    init(content: String) {
        self.id = UUID()
        self.content = content
        self.timestamp = Date()
    }
}
