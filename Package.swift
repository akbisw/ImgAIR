// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "imgair",
    dependencies: [
	.Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 7),
	.Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 7),
	.Package(url: "https://github.com/IBM-Swift/Kitura-CouchDB.git", majorVersion: 1, minor: 7),
    .Package(url: "https://github.com/SwiftOnTheServer/SwiftDotEnv.git", majorVersion: 1, minor: 1),
    ]
)
