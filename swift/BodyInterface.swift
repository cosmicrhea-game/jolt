import CJolt

public final class BodyInterface {
  public let raw: OpaquePointer?

  internal init(raw: OpaquePointer?) { self.raw = raw }

  @discardableResult
  public func createAndAddBody(settings: BodyCreationSettings, activation: Activation = .activate)
    -> BodyID
  {
    guard let raw else { return 0 }
    return JPH_BodyInterface_CreateAndAddBody(
      raw, settings.raw, JPH_Activation(activation.rawValue))
  }

  public func addBody(_ id: BodyID, activation: Activation = .activate) {
    guard let raw else { return }
    JPH_BodyInterface_AddBody(raw, id, JPH_Activation(activation.rawValue))
  }

  public func removeBody(_ id: BodyID) {
    guard let raw else { return }
    JPH_BodyInterface_RemoveBody(raw, id)
  }

  public func setLinearVelocity(_ id: BodyID, _ velocity: Vec3) {
    guard let raw else { return }
    var v = velocity.cValue
    JPH_BodyInterface_SetLinearVelocity(raw, id, &v)
  }

  public func getLinearVelocity(_ id: BodyID) -> Vec3 {
    guard let raw else { return .zero }
    var out = JPH_Vec3(x: 0, y: 0, z: 0)
    JPH_BodyInterface_GetLinearVelocity(raw, id, &out)
    return Vec3(out)
  }

  public func body(_ id: BodyID, in world: PhysicsSystem) -> Body {
    Body(id: id, world: world)
  }

  public func isActive(_ id: BodyID) -> Bool {
    guard let raw else { return false }
    return JPH_BodyInterface_IsActive(raw, id)
  }

  public func getCenterOfMassPosition(_ id: BodyID) -> RVec3 {
    guard let raw else { return .init(x: 0, y: 0, z: 0) }
    var out = JPH_RVec3(x: 0, y: 0, z: 0)
    JPH_BodyInterface_GetCenterOfMassPosition(raw, id, &out)
    return RVec3(out)
  }

  public func removeAndDestroyBody(_ id: BodyID) {
    guard let raw else { return }
    JPH_BodyInterface_RemoveAndDestroyBody(raw, id)
  }
}
