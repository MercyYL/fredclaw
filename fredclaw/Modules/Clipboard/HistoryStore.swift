import Foundation

/// 剪贴板历史持久化 — 基于 DataStore
class HistoryStore {
    private let dataStore: DataStore
    private let module = "clipboard"
    private let key = "history"
    private let maxItems: Int

    init(dataStore: DataStore, maxItems: Int = 50) {
        self.dataStore = dataStore
        self.maxItems = maxItems
    }

    /// 从磁盘加载历史记录
    func load() -> [ClipboardItem] {
        dataStore.load([ClipboardItem].self, module: module, key: key) ?? []
    }

    /// 保存历史记录到磁盘
    func save(_ items: [ClipboardItem]) {
        let trimmed = Array(items.prefix(maxItems))
        dataStore.save(trimmed, module: module, key: key)
    }

    /// 清空历史
    func clear() {
        dataStore.delete(module: module, key: key)
    }
}
