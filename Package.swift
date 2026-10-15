// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "APSSPMediationFyber",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "APSSPMediationFyber", targets: ["APSSPMediationFyber"]),
    ],
    dependencies: [
        .package(url: "https://github.com/IGAWorksDev/ap-APSSPSDK-SPM.git", from: "3.4.0"),
        .package(url: "https://github.com/inner-active/DTExchangeSDK-iOS-SPM.git", exact: "8.5.0"),
    ],
    targets: [
        .target(name: "APSSPMediationFyber",
                dependencies: [
                    .product(name: "APSSPSDK", package: "ap-APSSPSDK-SPM"),
                    .product(name: "DTExchangeSDK", package: "DTExchangeSDK-iOS-SPM"),
                ],
                path: "Sources/MediationFyber"),
    ]
)
