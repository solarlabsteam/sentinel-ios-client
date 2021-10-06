// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SwiftGenerator",
    defaultLocalization: "en",
    platforms: [.iOS("14.0")],
    dependencies: [
        .package(url: "https://github.com/solarlabsteam/SwiftGen", .branch("fix-xcode-13")),
    ],
    targets: [
        .target(
            name: "SwiftGenerator",
            path: "DVPNApp",
            resources: [
                .process("swiftgen.yml"),
            ]
        ),
    ]
)
