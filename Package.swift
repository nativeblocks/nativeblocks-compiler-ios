// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "NativeblocksCompiler",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(name: "NativeblocksCompiler", targets: ["NativeblocksCompiler"]),
        .plugin(name: "GenerateProvider", targets: ["GenerateProvider"]),
        .executable(name: "NativeblocksCompilerClient", targets: ["NativeblocksCompilerClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .macro(
            name: "NativeblocksCompilerMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        .plugin(
            name: "GenerateProvider",
            capability: .command(
                intent: .custom(
                    verb: "GenerateProvider",
                    description: "prints hello world"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "This command write the new Provider to the source root."),
                ]
            )
        ),
        .target(
            name: "NativeblocksCompiler",
            dependencies: ["NativeblocksCompilerMacros"]
        ),

        .executableTarget(name: "NativeblocksCompilerClient", dependencies: ["NativeblocksCompiler"]),
        .testTarget(
            name: "NativeblocksCompilerTests",
            dependencies: [
                "NativeblocksCompilerMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
