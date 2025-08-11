import ProjectDescription

let project = Project(
    name: "CursorStatsTool",
    targets: [
        .target(
            name: "CursorStatsTool",
            destinations: .macOS,
            product: .app,
            bundleId: "com.tinder.cursorstatstool.CursorStatsTool",
            deploymentTargets: .macOS("14.7"),
            infoPlist: .default,
            sources: ["CursorStatsTool/**"],
            resources: [
                "CursorStatsTool/Assets.xcassets",
                "CursorStatsTool/Preview Content/**"
            ],
            entitlements: .file(path: "CursorStatsTool/CursorStatsTool.entitlements"),
            settings: .settings(
                base: [
                    "MARKETING_VERSION": "1.0",
                    "CURRENT_PROJECT_VERSION": "1",
                    "DEVELOPMENT_TEAM": "",
                    "CODE_SIGN_STYLE": "Automatic",
                    "ENABLE_HARDENED_RUNTIME": "YES",
                    "COMBINE_HIDPI_IMAGES": "YES",
                    "ENABLE_APP_SANDBOX": "YES",
                    "SWIFT_VERSION": "5.0"
                ]
            )
        )
    ]
)
