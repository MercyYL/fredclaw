import Carbon
import Foundation

/// 全局热键管理器 — 封装 Carbon RegisterEventHotKey API
class HotkeyManager {
    private var registrations: [UInt32: Registration] = [:]
    private var nextId: UInt32 = 1
    private var eventHandlerInstalled = false

    private struct Registration {
        let hotKeyRef: EventHotKeyRef
        let handler: () -> Void
        let binding: HotkeyBinding
    }

    init() {
        installEventHandler()
    }

    deinit {
        unregisterAll()
    }

    /// 注册全局热键
    /// - Parameters:
    ///   - keyCode: Carbon virtual keycode
    ///   - modifiers: Carbon modifier flags (cmdKey, shiftKey, optionKey, controlKey)
    ///   - label: 热键描述
    ///   - module: 所属模块 ID
    ///   - handler: 触发时执行的闭包
    /// - Returns: 热键绑定信息（可通过 unregister 注销）
    @discardableResult
    func register(
        keyCode: UInt32,
        modifiers: UInt32,
        label: String,
        module: String,
        handler: @escaping () -> Void
    ) -> HotkeyBinding {
        let binding = HotkeyBinding(keyCode: keyCode, modifiers: modifiers, label: label, module: module)
        let hotKeyId = EventHotKeyID(signature: fourCharCode("frcl"), id: nextId)

        var hotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyId,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        guard status == noErr, let ref = hotKeyRef else {
            FredLog.hotkey.error("Failed to register hotkey: \(binding.displayString), status: \(status)")
            return binding
        }

        registrations[nextId] = Registration(hotKeyRef: ref, handler: handler, binding: binding)
        nextId += 1

        FredLog.hotkey.info("Registered hotkey: \(binding.displayString) for module: \(module)")
        return binding
    }

    /// 按热键信息注销
    func unregister(_ binding: HotkeyBinding) {
        guard let entry = registrations.first(where: { $0.value.binding.id == binding.id }) else { return }
        UnregisterEventHotKey(entry.value.hotKeyRef)
        registrations.removeValue(forKey: entry.key)
    }

    /// 注销某模块的所有热键
    func unregisterAll(forModule module: String) {
        let toRemove = registrations.filter { $0.value.binding.module == module }
        for (key, entry) in toRemove {
            UnregisterEventHotKey(entry.hotKeyRef)
            registrations.removeValue(forKey: key)
        }
    }

    /// 注销所有热键
    func unregisterAll() {
        for (_, entry) in registrations {
            UnregisterEventHotKey(entry.hotKeyRef)
        }
        registrations.removeAll()
    }

    // MARK: - Private

    /// 安装 Carbon 事件处理器
    private func installEventHandler() {
        guard !eventHandlerInstalled else { return }

        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, eventRef, userData) -> OSStatus in
                guard let userData = userData else { return noErr }
                let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()

                var hotKeyId = EventHotKeyID()
                GetEventParameter(
                    eventRef,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyId
                )

                if let entry = manager.registrations[hotKeyId.id] {
                    DispatchQueue.main.async {
                        entry.handler()
                    }
                }
                return noErr
            },
            1,
            &eventSpec,
            selfPtr,
            nil
        )

        eventHandlerInstalled = true
    }

    /// 将四字符字符串转为 OSType (FourCharCode)
    private func fourCharCode(_ str: String) -> OSType {
        var result: UInt32 = 0
        for char in str.utf8 {
            result = (result << 8) | UInt32(char)
        }
        return OSType(result)
    }
}
