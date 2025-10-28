import CJolt

public final class BodyCreationSettings {
  public let raw: OpaquePointer

  public init() {
    guard let ptr = JPH_BodyCreationSettings_Create() else {
      fatalError("Failed to allocate BodyCreationSettings")
    }
    self.raw = ptr
  }

  public convenience init(
    shape: Shape, position: RVec3, rotation: Quat, motionType: MotionType, objectLayer: ObjectLayer
  ) {
    var pos = position.cValue
    var rot = rotation.cValue
    guard
      let ptr = JPH_BodyCreationSettings_Create3(
        shape.raw, &pos, &rot, JPH_MotionType(motionType.rawValue), objectLayer)
    else {
      fatalError("Failed to allocate BodyCreationSettings")
    }
    self.init(from: ptr)
  }

  internal init(from ptr: OpaquePointer) {
    self.raw = ptr
  }

  deinit { JPH_BodyCreationSettings_Destroy(raw) }

  public var userData: UInt64 {
    get { JPH_BodyCreationSettings_GetUserData(raw) }
    set { JPH_BodyCreationSettings_SetUserData(raw, newValue) }
  }

  public var layer: ObjectLayer {
    get { JPH_BodyCreationSettings_GetObjectLayer(raw) }
    set { JPH_BodyCreationSettings_SetObjectLayer(raw, newValue) }
  }

  public var allowedDOFs: AllowedDOFs {
    get { AllowedDOFs(rawValue: JPH_BodyCreationSettings_GetAllowedDOFs(raw).rawValue) }
    set { JPH_BodyCreationSettings_SetAllowedDOFs(raw, JPH_AllowedDOFs(newValue.rawValue)) }
  }

  public var isSensor: Bool {
    get { JPH_BodyCreationSettings_GetIsSensor(raw) }
    set { JPH_BodyCreationSettings_SetIsSensor(raw, newValue) }
  }
}
