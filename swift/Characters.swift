import CJolt

public enum GroundState: UInt32 {
  case onGround = 0
  case onSteepGround = 1
  case notSupported = 2
  case inAir = 3
}

public final class CharacterVirtualSettings {
  public let raw: UnsafeMutablePointer<JPH_CharacterVirtualSettings>

  public init(up: Vec3 = .init(x: 0, y: 1, z: 0), supportingVolume: Plane, shape: Shape) {
    raw = .allocate(capacity: 1)
    JPH_CharacterVirtualSettings_Init(raw)
    let upv = up.cValue
    let plane = supportingVolume.cValue
    raw.pointee.base.up = upv
    raw.pointee.base.supportingVolume = plane
    raw.pointee.base.shape = shape.raw
  }

  deinit { raw.deallocate() }
}

public final class CharacterVirtual {
  public let raw: OpaquePointer?

  public init(
    settings: CharacterVirtualSettings, position: RVec3 = .init(x: 0, y: 0, z: 0),
    rotation: Quat = .identity, userData: UInt64 = 0, in system: PhysicsSystem? = nil
  ) {
    var pos = position.cValue
    var rot = rotation.cValue
    self.raw = JPH_CharacterVirtual_Create(settings.raw, &pos, &rot, userData, system?.raw)
  }

  public var id: CharacterID { JPH_CharacterVirtual_GetID(raw) }

  public var position: RVec3 {
    get {
      var p = JPH_RVec3(x: 0, y: 0, z: 0)
      JPH_CharacterVirtual_GetPosition(raw, &p)
      return RVec3(p)
    }
    set {
      var p = newValue.cValue
      JPH_CharacterVirtual_SetPosition(raw, &p)
    }
  }

  public var rotation: Quat {
    get {
      var q = JPH_Quat(x: 0, y: 0, z: 0, w: 1)
      JPH_CharacterVirtual_GetRotation(raw, &q)
      return Quat(q)
    }
    set {
      var q = newValue.cValue
      JPH_CharacterVirtual_SetRotation(raw, &q)
    }
  }

  public var linearVelocity: Vec3 {
    get {
      var v = JPH_Vec3(x: 0, y: 0, z: 0)
      JPH_CharacterVirtual_GetLinearVelocity(raw, &v)
      return Vec3(v)
    }
    set {
      var v = newValue.cValue
      JPH_CharacterVirtual_SetLinearVelocity(raw, &v)
    }
  }

  public func update(deltaTime: Float, layer: ObjectLayer, in system: PhysicsSystem) {
    JPH_CharacterVirtual_Update(raw, deltaTime, layer, system.raw, nil, nil)
  }

  public func canWalkStairs(desiredLinearVelocity: Vec3) -> Bool {
    var v = desiredLinearVelocity.cValue
    return JPH_CharacterVirtual_CanWalkStairs(raw, &v)
  }

  public func walkStairs(
    deltaTime: Float, stepUp: Vec3, stepForward: Vec3, stepForwardTest: Vec3, stepDownExtra: Vec3,
    layer: ObjectLayer, in system: PhysicsSystem
  ) -> Bool {
    var up = stepUp.cValue
    var forward = stepForward.cValue
    var forwardTest = stepForwardTest.cValue
    var downExtra = stepDownExtra.cValue
    return JPH_CharacterVirtual_WalkStairs(
      raw, deltaTime, &up, &forward, &forwardTest, &downExtra, layer, system.raw, nil, nil)
  }

  public func stickToFloor(stepDown: Vec3, layer: ObjectLayer, in system: PhysicsSystem) -> Bool {
    var sd = stepDown.cValue
    return JPH_CharacterVirtual_StickToFloor(raw, &sd, layer, system.raw, nil, nil)
  }

  // MARK: - Ground helpers
  public var groundState: GroundState {
    GroundState(rawValue: JPH_CharacterBase_GetGroundState(raw).rawValue) ?? .inAir
  }

  public var isSupported: Bool { JPH_CharacterBase_IsSupported(raw) }

  public func getGroundPosition() -> RVec3 {
    var out = JPH_RVec3(x: 0, y: 0, z: 0)
    JPH_CharacterBase_GetGroundPosition(raw, &out)
    return RVec3(out)
  }

  public func getGroundNormal() -> Vec3 {
    var out = JPH_Vec3(x: 0, y: 0, z: 0)
    JPH_CharacterBase_GetGroundNormal(raw, &out)
    return Vec3(out)
  }

  public func getGroundVelocity() -> Vec3 {
    var out = JPH_Vec3(x: 0, y: 0, z: 0)
    JPH_CharacterBase_GetGroundVelocity(raw, &out)
    return Vec3(out)
  }

  public func getGroundBodyID() -> BodyID {
    JPH_CharacterBase_GetGroundBodyId(raw)
  }

  // MARK: - Contacts
  public struct Contact {
    public var bodyID: BodyID
    public var characterID: CharacterID
    public var position: RVec3
    public var linearVelocity: Vec3
    public var contactNormal: Vec3
    public var surfaceNormal: Vec3
    public var distance: Float
    public var fraction: Float
    public var motionTypeB: MotionType
    public var isSensorB: Bool

    init(_ c: JPH_CharacterVirtualContact) {
      self.bodyID = c.bodyB
      self.characterID = c.characterIDB
      self.position = RVec3(c.position)
      self.linearVelocity = Vec3(c.linearVelocity)
      self.contactNormal = Vec3(c.contactNormal)
      self.surfaceNormal = Vec3(c.surfaceNormal)
      self.distance = c.distance
      self.fraction = c.fraction
      self.motionTypeB = MotionType(rawValue: c.motionTypeB.rawValue) ?? .dynamic
      self.isSensorB = c.isSensorB
    }
  }

  public func activeContacts() -> [Contact] {
    var results: [Contact] = []
    let count = JPH_CharacterVirtual_GetNumActiveContacts(raw)
    results.reserveCapacity(Int(count))
    var c = JPH_CharacterVirtualContact(
      hash: 0,
      bodyB: 0,
      characterIDB: 0,
      subShapeIDB: 0,
      position: JPH_RVec3(x: 0, y: 0, z: 0),
      linearVelocity: JPH_Vec3(x: 0, y: 0, z: 0),
      contactNormal: JPH_Vec3(x: 0, y: 0, z: 0),
      surfaceNormal: JPH_Vec3(x: 0, y: 0, z: 0),
      distance: 0,
      fraction: 0,
      motionTypeB: JPH_MotionType(0),
      isSensorB: false,
      characterB: nil,
      userData: 0,
      material: nil,
      hadCollision: false,
      wasDiscarded: false,
      canPushCharacter: false
    )
    var i: UInt32 = 0
    while i < count {
      JPH_CharacterVirtual_GetActiveContact(raw, i, &c)
      results.append(Contact(c))
      i += 1
    }
    return results
  }

  // MARK: - Shape & properties
  public func setShape(
    _ shape: Shape, maxPenetrationDepth: Float, layer: ObjectLayer, in system: PhysicsSystem
  ) -> Bool {
    JPH_CharacterVirtual_SetShape(raw, shape.raw, maxPenetrationDepth, layer, system.raw, nil, nil)
  }

  public var mass: Float {
    get { JPH_CharacterVirtual_GetMass(raw) }
    set { JPH_CharacterVirtual_SetMass(raw, newValue) }
  }

  public var maxStrength: Float {
    get { JPH_CharacterVirtual_GetMaxStrength(raw) }
    set { JPH_CharacterVirtual_SetMaxStrength(raw, newValue) }
  }

  public func getWorldTransform() -> RMat44 {
    var result = JPH_RMat4()
    JPH_CharacterVirtual_GetWorldTransform(raw, &result)
    return RMat44(result)
  }

  public func getInnerBodyID() -> BodyID {
    JPH_CharacterVirtual_GetInnerBodyID(raw)
  }
}
