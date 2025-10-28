import CJolt

@frozen
public struct Vec3 {
  public var x: Float
  public var y: Float
  public var z: Float

  public init(x: Float, y: Float, z: Float) {
    self.x = x
    self.y = y
    self.z = z
  }

  public static let zero = Vec3(x: 0, y: 0, z: 0)
}

extension Vec3 {
  @inline(__always)
  public var cValue: JPH_Vec3 { JPH_Vec3(x: x, y: y, z: z) }

  @inline(__always)
  public init(_ c: JPH_Vec3) { self.init(x: c.x, y: c.y, z: c.z) }
}

@frozen
public struct Quat {
  public var x: Float
  public var y: Float
  public var z: Float
  public var w: Float

  public init(x: Float, y: Float, z: Float, w: Float) {
    self.x = x
    self.y = y
    self.z = z
    self.w = w
  }

  public static let identity = Quat(x: 0, y: 0, z: 0, w: 1)
}

extension Quat {
  @inline(__always)
  public var cValue: JPH_Quat { JPH_Quat(x: x, y: y, z: z, w: w) }
  @inline(__always)
  public init(_ c: JPH_Quat) { self.init(x: c.x, y: c.y, z: c.z, w: c.w) }
}

@frozen
public struct RVec3 {
  public var x: Float
  public var y: Float
  public var z: Float

  public init(x: Float, y: Float, z: Float) {
    self.x = x
    self.y = y
    self.z = z
  }
}

extension RVec3 {
  @inline(__always)
  public var cValue: JPH_RVec3 { JPH_RVec3(x: x, y: y, z: z) }
  @inline(__always)
  public init(_ c: JPH_RVec3) { self.init(x: c.x, y: c.y, z: c.z) }
}

@frozen
public struct Mat44 {
  public var m11: Float, m12: Float, m13: Float, m14: Float
  public var m21: Float, m22: Float, m23: Float, m24: Float
  public var m31: Float, m32: Float, m33: Float, m34: Float
  public var m41: Float, m42: Float, m43: Float, m44: Float

  public init(
    _ m11: Float, _ m12: Float, _ m13: Float, _ m14: Float,
    _ m21: Float, _ m22: Float, _ m23: Float, _ m24: Float,
    _ m31: Float, _ m32: Float, _ m33: Float, _ m34: Float,
    _ m41: Float, _ m42: Float, _ m43: Float, _ m44: Float
  ) {
    self.m11 = m11
    self.m12 = m12
    self.m13 = m13
    self.m14 = m14
    self.m21 = m21
    self.m22 = m22
    self.m23 = m23
    self.m24 = m24
    self.m31 = m31
    self.m32 = m32
    self.m33 = m33
    self.m34 = m34
    self.m41 = m41
    self.m42 = m42
    self.m43 = m43
    self.m44 = m44
  }
}

extension Mat44 {
  @inline(__always)
  public var cValue: JPH_Mat4 {
    JPH_Mat4(
      column: (
        JPH_Vec4(x: m11, y: m21, z: m31, w: m41),
        JPH_Vec4(x: m12, y: m22, z: m32, w: m42),
        JPH_Vec4(x: m13, y: m23, z: m33, w: m43),
        JPH_Vec4(x: m14, y: m24, z: m34, w: m44)
      )
    )
  }
  @inline(__always)
  public init(_ c: JPH_Mat4) {
    self.init(
      c.column.0.x, c.column.1.x, c.column.2.x, c.column.3.x,
      c.column.0.y, c.column.1.y, c.column.2.y, c.column.3.y,
      c.column.0.z, c.column.1.z, c.column.2.z, c.column.3.z,
      c.column.0.w, c.column.1.w, c.column.2.w, c.column.3.w
    )
  }
}

@frozen
public struct RMat44 {
  public var m11: Float, m12: Float, m13: Float, m14: Float
  public var m21: Float, m22: Float, m23: Float, m24: Float
  public var m31: Float, m32: Float, m33: Float, m34: Float
  public var m41: Float, m42: Float, m43: Float, m44: Float

  public init(
    _ m11: Float, _ m12: Float, _ m13: Float, _ m14: Float,
    _ m21: Float, _ m22: Float, _ m23: Float, _ m24: Float,
    _ m31: Float, _ m32: Float, _ m33: Float, _ m34: Float,
    _ m41: Float, _ m42: Float, _ m43: Float, _ m44: Float
  ) {
    self.m11 = m11
    self.m12 = m12
    self.m13 = m13
    self.m14 = m14
    self.m21 = m21
    self.m22 = m22
    self.m23 = m23
    self.m24 = m24
    self.m31 = m31
    self.m32 = m32
    self.m33 = m33
    self.m34 = m34
    self.m41 = m41
    self.m42 = m42
    self.m43 = m43
    self.m44 = m44
  }
}

extension RMat44 {
  @inline(__always)
  public var cValue: JPH_RMat4 {
    JPH_RMat4(
      column: (
        JPH_Vec4(x: m11, y: m21, z: m31, w: m41),
        JPH_Vec4(x: m12, y: m22, z: m32, w: m42),
        JPH_Vec4(x: m13, y: m23, z: m33, w: m43),
        JPH_Vec4(x: m14, y: m24, z: m34, w: m44)
      )
    )
  }
  @inline(__always)
  public init(_ c: JPH_RMat4) {
    self.init(
      c.column.0.x, c.column.1.x, c.column.2.x, c.column.3.x,
      c.column.0.y, c.column.1.y, c.column.2.y, c.column.3.y,
      c.column.0.z, c.column.1.z, c.column.2.z, c.column.3.z,
      c.column.0.w, c.column.1.w, c.column.2.w, c.column.3.w
    )
  }
}

@frozen
public struct AABB {
  public var min: Vec3
  public var max: Vec3

  public init(min: Vec3, max: Vec3) {
    self.min = min
    self.max = max
  }
}

extension AABB {
  @inline(__always)
  public var cValue: JPH_AABox { JPH_AABox(min: min.cValue, max: max.cValue) }
  @inline(__always)
  public init(_ c: JPH_AABox) { self.init(min: Vec3(c.min), max: Vec3(c.max)) }
}
@frozen
public struct Plane {
  public var normal: Vec3
  public var distance: Float

  public init(normal: Vec3, distance: Float) {
    self.normal = normal
    self.distance = distance
  }
}

extension Plane {
  @inline(__always)
  public var cValue: JPH_Plane { JPH_Plane(normal: normal.cValue, distance: distance) }
  @inline(__always)
  public init(_ c: JPH_Plane) { self.init(normal: Vec3(c.normal), distance: c.distance) }
}

@frozen
public struct Triangle {
  public var v1: Vec3
  public var v2: Vec3
  public var v3: Vec3
  public var materialIndex: UInt32

  public init(v1: Vec3, v2: Vec3, v3: Vec3, materialIndex: UInt32 = 0) {
    self.v1 = v1
    self.v2 = v2
    self.v3 = v3
    self.materialIndex = materialIndex
  }
}

extension Triangle {
  @inline(__always)
  public var cValue: JPH_Triangle {
    JPH_Triangle(v1: v1.cValue, v2: v2.cValue, v3: v3.cValue, materialIndex: materialIndex)
  }
  @inline(__always)
  public init(_ c: JPH_Triangle) {
    self.init(v1: Vec3(c.v1), v2: Vec3(c.v2), v3: Vec3(c.v3), materialIndex: c.materialIndex)
  }
}

@frozen
public struct IndexedTriangle {
  public var i1: UInt32
  public var i2: UInt32
  public var i3: UInt32
  public var materialIndex: UInt32
  public var userData: UInt32

  public init(i1: UInt32, i2: UInt32, i3: UInt32, materialIndex: UInt32 = 0, userData: UInt32 = 0) {
    self.i1 = i1
    self.i2 = i2
    self.i3 = i3
    self.materialIndex = materialIndex
    self.userData = userData
  }
}

extension IndexedTriangle {
  @inline(__always)
  public var cValue: JPH_IndexedTriangle {
    JPH_IndexedTriangle(i1: i1, i2: i2, i3: i3, materialIndex: materialIndex, userData: userData)
  }
  @inline(__always)
  public init(_ c: JPH_IndexedTriangle) {
    self.init(i1: c.i1, i2: c.i2, i3: c.i3, materialIndex: c.materialIndex, userData: c.userData)
  }
}
