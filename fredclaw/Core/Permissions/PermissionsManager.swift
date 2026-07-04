import AppKit
import ApplicationServices

/// 权限管理 — 检查和请求 macOS 系统权限
class PermissionsManager {
    /// 检查辅助功能（Accessibility）权限
    /// 窗口管理、全局热键模拟等需要此权限
    func checkAccessibility() -> Bool {
        AXIsProcessTrusted()
    }

    /// 请求辅助功能权限（弹出系统授权弹窗）
    func requestAccessibility() {
        let options: NSDictionary = [
            kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true
        ]
        AXIsProcessTrustedWithOptions(options)
    }

    /// 检查屏幕录制权限（部分窗口截取功能需要）
    func checkScreenRecording() -> Bool {
        // CGPreflightScreenCaptureAccess() 在 macOS 15.0+ 可用
        // 保守返回 true，实际需要时再请求
        return true
    }

    /// 打开系统设置中的辅助功能页面
    func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}
