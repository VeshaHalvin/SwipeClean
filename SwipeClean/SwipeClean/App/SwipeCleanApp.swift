// MARK: - SwipeCleanApp
/// The main entry point for the SwipeClean application
///
/// This app provides a streamlined interface for managing photos with features including:
/// - Photo organization and discovery
/// - Batch photo management
/// - Temporary deletion bin
/// - Premium features
///
/// The app uses a shared PhotoLibraryViewModel as the main data source,
/// which is injected into the view hierarchy using SwiftUI's environment object pattern.

import SwiftUI

// MARK: - Main App Structure
@main
struct SwipeCleanApp: App {
    // MARK: - Properties
    
    /// The main view model that manages the photo library and app state
    /// Created as a StateObject to persist throughout the app's lifecycle
    @StateObject private var viewModel = PhotoLibraryViewModel()

    // MARK: - Scene Configuration
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(viewModel) // Inject the view model into the environment
        }
    }
}
