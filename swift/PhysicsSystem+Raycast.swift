import CJolt

public struct RayHit {
  public var bodyID: BodyID
  public var fraction: Float
  public init(_ c: JPH_RayCastResult) {
    self.bodyID = c.bodyID
    self.fraction = c.fraction
  }
}

public struct RayCastSettings {
  public var backFaceModeTriangles: UInt32 = JPH_BackFaceMode_IgnoreBackFaces.rawValue
  public var backFaceModeConvex: UInt32 = JPH_BackFaceMode_IgnoreBackFaces.rawValue
  public var treatConvexAsSolid: Bool = true

  @inline(__always)
  public var cValue: JPH_RayCastSettings {
    JPH_RayCastSettings(
      backFaceModeTriangles: JPH_BackFaceMode(backFaceModeTriangles),
      backFaceModeConvex: JPH_BackFaceMode(backFaceModeConvex),
      treatConvexAsSolid: treatConvexAsSolid
    )
  }
}

@inline(__always)
private func makeRayCastSettings(_ settings: RayCastSettings?) -> JPH_RayCastSettings {
  settings?.cValue
    ?? JPH_RayCastSettings(
      backFaceModeTriangles: JPH_BackFaceMode(JPH_BackFaceMode_IgnoreBackFaces.rawValue),
      backFaceModeConvex: JPH_BackFaceMode(JPH_BackFaceMode_IgnoreBackFaces.rawValue),
      treatConvexAsSolid: true
    )
}

private final class RayHitCollectorBox {
  var hits: [RayHit] = []
}

private func withCollectorBox<R>(_ body: (UnsafeMutableRawPointer?) -> R) -> (R, [RayHit]) {
  let box = RayHitCollectorBox()
  let result = body(Unmanaged.passUnretained(box).toOpaque())
  return (result, box.hits)
}

@_cdecl("swift_rayCastResultCallback")
private func swift_rayCastResultCallback(
  _ context: UnsafeMutableRawPointer?, _ result: UnsafePointer<JPH_RayCastResult>?
) {
  guard let context, let result else { return }
  let box = Unmanaged<RayHitCollectorBox>.fromOpaque(context).takeUnretainedValue()
  box.hits.append(RayHit(result.pointee))
}

extension PhysicsSystem {
  public func castRaySingle(origin: RVec3, direction: Vec3) -> RayHit? {
    var hit = JPH_RayCastResult(bodyID: 0, fraction: 0, subShapeID2: 0)
    var o = origin.cValue
    var d = direction.cValue
    let ok = JPH_NarrowPhaseQuery_CastRay(
      JPH_PhysicsSystem_GetNarrowPhaseQuery(self.raw),
      &o, &d, &hit,
      nil, nil, nil
    )
    return ok ? RayHit(hit) : nil
  }

  public func castRayAny(origin: RVec3, direction: Vec3) -> Bool {
    var hit = JPH_RayCastResult(bodyID: 0, fraction: 0, subShapeID2: 0)
    var o = origin.cValue
    var d = direction.cValue
    let ok = JPH_NarrowPhaseQuery_CastRay(
      JPH_PhysicsSystem_GetNarrowPhaseQuery(self.raw),
      &o, &d, &hit,
      nil, nil, nil
    )
    return ok
  }

  public func castRayAll(
    origin: RVec3, direction: Vec3, settings: RayCastSettings? = nil, sorted: Bool = true
  ) -> [RayHit] {
    var o = origin.cValue
    var d = direction.cValue
    var s = makeRayCastSettings(settings)
    let collectorType: JPH_CollisionCollectorType =
      sorted ? JPH_CollisionCollectorType_AllHitSorted : JPH_CollisionCollectorType_AllHit
    let (_, hits) = withCollectorBox { ctx in
      _ = JPH_NarrowPhaseQuery_CastRay3(
        JPH_PhysicsSystem_GetNarrowPhaseQuery(self.raw),
        &o, &d,
        &s,
        collectorType,
        swift_rayCastResultCallback,
        ctx,
        nil, nil, nil, nil
      )
    }
    if sorted {
      return hits.sorted { $0.fraction < $1.fraction }
    }
    return hits
  }

  public func collidePointAll(point: RVec3) -> [BodyID] {
    var p = point.cValue
    final class Box { var ids: [BodyID] = [] }
    let box = Box()
    let cb:
      @convention(c) (UnsafeMutableRawPointer?, UnsafePointer<JPH_CollidePointResult>?) -> Float = {
        ctx, res in
        guard let ctx, let res else { return 1.0 }
        let b = Unmanaged<Box>.fromOpaque(ctx).takeUnretainedValue()
        b.ids.append(res.pointee.bodyID)
        return 1.0
      }
    let ctx = Unmanaged.passUnretained(box).toOpaque()
    _ = JPH_NarrowPhaseQuery_CollidePoint(
      JPH_PhysicsSystem_GetNarrowPhaseQuery(self.raw),
      &p,
      cb,
      ctx,
      nil, nil, nil, nil
    )
    return box.ids
  }

  public func collideShapeAll(
    shape: Shape, scale: Vec3 = .init(x: 1, y: 1, z: 1),
    centerOfMassTransform: JPH_RMat4? = nil, baseOffset: inout RVec3
  ) -> [JPH_CollideShapeResult] {
    var sc = scale.cValue
    var com = centerOfMassTransform ?? JPH_RMat4()
    var offset = baseOffset.cValue
    var settings = JPH_CollideShapeSettings(
      base: JPH_CollideSettingsBase(
        activeEdgeMode: JPH_ActiveEdgeMode(JPH_ActiveEdgeMode_CollideOnlyWithActive.rawValue),
        collectFacesMode: JPH_CollectFacesMode(JPH_CollectFacesMode_NoFaces.rawValue),
        collisionTolerance: JPH_DEFAULT_COLLISION_TOLERANCE,
        penetrationTolerance: JPH_DEFAULT_PENETRATION_TOLERANCE,
        activeEdgeMovementDirection: JPH_Vec3(x: 0, y: 0, z: 0)
      ),
      maxSeparationDistance: 0,
      backFaceMode: JPH_BackFaceMode(JPH_BackFaceMode_IgnoreBackFaces.rawValue)
    )

    final class Box { var results: [JPH_CollideShapeResult] = [] }
    let box = Box()
    let cb:
      @convention(c) (UnsafeMutableRawPointer?, UnsafePointer<JPH_CollideShapeResult>?) -> Void = {
        ctx, res in
        guard let ctx, let res else { return }
        let b = Unmanaged<Box>.fromOpaque(ctx).takeUnretainedValue()
        b.results.append(res.pointee)
      }

    let ctx2 = Unmanaged.passUnretained(box).toOpaque()
    _ = JPH_NarrowPhaseQuery_CollideShape2(
      JPH_PhysicsSystem_GetNarrowPhaseQuery(self.raw),
      shape.raw, &sc, &com, &settings,
      &offset,
      JPH_CollisionCollectorType_AllHit,
      cb,
      ctx2,
      nil, nil, nil, nil
    )

    baseOffset = RVec3(offset)
    return box.results
  }

  public func castShapeAll(
    shape: Shape, worldTransform: JPH_RMat4, direction: Vec3, baseOffset: inout RVec3
  ) -> [JPH_ShapeCastResult] {
    var wt = worldTransform
    var dir = direction.cValue
    var offset = baseOffset.cValue
    var settings = JPH_ShapeCastSettings(
      base: JPH_CollideSettingsBase(
        activeEdgeMode: JPH_ActiveEdgeMode(JPH_ActiveEdgeMode_CollideOnlyWithActive.rawValue),
        collectFacesMode: JPH_CollectFacesMode(JPH_CollectFacesMode_NoFaces.rawValue),
        collisionTolerance: JPH_DEFAULT_COLLISION_TOLERANCE,
        penetrationTolerance: JPH_DEFAULT_PENETRATION_TOLERANCE,
        activeEdgeMovementDirection: JPH_Vec3(x: 0, y: 0, z: 0)
      ),
      backFaceModeTriangles: JPH_BackFaceMode(JPH_BackFaceMode_IgnoreBackFaces.rawValue),
      backFaceModeConvex: JPH_BackFaceMode(JPH_BackFaceMode_IgnoreBackFaces.rawValue),
      useShrunkenShapeAndConvexRadius: false,
      returnDeepestPoint: false
    )

    final class Box { var results: [JPH_ShapeCastResult] = [] }
    let box = Box()
    let cb: @convention(c) (UnsafeMutableRawPointer?, UnsafePointer<JPH_ShapeCastResult>?) -> Void =
      { ctx, res in
        guard let ctx, let res else { return }
        let b = Unmanaged<Box>.fromOpaque(ctx).takeUnretainedValue()
        b.results.append(res.pointee)
      }

    let ctx3 = Unmanaged.passUnretained(box).toOpaque()
    _ = JPH_NarrowPhaseQuery_CastShape2(
      JPH_PhysicsSystem_GetNarrowPhaseQuery(self.raw),
      shape.raw,
      &wt, &dir, &settings,
      &offset,
      JPH_CollisionCollectorType_AllHit,
      cb,
      ctx3,
      nil, nil, nil, nil
    )

    baseOffset = RVec3(offset)
    return box.results
  }
}
