import CJolt

public struct PhysicsSystemSettings {
  public var maxBodies: UInt32
  public var numBodyMutexes: UInt32
  public var maxBodyPairs: UInt32
  public var maxContactConstraints: UInt32

  public init(
    maxBodies: UInt32, numBodyMutexes: UInt32 = 0, maxBodyPairs: UInt32 = 65536,
    maxContactConstraints: UInt32 = 10240
  ) {
    self.maxBodies = maxBodies
    self.numBodyMutexes = numBodyMutexes
    self.maxBodyPairs = maxBodyPairs
    self.maxContactConstraints = maxContactConstraints
  }

  @inline(__always)
  func withCSettings<R>(_ body: (inout JPH_PhysicsSystemSettings) -> R) -> R {
    var c = JPH_PhysicsSystemSettings(
      maxBodies: maxBodies,
      numBodyMutexes: numBodyMutexes,
      maxBodyPairs: maxBodyPairs,
      maxContactConstraints: maxContactConstraints,
      _padding: 0,
      broadPhaseLayerInterface: nil,
      objectLayerPairFilter: nil,
      objectVsBroadPhaseLayerFilter: nil
    )
    return body(&c)
  }
}

public struct PhysicsSettings {
  // Int fields
  public var maxInFlightBodyPairs: Int32?
  public var stepListenersBatchSize: Int32?
  public var stepListenerBatchesPerJob: Int32?

  // Float fields
  public var baumgarte: Float?
  public var speculativeContactDistance: Float?
  public var penetrationSlop: Float?
  public var linearCastThreshold: Float?
  public var linearCastMaxPenetration: Float?
  public var manifoldTolerance: Float?
  public var maxPenetrationDistance: Float?
  public var bodyPairCacheMaxDeltaPositionSq: Float?
  public var bodyPairCacheCosMaxDeltaRotationDiv2: Float?
  public var contactNormalCosMaxDeltaRotation: Float?
  public var contactPointPreserveLambdaMaxDistSq: Float?
  public var minVelocityForRestitution: Float?
  public var timeBeforeSleep: Float?
  public var pointVelocitySleepThreshold: Float?

  // UInt32 fields
  public var numVelocitySteps: UInt32?
  public var numPositionSteps: UInt32?

  // Bool fields
  public var deterministicSimulation: Bool?
  public var constraintWarmStart: Bool?
  public var useBodyPairContactCache: Bool?
  public var useManifoldReduction: Bool?
  public var useLargeIslandSplitter: Bool?
  public var allowSleeping: Bool?
  public var checkActiveEdges: Bool?

  public init() {}

  @inline(__always)
  func apply(to c: inout JPH_PhysicsSettings) {
    if let value = maxInFlightBodyPairs { c.maxInFlightBodyPairs = value }
    if let value = stepListenersBatchSize { c.stepListenersBatchSize = value }
    if let value = stepListenerBatchesPerJob { c.stepListenerBatchesPerJob = value }

    if let value = baumgarte { c.baumgarte = value }
    if let value = speculativeContactDistance { c.speculativeContactDistance = value }
    if let value = penetrationSlop { c.penetrationSlop = value }
    if let value = linearCastThreshold { c.linearCastThreshold = value }
    if let value = linearCastMaxPenetration { c.linearCastMaxPenetration = value }
    if let value = manifoldTolerance { c.manifoldTolerance = value }
    if let value = maxPenetrationDistance { c.maxPenetrationDistance = value }
    if let value = bodyPairCacheMaxDeltaPositionSq { c.bodyPairCacheMaxDeltaPositionSq = value }
    if let value = bodyPairCacheCosMaxDeltaRotationDiv2 {
      c.bodyPairCacheCosMaxDeltaRotationDiv2 = value
    }
    if let value = contactNormalCosMaxDeltaRotation { c.contactNormalCosMaxDeltaRotation = value }
    if let value = contactPointPreserveLambdaMaxDistSq {
      c.contactPointPreserveLambdaMaxDistSq = value
    }

    if let value = numVelocitySteps { c.numVelocitySteps = value }
    if let value = numPositionSteps { c.numPositionSteps = value }

    if let value = minVelocityForRestitution { c.minVelocityForRestitution = value }
    if let value = timeBeforeSleep { c.timeBeforeSleep = value }
    if let value = pointVelocitySleepThreshold { c.pointVelocitySleepThreshold = value }

    if let value = deterministicSimulation { c.deterministicSimulation = value }
    if let value = constraintWarmStart { c.constraintWarmStart = value }
    if let value = useBodyPairContactCache { c.useBodyPairContactCache = value }
    if let value = useManifoldReduction { c.useManifoldReduction = value }
    if let value = useLargeIslandSplitter { c.useLargeIslandSplitter = value }
    if let value = allowSleeping { c.allowSleeping = value }
    if let value = checkActiveEdges { c.checkActiveEdges = value }
  }
}

public final class PhysicsSystem {
  public let raw: OpaquePointer

  public init(settings: PhysicsSystemSettings) {
    let ptr: OpaquePointer? = settings.withCSettings { cSettings in
      JPH_PhysicsSystem_Create(&cSettings)
    }
    guard let raw = ptr else { fatalError("Failed to create PhysicsSystem") }
    self.raw = raw
  }

  public convenience init(cSettings: JPH_PhysicsSystemSettings) {
    var mutableSettings = cSettings
    let ptr: OpaquePointer? = JPH_PhysicsSystem_Create(&mutableSettings)
    guard let raw = ptr else { fatalError("Failed to create PhysicsSystem") }
    self.init(raw: raw)
  }

  private init(raw: OpaquePointer) {
    self.raw = raw
  }

  deinit {
    JPH_PhysicsSystem_Destroy(raw)
  }

  public func setPhysicsSettings(_ settings: PhysicsSettings) {
    var c = JPH_PhysicsSettings(
      maxInFlightBodyPairs: 0,
      stepListenersBatchSize: 0,
      stepListenerBatchesPerJob: 0,
      baumgarte: 0,
      speculativeContactDistance: 0,
      penetrationSlop: 0,
      linearCastThreshold: 0,
      linearCastMaxPenetration: 0,
      manifoldTolerance: 0,
      maxPenetrationDistance: 0,
      bodyPairCacheMaxDeltaPositionSq: 0,
      bodyPairCacheCosMaxDeltaRotationDiv2: 0,
      contactNormalCosMaxDeltaRotation: 0,
      contactPointPreserveLambdaMaxDistSq: 0,
      numVelocitySteps: 0,
      numPositionSteps: 0,
      minVelocityForRestitution: 0,
      timeBeforeSleep: 0,
      pointVelocitySleepThreshold: 0,
      deterministicSimulation: false,
      constraintWarmStart: false,
      useBodyPairContactCache: false,
      useManifoldReduction: false,
      useLargeIslandSplitter: false,
      allowSleeping: false,
      checkActiveEdges: false
    )
    JPH_PhysicsSystem_GetPhysicsSettings(raw, &c)
    settings.apply(to: &c)
    JPH_PhysicsSystem_SetPhysicsSettings(raw, &c)
  }

  @discardableResult
  public func update(
    deltaTime: Float, collisionSteps: Int = 1, jobSystem: JobSystemThreadPool? = nil
  ) -> PhysicsUpdateError {
    let result = JPH_PhysicsSystem_Update(raw, deltaTime, Int32(collisionSteps), jobSystem?.raw)
    return PhysicsUpdateError(rawValue: result.rawValue)
  }

  public func setGravity(_ value: Vec3) {
    var c = value.cValue
    JPH_PhysicsSystem_SetGravity(raw, &c)
  }

  public func getGravity() -> Vec3 {
    var out = JPH_Vec3(x: 0, y: 0, z: 0)
    JPH_PhysicsSystem_GetGravity(raw, &out)
    return Vec3(out)
  }

  public func bodyInterface() -> BodyInterface {
    let bi = JPH_PhysicsSystem_GetBodyInterface(raw)
    return BodyInterface(raw: bi)
  }

  public func optimizeBroadPhase() {
    JPH_PhysicsSystem_OptimizeBroadPhase(raw)
  }

  /// Draw all physics bodies using the debug renderer
  /// - Parameters:
  ///   - debugRenderer: The debug renderer to draw with
  public func drawBodies(debugRenderer: DebugRenderer) {
    var cSettings = JPH_DrawSettings()
    JPH_DrawSettings_InitDefault(&cSettings)
    // Enable drawing shapes in wireframe
    cSettings.drawShape = true
    cSettings.drawShapeWireframe = true
    //cSettings.drawShapeColor = JPH_BodyManager_ShapeColor_ShapeTypeColor
    //cSettings.drawBoundingBox = true
    //cSettings.drawCenterOfMassTransform = true
    //cSettings.drawWorldTransform = true
    //cSettings.drawVelocity = true
    //cSettings.drawMassAndInertia = true
    //cSettings.drawSleepStats = true

    JPH_PhysicsSystem_DrawBodies(raw, &cSettings, debugRenderer.raw, nil)
  }
}

extension PhysicsSystem {
  public func getPhysicsSettings() -> PhysicsSettings {
    var c = JPH_PhysicsSettings(
      maxInFlightBodyPairs: 0,
      stepListenersBatchSize: 0,
      stepListenerBatchesPerJob: 0,
      baumgarte: 0,
      speculativeContactDistance: 0,
      penetrationSlop: 0,
      linearCastThreshold: 0,
      linearCastMaxPenetration: 0,
      manifoldTolerance: 0,
      maxPenetrationDistance: 0,
      bodyPairCacheMaxDeltaPositionSq: 0,
      bodyPairCacheCosMaxDeltaRotationDiv2: 0,
      contactNormalCosMaxDeltaRotation: 0,
      contactPointPreserveLambdaMaxDistSq: 0,
      numVelocitySteps: 0,
      numPositionSteps: 0,
      minVelocityForRestitution: 0,
      timeBeforeSleep: 0,
      pointVelocitySleepThreshold: 0,
      deterministicSimulation: false,
      constraintWarmStart: false,
      useBodyPairContactCache: false,
      useManifoldReduction: false,
      useLargeIslandSplitter: false,
      allowSleeping: false,
      checkActiveEdges: false
    )
    JPH_PhysicsSystem_GetPhysicsSettings(raw, &c)
    return PhysicsSettings(from: c)
  }
}

extension PhysicsSettings {
  @inline(__always)
  init(from c: JPH_PhysicsSettings) {
    self.init()
    self.maxInFlightBodyPairs = c.maxInFlightBodyPairs
    self.stepListenersBatchSize = c.stepListenersBatchSize
    self.stepListenerBatchesPerJob = c.stepListenerBatchesPerJob

    self.baumgarte = c.baumgarte
    self.speculativeContactDistance = c.speculativeContactDistance
    self.penetrationSlop = c.penetrationSlop
    self.linearCastThreshold = c.linearCastThreshold
    self.linearCastMaxPenetration = c.linearCastMaxPenetration
    self.manifoldTolerance = c.manifoldTolerance
    self.maxPenetrationDistance = c.maxPenetrationDistance
    self.bodyPairCacheMaxDeltaPositionSq = c.bodyPairCacheMaxDeltaPositionSq
    self.bodyPairCacheCosMaxDeltaRotationDiv2 = c.bodyPairCacheCosMaxDeltaRotationDiv2
    self.contactNormalCosMaxDeltaRotation = c.contactNormalCosMaxDeltaRotation
    self.contactPointPreserveLambdaMaxDistSq = c.contactPointPreserveLambdaMaxDistSq

    self.numVelocitySteps = c.numVelocitySteps
    self.numPositionSteps = c.numPositionSteps

    self.minVelocityForRestitution = c.minVelocityForRestitution
    self.timeBeforeSleep = c.timeBeforeSleep
    self.pointVelocitySleepThreshold = c.pointVelocitySleepThreshold

    self.deterministicSimulation = c.deterministicSimulation
    self.constraintWarmStart = c.constraintWarmStart
    self.useBodyPairContactCache = c.useBodyPairContactCache
    self.useManifoldReduction = c.useManifoldReduction
    self.useLargeIslandSplitter = c.useLargeIslandSplitter
    self.allowSleeping = c.allowSleeping
    self.checkActiveEdges = c.checkActiveEdges
  }
}
