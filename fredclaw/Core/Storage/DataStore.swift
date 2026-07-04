import Foundation

/// 通用 JSON 数据存储 — 每个模块独立目录
/// 存储路径: ~/Library/Application Support/fredclaw/<module>/<key>.json
class DataStore {
    private let baseDir: URL

    init() {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        baseDir = appSupport.appendingPathComponent("fredclaw")
        try? FileManager.default.createDirectory(
            at: baseDir,
            withIntermediateDirectories: true
        )
    }

    /// 读取模块数据
    func load<T: Codable>(_ type: T.Type, module: String, key: String) -> T? {
        let url = path(module: module, key: key)
        guard let data = try? Data(contentsOf: url) else { return nil }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(T.self, from: data)
    }

    /// 保存模块数据
    func save<T: Codable>(_ data: T, module: String, key: String) {
        let dir = baseDir.appendingPathComponent(module)
        try? FileManager.default.createDirectory(
            at: dir,
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        guard let encoded = try? encoder.encode(data) else { return }
        try? encoded.write(to: path(module: module, key: key), options: .atomic)
    }

    /// 删除模块数据
    func delete(module: String, key: String) {
        try? FileManager.default.removeItem(at: path(module: module, key: key))
    }

    /// 清空模块所有数据
    func clearModule(_ module: String) {
        let dir = baseDir.appendingPathComponent(module)
        try? FileManager.default.removeItem(at: dir)
    }

    private func path(module: String, key: String) -> URL {
        baseDir.appendingPathComponent(module).appendingPathComponent("\(key).json")
    }
}
