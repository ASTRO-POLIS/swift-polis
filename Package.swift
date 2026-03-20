// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-polis",
    defaultLocalization: "en",
    platforms: [.macOS(.v26), .iOS(.v26), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "SwiftPolis", targets: ["SwiftPolis"]),
        .executable(name: "polis", targets: ["polis"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/tuparev/SoftwareEtudes", branch: "new_logger"),
        .package(url: "https://github.com/tuparev/ScienceEtudes",  branch: "dev"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftPolis",
            dependencies: [
                .product(name: "SoftwareEtudesUtilities",              package: "SoftwareEtudes"),
                .product(name: "SoftwareEtudesLogging",                package: "SoftwareEtudes"),
                .product(name: "SoftwareEtudesCoreMessageDispatching", package: "SoftwareEtudes"),
                .product(name: "UnitsAndMeasurements",                 package: "ScienceEtudes"),
            ],
            path: "Sources/SwiftPolis"
        ),
        .executableTarget(
            name: "polis",
            dependencies: [
                .product(name: "SoftwareEtudesUtilities",               package: "SoftwareEtudes"),
                .product(name: "SoftwareEtudesExecutableConfiguration", package: "SoftwareEtudes"),
                "SwiftPolis",
            ],
            path: "Sources/polis-tool"
        ),
        .testTarget(
            name: "SwiftPolisTests",
            dependencies: ["SwiftPolis"]),
    ]
)

