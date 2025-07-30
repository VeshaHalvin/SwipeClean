// MARK: - SwipeCleanView
/// The main photo management interface with Tinder-style swipe interactions
///
/// Features:
/// - Swipe-based photo management (right to keep, left to delete)
/// - Visual feedback during swipe gestures
/// - Smooth animations and transitions
/// - Premium access control
/// - Empty state handling
///
/// This view provides an intuitive interface for quickly reviewing and
/// managing photos through swipe gestures with visual feedback.

import SwiftUI

// MARK: - Main View
struct SwipeCleanView: View {
    // MARK: - Properties
    
    /// View model containing the photo library data
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    
    /// Index of the currently displayed photo
    @State private var currentIndex = 0
    
    /// Current offset of the photo during swipe gesture
    @State private var offset: CGSize = .zero
    
    /// Background color that changes based on swipe direction
    @State private var backgroundColor = Color.black.opacity(0.001)
    
    /// Current rotation angle of the photo
    @State private var rotation = 0.0
    
    /// Current scale factor of the photo
    @State private var scale: CGFloat = 1.0
    
    /// Flag to show premium upgrade alert
    @State private var showPremiumAlert = false
    
    // MARK: - Computed Properties
    
    /// The currently displayed photo, if available
    private var currentPhoto: Photo? {
        guard currentIndex < viewModel.swipeCleanPhotos.count else { return nil }
        return viewModel.swipeCleanPhotos[currentIndex]
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // MARK: - Premium Gate
                if !viewModel.isPremium {
                    VStack(spacing: 20) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("Premium Feature")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Upgrade to Premium to access the SwipeClean feature and manage unlimited photos!")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        // MARK: - Upgrade Button
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
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                    }
                    .padding()
                } else {
                    // MARK: - Main Photo Interface
                    backgroundColor
                        .animation(.easeInOut(duration: 0.3), value: backgroundColor)
                        .ignoresSafeArea()
                    
                    VStack {
                        if let photo = currentPhoto {
                            // MARK: - Photo Card
                            ZStack {
                                Image(uiImage: photo.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 400)
                                    .cornerRadius(12)
                                    .offset(offset)
                                    .rotationEffect(.degrees(rotation))
                                    .scaleEffect(scale)
                                    // MARK: - Swipe Gesture
                                    .gesture(
                                        DragGesture()
                                            .onChanged { gesture in
                                                // Update visual feedback during swipe
                                                offset = gesture.translation
                                                
                                                // Calculate rotation based on horizontal movement
                                                let rotationAngle = Double(gesture.translation.width / 300) * 25
                                                rotation = rotationAngle
                                                
                                                // Update background color based on drag direction
                                                if gesture.translation.width > 0 {
                                                    // Dragging right (keep)
                                                    backgroundColor = Color.green.opacity(min(0.2, Double(gesture.translation.width) / 300))
                                                } else {
                                                    // Dragging left (delete)
                                                    backgroundColor = Color.red.opacity(min(0.2, Double(-gesture.translation.width) / 300))
                                                }
                                                
                                                // Scale down slightly while dragging
                                                scale = 1.0 - min(0.1, abs(Double(gesture.translation.width)) / 1000)
                                            }
                                            .onEnded { gesture in
                                                // Handle swipe completion
                                                let width = gesture.translation.width
                                                if abs(width) > 100 {
                                                    // Swipe threshold met
                                                    if width > 0 {
                                                        // Swipe right - keep
                                                        withAnimation(.easeOut) {
                                                            offset.width = 500
                                                            rotation = 20
                                                        }
                                                    } else {
                                                        // Swipe left - delete
                                                        withAnimation(.easeOut) {
                                                            offset.width = -500
                                                            rotation = -20
                                                        }
                                                        viewModel.moveToBin(photo)
                                                    }
                                                    
                                                    // Move to next photo after animation
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                        currentIndex += 1
                                                        offset = .zero
                                                        rotation = 0
                                                        scale = 1.0
                                                        backgroundColor = Color.black.opacity(0.001)
                                                    }
                                                } else {
                                                    // Reset if swipe threshold not met
                                                    withAnimation(.spring()) {
                                                        offset = .zero
                                                        rotation = 0
                                                        scale = 1.0
                                                        backgroundColor = Color.black.opacity(0.001)
                                                    }
                                                }
                                            }
                                    )
                                
                                // MARK: - Action Indicators
                                HStack {
                                    Image(systemName: "trash.circle.fill")
                                        .foregroundColor(.red)
                                        .opacity(offset.width < -20 ? 1 : 0)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "heart.circle.fill")
                                        .foregroundColor(.green)
                                        .opacity(offset.width > 20 ? 1 : 0)
                                }
                                .font(.system(size: 42))
                                .padding(40)
                            }
                            
                            // MARK: - Instructions
                            Text("Swipe right to keep, left to delete")
                                .foregroundColor(.gray)
                                .padding(.top, 30)
                        } else {
                            // MARK: - Empty State
                            VStack(spacing: 16) {
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("No Photos to Review")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                Text("Add more photos or check back later")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("SwipeClean")
        }
        // MARK: - Premium Alert
        .alert("Upgrade to Premium", isPresented: $showPremiumAlert) {
            Button("Purchase ($4.99)", role: .none) {
                viewModel.upgradeToPremium()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Get unlimited access to SwipeClean and all premium features!")
        }
    }
}

// MARK: - Preview Provider
struct SwipeCleanView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeCleanView()
            .environmentObject(PhotoLibraryViewModel())
    }
}

