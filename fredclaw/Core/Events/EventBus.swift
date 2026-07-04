import Foundation

/// 事件基类 — 模块可自定义子类通过 EventBus 传递
class FredEvent {
    var name: String { "FredEvent" }
}

/// 模块间事件总线 — 发布/订阅模式，松耦合通信
class EventBus {
    private var subscriptions: [String: [Subscription]] = [:]
    private let queue = DispatchQueue(label: "com.fredclaw.eventbus", attributes: .concurrent)

    private struct Subscription {
        let id: UUID
        let handler: (FredEvent) -> Void
    }

    /// 发布事件（同步调用所有订阅者）
    func publish(_ event: FredEvent) {
        let typeName = String(describing: type(of: event))
        let subs = queue.sync { subscriptions[typeName] ?? [] }
        for sub in subs {
            sub.handler(event)
        }
    }

    /// 订阅特定类型的事件
    /// - Parameters:
    ///   - type: 事件类型（如 ClipboardChangedEvent.self）
    ///   - handler: 事件处理闭包
    /// - Returns: 订阅 ID（用于取消订阅）
    @discardableResult
    func subscribe<T: FredEvent>(_ type: T.Type, handler: @escaping (T) -> Void) -> UUID {
        let id = UUID()
        let typeName = String(describing: type)
        let wrapped: (FredEvent) -> Void = { event in
            if let typed = event as? T {
                handler(typed)
            }
        }

        queue.async(flags: .barrier) {
            self.subscriptions[typeName, default: []].append(Subscription(id: id, handler: wrapped))
        }
        return id
    }

    /// 取消订阅
    func unsubscribe(_ id: UUID) {
        queue.async(flags: .barrier) {
            for (typeName, subs) in self.subscriptions {
                self.subscriptions[typeName] = subs.filter { $0.id != id }
            }
        }
    }
}

// MARK: - 预定义事件

/// 剪贴板内容变化事件
class ClipboardChangedEvent: FredEvent {
    override var name: String { "ClipboardChanged" }
}

/// 模块状态变化事件
class ModuleStateChangedEvent: FredEvent {
    let moduleId: String
    let enabled: Bool
    override var name: String { "ModuleStateChanged" }

    init(moduleId: String, enabled: Bool) {
        self.moduleId = moduleId
        self.enabled = enabled
    }
}
