import CJolt

public protocol Shape { var raw: OpaquePointer? { get } }

public final class BoxShape: Shape {
  public let raw: OpaquePointer?

  public init(halfExtent: Vec3, convexRadius: Float = JoltDefaults.convexRadius) {
    var he = halfExtent.cValue
    let box = JPH_BoxShape_Create(&he, convexRadius)
    self.raw = box
  }

  deinit {
    if let raw { JPH_Shape_Destroy(raw) }
  }
}

public final class SphereShape: Shape {
  public let raw: OpaquePointer?

  public init(radius: Float) {
    let sphere = JPH_SphereShape_Create(radius)
    self.raw = sphere
  }

  deinit {
    if let raw { JPH_Shape_Destroy(raw) }
  }
}

public final class CapsuleShape: Shape {
  public let raw: OpaquePointer?

  public init(halfHeight: Float, radius: Float) {
    let cap = JPH_CapsuleShape_Create(halfHeight, radius)
    self.raw = cap
  }

  deinit { if let raw { JPH_Shape_Destroy(raw) } }
}

public final class CylinderShape: Shape {
  public let raw: OpaquePointer?

  public init(halfHeight: Float, radius: Float) {
    let cyl = JPH_CylinderShape_Create(halfHeight, radius)
    self.raw = cyl
  }

  deinit { if let raw { JPH_Shape_Destroy(raw) } }
}

public final class PlaneShape: Shape {
  public let raw: OpaquePointer?

  public init(plane: Plane, material: PhysicsMaterial? = nil, halfExtent: Float = 1.0) {
    var cPlane = plane.cValue
    let settings = JPH_PlaneShapeSettings_Create(&cPlane, material?.raw, halfExtent)
    self.raw = JPH_PlaneShapeSettings_CreateShape(settings)
    // TODO: Need to destroy settings
  }

  public convenience init(
    normal: Vec3, distance: Float, material: PhysicsMaterial? = nil, halfExtent: Float = 1.0
  ) {
    let plane = Plane(normal: normal, distance: distance)
    self.init(plane: plane, material: material, halfExtent: halfExtent)
  }

  public func getPlane() -> Plane {
    var out = JPH_Plane(normal: JPH_Vec3(x: 0, y: 0, z: 0), distance: 0)
    JPH_PlaneShape_GetPlane(raw, &out)
    return Plane(out)
  }

  public func getHalfExtent() -> Float {
    JPH_PlaneShape_GetHalfExtent(raw)
  }

  deinit { if let raw { JPH_Shape_Destroy(raw) } }
}

public final class TriangleShape: Shape {
  public let raw: OpaquePointer?

  public init(
    vertex1: Vec3, vertex2: Vec3, vertex3: Vec3, convexRadius: Float = JoltDefaults.convexRadius
  ) {
    var v1 = vertex1.cValue
    var v2 = vertex2.cValue
    var v3 = vertex3.cValue
    let settings = JPH_TriangleShapeSettings_Create(&v1, &v2, &v3, convexRadius)
    self.raw = JPH_TriangleShapeSettings_CreateShape(settings)
    // TODO: Need to destroy settings
  }

  public func getConvexRadius() -> Float {
    JPH_TriangleShape_GetConvexRadius(raw)
  }

  public func getVertex1() -> Vec3 {
    var out = JPH_Vec3(x: 0, y: 0, z: 0)
    JPH_TriangleShape_GetVertex1(raw, &out)
    return Vec3(out)
  }

  public func getVertex2() -> Vec3 {
    var out = JPH_Vec3(x: 0, y: 0, z: 0)
    JPH_TriangleShape_GetVertex2(raw, &out)
    return Vec3(out)
  }

  public func getVertex3() -> Vec3 {
    var out = JPH_Vec3(x: 0, y: 0, z: 0)
    JPH_TriangleShape_GetVertex3(raw, &out)
    return Vec3(out)
  }

  deinit { if let raw { JPH_Shape_Destroy(raw) } }
}

public final class TaperedCylinderShape: Shape {
  public let raw: OpaquePointer?

  public init(
    halfHeightOfTaperedCylinder: Float, topRadius: Float, bottomRadius: Float,
    convexRadius: Float = JoltDefaults.convexRadius, material: PhysicsMaterial? = nil
  ) {
    let settings = JPH_TaperedCylinderShapeSettings_Create(
      halfHeightOfTaperedCylinder, topRadius, bottomRadius, convexRadius, material?.raw)
    self.raw = JPH_TaperedCylinderShapeSettings_CreateShape(settings)
    // TODO: Need to destroy settings
  }

  public func getTopRadius() -> Float {
    JPH_TaperedCylinderShape_GetTopRadius(raw)
  }

  public func getBottomRadius() -> Float {
    JPH_TaperedCylinderShape_GetBottomRadius(raw)
  }

  public func getConvexRadius() -> Float {
    JPH_TaperedCylinderShape_GetConvexRadius(raw)
  }

  public func getHalfHeight() -> Float {
    JPH_TaperedCylinderShape_GetHalfHeight(raw)
  }

  deinit { if let raw { JPH_Shape_Destroy(raw) } }
}

public final class ConvexHullShape: Shape {
  public let raw: OpaquePointer?

  public init(points: [Vec3], maxConvexRadius: Float = JoltDefaults.convexRadius) {
    var cPoints = points.map { $0.cValue }
    let settings = JPH_ConvexHullShapeSettings_Create(
      &cPoints, UInt32(points.count), maxConvexRadius)
    self.raw = JPH_ConvexHullShapeSettings_CreateShape(settings)
    // TODO: Need to destroy settings
  }

  public func getNumPoints() -> UInt32 {
    JPH_ConvexHullShape_GetNumPoints(raw)
  }

  public func getPoint(_ index: UInt32) -> Vec3 {
    var out = JPH_Vec3(x: 0, y: 0, z: 0)
    JPH_ConvexHullShape_GetPoint(raw, index, &out)
    return Vec3(out)
  }

  public func getNumFaces() -> UInt32 {
    JPH_ConvexHullShape_GetNumFaces(raw)
  }

  public func getNumVerticesInFace(_ faceIndex: UInt32) -> UInt32 {
    JPH_ConvexHullShape_GetNumVerticesInFace(raw, faceIndex)
  }

  public func getFaceVertices(_ faceIndex: UInt32, maxVertices: UInt32) -> [UInt32] {
    var vertices = [UInt32](repeating: 0, count: Int(maxVertices))
    let count = JPH_ConvexHullShape_GetFaceVertices(raw, faceIndex, maxVertices, &vertices)
    return Array(vertices.prefix(Int(count)))
  }

  deinit { if let raw { JPH_Shape_Destroy(raw) } }
}

public final class MeshShape: Shape {
  public let raw: OpaquePointer?

  public init(triangles: [Triangle], maxTrianglesPerLeaf: UInt32 = 4) {
    var cTriangles = triangles.map { $0.cValue }
    let settings = JPH_MeshShapeSettings_Create(&cTriangles, UInt32(triangles.count))
    JPH_MeshShapeSettings_SetMaxTrianglesPerLeaf(settings, maxTrianglesPerLeaf)
    self.raw = JPH_MeshShapeSettings_CreateShape(settings)
    // TODO: Need to destroy settings
  }

  public init(vertices: [Vec3], triangles: [IndexedTriangle]) {
    var cVertices = vertices.map { $0.cValue }
    var cTriangles = triangles.map { $0.cValue }
    let settings = JPH_MeshShapeSettings_Create2(
      &cVertices, UInt32(vertices.count), &cTriangles, UInt32(triangles.count))
    self.raw = JPH_MeshShapeSettings_CreateShape(settings)
    // TODO: Need to destroy settings
  }

  public func getTriangleUserData(_ id: SubShapeID) -> UInt32 {
    JPH_MeshShape_GetTriangleUserData(raw, id)
  }

  deinit { if let raw { JPH_Shape_Destroy(raw) } }
}
