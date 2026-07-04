import Foundation

/// 模块设置持久化 — 基于 UserDefaults，按模块命名空间
/// 键格式: fredclaw.<module>.<key>
class SettingsStore {
    private let defaults = UserDefaults.standard
    private let prefix = "fredclaw"

    /// 读取设置（带默认值）
    func get<T>(_ type: T.Type, module: String, key: String, default defaultValue: T) -> T {
        let fullKey = fullKey(module: module, key: key)
        return (defaults.object(forKey: fullKey) as? T) ?? defaultValue
    }

    /// 写入设置
    func set<T>(_ value: T, module: String, key: String) {
        let fullKey = fullKey(module: module, key: key)
        defaults.set(value, forKey: fullKey)
    }

    /// 删除设置
    func remove(module: String, key: String) {
        defaults.removeObject(forKey: fullKey(module: module, key: key))
    }

    /// 检查设置是否存在
    func exists(module: String, key: String) -> Bool {
        defaults.object(forKey: fullKey(module: module, key: key)) != nil
    }

    private func fullKey(module: String, key: String) -> String {
        "\(prefix).\(module).\(key)"
    }
}
