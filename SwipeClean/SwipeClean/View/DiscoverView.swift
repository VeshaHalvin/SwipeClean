//
//  DiscoverView.swift
//  SwipeClean
//
//  Created by 20 on 2025/6/3.
//

// MARK: - DiscoverView
// Main view for discovering and browsing photos organized by date and months
// Features:
// - Premium banner for non-premium users
// - "On This Date" featured photo section
// - Monthly photo collections with expandable galleries
// - Photo detail view navigation
// - Pull to refresh functionality

import SwiftUI

struct DiscoverView: View {
    // MARK: - Properties
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    @State private var selectedPhoto: Photo?
    @State private var isShowingDetail = false
    @State private var showPremiumAlert = false
    @State private var expandedMonth: String?
    
    // Layout Constants
    private let rowHeight: CGFloat = 140
    private let spacing: CGFloat = 8
    private let photosPerRow = 3
    
    // MARK: - Main View Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Premium Banner Section
                    if !viewModel.isPremium {
                        ZStack {
                            Button {
                                showPremiumAlert = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "crown.fill")
                                        .font(.title2)
                                        .foregroundColor(.yellow)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Upgrade to Premium")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text("Unlock unlimited photos")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("$4.99")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue)
                                        .clipShape(Capsule())
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contentShape(Rectangle())
                        }
                        .zIndex(1) // Ensure the banner stays on top
                    }
                    
                    // MARK: - On This Date Section
                    // Algorithm:
                    // 1. Get first available photo
                    // 2. Display date header
                    // 3. Show featured photo with tap interaction
                    if let todayPhoto = viewModel.availablePhotos.first {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(formatDate(todayPhoto.date))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("On This Date")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal)
                        
                        ZStack {
                            Image(uiImage: todayPhoto.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 240)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .onTapGesture {
                                    selectedPhoto = todayPhoto
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        isShowingDetail = true
                                    }
                                }
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Monthly Sections
                    // Algorithm:
                    // 1. Group photos by month
                    // 2. For each month:
                    //    - Show month header
                    //    - If expanded: Display grid view with all photos
                    //    - If collapsed: Show preview with first 3 photos
                    // 3. Handle expand/collapse interactions
                    ForEach(groupedPhotos.keys.sorted(), id: \.self) { month in
                        if let monthPhotos = groupedPhotos[month] {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(month)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                if expandedMonth == month {
                                    // Expanded View with scrollable rows
                                    VStack(spacing: spacing) {
                                        ForEach(0..<Int(ceil(Double(monthPhotos.count) / Double(photosPerRow))), id: \.self) { rowIndex in
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: spacing) {
                                                    let startIndex = rowIndex * photosPerRow
                                                    let endIndex = min(startIndex + photosPerRow, monthPhotos.count)
                                                    ForEach(monthPhotos[startIndex..<endIndex]) { photo in
                                                        Image(uiImage: photo.image)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: rowHeight, height: rowHeight)
                                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                                            .onTapGesture {
                                                                selectedPhoto = photo
                                                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                                                    isShowingDetail = true
                                                                }
                                                            }
                                                    }
                                                }
                                                .padding(.horizontal)
                                            }
                                        }
                                    }
                                    
                                    Button(action: {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            expandedMonth = nil
                                        }
                                    }) {
                                        Text("Show Less")
                                            .foregroundColor(.blue)
                                            .padding(.horizontal)
                                            .padding(.top, 8)
                                    }
                                } else {
                                    // Collapsed Preview
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(monthPhotos.prefix(3)) { photo in
                                                ZStack(alignment: .bottomTrailing) {
                                                    Image(uiImage: photo.image)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: rowHeight, height: rowHeight)
                                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                                        .onTapGesture {
                                                            selectedPhoto = photo
                                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                                                isShowingDetail = true
                                                            }
                                                        }
                                                    
                                                    if monthPhotos.count > 3 && photo.id == monthPhotos[2].id {
                                                        Button(action: {
                                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                                                expandedMonth = month
                                                            }
                                                        }) {
                                                            ZStack {
                                                                Color.black.opacity(0.7)
                                                                Text("+\(monthPhotos.count - 3)")
                                                                    .font(.title3)
                                                                    .fontWeight(.bold)
                                                                    .foregroundColor(.white)
                                                            }
                                                            .frame(width: rowHeight, height: rowHeight)
                                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Discover")
            // MARK: - Toolbar Items
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Refresh Button
                    // - Animates during refresh
                    // - Disabled while refreshing
                    Button {
                        viewModel.refreshPhotos()
                    } label: {
                        Image(systemName: viewModel.isRefreshing ? "arrow.clockwise.circle.fill" : "arrow.clockwise.circle")
                            .font(.system(size: 22))
                            .rotationEffect(.degrees(viewModel.isRefreshing ? 360 : 0))
                            .animation(viewModel.isRefreshing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isRefreshing)
                    }
                    .disabled(viewModel.isRefreshing)
                }
            }
            .overlay {
                if viewModel.isRefreshing {
                    ProgressView()
                }
            }
        }
        // MARK: - Photo Detail Overlay
        .overlay {
            if isShowingDetail, let photo = selectedPhoto {
                PhotoDetailView(isShowingDetail: $isShowingDetail, photo: photo, namespace: Namespace().wrappedValue)
            }
        }
        // MARK: - Premium Upgrade Alert
        .alert("Upgrade to Premium", isPresented: $showPremiumAlert) {
            Button("Purchase ($4.99)", role: .none) {
                viewModel.upgradeToPremium()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Unlock unlimited photo review and all premium features!")
        }
    }
    
    // MARK: - Helper Methods
    
    /// Groups photos by month
    /// Returns: Dictionary with month string as key and array of photos as value
    private var groupedPhotos: [String: [Photo]] {
        Dictionary(grouping: viewModel.availablePhotos) { photo in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            return dateFormatter.string(from: photo.date)
        }
    }
    
    /// Formats date to "Month day" format
    /// - Parameter date: Date to format
    /// - Returns: Formatted date string
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Preview Provider
//struct DiscoverView_Previews: PreviewProvider {
//    static var previews: some View {
//        DiscoverView()
//            .environmentObject(PhotoLibraryViewModel())
//    }
//}
