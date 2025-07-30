// MARK: - SettingsView
/// The settings and configuration view for the SwipeClean app
///
/// Features:
/// - Premium status management
/// - Premium feature showcase
/// - Usage statistics
/// - Legal information
/// - Purchase and restore functionality
///
/// This view handles all app settings and premium feature management,
/// providing a central location for user configuration and premium upgrades.

import SwiftUI

// MARK: - Main View
struct SettingsView: View {
    // MARK: - Properties
    
    /// View model containing the photo library and premium status data
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    
    /// Flag to show premium purchase alert
    @State private var showPremiumAlert = false
    
    /// Flag to show premium reset confirmation alert
    @State private var showResetAlert = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            List {
                // MARK: - Premium Section
                Section {
                    VStack(spacing: 16) {
                        // MARK: - Premium Status Header
                        HStack {
                            if viewModel.isPremium {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                Text("Premium Member")
                                    .bold()
                                Spacer()
                                Text("Active")
                                    .foregroundColor(.green)
                            } else {
                                HStack {
                                    Spacer()
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.yellow)
                                    Spacer()
                                }
                            }
                        }
                        
                        // MARK: - Premium Upgrade UI
                        if !viewModel.isPremium {
                            Text("Unlock Premium")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Get unlimited access to all features")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            // MARK: - Premium Features List
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Premium Features:")
                                    .font(.headline)
                                    .padding(.bottom, 4)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    FeatureRow(icon: "photo.stack", text: "Unlimited photo review")
                                    FeatureRow(icon: "arrow.clockwise", text: "Faster refresh rate")
                                    FeatureRow(icon: "wand.and.stars", text: "Advanced sorting options")
                                    FeatureRow(icon: "arrow.triangle.2.circlepath", text: "Priority updates")
                                    FeatureRow(icon: "star.fill", text: "Premium support")
                                }
                            }
                            .padding(.vertical, 8)
                            
                            // MARK: - Purchase Actions
                            Button(action: {
                                showPremiumAlert = true
                            }) {
                                HStack {
                                    Text("Upgrade Now")
                                        .fontWeight(.semibold)
                                    Text("$4.99")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            
                            // MARK: - Restore Purchases
                            Button(action: {
                                viewModel.restorePurchases()
                            }) {
                                HStack {
                                    Text("Restore Purchases")
                                        .foregroundColor(.blue)
                                    if viewModel.isProcessingPurchase {
                                        Spacer()
                                        ProgressView()
                                    }
                                }
                            }
                            .disabled(viewModel.isProcessingPurchase)
                            
                            // MARK: - Error Display
                            if let error = viewModel.purchaseError {
                                Text(error)
                                    .font(.footnote)
                                    .foregroundColor(.red)
                            }
                        } else {
                            // MARK: - Premium Member UI
                            VStack(spacing: 12) {
                                Text("Thank you for supporting SwipeClean!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    showResetAlert = true
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.counterclockwise")
                                        Text("Reset Premium Status")
                                    }
                                    .foregroundColor(.red)
                                }
                                .disabled(viewModel.isProcessingPurchase)
                            }
                        }
                    }
                    .padding(.vertical)
                } header: {
                    Text("Premium Status")
                }
                
                // MARK: - Statistics Section
                Section {
                    HStack {
                        Text("Photos Reviewed")
                        Spacer()
                        Text("\(viewModel.importedPhotos.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Photos in Bin")
                        Spacer()
                        Text("\(viewModel.photoBin.count)")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Statistics")
                }
                
                // MARK: - Legal Section
                Section {
                    Link(destination: URL(string: "https://www.example.com/privacy")!) {
                        Text("Privacy Policy")
                    }
                    
                    Link(destination: URL(string: "https://www.example.com/terms")!) {
                        Text("Terms of Service")
                    }
                } header: {
                    Text("Legal")
                }
            }
            .navigationTitle("Settings")
        }
        // MARK: - Alerts
        .alert("Confirm Premium Upgrade", isPresented: $showPremiumAlert) {
            Button("Purchase ($4.99)", role: .none) {
                viewModel.upgradeToPremium()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Unlock unlimited photo review and all premium features!")
        }
        .alert("Reset Premium Status", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) {
                viewModel.resetPremiumStatus()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove your premium status. You'll need to purchase again to restore premium features.")
        }
    }
}

// MARK: - Feature Row View
/// A reusable view component for displaying premium features
struct FeatureRow: View {
    // MARK: - Properties
    
    /// The SF Symbol name for the feature icon
    let icon: String
    
    /// The description text of the feature
    let text: String
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(text)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview Provider
//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//            .environmentObject(PhotoLibraryViewModel())
//    }
//}
