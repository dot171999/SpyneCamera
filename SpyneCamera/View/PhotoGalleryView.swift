//
//  PhotoGalleryView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 10/11/24.
//

import SwiftUI

struct PhotoGalleryView: View {
    @Environment(\.colorScheme) private var colorScheme
    private let scrollViewContentMargin: CGFloat = 10
    private let lazyVGridRowSpacing: CGFloat = 2
    private let lazyVGridColumns: [GridItem] = [GridItem(.flexible(), spacing: 2), GridItem(.flexible())]
    private var lazyVGridColumnSpacing : CGFloat {
        lazyVGridColumns.first?.spacing ?? 2
    }
    @State private var progress = 0.8
    var body: some View {
        GeometryReader { geometry in
            let itemHeight = (geometry.size.width - (scrollViewContentMargin * 2) - lazyVGridColumnSpacing) / 2
            
            ScrollView {
                LazyVGrid(columns: lazyVGridColumns, spacing: lazyVGridRowSpacing) {
                    ForEach(0..<20, id: \.self) { _ in
                        UploadableImageView(itemHeight: itemHeight, progress: 0.5)
                    }
                }
            }
            .contentMargins(.horizontal , scrollViewContentMargin, for: .scrollContent)
        }
    }
}

struct UploadableImageView: View {
    @Environment(\.colorScheme) private var colorScheme
    let itemHeight: CGFloat
    let progress: Float
    
    var body: some View {
        Rectangle()
            .frame(height: itemHeight)
            .foregroundStyle(.red)
            .overlay(alignment: .bottom) {
                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "play.fill")
                    }
                    ProgressView(value: progress)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(colorScheme == .dark ? .white : .black)
                
            }
    }
}

#Preview {
    PhotoGalleryView()
}
