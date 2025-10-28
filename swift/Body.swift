import CJolt

public struct Body {
  public let id: BodyID
  public unowned let world: PhysicsSystem

  public init(id: BodyID, world: PhysicsSystem) {
    self.id = id
    self.world = world
  }

  private var bi: BodyInterface { world.bodyInterface() }

  // MARK: - Pose
  public var position: RVec3 {
    get {
      var out = JPH_RVec3(x: 0, y: 0, z: 0)
      JPH_BodyInterface_GetPosition(bi.raw, id, &out)
      return RVec3(out)
    }
    set {
      var pos = newValue.cValue
      JPH_BodyInterface_SetPosition(bi.raw, id, &pos, JPH_Activation(Activation.activate.rawValue))
    }
  }

  public var rotation: Quat {
    get {
      var out = JPH_Quat(x: 0, y: 0, z: 0, w: 1)
      JPH_BodyInterface_GetRotation(bi.raw, id, &out)
      return Quat(out)
    }
    set {
      var rot = newValue.cValue
      JPH_BodyInterface_SetRotation(bi.raw, id, &rot, JPH_Activation(Activation.activate.rawValue))
    }
  }

  // MARK: - Velocities
  public var linearVelocity: Vec3 {
    get {
      var out = JPH_Vec3(x: 0, y: 0, z: 0)
      JPH_BodyInterface_GetLinearVelocity(bi.raw, id, &out)
      return Vec3(out)
    }
    set {
      var vv = newValue.cValue
      JPH_BodyInterface_SetLinearVelocity(bi.raw, id, &vv)
    }
  }

  public var angularVelocity: Vec3 {
    get {
      var out = JPH_Vec3(x: 0, y: 0, z: 0)
      JPH_BodyInterface_GetAngularVelocity(bi.raw, id, &out)
      return Vec3(out)
    }
    set {
      var vv = newValue.cValue
      JPH_BodyInterface_SetAngularVelocity(bi.raw, id, &vv)
    }
  }

  // MARK: - Properties
  public var friction: Float {
    get { JPH_BodyInterface_GetFriction(bi.raw, id) }
    set { JPH_BodyInterface_SetFriction(bi.raw, id, newValue) }
  }

  public var restitution: Float {
    get { JPH_BodyInterface_GetRestitution(bi.raw, id) }
    set { JPH_BodyInterface_SetRestitution(bi.raw, id, newValue) }
  }

  public var motionType: MotionType {
    get { MotionType(rawValue: JPH_BodyInterface_GetMotionType(bi.raw, id).rawValue) ?? .dynamic }
    set {
      JPH_BodyInterface_SetMotionType(
        bi.raw, id, JPH_MotionType(newValue.rawValue), JPH_Activation(Activation.activate.rawValue))
    }
  }

  public var isSensor: Bool {
    get { JPH_BodyInterface_IsSensor(bi.raw, id) }
    set { JPH_BodyInterface_SetIsSensor(bi.raw, id, newValue) }
  }

  public var motionQuality: MotionQuality {
    get {
      MotionQuality(rawValue: JPH_BodyInterface_GetMotionQuality(bi.raw, id).rawValue) ?? .discrete
    }
    set { JPH_BodyInterface_SetMotionQuality(bi.raw, id, JPH_MotionQuality(newValue.rawValue)) }
  }

  public var gravityFactor: Float {
    get { JPH_BodyInterface_GetGravityFactor(bi.raw, id) }
    set { JPH_BodyInterface_SetGravityFactor(bi.raw, id, newValue) }
  }

  public var useManifoldReduction: Bool {
    get { JPH_BodyInterface_GetUseManifoldReduction(bi.raw, id) }
    set { JPH_BodyInterface_SetUseManifoldReduction(bi.raw, id, newValue) }
  }

  public var userData: UInt64 {
    get { JPH_BodyInterface_GetUserData(bi.raw, id) }
    set { JPH_BodyInterface_SetUserData(bi.raw, id, newValue) }
  }

  public var objectLayer: ObjectLayer {
    get { JPH_BodyInterface_GetObjectLayer(bi.raw, id) }
    set { JPH_BodyInterface_SetObjectLayer(bi.raw, id, newValue) }
  }

  public func activate() { JPH_BodyInterface_ActivateBody(bi.raw, id) }
  public func deactivate() { JPH_BodyInterface_DeactivateBody(bi.raw, id) }

  // MARK: - Forces/impulses
  public func addForce(_ f: Vec3) {
    var ff = f.cValue
    JPH_BodyInterface_AddForce(bi.raw, id, &ff)
  }

  public func addImpulse(_ i: Vec3) {
    var ii = i.cValue
    JPH_BodyInterface_AddImpulse(bi.raw, id, &ii)
  }

  public func addForce(_ f: Vec3, at position: RVec3) {
    var ff = f.cValue
    var p = position.cValue
    JPH_BodyInterface_AddForce2(bi.raw, id, &ff, &p)
  }

  public func addTorque(_ t: Vec3) {
    var tt = t.cValue
    JPH_BodyInterface_AddTorque(bi.raw, id, &tt)
  }

  public func addForceAndTorque(force: Vec3, torque: Vec3) {
    var f = force.cValue
    var t = torque.cValue
    JPH_BodyInterface_AddForceAndTorque(bi.raw, id, &f, &t)
  }

  public func addAngularImpulse(_ i: Vec3) {
    var ii = i.cValue
    JPH_BodyInterface_AddAngularImpulse(bi.raw, id, &ii)
  }

  public func addImpulse(_ i: Vec3, at position: RVec3) {
    var ii = i.cValue
    var p = position.cValue
    JPH_BodyInterface_AddImpulse2(bi.raw, id, &ii, &p)
  }

  public func setLinearAndAngularVelocity(linear: Vec3, angular: Vec3) {
    var lv = linear.cValue
    var av = angular.cValue
    JPH_BodyInterface_SetLinearAndAngularVelocity(bi.raw, id, &lv, &av)
  }

  public func getPointVelocity(at point: RVec3) -> Vec3 {
    var p = point.cValue
    var out = JPH_Vec3(x: 0, y: 0, z: 0)
    JPH_BodyInterface_GetPointVelocity(bi.raw, id, &p, &out)
    return Vec3(out)
  }

  // MARK: - Kinematic helpers
  public func moveKinematic(targetPosition: RVec3, targetRotation: Quat, deltaTime: Float) {
    var p = targetPosition.cValue
    var r = targetRotation.cValue
    JPH_BodyInterface_MoveKinematic(bi.raw, id, &p, &r, deltaTime)
  }

  // MARK: - Shape
  public func setShape(
    _ shape: Shape, updateMassProperties: Bool = true, activation: Activation = .activate
  ) {
    JPH_BodyInterface_SetShape(
      bi.raw,
      id,
      shape.raw,
      updateMassProperties,
      JPH_Activation(activation.rawValue)
    )
  }
}
