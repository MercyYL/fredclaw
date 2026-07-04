import Foundation

/// 全局热键数据模型
struct HotkeyBinding: Codable, Equatable {
    let id: UUID
    let keyCode: UInt32          // Carbon virtual keycode
    let modifiers: UInt32        // Carbon modifier flags
    let label: String            // 显示名称
    let module: String           // 所属模块 ID

    init(keyCode: UInt32, modifiers: UInt32, label: String, module: String) {
        self.id = UUID()
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.label = label
        self.module = module
    }
}

/// 将 Carbon 修饰键标志转为可读字符串
extension HotkeyBinding {
    var displayString: String {
        var parts: [String] = []
        if modifiers & UInt32(cmdKey) != 0 { parts.append("⌘") }
        if modifiers & UInt32(shiftKey) != 0 { parts.append("⇧") }
        if modifiers & UInt32(optionKey) != 0 { parts.append("⌥") }
        if modifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
        parts.append(keyCodeToString(keyCode))
        return parts.joined()
    }

    private func keyCodeToString(_ code: UInt32) -> String {
        // 常用键映射
        let mapping: [UInt32: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G",
            6: "Z", 7: "X", 8: "C", 9: "V", 11: "B", 12: "Q",
            13: "W", 14: "E", 15: "R", 16: "Y", 17: "T",
            18: "1", 19: "2", 20: "3", 21: "4", 22: "5",
            23: "6", 24: "7", 25: "8", 26: "9", 27: "0",
            36: "Return", 37: "⇥", 38: "⇪", 39: "Space",
            48: "Tab", 49: "Space", 51: "⌫", 53: "Esc",
            122: "F1", 120: "F2", 99: "F3", 118: "F4",
            96: "F5", 97: "F6", 98: "F7", 100: "F8",
            101: "F9", 109: "F10", 103: "F11", 111: "F12",
            123: "←", 124: "→", 125: "↓", 126: "↑",
        ]
        return mapping[code] ?? "Key\(code)"
    }
}
