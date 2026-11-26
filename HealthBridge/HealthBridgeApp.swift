import SwiftUI

@main
@MainActor
struct HealthBridgeApp: App {
    @StateObject private var model = ExportViewModel()
    init() { ExportService.clearTemporaryExports() }
    var body: some Scene {
        WindowGroup {
            MainView(model: model)
        }
    }
}
