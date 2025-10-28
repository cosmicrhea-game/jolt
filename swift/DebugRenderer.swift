import CJolt

public typealias Color = UInt32

public protocol DebugRendererProcs {
  func drawLine(from: RVec3, to: RVec3, color: Color)
  func drawTriangle(
    v1: RVec3, v2: RVec3, v3: RVec3, color: Color, castShadow: DebugRenderer.CastShadow)
  func drawText3D(position: RVec3, text: String, color: Color, height: Float)
}

public final class DebugRenderer {
  public enum CastShadow: UInt32 {
    case on = 0
    case off = 1
  }

  public enum DrawMode: UInt32 {
    case solid = 0
    case wireframe = 1
  }

  public let raw: OpaquePointer?
  private let procs: DebugRendererProcs
  private let userData: UnsafeMutableRawPointer
  // Store the C callbacks struct permanently to prevent deallocation
  private let cProcs: UnsafeMutablePointer<JPH_DebugRenderer_Procs>

  public init(procs: DebugRendererProcs) {
    self.procs = procs

    // Create a boxed wrapper to pass as userData
    let box = Box(procs)
    let boxPtr = Unmanaged.passRetained(box)
    self.userData = boxPtr.toOpaque()

    // Allocate and initialize the C callbacks struct permanently
    let procsPtr = UnsafeMutablePointer<JPH_DebugRenderer_Procs>.allocate(capacity: 1)
    procsPtr.initialize(to: JPH_DebugRenderer_Procs())

    procsPtr.pointee.DrawLine = { userData, from, to, color in
      guard let userData = userData, let from = from, let to = to else { return }
      let box = Unmanaged<Box<DebugRendererProcs>>.fromOpaque(userData).takeUnretainedValue()
      box.value.drawLine(from: RVec3(from.pointee), to: RVec3(to.pointee), color: color)
    }
    procsPtr.pointee.DrawTriangle = { userData, v1, v2, v3, color, castShadow in
      guard let userData = userData, let v1 = v1, let v2 = v2, let v3 = v3 else { return }
      let box = Unmanaged<Box<DebugRendererProcs>>.fromOpaque(userData).takeUnretainedValue()
      box.value.drawTriangle(
        v1: RVec3(v1.pointee),
        v2: RVec3(v2.pointee),
        v3: RVec3(v3.pointee),
        color: color,
        castShadow: CastShadow(rawValue: castShadow.rawValue) ?? .off
      )
    }
    procsPtr.pointee.DrawText3D = { userData, position, text, color, height in
      guard let userData = userData, let position = position, let text = text else { return }
      let box = Unmanaged<Box<DebugRendererProcs>>.fromOpaque(userData).takeUnretainedValue()
      box.value.drawText3D(
        position: RVec3(position.pointee),
        text: String(cString: text),
        color: color,
        height: height
      )
    }

    self.cProcs = procsPtr
    JPH_DebugRenderer_SetProcs(UnsafePointer(procsPtr))
    self.raw = JPH_DebugRenderer_Create(self.userData)
  }

  deinit {
    if let raw {
      JPH_DebugRenderer_Destroy(raw)
    }
    // Release the boxed procs
    Unmanaged<Box<DebugRendererProcs>>.fromOpaque(userData).release()
    // Deallocate the C callbacks struct
    cProcs.deinitialize(count: 1)
    cProcs.deallocate()
  }

  public func nextFrame() {
    guard let raw else { return }
    JPH_DebugRenderer_NextFrame(raw)
  }

  public func setCameraPosition(_ position: RVec3) {
    guard let raw else { return }
    var pos = position.cValue
    JPH_DebugRenderer_SetCameraPos(raw, &pos)
  }

  // MARK: - Drawing methods

  public func drawLine(from: RVec3, to: RVec3, color: Color) {
    guard let raw else { return }
    var fromVal = from.cValue
    var toVal = to.cValue
    JPH_DebugRenderer_DrawLine(raw, &fromVal, &toVal, color)
  }

  public func drawWireBox(_ box: AABB, color: Color) {
    guard let raw else { return }
    var cBox = box.cValue
    JPH_DebugRenderer_DrawWireBox(raw, &cBox, color)
  }

  public func drawWireBox(_ box: AABB, matrix: RMat44, color: Color) {
    guard let raw else { return }
    var cBox = box.cValue
    var cMatrix = matrix.cValue
    JPH_DebugRenderer_DrawWireBox2(raw, &cMatrix, &cBox, color)
  }

  public func drawMarker(_ position: RVec3, color: Color, size: Float) {
    guard let raw else { return }
    var pos = position.cValue
    JPH_DebugRenderer_DrawMarker(raw, &pos, color, size)
  }

  public func drawArrow(from: RVec3, to: RVec3, color: Color, size: Float) {
    guard let raw else { return }
    var fromVal = from.cValue
    var toVal = to.cValue
    JPH_DebugRenderer_DrawArrow(raw, &fromVal, &toVal, color, size)
  }

  public func drawCoordinateSystem(_ matrix: RMat44, size: Float) {
    guard let raw else { return }
    var cMatrix = matrix.cValue
    JPH_DebugRenderer_DrawCoordinateSystem(raw, &cMatrix, size)
  }

  public func drawPlane(_ point: RVec3, normal: Vec3, color: Color, size: Float) {
    guard let raw else { return }
    var pointVal = point.cValue
    var normalVal = normal.cValue
    JPH_DebugRenderer_DrawPlane(raw, &pointVal, &normalVal, color, size)
  }

  public func drawWireTriangle(v1: RVec3, v2: RVec3, v3: RVec3, color: Color) {
    guard let raw else { return }
    var v1Val = v1.cValue
    var v2Val = v2.cValue
    var v3Val = v3.cValue
    JPH_DebugRenderer_DrawWireTriangle(raw, &v1Val, &v2Val, &v3Val, color)
  }

  public func drawWireSphere(_ center: RVec3, radius: Float, color: Color, level: Int) {
    guard let raw else { return }
    var centerVal = center.cValue
    JPH_DebugRenderer_DrawWireSphere(raw, &centerVal, radius, color, Int32(level))
  }

  public func drawWireUnitSphere(_ matrix: RMat44, color: Color, level: Int) {
    guard let raw else { return }
    var cMatrix = matrix.cValue
    JPH_DebugRenderer_DrawWireUnitSphere(raw, &cMatrix, color, Int32(level))
  }

  public func drawTriangle(
    v1: RVec3, v2: RVec3, v3: RVec3, color: Color, castShadow: CastShadow
  ) {
    guard let raw else { return }
    var v1Val = v1.cValue
    var v2Val = v2.cValue
    var v3Val = v3.cValue
    JPH_DebugRenderer_DrawTriangle(
      raw, &v1Val, &v2Val, &v3Val, color,
      JPH_DebugRenderer_CastShadow(rawValue: castShadow.rawValue)
    )
  }

  public func drawBox(
    _ box: AABB, color: Color, castShadow: CastShadow,
    drawMode: DrawMode
  ) {
    guard let raw else { return }
    var cBox = box.cValue
    JPH_DebugRenderer_DrawBox(
      raw, &cBox, color,
      JPH_DebugRenderer_CastShadow(rawValue: castShadow.rawValue),
      JPH_DebugRenderer_DrawMode(rawValue: drawMode.rawValue)
    )
  }

  public func drawBox(
    _ box: AABB, matrix: RMat44, color: Color, castShadow: CastShadow,
    drawMode: DrawMode
  ) {
    guard let raw else { return }
    var cBox = box.cValue
    var cMatrix = matrix.cValue
    JPH_DebugRenderer_DrawBox2(
      raw, &cMatrix, &cBox, color,
      JPH_DebugRenderer_CastShadow(rawValue: castShadow.rawValue),
      JPH_DebugRenderer_DrawMode(rawValue: drawMode.rawValue)
    )
  }

  public func drawSphere(
    _ center: RVec3, radius: Float, color: Color, castShadow: CastShadow,
    drawMode: DrawMode
  ) {
    guard let raw else { return }
    var centerVal = center.cValue
    JPH_DebugRenderer_DrawSphere(
      raw, &centerVal, radius, color,
      JPH_DebugRenderer_CastShadow(rawValue: castShadow.rawValue),
      JPH_DebugRenderer_DrawMode(rawValue: drawMode.rawValue)
    )
  }

  public func drawUnitSphere(
    _ matrix: RMat44, color: Color, castShadow: CastShadow,
    drawMode: DrawMode
  ) {
    guard let raw else { return }
    let cMatrix = matrix.cValue
    JPH_DebugRenderer_DrawUnitSphere(
      raw, cMatrix, color,
      JPH_DebugRenderer_CastShadow(rawValue: castShadow.rawValue),
      JPH_DebugRenderer_DrawMode(rawValue: drawMode.rawValue)
    )
  }

  public func drawCapsule(
    _ matrix: RMat44, halfHeightOfCylinder: Float, radius: Float, color: Color,
    castShadow: CastShadow, drawMode: DrawMode
  ) {
    guard let raw else { return }
    var cMatrix = matrix.cValue
    JPH_DebugRenderer_DrawCapsule(
      raw, &cMatrix, halfHeightOfCylinder, radius, color,
      JPH_DebugRenderer_CastShadow(rawValue: castShadow.rawValue),
      JPH_DebugRenderer_DrawMode(rawValue: drawMode.rawValue)
    )
  }

  public func drawCylinder(
    _ matrix: RMat44, halfHeight: Float, radius: Float, color: Color,
    castShadow: CastShadow, drawMode: DrawMode
  ) {
    guard let raw else { return }
    var cMatrix = matrix.cValue
    JPH_DebugRenderer_DrawCylinder(
      raw, &cMatrix, halfHeight, radius, color,
      JPH_DebugRenderer_CastShadow(rawValue: castShadow.rawValue),
      JPH_DebugRenderer_DrawMode(rawValue: drawMode.rawValue)
    )
  }
}

// Helper class to box the protocol for C interop
private final class Box<T> {
  let value: T
  init(_ value: T) {
    self.value = value
  }
}
