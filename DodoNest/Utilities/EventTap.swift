import Foundation
import CoreGraphics

/// A wrapper around CGEventTap for monitoring and modifying events.
final class EventTap {
    /// The location where the event tap is installed.
    enum Location {
        case hidEventTap
        case sessionEventTap
        case annotatedSessionEventTap
        case pid(pid_t)

        var logString: String {
            switch self {
            case .hidEventTap: return "hidEventTap"
            case .sessionEventTap: return "sessionEventTap"
            case .annotatedSessionEventTap: return "annotatedSessionEventTap"
            case .pid(let pid): return "pid(\(pid))"
            }
        }
    }

    /// Proxy for interacting with the event tap from within the callback.
    final class Proxy {
        private let tapProxy: CGEventTapProxy
        private weak var eventTap: EventTap?

        var label: String {
            eventTap?.label ?? "Unknown"
        }

        var isEnabled: Bool {
            eventTap?.isEnabled ?? false
        }

        init(tapProxy: CGEventTapProxy, eventTap: EventTap) {
            self.tapProxy = tapProxy
            self.eventTap = eventTap
        }

        func enable() {
            eventTap?.enable()
        }

        func disable() {
            eventTap?.disable()
        }
    }

    typealias Callback = (Proxy, CGEventType, CGEvent) -> CGEvent?

    let label: String
    let options: CGEventTapOptions
    let location: Location
    let place: CGEventTapPlacement
    let types: [CGEventType]
    let callback: Callback

    private var machPort: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    private(set) var isEnabled: Bool = false

    init(
        label: String = "EventTap",
        options: CGEventTapOptions = .defaultTap,
        location: Location = .sessionEventTap,
        place: CGEventTapPlacement = .headInsertEventTap,
        types: [CGEventType],
        callback: @escaping Callback
    ) {
        self.label = label
        self.options = options
        self.location = location
        self.place = place
        self.types = types
        self.callback = callback
    }

    deinit {
        disable()
    }

    /// Enables the event tap.
    func enable(timeout: Duration? = nil, onTimeout: (() -> Void)? = nil) {
        guard !isEnabled else { return }

        let eventMask = types.reduce(into: CGEventMask(0)) { mask, type in
            mask |= (1 << type.rawValue)
        }

        let userInfo = Unmanaged.passUnretained(self).toOpaque()

        let tapCallback: CGEventTapCallBack = { proxy, type, event, userInfo in
            guard let userInfo = userInfo else { return Unmanaged.passUnretained(event) }
            let eventTap = Unmanaged<EventTap>.fromOpaque(userInfo).takeUnretainedValue()
            let tapProxy = EventTap.Proxy(tapProxy: proxy, eventTap: eventTap)

            if let result = eventTap.callback(tapProxy, type, event) {
                return Unmanaged.passUnretained(result)
            }
            return nil
        }

        let tapLocation: CGEventTapLocation
        switch location {
        case .hidEventTap:
            tapLocation = .cghidEventTap
        case .sessionEventTap:
            tapLocation = .cgSessionEventTap
        case .annotatedSessionEventTap:
            tapLocation = .cgAnnotatedSessionEventTap
        case .pid:
            // For pid-specific taps, we use session tap and filter by pid in callback
            tapLocation = .cgSessionEventTap
        }

        guard let port = CGEvent.tapCreate(
            tap: tapLocation,
            place: place,
            options: options,
            eventsOfInterest: eventMask,
            callback: tapCallback,
            userInfo: userInfo
        ) else {
            print("Failed to create event tap: \(label)")
            return
        }

        machPort = port

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, port, 0)
        runLoopSource = source

        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: port, enable: true)

        isEnabled = true

        // Set up timeout if specified
        if let timeout = timeout, let onTimeout = onTimeout {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(timeout.components.seconds) + Double(timeout.components.attoseconds) / 1e18) { [weak self] in
                if self?.isEnabled == true {
                    onTimeout()
                }
            }
        }
    }

    /// Disables the event tap.
    func disable() {
        guard isEnabled else { return }

        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }

        if let port = machPort {
            CGEvent.tapEnable(tap: port, enable: false)
        }

        machPort = nil
        runLoopSource = nil
        isEnabled = false
    }
}

// MARK: - Duration Extension

extension Duration {
    static func milliseconds(_ value: Int) -> Duration {
        .init(secondsComponent: Int64(value / 1000), attosecondsComponent: Int64((value % 1000)) * 1_000_000_000_000_000)
    }

    static func seconds(_ value: Int) -> Duration {
        .init(secondsComponent: Int64(value), attosecondsComponent: 0)
    }
}
