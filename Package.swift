// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "ReCaptcha",
	platforms: [
		.iOS(.v12)
		],
	products: [
		.library(
			name: "ReCaptcha",
			targets: ["ReCaptcha"]),
	],
	dependencies: [
		 .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0"),
	],
	targets: [
		.target(
			name: "ReCaptcha",
			dependencies: [], path: "ReCapcha/Classes"),
		.testTarget(
			name: "ReCaptchaTests",
			dependencies: ["ReCaptcha"]),
	]
)

