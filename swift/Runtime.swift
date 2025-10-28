import CJolt
import Foundation

public enum JoltRuntime {
  private static let state = RuntimeState()

  @discardableResult
  public static func initialize() -> Bool { state.initialize() }

  public static func shutdown() { state.shutdown() }

  @MainActor
  public static func setTraceHandler(_ handler: @escaping (String) -> Void) {
    // Retain closure in a global trampoline box
    ClosureTrampolines.traceHandler = handler
    JPH_SetTraceHandler(traceCallback)
  }

  @MainActor
  public static func setAssertFailureHandler(
    _ handler: @escaping (_ expression: String, _ message: String, _ file: String, _ line: UInt32)
      -> Bool
  ) {
    ClosureTrampolines.assertHandler = handler
    JPH_SetAssertFailureHandler(assertCallback)
  }
}

@MainActor
enum ClosureTrampolines {
  static var traceHandler: ((String) -> Void)?
  static var assertHandler:
    ((_ expression: String, _ message: String, _ file: String, _ line: UInt32) -> Bool)?
}

// Global C callback functions that don't capture context
private func traceCallback(_ message: UnsafePointer<CChar>?) {
  if let message {
    let msg = String(cString: message)
    Task { @MainActor in
      ClosureTrampolines.traceHandler?(msg)
    }
  }
}

private func assertCallback(
  _ expression: UnsafePointer<CChar>?, _ message: UnsafePointer<CChar>?,
  _ file: UnsafePointer<CChar>?, _ line: UInt32
) -> Bool {
  let expr = expression.map { String(cString: $0) } ?? ""
  let msg = message.map { String(cString: $0) } ?? ""
  let fileName = file.map { String(cString: $0) } ?? ""

  // For assert callbacks, we need to handle this synchronously since asserts might be fatal
  // We'll call the handler on the main actor synchronously using Task with a synchronous result
  var result = false
  let semaphore = DispatchSemaphore(value: 0)

  Task { @MainActor in
    result = ClosureTrampolines.assertHandler?(expr, msg, fileName, line) ?? false
    semaphore.signal()
  }

  semaphore.wait()
  return result
}

// MARK: - Internal state container (thread-safe)
private final class RuntimeState: @unchecked Sendable {
  private let initializationLock = NSLock()
  private var initializationCount: Int = 0
  private var isInitialized: Bool = false

  @inline(__always)
  func initialize() -> Bool {
    initializationLock.lock()
    defer { initializationLock.unlock() }

    if isInitialized {
      initializationCount += 1
      return true
    }

    let ok = JPH_Init()
    if ok {
      isInitialized = true
      initializationCount = 1
    }
    return ok
  }

  @inline(__always)
  func shutdown() {
    initializationLock.lock()
    defer { initializationLock.unlock() }

    guard isInitialized else { return }

    initializationCount -= 1
    if initializationCount <= 0 {
      JPH_Shutdown()
      isInitialized = false
      initializationCount = 0
    }
  }
}
