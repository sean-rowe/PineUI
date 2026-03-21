// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PineUI",
    products: [
        .library(name: "PineUI", targets: ["PineUI"]),
        .executable(name: "pine-demo", targets: ["PineDemo"]),
    ],
    targets: [
        // System module: wraps GTK4 C headers for Swift import.
        .systemLibrary(
            name: "CGTK4",
            pkgConfig: "gtk4",
            providers: [
                .apt(["libgtk-4-dev"]),
            ]
        ),
        // PineUI: the declarative widget library.
        .target(
            name: "PineUI",
            dependencies: ["CGTK4"],
            path: "Sources/PineUI"
        ),
        // Demo app to prove the concept.
        .executableTarget(
            name: "PineDemo",
            dependencies: ["PineUI"],
            path: "Sources/PineDemo"
        ),
        // Todo list app — proof that PineUI works for real apps.
        .executableTarget(
            name: "PineTodo",
            dependencies: ["PineUI"],
            path: "Sources/PineTodo"
        ),
        .testTarget(
            name: "PineUITests",
            dependencies: ["PineUI"],
            path: "Tests/PineUITests"
        ),
    ]
)
