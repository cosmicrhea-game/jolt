import CJolt

public final class BroadPhaseLayerInterfaceMask {
  public let raw: OpaquePointer?
  public init(numBroadPhaseLayers: UInt32) {
    self.raw = JPH_BroadPhaseLayerInterfaceMask_Create(numBroadPhaseLayers)
  }
  public func configureLayer(
    _ broadPhaseLayer: BroadPhaseLayer, include groupsToInclude: UInt32,
    exclude groupsToExclude: UInt32
  ) {
    guard let raw else { return }
    JPH_BroadPhaseLayerInterfaceMask_ConfigureLayer(
      raw, broadPhaseLayer, groupsToInclude, groupsToExclude)
  }
}

public final class BroadPhaseLayerInterfaceTable {
  public let raw: OpaquePointer?
  public init(numObjectLayers: UInt32, numBroadPhaseLayers: UInt32) {
    self.raw = JPH_BroadPhaseLayerInterfaceTable_Create(numObjectLayers, numBroadPhaseLayers)
  }
  public func map(objectLayer: ObjectLayer, to broadPhaseLayer: BroadPhaseLayer) {
    guard let raw else { return }
    JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(raw, objectLayer, broadPhaseLayer)
  }
}

public final class ObjectLayerPairFilterMask {
  public let raw: OpaquePointer?
  public init() { self.raw = JPH_ObjectLayerPairFilterMask_Create() }
  public func group(for layer: ObjectLayer) -> UInt32 {
    JPH_ObjectLayerPairFilterMask_GetGroup(layer)
  }
  public func mask(for layer: ObjectLayer) -> UInt32 {
    JPH_ObjectLayerPairFilterMask_GetMask(layer)
  }
  public func objectLayer(group: UInt32, mask: UInt32) -> ObjectLayer {
    JPH_ObjectLayerPairFilterMask_GetObjectLayer(group, mask)
  }
}

public final class ObjectLayerPairFilterTable {
  public let raw: OpaquePointer?
  public init(numObjectLayers: UInt32) {
    self.raw = JPH_ObjectLayerPairFilterTable_Create(numObjectLayers)
  }
  public func disableCollision(_ a: ObjectLayer, _ b: ObjectLayer) {
    guard let raw else { return }
    JPH_ObjectLayerPairFilterTable_DisableCollision(raw, a, b)
  }
  public func enableCollision(_ a: ObjectLayer, _ b: ObjectLayer) {
    guard let raw else { return }
    JPH_ObjectLayerPairFilterTable_EnableCollision(raw, a, b)
  }
  public func shouldCollide(_ a: ObjectLayer, _ b: ObjectLayer) -> Bool {
    guard let raw else { return false }
    return JPH_ObjectLayerPairFilterTable_ShouldCollide(raw, a, b)
  }
}

public final class ObjectVsBroadPhaseLayerFilterTable {
  public let raw: OpaquePointer?
  public init(
    broadPhaseLayerInterface: BroadPhaseLayerInterfaceTable,
    numBroadPhaseLayers: UInt32,
    objectLayerPairFilter: ObjectLayerPairFilterTable,
    numObjectLayers: UInt32
  ) {
    self.raw = JPH_ObjectVsBroadPhaseLayerFilterTable_Create(
      broadPhaseLayerInterface.raw,
      numBroadPhaseLayers,
      objectLayerPairFilter.raw,
      numObjectLayers
    )
  }
}

extension PhysicsSystem {
  public convenience init(
    maxBodies: UInt32 = 65536,
    numBodyMutexes: UInt32 = 0,
    maxBodyPairs: UInt32 = 65536,
    maxContactConstraints: UInt32 = 65536,
    broadPhaseLayerInterface: BroadPhaseLayerInterfaceTable,
    objectLayerPairFilter: ObjectLayerPairFilterTable,
    objectVsBroadPhaseLayerFilter: ObjectVsBroadPhaseLayerFilterTable
  ) {
    let physicsSettings = PhysicsSystemSettings(
      maxBodies: maxBodies,
      numBodyMutexes: numBodyMutexes,
      maxBodyPairs: maxBodyPairs,
      maxContactConstraints: maxContactConstraints
    )

    let cSettings = physicsSettings.withCSettings { cSettings in
      cSettings.broadPhaseLayerInterface = broadPhaseLayerInterface.raw
      cSettings.objectLayerPairFilter = objectLayerPairFilter.raw
      cSettings.objectVsBroadPhaseLayerFilter = objectVsBroadPhaseLayerFilter.raw
      return cSettings
    }

    self.init(cSettings: cSettings)
  }
}
