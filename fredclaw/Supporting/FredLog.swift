import os

/// 统一日志工具
enum FredLog {
    private static let subsystem = "com.fredclaw.app"

    static func category(_ name: String) -> Logger {
        Logger(subsystem: subsystem, category: name)
    }

    static let app = category("App")
    static let module = category("Module")
    static let hotkey = category("Hotkey")
    static let clipboard = category("Clipboard")
    static let storage = category("Storage")
    static let permissions = category("Permissions")
}
