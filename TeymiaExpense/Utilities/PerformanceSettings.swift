import Foundation

struct PerformanceSettings {
    static var shouldUseZoomTransition: Bool {
        ProcessInfo.processInfo.physicalMemory >= 4_000_000_000
    }
}
