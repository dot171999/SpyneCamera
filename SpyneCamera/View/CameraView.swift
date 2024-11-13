//
//  CameraView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 10/11/24.
//

import SwiftUI
import AVFoundation
import Foundation

struct CameraView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var viewModel = CameraViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            CameraPreview(image: viewModel.capturedImage)
            ZStack {
                HStack {
                    CapturedPhotoPreview(image: viewModel.cameraPreviewFrameImage)
                    Spacer()
                }
                ShutterButton {
                    viewModel.clickPhoto()
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            guard await viewModel.isAuthorized else { return }
            await viewModel.captureSessionManager.configureSession()
            await viewModel.captureSessionManager.startSession()
        }
        .onDisappear {
            Task {
                await viewModel.captureSessionManager.stopSession()
            }
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
            }
    }
    
    @ViewBuilder
    func CapturedPhotoPreview(image: UIImage?) -> some View {
        Rectangle()
            .frame(width: 50, height: 50, alignment: .center)
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .clipShape(.rect(cornerRadius: 10))
    }
    
    @ViewBuilder
    func ShutterButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(width: 70, height: 70, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(colorScheme == .dark ? .black : .white, lineWidth: 2)
                        .frame(width: 58, height: 58, alignment: .center)
                )
        }
    }
}

#Preview {
    CameraView()
}
