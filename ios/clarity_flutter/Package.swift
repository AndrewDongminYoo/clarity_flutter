// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "clarity_flutter",
    platforms: [
        .iOS("12.0"),
    ],
    products: [
        .library(name: "clarity-flutter", targets: ["clarity_flutter"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "clarity_flutter",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        ),
    ]
)
