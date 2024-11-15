//
//  CameraView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 10/11/24.
//

import SwiftUI
import AVFoundation
import Foundation
import RealmSwift

struct CameraView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel = CameraViewModel()
    @ObservedResults(Photo.self, sortDescriptor: SortDescriptor(keyPath: "captureDate", ascending: false)) private var photos
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            CameraPreview(image: viewModel.cameraPreviewFrameImage)
            ZStack {
                HStack {
                    let image = viewModel.capturedImage
                    CapturedPhotoPreview(image: image == nil ? UIImage(contentsOfFile: photos.first?.urlPathString ?? "") : image)
                    Spacer()
                }
                ShutterButton {
                    viewModel.clickPhoto()
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .alert("Error", isPresented: $viewModel.showErrorAlert, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(viewModel.errorMessage)
        })
        .task {
            await viewModel.setup()
        }
        .onDisappear {
            viewModel.stopSession()
        }
    }
}

extension CameraView {
    @ViewBuilder
    func CameraPreview(image: UIImage?) -> some View {
        Rectangle()
            .foregroundStyle(colorScheme == .dark ? .black : .white)
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                #if targetEnvironment(simulator)
                Image("Image")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea(edges: .top)
                #endif
            }
    }
    
    @ViewBuilder
    func CapturedPhotoPreview(image: UIImage?) -> some View {
        Rectangle()
            .frame(width: 65, height: 65, alignment: .center)
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                #if targetEnvironment(simulator)
                Image("Image1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea(edges: .top)
                #endif
            }
            .clipShape(.rect(cornerRadius: 10))
            .onTapGesture {
                action()
            }
    }
    
    @ViewBuilder
    func ShutterButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(width: 80, height: 80, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(colorScheme == .dark ? .black : .white, lineWidth: 2)
                        .frame(width: 68, height: 68, alignment: .center)
                )
        }
    }
}

#Preview {
    let congif = Realm.Configuration(inMemoryIdentifier:  UUID().uuidString)
    return CameraView(action: {})
        .environment(\.realmConfiguration, congif)
}
