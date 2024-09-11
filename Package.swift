// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "NativeblocksCompiler",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(name: "NativeblocksCompiler", targets: ["NativeblocksCompiler"]),
        .library(name: "NativeblocksCompilerCommon", targets: ["NativeblocksCompilerCommon"]),
        .plugin(name: "GenerateProvider", targets: ["GenerateProvider"]),
        .plugin(name: "GenerateJson", targets: ["GenerateJson"]),
        .executable(name: "NativeblocksTool", targets: ["NativeblocksTool"]),
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
                "NativeblocksCompilerCommon"
            ]
        ),

        .plugin(
            name: "GenerateProvider",
            capability: .command(
                intent: .custom(
                    verb: "GenerateProvider",
                    description: "Generate Provider"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "This command write the new Provider to the source root."),
                ]
            ),
            dependencies: [
                .target(name: "NativeblocksTool"),
            ]
        ),

        .plugin(
            name: "GenerateJson",
            capability: .command(
                intent: .custom(
                    verb: "GenerateJson",
                    description: "Generate Json"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "This command write the new json blocks to the source root."),
                ]
            ),
            dependencies: [
                .target(name: "NativeblocksTool"),
            ]
        ),

        .executableTarget(
            name: "NativeblocksTool",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                "NativeblocksCompilerCommon"
            ]
        ),
        .target(
            name: "NativeblocksCompiler",
            dependencies: ["NativeblocksCompilerMacros"]
        ),
        
        .target(
            name: "NativeblocksCompilerCommon",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "NativeblocksCompilerTests",
            dependencies: [
                "NativeblocksCompilerMacros",
                "NativeblocksCompilerCommon",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),

        .testTarget(
            name: "NativeblocksToolTests",
            dependencies: [
                "NativeblocksTool",
                "NativeblocksCompilerCommon",
            ]
        ),
    ]
)
