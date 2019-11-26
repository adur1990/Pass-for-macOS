import Cocoa
import Carbon

class Shortcut {
    init() {}

    static func register(_ keyCode: UInt32, modifiers: UInt32, block: @escaping () -> ()) {
        var shortcut: EventHotKeyRef? = nil
        var eventHandler: EventHandlerRef? = nil
        let shortcutID = EventHotKeyID(signature: 1, id: 1)
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let ptr = UnsafeMutablePointer<() -> ()>.allocate(capacity: 1)
        ptr.initialize(to: block)

        if InstallEventHandler(GetApplicationEventTarget(),
            { (_: EventHandlerCallRef?, _: EventRef?, ptr: UnsafeMutableRawPointer?) -> OSStatus in
                ptr.map({$0.assumingMemoryBound(to: (() -> ()).self).pointee()})
                return noErr
            },
            1,
            &eventType,
            ptr,
            &eventHandler
        ) == noErr {
            if RegisterEventHotKey(
                keyCode,
                modifiers,
                shortcutID,
                GetApplicationEventTarget(),
                OptionBits(0),
                &shortcut
            ) != noErr {
                fatalError("Failed to register global shortcut")
            }
        }
    }
}
