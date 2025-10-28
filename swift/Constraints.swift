import CJolt

public protocol Constraint { var raw: OpaquePointer? { get } }

public struct SpringSettings {
  public var mode: UInt32 = JPH_SpringMode_FrequencyAndDamping.rawValue
  public var frequencyOrStiffness: Float = 0
  public var damping: Float = 0

  @inline(__always)
  public var cValue: JPH_SpringSettings {
    JPH_SpringSettings(
      mode: JPH_SpringMode(mode),
      frequencyOrStiffness: frequencyOrStiffness,
      damping: damping
    )
  }
}

public struct MotorSettings {
  public var springSettings: SpringSettings = SpringSettings()
  public var minForceLimit: Float = 0
  public var maxForceLimit: Float = 0
  public var minTorqueLimit: Float = 0
  public var maxTorqueLimit: Float = 0

  @inline(__always)
  public var cValue: JPH_MotorSettings {
    JPH_MotorSettings(
      springSettings: springSettings.cValue,
      minForceLimit: minForceLimit,
      maxForceLimit: maxForceLimit,
      minTorqueLimit: minTorqueLimit,
      maxTorqueLimit: maxTorqueLimit
    )
  }
}

public struct FixedConstraintSettings {
  public var space: UInt32 = JPH_ConstraintSpace_WorldSpace.rawValue
  public var autoDetectPoint: Bool = true
  public var point1: RVec3 = .init(x: 0, y: 0, z: 0)
  public var axisX1: Vec3 = .init(x: 1, y: 0, z: 0)
  public var axisY1: Vec3 = .init(x: 0, y: 1, z: 0)
  public var point2: RVec3 = .init(x: 0, y: 0, z: 0)
  public var axisX2: Vec3 = .init(x: 1, y: 0, z: 0)
  public var axisY2: Vec3 = .init(x: 0, y: 1, z: 0)

  @inline(__always)
  func withC<R>(_ body: (inout JPH_FixedConstraintSettings) -> R) -> R {
    var c = JPH_FixedConstraintSettings(
      base: JPH_ConstraintSettings(
        enabled: true,
        constraintPriority: 0,
        numVelocityStepsOverride: 0,
        numPositionStepsOverride: 0,
        drawConstraintSize: 0,
        userData: 0
      ),
      space: JPH_ConstraintSpace(space),
      autoDetectPoint: autoDetectPoint,
      point1: point1.cValue,
      axisX1: axisX1.cValue,
      axisY1: axisY1.cValue,
      point2: point2.cValue,
      axisX2: axisX2.cValue,
      axisY2: axisY2.cValue
    )
    return body(&c)
  }
}

public final class FixedConstraint: Constraint {
  public let raw: OpaquePointer?
  public init(settings: FixedConstraintSettings, body1: OpaquePointer?, body2: OpaquePointer?) {
    let c = settings.withC { c in JPH_FixedConstraint_Create(&c, body1, body2) }
    self.raw = c
  }
}

public struct HingeConstraintSettings {
  public var space: UInt32 = JPH_ConstraintSpace_WorldSpace.rawValue
  public var point1: RVec3 = .init(x: 0, y: 0, z: 0)
  public var hingeAxis1: Vec3 = .init(x: 1, y: 0, z: 0)
  public var normalAxis1: Vec3 = .init(x: 0, y: 1, z: 0)
  public var point2: RVec3 = .init(x: 0, y: 0, z: 0)
  public var hingeAxis2: Vec3 = .init(x: 1, y: 0, z: 0)
  public var normalAxis2: Vec3 = .init(x: 0, y: 1, z: 0)
  public var limitsMin: Float = 0
  public var limitsMax: Float = 0
  public var limitsSpringSettings: SpringSettings = SpringSettings()
  public var maxFrictionTorque: Float = 0
  public var motorSettings: MotorSettings = MotorSettings()

  @inline(__always)
  func withC<R>(_ body: (inout JPH_HingeConstraintSettings) -> R) -> R {
    var c = JPH_HingeConstraintSettings(
      base: JPH_ConstraintSettings(
        enabled: true,
        constraintPriority: 0,
        numVelocityStepsOverride: 0,
        numPositionStepsOverride: 0,
        drawConstraintSize: 0,
        userData: 0
      ),
      space: JPH_ConstraintSpace(space),
      point1: point1.cValue,
      hingeAxis1: hingeAxis1.cValue,
      normalAxis1: normalAxis1.cValue,
      point2: point2.cValue,
      hingeAxis2: hingeAxis2.cValue,
      normalAxis2: normalAxis2.cValue,
      limitsMin: limitsMin,
      limitsMax: limitsMax,
      limitsSpringSettings: limitsSpringSettings.cValue,
      maxFrictionTorque: maxFrictionTorque,
      motorSettings: motorSettings.cValue
    )
    return body(&c)
  }
}

public final class HingeConstraint: Constraint {
  public let raw: OpaquePointer?
  public init(settings: HingeConstraintSettings, body1: OpaquePointer?, body2: OpaquePointer?) {
    let c = settings.withC { c in JPH_HingeConstraint_Create(&c, body1, body2) }
    self.raw = c
  }
}

public struct DistanceConstraintSettings {
  public var space: UInt32 = JPH_ConstraintSpace_WorldSpace.rawValue
  public var point1: RVec3 = .init(x: 0, y: 0, z: 0)
  public var point2: RVec3 = .init(x: 0, y: 0, z: 0)
  public var minDistance: Float = 0
  public var maxDistance: Float = 0
  public var limitsSpringSettings: SpringSettings = SpringSettings()

  @inline(__always)
  func withC<R>(_ body: (inout JPH_DistanceConstraintSettings) -> R) -> R {
    var c = JPH_DistanceConstraintSettings(
      base: JPH_ConstraintSettings(
        enabled: true,
        constraintPriority: 0,
        numVelocityStepsOverride: 0,
        numPositionStepsOverride: 0,
        drawConstraintSize: 0,
        userData: 0
      ),
      space: JPH_ConstraintSpace(space),
      point1: point1.cValue,
      point2: point2.cValue,
      minDistance: minDistance,
      maxDistance: maxDistance,
      limitsSpringSettings: limitsSpringSettings.cValue
    )
    return body(&c)
  }
}

public final class DistanceConstraint: Constraint {
  public let raw: OpaquePointer?
  public init(settings: DistanceConstraintSettings, body1: OpaquePointer?, body2: OpaquePointer?) {
    let c = settings.withC { c in JPH_DistanceConstraint_Create(&c, body1, body2) }
    self.raw = c
  }
}

public struct PointConstraintSettings {
  public var space: UInt32 = JPH_ConstraintSpace_WorldSpace.rawValue
  public var point1: RVec3 = .init(x: 0, y: 0, z: 0)
  public var point2: RVec3 = .init(x: 0, y: 0, z: 0)

  @inline(__always)
  func withC<R>(_ body: (inout JPH_PointConstraintSettings) -> R) -> R {
    var c = JPH_PointConstraintSettings(
      base: JPH_ConstraintSettings(
        enabled: true,
        constraintPriority: 0,
        numVelocityStepsOverride: 0,
        numPositionStepsOverride: 0,
        drawConstraintSize: 0,
        userData: 0
      ),
      space: JPH_ConstraintSpace(space),
      point1: point1.cValue,
      point2: point2.cValue
    )
    return body(&c)
  }
}

public final class PointConstraint: Constraint {
  public let raw: OpaquePointer?
  public init(settings: PointConstraintSettings, body1: OpaquePointer?, body2: OpaquePointer?) {
    let c = settings.withC { c in JPH_PointConstraint_Create(&c, body1, body2) }
    self.raw = c
  }
}

public struct SliderConstraintSettings {
  public var space: UInt32 = JPH_ConstraintSpace_WorldSpace.rawValue
  public var autoDetectPoint: Bool = true
  public var point1: RVec3 = .init(x: 0, y: 0, z: 0)
  public var sliderAxis1: Vec3 = .init(x: 1, y: 0, z: 0)
  public var normalAxis1: Vec3 = .init(x: 0, y: 1, z: 0)
  public var point2: RVec3 = .init(x: 0, y: 0, z: 0)
  public var sliderAxis2: Vec3 = .init(x: 1, y: 0, z: 0)
  public var normalAxis2: Vec3 = .init(x: 0, y: 1, z: 0)
  public var limitsMin: Float = 0
  public var limitsMax: Float = 0
  public var limitsSpringSettings: SpringSettings = SpringSettings()
  public var maxFrictionForce: Float = 0
  public var motorSettings: MotorSettings = MotorSettings()

  @inline(__always)
  func withC<R>(_ body: (inout JPH_SliderConstraintSettings) -> R) -> R {
    var c = JPH_SliderConstraintSettings(
      base: JPH_ConstraintSettings(
        enabled: true,
        constraintPriority: 0,
        numVelocityStepsOverride: 0,
        numPositionStepsOverride: 0,
        drawConstraintSize: 0,
        userData: 0
      ),
      space: JPH_ConstraintSpace(space),
      autoDetectPoint: autoDetectPoint,
      point1: point1.cValue,
      sliderAxis1: sliderAxis1.cValue,
      normalAxis1: normalAxis1.cValue,
      point2: point2.cValue,
      sliderAxis2: sliderAxis2.cValue,
      normalAxis2: normalAxis2.cValue,
      limitsMin: limitsMin,
      limitsMax: limitsMax,
      limitsSpringSettings: limitsSpringSettings.cValue,
      maxFrictionForce: maxFrictionForce,
      motorSettings: motorSettings.cValue
    )
    return body(&c)
  }
}

public final class SliderConstraint: Constraint {
  public let raw: OpaquePointer?
  public init(settings: SliderConstraintSettings, body1: OpaquePointer?, body2: OpaquePointer?) {
    let c = settings.withC { c in JPH_SliderConstraint_Create(&c, body1, body2) }
    self.raw = c
  }
}

extension PhysicsSystem {
  public func addConstraint(_ constraint: Constraint) {
    guard let c = constraint.raw else { return }
    JPH_PhysicsSystem_AddConstraint(raw, c)
  }

  public func removeConstraint(_ constraint: Constraint) {
    guard let c = constraint.raw else { return }
    JPH_PhysicsSystem_RemoveConstraint(raw, c)
  }
}
