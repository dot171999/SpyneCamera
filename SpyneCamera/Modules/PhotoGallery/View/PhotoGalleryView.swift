//
//  PhotoGalleryView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 10/11/24.
//

import SwiftUI
import RealmSwift

struct PhotoGalleryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel = PhotoGalleryViewModel()
    @State private var presentSheet: Photo? = nil
    @ObservedResults(Photo.self, sortDescriptor: SortDescriptor(keyPath: "captureDate", ascending: false)) private var photos
    
    private let lazyVGridRowSpacing: CGFloat = 2
    private let lazyVGridColumns: [GridItem] = [GridItem(spacing: 2), GridItem(spacing: 2), GridItem(spacing: 0)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: lazyVGridColumns, spacing: lazyVGridRowSpacing) {
                ForEach(photos, id: \.self) { photo in
                    UploadableImageView(progress: viewModel.progress(for: photo), photo: photo)
                        .onTapGesture {
                            presentSheet = photo
                        }
                }
                #if targetEnvironment(simulator)
                ForEach(0..<50, id: \.self) { photo in
                    UploadableImageView(progress: Float.random(in: 0...1), photo: Photo())
                        .onTapGesture {
                            presentSheet = Photo()
                        }
                }
                #endif
            }
        }
        .safeAreaInset(edge: .top, spacing: 0, content: {
            if viewModel.isUploading {
                HStack(spacing: 20) {
                    Button {
                        
                    } label: {
                        Image(systemName: "pause.fill")
                    }.padding(.horizontal, 10)
                    ProgressView(value: viewModel.totalUploadProgress)
                        .scaleEffect(y: 1.5)
                    Text("\(Int((viewModel.totalUploadProgress * 100).rounded()))%")
                }
                .padding()
                .transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom)))
                .background(colorScheme == .dark ? .black : .white)
            }
        })
        .alert("Error", isPresented: $viewModel.showErrorAlert, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(viewModel.errorMessage)
        })
        .sheet(item: $presentSheet, content: { photo in
            ExpandedPhotoView(photo: photo)
        })
        .task {
            await viewModel.upload(photos)
        }
    }
}

#Preview {
    let congif = Realm.Configuration(inMemoryIdentifier:  UUID().uuidString)
    return PhotoGalleryView()
        .environment(\.realmConfiguration, congif)
}
