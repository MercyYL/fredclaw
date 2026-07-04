import Foundation
import AppKit
import Combine

/// 剪贴板管理器 — 监控剪贴板变化并维护历史记录
class ClipboardManager: ObservableObject {
    @Published var items: [ClipboardItem] = []

    private let store: HistoryStore
    private var eventBus: EventBus?
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let maxItems: Int

    init(dataStore: DataStore, eventBus: EventBus? = nil, maxItems: Int = 50) {
        self.store = HistoryStore(dataStore: dataStore, maxItems: maxItems)
        self.eventBus = eventBus
        self.maxItems = maxItems

        // 加载历史记录
        items = store.load()
        // 记录当前剪贴板状态
        lastChangeCount = NSPasteboard.general.changeCount
        // 启动定时监控
        startMonitoring()
    }

    deinit {
        timer?.invalidate()
    }

    /// 开始监控剪贴板变化
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    /// 检查剪贴板是否有新内容
    private func checkClipboard() {
        let currentCount = NSPasteboard.general.changeCount
        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        // 读取剪贴板文本
        guard let text = NSPasteboard.general.string(forType: .string),
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }

        // 如果和最新一条相同，跳过
        if let first = items.first, first.content == text {
            return
        }

        // 移除重复项
        items.removeAll { $0.content == text }

        // 插入到最前面
        let newItem = ClipboardItem(content: text)
        items.insert(newItem, at: 0)

        // 超出上限时截断
        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }

        // 持久化
        store.save(items)

        // 发布事件
        eventBus?.publish(ClipboardChangedEvent())
    }

    /// 将某条历史内容重新复制到剪贴板
    func copy(_ item: ClipboardItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.content, forType: .string)
    }

    /// 删除某条记录
    func delete(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        store.save(items)
    }

    /// 清空所有历史
    func clearAll() {
        items.removeAll()
        store.clear()
    }
}
