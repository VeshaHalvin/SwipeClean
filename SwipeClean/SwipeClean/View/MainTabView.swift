// MARK: - MainTabView
/// The main navigation container view for the SwipeClean app
///
/// This view provides the tab-based navigation structure with four main sections:
/// - Discover: Browse and view photos organized by date
/// - SwipeClean: Main photo management interface
/// - PhotoBin: Temporary storage for photos marked for deletion
/// - Settings: App configuration and premium features
///
/// The tab bar uses system SF Symbols for consistent iOS-style navigation

import SwiftUI

// MARK: - Main View
struct MainTabView: View {
    // MARK: - Body
    
    /// The main view hierarchy for the tab-based navigation
    var body: some View {
        TabView {
            // MARK: - Discover Tab
            /// Shows photos organized by date with "On This Date" feature
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "calendar")
                }

            // MARK: - SwipeClean Tab
            /// Main interface for managing and organizing photos
            SwipeCleanView()
                .tabItem {
                    Label("SwipeClean", systemImage: "hand.draw")
                }

            // MARK: - PhotoBin Tab
            /// Temporary storage for photos marked for deletion
            PhotoBinView()
                .tabItem {
                    Label("PhotoBin", systemImage: "trash")
                }

            // MARK: - Settings Tab
            /// App settings and premium features management
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

// MARK: - Preview Provider
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
