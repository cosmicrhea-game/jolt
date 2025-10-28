import CJolt

// MARK: - Core aliases (prefer Jolt names)

public typealias JoltBool = UInt32  // Matches JPH_Bool ABI
public typealias BodyID = UInt32
public typealias SubShapeID = UInt32
public typealias ObjectLayer = UInt32
public typealias BroadPhaseLayer = UInt8
public typealias CollisionGroupID = UInt32
public typealias CollisionSubGroupID = UInt32
public typealias CharacterID = UInt32

// MARK: - Enums (RawRepresentable wrappers)

@frozen
public struct PhysicsUpdateError: OptionSet, Sendable {
  public let rawValue: UInt32
  public init(rawValue: UInt32) { self.rawValue = rawValue }
  public static let none: PhysicsUpdateError = []
  public static let manifoldCacheFull = PhysicsUpdateError(rawValue: 1)
  public static let bodyPairCacheFull = PhysicsUpdateError(rawValue: 2)
  public static let contactConstraintsFull = PhysicsUpdateError(rawValue: 4)
}

public enum BodyType: UInt32 {
  case rigid = 0
  case soft = 1
}

public enum MotionType: UInt32 {
  case `static` = 0
  case kinematic = 1
  case dynamic = 2
}

public enum Activation: UInt32 {
  case activate = 0
  case dontActivate = 1
}

public enum MotionQuality: UInt32 {
  case discrete = 0
  case linearCast = 1
}

public enum OverrideMassProperties: UInt32 {
  case calculateMassAndInertia = 0
  case calculateInertia = 1
  case massAndInertiaProvided = 2
}

public struct AllowedDOFs: OptionSet, Sendable {
  public let rawValue: UInt32
  public init(rawValue: UInt32) { self.rawValue = rawValue }
  // Use literal masks to avoid enum bridging issues in Swift import
  public static let all = AllowedDOFs(rawValue: 0b111111)
  public static let translationX = AllowedDOFs(rawValue: 0b000001)
  public static let translationY = AllowedDOFs(rawValue: 0b000010)
  public static let translationZ = AllowedDOFs(rawValue: 0b000100)
  public static let rotationX = AllowedDOFs(rawValue: 0b001000)
  public static let rotationY = AllowedDOFs(rawValue: 0b010000)
  public static let rotationZ = AllowedDOFs(rawValue: 0b100000)
  public static let plane2D: AllowedDOFs = [.translationX, .translationY, .rotationZ]
}

// MARK: - Constants

public enum JoltDefaults {
  public static let collisionTolerance: Float = JPH_DEFAULT_COLLISION_TOLERANCE
  public static let penetrationTolerance: Float = JPH_DEFAULT_PENETRATION_TOLERANCE
  public static let convexRadius: Float = JPH_DEFAULT_CONVEX_RADIUS
  public static let capsuleProjectionSlop: Float = JPH_CAPSULE_PROJECTION_SLOP
  public static let maxPhysicsJobs: Int = Int(JPH_MAX_PHYSICS_JOBS)
  public static let maxPhysicsBarriers: Int = Int(JPH_MAX_PHYSICS_BARRIERS)
}

// MARK: - Materials

public final class PhysicsMaterial {
  public let raw: OpaquePointer?

  public init(name: String, color: UInt32) {
    let cName = name.cString(using: .utf8)
    let material = JPH_PhysicsMaterial_Create(cName, color)
    self.raw = material
  }

  public func getDebugName() -> String {
    guard let name = JPH_PhysicsMaterial_GetDebugName(raw) else { return "" }
    return String(cString: name)
  }

  public func getDebugColor() -> UInt32 {
    JPH_PhysicsMaterial_GetDebugColor(raw)
  }

  deinit {
    if let raw {
      JPH_PhysicsMaterial_Destroy(raw)
    }
  }
}
