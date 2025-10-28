// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "jolt",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .library(name: "Jolt", targets: ["Jolt"])
  ],
  targets: [
    .target(
      name: "Jolt",
      dependencies: ["CJolt"],
      path: "swift",
      swiftSettings: [
        .swiftLanguageMode(.v5)
        //.interoperabilityMode(.Cxx),
      ]
    ),
    .target(
      name: "CJolt",
      path: ".",
      exclude: [
        "swift",
        "samples",
        "JoltPhysics/UnitTests",
        "JoltPhysics/Samples",
        "JoltPhysics/TestFramework",
        "JoltPhysics/PerformanceTest",
        "JoltPhysics/JoltViewer",
        "JoltPhysics/HelloWorld",
        "JoltPhysics/Assets",
      ],
      cxxSettings: [
        .headerSearchPath("JoltPhysics"),
        .define("JPH_DEBUG_RENDERER"),
        .define("JPH_OBJECT_LAYER_BITS", to: "32"),
      ],
    ),
  ],
  cxxLanguageStandard: .cxx17
)
