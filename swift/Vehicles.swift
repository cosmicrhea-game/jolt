import CJolt

public final class VehicleConstraintSettingsBox {
  public let raw: UnsafeMutablePointer<JPH_VehicleConstraintSettings>
  private var wheelSettings: [WheelSettingsWV] = []
  public init(up: Vec3 = .init(x: 0, y: 1, z: 0), forward: Vec3 = .init(x: 0, y: 0, z: 1)) {
    raw = .allocate(capacity: 1)
    JPH_VehicleConstraintSettings_Init(raw)
    raw.pointee.up = up.cValue
    raw.pointee.forward = forward.cValue
  }
  deinit { raw.deallocate() }

  public func addWheel(_ settings: WheelSettingsWV) {
    wheelSettings.append(settings)
    var ptrs = wheelSettings.map { $0.raw }
    raw.pointee.wheelsCount = UInt32(ptrs.count)
    ptrs.withUnsafeMutableBufferPointer { buf in
      raw.pointee.wheels = UnsafeMutablePointer(mutating: buf.baseAddress)
    }
  }
}

public final class WheeledVehicleControllerSettingsBox {
  public let raw: OpaquePointer?
  public init() { raw = JPH_WheeledVehicleControllerSettings_Create() }
}

public final class WheelSettingsWV {
  public let raw: OpaquePointer?
  public init() { raw = JPH_WheelSettingsWV_Create() }

  // Base wheel settings
  public var position: Vec3 {
    get {
      var out = JPH_Vec3(x: 0, y: 0, z: 0)
      JPH_WheelSettings_GetPosition(raw, &out)
      return Vec3(out)
    }
    set {
      var v = newValue.cValue
      JPH_WheelSettings_SetPosition(raw, &v)
    }
  }
  public var suspensionDirection: Vec3 {
    get {
      var out = JPH_Vec3(x: 0, y: 0, z: 0)
      JPH_WheelSettings_GetSuspensionDirection(raw, &out)
      return Vec3(out)
    }
    set {
      var v = newValue.cValue
      JPH_WheelSettings_SetSuspensionDirection(raw, &v)
    }
  }
  public var steeringAxis: Vec3 {
    get {
      var out = JPH_Vec3(x: 0, y: 0, z: 0)
      JPH_WheelSettings_GetSteeringAxis(raw, &out)
      return Vec3(out)
    }
    set {
      var v = newValue.cValue
      JPH_WheelSettings_SetSteeringAxis(raw, &v)
    }
  }
  public var wheelUp: Vec3 {
    get {
      var out = JPH_Vec3(x: 0, y: 0, z: 0)
      JPH_WheelSettings_GetWheelUp(raw, &out)
      return Vec3(out)
    }
    set {
      var v = newValue.cValue
      JPH_WheelSettings_SetWheelUp(raw, &v)
    }
  }
  public var wheelForward: Vec3 {
    get {
      var out = JPH_Vec3(x: 0, y: 0, z: 0)
      JPH_WheelSettings_GetWheelForward(raw, &out)
      return Vec3(out)
    }
    set {
      var v = newValue.cValue
      JPH_WheelSettings_SetWheelForward(raw, &v)
    }
  }
  public var suspensionMinLength: Float {
    get { JPH_WheelSettings_GetSuspensionMinLength(raw) }
    set { JPH_WheelSettings_SetSuspensionMinLength(raw, newValue) }
  }
  public var suspensionMaxLength: Float {
    get { JPH_WheelSettings_GetSuspensionMaxLength(raw) }
    set { JPH_WheelSettings_SetSuspensionMaxLength(raw, newValue) }
  }
  public var suspensionPreloadLength: Float {
    get { JPH_WheelSettings_GetSuspensionPreloadLength(raw) }
    set { JPH_WheelSettings_SetSuspensionPreloadLength(raw, newValue) }
  }
  public var suspensionSpring: JPH_SpringSettings {
    get {
      var s = JPH_SpringSettings(
        mode: JPH_SpringMode_FrequencyAndDamping, frequencyOrStiffness: 0, damping: 0)
      JPH_WheelSettings_GetSuspensionSpring(raw, &s)
      return s
    }
    set {
      var s = newValue
      JPH_WheelSettings_SetSuspensionSpring(raw, &s)
    }
  }
  public var radius: Float {
    get { JPH_WheelSettings_GetRadius(raw) }
    set { JPH_WheelSettings_SetRadius(raw, newValue) }
  }
  public var width: Float {
    get { JPH_WheelSettings_GetWidth(raw) }
    set { JPH_WheelSettings_SetWidth(raw, newValue) }
  }
  public var enableSuspensionForcePoint: Bool {
    get { JPH_WheelSettings_GetEnableSuspensionForcePoint(raw) }
    set { JPH_WheelSettings_SetEnableSuspensionForcePoint(raw, newValue) }
  }

  // WV specific
  public var inertia: Float {
    get { JPH_WheelSettingsWV_GetInertia(raw) }
    set { JPH_WheelSettingsWV_SetInertia(raw, newValue) }
  }
  public var angularDamping: Float {
    get { JPH_WheelSettingsWV_GetAngularDamping(raw) }
    set { JPH_WheelSettingsWV_SetAngularDamping(raw, newValue) }
  }

  deinit { if let raw { JPH_WheelSettings_Destroy(raw) } }
}

public final class Vehicle {
  public let constraint: OpaquePointer?
  public let controller: OpaquePointer?

  public init(
    vehicleBodyId: BodyID, settings: VehicleConstraintSettingsBox,
    wheelSettings: [OpaquePointer?] = [],
    controllerSettings: WheeledVehicleControllerSettingsBox? = nil, in system: PhysicsSystem
  ) {
    // Build wheels array
    if !wheelSettings.isEmpty {
      var wheelsPtr: [OpaquePointer?] = wheelSettings
      settings.raw.pointee.wheelsCount = UInt32(wheelsPtr.count)
      wheelsPtr.withUnsafeMutableBufferPointer { buf in
        settings.raw.pointee.wheels = UnsafeMutablePointer(mutating: buf.baseAddress)
      }
    }
    if let cs = controllerSettings?.raw {
      settings.raw.pointee.controller = cs
    }

    // Lock body to get JPH_Body*
    let body = JPH_BodyInterface_CreateBodyWithID(system.bodyInterface().raw, vehicleBodyId, nil)
    self.constraint = JPH_VehicleConstraint_Create(body, settings.raw)
    self.controller = JPH_VehicleConstraint_GetController(self.constraint)
  }

  public func setDriverInput(forward: Float, right: Float, brake: Float, handBrake: Float) {
    if let controller {
      JPH_WheeledVehicleController_SetDriverInput(controller, forward, right, brake, handBrake)
    }
  }

  public func setForward(_ v: Float) {
    if let controller { JPH_WheeledVehicleController_SetForwardInput(controller, v) }
  }
  public func setRight(_ v: Float) {
    if let controller { JPH_WheeledVehicleController_SetRightInput(controller, v) }
  }
  public func setBrake(_ v: Float) {
    if let controller { JPH_WheeledVehicleController_SetBrakeInput(controller, v) }
  }
  public func setHandBrake(_ v: Float) {
    if let controller { JPH_WheeledVehicleController_SetHandBrakeInput(controller, v) }
  }

  public func getWheelWorldTransform(index: UInt32) -> RMat44 {
    guard let constraint else { return RMat44(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1) }
    var right = JPH_Vec3(x: 1, y: 0, z: 0)
    var up = JPH_Vec3(x: 0, y: 1, z: 0)
    var out = JPH_RMat4()
    JPH_VehicleConstraint_GetWheelWorldTransform(constraint, index, &right, &up, &out)
    return RMat44(out)
  }
}
