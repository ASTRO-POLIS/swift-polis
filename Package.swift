// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-polis",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v12), .iOS(.v15), .tvOS(.v11), .watchOS(.v5)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "swift-polis", targets: ["swift-polis"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "SoftwareEtudes", url: "https://github.com/tuparev/SoftwareEtudes", .branch("dev")),
        .package(name: "ScienceEtudes",  url: "https://github.com/tuparev/ScienceEtudes",  .branch("dev"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "swift-polis",
            dependencies: [
                .product(name: "SoftwareEtudesUtilities", package: "SoftwareEtudes"),
                .product(name: "UnitsAndMeasurements",    package: "ScienceEtudes"),
            ]
        ),
        .testTarget(
            name: "swift-polisTests",
            dependencies: ["swift-polis"]),
    ]
)
